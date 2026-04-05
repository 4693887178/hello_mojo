"""
RQAlpha Mojo - Command Line Interface
Ported from rqalpha/cmds/entry.py
"""

from argmojo import Command


def cli() raises -> Command:
    var c = Command("rqmojo", "RQAlpha Mojo - Quantitative Investment Framework")
    # @click.group() implicitly prints usage and exits on no arguments
    # (invoke_without_command=False by default). argmojo requires this
    # explicit call to match the same behavior.
    c.help_on_no_arguments()
    return c^
