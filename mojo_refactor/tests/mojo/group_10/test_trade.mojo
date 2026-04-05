"""
Test for model/trade.mojo
Group 10 - File 8
"""

from std.collections import Dict, List
from rqmojo.model.trade import Trade, create_trade
from rqmojo.model.order import Order, create_order_with_id, MarketOrder
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_trade_struct() raises:
    print("Test: Trade struct exists")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    var trade = create_trade(order=order, quantity=100, price=10.0)
    assert_equal(trade.order_id, 1, "Trade order_id should match")
    assert_equal(trade.quantity, 100, "Trade quantity should match")
    assert_equal(trade.price, 10.0, "Trade price should match")
    print("  PASSED")


def test_trade_price() raises:
    print("Test: Trade price property")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    var trade = create_trade(order=order, quantity=100, price=10.5)
    assert_equal(trade.price, 10.5, "Trade price should match")
    print("  PASSED")


def test_trade_order_book_id() raises:
    print("Test: Trade order_book_id property")
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000002.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    var trade = create_trade(order=order, quantity=100, price=10.0)
    assert_equal(trade.order_book_id, "000002.XSHE", "Trade order_book_id should match")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
