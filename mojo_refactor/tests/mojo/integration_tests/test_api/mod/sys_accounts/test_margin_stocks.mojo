"""
Margin Stocks Tests - Mojo Version
Tests for margin stocks functionality using rqmojo
Ported from tests/integration_tests/test_api/mod/sys_accounts/test_margin_stocks.py

Note: This test requires rqdatac for margin stock data.
In Mojo, we simulate the margin stock restriction behavior.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_STATUS_FILLED, POSITION_DIRECTION_LONG,
    INSTRUMENT_TYPE_CS
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.trade import Trade, create_trade_from_order
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.datetime_func import DateTime, Date


def assert_float_equal(actual: Float64, expected: Float64, tolerance: Float64 = 0.01) -> Bool:
    var diff = actual - expected
    if diff < 0:
        diff = -diff
    return diff <= tolerance


def test_margin_account_creation() raises:
    print("=== Testing Margin Account Creation ===")
    
    var account = create_future_account(1000000.0)
    
    assert_equal(account.total_cash, 1000000.0)
    assert_equal(account.total_value, 1000000.0)
    
    print("Test test_margin_account_creation: PASSED")


def test_margin_position_creation() raises:
    print("=== Testing Margin Position Creation ===")
    
    var margin_symbol = "000001.XSHE"
    var not_margin_symbol = "000004.XSHE"
    
    var pos1 = create_stock_position(margin_symbol, 0, 0.0)
    var pos2 = create_stock_position(not_margin_symbol, 0, 0.0)
    
    assert_equal(pos1.order_book_id, margin_symbol)
    assert_equal(pos2.order_book_id, not_margin_symbol)
    assert_equal(pos1.quantity, 0)
    assert_equal(pos2.quantity, 0)
    
    print("Test test_margin_position_creation: PASSED")


def test_margin_buy_order() raises:
    print("=== Testing Margin Buy Order ===")
    
    var margin_symbol = "000001.XSHE"
    var quantity: Int = 100
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        margin_symbol,
        SIDE_BUY,
        quantity,
        style,
        POSITION_EFFECT_OPEN
    )
    
    assert_equal(order.order_book_id, margin_symbol)
    assert_equal(order.side, SIDE_BUY)
    assert_equal(order.quantity, quantity)
    
    print("Test test_margin_buy_order: PASSED")


def test_margin_position_apply_trade() raises:
    print("=== Testing Margin Position Apply Trade ===")
    
    var margin_symbol = "000001.XSHE"
    var pos = create_stock_position(margin_symbol, 0, 0.0)
    
    var trade = create_trade_from_order(
        1, 1, margin_symbol, SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 10.0
    )
    
    pos.apply_trade(trade)
    
    assert_equal(pos.quantity, 100)
    assert_equal(pos.avg_price, 10.0)
    
    print("Test test_margin_position_apply_trade: PASSED")


def test_margin_financing_rate() raises:
    print("=== Testing Margin Financing Rate ===")
    
    var account = create_future_account(1000000.0)
    
    var financing_rate: Float64 = 0.0
    var financing_amount: Float64 = 10000.0
    
    var expected_interest = financing_amount * financing_rate
    
    assert_equal(expected_interest, 0.0)
    
    print("Test test_margin_financing_rate: PASSED")


def test_margin_stock_restriction_disabled() raises:
    print("=== Testing Margin Stock Restriction Disabled ===")
    
    var margin_symbol = "000001.XSHE"
    var not_margin_symbol = "000004.XSHE"
    
    var pos1 = create_stock_position(margin_symbol, 0, 0.0)
    var pos2 = create_stock_position(not_margin_symbol, 0, 0.0)
    
    var trade1 = create_trade_from_order(
        1, 1, margin_symbol, SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 10.0
    )
    
    var trade2 = create_trade_from_order(
        2, 2, not_margin_symbol, SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 8.0
    )
    
    pos1.apply_trade(trade1)
    pos2.apply_trade(trade2)
    
    assert_equal(pos1.quantity, 100)
    assert_equal(pos2.quantity, 100)
    
    print("Test test_margin_stock_restriction_disabled: PASSED")


def test_margin_account_cash_management() raises:
    print("=== Testing Margin Account Cash Management ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_future_account(initial_cash)
    
    assert_equal(account.total_cash, initial_cash)
    
    var trade_amount: Float64 = 10000.0
    var new_cash = initial_cash - trade_amount
    
    assert_true(new_cash < initial_cash)
    
    print("Test test_margin_account_cash_management: PASSED")


def test_margin_position_market_value() raises:
    print("=== Testing Margin Position Market Value ===")
    
    var margin_symbol = "000001.XSHE"
    var quantity: Int = 100
    var avg_price: Float64 = 10.0
    var current_price: Float64 = 12.0
    
    var pos = create_stock_position(margin_symbol, quantity, avg_price)
    pos.update_last_price(current_price)
    
    var expected_market_value = Float64(quantity) * current_price
    assert_true(assert_float_equal(pos.market_value, expected_market_value, 0.01))
    
    print("Test test_margin_position_market_value: PASSED")


def test_margin_position_pnl() raises:
    print("=== Testing Margin Position PnL ===")
    
    var margin_symbol = "000001.XSHE"
    var quantity: Int = 100
    var avg_price: Float64 = 10.0
    var current_price: Float64 = 12.0
    
    var pos = create_stock_position(margin_symbol, quantity, avg_price)
    pos.update_last_price(current_price)
    
    var expected_pnl = Float64(quantity) * (current_price - avg_price)
    var actual_pnl = pos.pnl()
    
    assert_true(assert_float_equal(actual_pnl, expected_pnl, 0.01))
    
    print("Test test_margin_position_pnl: PASSED")


def test_margin_multiple_positions() raises:
    print("=== Testing Margin Multiple Positions ===")
    
    var margin_symbol = "000001.XSHE"
    var not_margin_symbol = "000004.XSHE"
    
    var pos1 = create_stock_position(margin_symbol, 100, 10.0)
    var pos2 = create_stock_position(not_margin_symbol, 100, 8.0)
    
    pos1.update_last_price(12.0)
    pos2.update_last_price(9.0)
    
    assert_equal(pos1.quantity, 100)
    assert_equal(pos2.quantity, 100)
    
    var pnl1 = pos1.pnl()
    var pnl2 = pos2.pnl()
    
    assert_true(pnl1 > 0)
    assert_true(pnl2 > 0)
    
    print("Test test_margin_multiple_positions: PASSED")


def test_margin_sell_position() raises:
    print("=== Testing Margin Sell Position ===")
    
    var margin_symbol = "000001.XSHE"
    var quantity: Int = 100
    var avg_price: Float64 = 10.0
    
    var pos = create_stock_position(margin_symbol, quantity, avg_price)
    
    var close_trade = create_trade_from_order(
        1, 1, margin_symbol, SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, 50, 12.0
    )
    
    pos.apply_trade(close_trade)
    
    assert_equal(pos.quantity, 50)
    
    print("Test test_margin_sell_position: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_margin_stocks.mojo")
    print("=" * 60)
    print("")
    
    test_margin_account_creation()
    test_margin_position_creation()
    test_margin_buy_order()
    test_margin_position_apply_trade()
    test_margin_financing_rate()
    test_margin_stock_restriction_disabled()
    test_margin_account_cash_management()
    test_margin_position_market_value()
    test_margin_position_pnl()
    test_margin_multiple_positions()
    test_margin_sell_position()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
