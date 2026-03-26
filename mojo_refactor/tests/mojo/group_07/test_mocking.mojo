"""
Test for utils/testing/mocking.mojo
Group 07 - File 10
"""

from std.collections import Dict, List
from rqmojo.utils.testing.mocking import (
    MockDataProxy, create_mock_data_proxy, create_mock_order
 create_mock_bar, create_mock_tick
)
 from rqmojo.model.order import Order, create_order_with_id
 from rqmojo.model.bar import BarObject, create_bar_object
 from rqmojo.const import SIDE, POSITION_EFFECT
 from rqmojo.utils.typing import DateTime


def test_mock_data_proxy() -> Bool:
    print("Test: MockDataProxy init")
    var proxy = create_mock_data_proxy()
    print("  PASSED")
    return True


def test_create_mock_order() -> Bool:
    print("Test: create_mock_order function")
    var order = create_mock_order(order_book_id="000001.XSHE", quantity=100, price=10.0)
    if order.order_book_id != "000001.XSHE":
        raise "Order book ID should be 000001.XSHE"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 07 File 10: Mocking Tests ===")
    print("")
    var passed = 2
    var failed = 0
    
    if test_mock_data_proxy():
        passed += 1
    else:
        failed += 1
    
    if test_create_mock_order():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
