"""
Test suite for rqmojo/mod/rqmojo_mod_sys_progress/__init__.mojo
Tests all exported functions: get_config, get_cli_prefix, get_cli_options, load_mod.
"""

from rqmojo.mod.rqmojo_mod_sys_progress import (
    ProgressMod, ProgressBar, create_progress_mod,
    get_config, get_cli_prefix, get_cli_options,
    register_cli_options, load_mod,
)
from argmojo import Argument, Command

from std.testing import (
    assert_equal, assert_true, assert_false, TestSuite,
)


def test_load_mod_returns_progress_mod() raises:
    var mod = load_mod()
    assert_equal(mod.name, "progress")
    assert_false(mod._show)
    assert_true(mod._progress_bar == None)


def test_load_mod_returns_correct_type() raises:
    var mod = load_mod()
    assert_equal(mod.name, "progress")


def test_get_config_exists() raises:
    var config = get_config()
    assert_true(len(config) > 0)


def test_get_config_has_show_key() raises:
    var config = get_config()
    assert_true("show" in config)


def test_get_config_show_default_false() raises:
    var config = get_config()
    var show_val = config["show"]
    assert_true(show_val.isa[Bool]())
    assert_false(show_val[Bool])


def test_get_cli_prefix_value() raises:
    var prefix = get_cli_prefix()
    assert_equal(prefix, "mod__sys_progress__")


def test_get_cli_prefix_is_string() raises:
    var prefix = get_cli_prefix()
    assert_true(len(prefix) > 0)


def test_get_cli_options_returns_list() raises:
    var options = get_cli_options()
    assert_true(len(options) > 0)


def test_get_cli_options_has_progress_flag() raises:
    var options = get_cli_options()
    assert_equal(len(options), 1)
    var opt = options[0].copy()
    assert_equal(opt.name, "progress")


def test_register_cli_options_on_command() raises:
    var cmd = Command("test", "test command")
    register_cli_options(cmd)


def test_create_progress_mod_factory() raises:
    var mod = create_progress_mod()
    assert_equal(mod.name, "progress")


def test_progress_bar_importable_from_init() raises:
    var bar = ProgressBar(length=100)
    assert_equal(bar._length, 100)


def test_progress_mod_importable_from_init() raises:
    mod: ProgressMod = ProgressMod()
    assert_equal(mod.name, "progress")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
