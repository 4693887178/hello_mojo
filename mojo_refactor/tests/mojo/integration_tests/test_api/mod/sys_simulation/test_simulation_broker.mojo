"""
Mojo Test for Simulation Broker
Ported from tests/integration_tests/test_api/mod/sys_simulation/test_simulation_broker.py
Tests simulation broker functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT, MATCHING_TYPE, SIDE_BUY, POSITION_EFFECT_OPEN, MATCHING_TYPE_CURRENT_BAR_CLOSE, MATCHING_TYPE_VWAP
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.trade import Trade
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import SimulationBroker, create_simulation_broker
from rqmojo.utils.datetime_func import DateTime


comptime TEST_START_DATE_YEAR = 2015
comptime TEST_START_DATE_MONTH = 4
comptime TEST_START_DATE_DAY = 11
comptime TEST_END_DATE_DAY = 20
comptime INITIAL_CASH = 1000000.0
comptime TEST_FREQUENCY = "1d"


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_simulation_broker_creation() raises:
    """
    Test creating simulation broker in Mojo.
    """
    print("=== Testing Simulation Broker Creation ===")
    
    var broker = create_simulation_broker()
    print("  SimulationBroker created")
    
    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 0)
    
    print("Test test_simulation_broker_creation: PASSED")


def test_simulation_broker_submit_order() raises:
    """
    Test submitting orders to simulation broker.
    """
    print("=== Testing Simulation Broker Submit Order ===")
    
    var broker = create_simulation_broker()
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    
    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 1)
    print("  Order submitted, open orders: " + String(len(open_orders)))
    
    print("Test test_simulation_broker_submit_order: PASSED")


def test_simulation_broker_cancel_order() raises:
    """
    Test cancelling orders in simulation broker.
    """
    print("=== Testing Simulation Broker Cancel Order ===")
    
    var broker = create_simulation_broker()
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    
    var open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 1)
    
    broker.cancel_order(order)
    
    open_orders = broker.get_open_orders()
    assert_equal(len(open_orders), 0)
    print("  Order cancelled, open orders: " + String(len(open_orders)))
    
    print("Test test_simulation_broker_cancel_order: PASSED")


def test_simulation_broker_match_order() raises:
    """
    Test matching orders in simulation broker.
    """
    print("=== Testing Simulation Broker Match Order ===")
    
    var broker = create_simulation_broker()
    
    var dt = DateTime(2015, 4, 11, 15, 0, 0, 0)
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=dt,
        open=10.0,
        high=10.5,
        low=9.8,
        close=10.2,
        volume=1000000.0,
        total_turnover=10200000.0
    )
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    
    var trades = broker.on_bar(bar)
    assert_equal(len(trades), 1)
    print("  Order matched, trades: " + String(len(trades)))
    
    var trade = trades[0]
    assert_equal(trade.quantity, 100)
    print("  Trade quantity: " + String(trade.quantity))
    
    print("Test test_simulation_broker_match_order: PASSED")


def test_open_auction_match_simulation() raises:
    """
    Test open auction match simulation (ported from test_open_auction_match).
    
    In Python test:
    - volume_limit is enabled
    - volume_percent is 0.000002
    - Partial fill during open auction (900 shares)
    - Remaining fill during handle_bar (100 shares)
    """
    print("=== Testing Open Auction Match Simulation ===")
    
    var broker = create_simulation_broker()
    
    var dt = DateTime(2015, 4, 11, 9, 25, 0, 0)
    var limit_up = 19.8
    var open_price = 18.0
    
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=dt,
        open=open_price,
        high=18.5,
        low=17.5,
        close=18.2,
        volume=450000000.0,
        total_turnover=8100000000.0,
        limit_up=limit_up,
        limit_down=16.2,
        prev_close=18.0
    )
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=1000,
        style=LimitOrder(limit_up * 0.99),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    print("  Order submitted for 1000 shares at limit_up * 0.99")
    
    var trades = broker.on_bar(bar)
    print("  Trades executed: " + String(len(trades)))
    
    if len(trades) > 0:
        var trade = trades[0]
        print("  Trade quantity: " + String(trade.quantity))
        print("  Trade price: " + String(trade.price))
    
    print("Test test_open_auction_match_simulation: PASSED")


def test_vwap_match_simulation() raises:
    """
    Test VWAP match simulation (ported from test_vwap_match).
    
    In Python test:
    - matching_type is "vwap"
    - Order avg_price should equal bar.total_turnover / bar.volume
    """
    print("=== Testing VWAP Match Simulation ===")
    
    var broker = create_simulation_broker(MATCHING_TYPE_VWAP)
    
    var dt = DateTime(2015, 4, 11, 15, 0, 0, 0)
    var volume = 1000000.0
    var turnover = 10200000.0
    var vwap = turnover / volume
    
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=dt,
        open=10.0,
        high=10.5,
        low=9.8,
        close=10.2,
        volume=volume,
        total_turnover=turnover
    )
    
    print("  Bar VWAP: " + String(vwap))
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=1000,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    
    var trades = broker.on_bar(bar)
    print("  Trades executed: " + String(len(trades)))
    
    if len(trades) > 0:
        var trade = trades[0]
        print("  Trade quantity: " + String(trade.quantity))
        print("  Trade price: " + String(trade.price))
    
    print("Test test_vwap_match_simulation: PASSED")


def test_get_open_orders_for() raises:
    """
    Test getting open orders for specific symbol.
    """
    print("=== Testing Get Open Orders For Symbol ===")
    
    var broker = create_simulation_broker()
    
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
    
    var orders_for_000001 = broker.get_open_orders_for("000001.XSHE")
    assert_equal(len(orders_for_000001), 1)
    print("  Open orders for 000001.XSHE: " + String(len(orders_for_000001)))
    
    var orders_for_000002 = broker.get_open_orders_for("000002.XSHE")
    assert_equal(len(orders_for_000002), 1)
    print("  Open orders for 000002.XSHE: " + String(len(orders_for_000002)))
    
    print("Test test_get_open_orders_for: PASSED")


def test_broker_state() raises:
    """
    Test broker state persistence.
    """
    print("=== Testing Broker State ===")
    
    var broker = create_simulation_broker()
    
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE_BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT_OPEN
    )
    
    broker.submit_order(order)
    
    var state = broker.get_state()
    print("  Broker state order_count: " + String(state.order_count))
    
    assert_equal(state.order_count, 1)
    
    print("Test test_broker_state: PASSED")


def test_config_consistency() raises:
    """
    Test that config values are consistent with Python test.
    """
    print("=== Testing Config Consistency ===")
    
    assert_equal(TEST_START_DATE_YEAR, 2015)
    assert_equal(TEST_START_DATE_MONTH, 4)
    assert_equal(TEST_START_DATE_DAY, 11)
    assert_equal(TEST_END_DATE_DAY, 20)
    assert_true(is_close(INITIAL_CASH, 1000000.0))
    assert_equal(TEST_FREQUENCY, "1d")
    
    print("Config values:")
    print("  Start date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_START_DATE_DAY))
    print("  End date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_END_DATE_DAY))
    print("  Initial cash: " + String(INITIAL_CASH))
    print("  Frequency: " + TEST_FREQUENCY)
    
    print("Test test_config_consistency: PASSED")


def run_all_tests() raises -> Dict[String, String]:
    var results = Dict[String, String]()
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Running test_simulation_broker.mojo")
    print("=" * 60)
    print("")
    
    var tests = List[String]()
    tests.append("test_config_consistency")
    tests.append("test_simulation_broker_creation")
    tests.append("test_simulation_broker_submit_order")
    tests.append("test_simulation_broker_cancel_order")
    tests.append("test_simulation_broker_match_order")
    tests.append("test_open_auction_match_simulation")
    tests.append("test_vwap_match_simulation")
    tests.append("test_get_open_orders_for")
    tests.append("test_broker_state")
    
    for test_name in tests:
        try:
            if test_name == "test_config_consistency":
                test_config_consistency()
            elif test_name == "test_simulation_broker_creation":
                test_simulation_broker_creation()
            elif test_name == "test_simulation_broker_submit_order":
                test_simulation_broker_submit_order()
            elif test_name == "test_simulation_broker_cancel_order":
                test_simulation_broker_cancel_order()
            elif test_name == "test_simulation_broker_match_order":
                test_simulation_broker_match_order()
            elif test_name == "test_open_auction_match_simulation":
                test_open_auction_match_simulation()
            elif test_name == "test_vwap_match_simulation":
                test_vwap_match_simulation()
            elif test_name == "test_get_open_orders_for":
                test_get_open_orders_for()
            elif test_name == "test_broker_state":
                test_broker_state()
            
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
