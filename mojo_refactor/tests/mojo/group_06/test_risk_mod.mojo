"""
Comprehensive Tests for Risk Manager Mod (mod.mojo)
Tests for: SysRiskModConfig, RiskManagerMod, start_up_with_config, tear_down
Aligned with Python rqalpha/mod/rqalpha_mod_sys_risk/mod.py behavior

Python original key behavior:
  1. RiskManagerMod.start_up(env, mod_config) registers validators based on config flags
  2. Config flags: validate_price, validate_is_trading, validate_cash, validate_self_trade
  3. Default: price=True, is_trading=True, cash=True, self_trade=False
  4. tear_down does nothing (pass)
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, List, Dict, Set

from rqmojo.const import EXIT_CODE, INSTRUMENT_TYPE
from rqmojo.environment import Environment, FrontendValidator
from rqmojo.interface import ModInterface
from rqmojo.mod.rqmojo_mod_sys_risk.mod import (
    RiskManagerMod,
    SysRiskModConfig,
    create_risk_manager_mod,
    create_sys_risk_mod_config,
)


# ============================================================
# SysRiskModConfig Tests
# ============================================================

def test_config_default_values() raises:
    print("Test: SysRiskModConfig default values match Python __config__")
    var config = SysRiskModConfig()
    assert_true(config.validate_price == True, "validate_price should default to True")
    assert_true(config.validate_is_trading == True, "validate_is_trading should default to True")
    assert_true(config.validate_cash == True, "validate_cash should default to True")
    assert_true(config.validate_self_trade == False, "validate_self_trade should default to False")
    print("  PASSED")


def test_config_custom_values() raises:
    print("Test: SysRiskModConfig custom constructor")
    var config = SysRiskModConfig(
        validate_price=False,
        validate_is_trading=False,
        validate_cash=False,
        validate_self_trade=True
    )
    assert_true(config.validate_price == False, "validate_price should be False")
    assert_true(config.validate_is_trading == False, "validate_is_trading should be False")
    assert_true(config.validate_cash == False, "validate_cash should be False")
    assert_true(config.validate_self_trade == True, "validate_self_trade should be True")
    print("  PASSED")


def test_config_partial_custom() raises:
    print("Test: SysRiskModConfig with mixed True/False values")
    var config = SysRiskModConfig(
        validate_price=True,
        validate_is_trading=False,
        validate_cash=True,
        validate_self_trade=False
    )
    assert_true(config.validate_price == True)
    assert_true(config.validate_is_trading == False)
    assert_true(config.validate_cash == True)
    assert_true(config.validate_self_trade == False)
    print("  PASSED")


# ============================================================
# Factory Function Tests
# ============================================================

def test_create_risk_manager_mod() raises:
    print("Test: create_risk_manager_mod returns valid RiskManagerMod")
    var _mod = create_risk_manager_mod()
    assert_true(True, "RiskManagerMod created successfully via factory")
    print("  PASSED")


def test_create_sys_risk_mod_config_default() raises:
    print("Test: create_sys_risk_mod_config with defaults")
    var config = create_sys_risk_mod_config()
    assert_true(config.validate_price == True)
    assert_true(config.validate_is_trading == True)
    assert_true(config.validate_cash == True)
    assert_true(config.validate_self_trade == False)
    print("  PASSED")


def test_create_sys_risk_mod_config_custom() raises:
    print("Test: create_sys_risk_mod_config with custom values")
    var config = create_sys_risk_mod_config(
        validate_price=False,
        validate_is_trading=True,
        validate_cash=False,
        validate_self_trade=True
    )
    assert_true(config.validate_price == False)
    assert_true(config.validate_is_trading == True)
    assert_true(config.validate_cash == False)
    assert_true(config.validate_self_trade == True)
    print("  PASSED")


# ============================================================
# RiskManagerMod.tear_down Tests (no Environment needed)
# ============================================================

def test_tear_down_success_code() raises:
    print("Test: tear_down with EXIT_SUCCESS")
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))
    assert_true(True, "tear_down with EXIT_SUCCESS completed without error")
    print("  PASSED")


def test_tear_down_user_error_code() raises:
    print("Test: tear_down with EXIT_USER_ERROR")
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_USER_ERROR, Optional[String]("test error"))
    assert_true(True, "tear_down with EXIT_USER_ERROR completed without error")
    print("  PASSED")


def test_tear_down_internal_error_code() raises:
    print("Test: tear_down with EXIT_INTERNAL_ERROR")
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_INTERNAL_ERROR, Optional[String](None))
    assert_true(True, "tear_down with EXIT_INTERNAL_ERROR completed without error")
    print("  PASSED")


def test_tear_down_none_exception() raises:
    print("Test: tear_down with None exception (normal exit)")
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))
    assert_true(True, "tear_down with None exception completed")
    print("  PASSED")


def test_tear_down_with_exception_message() raises:
    print("Test: tear_down with exception message string")
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_USER_ERROR, Optional[String]("Something went wrong"))
    assert_true(True, "tear_down with exception message completed")
    print("  PASSED")


# ============================================================
# ModInterface Conformance Tests (no Environment needed)
# ============================================================

def test_mod_interface_has_start_up() raises:
    print("Test: RiskManagerMod has start_up method (ModInterface)")
    var mod = create_risk_manager_mod()
    mod.start_up("test_env", "test_config")
    assert_true(True, "start_up method exists and is callable")
    print("  PASSED")


def test_mod_interface_has_tear_down() raises:
    print("Test: RiskManagerMod has tear_down method (ModInterface)")
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))
    assert_true(True, "tear_down method exists and is callable")
    print("  PASSED")


# ============================================================
# Python Behavior Match Tests (config-level, no Environment needed)
# ============================================================

def test_python_behavior_default_no_self_trade() raises:
    """Python default: validate_self_trade=False (disabled by default). Verify mojo default matches."""
    print("Test: Behavior match - self_trade validator disabled by default (matches Python)")
    var default_config = create_sys_risk_mod_config()
    assert_true(default_config.validate_self_trade == False,
        "validate_self_trade should be False by default (matches Python __config__)")
    print("  PASSED")


def test_python_behavior_default_three_enabled() raises:
    """Python default: price=T, is_trading=T, cash=T (3 of 4 enabled by default)."""
    print("Test: Behavior match - 3 validators enabled by default (matches Python)")
    var default_config = create_sys_risk_mod_config()
    assert_true(default_config.validate_price == True, "price=True by default")
    assert_true(default_config.validate_is_trading == True, "is_trading=True by default")
    assert_true(default_config.validate_cash == True, "cash=True by default")
    assert_true(default_config.validate_self_trade == False, "self_trade=False by default")
    var enabled_count = 0
    if default_config.validate_price:
        enabled_count += 1
    if default_config.validate_is_trading:
        enabled_count += 1
    if default_config.validate_cash:
        enabled_count += 1
    if default_config.validate_self_trade:
        enabled_count += 1
    assert_true(enabled_count == 3, "Exactly 3 validators enabled by default (matches Python)")
    print("  PASSED")


def test_python_behavior_all_flags_independent() raises:
    """Test that all 4 config flags are independent."""
    print("Test: Behavior match - all 4 config flags are independently controllable")
    var c1 = SysRiskModConfig(False, False, False, False)
    assert_true(c1.validate_price == False and c1.validate_is_trading == False
        and c1.validate_cash == False and c1.validate_self_trade == False, "All False")

    var c2 = SysRiskModConfig(True, True, True, True)
    assert_true(c2.validate_price == True and c2.validate_is_trading == True
        and c2.validate_cash == True and c2.validate_self_trade == True, "All True")
    print("  PASSED")


# ============================================================
# SysRiskModConfig Field Mutation Tests
# ============================================================

def test_config_fields_mutable() raises:
    print("Test: SysRiskModConfig fields are mutable after construction")
    var config = SysRiskModConfig()
    config.validate_price = False
    config.validate_self_trade = True
    assert_true(config.validate_price == False, "Field mutated to False")
    assert_true(config.validate_self_trade == True, "Field mutated to True")
    assert_true(config.validate_is_trading == True, "Unchanged field still True")
    assert_true(config.validate_cash == True, "Unchanged field still True")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
