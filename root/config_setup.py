import configparser
import sys
import os

class CaseSensitiveConfigParser(configparser.ConfigParser):
    """A case-sensitive ConfigParser to preserve case in keys."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, delimiters=('=', ':'), **kwargs)

    def optionxform(self, optionstr):
        """Override option transformation to keep original case."""
        return optionstr

def read_config(file_path):
    """Read the configuration file and return a ConfigParser object."""
    config = CaseSensitiveConfigParser(interpolation=None)
    config.read(file_path)
    return config

def write_config(config, file_path):
    """Write the modified configuration back to the file."""
    with open(file_path, 'w') as config_file:
        config.write(config_file)

def modify_config(config):
    """Modify the configuration as needed."""
    runOnDownloadComplete = os.environ.get('AUTO_RUN_PROGRAM')
    if runOnDownloadComplete is not None:
        print(f'QBT_RUN_PROGRAM: {runOnDownloadComplete}')
        config.set('AutoRun', 'enabled', 'true')
        config.set('AutoRun', 'program', runOnDownloadComplete)
    else:
        print('QBT_RUN_PROGRAM is not set.')
        config.set('AutoRun', 'enabled', 'false')
        config.set('AutoRun', 'program', '')

def print_config(config):
    """Print the entire configuration as a string."""
    config_string = ''
    for section in config.sections():
        config_string += f'[{section}]\n'
        for key, val in config.items(section):
            config_string += f'{key} = {val}\n'
    return config_string

# Path to the configuration file
config_file_path = sys.argv[1]

# Read the configuration from the file
config = read_config(config_file_path)

# Modify the configuration
modify_config(config)

# Write the modified configuration back to the file
write_config(config, config_file_path)

print("Current Configuration:")
print(print_config(config))

print(f"Configuration updated successfully in {config_file_path}")