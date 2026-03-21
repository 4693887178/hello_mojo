"""
RQAlpha Mojo - Misc Commands Module
Ported from rqalpha/cmds/misc.py
"""

from std.collections import List, Dict
from python import Python


def examples(directory: String) raises -> Int:
    var py = Python.import_module("rqalpha")
    var os = Python.import_module("os")
    var shutil = Python.import_module("shutil")
    
    var source_dir = os.path.join(os.path.dirname(py.__file__), "examples")
    
    try:
        var dest_path = os.path.abspath(os.path.join(directory, "examples"))
        shutil.copytree(source_dir, dest_path)
        print("Examples copied to: " + dest_path)
        return 0
    except:
        print("Folder examples exists or error occurred.")
        return 1


def version(kwargs: Dict[String, String] = Dict[String, String]()) raises -> Int:
    try:
        var py = Python.import_module("rqalpha")
        print("Current Version: ", py.__version__)
        return 0
    except:
        print("Current Version: 0.0.1 (Mojo)")
        return 0


def generate_config(directory: String) raises -> Int:
    var os = Python.import_module("os")
    var shutil = Python.import_module("shutil")
    var builtins = Python.import_module("builtins")
    
    try:
        var cwd = os.getcwd()
        var default_config = os.path.join(cwd, "config.yml")
        var target_config_path = os.path.abspath(os.path.join(directory, "config.yml"))
        var content = builtins.open(default_config, "r").read()
        builtins.open(target_config_path, "w").write(content)
        print("Config file has been generated in " + target_config_path)
        return 0
    except:
        print("Failed to generate config file.")
        return 1


def print_version() raises -> None:
    _ = version()


def print_help() -> None:
    print("Available commands:")
    print("  examples    - Generate example strategies to target folder")
    print("  version     - Output Version Info")
    print("  generate_config - Generate default config file")


def main():
    print("misc.mojo - Misc commands module loaded successfully")
