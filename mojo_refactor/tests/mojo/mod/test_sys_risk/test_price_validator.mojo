"""
Comprehensive unit tests for PriceValidator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/price_validator.py

Tests cover:
  1. Constructor and factory function
  2. validate_submission - market order skipped
  3. validate_submission - EXERCISE position effect skipped
  4. validate_submission - limit order within range returns None
  5. validate_submission - price above limit_up returns error
  6. validate_submission - price below limit_down returns error
  7. validate_submission - error message format matches Python
  8. validate_submission - error message contains order_book_id
  9. validate_submission - price exactly at limit_up (boundary)
  10. validate_submission - price exactly at limit_down (boundary)
  11. validate_cancellation always returns None
  12. validate_order always returns True
  13. can_submit_order always returns True
  14. can_cancel_order always returns True
  15. Writable trait (write_to)
  16. _format_float helper function
  17. Rounding behavior (4 decimal places)
  18. Different order_book_ids
  19. Sell order validation
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, List

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, DEFAULT_ACCOUNT_TYPE
from rqmojo.model.order import Order, OrderStyle, LimitOrder, MarketOrder, create_order_with_id
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import (
    PriceValidator, create_price_validator, _format_float
)


def _create_limit_buy_order(order_book_id: String = "000001.XSHE", price: Float64 = 10.0, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.OPEN
    )


def _create_limit_sell_order(order_book_id: String = "000001.XSHE", price: Float64 = 10.0, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=2,
        order_book_id=order_book_id,
        side=SIDE.SELL,
        quantity=quantity,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.CLOSE
    )


def _create_market_order(order_book_id: String = "000001.XSHE", quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=3,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


def _create_exercise_order(order_book_id: String = "000001.XSHE", price: Float64 = 10.0) -> Order:
    return create_order_with_id(
        order_id=4,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.EXERCISE
    )


# ============================================================
# Test: Constructor and factory
# ============================================================

def test_price_validator_init() raises:
    var dp = create_data_proxy()
    var _ = create_price_validator(dp^)
    assert_true(True, "PriceValidator created successfully")


def test_price_validator_write_to() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var s = String.write(validator)
    assert_equal(s, "PriceValidator", "write_to produces correct string")


# ============================================================
# Test: validate_submission - market order skipped
# ============================================================

def test_validate_submission_market_order_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_market_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Market orders should skip price validation")


def test_validate_submission_market_order_with_account_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_market_order()
    var account = create_stock_account()
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "Market orders with account should skip price validation")


# ============================================================
# Test: validate_submission - EXERCISE position effect skipped
# ============================================================

def test_validate_submission_exercise_order_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_exercise_order(price=12.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "EXERCISE orders should skip price validation")


def test_validate_submission_exercise_order_above_limit_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_exercise_order(price=100.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "EXERCISE orders skip price validation even with extreme price")


# ============================================================
# Test: validate_submission - limit order within range
# ============================================================

def test_validate_submission_limit_within_range_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Limit order within range should return None")


def test_validate_submission_limit_at_mid_range_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=10.5)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Limit order at mid-range should return None")


# ============================================================
# Test: validate_submission - price above limit_up
# ============================================================

def test_validate_submission_above_limit_up_returns_error() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=12.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Should return error when price > limit_up")


def test_validate_submission_above_limit_up_error_contains_higher() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=12.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    var reason = result.value()
    assert_true(reason.find("higher than limit up") != -1, "Error should mention 'higher than limit up'")


def test_validate_submission_above_limit_up_error_contains_order_book_id() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order("000001.XSHE", 12.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    var reason = result.value()
    assert_true(reason.find("000001.XSHE") != -1, "Error should contain order_book_id")


def test_validate_submission_above_limit_up_error_format() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order("000001.XSHE", 12.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    var reason = result.value()
    assert_true(reason.find("Order Creation Failed") != -1, "Error should start with 'Order Creation Failed'")


# ============================================================
# Test: validate_submission - price below limit_down
# ============================================================

def test_validate_submission_below_limit_down_returns_error() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=8.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Should return error when price < limit_down")


def test_validate_submission_below_limit_down_error_contains_lower() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=8.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    var reason = result.value()
    assert_true(reason.find("lower than limit down") != -1, "Error should mention 'lower than limit down'")


def test_validate_submission_below_limit_down_error_contains_order_book_id() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order("000001.XSHE", 8.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    var reason = result.value()
    assert_true(reason.find("000001.XSHE") != -1, "Error should contain order_book_id")


# ============================================================
# Test: validate_submission - boundary conditions
# DataProxy.get_limit_up returns 11.0, get_limit_down returns 9.0
# ============================================================

def test_validate_submission_price_at_limit_up_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=11.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Price exactly at limit_up should return None")


def test_validate_submission_price_at_limit_down_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=9.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Price exactly at limit_down should return None")


def test_validate_submission_price_slightly_above_limit_up() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=11.0001)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Price slightly above limit_up should return error")


def test_validate_submission_price_slightly_below_limit_down() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=8.9999)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Price slightly below limit_down should return error")


# ============================================================
# Test: validate_submission - sell order
# ============================================================

def test_validate_submission_sell_order_within_range() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_sell_order(price=10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Sell order within range should return None")


def test_validate_submission_sell_order_below_limit_down() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_sell_order(price=8.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Sell order below limit_down should return error")


# ============================================================
# Test: validate_cancellation
# ============================================================

def test_validate_cancellation_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=10.0)
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")


def test_validate_cancellation_with_account_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=10.0)
    var account = create_stock_account()
    var result = validator.validate_cancellation(order, Optional[Account](account))
    assert_true(result is None, "validate_cancellation with account should return None")


# ============================================================
# Test: validate_order, can_submit_order, can_cancel_order
# ============================================================

def test_validate_order_returns_true() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order()
    assert_true(validator.validate_order(order), "validate_order always returns True")


def test_can_submit_order_returns_true() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order()
    assert_true(validator.can_submit_order(order), "can_submit_order always returns True")


def test_can_cancel_order_returns_true() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    assert_true(validator.can_cancel_order(1), "can_cancel_order always returns True")


# ============================================================
# Test: _format_float helper
# ============================================================

def test_format_float_rounds_to_4_decimals() raises:
    var result = _format_float(10.123456789)
    assert_equal(result, "10.1235", "_format_float rounds to 4 decimal places")


def test_format_float_no_decimals() raises:
    var result = _format_float(10.0)
    assert_equal(result, "10.0", "_format_float handles whole numbers")


def test_format_float_exact_4_decimals() raises:
    var result = _format_float(10.1234)
    assert_equal(result, "10.1234", "_format_float preserves exact 4 decimal places")


# ============================================================
# Test: Different order_book_ids
# ============================================================

def test_validate_submission_different_order_book_ids() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order1 = _create_limit_buy_order("000001.XSHE", 12.0)
    var result1 = validator.validate_submission(order1, Optional[Account](None))
    assert_false(result1 is None, "Error for 000001.XSHE")
    assert_true(result1.value().find("000001.XSHE") != -1, "Error contains 000001.XSHE")


# ============================================================
# Test: Rounding behavior matches Python round(value, 4)
# ============================================================

def test_rounding_behavior_matches_python() raises:
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_limit_buy_order(price=11.00006)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Price 11.00006 > 11.0 (limit_up) should return error")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
