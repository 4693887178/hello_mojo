"""
Futures Settlement Price Type Tests - Mojo Version
Tests for futures settlement price type functionality using rqmojo
Ported from tests/integration_tests/test_api/mod/sys_accounts/test_futures_settlement_price_type.py
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
from rqmojo.model.instrument import Instrument, create_future_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_future_position
from rqmojo.portfolio.account import Account, create_future_account
from rqmojo.utils.datetime_func import DateTime, Date


def assert_float_equal(actual: Float64, expected: Float64, tolerance: Float64 = 0.01) -> Bool:
    var diff = actual - expected
    if diff < 0:
        diff = -diff
    return diff <= tolerance


def test_futures_settlement_price_type() raises:
    print("=== Testing Futures Settlement Price Type ===")
    
    var contract_multiplier: Float64 = 200.0
    var prev_settlement: Float64 = 6657.0
    var close_price: Float64 = 6364.6
    var next_close: Float64 = 6468.0
    var prev_close_for_next: Float64 = 6351.2
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        1,
        prev_settlement,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(prev_settlement)
    pos.update_last_price(close_price)
    
    var expected_pnl_day1 = (close_price - prev_settlement) * contract_multiplier
    var actual_pnl_day1 = pos.position_pnl()
    
    assert_true(assert_float_equal(actual_pnl_day1, expected_pnl_day1, 0.01))
    
    pos.settlement()
    pos.update_last_price(next_close)
    
    var expected_pnl_day2 = (next_close - close_price) * contract_multiplier
    var actual_pnl_day2 = pos.position_pnl()
    
    assert_true(assert_float_equal(actual_pnl_day2, expected_pnl_day2, 0.01))
    
    print("Test test_futures_settlement_price_type: PASSED")


def test_futures_de_listed() raises:
    print("=== Testing Futures De-listed ===")
    
    var contract_multiplier: Float64 = 200.0
    var entry_price: Float64 = 5760.0
    var settlement_price: Float64 = 5944.29
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        1,
        entry_price,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(entry_price)
    pos.update_last_price(settlement_price)
    
    var expected_pnl = (settlement_price - entry_price) * contract_multiplier
    var actual_pnl = pos.position_pnl()
    
    assert_true(assert_float_equal(actual_pnl, expected_pnl, 0.01))
    
    print("Test test_futures_de_listed: PASSED")


def test_futures_position_pnl_calculation() raises:
    print("=== Testing Futures Position PnL Calculation ===")
    
    var contract_multiplier: Float64 = 200.0
    var initial_price: Float64 = 5000.0
    var current_price: Float64 = 5100.0
    var quantity: Int = 3
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        quantity,
        initial_price,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(initial_price)
    pos.update_last_price(current_price)
    
    var expected_pnl = (current_price - initial_price) * Float64(quantity) * contract_multiplier
    var actual_pnl = pos.pnl()
    
    assert_true(assert_float_equal(actual_pnl, expected_pnl, 0.01))
    
    print("Test test_futures_position_pnl_calculation: PASSED")


def test_futures_short_position_pnl() raises:
    print("=== Testing Futures Short Position PnL ===")
    
    var contract_multiplier: Float64 = 200.0
    var entry_price: Float64 = 5300.0
    var current_price: Float64 = 5200.0
    var quantity: Int = 2
    
    var pos = create_future_position(
        "IC2001",
        POSITION_DIRECTION_SHORT,
        quantity,
        entry_price,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(entry_price)
    pos.update_last_price(current_price)
    
    var expected_pnl = (entry_price - current_price) * Float64(quantity) * contract_multiplier
    var actual_pnl = pos.pnl()
    
    assert_true(assert_float_equal(actual_pnl, expected_pnl, 0.01))
    
    print("Test test_futures_short_position_pnl: PASSED")


def test_futures_daily_pnl_vs_position_pnl() raises:
    print("=== Testing Futures Daily PnL vs Position PnL ===")
    
    var contract_multiplier: Float64 = 200.0
    var prev_close: Float64 = 5000.0
    var current_price: Float64 = 5100.0
    var quantity: Int = 2
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        quantity,
        prev_close,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(prev_close)
    pos.update_last_price(current_price)
    
    var trade = create_trade_from_order(
        1, 1, "IC1603", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1, 5050.0
    )
    
    pos.apply_trade(trade)
    
    var daily_pnl = pos.daily_pnl()
    var position_pnl = pos.position_pnl()
    var trading_pnl = pos.trading_pnl()
    
    assert_true(daily_pnl > position_pnl)
    assert_true(assert_float_equal(daily_pnl, position_pnl + trading_pnl, 0.01))
    
    print("Test test_futures_daily_pnl_vs_position_pnl: PASSED")


def test_futures_settlement_sequence() raises:
    print("=== Testing Futures Settlement Sequence ===")
    
    var contract_multiplier: Float64 = 200.0
    var day1_settlement: Float64 = 5000.0
    var day2_settlement: Float64 = 5100.0
    var day3_settlement: Float64 = 5050.0
    
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        1,
        day1_settlement,
        contract_multiplier,
        0.1
    )
    
    pos.update_prev_close(day1_settlement)
    pos.update_last_price(day2_settlement)
    
    var day1_pnl = pos.position_pnl()
    var expected_day1_pnl = (day2_settlement - day1_settlement) * contract_multiplier
    assert_true(assert_float_equal(day1_pnl, expected_day1_pnl, 0.01))
    
    pos.settlement()
    pos.update_last_price(day3_settlement)
    
    var day2_pnl = pos.position_pnl()
    var expected_day2_pnl = (day3_settlement - day2_settlement) * contract_multiplier
    assert_true(assert_float_equal(day2_pnl, expected_day2_pnl, 0.01))
    
    print("Test test_futures_settlement_sequence: PASSED")


def test_futures_margin_calculation() raises:
    print("=== Testing Futures Margin Calculation ===")
    
    var contract_multiplier: Float64 = 200.0
    var margin_rate: Float64 = 0.15
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
    
    print("Test test_futures_margin_calculation: PASSED")


def test_futures_close_today() raises:
    print("=== Testing Futures Close Today ===")
    
    var contract_multiplier: Float64 = 200.0
    var pos = create_future_position(
        "IC1603",
        POSITION_DIRECTION_LONG,
        0,
        0.0,
        contract_multiplier,
        0.1
    )
    
    var open_trade = create_trade_from_order(
        1, 1, "IC1603", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 2, 5000.0
    )
    
    pos.apply_trade(open_trade)
    
    assert_equal(pos.quantity, 2)
    assert_equal(pos.today_quantity, 2)
    
    var close_trade = create_trade_from_order(
        2, 2, "IC1603", SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, 1, 5100.0
    )
    
    pos.apply_trade(close_trade)
    
    assert_equal(pos.quantity, 1)
    
    print("Test test_futures_close_today: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_futures_settlement_price_type.mojo")
    print("=" * 60)
    print("")
    
    test_futures_settlement_price_type()
    test_futures_de_listed()
    test_futures_position_pnl_calculation()
    test_futures_short_position_pnl()
    test_futures_daily_pnl_vs_position_pnl()
    test_futures_settlement_sequence()
    test_futures_margin_calculation()
    test_futures_close_today()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
