"""
Test for mod/rqmojo_mod_sys_simulation/testing.mojo
Group 09 - File 7
Comprehensive tests for SimulationEventSourceFixture and helper functions.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.mod.rqmojo_mod_sys_simulation.testing import (
    SimulationEventSourceFixture,
    create_test_order,
    create_test_bar,
    create_test_instrument,
)
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, EXCHANGE


def test_testing_module_imports() raises:
    print("Test: testing module imports correctly")
    from rqmojo.mod.rqmojo_mod_sys_simulation import testing
    print("  PASSED")


def test_simulation_event_source_fixture_init() raises:
    print("Test: SimulationEventSourceFixture init")
    var fixture = SimulationEventSourceFixture()
    print("  PASSED")


def test_simulation_event_source_fixture_env_config() raises:
    print("Test: SimulationEventSourceFixture has env_config")
    var fixture = SimulationEventSourceFixture()
    print("  PASSED")


def test_simulation_event_source_fixture_init_fixture_no_env() raises:
    print("Test: SimulationEventSourceFixture init_fixture with no env")
    var fixture = SimulationEventSourceFixture()
    fixture.init_fixture()
    print("  PASSED")


def test_create_test_order_defaults() raises:
    print("Test: create_test_order with defaults")
    var order = create_test_order()
    assert_equal(order.order_book_id, "000001.XSHE", "default order_book_id should be 000001.XSHE")
    assert_equal(order.quantity, 100, "default quantity should be 100")
    assert_equal(order.side, SIDE.BUY, "default side should be BUY")
    assert_equal(order.position_effect, POSITION_EFFECT.OPEN, "default position_effect should be OPEN")
    print("  PASSED")


def test_create_test_order_custom() raises:
    print("Test: create_test_order with custom params")
    var order = create_test_order(
        order_book_id="600000.XSHG",
        quantity=200,
        price=15.0,
        side=SIDE.SELL
    )
    assert_equal(order.order_book_id, "600000.XSHG")
    assert_equal(order.quantity, 200)
    assert_equal(order.side, SIDE.SELL)
    print("  PASSED")


def test_create_test_bar_defaults() raises:
    print("Test: create_test_bar with defaults")
    var bar = create_test_bar()
    assert_equal(bar.open(), 10.0, "default open should be 10.0")
    assert_equal(bar.high(), 11.0, "default high should be 11.0")
    assert_equal(bar.low(), 9.0, "default low should be 9.0")
    assert_equal(bar.close(), 10.5, "default close should be 10.5")
    assert_equal(bar.volume(), Float64(1000000), "default volume should be 1000000")
    print("  PASSED")


def test_create_test_bar_custom() raises:
    print("Test: create_test_bar with custom params")
    var bar = create_test_bar(
        open_price=20.0,
        high=22.0,
        low=18.0,
        close=21.0,
        volume=500000
    )
    assert_equal(bar.open(), 20.0)
    assert_equal(bar.high(), 22.0)
    assert_equal(bar.low(), 18.0)
    assert_equal(bar.close(), 21.0)
    assert_equal(bar.volume(), Float64(500000))
    print("  PASSED")


def test_create_test_instrument_defaults() raises:
    print("Test: create_test_instrument with defaults")
    var instrument = create_test_instrument()
    var ob_id = instrument.order_book_id()
    var sym = instrument.symbol()
    assert_equal(ob_id, "000001.XSHE", "default order_book_id should be 000001.XSHE")
    assert_equal(sym, "000001", "symbol should be extracted from order_book_id")
    print("  PASSED")


def test_create_test_instrument_custom() raises:
    print("Test: create_test_instrument with custom params")
    var instrument = create_test_instrument(order_book_id="300033.XSHE")
    var ob_id2 = instrument.order_book_id()
    var sym2 = instrument.symbol()
    assert_equal(ob_id2, "300033.XSHE")
    assert_equal(sym2, "300033")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
