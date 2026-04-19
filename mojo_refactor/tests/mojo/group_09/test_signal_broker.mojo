"""
Test for mod/rqmojo_mod_sys_simulation/signal_broker.mojo
Group 09 - File 6
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.environment import create_environment
from rqmojo.utils.typing import DateTime


def test_signal_broker_init() raises:
    print("Test: SignalBroker init")
    var env = create_environment(DateTime(2015, 1, 1), DateTime(2016, 1, 1))
    var broker = create_signal_broker(env^)
    print("  PASSED")


def test_signal_broker_get_open_orders() raises:
    print("Test: SignalBroker get_open_orders")
    var env = create_environment(DateTime(2015, 1, 1), DateTime(2016, 1, 1))
    var broker = create_signal_broker(env^)
    var orders = broker.get_open_orders()
    assert_equal(len(orders), 0, "Open orders should be empty")
    print("  PASSED")


def test_signal_broker_cancel_order() raises:
    print("Test: SignalBroker cancel_order (should warn)")
    var env = create_environment(DateTime(2015, 1, 1), DateTime(2016, 1, 1))
    var broker = create_signal_broker(env^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    broker.cancel_order(order)
    print("  PASSED")


def test_signal_broker_submit_market_order() raises:
    print("Test: SignalBroker submit market order")
    var env = create_environment(DateTime(2015, 1, 1), DateTime(2016, 1, 1))
    var broker = create_signal_broker(env^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_true(order.is_filled() or order.status == ORDER_STATUS.FILLED, "Order should be filled after market submit")
    print("  PASSED")


def test_signal_broker_submit_limit_order() raises:
    print("Test: SignalBroker submit limit order")
    var env = create_environment(DateTime(2015, 1, 1), DateTime(2016, 1, 1))
    var broker = create_signal_broker(env^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_true(order.is_filled() or order.status == ORDER_STATUS.FILLED, "Limit order should be filled if price valid")
    print("  PASSED")


def test_signal_broker_exercise_order_raises() raises:
    print("Test: SignalBroker exercise order raises error")
    var env = create_environment(DateTime(2015, 1, 1), DateTime(2016, 1, 1))
    var broker = create_signal_broker(env^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.EXERCISE
    )
    with assert_raises():
        broker.submit_order(order)
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
