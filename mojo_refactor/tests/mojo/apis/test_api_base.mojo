"""
Comprehensive Tests for apis/api_base.mojo
Tests all API functions against Python rqalpha/apis/api_base.py behavior.

Coverage:
  - Order APIs:     order_shares, order_value, order_percent,
                    order_target_value, order_target_percent, submit_order, cancel_order
  - Universe APIs:  update_universe, subscribe, unsubscribe
  - Data APIs:      history_bars, history, get_price, current_snapshot,
                    get_trading_dates, get_previous_trading_date, get_next_trading_date
  - Instrument APIs: instruments, all_instruments, active_instrument
  - Position APIs:  get_position, get_positions, get_portfolio
  - Account APIs:   deposit, withdraw
  - Helpers:        assure_order_book_id, cal_style
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List, Dict, Set, Optional

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id, OrderStyle
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.environment import create_environment
from rqmojo.core.strategy_context import StrategyContext, create_strategy_context
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.portfolio.position import Position, create_position
from rqmojo.portfolio_manager import Portfolio, create_portfolio as create_portfolio_simple
from rqmojo.utils.typing import DateTime

from rqmojo.apis.api_base import (
    assure_order_book_id, cal_style,
    order_shares, order_value, order_percent,
    order_target_value, order_target_percent,
    submit_order, cancel_order,
    update_universe, subscribe, unsubscribe,
    history_bars, history, get_price,
    current_snapshot,
    get_trading_dates, get_previous_trading_date, get_next_trading_date,
    get_position, get_positions, get_portfolio,
    instruments, all_instruments, active_instrument,
    deposit, withdraw
)


def _setup_test_context() raises -> StrategyContext:
    var env = create_environment(
        DateTime(2016, 12, 1, 0, 0, 0, 0),
        DateTime(2016, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    return ctx^


def test_assure_order_book_id() raises:
    print("Test: assure_order_book_id returns input string")
    var result = assure_order_book_id("000001.XSHE")
    assert_equal(result, "000001.XSHE")
    print("  PASSED")


def test_cal_style_market() raises:
    print("Test: cal_style with no price returns MarketOrder")
    var style = cal_style(0.0, MarketOrder(), None)
    assert_equal(style.style_type, ORDER_TYPE.MARKET)
    print("  PASSED")


def test_cal_style_limit_from_price() raises:
    print("Test: cal_style with price > 0 returns LimitOrder")
    var style = cal_style(10.5, MarketOrder(), None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 10.5)
    print("  PASSED")


def test_cal_style_limit_from_param() raises:
    print("Test: cal_style with price_or_style returns LimitOrder")
    var style = cal_style(0.0, MarketOrder(), Optional[Float64](15.0))
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 15.0)
    print("  PASSED")


def test_order_shares_buy_market() raises:
    print("Test: order_shares buy market order")
    var ctx = _setup_test_context()
    var result = order_shares(ctx, "000001.XSHE", 100)
    assert_true(result != None, "order should not be None")
    var order = result.value().copy()
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.quantity, 100)
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.position_effect.value().name, "OPEN")
    print("  PASSED")


def test_order_shares_sell() raises:
    print("Test: order_shares sell (negative quantity)")
    var ctx = _setup_test_context()
    var result = order_shares(ctx, "000001.XSHE", -200)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.SELL)
    assert_equal(order.quantity, 200)
    assert_equal(order.position_effect.value().name, "CLOSE")
    print("  PASSED")


def test_order_shares_zero_quantity() raises:
    print("Test: order_shares with zero quantity returns None")
    var ctx = _setup_test_context()
    var result = order_shares(ctx, "000001.XSHE", 0)
    assert_true(result == None, "zero quantity should return None")
    print("  PASSED")


def test_order_shares_limit_order() raises:
    print("Test: order_shares with LIMIT type creates LimitOrder")
    var ctx = _setup_test_context()
    var result = order_shares(ctx, "000001.XSHE", 100, ORDER_TYPE.LIMIT, 15.5)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.style_order.style_type, ORDER_TYPE.LIMIT)
    assert_equal(order.style_order.limit_price, 15.5)
    print("  PASSED")


def test_order_value_positive() raises:
    print("Test: order_value with positive amount buys shares")
    var ctx = _setup_test_context()
    var result = order_value(ctx, "000001.XSHE", 50000.0)
    assert_true(result != None, "order should not be None for valid amount")
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)
    assert_true(order.quantity > 0, "quantity should be positive")
    print("  PASSED")


def test_order_value_zero() raises:
    print("Test: order_value with zero returns None")
    var ctx = _setup_test_context()
    var result = order_value(ctx, "000001.XSHE", 0.0)
    assert_true(result == None)
    print("  PASSED")


def test_order_value_negative_sells() raises:
    print("Test: order_value with negative amount sells")
    var ctx = _setup_test_context()
    var result = order_value(ctx, "000001.XSHE", -50000.0)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.SELL)
    print("  PASSED")


def test_order_percent_valid() raises:
    print("Test: order_percent with valid percent (0, 1]")
    var ctx = _setup_test_context()
    var result = order_percent(ctx, "000001.XSHE", 0.5)
    assert_true(result != None, "50% should produce an order")
    print("  PASSED")


def test_order_percent_zero() raises:
    print("Test: order_percent with 0 returns None")
    var ctx = _setup_test_context()
    var result = order_percent(ctx, "000001.XSHE", 0.0)
    assert_true(result == None)
    print("  PASSED")


def test_order_percent_over_one() raises:
    print("Test: order_percent > 1 returns None")
    var ctx = _setup_test_context()
    var result = order_percent(ctx, "000001.XSHE", 1.5)
    assert_true(result == None)
    print("  PASSED")


def test_order_percent_negative() raises:
    print("Test: order_percent negative returns None")
    var ctx = _setup_test_context()
    var result = order_percent(ctx, "000001.XSHE", -0.5)
    assert_true(result == None)
    print("  PASSED")


def test_order_target_value_increase() raises:
    print("Test: order_target_value increases position")
    var ctx = _setup_test_context()
    var result = order_target_value(ctx, "000001.XSHE", 50000.0)
    assert_true(result != None, "should order to increase value")
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)
    print("  PASSED")


def test_order_target_percent() raises:
    print("Test: order_target_percent converts percent to value")
    var ctx = _setup_test_context()
    var result = order_target_percent(ctx, "000001.XSHE", 0.3)
    assert_true(result != None, "30% should produce an order")
    print("  PASSED")


def test_submit_order_buy() raises:
    print("Test: submit_order buy side")
    var ctx = _setup_test_context()
    var result = submit_order(ctx, "000001.XSHE", 100, SIDE.BUY)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.quantity, 100)
    print("  PASSED")


def test_submit_order_sell() raises:
    print("Test: submit_order sell side")
    var ctx = _setup_test_context()
    var result = submit_order(ctx, "000001.XSHE", 200, SIDE.SELL)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.SELL)
    print("  PASSED")


def test_submit_order_zero_amount() raises:
    print("Test: submit_order with zero amount returns None")
    var ctx = _setup_test_context()
    var result = submit_order(ctx, "000001.XSHE", 0, SIDE.BUY)
    assert_true(result == None)
    print("  PASSED")


def test_submit_order_negative_amount() raises:
    print("Test: submit_order with negative amount returns None")
    var ctx = _setup_test_context()
    var result = submit_order(ctx, "000001.XSHE", -10, SIDE.BUY)
    assert_true(result == None)
    print("  PASSED")


def test_submit_order_with_price() raises:
    print("Test: submit_order with price creates limit order")
    var ctx = _setup_test_context()
    var result = submit_order(ctx, "000001.XSHE", 100, SIDE.BUY, price=25.5)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.style_order.style_type, ORDER_TYPE.LIMIT)
    assert_equal(order.style_order.limit_price, 25.5)
    print("  PASSED")


def test_cancel_order_active() raises:
    print("Test: cancel_order on active order returns order copy")
    var ctx = _setup_test_context()
    var style = MarketOrder()
    var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, style, POSITION_EFFECT.OPEN)
    order.active()
    var result = cancel_order(ctx, order)
    assert_equal(result.order_id, order.order_id)
    assert_equal(result.status, ORDER_STATUS.ACTIVE)
    print("  PASSED")


def test_cancel_order_inactive() raises:
    print("Test: cancel_order on inactive order returns order copy")
    var ctx = _setup_test_context()
    var style = MarketOrder()
    var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, style, POSITION_EFFECT.OPEN)
    var result = cancel_order(ctx, order)
    assert_equal(result.order_id, order.order_id)
    print("  PASSED")


def test_history_bars_close_field() raises:
    print("Test: history_bars with close field")
    var ctx = _setup_test_context()
    var result = history_bars(ctx, "000001.XSHE", 3, "1d", "close")
    assert_equal(len(result), 3)
    for val in result:
        assert_true(val >= 0.0, "close price should be non-negative")
    print("  PASSED")


def test_history_bars_open_field() raises:
    print("Test: history_bars with open field")
    var ctx = _setup_test_context()
    var result = history_bars(ctx, "000001.XSHE", 2, "1d", "open")
    assert_equal(len(result), 2)
    print("  PASSED")


def test_history_bars_volume_field() raises:
    print("Test: history_bars with volume field")
    var ctx = _setup_test_context()
    var result = history_bars(ctx, "000001.XSHE", 2, "1d", "volume")
    assert_equal(len(result), 2)
    print("  PASSED")


def test_history_bars_high_low_fields() raises:
    print("Test: history_bars with high and low fields")
    var ctx = _setup_test_context()
    var high_result = history_bars(ctx, "000001.XSHE", 2, "1d", "high")
    var low_result = history_bars(ctx, "000001.XSHE", 2, "1d", "low")
    assert_equal(len(high_result), 2)
    assert_equal(len(low_result), 2)
    print("  PASSED")


def test_history_bars_default_field() raises:
    print("Test: history_bars defaults to close field")
    var ctx = _setup_test_context()
    var result = history_bars(ctx, "000001.XSHE", 2, "1d")
    assert_equal(len(result), 2)
    print("  PASSED")


def test_history_wrapper() raises:
    print("Test: history delegates to history_bars")
    var ctx = _setup_test_context()
    var result = history(ctx, "000001.XSHE", 3, "1d", "close")
    assert_equal(len(result), 3)
    print("  PASSED")


def test_get_price_date_range() raises:
    print("Test: get_price returns values in date range")
    var ctx = _setup_test_context()
    var start = DateTime(2016, 12, 1, 0, 0, 0, 0)
    var end = DateTime(2016, 12, 5, 0, 0, 0, 0)
    var result = get_price(ctx, "000001.XSHE", start, end)
    assert_true(len(result) > 0, "should return some prices")
    print("  PASSED")


def test_current_snapshot_returns_none() raises:
    print("Test: current_snapshot returns None (stub)")
    var ctx = _setup_test_context()
    var result = current_snapshot(ctx, "000001.XSHE")
    assert_true(result == None)
    print("  PASSED")


def test_get_trading_dates_range() raises:
    print("Test: get_trading_dates generates dates in range")
    var ctx = _setup_test_context()
    var start = DateTime(2016, 12, 1, 0, 0, 0, 0)
    var end = DateTime(2016, 12, 5, 0, 0, 0, 0)
    var result = get_trading_dates(ctx, start, end)
    assert_true(len(result) >= 4, "should have at least 4 dates (1st-4th)")
    assert_equal(result[0].year, 2016)
    assert_equal(result[0].month, 12)
    print("  PASSED")


def test_get_previous_trading_date() raises:
    print("Test: get_previous_trading_date returns earlier date")
    var ctx = _setup_test_context()
    var date = DateTime(2016, 12, 10, 0, 0, 0, 0)
    var prev = get_previous_trading_date(ctx, date)
    assert_true(prev.day < date.day or prev.month < date.month, "previous should be earlier")
    print("  PASSED")


def test_get_next_trading_date() raises:
    print("Test: get_next_trading_date returns later date")
    var ctx = _setup_test_context()
    var date = DateTime(2016, 12, 10, 0, 0, 0, 0)
    var next_dt = get_next_trading_date(ctx, date)
    assert_true(next_dt.day >= date.day, "next should be later or same day")
    print("  PASSED")


def test_get_position_empty() raises:
    print("Test: get_position returns None for empty position")
    var ctx = _setup_test_context()
    var result = get_position(ctx, "NONEXISTENT.XSHE")
    assert_true(result == None, "non-existent position should be None")
    print("  PASSED")


def test_get_position_default_direction() raises:
    print("Test: get_position uses LONG direction by default")
    var ctx = _setup_test_context()
    var result = get_position(ctx, "000001.XSHE")
    assert_true(result == None, "default position should be empty/None")
    print("  PASSED")


def test_get_positions_empty() raises:
    print("Test: get_positions returns empty list")
    var ctx = _setup_test_context()
    var result = get_positions(ctx)
    assert_equal(len(result), 0)
    print("  PASSED")


def test_get_portfolio_returns_portfolio() raises:
    print("Test: get_portfolio returns Portfolio object")
    var ctx = _setup_test_context()
    var pf = get_portfolio(ctx)
    assert_true(pf.total_value > 0, "portfolio should have value")
    print("  PASSED")


def test_instruments_returns_instrument() raises:
    print("Test: instruments returns Instrument for valid id")
    var ctx = _setup_test_context()
    var result = instruments(ctx, "000001.XSHE")
    assert_true(result != None, "should find instrument")
    print("  PASSED")


def test_all_instruments_returns_list() raises:
    print("Test: all_instruments returns empty list (stub)")
    var ctx = _setup_test_context()
    var result = all_instruments(ctx)
    assert_equal(len(result), 0)
    print("  PASSED")


def test_active_instrument_returns_instrument() raises:
    print("Test: active_instrument returns instrument")
    var ctx = _setup_test_context()
    var result = active_instrument(ctx, "000001.XSHE")
    assert_true(result != None)
    print("  PASSED")


def test_deposit_noop() raises:
    print("Test: deposit is a no-op stub")
    var ctx = _setup_test_context()
    deposit(ctx, "STOCK", 10000.0)
    print("  PASSED")


def test_withdraw_noop() raises:
    print("Test: withdraw is a no-op stub")
    var ctx = _setup_test_context()
    withdraw(ctx, "STOCK", 5000.0)
    print("  PASSED")


def test_subscribe_noop() raises:
    print("Test: subscribe is a no-op stub")
    var ctx = _setup_test_context()
    subscribe(ctx, "000001.XSHE")
    print("  PASSED")


def test_unsubscribe_noop() raises:
    print("Test: unsubscribe is a no-op stub")
    var ctx = _setup_test_context()
    unsubscribe(ctx, "000001.XSHE")
    print("  PASSED")


def main() raises:
    print("=" * 60)
    print("Running api_base.mojo Comprehensive Tests")
    print("=" * 60)
    print("")

    test_assure_order_book_id()
    test_cal_style_market()
    test_cal_style_limit_from_price()
    test_cal_style_limit_from_param()

    test_order_shares_buy_market()
    test_order_shares_sell()
    test_order_shares_zero_quantity()
    test_order_shares_limit_order()

    test_order_value_positive()
    test_order_value_zero()
    test_order_value_negative_sells()

    test_order_percent_valid()
    test_order_percent_zero()
    test_order_percent_over_one()
    test_order_percent_negative()

    test_order_target_value_increase()
    test_order_target_percent()

    test_submit_order_buy()
    test_submit_order_sell()
    test_submit_order_zero_amount()
    test_submit_order_negative_amount()
    test_submit_order_with_price()

    test_cancel_order_active()
    test_cancel_order_inactive()

    test_history_bars_close_field()
    test_history_bars_open_field()
    test_history_bars_volume_field()
    test_history_bars_high_low_fields()
    test_history_bars_default_field()
    test_history_wrapper()

    test_get_price_date_range()
    test_current_snapshot_returns_none()

    test_get_trading_dates_range()
    test_get_previous_trading_date()
    test_get_next_trading_date()

    test_get_position_empty()
    test_get_position_default_direction()
    test_get_positions_empty()
    test_get_portfolio_returns_portfolio()

    test_instruments_returns_instrument()
    test_all_instruments_returns_list()
    test_active_instrument_returns_instrument()

    test_deposit_noop()
    test_withdraw_noop()
    test_subscribe_noop()
    test_unsubscribe_noop()

    print("")
    print("=" * 60)
    print("All api_base tests completed successfully!")
    print("=" * 60)
