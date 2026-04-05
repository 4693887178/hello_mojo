"""
Test for model/order.mojo
Group 10 - File 7
"""

from std.collections import Dict, List
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder, buy, sell
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_order_struct() raises:
    print("Test: Order struct exists")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    assert_equal(order.order_id, 1, "Order ID should match")
    assert_equal(order.order_book_id, "000001.XSHE", "Order book ID should match")
    print("  PASSED")


def test_order_status() raises:
    print("Test: Order status methods")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    assert_true(order.status == ORDER_STATUS.PENDING_NEW, "Initial status should be PENDING_NEW")
    print("  PASSED")


def test_order_is_active() raises:
    print("Test: Order is_active method")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    assert_true(order.is_active(), "Order should be active when PENDING_NEW")
    print("  PASSED")


def test_order_mark_rejected() raises:
    print("Test: Order mark_rejected method")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    order.mark_rejected("Test rejection")
    assert_true(order.is_rejected(), "Order should be rejected after mark_rejected")
    assert_equal(order.message, "Test rejection", "Message should match")
    print("  PASSED")


def test_buy_function() raises:
    print("Test: buy function")
    var order = buy("000001.XSHE", 100)
    assert_equal(order.side, SIDE.BUY, "Side should be BUY")
    assert_equal(order.quantity, 100, "Quantity should match")
    print("  PASSED")


def test_sell_function() raises:
    print("Test: sell function")
    var order = sell("000001.XSHE", 100)
    assert_equal(order.side, SIDE.SELL, "Side should be SELL")
    assert_equal(order.quantity, 100, "Quantity should match")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
