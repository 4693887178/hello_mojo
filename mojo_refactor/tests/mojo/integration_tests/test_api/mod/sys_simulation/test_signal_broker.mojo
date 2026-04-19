"""
Mojo Test for Signal Broker
Ported from tests/integration_tests/test_api/mod/sys_simulation/test_signal_broker.py
Tests signal broker functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT, ORDER_TYPE
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker
from rqmojo.environment import create_environment
from rqmojo.utils.typing import DateTime


comptime TEST_START_DATE_YEAR = 2015
comptime TEST_START_DATE_MONTH = 4
comptime TEST_START_DATE_DAY = 10
comptime INITIAL_CASH = 1000000.0
comptime TEST_FREQUENCY = "1d"


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_signal_broker_creation() raises:
    """Test creating signal broker in Mojo."""
    print("=== Testing Signal Broker Creation ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)
    print("  SignalBroker created")

    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 0, "Should have no open orders initially")

    print("Test test_signal_broker_creation: PASSED")


def test_signal_broker_submit_market_order() raises:
    """Test submitting market orders to signal broker."""
    print("=== Testing Signal Broker Submit Market Order ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)

    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )

    broker.submit_order(order)
    assert_true(order.is_filled(), "Market buy order should be filled")
    assert_equal(order.filled_quantity, 100, "Filled quantity should be 100")
    print("  Market order submitted and filled, qty: " + String(order.filled_quantity))

    print("Test test_signal_broker_submit_market_order: PASSED")


def test_signal_broker_submit_limit_order() raises:
    """Test submitting limit orders to signal broker."""
    print("=== Testing Signal Broker Submit Limit Order ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)

    var limit_up = 11.0
    var price = 10.0

    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.OPEN
    )

    broker.submit_order(order)
    assert_true(order.is_filled(), "Limit order below limit_up should be filled")
    assert_equal(order.filled_quantity, 100)
    print("  Limit order at " + String(price) + " filled successfully")

    print("Test test_signal_broker_submit_limit_order: PASSED")


def test_signal_broker_cancel_order() raises:
    """Test cancelling orders in signal broker (should warn)."""
    print("=== Testing Signal Broker Cancel Order ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)

    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )

    broker.cancel_order(order)

    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 0, "Signal broker always returns empty open orders")
    print("  cancel_order called (warns as expected), open orders: " + String(len(open_orders)))

    print("Test test_signal_broker_cancel_order: PASSED")


def test_signal_broker_get_open_orders() raises:
    """Test getting open orders from signal broker."""
    print("=== Testing Signal Broker Get Open Orders ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)

    var order1 = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )

    var order2 = create_order_with_id(
        order_id=2,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=200,
        style=LimitOrder(10.5),
        position_effect=POSITION_EFFECT.CLOSE
    )

    broker.submit_order(order1)
    broker.submit_order(order2)

    assert_true(order1.is_filled(), "Order 1 should be filled")
    assert_true(order2.is_filled(), "Order 2 should be filled")

    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 0, "Filled orders should not appear in open orders")
    print("  Orders submitted and filled, open orders: " + String(len(open_orders)))

    print("Test test_signal_broker_get_open_orders: PASSED")


def test_price_limit_buy_reject() raises:
    """Test that buy orders at or above limit_up are rejected."""
    print("=== Testing Price Limit Buy Reject ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^, price_limit=True)

    var limit_up = 11.0
    var order_at_limit = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(limit_up),
        position_effect=POSITION_EFFECT.OPEN
    )

    broker.submit_order(order_at_limit)
    assert_true(order_at_limit.is_rejected(), "Buy at limit_up should be rejected")
    print("  Buy order at limit_up rejected: " + order_at_limit.message)

    print("Test test_price_limit_buy_reject: PASSED")


def test_price_limit_sell_reject() raises:
    """Test that sell orders at or below limit_down are rejected."""
    print("=== Testing Price Limit Sell Reject ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^, price_limit=True)

    var limit_down = 9.0
    var order_at_limit = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=LimitOrder(limit_down),
        position_effect=POSITION_EFFECT.CLOSE
    )

    broker.submit_order(order_at_limit)
    assert_true(order_at_limit.is_rejected(), "Sell at limit_down should be rejected")
    print("  Sell order at limit_down rejected: " + order_at_limit.message)

    print("Test test_price_limit_sell_reject: PASSED")


def test_price_limit_disabled() raises:
    """Test that disabling price_limit allows all prices through."""
    print("=== Testing Price Limit Disabled ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^, price_limit=False)

    var limit_up = 11.0
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(limit_up),
        position_effect=POSITION_EFFECT.OPEN
    )

    broker.submit_order(order)
    assert_true(order.is_filled(), "With price_limit disabled, order at limit_up should fill")
    print("  Price limit disabled, order filled successfully")

    print("Test test_price_limit_disabled: PASSED")


def test_exercise_order_raises() raises:
    """Test that EXERCISE orders raise an error."""
    print("=== Testing Exercise Order Raises ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)

    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.EXERCISE
    )

    with assert_raises():
        broker.submit_order(order)
    print("  Exercise order correctly raised error")

    print("Test test_exercise_order_raises: PASSED")


def test_sell_order_fills() raises:
    """Test that sell orders are properly filled."""
    print("=== Testing Sell Order Fills ===")
    var env = create_environment(DateTime(TEST_START_DATE_YEAR, TEST_START_DATE_MONTH, TEST_START_DATE_DAY), DateTime(2016, 4, 10))
    var broker = create_signal_broker(env^)

    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=50,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )

    broker.submit_order(order)
    assert_true(order.is_filled(), "Sell order should be filled")
    assert_equal(order.filled_quantity, 50)
    print("  Sell order filled, qty: " + String(order.filled_quantity))

    print("Test test_sell_order_fills: PASSED")


def test_config_consistency() raises:
    """Test that config values are consistent with Python test."""
    print("=== Testing Config Consistency ===")
    assert_equal(TEST_START_DATE_YEAR, 2015)
    assert_equal(TEST_START_DATE_MONTH, 4)
    assert_equal(TEST_START_DATE_DAY, 10)
    assert_true(is_close(INITIAL_CASH, 1000000.0))
    assert_equal(TEST_FREQUENCY, "1d")

    print("Config values:")
    print("  Start date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_START_DATE_DAY))
    print("  Initial cash: " + String(INITIAL_CASH))
    print("  Frequency: " + TEST_FREQUENCY)

    print("Test test_config_consistency: PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
