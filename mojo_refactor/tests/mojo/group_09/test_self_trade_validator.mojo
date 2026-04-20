"""
Test for mod/rqmojo_mod_sys_risk/validators/self_trade_validator.mojo
Group 09 - File 3
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator, create_self_trade_validator

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_self_trade_validator_init() raises:
    print("Test: SelfTradeValidator init")
    var _ = create_self_trade_validator(True)
    print("  PASSED")


def test_self_trade_validator_enabled() raises:
    print("Test: SelfTradeValidator enabled")
    var validator = create_self_trade_validator(True)
    assert_true(validator.enabled, "Validator should be enabled")
    print("  PASSED")


def test_self_trade_validator_disabled() raises:
    print("Test: SelfTradeValidator disabled")
    var validator = create_self_trade_validator(False)
    assert_false(validator.enabled, "Validator should be disabled")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
