"""
RQAlpha Mojo - Misc Commands Module
Ported from rqalpha/cmds/misc.py
"""

from std.collections import List
from python import Python


def examples(directory: String) -> Int:
    """Generate example strategies to target folder."""
    var py = Python.import_module("rqalpha")
    var os = Python.import_module("os")
    var shutil = Python.import_module("shutil")
    var errno = Python.import_module("errno")
    
    var source_dir = os.path.join(os.path.dirname(py.__file__), "examples")
    
    try:
        var dest_path = os.path.abspath(os.path.join(directory, "examples"))
        shutil.copytree(source_dir, dest_path)
        print("Examples copied to: " + dest_path)
        return 0
    except:
        print("Folder examples exists or error occurred.")
        return 1


def version(**kwargs) -> Int:
    """Output Version Info."""
    try:
        var py = Python.import_module("rqalpha")
        print("Current Version: ", py.__version__)
        return 0
    except:
        print("Current Version: 0.0.1 (Mojo)")
        return 0


def generate_config(directory: String) -> Int:
    """Generate default config file."""
    var os = Python.import_module("os")
    var shutil = Python.import_module("shutil")
    
    try:
        var default_config = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "config.yml")
        var target_config_path = os.path.abspath(os.path.join(directory, "config.yml"))
        shutil.copy(default_config, target_config_path)
        print("Config file has been generated in " + target_config_path)
        return 0
    except:
        print("Failed to generate config file.")
        return 1


def print_version() -> None:
    """Print version info."""
    version()


def print_help() -> None:
    """Print help info."""
    print("Available commands:")
    print("  examples    - Generate example strategies to target folder")
    print("  version     - Output Version Info")
    print("  generate_config - Generate default config file")


def main():
    print("misc.mojo - Misc commands module loaded successfully")
