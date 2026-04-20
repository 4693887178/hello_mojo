"""
Test for mod/rqmojo_mod_sys_simulation/validator.mojo
Comprehensive unit tests for OrderStyleValidator

Tests cover:
  1. Constructor and factory function
  2. validate_order always returns True
  3. can_submit_order always returns True
  4. can_cancel_order always returns True
  5. validate_submission - market order with 1d frequency (pass)
  6. validate_submission - market order with 1m frequency (pass)
  7. validate_submission - market order with tick frequency (pass)
  8. validate_submission - limit order with 1d frequency (pass)
  9. validate_submission - limit order with 1m frequency (pass)
  10. validate_submission - limit order with tick frequency (pass)
  11. validate_submission - algo order with 1d frequency (pass)
  12. validate_submission - algo order with 1m frequency (fail)
  13. validate_submission - algo order with tick frequency (fail)
  14. validate_cancellation always returns None
  15. Error message content matches Python original
  16. Optional[Account] parameter handling
"""

from std.collections import Optional
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

from rqmojo.mod.rqmojo_mod_sys_simulation.validator import OrderStyleValidator, create_order_style_validator
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.const import ORDER_TYPE, SIDE, POSITION_EFFECT
from rqmojo.portfolio.account import Account, create_stock_account


fn algo_order_style() -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.ALGO, limit_price=0.0)


fn create_market_order() -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


fn create_limit_order(price: Float64 = 10.0) -> Order:
    return create_order_with_id(
        order_id=2,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.OPEN
    )


fn create_algo_order() -> Order:
    return create_order_with_id(
        order_id=3,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=algo_order_style(),
        position_effect=POSITION_EFFECT.OPEN
    )


def test_constructor_default_frequency() raises:
    var validator = OrderStyleValidator()
    assert_equal(validator.frequency, "1d", "Default frequency should be '1d'")


def test_constructor_custom_frequency() raises:
    var validator = OrderStyleValidator(frequency="1m")
    assert_equal(validator.frequency, "1m", "Custom frequency should be '1m'")


def test_constructor_tick_frequency() raises:
    var validator = OrderStyleValidator(frequency="tick")
    assert_equal(validator.frequency, "tick", "Tick frequency should be stored")


def test_factory_function_default() raises:
    var validator = create_order_style_validator()
    assert_equal(validator.frequency, "1d", "Factory default frequency should be '1d'")


def test_factory_function_custom() raises:
    var validator = create_order_style_validator(frequency="1m")
    assert_equal(validator.frequency, "1m", "Factory custom frequency should be '1m'")


def test_validate_order_returns_true() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_market_order()
    assert_true(validator.validate_order(order), "validate_order should always return True")


def test_validate_order_returns_true_for_algo() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_algo_order()
    assert_true(validator.validate_order(order), "validate_order should always return True even for algo")


def test_can_submit_order_returns_true() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_market_order()
    assert_true(validator.can_submit_order(order), "can_submit_order should always return True")


def test_can_submit_order_returns_true_for_algo() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_algo_order()
    assert_true(validator.can_submit_order(order), "can_submit_order should always return True")


def test_can_cancel_order_returns_true() raises:
    var validator = OrderStyleValidator(frequency="1d")
    assert_true(validator.can_cancel_order(1), "can_cancel_order should always return True")


def test_can_cancel_order_returns_true_for_any_id() raises:
    var validator = OrderStyleValidator(frequency="1d")
    assert_true(validator.can_cancel_order(999), "can_cancel_order should always return True for any id")


def test_validate_submission_market_order_1d() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_market_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Market order with 1d frequency should pass validation")


def test_validate_submission_market_order_1m() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_market_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Market order with 1m frequency should pass validation")


def test_validate_submission_market_order_tick() raises:
    var validator = OrderStyleValidator(frequency="tick")
    var order = create_market_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Market order with tick frequency should pass validation")


def test_validate_submission_limit_order_1d() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_limit_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Limit order with 1d frequency should pass validation")


def test_validate_submission_limit_order_1m() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_limit_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Limit order with 1m frequency should pass validation")


def test_validate_submission_limit_order_tick() raises:
    var validator = OrderStyleValidator(frequency="tick")
    var order = create_limit_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Limit order with tick frequency should pass validation")


def test_validate_submission_algo_order_1d_passes() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_algo_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result == None, "Algo order with 1d frequency should pass validation")


def test_validate_submission_algo_order_1m_fails() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_algo_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result == None, "Algo order with 1m frequency should fail validation")
    if result != None:
        assert_equal(result.value(), "algo order no support 1m and tick frequency", "Error message should match Python original")


def test_validate_submission_algo_order_tick_fails() raises:
    var validator = OrderStyleValidator(frequency="tick")
    var order = create_algo_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result == None, "Algo order with tick frequency should fail validation")
    if result != None:
        assert_equal(result.value(), "algo order no support 1m and tick frequency", "Error message should match Python original")


def test_validate_submission_with_account() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_market_order()
    var account = create_stock_account()
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result == None, "Market order with account should pass validation")


def test_validate_submission_algo_1m_with_account() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_algo_order()
    var account = create_stock_account()
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result == None, "Algo order with 1m frequency should fail even with account")


def test_validate_cancellation_returns_none() raises:
    var validator = OrderStyleValidator(frequency="1d")
    var order = create_market_order()
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result == None, "validate_cancellation should always return None")


def test_validate_cancellation_algo_order_returns_none() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_algo_order()
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result == None, "validate_cancellation should always return None even for algo")


def test_validate_cancellation_with_account() raises:
    var validator = OrderStyleValidator(frequency="tick")
    var order = create_market_order()
    var account = create_stock_account()
    var result = validator.validate_cancellation(order, Optional[Account](account))
    assert_true(result == None, "validate_cancellation should always return None with account")


def test_error_message_exact_content() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_algo_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    if result != None:
        var msg = result.value()
        assert_equal(msg, "algo order no support 1m and tick frequency", "Error message must match Python original exactly")


def test_multiple_validators_independent() raises:
    var validator_1d = OrderStyleValidator(frequency="1d")
    var validator_1m = OrderStyleValidator(frequency="1m")
    var validator_tick = OrderStyleValidator(frequency="tick")
    var order = create_algo_order()

    var result_1d = validator_1d.validate_submission(order, Optional[Account](None))
    var result_1m = validator_1m.validate_submission(order, Optional[Account](None))
    var result_tick = validator_tick.validate_submission(order, Optional[Account](None))

    assert_true(result_1d == None, "1d validator should pass algo order")
    assert_false(result_1m == None, "1m validator should reject algo order")
    assert_false(result_tick == None, "tick validator should reject algo order")


def test_sell_order_validation() raises:
    var validator = OrderStyleValidator(frequency="1m")
    var order = create_order_with_id(
        order_id=4,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=algo_order_style(),
        position_effect=POSITION_EFFECT.CLOSE
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result == None, "Sell algo order with 1m frequency should also fail")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
