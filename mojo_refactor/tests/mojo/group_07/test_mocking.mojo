"""
Test for utils/testing/mocking.mojo
Group 07 - File 04
"""

from rqmojo.utils.testing.mocking import MockDataProxy, create_mock_data_proxy, create_mock_order
from rqmojo.model.order import Order, create_order_with_id
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_mock_data_proxy() raises:
    print("Test: MockDataProxy init")
    var proxy = create_mock_data_proxy()
    print("  PASSED")


def test_create_mock_order() raises:
    print("Test: create_mock_order function")
    var order = create_mock_order(order_book_id="000001.XSHE", quantity=100, price=10.0)
    assert_equal(order.order_book_id, "000001.XSHE", "Order book ID should be 000001.XSHE")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
