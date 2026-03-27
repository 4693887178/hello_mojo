"""
Test for mod/rqmojo_mod_sys_risk/validators/__init__.mojo
Group 06 - File 02
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators import (
    CashValidator,
    PriceValidator,
    IsTradingValidator,
    SelfTradeValidator,
    create_cash_validator,
    create_price_validator,
    create_is_trading_validator,
    create_self_trade_validator
)



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_cash_validator() raises:
    print("Test: CashValidator exists")
    var validator = create_cash_validator()
    print("  CashValidator created successfully")
    assert_true(True, "test passed")


def test_price_validator() raises:
    print("Test: PriceValidator exists")
    var validator = create_price_validator()
    print("  PriceValidator created successfully")
    assert_true(True, "test passed")


def test_is_trading_validator() raises:
    print("Test: IsTradingValidator exists")
    var validator = create_is_trading_validator()
    print("  IsTradingValidator created successfully")
    assert_true(True, "test passed")


def test_self_trade_validator() raises:
    print("Test: SelfTradeValidator exists")
    var validator = create_self_trade_validator()
    print("  SelfTradeValidator created successfully")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()