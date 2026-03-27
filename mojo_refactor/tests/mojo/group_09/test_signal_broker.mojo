"""
Test for mod/rqmojo_mod_sys_simulation/signal_broker.mojo
Group 09 - File 6
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_signal_broker_init() raises:
    print("Test: SignalBroker init")
    var _ = create_signal_broker()
    print("  PASSED")


def test_signal_broker_get_order_count() raises:
    print("Test: SignalBroker get_order_count")
    var broker = create_signal_broker()
    var count = broker.get_order_count()
    assert_equal(count, 0, "Order count should be 0")
    print("  PASSED")


def test_signal_broker_get_open_orders() raises:
    print("Test: SignalBroker get_open_orders")
    var broker = create_signal_broker()
    var _ = broker.get_open_orders()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
