# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBT_CLI_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config"

# install runtime packages and qbittorrent-cli
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    icu-libs \
    p7zip \
    python3 \
    qt6-qtbase-sqlite \
    qbittorrent-nox && \
  echo "***** install qbittorrent-cli ****" && \
  mkdir -p /qbt && \
  if [ -z "${QBT_CLI_VERSION}" ]; then \
    QBT_CLI_VERSION=$(curl -sL "https://api.github.com/repos/fedarovich/qbittorrent-cli/releases/latest" | jq -r '.tag_name'); \
  fi && \
  curl -L -o /tmp/qbt.tar.gz \
    "https://github.com/fedarovich/qbittorrent-cli/releases/download/${QBT_CLI_VERSION}/qbt-linux-alpine-x64-net6-${QBT_CLI_VERSION#v}.tar.gz" && \
  tar -xf /tmp/qbt.tar.gz -C /qbt && \
  chmod +x /qbt/qbt && \
  printf "Linuxserver.io version: %s\nBuild-date: %s\n" "${VERSION}" "${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf /root/.cache /tmp/*

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME ["/config"]
