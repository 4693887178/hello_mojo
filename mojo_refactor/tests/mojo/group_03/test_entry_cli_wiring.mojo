"""
Test for entry.mojo CLI wiring
Verifies that inject_mod_commands() properly registers misc subcommands,
replicating Python's 'from .entry import cli' + @cli.command() pattern.
"""

from rqmojo.cmds.entry import cli, inject_mod_commands, run_cli
from rqmojo.cmds.misc import (
    create_examples_command,
    create_version_command,
    create_generate_config_command,
)

from std.testing import assert_equal, assert_true, TestSuite


def test_cli_function_exists() raises:
    var c = cli()
    assert_equal(c.name, "rqmojo")


def test_cli_is_unwired_by_default() raises:
    var c = cli()
    assert_true(len(c.subcommands) == 0)


def test_inject_mod_commands_returns_command() raises:
    var wired = inject_mod_commands()
    assert_equal(wired.name, "rqmojo")
    assert_true(len(wired.subcommands) >= 3)


def test_inject_registers_examples_subcommand() raises:
    var wired = inject_mod_commands()
    assert_true(wired._find_subcommand("examples") >= 0)


def test_inject_registers_version_subcommand() raises:
    var wired = inject_mod_commands()
    assert_true(wired._find_subcommand("version") >= 0)


def test_inject_registers_generate_config_subcommand() raises:
    var wired = inject_mod_commands()
    assert_true(wired._find_subcommand("generate_config") >= 0)


def test_misc_help_text_translated_in_wired_cli() raises:
    from rqmojo.utils.i18n import set_locale
    set_locale("zh_CN")
    var wired = inject_mod_commands()

    var examples_idx = wired._find_subcommand("examples")
    assert_true(examples_idx >= 0)
    var examples_cmd = wired.subcommands[examples_idx].copy()
    assert_true("样例" in examples_cmd.description)


def test_all_three_misc_commands_registered() raises:
    var wired = inject_mod_commands()
    var names = List[String]()
    for sc in wired.subcommands:
        names.append(sc.name)

    assert_true("examples" in names)
    assert_true("version" in names)
    assert_true("generate_config" in names)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
