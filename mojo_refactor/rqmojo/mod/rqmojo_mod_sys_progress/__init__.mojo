"""
RQAlpha Mojo - Progress Mod Init
Ported from rqalpha/mod/rqalpha_mod_sys_progress/__init__.py

Python original provides:
  - __config__: {"show": False}
  - load_mod(): returns ProgressMod()
  - CLI injection: --progress flag via click.Option
  - cli_prefix = "mod__sys_progress__"
"""

from rqmojo.mod.rqmojo_mod_sys_progress.mod import ProgressMod, ProgressBar, create_progress_mod
from rqmojo.mod.utils import ConfigValue
from argmojo import Argument, Command
from std.collections import Dict, List


def get_config() -> Dict[String, ConfigValue]:
    """Get module config, corresponds to Python __config__ = {'show': False}."""
    var config = Dict[String, ConfigValue]()
    config["show"] = ConfigValue(False)
    return config^


def get_cli_prefix() -> String:
    """Get CLI argument prefix, corresponds to Python cli_prefix."""
    return "mod__sys_progress__"


def get_cli_options() -> List[Argument]:
    """Get CLI options list, corresponds to Python click.Option('--progress', ...)."""
    var options = List[Argument]()

    options.append(
        Argument(name="progress", help="[sys_progress] show progress bar")
            .long["progress"]().flag()
    )

    return options^


def register_cli_options(mut cmd: Command) raises -> None:
    """Register CLI options to command, corresponds to Python cli.commands['run'].params.append."""
    for option in get_cli_options():
        cmd.add_argument(option.copy())


def load_mod() -> ProgressMod:
    """Load module instance, corresponds to Python load_mod()."""
    return create_progress_mod()


comptime __all__: List[String] = [
    "ProgressMod",
    "ProgressBar",
    "create_progress_mod",
    "get_config",
    "get_cli_prefix",
    "get_cli_options",
    "register_cli_options",
    "load_mod",
]
