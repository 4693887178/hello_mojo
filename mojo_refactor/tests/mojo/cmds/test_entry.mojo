"""
Test for entry.mojo - Command Line Interface Entry
Compares behavior with Python rqalpha/cmds/entry.py cli()
Uses std.testing standard framework.
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.collections import List

from argmojo import Command


def cli() raises -> Command:
    from rqmojo.cmds.entry import cli as _cli
    return _cli()


def test_cli_returns_command() raises:
    """Cli() returns a Command instance (equivalent to Python's click.Group)."""
    var c = cli()
    assert_true(c.name == "rqmojo", "Command name should be 'rqmojo'")


def test_cli_is_command_group() raises:
    """Cli() creates a command group (no handler, just a container for subcommands)."""
    var c = cli()
    assert_true(len(c.name) > 0, "Command should have a name")


def test_cli_has_description() raises:
    """Cli() has description text (equivalent to Click group docstring)."""
    var c = cli()
    assert_true(len(c.description) > 0, "Command should have description")


def test_cli_no_subcommands_by_default() raises:
    """Fresh cli() has no registered subcommands.
    Subcommands are added externally via add_subcommand(),
    mirroring Python's @cli.command() decorator pattern."""
    var c = cli()
    var empty = len(c.subcommands) == 0
    assert_true(empty, "cli() should have 0 subcommands initially")


def test_cli_accepts_add_subcommand() raises:
    """External modules can register subcommands on cli().
    Mirrors: from .entry import cli; @cli.command() def run(): ...
    Note: argmojo auto-inserts a 'help' subcommand on first add_subcommand()."""
    var c = cli()
    var sub = Command("test-cmd", "A test subcommand")
    c.add_subcommand(sub^)
    assert_true(len(c.subcommands) >= 1, "Should have at least 1 subcommand after add_subcommand")
    assert_true(c.subcommands[0].name == "test-cmd" or c.subcommands[1].name == "test-cmd", "Subcommand name should match")


def test_cli_multiple_calls_independent() raises:
    """Each call to cli() returns a fresh Command.
    Equivalent to Python where cli is a function returning a new group each time."""
    var c1 = cli()
    var c2 = cli()
    c1.add_subcommand(Command("only-in-c1", ""))
    assert_equal(len(c2.subcommands), 0, "c2 should not be affected by c1 mutation")


def main() raises:
    print("=" * 60)
    print("RQMojo Test: cmds/entry.mojo vs Python entry.py")
    print("=" * 60)
    print("")

    TestSuite.discover_tests[__functions_in_module()]().run()
