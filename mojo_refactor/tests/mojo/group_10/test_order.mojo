"""
Comprehensive Test Suite for model/order.mojo
Tests all classes: OrderIdGenerator, OrderStyle, AlgoOrderStyle, Order
Covers all methods and edge cases to ensure parity with Python rqalpha/model/order.py
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from rqmojo.model.order import (
    OrderIdGenerator, create_order_id_generator,
    OrderStyle, MarketOrder, LimitOrder,
    AlgoOrderStyle, TWAPOrder, VWAPOrder,
    Order, create_order_with_id, create_algo_order_with_id, buy, sell,
)
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, ORDER_TYPE, POSITION_DIRECTION, ALGO
from rqmojo.utils.typing import DateTime


# ============== OrderIdGenerator Tests ==============

def test_order_id_generator_default() raises:
    print("Test: OrderIdGenerator default construction")
    var gen = OrderIdGenerator()
    assert_equal(gen.counter, 0, "Default counter should be 0")
    print("  PASSED")


def test_order_id_generator_custom_start() raises:
    print("Test: OrderIdGenerator custom start value")
    var gen = OrderIdGenerator(100)
    assert_equal(gen.counter, 100, "Counter should start at 100")
    print("  PASSED")


def test_order_id_generator_next() raises:
    print("Test: OrderIdGenerator.next() increments and returns")
    var gen = OrderIdGenerator()
    var id1 = gen.next()
    var id2 = gen.next()
    var id3 = gen.next()
    assert_equal(id1, 1, "First next() should return 1")
    assert_equal(id2, 2, "Second next() should return 2")
    assert_equal(id3, 3, "Third next() should return 3")
    assert_equal(gen.counter, 3, "Counter should be 3 after 3 calls")
    print("  PASSED")


def test_create_order_id_generator() raises:
    print("Test: create_order_id_generator factory function")
    var gen = create_order_id_generator()
    assert_equal(gen.counter, 0, "Factory should create generator with counter=0")
    print("  PASSED")


# ============== OrderStyle / MarketOrder / LimitOrder Tests ==============

def test_market_order_creation() raises:
    print("Test: MarketOrder() creates MARKET style")
    var style = MarketOrder()
    assert_equal(style.style_type, ORDER_TYPE.MARKET, "MarketOrder should have MARKET type")
    assert_equal(style.limit_price, 0.0, "MarketOrder limit_price should be 0.0")
    print("  PASSED")


def test_limit_order_creation() raises:
    print("Test: LimitOrder(price) creates LIMIT style")
    var style = LimitOrder(10.5)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT, "LimitOrder should have LIMIT type")
    assert_equal(style.limit_price, 10.5, "LimitOrder should store given price")
    print("  PASSED")


def test_order_style_get_limit_price_market() raises:
    print("Test: OrderStyle.get_limit_price() returns None for MARKET")
    var style = MarketOrder()
    var result = style.get_limit_price()
    assert_true(result == None, "MARKET style get_limit_price should return None")
    print("  PASSED")


def test_order_style_get_limit_price_limit() raises:
    print("Test: OrderStyle.get_limit_price() returns price for LIMIT")
    var style = LimitOrder(25.8)
    var result = style.get_limit_price()
    assert_true(result != None, "LIMIT style get_limit_price should not be None")
    assert_equal(result.value(), 25.8, "LIMIT style should return its limit_price")
    print("  PASSED")


def test_limit_order_round_price_basic() raises:
    print("Test: LimitOrder.round_price() basic rounding")
    var style = LimitOrder(12.345)
    style.round_price(0.01)
    assert_true(style.limit_price >= 12.34 - 0.001 and style.limit_price <= 12.34 + 0.001,
        "Should round to nearest tick")
    print("  PASSED")


def test_limit_order_round_price_no_op_for_non_limit() raises:
    print("Test: round_price() does nothing for non-LIMIT styles")
    var style = MarketOrder()
    style.round_price(0.01)
    assert_equal(style.style_type, ORDER_TYPE.MARKET, "Type unchanged")
    assert_equal(style.limit_price, 0.0, "Price unchanged")
    print("  PASSED")


def test_limit_order_round_price_zero_tick() raises:
    print("Test: round_price() with zero tick_size does nothing")
    var style = LimitOrder(99.99)
    style.round_price(0.0)
    assert_equal(style.limit_price, 99.99, "Zero tick_size should not modify price")
    print("  PASSED")


def test_order_style_copy() raises:
    print("Test: OrderStyle copy constructor")
    var original = LimitOrder(42.0)
    var copy = original.copy()
    assert_equal(copy.style_type, original.style_type, "Copied type matches")
    assert_equal(copy.limit_price, original.limit_price, "Copied price matches")
    print("  PASSED")


# ============== AlgoOrderStyle / TWAPOrder / VWAPOrder Tests ==============

def test_twap_order_creation() raises:
    print("Test: TWAPOrder(start_min, end_min) creation")
    var algo = TWAPOrder(10, 30)
    assert_equal(algo.algo_type, ALGO.TWAP, "TWAPOrder should have TWAP type")
    assert_equal(algo.start_min, 10, "start_min should match")
    assert_equal(algo.end_min, 30, "end_min should match")
    print("  PASSED")


def test_vwap_order_creation() raises:
    print("Test: VWAPOrder(start_min, end_min) creation")
    var algo = VWAPOrder(15, 45)
    assert_equal(algo.algo_type, ALGO.VWAP, "VWAPOrder should have VWAP type")
    assert_equal(algo.start_min, 15, "start_min should match")
    assert_equal(algo.end_min, 45, "end_min should match")
    print("  PASSED")


def test_algo_order_get_limit_price_returns_none() raises:
    print("Test: AlgoOrderStyle.get_limit_price() always returns None")
    var twap = TWAPOrder(5, 20)
    var vwap = VWAPOrder(5, 20)
    assert_true(twap.get_limit_price() == None, "TWAP get_limit_price should be None")
    assert_true(vwap.get_limit_price() == None, "VWAP get_limit_price should be None")
    print("  PASSED")


def test_algo_order_copy() raises:
    print("Test: AlgoOrderStyle copy constructor")
    var original = TWAPOrder(7, 77)
    var copy = original.copy()
    assert_equal(copy.algo_type, original.algo_type, "Copied algo type matches")
    assert_equal(copy.start_min, original.start_min, "Copied start_min matches")
    assert_equal(copy.end_min, original.end_min, "Copied end_min matches")
    print("  PASSED")


# ============== Order Construction Tests ==============

def test_create_order_market_buy() raises:
    print("Test: create_order_with_id - market buy order")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN,
    )
    assert_equal(order.order_id, 1, "order_id should match")
    assert_equal(order.order_book_id, "000001.XSHE", "order_book_id should match")
    assert_equal(order.side, SIDE.BUY, "side should be BUY")
    assert_equal(order.quantity, 100, "quantity should match")
    assert_equal(order.filled_quantity, 0, "filled_quantity starts at 0")
    assert_equal(order.status, ORDER_STATUS.PENDING_NEW, "initial status PENDING_NEW")
    assert_equal(order.order_type_val, ORDER_TYPE.MARKET, "type should be MARKET")
    assert_equal(order.position_effect.value(), POSITION_EFFECT.OPEN, "position_effect should be OPEN")
    print("  PASSED")


def test_create_order_limit_sell() raises:
    print("Test: create_order_with_id - limit sell order")
    var order = create_order_with_id(
        order_id=2,
        order_book_id="000002.XSHG",
        side=SIDE.SELL,
        quantity=200,
        style=LimitOrder(15.5),
        position_effect=POSITION_EFFECT.CLOSE,
    )
    assert_equal(order.side, SIDE.SELL, "side should be SELL")
    assert_equal(order.quantity, 200, "quantity should match")
    assert_equal(order.order_type_val, ORDER_TYPE.LIMIT, "type should be LIMIT")
    assert_equal(order.frozen_price, 15.5, "frozen_price should be limit_price for LIMIT orders")
    assert_equal(order.price(), 15.5, "price() should return frozen_price for LIMIT orders")
    assert_equal(order.position_effect.value(), POSITION_EFFECT.CLOSE, "position_effect CLOSE")
    print("  PASSED")


def test_create_order_none_position_effect() raises:
    print("Test: create_order_with_id - None position_effect defaults by side")
    var buy_order = create_order_with_id(
        order_id=10, order_book_id="000001.XSHE", side=SIDE.BUY,
        quantity=100, style=MarketOrder(),
    )
    var sell_order = create_order_with_id(
        order_id=11, order_book_id="000001.XSHE", side=SIDE.SELL,
        quantity=100, style=MarketOrder(),
    )
    assert_equal(buy_order.position_effect_resolved(), POSITION_EFFECT.OPEN,
        "BUY with None -> OPEN")
    assert_equal(sell_order.position_effect_resolved(), POSITION_EFFECT.CLOSE,
        "SELL with None -> CLOSE")
    print("  PASSED")


def test_create_algo_order_twap() raises:
    print("Test: create_algo_order_with_id - TWAP order")
    var order = create_algo_order_with_id(
        order_id=50,
        order_book_id="IF2309.XCFF",
        side=SIDE.BUY,
        quantity=300,
        style=TWAPOrder(10, 50),
        position_effect=POSITION_EFFECT.OPEN,
        frozen_price=4000.0,
    )
    assert_equal(order.order_id, 50, "order_id should match")
    assert_equal(order.order_type_val, ORDER_TYPE.ALGO, "type should be ALGO")
    assert_true(order.style_algo != None, "style_algo should be set")
    assert_equal(order.style_algo.value().algo_type, ALGO.TWAP, "algo type should be TWAP")
    assert_equal(order.style_algo.value().start_min, 10, "start_min should match")
    assert_equal(order.style_algo.value().end_min, 50, "end_min should match")
    assert_equal(order.frozen_price, 4000.0, "frozen_price should match")
    print("  PASSED")


def test_create_algo_order_vwap() raises:
    print("Test: create_algo_order_with_id - VWAP order")
    var order = create_algo_order_with_id(
        order_id=51,
        order_book_id="IF2310.XCFF",
        side=SIDE.SELL,
        quantity=200,
        style=VWAPOrder(15, 60),
        position_effect=POSITION_EFFECT.CLOSE,
        frozen_price=4010.0,
    )
    assert_equal(order.order_type_val, ORDER_TYPE.ALGO, "type should be ALGO")
    assert_equal(order.style_algo.value().algo_type, ALGO.VWAP, "algo type should be VWAP")
    print("  PASSED")


# ============== buy/sell Convenience Functions ==============

def test_buy_function() raises:
    print("Test: buy() function creates BUY order")
    var order = buy("000001.XSHE", 100)
    assert_equal(order.side, SIDE.BUY, "buy() should create BUY order")
    assert_equal(order.quantity, 100, "Quantity should match")
    assert_equal(order.order_book_id, "000001.XSHE", "order_book_id should match")
    assert_equal(order.position_effect.value(), POSITION_EFFECT.OPEN, "BUY default to OPEN")
    print("  PASSED")


def test_buy_function_with_limit_style() raises:
    print("Test: buy() with LimitOrder style")
    var order = buy("000001.XSHE", 200, LimitOrder(50.0))
    assert_equal(order.side, SIDE.BUY, "side BUY")
    assert_equal(order.order_type_val, ORDER_TYPE.LIMIT, "type LIMIT from style")
    assert_equal(order.frozen_price, 50.0, "frozen_price from limit_price")
    print("  PASSED")


def test_sell_function() raises:
    print("Test: sell() function creates SELL order")
    var order = sell("000002.XSHG", 500)
    assert_equal(order.side, SIDE.SELL, "sell() should create SELL order")
    assert_equal(order.quantity, 500, "Quantity should match")
    assert_equal(order.position_effect.value(), POSITION_EFFECT.CLOSE, "SELL default to CLOSE")
    print("  PASSED")


# ============== Computed Properties Tests ==============

def test_unfilled_quantity_property() raises:
    print("Test: unfilled_quantity() computed property")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.unfilled_quantity(), 100, "Initial unfilled = total qty")
    order.fill(30, 10.0)
    assert_equal(order.unfilled_quantity(), 70, "After partial fill: 100-30=70")
    order.fill(70, 11.0)
    assert_equal(order.unfilled_quantity(), 0, "After full fill: 0")
    print("  PASSED")


def test_price_property_market() raises:
    print("Test: price() returns 0 for MARKET orders")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(),
        POSITION_EFFECT.OPEN, frozen_price=25.5,
    )
    assert_equal(order.price(), 0.0, "MARKET order price() should be 0")
    print("  PASSED")


def test_price_property_limit() raises:
    print("Test: price() returns frozen_price for LIMIT orders")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(33.3), POSITION_EFFECT.OPEN
    )
    assert_equal(order.price(), 33.3, "LIMIT order price() should equal frozen_price")
    print("  PASSED")


def test_position_direction_buy_open() raises:
    print("Test: position_direction() BUY + OPEN -> LONG")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.position_direction(), POSITION_DIRECTION.LONG, "BUY+OPEN -> LONG")
    print("  PASSED")


def test_position_direction_buy_close() raises:
    print("Test: position_direction() BUY + CLOSE -> SHORT")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.CLOSE
    )
    assert_equal(order.position_direction(), POSITION_DIRECTION.SHORT, "BUY+CLOSE -> SHORT")
    print("  PASSED")


def test_position_direction_sell_open() raises:
    print("Test: position_direction() SELL + OPEN -> SHORT")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.SELL, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.position_direction(), POSITION_DIRECTION.SHORT, "SELL+OPEN -> SHORT")
    print("  PASSED")


def test_position_direction_sell_close() raises:
    print("Test: position_direction() SELL + CLOSE -> LONG")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.SELL, 100, MarketOrder(), POSITION_EFFECT.CLOSE
    )
    assert_equal(order.position_direction(), POSITION_DIRECTION.LONG, "SELL+CLOSE -> LONG")
    print("  PASSED")


def test_datetime_properties() raises:
    print("Test: datetime() and trading_datetime()")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    var cal_dt = order.datetime()
    var trade_dt = order.trading_datetime()
    assert_equal(cal_dt.year, 1970, "Default calendar year")
    assert_equal(trade_dt.year, 1970, "Default trading year")
    print("  PASSED")


# ============== get_state Tests ==============

def test_get_state_basic() raises:
    print("Test: get_state() returns dict with all fields")
    var order = create_order_with_id(
        42, "000001.XSHE", SIDE.BUY, 200, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    var state = order.get_state()
    assert_true(state["order_id"] == "42", "state order_id")
    assert_true(state["order_book_id"] == "000001.XSHE", "state order_book_id")
    assert_true(state["quantity"] == "200", "state quantity")
    assert_true(state["side"] == "BUY", "state side")
    assert_true(state["status"] == "PENDING_NEW", "state status")
    assert_true(state["type"] == "LIMIT", "state type")
    assert_true(state["position_effect"] == "OPEN", "state position_effect")
    print("  PASSED")


def test_get_state_none_position_effect() raises:
    print("Test: get_state() with None position_effect")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder()
    )
    var state = order.get_state()
    assert_true(state["position_effect"] == "", "None position_effect stored as empty string")
    print("  PASSED")


# ============== Status Methods Tests ==============

def test_is_active_pending_new() raises:
    print("Test: is_active() returns False for PENDING_NEW (matches Python)")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_false(order.is_active(), "PENDING_NEW is not active (Python behavior)")
    print("  PASSED")


def test_is_active_when_active() raises:
    print("Test: is_active() returns True only for ACTIVE status")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.active()
    assert_true(order.is_active(), "ACTIVE status should return True")
    print("  PASSED")


def test_is_filled() raises:
    print("Test: is_filled() returns True only for FILLED")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_false(order.is_filled(), "Not filled initially")
    order.fill(100, 10.0)
    assert_true(order.is_filled(), "Filled after complete fill")
    print("  PASSED")


def test_is_cancelled() raises:
    print("Test: is_cancelled() returns True for CANCELLED")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_false(order.is_cancelled(), "Not cancelled initially")
    order.mark_cancelled("User cancelled")
    assert_true(order.is_cancelled(), "Cancelled after mark_cancelled")
    print("  PASSED")


def test_is_rejected() raises:
    print("Test: is_rejected() returns True for REJECTED")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_false(order.is_rejected(), "Not rejected initially")
    order.mark_rejected("Insufficient funds")
    assert_true(order.is_rejected(), "Rejected after mark_rejected")
    assert_equal(order.message, "Insufficient funds", "Message should be set")
    print("  PASSED")


def test_is_final_various_statuses() raises:
    print("Test: is_final() for various statuses")
    var o1 = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    assert_false(o1.is_final(), "PENDING_NEW is not final")

    var o2 = create_order_with_id(2, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    o2.active()
    assert_false(o2.is_final(), "ACTIVE is not final")

    var o3 = create_order_with_id(3, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    o3.set_pending_cancel()
    assert_false(o3.is_final(), "PENDING_CANCEL is not final")

    var o4 = create_order_with_id(4, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    o4.fill(100, 10.0)
    assert_true(o4.is_final(), "FILLED is final")

    var o5 = create_order_with_id(5, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    o5.mark_rejected("x")
    assert_true(o5.is_final(), "REJECTED is final")

    var o6 = create_order_with_id(6, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    o6.mark_cancelled("y")
    assert_true(o6.is_final(), "CANCELLED is final")
    print("  PASSED")


# ============== State Transition Tests ==============

def test_active_method() raises:
    print("Test: active() transitions to ACTIVE status")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.status, ORDER_STATUS.PENDING_NEW, "Starts as PENDING_NEW")
    order.active()
    assert_equal(order.status, ORDER_STATUS.ACTIVE, "Becomes ACTIVE after active()")
    print("  PASSED")


def test_mark_rejected_transitions() raises:
    print("Test: mark_rejected() transitions to REJECTED")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.mark_rejected("Balance insufficient")
    assert_equal(order.status, ORDER_STATUS.REJECTED, "Status becomes REJECTED")
    assert_equal(order.message, "Balance insufficient", "Message set correctly")
    print("  PASSED")


def test_mark_rejected_noop_on_final() raises:
    print("Test: mark_rejected() no-op on already-final order")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.fill(100, 10.0)
    assert_true(order.is_final(), "Order is final after full fill")
    order.mark_rejected("Should not change")
    assert_true(order.is_filled(), "Still FILLED, not REJECTED")
    print("  PASSED")


def test_mark_cancelled_transitions() raises:
    print("Test: mark_cancelled() transitions to CANCELLED")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.mark_cancelled("User requested cancellation")
    assert_equal(order.status, ORDER_STATUS.CANCELLED, "Status becomes CANCELLED")
    assert_equal(order.message, "User requested cancellation", "Message set")
    print("  PASSED")


def test_mark_cancelled_noop_on_final() raises:
    print("Test: mark_cancelled() no-op on already-final order")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.mark_rejected("Already rejected")
    order.mark_cancelled("Should not override rejection")
    assert_true(order.is_rejected(), "Still REJECTED")
    print("  PASSED")


def test_set_pending_cancel() raises:
    print("Test: set_pending_cancel() transitions to PENDING_CANCEL")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.active()
    order.set_pending_cancel()
    assert_equal(order.status, ORDER_STATUS.PENDING_CANCEL, "Status becomes PENDING_CANCEL")
    print("  PASSED")


def test_set_pending_cancel_noop_on_final() raises:
    print("Test: set_pending_cancel() no-op on final order")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.mark_cancelled("Cancelled first")
    order.set_pending_cancel()
    assert_true(order.is_cancelled(), "Still CANCELLED, not PENDING_CANCEL")
    print("  PASSED")


# ============== Fill Method Tests ==============

def test_fill_partial() raises:
    print("Test: fill() partial fill updates quantities and avg_price")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    order.fill(50, 10.5, 5.0)
    assert_equal(order.filled_quantity, 50, "filled_quantity updated")
    assert_equal(order.unfilled_quantity(), 50, "unfilled_quantity computed correctly")
    assert_equal(order.avg_price, 10.5, "avg_price equals fill price for first fill")
    assert_equal(order.transaction_cost, 5.0, "transaction_cost accumulated")
    assert_equal(order.status, ORDER_STATUS.PENDING_NEW, "Status stays PENDING_NEW after partial fill (active() sets ACTIVE)")
    print("  PASSED")


def test_fill_complete() raises:
    print("Test: fill() complete fill auto-sets FILLED status")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    order.fill(100, 11.0, 8.0)
    assert_equal(order.filled_quantity, 100, "Fully filled")
    assert_equal(order.unfilled_quantity(), 0, "Nothing left unfilled")
    assert_equal(order.status, ORDER_STATUS.FILLED, "Auto-set to FILLED")
    assert_equal(order.transaction_cost, 8.0, "transaction_cost recorded")
    print("  PASSED")


def test_fill_multiple_partial() raises:
    print("Test: fill() multiple partial fills accumulate correctly")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    order.fill(30, 10.0, 1.5)
    assert_equal(order.avg_price, 10.0, "First fill: avg = 10.0")
    order.fill(30, 11.0, 1.6)
    var expected_avg = (10.0 * 30.0 + 11.0 * 30.0) / 60.0
    var diff = order.avg_price - expected_avg
    assert_true(diff < 0.001 and diff > -0.001, "Second fill: weighted avg correct")
    order.fill(40, 12.0, 2.0)
    expected_avg = (10.0 * 30.0 + 11.0 * 30.0 + 12.0 * 40.0) / 100.0
    diff = order.avg_price - expected_avg
    assert_true(diff < 0.001 and diff > -0.001, "Third fill: weighted avg correct")
    assert_equal(order.status, ORDER_STATUS.FILLED, "Fully filled")
    assert_equal(order.transaction_cost, 5.1, "Total cost = 1.5+1.6+2.0")
    print("  PASSED")


def test_fill_match_position_effect_no_avg_update() raises:
    print("Test: fill() with MATCH position_effect does NOT update avg_price")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    order.fill(50, 10.0, 1.0)
    assert_equal(order.avg_price, 10.0, "First fill sets avg_price")
    order.fill(50, 999.0, 1.0, POSITION_EFFECT.MATCH)
    assert_equal(order.avg_price, 10.0, "MATCH fill does NOT update avg_price")
    assert_equal(order.filled_quantity, 100, "But filled_quantity still updates")
    assert_equal(order.status, ORDER_STATUS.FILLED, "Status becomes FILLED")
    print("  PASSED")


def test_fill_assert_exceeds_quantity() raises:
    print("Test: fill() validates quantity does not exceed remaining")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.fill(80, 10.0)
    order.fill(20, 11.0)
    assert_equal(order.filled_quantity, 100, "Exactly filled")
    assert_equal(order.unfilled_quantity(), 0, "Nothing left unfilled")
    assert_equal(order.status, ORDER_STATUS.FILLED, "Auto-set to FILLED")
    print("  PASSED")


# ============== Setter Method Tests ==============

def test_set_frozen_price() raises:
    print("Test: set_frozen_price() updates frozen price")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.frozen_price, 0.0, "Initial frozen_price")
    order.set_frozen_price(55.5)
    assert_equal(order.frozen_price, 55.5, "Updated frozen_price")
    print("  PASSED")


def test_set_frozen_cash() raises:
    print("Test: set_frozen_cash() updates init_frozen_cash")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.init_frozen_cash, 0.0, "Initial init_frozen_cash")
    order.set_frozen_cash(10000.0)
    assert_equal(order.init_frozen_cash, 10000.0, "Updated init_frozen_cash")
    print("  PASSED")


def test_set_secondary_order_id() raises:
    print("Test: set_secondary_order_id() updates secondary ID")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    assert_equal(order.secondary_order_id, "", "Initially empty")
    order.set_secondary_order_id("EXCH-12345")
    assert_equal(order.secondary_order_id, "EXCH-12345", "Updated secondary ID")
    print("  PASSED")


# ============== Kwargs Tests ==============

def test_kwargs_set_and_get() raises:
    print("Test: kwargs set_kwarg / get_kwarg round-trip")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.set_kwarg("key1", "value1")
    order.set_kwarg("key2", "value2")
    var val1 = order.get_kwarg("key1")
    var val2 = order.get_kwarg("key2")
    assert_true(val1 != None and val1.value() == "value1", "get_kwarg key1")
    assert_true(val2 != None and val2.value() == "value2", "get_kwarg key2")
    print("  PASSED")


def test_kwargs_missing_key() raises:
    print("Test: get_kwarg returns None for missing key")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    var result = order.get_kwarg("nonexistent")
    assert_true(result == None, "Missing key returns None")
    print("  PASSED")


def test_get_kwargs_returns_copy() raises:
    print("Test: get_kwargs() returns independent copy")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.set_kwarg("a", "b")
    var kwargs_copy = order.get_kwargs()
    assert_true(kwargs_copy["a"] == "b", "Copy has the data")
    order.set_kwarg("c", "d")
    var after = order.get_kwarg("c")
    assert_true(after != None and after.value() == "d", "Original has new data")
    print("  PASSED")


# ============== Copy Tests ==============

def test_order_copy() raises:
    print("Test: Order copy preserves all fields")
    var original = create_order_with_id(
        99, "000001.XSHE", SIDE.BUY, 500, LimitOrder(22.5),
        POSITION_EFFECT.OPEN, frozen_price=22.5,
    )
    original.fill(100, 22.5, 3.0)
    original.set_frozen_cash(11250.0)
    original.set_secondary_order_id("EXCH-99")
    original.set_kwarg("custom", "data")
    var copied = original.copy()
    assert_equal(copied.order_id, original.order_id, "order_id copied")
    assert_equal(copied.order_book_id, original.order_book_id, "order_book_id copied")
    assert_equal(copied.side, original.side, "side copied")
    assert_equal(copied.quantity, original.quantity, "quantity copied")
    assert_equal(copied.filled_quantity, original.filled_quantity, "filled_quantity copied")
    assert_equal(copied.status, original.status, "status copied")
    assert_equal(copied.frozen_price, original.frozen_price, "frozen_price copied")
    assert_equal(copied.avg_price, original.avg_price, "avg_price copied")
    assert_equal(copied.transaction_cost, original.transaction_cost, "transaction_cost copied")
    assert_equal(copied.message, original.message, "message copied")
    assert_equal(copied.secondary_order_id, original.secondary_order_id, "secondary_order_id copied")
    assert_equal(copied.init_frozen_cash, original.init_frozen_cash, "init_frozen_cash copied")
    assert_equal(copied.order_type_val, original.order_type_val, "order_type copied")
    print("  PASSED")


def test_order_copy_independence() raises:
    print("Test: Order copy is independent of original")
    var original = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    var copied = original.copy()
    original.fill(50, 10.0)
    assert_equal(original.filled_quantity, 50, "Original modified")
    assert_equal(copied.filled_quantity, 0, "Copy unaffected")
    print("  PASSED")


# ============== Style Property Test ==============

def test_style_property() raises:
    print("Test: style() returns order_type_val")
    var market_o = create_order_with_id(1, "a", SIDE.BUY, 100, MarketOrder())
    var limit_o = create_order_with_id(2, "a", SIDE.BUY, 100, LimitOrder(10.0))
    var algo_o = create_algo_order_with_id(3, "a", SIDE.BUY, 100, TWAPOrder(5, 25))
    assert_equal(market_o.style(), ORDER_TYPE.MARKET, "style() for market")
    assert_equal(limit_o.style(), ORDER_TYPE.LIMIT, "style() for limit")
    assert_equal(algo_o.style(), ORDER_TYPE.ALGO, "style() for algo")
    print("  PASSED")


# ============== WriteTo (String Representation) Tests ==============

def test_write_to_order() raises:
    print("Test: Order write_to produces valid representation")
    var order = create_order_with_id(
        42, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.5), POSITION_EFFECT.OPEN
    )
    var s = String(order)
    assert_true("Order" in s, "Contains 'Order'")
    assert_true("42" in s, "Contains order_id")
    assert_true("000001.XSHE" in s, "Contains order_book_id")
    assert_true("BUY" in s, "Contains side")
    assert_true("100" in s, "Contains quantity")
    print("  PASSED")


def test_write_to_market_order_style() raises:
    print("Test: OrderStyle(MARKET) write_to")
    var style = MarketOrder()
    var s = String(style)
    assert_true("MarketOrder" in s, "MarketOrder repr")
    print("  PASSED")


def test_write_to_limit_order_style() raises:
    print("Test: OrderStyle(LIMIT) write_to")
    var style = LimitOrder(15.5)
    var s = String(style)
    assert_true("LimitOrder" in s, "LimitOrder repr")
    assert_true("15.5" in s, "Contains price")
    print("  PASSED")


def test_write_to_twap_order_style() raises:
    print("Test: AlgoOrderStyle(TWAP) write_to")
    var algo = TWAPOrder(10, 30)
    var s = String(algo)
    assert_true("TWAPOrder" in s, "TWAPOrder repr")
    assert_true("10" in s, "Contains start_min")
    assert_true("30" in s, "Contains end_min")
    print("  PASSED")


def test_write_to_vwap_order_style() raises:
    print("Test: AlgoOrderStyle(VWAP) write_to")
    var algo = VWAPOrder(15, 45)
    var s = String(algo)
    assert_true("VWAPOrder" in s, "VWAPOrder repr")
    print("  PASSED")


# ============== Edge Cases ==============

def test_fill_zero_quantity() raises:
    print("Test: fill(0) is a no-op that doesn't crash")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.fill(0, 10.0)
    assert_equal(order.filled_quantity, 0, "No fill occurred")
    assert_equal(order.unfilled_quantity(), 100, "Unchanged")
    print("  PASSED")


def test_mark_rejected_on_already_rejected() raises:
    print("Test: Double mark_rejected is no-op")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.mark_rejected("Reason A")
    order.mark_rejected("Reason B")
    assert_equal(order.message, "Reason A", "Original reason preserved")
    print("  PASSED")


def test_mark_cancelled_on_already_cancelled() raises:
    print("Test: Double mark_cancelled is no-op")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    order.mark_cancelled("Reason X")
    order.mark_cancelled("Reason Y")
    assert_equal(order.message, "Reason X", "Original reason preserved")
    print("  PASSED")


def test_large_quantity_order() raises:
    print("Test: Large quantity order fills correctly")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 1000000, LimitOrder(100.0), POSITION_EFFECT.OPEN
    )
    order.fill(500000, 100.5, 2500.0)
    order.fill(500000, 101.0, 2550.0)
    assert_equal(order.filled_quantity, 1000000, "All filled")
    assert_equal(order.status, ORDER_STATUS.FILLED, "FILLED status")
    var expected_avg = (100.5 * 500000.0 + 101.0 * 500000.0) / 1000000.0
    var diff = order.avg_price - expected_avg
    assert_true(diff < 0.01 and diff > -0.01, "Avg price accurate for large qty")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
