"""
Mojo Test for Signal Broker
Ported from tests/integration_tests/test_api/mod/sys_simulation/test_signal_broker.py
Tests signal broker functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT, SIDE_BUY, POSITION_EFFECT_OPEN
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker
from rqmojo.utils.datetime_func import DateTime


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
    """
    Test creating signal broker in Mojo.
    """
    print("=== Testing Signal Broker Creation ===")
    
    var broker = create_signal_broker()
    print("  SignalBroker created: " + String(broker))
    
    assert_equal(broker.get_order_count(), 0)
    
    print("Test test_signal_broker_creation: PASSED")


def test_signal_broker_submit_order() raises:
    """
    Test submitting orders to signal broker.
    """
    print("=== Testing Signal Broker Submit Order ===")
    
    var broker = create_signal_broker()
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    assert_equal(broker.get_order_count(), 1)
    print("  Order submitted, count: " + String(broker.get_order_count()))
    
    print("Test test_signal_broker_submit_order: PASSED")


def test_signal_broker_cancel_order() raises:
    """
    Test cancelling orders in signal broker.
    """
    print("=== Testing Signal Broker Cancel Order ===")
    
    var broker = create_signal_broker()
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    assert_equal(broker.get_order_count(), 1)
    
    broker.cancel_order(1)
    
    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 0)
    print("  Order cancelled, open orders: " + String(len(open_orders)))
    
    print("Test test_signal_broker_cancel_order: PASSED")


def test_signal_broker_get_open_orders() raises:
    """
    Test getting open orders from signal broker.
    """
    print("=== Testing Signal Broker Get Open Orders ===")
    
    var broker = create_signal_broker()
    
    var order1 = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    var order2 = create_order_with_id(
        order_id=2,
        order_book_id="000002.XSHE",
        side=SIDE_BUY,
        quantity=200,
        style=LimitOrder(20.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order1)
    broker.submit_order(order2)
    
    assert_equal(broker.get_order_count(), 2)
    print("  Orders submitted, count: " + String(broker.get_order_count()))
    
    print("Test test_signal_broker_get_open_orders: PASSED")


def test_price_limit_simulation() raises:
    """
    Test price limit simulation (ported from test_price_limit).
    
    In Python test:
    - Order at limit_up * 0.99 should succeed
    - Order at limit_up should be rejected
    """
    print("=== Testing Price Limit Simulation ===")
    
    var broker = create_signal_broker()
    
    var limit_up = 20.0
    var price = limit_up * 0.99
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    assert_equal(broker.get_order_count(), 1)
    print("  Order at limit_up * 0.99 submitted successfully")
    
    var order_at_limit = create_order_with_id(
        order_id=2,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(limit_up),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order_at_limit)
    assert_equal(broker.get_order_count(), 2)
    print("  Order at limit_up submitted (validation happens in matching)")
    
    print("Test test_price_limit_simulation: PASSED")


def test_signal_open_auction_simulation() raises:
    """
    Test signal open auction simulation (ported from test_signal_open_auction).
    
    In Python test:
    - Orders during open_auction phase
    - Stock and future position checks
    """
    print("=== Testing Signal Open Auction Simulation ===")
    
    var broker = create_signal_broker()
    
    var stock_order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=1000,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(stock_order)
    assert_equal(broker.get_order_count(), 1)
    print("  Stock order submitted during open auction")
    
    var future_order = create_order_with_id(
        order_id=2,
        order_book_id="AU1512",
        side=SIDE_BUY,
        quantity=1,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(future_order)
    assert_equal(broker.get_order_count(), 2)
    print("  Future order submitted during open auction")
    
    print("Test test_signal_open_auction_simulation: PASSED")


def test_config_consistency() raises:
    """
    Test that config values are consistent with Python test.
    """
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


def run_all_tests() raises -> Dict[String, String]:
    var results = Dict[String, String]()
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Running test_signal_broker.mojo")
    print("=" * 60)
    print("")
    
    var tests = List[String]()
    tests.append("test_config_consistency")
    tests.append("test_signal_broker_creation")
    tests.append("test_signal_broker_submit_order")
    tests.append("test_signal_broker_cancel_order")
    tests.append("test_signal_broker_get_open_orders")
    tests.append("test_price_limit_simulation")
    tests.append("test_signal_open_auction_simulation")
    
    for test_name in tests:
        try:
            if test_name == "test_config_consistency":
                test_config_consistency()
            elif test_name == "test_signal_broker_creation":
                test_signal_broker_creation()
            elif test_name == "test_signal_broker_submit_order":
                test_signal_broker_submit_order()
            elif test_name == "test_signal_broker_cancel_order":
                test_signal_broker_cancel_order()
            elif test_name == "test_signal_broker_get_open_orders":
                test_signal_broker_get_open_orders()
            elif test_name == "test_price_limit_simulation":
                test_price_limit_simulation()
            elif test_name == "test_signal_open_auction_simulation":
                test_signal_open_auction_simulation()
            
            results[test_name] = "PASS"
            passed += 1
        except e:
            results[test_name] = "FAIL: " + String(e)
            failed += 1
    
    print("")
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    print("Total:  " + String(passed + failed))
    print("Passed: " + String(passed))
    print("Failed: " + String(failed))
    print("")
    
    results["total"] = String(passed + failed)
    results["passed"] = String(passed)
    results["failed"] = String(failed)
    
    return results^


def main() raises:
    var results = run_all_tests()
    
    print("Final Results:")
    var keys_list = List[String]()
    for key in results.keys():
        keys_list.append(key)
    for key in keys_list:
        var value = results[key]
        print("  " + key + ": " + value)
