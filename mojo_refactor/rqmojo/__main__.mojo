"""
RQAlpha Mojo - Entry Point
Ported from rqalpha/__main__.py
"""

from rqmojo.cmds.entry import cli, inject_mod_commands, run_cli


def entry_point() -> Int:
    """Main entry point: wire up CLI, parse args, dispatch."""
    return run_cli()


def main() -> None:
    var exit_code = entry_point()
    if exit_code != 0:
        pass
