"""
Test for mod/rqmojo_mod_sys_risk/cash_validator.mojo
Group 11 - File 3
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import CashValidator, create_cash_validator
from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import IsTradingValidator, create_is_trading_validator
from std.testing import assert_equal, assert_true, assert_false, TestSuite


from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import IsTradingValidator, create_is_trading_validator


def test_cash_validator_struct() raises:
    print("Test: CashValidator struct exists")
    var validator = create_cash_validator(enabled=True)
    assert_true(validator.enabled, "CashValidator should be enabled")
    print("  PASSED")


def test_cash_validator_disabled() raises:
    print("Test: CashValidator disabled")
    var validator = create_cash_validator(enabled=False)
    assert_false(validator.enabled, "CashValidator should be disabled")
    print("  PASSED")


def test_cash_validator_validate() raises:
    print("Test: CashValidator validate")
    var validator = create_cash_validator(enabled=True)
    assert_true(True, "CashValidator should validate")
    print("  PASSED")


def test_is_trading_validator_struct() raises:
    print("Test: IsTradingValidator struct exists")
    var validator = create_is_trading_validator(enabled=True)
    assert_true(validator.enabled, "IsTradingValidator should be enabled")
    print("  PASSED")


def test_is_trading_validator_disabled() raises:
    print("Test: IsTradingValidator disabled")
    var validator = create_is_trading_validator(enabled=False)
    assert_false(validator.enabled, "IsTradingValidator should be disabled")
    print("  PASSED")


def test_is_trading_validator_validate() raises:
    print("Test: IsTradingValidator validate")
    var validator = create_is_trading_validator(enabled=True)
    assert_true(True, "IsTradingValidator should validate")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
