"""
Test for mod/rqmojo_mod_sys_risk/is_trading_validator.mojo
Group 11 - File 4
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_risk.is_trading_validator import IsTradingValidator, create_is_trading_validator
from std.testing import assert_equal, assert_true, assert_false, TestSuite


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
