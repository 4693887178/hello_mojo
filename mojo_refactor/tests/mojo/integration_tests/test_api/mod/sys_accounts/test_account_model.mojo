"""
Account Model Tests - Mojo Version
Tests for account model functionality using rqmojo
Ported from tests/integration_tests/test_api/mod/sys_accounts/test_account_model.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_STATUS_FILLED, POSITION_DIRECTION_LONG, POSITION_DIRECTION_SHORT,
    INSTRUMENT_TYPE_CS, INSTRUMENT_TYPE_FUTURE,
    EXCHANGE_XSHG, EXCHANGE_XSHE
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.trade import Trade, create_trade_from_order
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position, create_future_position
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.datetime_func import DateTime, Date


def assert_float_equal(actual: Float64, expected: Float64, tolerance: Float64 = 0.01) -> Bool:
    var diff = actual - expected
    if diff < 0:
        diff = -diff
    return diff <= tolerance


def test_stock_account_creation() raises:
    print("=== Testing Stock Account Creation ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_stock_account(initial_cash)
    
    assert_equal(account.total_cash, initial_cash)
    assert_equal(account.total_value, initial_cash)
    
    print("Test test_stock_account_creation: PASSED")


def test_future_account_creation() raises:
    print("=== Testing Future Account Creation ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_future_account(initial_cash)
    
    assert_equal(account.total_cash, initial_cash)
    assert_equal(account.total_value, initial_cash)
    
    print("Test test_future_account_creation: PASSED")


def test_stock_delist() raises:
    print("=== Testing Stock Delist ===")
    
    var symbol = "000979.XSHE"
    var quantity: Int = 20000
    var avg_price: Float64 = 10.0
    
    var pos = create_stock_position(symbol, quantity, avg_price)
    
    assert_equal(pos.quantity, quantity)
    
    pos.update_last_price(0.0)
    
    var market_value = pos.market_value
    assert_equal(market_value, 0.0)
    
    print("Test test_stock_delist: PASSED")


def test_stock_dividend() raises:
    print("=== Testing Stock Dividend ===")
    
    var symbol = "601088.XSHG"
    var quantity: Int = 1000
    var avg_price: Float64 = 20.0
    var dividend_per_share: Float64 = 0.9
    
    var pos = create_stock_position(symbol, quantity, avg_price)
    
    assert_equal(pos.quantity, quantity)
    
    var expected_dividend = Float64(quantity) * dividend_per_share
    
    assert_true(assert_float_equal(expected_dividend, 900.0, 0.01))
    
    print("Test test_stock_dividend: PASSED")


def test_stock_transform() raises:
    print("=== Testing Stock Transform ===")
    
    var s1 = "601299.XSHG"
    var s2 = "601766.XSHG"
    var quantity: Int = 200
    var transform_ratio: Float64 = 1.1
    
    var pos1 = create_stock_position(s1, quantity, 10.0)
    
    assert_equal(pos1.quantity, quantity)
    
    var new_quantity = Int(Float64(quantity) * transform_ratio)
    
    assert_equal(new_quantity, 220)
    
    print("Test test_stock_transform: PASSED")


def test_stock_split() raises:
    print("=== Testing Stock Split ===")
    
    var symbol = "000035.XSHE"
    var quantity: Int = 1000
    var avg_price: Float64 = 10.0
    var split_ratio: Int = 2
    
    var pos = create_stock_position(symbol, quantity, avg_price)
    
    assert_equal(pos.quantity, quantity)
    
    var new_quantity = quantity * split_ratio
    var new_avg_price = avg_price / Float64(split_ratio)
    
    assert_equal(new_quantity, 2000)
    assert_true(assert_float_equal(new_avg_price, 5.0, 0.01))
    
    print("Test test_stock_split: PASSED")


def test_account_position_management() raises:
    print("=== Testing Account Position Management ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_stock_account(initial_cash)
    
    var symbol = "000001.XSHE"
    var pos = create_stock_position(symbol, 0, 0.0)
    
    var trade = create_trade_from_order(
        1, 1, symbol, SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 10.0
    )
    
    pos.apply_trade(trade)
    
    assert_equal(pos.quantity, 100)
    assert_equal(pos.avg_price, 10.0)
    
    print("Test test_account_position_management: PASSED")


def test_account_cash_update() raises:
    print("=== Testing Account Cash Update ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_stock_account(initial_cash)
    
    var trade_amount: Float64 = 10000.0
    
    assert_equal(account.total_cash, initial_cash)
    
    print("Test test_account_cash_update: PASSED")


def test_account_total_value_calculation() raises:
    print("=== Testing Account Total Value Calculation ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_stock_account(initial_cash)
    
    assert_equal(account.total_value, initial_cash)
    
    print("Test test_account_total_value_calculation: PASSED")


def test_future_account_margin() raises:
    print("=== Testing Future Account Margin ===")
    
    var initial_cash: Float64 = 1000000.0
    var account = create_future_account(initial_cash)
    
    assert_equal(account.total_cash, initial_cash)
    
    print("Test test_future_account_margin: PASSED")


def test_account_multiple_positions() raises:
    print("=== Testing Account Multiple Positions ===")
    
    var symbol1 = "000001.XSHE"
    var symbol2 = "000002.XSHE"
    
    var pos1 = create_stock_position(symbol1, 100, 10.0)
    var pos2 = create_stock_position(symbol2, 200, 8.0)
    
    pos1.update_last_price(12.0)
    pos2.update_last_price(9.0)
    
    assert_equal(pos1.quantity, 100)
    assert_equal(pos2.quantity, 200)
    
    var total_market_value = pos1.market_value + pos2.market_value
    
    assert_true(assert_float_equal(total_market_value, 1200.0 + 1800.0, 0.01))
    
    print("Test test_account_multiple_positions: PASSED")


def test_account_pnl_calculation() raises:
    print("=== Testing Account PnL Calculation ===")
    
    var symbol = "000001.XSHE"
    var quantity: Int = 100
    var avg_price: Float64 = 10.0
    var current_price: Float64 = 12.0
    
    var pos = create_stock_position(symbol, quantity, avg_price)
    pos.update_last_price(current_price)
    
    var expected_pnl = Float64(quantity) * (current_price - avg_price)
    var actual_pnl = pos.pnl()
    
    assert_true(assert_float_equal(actual_pnl, expected_pnl, 0.01))
    
    print("Test test_account_pnl_calculation: PASSED")


def test_account_daily_pnl() raises:
    print("=== Testing Account Daily PnL ===")
    
    var symbol = "000001.XSHE"
    var quantity: Int = 100
    var prev_close: Float64 = 11.0
    var current_price: Float64 = 12.0
    
    var pos = create_stock_position(symbol, quantity, prev_close)
    pos.update_prev_close(prev_close)
    pos.update_last_price(current_price)
    
    var expected_daily_pnl = Float64(quantity) * (current_price - prev_close)
    var actual_daily_pnl = pos.daily_pnl()
    
    assert_true(assert_float_equal(actual_daily_pnl, expected_daily_pnl, 0.01))
    
    print("Test test_account_daily_pnl: PASSED")


def test_account_position_pnl() raises:
    print("=== Testing Account Position PnL ===")
    
    var symbol = "000001.XSHE"
    var quantity: Int = 100
    var prev_close: Float64 = 11.0
    var current_price: Float64 = 12.0
    
    var pos = create_stock_position(symbol, quantity, prev_close)
    pos.update_prev_close(prev_close)
    pos.update_last_price(current_price)
    
    var expected_position_pnl = Float64(quantity) * (current_price - prev_close)
    var actual_position_pnl = pos.position_pnl()
    
    assert_true(assert_float_equal(actual_position_pnl, expected_position_pnl, 0.01))
    
    print("Test test_account_position_pnl: PASSED")


def test_account_trading_pnl() raises:
    print("=== Testing Account Trading PnL ===")
    
    var symbol = "000001.XSHE"
    var pos = create_stock_position(symbol, 0, 0.0)
    
    var trade = create_trade_from_order(
        1, 1, symbol, SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 10.0
    )
    
    pos.apply_trade(trade)
    pos.update_last_price(12.0)
    
    var trading_pnl = pos.trading_pnl()
    
    assert_true(trading_pnl != 0.0)
    
    print("Test test_account_trading_pnl: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_account_model.mojo")
    print("=" * 60)
    print("")
    
    test_stock_account_creation()
    test_future_account_creation()
    test_stock_delist()
    test_stock_dividend()
    test_stock_transform()
    test_stock_split()
    test_account_position_management()
    test_account_cash_update()
    test_account_total_value_calculation()
    test_future_account_margin()
    test_account_multiple_positions()
    test_account_pnl_calculation()
    test_account_daily_pnl()
    test_account_position_pnl()
    test_account_trading_pnl()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
