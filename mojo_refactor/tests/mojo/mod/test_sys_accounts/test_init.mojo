"""
Test suite for rqmojo/mod/rqmojo_mod_sys_accounts/__init__.mojo
Tests all exported functions: get_config, get_cli_prefix, get_cli_options,
register_cli_options, load_mod.
Also tests ConfigValue from mod/utils.mojo.

Corresponds to Python: rqalpha/mod/rqalpha_mod_sys_accounts/__init__.py

Python original provides:
  - __config__: 10 config items
  - load_mod(): returns AccountMod()
  - CLI injection: 5 click.Options
  - cli_prefix = "mod__sys_accounts__"
"""

from rqmojo.mod.rqmojo_mod_sys_accounts import (
    AccountsMod, create_accounts_mod,
    get_config, get_cli_prefix, get_cli_options,
    register_cli_options, load_mod,
)
from rqmojo.mod.utils import ConfigValue
from argmojo import Argument, Command
from std.testing import assert_equal, assert_true, assert_false, TestSuite


# === get_config() tests ===

def test_get_config_returns_dict() raises:
    var config = get_config()
    assert_true(len(config) == 10)


def test_get_config_stock_t1_is_true() raises:
    var config = get_config()
    var val = config["stock_t1"]
    assert_true(val.as_bool() == True)


def test_get_config_dividend_reinvestment_is_false() raises:
    var config = get_config()
    var val = config["dividend_reinvestment"]
    assert_true(val.as_bool() == False)


def test_get_config_dividend_tax_rate_is_zero() raises:
    var config = get_config()
    var val = config["dividend_tax_rate"]
    assert_true(val.as_float() == 0.0)


def test_get_config_cash_return_by_delisted_is_true() raises:
    var config = get_config()
    var val = config["cash_return_by_stock_delisted"]
    assert_true(val.as_bool() == True)


def test_get_config_auto_switch_order_value_is_false() raises:
    var config = get_config()
    var val = config["auto_switch_order_value"]
    assert_true(val.as_bool() == False)


def test_get_config_validate_stock_position_is_true() raises:
    var config = get_config()
    var val = config["validate_stock_position"]
    assert_true(val.as_bool() == True)


def test_get_config_validate_future_position_is_true() raises:
    var config = get_config()
    var val = config["validate_future_position"]
    assert_true(val.as_bool() == True)


def test_get_config_financing_rate_is_zero() raises:
    var config = get_config()
    var val = config["financing_rate"]
    assert_true(val.as_float() == 0.0)


def test_get_config_financing_stocks_restriction_is_false() raises:
    var config = get_config()
    var val = config["financing_stocks_restriction_enabled"]
    assert_true(val.as_bool() == False)


def test_get_config_futures_settlement_price_type_is_close() raises:
    var config = get_config()
    var val = config["futures_settlement_price_type"]
    assert_equal(val.as_string(), "close")


def test_get_config_all_keys_present() raises:
    var config = get_config()
    var expected_keys = [
        "stock_t1",
        "dividend_reinvestment",
        "dividend_tax_rate",
        "cash_return_by_stock_delisted",
        "auto_switch_order_value",
        "validate_stock_position",
        "validate_future_position",
        "financing_rate",
        "financing_stocks_restriction_enabled",
        "futures_settlement_price_type",
    ]
    for key in expected_keys:
        assert_true(key in config, String("Missing config key: ") + key)


# === get_cli_prefix() tests ===

def test_get_cli_prefix_value() raises:
    var prefix = get_cli_prefix()
    assert_equal(prefix, "mod__sys_accounts__")


def test_get_cli_prefix_not_empty() raises:
    var prefix = get_cli_prefix()
    assert_true(len(prefix) > 0)


# === get_cli_options() tests ===

def test_get_cli_options_returns_five_options() raises:
    var options = get_cli_options()
    assert_equal(len(options), 5)


def test_cli_option_1_stock_t1_negatable_flag() raises:
    var options = get_cli_options()
    var opt = options[0].copy()
    assert_equal(opt.name, "mod__sys_accounts__stock_t1")
    assert_true(opt._is_flag)
    assert_true(opt._is_negatable)


