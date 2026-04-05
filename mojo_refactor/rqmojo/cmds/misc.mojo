"""
RQAlpha Mojo - Misc Commands Module
Ported from rqalpha/cmds/misc.py

Uses argmojo for CLI command definition (replacing Python click).
Uses Mojo standard library for all file operations.
Minimizes Python interop to only package path discovery.
"""

from std.collections import Dict
from std.os import makedirs, listdir, remove
from std.os.path import exists as path_exists
from std.pathlib import Path, cwd

from argmojo import Command, Argument, ParseResult
from rqmojo.utils.i18n import gettext as `__`


def _copy_file(src_path: String, dst_path: String) raises -> None:
    """Copy a single file using pure Mojo I/O with buffered read/write."""
    comptime BUF_SIZE = 8192
    var src = open(src_path, "r")
    var dst = open(dst_path, "w")

    var buffer = InlineArray[UInt8, BUF_SIZE](fill=0)

    while True:
        var n = src.read[DType.uint8](Span[UInt8](buffer))
        if n <= 0:
            break
        _ = dst.write_once(Span[UInt8](buffer)[0:n])

    src.close()
    dst.close()


def _is_directory(p: String) -> Bool:
    """Check if path is a directory by attempting listdir."""
    try:
        _ = listdir(p)
        return True
    except:
        return False


def _copytree(source: String, destination: String) raises -> Int:
    """
    Recursively copy directory tree from source to destination.
    Pure Mojo implementation replacing shutil.copytree.
    Returns 0 on success, 1 on error.
    """
    if not path_exists(source):
        print("Source path does not exist: ", source)
        return 1

    makedirs(destination)

    var entries = listdir(source)
    for entry in entries:
        var entry_name = String(entry)
        var src_path = source + "/" + entry_name
        var dst_path = destination + "/" + entry_name

        if _is_directory(src_path):
            var sub_result = _copytree(src_path, dst_path)
            if sub_result != 0:
                return sub_result
        else:
            try:
                _copy_file(src_path, dst_path)
            except e:
                print("Failed to copy file: ", src_path, " -> ", dst_path, " (", String(e), ")")
                return 1

    return 0


def run_examples(directory: String) raises -> Int:
    """Core logic: Generate example strategies to target folder."""
    from std.python import Python

    var py = Python.import_module("rqalpha")
    var py_os = Python.import_module("os")

    var rqalpha_file = py.__file__
    var source_dir = String(py=py_os.path.join(
    py_os.path.dirname(rqalpha_file), "examples"
    ))
    var dest_path = String(py=py_os.path.abspath(
    py_os.path.join(directory, "examples")
    ))

    if path_exists(dest_path):
        print("Folder examples exists.")
        return 0

    print(source_dir, " ", dest_path)
    return _copytree(source_dir, dest_path)


def examples(directory: String) raises -> Int:
    """Backward-compatible alias for run_examples()."""
    return run_examples(directory)


def run_version() raises -> Int:
    """Core logic: Output Version Info."""
    from rqmojo._version import __version__

    print("Current Version: ", __version__)
    return 0


def version(kwargs: Dict[String, String] = Dict[String, String]()) raises -> Int:
    """Backward-compatible alias for run_version(). Accepts kwargs dict (ignored)."""
    return run_version()


def run_generate_config(directory: String) raises -> Int:
    """Core logic: Generate default config file in the target directory."""
    from std.python import Python

    var py = Python.import_module("rqalpha")
    var py_os = Python.import_module("os")

    var rqalpha_file = py.__file__
    var rqalpha_dir = String(py=py_os.path.dirname(rqalpha_file))
    var default_config = rqalpha_dir + "/config.yml"

    var target_config_path = String(py=py_os.path.abspath(
    py_os.path.join(directory, "config.yml")
    ))

    if not path_exists(default_config):
        print("Default config file not found at: ", default_config)
        return 1

    try:
        _copy_file(default_config, target_config_path)
        print("Config file has been generated in ", target_config_path)
        return 0
    except e:
        print("Failed to generate config file: ", String(e))
        return 1


def generate_config(directory: String) raises -> Int:
    """Backward-compatible alias for run_generate_config()."""
    return run_generate_config(directory)


def print_version() raises -> None:
    """Print the current version info."""
    _ = run_version()


# ── argmojo CLI Commands (replacing @click decorators) ──────────────────


def create_examples_command() raises -> Command:
    """Create the 'examples' subcommand using argmojo.

    Replaces: @cli.command(help=...) / @click.option('-d','--directory',...)
    """
    var cmd = Command(
        "examples", `__`("Generate example strategies to target folder")
    )
    cmd.add_argument(
        Argument("directory", help="Target directory path")
        .long["directory"]()
        .short["d"]()
        .default["./"]()
        .required()
    )
    return cmd^


def create_version_command() raises -> Command:
    """Create the 'version' subcommand using argmojo.

    Replaces: @cli.command(help=...) / @click.option('-v','--version', is_flag=True)
    """
    var cmd = Command("version", `__`("Output Version Info"))
    cmd.add_argument(
        Argument("version_flag", help="Show version info")
        .long["version"]()
        .short["v"]()
        .flag()
    )
    return cmd^


def create_generate_config_command() raises -> Command:
    """Create the 'generate_config' subcommand using argmojo.

    Replaces: @cli.command(help=...) / @click.option('-d','--directory',...)
    """
    var cmd = Command(
        "generate_config", `__`("Generate default config file")
    )
    cmd.add_argument(
        Argument("directory", help="Target directory path")
        .long["directory"]()
        .short["d"]()
        .default["./"]()
        .required()
    )
    return cmd^


def register_misc_commands(mut cli: Command) raises -> None:
    """Register all misc subcommands onto the main CLI group.

    Call this from entry.mojo after creating the root cli Command.
    Equivalent to Python's @cli.command() decorator pattern.
    """
    cli.add_subcommand(create_examples_command())
    cli.add_subcommand(create_version_command())
    cli.add_subcommand(create_generate_config_command())


def dispatch_misc_command(result: ParseResult) raises -> Int:
    """Dispatch to the correct core function based on parsed subcommand result.

    Args:
        result: ParseResult from cli.parse() where subcommand is 'examples',
                'version', or 'generate_config'.

    Returns:
        Exit code (0 = success, 1 = error).
    """
    var sub_name = result.subcommand
    var sub_result = result.get_subcommand_result()

    if sub_name == "examples":
        var directory = sub_result.get_string("directory")
        return run_examples(directory)

    elif sub_name == "version":
        return run_version()

    elif sub_name == "generate_config":
        var directory = sub_result.get_string("directory")
        return run_generate_config(directory)

    else:
        print("Unknown misc command: ", sub_name)
        return 1
