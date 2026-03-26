"""
RQAlpha Mojo - Entry Point
Ported from rqalpha/__main__.py
"""

from rqmojo.cmds.entry import cli, inject_mod_commands


def entry_point() -> None:
    inject_mod_commands()
    cli(obj={})


def main() -> None:
    entry_point()
