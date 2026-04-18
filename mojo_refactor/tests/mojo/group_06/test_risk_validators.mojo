"""
Comprehensive Tests for Risk Validators
Tests for: CashValidator, PriceValidator, IsTradingValidator, SelfTradeValidator
Aligned with Python rqalpha/mod/rqalpha_mod_sys_risk/validators/ behavior
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, List

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, DEFAULT_ACCOUNT_TYPE
from rqmojo.model.order import Order, OrderStyle, LimitOrder, MarketOrder, create_order_with_id
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.data.data_proxy import DataProxy, create_data_proxy

from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import (
    CashValidator, create_cash_validator, validate_cash
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import (
    PriceValidator, create_price_validator
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import (
    IsTradingValidator, create_is_trading_validator
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import (
    SelfTradeValidator, create_self_trade_validator
)
from rqmojo.utils.typing import DateTime


def _create_buy_order(order_book_id: String, price: Float64, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.OPEN
    )


def _create_sell_order(order_book_id: String, price: Float64, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=2,
        order_book_id=order_book_id,
        side=SIDE.SELL,
        quantity=quantity,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.CLOSE
    )


def _create_market_buy_order(order_book_id: String, quantity: Int = 100) -> Order:
    return create_order_with_id(
        order_id=3,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


# ============================================================
# CashValidator Tests
# ============================================================

def test_cash_validator_init() raises:
    print("Test: CashValidator init with DataProxy")
    var dp = create_data_proxy()
    var _ = create_cash_validator(dp^)
    assert_true(True, "CashValidator created successfully")
    print("  PASSED")


def test_cash_validate_sufficient_cash() raises:
    print("Test: validate_cash - sufficient cash returns None")
    var dp = create_data_proxy()
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validate_cash(order=order, cash=10000.0, data_proxy=dp)
    assert_true(result is None, "Should return None when cash is sufficient")
    print("  PASSED")


def test_cash_validate_insufficient_cash() raises:
    print("Test: validate_cash - insufficient cash returns error message")
    var dp = create_data_proxy()
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validate_cash(order=order, cash=500.0, data_proxy=dp)
    assert_true(result is not None, "Should return error when cash is insufficient")
    assert_true("not enough money" in result.value(), "Error message should mention 'not enough money'")
    print("  PASSED")


def test_cash_submission_none_account() raises:
    print("Test: CashValidator.validate_submission - None account returns None")
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Should return None when account is None")
    print("  PASSED")


def test_cash_submission_close_position() raises:
    print("Test: CashValidator.validate_submission - CLOSE position effect skips validation")
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(1000.0)
    var order = _create_sell_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "Should return None for non-OPEN position effects")
    print("  PASSED")


def test_cash_submission_open_sufficient() raises:
    print("Test: CashValidator.validate_submission - OPEN with sufficient cash returns None")
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(10000.0)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "Should return None when cash is sufficient for OPEN order")
    print("  PASSED")


def test_cash_cancellation_always_none() raises:
    print("Test: CashValidator.validate_cancellation - always returns None")
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(10000.0)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_cancellation(order, Optional[Account](account))
    assert_true(result is None, "validate_cancellation should always return None")
    print("  PASSED")


def test_cash_interface_methods() raises:
    print("Test: CashValidator interface methods")
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)

    assert_true(validator.validate_order(order), "validate_order should return True")
    assert_true(validator.can_submit_order(order), "can_submit_order should return True")
    assert_true(validator.can_cancel_order(1), "can_cancel_order should return True")
    print("  PASSED")


# ============================================================
# PriceValidator Tests
# ============================================================

def test_price_validator_init() raises:
    print("Test: PriceValidator init with DataProxy")
    var dp = create_data_proxy()
    var _ = create_price_validator(dp^)
    assert_true(True, "PriceValidator created successfully")
    print("  PASSED")


def test_price_validation_limit_within_range() raises:
    print("Test: PriceValidator - limit order within range returns None")
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 10.5, 100)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Should return None when price is within limits")
    print("  PASSED")


def test_price_validation_above_limit_up() raises:
    print("Test: PriceValidator - above limit up returns error")
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 12.0, 100)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is not None, "Should return error when price > limit_up")
    assert_true("higher than limit up" in result.value(), "Error should mention 'higher than limit up'")
    print("  PASSED")


def test_price_validation_below_limit_down() raises:
    print("Test: PriceValidator - below limit down returns error")
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 8.0, 100)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is not None, "Should return error when price < limit_down")
    assert_true("lower than limit down" in result.value(), "Error should mention 'lower than limit down'")
    print("  PASSED")


def test_price_validation_market_order_skipped() raises:
    print("Test: PriceValidator - market order skipped")
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_market_buy_order("000001.XSHE", 100)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Market orders should skip price validation")
    print("  PASSED")


def test_price_validation_exercise_skipped() raises:
    print("Test: PriceValidator - EXERCISE position effect skipped")
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var exercise_order = create_order_with_id(
        order_id=10,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.EXERCISE
    )
    var result = validator.validate_submission(exercise_order, Optional[Account](None))
    assert_true(result is None, "EXERCISE orders should skip price validation")
    print("  PASSED")


def test_price_cancellation_always_none() raises:
    print("Test: PriceValidator.validate_cancellation - always returns None")
    var dp = create_data_proxy()
    var validator = create_price_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 15.0, 100)
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")
    print("  PASSED")


# ============================================================
# IsTradingValidator Tests
# ============================================================

def test_is_trading_validator_init() raises:
    print("Test: IsTradingValidator init with DataProxy")
    var dp = create_data_proxy()
    var _ = create_is_trading_validator(dp^)
    assert_true(True, "IsTradingValidator created successfully")
    print("  PASSED")


def test_is_trading_normal_instrument() raises:
    print("Test: IsTradingValidator - normal trading instrument returns None")
    var dp = create_data_proxy()
    var validator = create_is_trading_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Normal instrument should pass validation")
    print("  *** CRITICAL BUG FIX VERIFIED: No longer always rejects orders ***")
    print("  PASSED")


def test_is_trading_not_cs_type_passes() raises:
    print("Test: IsTradingValidator - non-CS type passes even if suspended check runs")
    var dp = create_data_proxy()
    var validator = create_is_trading_validator(dp^)
    var future_order = create_order_with_id(
        order_id=20,
        order_book_id="RB1912",
        side=SIDE.BUY,
        quantity=1,
        style=LimitOrder(3500.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    var result = validator.validate_submission(future_order, Optional[Account](None))
    assert_true(result is None, "Non-CS instruments should pass (only CS checked for suspension)")
    print("  PASSED")


def test_is_trading_cancellation_always_none() raises:
    print("Test: IsTradingValidator.validate_cancellation - always returns None")
    var dp = create_data_proxy()
    var validator = create_is_trading_validator(dp^)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")
    print("  PASSED")


# ============================================================
# SelfTradeValidator Tests
# ============================================================

def test_self_trade_validator_init() raises:
    print("Test: SelfTradeValidator init with empty orders list")
    var empty_orders = List[Order]()
    var _ = create_self_trade_validator(empty_orders^)
    assert_true(True, "SelfTradeValidator created successfully")
    print("  PASSED")


def test_self_trade_no_conflicting_orders() raises:
    print("Test: SelfTradeValidator - no conflicting orders returns None")
    var empty_orders = List[Order]()
    var validator = create_self_trade_validator(empty_orders^)
    var buy_order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(buy_order, Optional[Account](None))
    assert_true(result is None, "No open orders means no self-trade risk")
    print("  PASSED")


def test_self_trade_market_order_conflict() raises:
    print("Test: SelfTradeValidator - market order with opposite open order triggers warning")
    var open_orders = List[Order]()
    var sell_order = create_order_with_id(
        order_id=100,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=50,
        style=LimitOrder(9.5),
        position_effect=POSITION_EFFECT.OPEN
    )
    open_orders.append(sell_order)

    var validator = create_self_trade_validator(open_orders^)
    var market_buy = _create_market_buy_order("000001.XSHE", 100)
    var result = validator.validate_submission(market_buy, Optional[Account](None))

    assert_true(result is not None, "Market order with conflicting open order should trigger warning")
    assert_true("self-trade" in result.value(), "Warning should mention 'self-trade'")
    print("  PASSED")


def test_self_trade_limit_buy_crosses_sell() raises:
    print("Test: SelfTradeValidator - BUY limit >= SELL open order price triggers warning")
    var open_orders = List[Order]()
    var sell_order = create_order_with_id(
        order_id=101,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=50,
        style=LimitOrder(9.5),
        position_effect=POSITION_EFFECT.OPEN
    )
    open_orders.append(sell_order)

    var validator = create_self_trade_validator(open_orders^)
    var buy_order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(buy_order, Optional[Account](None))

    assert_true(result is not None, "BUY at 10.0 >= SELL open at 9.5 should trigger warning")
    assert_true("self-trade" in result.value(), "Warning should mention 'self-trade'")
    print("  PASSED")


def test_self_trade_limit_buy_below_sell() raises:
    print("Test: SelfTradeValidator - BUY limit < SELL open order price no conflict")
    var open_orders = List[Order]()
    var sell_order = create_order_with_id(
        order_id=102,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=50,
        style=LimitOrder(11.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    open_orders.append(sell_order)

    var validator = create_self_trade_validator(open_orders^)
    var buy_order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(buy_order, Optional[Account](None))

    assert_true(result is None, "BUY at 10.0 < SELL open at 11.0 should NOT trigger warning")
    print("  PASSED")


def test_self_trade_same_side_ignored() raises:
    print("Test: SelfTradeValidator - same-side orders ignored")
    var open_orders = List[Order]()
    var other_buy = create_order_with_id(
        order_id=103,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=50,
        style=LimitOrder(9.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    open_orders.append(other_buy)

    var validator = create_self_trade_validator(open_orders^)
    var buy_order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(buy_order, Optional[Account](None))

    assert_true(result is None, "Same-side orders should be ignored")
    print("  PASSED")


def test_self_trade_exercise_ignored() raises:
    print("Test: SelfTradeValidator - EXERCISE orders ignored as conflicting")
    var open_orders = List[Order]()
    var exercise_sell = create_order_with_id(
        order_id=104,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=50,
        style=LimitOrder(8.0),
        position_effect=POSITION_EFFECT.EXERCISE
    )
    open_orders.append(exercise_sell)

    var validator = create_self_trade_validator(open_orders^)
    var buy_order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(buy_order, Optional[Account](None))

    assert_true(result is None, "EXERCISE orders should not be considered conflicting")
    print("  PASSED")


def test_self_trade_different_symbol_ignored() raises:
    print("Test: SelfTradeValidator - different order_book_id orders ignored")
    var open_orders = List[Order]()
    var other_sell = create_order_with_id(
        order_id=105,
        order_book_id="000002.XSHE",
        side=SIDE.SELL,
        quantity=50,
        style=LimitOrder(8.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    open_orders.append(other_sell)

    var validator = create_self_trade_validator(open_orders^)
    var buy_order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_submission(buy_order, Optional[Account](None))

    assert_true(result is None, "Different symbol orders should be ignored")
    print("  PASSED")


def test_self_trade_sell_crosses_buy() raises:
    print("Test: SelfTradeValidator - SELL limit <= BUY open order price triggers warning")
    var open_orders = List[Order]()
    var buy_open = create_order_with_id(
        order_id=106,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=50,
        style=LimitOrder(9.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    open_orders.append(buy_open)

    var validator = create_self_trade_validator(open_orders^)
    var sell_order = _create_sell_order("000001.XSHE", 8.5, 100)
    var result = validator.validate_submission(sell_order, Optional[Account](None))

    assert_true(result is not None, "SELL at 8.5 <= BUY open at 9.0 should trigger warning")
    assert_true("self-trade" in result.value(), "Warning should mention 'self-trade'")
    print("  PASSED")


def test_self_trade_cancellation_always_none() raises:
    print("Test: SelfTradeValidator.validate_cancellation - always returns None")
    var empty_orders = List[Order]()
    var validator = create_self_trade_validator(empty_orders^)
    var order = _create_buy_order("000001.XSHE", 10.0, 100)
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")
    print("  PASSED")


# ============================================================
# __init__.mojo Export Tests
# ============================================================

def test_validators_import_from_init() raises:
    print("Test: All validators importable from __init__.mojo")
    from rqmojo.mod.rqmojo_mod_sys_risk.validators import (
        CashValidator as CVCash,
        PriceValidator as CVPrice,
        IsTradingValidator as CVIsTrading,
        SelfTradeValidator as CVSelfTrade,
    )
    assert_true(True, "All 4 validators imported successfully from __init__.mojo")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
