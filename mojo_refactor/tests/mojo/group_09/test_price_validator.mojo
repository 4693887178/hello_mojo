"""
Test for mod/rqmojo_mod_sys_risk/validators/price_validator.mojo
Group 09 - File 2
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import PriceValidator, create_price_validator

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_price_validator_init() raises:
    print("Test: PriceValidator init")
    var _ = create_price_validator(True)
    print("  PASSED")


def test_price_validator_enabled() raises:
    print("Test: PriceValidator enabled")
    var validator = create_price_validator(True)
    assert_true(validator.enabled, "Validator should be enabled")
    print("  PASSED")


def test_price_validator_disabled() raises:
    print("Test: PriceValidator disabled")
    var validator = create_price_validator(False)
    assert_false(validator.enabled, "Validator should be disabled")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
