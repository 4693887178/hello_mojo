"""
Comprehensive unit tests for SelfTradeValidator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py

Tests cover:
  1. Constructor and factory function
  2. validate_submission - no open orders returns None
  3. validate_submission - same side orders ignored
  4. validate_submission - EXERCISE position effect orders ignored
  5. validate_submission - different order_book_id orders ignored
  6. validate_submission - market order with opposite open order triggers warning
  7. validate_submission - BUY limit >= SELL open order price triggers warning
  8. validate_submission - BUY limit < SELL open order price no conflict
  9. validate_submission - SELL limit <= BUY open order price triggers warning
  10. validate_submission - SELL limit > BUY open order price no conflict
  11. validate_submission - error message format matches Python
  12. validate_submission - error message contains order info
  13. validate_cancellation always returns None
  14. validate_order always returns True
  15. can_submit_order always returns True
  16. can_cancel_order always returns True
  17. Writable trait (write_to)
  18. Multiple conflicting orders
  19. Mixed open orders (some conflicting, some not)
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, List

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS
from rqmojo.model.order import Order, OrderStyle, LimitOrder, MarketOrder, create_order_with_id
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import (
    SelfTradeValidator, create_self_trade_validator
)


def _create_buy_limit_order(order_id: Int, order_book_id: String, price: Float64, quantity: Int = 100, position_effect: POSITION_EFFECT = POSITION_EFFECT.OPEN) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=LimitOrder(price),
        position_effect=position_effect
    )


def _create_sell_limit_order(order_id: Int, order_book_id: String, price: Float64, quantity: Int = 100, position_effect: POSITION_EFFECT = POSITION_EFFECT.CLOSE) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id=order_book_id,
        side=SIDE.SELL,
        quantity=quantity,
        style=LimitOrder(price),
        position_effect=position_effect
    )


def _create_buy_market_order(order_id: Int, order_book_id: String, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


def _create_sell_market_order(order_id: Int, order_book_id: String, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id=order_book_id,
        side=SIDE.SELL,
        quantity=quantity,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )


def _create_exercise_order(order_id: Int, order_book_id: String, price: Float64) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id=order_book_id,
        side=SIDE.SELL,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.EXERCISE
    )


# ============================================================
# Test: Constructor and factory
# ============================================================

def test_self_trade_validator_init() raises:
    var open_orders = List[Order]()
    var _ = create_self_trade_validator(open_orders^)
    assert_true(True, "SelfTradeValidator created successfully")


def test_self_trade_validator_write_to() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    var s = String.write(validator)
    assert_equal(s, "SelfTradeValidator", "write_to produces correct string")


# ============================================================
# Test: validate_submission - no open orders
# ============================================================

def test_validate_submission_no_open_orders_returns_none() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "No open orders should return None")


# ============================================================
# Test: validate_submission - same side orders ignored
# ============================================================

def test_validate_submission_same_side_buy_ignored() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 9.5))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Same side BUY orders should not conflict")


def test_validate_submission_same_side_sell_ignored() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.5))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_sell_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Same side SELL orders should not conflict")


# ============================================================
# Test: validate_submission - EXERCISE position effect ignored
# ============================================================

def test_validate_submission_exercise_order_ignored() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_exercise_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "EXERCISE orders should be filtered out")


# ============================================================
# Test: validate_submission - different order_book_id ignored
# ============================================================

def test_validate_submission_different_order_book_id_ignored() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "600000.XSHG", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Different order_book_id should not conflict")


# ============================================================
# Test: validate_submission - market order with opposite open order
# ============================================================

def test_validate_submission_market_buy_with_sell_open() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_market_order(1, "000001.XSHE")
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Market BUY with SELL open order should trigger warning")


def test_validate_submission_market_sell_with_buy_open() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_sell_market_order(1, "000001.XSHE")
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Market SELL with BUY open order should trigger warning")


# ============================================================
# Test: validate_submission - BUY limit >= SELL open order price
# ============================================================

def test_validate_submission_buy_limit_at_sell_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "BUY limit at SELL price should trigger warning")


def test_validate_submission_buy_limit_above_sell_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.5)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "BUY limit above SELL price should trigger warning")


# ============================================================
# Test: validate_submission - BUY limit < SELL open order price
# ============================================================

def test_validate_submission_buy_limit_below_sell_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 9.5)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "BUY limit below SELL price should not conflict")


# ============================================================
# Test: validate_submission - SELL limit <= BUY open order price
# ============================================================

def test_validate_submission_sell_limit_at_buy_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_sell_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "SELL limit at BUY price should trigger warning")


def test_validate_submission_sell_limit_below_buy_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_sell_limit_order(1, "000001.XSHE", 9.5)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "SELL limit below BUY price should trigger warning")


# ============================================================
# Test: validate_submission - SELL limit > BUY open order price
# ============================================================

def test_validate_submission_sell_limit_above_buy_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_sell_limit_order(1, "000001.XSHE", 10.5)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "SELL limit above BUY price should not conflict")


# ============================================================
# Test: validate_submission - error message format
# ============================================================

def test_validate_submission_error_message_format() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_market_order(1, "000001.XSHE")
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Should return error")
    var reason = result.value()
    assert_true(reason.find("Create order failed") != -1, "Error should contain 'Create order failed'")
    assert_true(reason.find("self-trade") != -1, "Error should contain 'self-trade'")


def test_validate_submission_error_message_contains_order_info() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_market_order(1, "000001.XSHE")
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Should return error")
    var reason = result.value()
    assert_true(reason.find("...]") != -1, "Error should end with '...]'")


# ============================================================
# Test: validate_cancellation
# ============================================================

def test_validate_cancellation_returns_none() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")


def test_validate_cancellation_with_account_returns_none() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var account = create_stock_account()
    var result = validator.validate_cancellation(order, Optional[Account](account))
    assert_true(result is None, "validate_cancellation with account should return None")


# ============================================================
# Test: validate_order, can_submit_order, can_cancel_order
# ============================================================

def test_validate_order_returns_true() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    assert_true(validator.validate_order(order), "validate_order always returns True")


def test_can_submit_order_returns_true() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    assert_true(validator.can_submit_order(order), "can_submit_order always returns True")


def test_can_cancel_order_returns_true() raises:
    var open_orders = List[Order]()
    var validator = create_self_trade_validator(open_orders^)
    assert_true(validator.can_cancel_order(1), "can_cancel_order always returns True")


# ============================================================
# Test: Multiple conflicting orders
# ============================================================

def test_validate_submission_multiple_conflicting_orders() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    open_orders.append(_create_sell_limit_order(11, "000001.XSHE", 10.5))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.5)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Should detect conflict with at least one open order")


# ============================================================
# Test: Mixed open orders (some conflicting, some not)
# ============================================================

def test_validate_submission_mixed_orders() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 9.0))
    open_orders.append(_create_sell_limit_order(11, "000001.XSHE", 10.0))
    open_orders.append(_create_sell_limit_order(12, "600000.XSHG", 10.0))
    open_orders.append(_create_exercise_order(13, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Should detect conflict with SELL open order for same symbol")


def test_validate_submission_mixed_orders_no_conflict() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 9.0))
    open_orders.append(_create_sell_limit_order(11, "600000.XSHG", 10.0))
    open_orders.append(_create_exercise_order(13, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "No conflicting orders should return None")


# ============================================================
# Test: Boundary price conditions
# ============================================================

def test_validate_submission_buy_at_exactly_sell_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_sell_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_buy_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "BUY at exactly SELL price should conflict (>=)")


def test_validate_submission_sell_at_exactly_buy_price() raises:
    var open_orders = List[Order]()
    open_orders.append(_create_buy_limit_order(10, "000001.XSHE", 10.0))
    var validator = create_self_trade_validator(open_orders^)
    var order = _create_sell_limit_order(1, "000001.XSHE", 10.0)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "SELL at exactly BUY price should conflict (<=)")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