def test_cli_option_2_dividend_reinvestment_flag() raises:
    var options = get_cli_options()
    var opt = options[1].copy()
    assert_equal(opt.name, "mod__sys_accounts__dividend_reinvestment")
    assert_true(opt._is_flag)


def test_cli_option_3_cash_return_negatable_flag() raises:
    var options = get_cli_options()
    var opt = options[2].copy()
    assert_equal(opt.name, "mod__sys_accounts__cash_return_by_stock_delisted")
    assert_true(opt._is_flag)
    assert_true(opt._is_negatable)


def test_cli_option_4_short_stock_negatable_flag() raises:
    var options = get_cli_options()
    var opt = options[3].copy()
    assert_equal(opt.name, "mod__sys_accounts__validate_stock_position")
    assert_true(opt._is_flag)
    assert_true(opt._is_negatable)


def test_cli_option_5_futures_settlement_string_option() raises:
    var options = get_cli_options()
    var opt = options[4].copy()
    assert_equal(opt.name, "mod__sys_accounts__futures_settlement_price_type")
    assert_false(opt._is_flag)
    assert_equal(opt._value_name, "TYPE")


def test_cli_options_all_have_help_text() raises:
    var options = get_cli_options()
    for i in range(len(options)):
        var opt = options[i].copy()
        assert_true(
            len(opt.help_text) > 0,
            String("Option '") + opt.name + "' missing help text"
        )


def test_cli_options_help_contains_sys_accounts_tag() raises:
    var options = get_cli_options()
    for i in range(len(options)):
        var opt = options[i].copy()
        assert_true(
            "[sys_accounts]" in opt.help_text,
            String("Option '") + opt.name + "' help missing [sys_accounts] tag"
        )


# === register_cli_options() tests ===

def test_register_cli_options_on_command() raises:
    var cmd = Command("test-run", "test run command")
    register_cli_options(cmd)


def test_register_cli_options_idempotent() raises:
    var cmd = Command("test-run", "test run command")
    register_cli_options(cmd)
    register_cli_options(cmd)


# === load_mod() tests ===

def test_load_mod_returns_accounts_mod() raises:
    var acct = load_mod()
    assert_equal(acct.name, "accounts")


def test_load_mod_enabled_by_default() raises:
    var acct = load_mod()
    assert_true(acct.enabled == True)


def test_load_mod_account_count_zero_initially() raises:
    var acct = load_mod()
    assert_equal(acct.account_count, 0)


def test_create_accounts_mod_factory() raises:
    var acct = create_accounts_mod()
    assert_equal(acct.name, "accounts")
    assert_true(acct.enabled == True)


def test_accounts_mod_importable_from_init() raises:
    var instance = AccountsMod(name="test", enabled=True, account_count=0)
    assert_equal(instance.name, "test")


# === ConfigValue tests (from mod/utils.mojo) ===

def test_config_value_bool_true() raises:
    var cv = ConfigValue(True)
    assert_true(cv.as_bool() == True)


def test_config_value_bool_false() raises:
    var cv = ConfigValue(False)
    assert_true(cv.as_bool() == False)


def test_config_value_float_positive() raises:
    var cv = ConfigValue(3.14)
    assert_true(cv.as_float() == 3.14)


def test_config_value_float_zero() raises:
    var cv = ConfigValue(0.0)
    assert_true(cv.as_float() == 0.0)


def test_config_value_int_positive() raises:
    var cv = ConfigValue(42)
    assert_true(cv.as_int() == 42)


def test_config_value_int_zero() raises:
    var cv = ConfigValue(0)
    assert_true(cv.as_int() == 0)


def test_config_value_string() raises:
    var cv = ConfigValue("close")
    assert_equal(cv.as_string(), "close")


def test_config_value_copy_constructor() raises:
    var original = ConfigValue(99.9)
    var copied = original.copy()
    assert_true(copied.as_float() == 99.9)


def test_config_value_default_values_are_none() raises:
    var cv = ConfigValue(True)
    assert_true(cv.float_value.__eq__(None))
    assert_true(cv.int_value.__eq__(None))
    assert_true(cv.string_value.__eq__(None))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
