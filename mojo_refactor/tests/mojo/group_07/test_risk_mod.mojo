"""
Test for mod/rqmojo_mod_sys_risk/mod.mojo
Group 07 - File 05
"""

from rqmojo.mod.rqmojo_mod_sys_risk.mod import (
    RiskMod, PriceValidator, CashValidator, SelfTradeValidator,
    create_risk_mod, create_price_validator, create_cash_validator, create_self_trade_validator
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

fn create_test_order() raises -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )

def test_risk_mod_init() raises:
    print("Test: RiskMod init")
    var mod = create_risk_mod()
    assert_equal(mod.name, "risk", "Mod name should be 'risk'")
    print("  PASSED")


def test_risk_mod_start() raises:
    print("Test: RiskMod start")
    var mod = create_risk_mod()
    mod.start()
    print("  PASSED")


def test_risk_mod_stop() raises:
    print("Test: RiskMod stop")
    var mod = create_risk_mod()
    mod.stop()
    print("  PASSED")


def test_price_validator() raises:
    print("Test: PriceValidator")
    var validator = create_price_validator(enabled=True)
    var order = create_test_order()
    var result = validator.validate(order, 11.5, 9.5)
    assert_true(result, "Price validation should pass")
    print("  PASSED")


def test_cash_validator() raises:
    print("Test: CashValidator")
    var validator = create_cash_validator(enabled=True, min_cash=1000.0)
    var order = create_test_order()
    var result = validator.validate(order, 5000.0)
    assert_true(result, "Cash validation should pass")
    print("  PASSED")


def test_self_trade_validator() raises:
    print("Test: SelfTradeValidator")
    var validator = create_self_trade_validator(enabled=True)
    var order = create_test_order()
    var result = validator.validate_order(order)
    assert_true(result, "Self trade validation should pass")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
