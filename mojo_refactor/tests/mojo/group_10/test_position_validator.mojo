"""
Test for mod/rqmojo_mod_sys_accounts/position_validator.mojo
Group 10 - File 3
"""

from std.collections import Dict, List, Optional
from rqmojo.mod.rqmojo_mod_sys_accounts.position_validator import PositionValidator, create_position_validator
from rqmojo.model.order import Order, create_order_with_id, MarketOrder
from rqmojo.const import SIDE, POSITION_EFFECT
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_position_validator_struct() raises:
    print("Test: PositionValidator struct exists")
    var validator = create_position_validator(enabled=True)
    assert_true(validator.enabled, "Validator should be enabled")
    print("  PASSED")


def test_position_validator_disabled() raises:
    print("Test: PositionValidator disabled")
    var validator = create_position_validator(enabled=False)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )
    var result = validator.validate_submission(order, "stock")
    assert_true(result is None, "Disabled validator should return None")
    print("  PASSED")


def test_position_validator_can_submit() raises:
    print("Test: PositionValidator can_submit_order")
    var validator = create_position_validator(enabled=True)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    assert_true(validator.can_submit_order(order), "Should be able to submit order")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
