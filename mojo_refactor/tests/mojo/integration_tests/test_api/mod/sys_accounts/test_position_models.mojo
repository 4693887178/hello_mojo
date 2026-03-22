"""
Position Models Tests - Mojo Version
Tests for position model functionality using rqmojo
Ported from tests/integration_tests/test_api/mod/sys_accounts/test_position_models.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_STATUS_FILLED, POSITION_DIRECTION_LONG, POSITION_DIRECTION_SHORT,
    INSTRUMENT_TYPE_FUTURE
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


def test_stock_sellable() raises:
    print("=== Testing Stock Sellable ===")
    
    var pos = create_stock_position("000001.XSHE", 0, 0.0)
    assert_equal(pos.quantity, 0)
    assert_equal(pos.closable(), 0)
    
    var trade = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1000, 10.0
    )
    
    pos.apply_trade(trade)
    
    assert_equal(pos.quantity, 1000)
    assert_equal(pos.closable(), 1000)
    
    print("Test test_stock_sellable: PASSED")


def test_stock_sellable_t1() raises:
    print("=== Testing Stock Sellable T+1 ===")
    
    var pos = create_stock_position("000001.XSHE", 0, 0.0)
    
    var trade = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1000, 10.0
    )
    
    pos.apply_trade(trade)
    
    assert_equal(pos.quantity, 1000)
    assert_equal(pos.today_quantity, 1000)
    
    pos.before_trading()
    
    assert_equal(pos.quantity, 1000)
    assert_equal(pos.old_quantity, 1000)
    assert_equal(pos.today_quantity, 0)
    
    print("Test test_stock_sellable_t1: PASSED")


def test_trading_pnl() raises:
    print("=== Testing Trading PnL ===")
    
    var contract_multiplier: Float64 = 200.0
    var pos = create_future_position(
        "IC2001",
        POSITION_DIRECTION_LONG,
        0,
        0.0,
        contract_multiplier,
        0.1
    )
    
    var open_price: Float64 = 5300.0
    var close_price: Float64 = 5361.8
    var quantity: Int = 2
    
    var open_trade = create_trade_from_order(
        1, 1, "IC2001", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, quantity, open_price
    )
    
    pos.apply_trade(open_trade)
    
    assert_equal(pos.quantity, quantity)
    assert_equal(pos.avg_price, open_price)
    
    var close_trade = create_trade_from_order(
        2, 2, "IC2001", SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, quantity, close_price
    )
    
    pos.apply_trade(close_trade)
    
    assert_equal(pos.quantity, 0)
    
    var expected_trading_pnl = (close_price - open_price) * Float64(quantity) * contract_multiplier
    var actual_trading_pnl = pos.trading_pnl()
    
    assert_true(assert_float_equal(actual_trading_pnl, expected_trading_pnl, 0.01))
    
    print("Test test_trading_pnl: PASSED")


def test_position_pnl() raises:
    print("=== Testing Position PnL ===")
    
    var contract_multiplier: Float64 = 200.0
    var prev_close: Float64 = 6657.0
    var last_price: Float64 = 6364.6
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        1,
        prev_close,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(prev_close)
    pos.update_last_price(last_price)
    
    var expected_position_pnl = (last_price - prev_close) * contract_multiplier
    var actual_position_pnl = pos.position_pnl()
    
    assert_true(assert_float_equal(actual_position_pnl, expected_position_pnl, 0.01))
    
    print("Test test_position_pnl: PASSED")


def test_daily_pnl() raises:
    print("=== Testing Daily PnL ===")
    
    var contract_multiplier: Float64 = 200.0
    var prev_close: Float64 = 6351.2
    var last_price: Float64 = 6468.0
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        1,
        prev_close,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(prev_close)
    pos.update_last_price(last_price)
    
    var expected_daily_pnl = (last_price - prev_close) * contract_multiplier
    var actual_daily_pnl = pos.daily_pnl()
    
    assert_true(assert_float_equal(actual_daily_pnl, expected_daily_pnl, 0.01))
    
    print("Test test_daily_pnl: PASSED")


def test_margin() raises:
    print("=== Testing Margin ===")
    
    var contract_multiplier: Float64 = 200.0
    var margin_rate: Float64 = 0.1
    var price: Float64 = 5000.0
    var quantity: Int = 2
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        quantity,
        price,
        contract_multiplier,
        margin_rate
    )
    
    pos.update_last_price(price)
    
    var market_value = price * Float64(quantity) * contract_multiplier
    var expected_margin = market_value * margin_rate
    var actual_margin = pos.margin()
    
    assert_true(assert_float_equal(actual_margin, expected_margin, 0.01))
    
    print("Test test_margin: PASSED")


def test_short_position_pnl() raises:
    print("=== Testing Short Position PnL ===")
    
    var contract_multiplier: Float64 = 200.0
    var open_price: Float64 = 5300.0
    var last_price: Float64 = 5200.0
    var quantity: Int = 2
    
    var pos = create_future_position(
        "IC2001",
        POSITION_DIRECTION_SHORT,
        quantity,
        open_price,
        contract_multiplier,
        0.1
    )
    
    pos.update_last_price(last_price)
    
    var expected_pnl = (open_price - last_price) * Float64(quantity) * contract_multiplier
    var actual_pnl = pos.pnl()
    
    assert_true(assert_float_equal(actual_pnl, expected_pnl, 0.01))
    
    print("Test test_short_position_pnl: PASSED")


def test_position_apply_trade_open() raises:
    print("=== Testing Position Apply Trade Open ===")
    
    var pos = create_stock_position("000001.XSHE", 0, 0.0)
    
    var trade1 = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 10.0
    )
    
    pos.apply_trade(trade1)
    
    assert_equal(pos.quantity, 100)
    assert_equal(pos.avg_price, 10.0)
    
    var trade2 = create_trade_from_order(
        2, 2, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 100, 12.0
    )
    
    pos.apply_trade(trade2)
    
    assert_equal(pos.quantity, 200)
    assert_equal(pos.avg_price, 11.0)
    
    print("Test test_position_apply_trade_open: PASSED")


def test_position_apply_trade_close() raises:
    print("=== Testing Position Apply Trade Close ===")
    
    var pos = create_stock_position("000001.XSHE", 200, 10.0)
    
    var trade = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, 100, 12.0
    )
    
    pos.apply_trade(trade)
    
    assert_equal(pos.quantity, 100)
    assert_equal(pos.avg_price, 10.0)
    
    print("Test test_position_apply_trade_close: PASSED")


def test_position_update_last_price() raises:
    print("=== Testing Position Update Last Price ===")
    
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    
    pos.update_last_price(12.0)
    
    assert_equal(pos.last_price, 12.0)
    assert_equal(pos.market_value, 1200.0)
    
    print("Test test_position_update_last_price: PASSED")


def test_position_settlement() raises:
    print("=== Testing Position Settlement ===")
    
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    
    pos.update_last_price(12.0)
    pos.settlement()
    
    assert_equal(pos.prev_close, 12.0)
    assert_equal(pos.old_quantity, 100)
    
    print("Test test_position_settlement: PASSED")


def test_position_before_trading() raises:
    print("=== Testing Position Before Trading ===")
    
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    
    var trade = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 50, 11.0
    )
    
    pos.apply_trade(trade)
    
    assert_equal(pos.quantity, 150)
    assert_equal(pos.today_quantity, 50)
    
    pos.before_trading()
    
    assert_equal(pos.old_quantity, 150)
    assert_equal(pos.today_quantity, 0)
    assert_equal(pos.trade_quantity, 0)
    
    print("Test test_position_before_trading: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_position_models.mojo")
    print("=" * 60)
    print("")
    
    test_stock_sellable()
    test_stock_sellable_t1()
    test_trading_pnl()
    test_position_pnl()
    test_daily_pnl()
    test_margin()
    test_short_position_pnl()
    test_position_apply_trade_open()
    test_position_apply_trade_close()
    test_position_update_last_price()
    test_position_settlement()
    test_position_before_trading()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
