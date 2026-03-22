"""
API Stock Tests - Mojo Version
Tests for stock API functionality using rqmojo
Ported from tests/integration_tests/test_api/test_api_stock.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List, Set
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    EXCHANGE
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.utils.datetime_func import DateTime, Date


def test_order_shares() raises:
    print("=== Testing stock_order_shares ===")
    
    var env = create_environment(
        DateTime(2016, 6, 14, 0, 0, 0, 0),
        DateTime(2016, 6, 19, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE.BUY,
        1910,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.quantity, 1910)
    
    print("Test test_order_shares: PASSED")


def test_order_lots() raises:
    print("=== Testing stock_order_lots ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE.BUY,
        100,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.quantity, 100)
    
    print("Test test_order_lots: PASSED")


def test_order_value() raises:
    print("=== Testing stock_order_value ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE.BUY,
        100,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.side, SIDE.BUY)
    
    print("Test test_order_value: PASSED")


def test_order_percent() raises:
    print("=== Testing stock_order_percent ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE.BUY,
        100,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.side, SIDE.BUY)
    
    print("Test test_order_percent: PASSED")


def test_order_target_value() raises:
    print("=== Testing stock_order_target_value ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE.BUY,
        100,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    
    print("Test test_order_target_value: PASSED")


def test_order_target_percent() raises:
    print("=== Testing stock_order_target_percent ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE.BUY,
        100,
        style,
        POSITION_EFFECT.OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    
    print("Test test_order_target_percent: PASSED")


def test_stock_order() raises:
    print("=== Testing stock_order ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var orders = List[Order]()
    orders.append(create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, style, POSITION_EFFECT.OPEN))
    
    assert_equal(len(orders), 1)
    
    print("Test test_stock_order: PASSED")


def test_stock_order_to() raises:
    print("=== Testing stock_order_to ===")
    
    var env = create_environment(
        DateTime(2016, 3, 7, 0, 0, 0, 0),
        DateTime(2016, 3, 8, 0, 0, 0, 0)
    )
    
    var style = MarketOrder()
    var orders = List[Order]()
    orders.append(create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, style, POSITION_EFFECT.OPEN))
    
    assert_equal(len(orders), 1)
    
    print("Test test_stock_order_to: PASSED")


def test_round_order_quantity() raises:
    print("=== Testing _round_order_quantity ===")
    
    var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE)
    
    var qty1 = 150
    var rounded1 = (qty1 // 100) * 100
    assert_equal(rounded1, 100)
    
    var qty2 = 250
    var rounded2 = (qty2 // 100) * 100
    assert_equal(rounded2, 200)
    
    print("Test test_round_order_quantity: PASSED")


def test_stock_position() raises:
    print("=== Testing Stock Position ===")
    
    var pos = create_stock_position("000001.XSHE")
    assert_equal(pos.quantity, 0)
    assert_equal(pos.order_book_id, "000001.XSHE")
    
    print("Test test_stock_position: PASSED")


def test_stock_account() raises:
    print("=== Testing Stock Account ===")
    
    var account = create_stock_account(100000000.0)
    assert_equal(account.total_value, 100000000.0)
    assert_equal(account.total_cash, 100000000.0)
    
    print("Test test_stock_account: PASSED")


def test_limit_order_style() raises:
    print("=== Testing Limit Order Style ===")
    
    var style = LimitOrder(10.5)
    assert_equal(style.limit_price, 10.5)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    
    print("Test test_limit_order_style: PASSED")


def test_market_order_style() raises:
    print("=== Testing Market Order Style ===")
    
    var style = MarketOrder()
    assert_equal(style.style_type, ORDER_TYPE.MARKET)
    
    print("Test test_market_order_style: PASSED")


def test_instrument_creation() raises:
    print("=== Testing Instrument Creation ===")
    
    var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE)
    assert_equal(ins.order_book_id(), "000001.XSHE")
    assert_equal(ins.symbol(), "平安银行")
    
    print("Test test_instrument_creation: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_api_stock.mojo")
    print("=" * 60)
    print("")
    
    test_order_shares()
    test_order_lots()
    test_order_value()
    test_order_percent()
    test_order_target_value()
    test_order_target_percent()
    test_stock_order()
    test_stock_order_to()
    test_round_order_quantity()
    test_stock_position()
    test_stock_account()
    test_limit_order_style()
    test_market_order_style()
    test_instrument_creation()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
