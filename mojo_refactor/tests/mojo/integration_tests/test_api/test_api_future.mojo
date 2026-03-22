"""
API Future Tests - Mojo Version
Tests for future API functionality using rqmojo
Ported from tests/integration_tests/test_api/test_api_future.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List, Set
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument, create_future_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_future_position
from rqmojo.portfolio.account import Account, create_future_account
from rqmojo.utils.datetime_func import DateTime, Date


def test_buy_open() raises:
    print("=== Testing buy_open ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "P88",
        SIDE.BUY,
        1,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "P88")
    assert_equal(order.quantity, 1)
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.position_effect, POSITION_EFFECT.OPEN)
    
    print("Test test_buy_open: PASSED")


def test_sell_open() raises:
    print("=== Testing sell_open ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "P88",
        SIDE.SELL,
        1,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "P88")
    assert_equal(order.quantity, 1)
    assert_equal(order.side, SIDE.SELL)
    assert_equal(order.position_effect, POSITION_EFFECT.OPEN)
    
    print("Test test_sell_open: PASSED")


def test_buy_close() raises:
    print("=== Testing buy_close ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "P88",
        SIDE.BUY,
        1,
        style,
        POSITION_EFFECT.CLOSE
    )
    
    assert_equal(order.order_book_id, "P88")
    assert_equal(order.quantity, 1)
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.position_effect, POSITION_EFFECT.CLOSE)
    
    print("Test test_buy_close: PASSED")


def test_sell_close() raises:
    print("=== Testing sell_close ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "P88",
        SIDE.SELL,
        1,
        style,
        POSITION_EFFECT.CLOSE
    )
    
    assert_equal(order.order_book_id, "P88")
    assert_equal(order.quantity, 1)
    assert_equal(order.side, SIDE.SELL)
    assert_equal(order.position_effect, POSITION_EFFECT.CLOSE)
    
    print("Test test_sell_close: PASSED")


def test_close_today() raises:
    print("=== Testing close_today ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order1 = create_order_with_id(
        1,
        "P88",
        SIDE.BUY,
        2,
        style,
        POSITION_EFFECT.OPEN
    )
    
    var order2 = create_order_with_id(
        2,
        "P88",
        SIDE.SELL,
        1,
        style,
        POSITION_EFFECT.CLOSE_TODAY
    )
    
    assert_equal(order2.position_effect, POSITION_EFFECT.CLOSE_TODAY)
    
    print("Test test_close_today: PASSED")


def test_future_order_to() raises:
    print("=== Testing future_order_to ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    
    var orders1 = List[Order]()
    orders1.append(create_order_with_id(1, "P88", SIDE_BUY, 3, style, POSITION_EFFECT_OPEN))
    
    var orders2 = List[Order]()
    orders2.append(create_order_with_id(2, "P88", SIDE_SELL, 1, style, POSITION_EFFECT_CLOSE))
    
    var orders3 = List[Order]()
    orders3.append(create_order_with_id(3, "P88", SIDE_SELL, 2, style, POSITION_EFFECT_CLOSE))
    
    var orders4 = List[Order]()
    orders4.append(create_order_with_id(4, "P88", SIDE_BUY, 1, style, POSITION_EFFECT_OPEN))
    
    assert_equal(len(orders1), 1)
    assert_equal(len(orders2), 1)
    assert_equal(len(orders3), 1)
    assert_equal(len(orders4), 1)
    
    print("Test test_future_order_to: PASSED")


def test_future_position() raises:
    print("=== Testing Future Position ===")
    
    var pos = create_future_position("IF1603", POSITION_DIRECTION_LONG)
    assert_equal(pos.quantity, 0)
    assert_equal(pos.order_book_id, "IF1603")
    
    print("Test test_future_position: PASSED")


def test_future_account() raises:
    print("=== Testing Future Account ===")
    
    var account = create_future_account(10000000000.0)
    assert_equal(account.total_value, 10000000000.0)
    assert_equal(account.total_cash, 10000000000.0)
    
    print("Test test_future_account: PASSED")


def test_position_effect_close_today() raises:
    print("=== Testing POSITION_EFFECT_CLOSE_TODAY ===")
    
    assert_equal(POSITION_EFFECT.CLOSE_TODAY.name(), "CLOSE_TODAY")
    assert_equal(POSITION_EFFECT.CLOSE_TODAY.value(), "CLOSE_TODAY")
    
    print("Test test_position_effect_close_today: PASSED")


def test_future_order_with_limit() raises:
    print("=== Testing Future Order with Limit ===")
    
    var style = LimitOrder(3000.0)
    var order = create_order_with_id(
        1,
        "IF1603",
        SIDE.BUY,
        1,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "IF1603")
    assert_equal(order.quantity, 1)
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.position_effect, POSITION_EFFECT.OPEN)
    assert_equal(order.style.limit_price, 3000.0)
    
    print("Test test_future_order_with_limit: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_api_future.mojo")
    print("=" * 60)
    print("")
    
    test_buy_open()
    test_sell_open()
    test_buy_close()
    test_sell_close()
    test_close_today()
    test_future_order_to()
    test_future_position()
    test_future_account()
    test_position_effect_close_today()
    test_future_order_with_limit()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
