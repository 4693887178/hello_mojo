"""
Test for utils/testing/mocking.mojo
Group 07 - File 04
Ported from Python: mock_instrument, mock_bar, mock_tick
"""

from rqmojo.utils.testing.mocking import (
    mock_instrument,
    mock_bar,
    mock_tick,
    MockDataProxy,
    create_mock_data_proxy,
    create_mock_order,
)
from rqmojo.model.order import Order
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.instrument import Instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, TestSuite


def test_mock_instrument() raises:
    print("Test: mock_instrument function")
    var ins = mock_instrument(order_book_id="000001.XSHE")
    assert_equal(ins.order_book_id(), "000001.XSHE", "order_book_id should be 000001.XSHE")

    var ins2 = mock_instrument(
        order_book_id="600000.XSHG",
        exchange=EXCHANGE.XSHG,
    )
    assert_equal(ins2.order_book_id(), "600000.XSHG", "order_book_id should be 600000.XSHG")
    print("  PASSED")


def test_mock_bar() raises:
    print("Test: mock_bar function")
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var bar = mock_bar(ins, dt)
    assert_equal(bar.order_book_id(), "000001.XSHE", "bar order_book_id should match instrument")
    print("  PASSED")


def test_mock_tick() raises:
    print("Test: mock_tick function")
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = DateTime(2023, 1, 1, 10, 30, 0, 0)
    var tick = mock_tick(ins, dt)
    assert_equal(tick.order_book_id(), "000001.XSHE", "tick order_book_id should match instrument")
    print("  PASSED")


def test_mock_data_proxy() raises:
    print("Test: MockDataProxy init")
    var proxy = create_mock_data_proxy()
    var bar = proxy.get_bar("000001.XSHE", DateTime(2023, 1, 1, 0, 0, 0, 0))
    assert_equal(bar.order_book_id(), "000001.XSHE", "proxy.get_bar should return bar with correct id")
    print("  PASSED")


def test_create_mock_order() raises:
    print("Test: create_mock_order function")
    var order = create_mock_order(order_book_id="000001.XSHE", quantity=100, price=10.0)
    assert_equal(order.order_book_id, "000001.XSHE", "Order book ID should be 000001.XSHE")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
