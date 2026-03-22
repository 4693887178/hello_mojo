"""
API Base Tests - Mojo Version
Tests for base API functionality using rqmojo
Ported from tests/integration_tests/test_api/test_api_base.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List, Set
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_STATUS_FILLED, ORDER_STATUS_CANCELLED, POSITION_DIRECTION_LONG,
    POSITION_DIRECTION_SHORT, ORDER_TYPE_LIMIT, ORDER_TYPE_MARKET,
    ORDER_STATUS_PENDING_NEW, EXCHANGE_XSHG, EXCHANGE_XSHE
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.model.bar import BarObject, create_simple_bar
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.position_queue import PositionQueue, create_position_queue
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.portfolio_manager import Portfolio


def test_order_creation() raises:
    print("=== Testing Order Creation ===")
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE_BUY,
        100,
        style,
        POSITION_EFFECT_OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.quantity, 100)
    assert_equal(order.side, SIDE_BUY)
    
    print("Test test_order_creation: PASSED")


def test_limit_order() raises:
    print("=== Testing Limit Order ===")
    
    var style = LimitOrder(10.5)
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE_BUY,
        100,
        style,
        POSITION_EFFECT_OPEN
    )
    
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.quantity, 100)
    assert_equal(order.side, SIDE_BUY)
    assert_equal(order.position_effect, POSITION_EFFECT_OPEN)
    assert_equal(order.style.limit_price, 10.5)
    
    print("Test test_limit_order: PASSED")


def test_market_order() raises:
    print("=== Testing Market Order ===")
    
    var style = MarketOrder()
    var order = create_order_with_id(
        2,
        "600000.XSHG",
        SIDE_SELL,
        200,
        style,
        POSITION_EFFECT_CLOSE
    )
    
    assert_equal(order.order_book_id, "600000.XSHG")
    assert_equal(order.quantity, 200)
    assert_equal(order.side, SIDE_SELL)
    assert_equal(order.position_effect, POSITION_EFFECT_CLOSE)
    
    print("Test test_market_order: PASSED")


def test_position_basic() raises:
    print("=== Testing Position Basic ===")
    
    var pos = create_stock_position("000001.XSHE")
    assert_equal(pos.quantity, 0)
    assert_equal(pos.order_book_id, "000001.XSHE")
    
    print("Test test_position_basic: PASSED")


def test_position_queue_operations() raises:
    print("=== Testing Position Queue Operations ===")
    
    var queue = create_position_queue()
    assert_true(queue.is_empty())
    
    queue.push(Date(2016, 3, 7), 1000)
    assert_equal(queue.len(), 1)
    assert_equal(queue.total_quantity(), 1000)
    
    queue.push(Date(2016, 3, 8), 500)
    assert_equal(queue.len(), 2)
    assert_equal(queue.total_quantity(), 1500)
    
    queue.pop(800)
    assert_equal(queue.total_quantity(), 700)
    
    print("Test test_position_queue_operations: PASSED")


def test_account_basic() raises:
    print("=== Testing Account Basic ===")
    
    var account = create_stock_account(100000.0)
    assert_equal(account.total_value, 100000.0)
    assert_equal(account.total_cash, 100000.0)
    
    print("Test test_account_basic: PASSED")


def test_portfolio_basic() raises:
    print("=== Testing Portfolio Basic ===")
    
    var portfolio = Portfolio(
        total_value=1000000.0,
        daily_pnl=0.0,
        total_pnl=0.0,
        annualized_returns=0.0,
        unit_net_value=1.0,
        cash=1000000.0,
        positions_count=0,
        start_cash=1000000.0
    )
    assert_equal(portfolio.total_value, 1000000.0)
    assert_equal(portfolio.cash, 1000000.0)
    
    print("Test test_portfolio_basic: PASSED")


def test_environment_creation() raises:
    print("=== Testing Environment Creation ===")
    
    var start_date = DateTime(2016, 12, 1, 0, 0, 0, 0)
    var end_date = DateTime(2016, 12, 31, 0, 0, 0, 0)
    var env = create_environment(start_date, end_date)
    
    assert_equal(env.start_date().year, 2016)
    assert_equal(env.start_date().month, 12)
    assert_equal(env.start_date().day, 1)
    assert_equal(env.end_date().day, 31)
    
    print("Test test_environment_creation: PASSED")


def test_datetime_operations() raises:
    print("=== Testing DateTime Operations ===")
    
    var dt1 = DateTime(2016, 12, 1, 9, 30, 0, 0)
    var dt2 = DateTime(2016, 12, 1, 15, 0, 0, 0)
    
    assert_equal(dt1.year, 2016)
    assert_equal(dt1.month, 12)
    assert_equal(dt1.day, 1)
    assert_equal(dt1.hour, 9)
    assert_equal(dt1.minute, 30)
    
    assert_equal(dt2.hour, 15)
    assert_equal(dt2.minute, 0)
    
    print("Test test_datetime_operations: PASSED")


def test_date_operations() raises:
    print("=== Testing Date Operations ===")
    
    var date1 = Date(2016, 12, 1)
    var date2 = Date(2016, 12, 31)
    
    assert_equal(date1.year, 2016)
    assert_equal(date1.month, 12)
    assert_equal(date1.day, 1)
    
    assert_equal(date2.day, 31)
    
    print("Test test_date_operations: PASSED")


def test_instrument_creation() raises:
    print("=== Testing Instrument Creation ===")
    
    var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE_XSHE)
    assert_equal(ins.order_book_id(), "000001.XSHE")
    assert_equal(ins.symbol(), "平安银行")
    
    print("Test test_instrument_creation: PASSED")


def test_bar_object() raises:
    print("=== Testing Bar Object ===")
    
    var bar = create_simple_bar(
        order_book_id="000001.XSHE",
        dt=DateTime(2016, 12, 1, 0, 0, 0, 0),
        open=10.0,
        high=10.5,
        low=9.8,
        close=10.2,
        volume=1000000
    )
    
    assert_equal(bar.order_book_id(), "000001.XSHE")
    assert_equal(bar.open(), 10.0)
    assert_equal(bar.high(), 10.5)
    assert_equal(bar.low(), 9.8)
    assert_equal(bar.close(), 10.2)
    assert_equal(bar.volume(), 1000000)
    
    print("Test test_bar_object: PASSED")


def test_data_proxy() raises:
    print("=== Testing Data Proxy ===")
    
    var proxy = create_data_proxy()
    var price = proxy.get_last_price("000001.XSHE")
    
    print("Test test_data_proxy: PASSED")


def test_order_status() raises:
    print("=== Testing Order Status ===")
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE_BUY,
        100,
        style,
        POSITION_EFFECT_OPEN
    )
    
    assert_equal(order.status, ORDER_STATUS_PENDING_NEW)
    
    print("Test test_order_status: PASSED")


def test_position_direction() raises:
    print("=== Testing Position Direction ===")
    
    assert_equal(POSITION_DIRECTION_LONG.name(), "LONG")
    assert_equal(POSITION_DIRECTION_SHORT.name(), "SHORT")
    
    print("Test test_position_direction: PASSED")


def test_side_enum() raises:
    print("=== Testing Side Enum ===")
    
    assert_equal(SIDE_BUY.name(), "BUY")
    assert_equal(SIDE_SELL.name(), "SELL")
    
    print("Test test_side_enum: PASSED")


def test_position_effect_enum() raises:
    print("=== Testing Position Effect Enum ===")
    
    assert_equal(POSITION_EFFECT_OPEN.name(), "OPEN")
    assert_equal(POSITION_EFFECT_CLOSE.name(), "CLOSE")
    
    print("Test test_position_effect_enum: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_api_base.mojo")
    print("=" * 60)
    print("")
    
    test_order_creation()
    test_limit_order()
    test_market_order()
    test_position_basic()
    test_position_queue_operations()
    test_account_basic()
    test_portfolio_basic()
    test_environment_creation()
    test_datetime_operations()
    test_date_operations()
    test_instrument_creation()
    test_bar_object()
    test_data_proxy()
    test_order_status()
    test_position_direction()
    test_side_enum()
    test_position_effect_enum()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
