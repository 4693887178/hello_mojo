"""
RQAlpha Mojo - Command Line Interface
Ported from rqalpha/cmds/entry.py

Python original uses Click's decorator pattern:
    cli = click.group()          # shared Group object
    @cli.command(help=...))       # decorator auto-registers at import time
    def examples(directory): ...

Mojo equivalent: explicit registration via inject_mod_commands().
The Python cmds/__init__.py imports bundle, mod, run, misc which triggers
@cli.command() decorators. Here we call register_*_commands() explicitly.
"""

from argmojo import Command, ParseResult

from rqmojo.cmds.misc import (
    register_misc_commands,
    dispatch_misc_command,
)


def cli() raises -> Command:
    """Backward-compatible: return an unwired root CLI command.

    Note: subcommands are NOT registered. Use inject_mod_commands()
    for a fully-wired CLI with all subcommands attached.
    """
    var c = Command("rqmojo", "RQAlpha Mojo - Quantitative Investment Framework")
    c.help_on_no_arguments()
    return c^


def inject_mod_commands() raises -> Command:
    """Create and wire up the full CLI with all subcommands registered.

    Equivalent to Python's side-effect-at-import pattern where
    cmds/__init__.py does 'from . import misc' etc., triggering
    @cli.command() decorators that register subcommands onto the shared cli.

    Returns:
        The fully-wired Command with all subcommands registered.
    """
    var c = Command("rqmojo", "RQAlpha Mojo - Quantitative Investment Framework")
    c.help_on_no_arguments()

    register_misc_commands(c)

    return c^


def run_cli() raises -> Int:
    """Parse sys.argv and dispatch to the correct subcommand handler."""
    var c = inject_mod_commands()
    var result = c.parse()

    if result.subcommand != "":
        var sub_name = result.subcommand
        if sub_name == "examples" or sub_name == "version" or sub_name == "generate_config":
            return dispatch_misc_command(result)

    print(result)
    return 0
