"""
Test for mod/rqmojo_mod_sys_simulation/validator.mojo
Group 07 - File 08
"""

from std.collections import Optional
from rqmojo.mod.rqmojo_mod_sys_simulation.validator import OrderStyleValidator, create_order_style_validator
from rqmojo.model.order import Order, OrderStyle, MarketOrder, create_order_with_id
from rqmojo.const import ORDER_TYPE, SIDE, POSITION_EFFECT
from rqmojo.portfolio.account import Account

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

def test_order_style_validator_init() raises:
    print("Test: OrderStyleValidator init")
    var validator = create_order_style_validator(frequency="1d")
    print("  PASSED")


def test_order_style_validator_validate_order() raises:
    print("Test: OrderStyleValidator validate_order")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.validate_order(order)
    assert_true(result, "Order should be valid")
    print("  PASSED")


def test_order_style_validator_can_submit() raises:
    print("Test: OrderStyleValidator can_submit_order")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.can_submit_order(order)
    assert_true(result, "Should be able to submit order")
    print("  PASSED")


def test_order_style_validator_can_cancel() raises:
    print("Test: OrderStyleValidator can_cancel_order")
    var validator = create_order_style_validator(frequency="1d")
    var result = validator.can_cancel_order(1)
    assert_true(result, "Should be able to cancel order")
    print("  PASSED")


def test_order_style_validator_validate_submission() raises:
    print("Test: OrderStyleValidator validate_submission")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Market order with 1d frequency should pass")
    print("  PASSED")


def test_order_style_validator_validate_cancellation() raises:
    print("Test: OrderStyleValidator validate_cancellation")
    var validator = create_order_style_validator(frequency="1d")
    var order = create_test_order()
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result == None, "validate_cancellation should return None")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
