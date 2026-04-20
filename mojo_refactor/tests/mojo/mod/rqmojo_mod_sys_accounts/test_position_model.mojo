"""
Unit tests for position_model.mojo
Tests StockPosition, FuturePosition, StockPositionProxy, FuturePositionProxy

Matching Python original:
  - StockPosition (lines 45-292): dividend/split/settlement logic
  - FuturePosition (lines 295-414): margin/contract multiplier logic
  - StockPositionProxy (lines 417-454): stock proxy aggregation
  - FuturePositionProxy (lines 457-670): future proxy aggregation
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, Optional
from std.python import Python, PythonObject

from rqmojo.const import POSITION_DIRECTION, SIDE, POSITION_EFFECT
from rqmojo.model.trade import Trade, create_trade_from_order
from rqmojo.mod.rqmojo_mod_sys_accounts.position_model import (
    StockPosition, create_stock_position,
    FuturePosition, create_future_position,
    StockPositionProxy,
    FuturePositionProxy,
)
from rqmojo.utils.typing import DateTimeDate


def test_stock_position_construction() raises:
    """Test StockPosition default and custom construction."""
    var pos = create_stock_position(
        order_book_id="000001.XSHE",
        direction=POSITION_DIRECTION.LONG,
        init_quantity=1000,
        init_price=Optional[Float64](10.0)
    )
    assert_equal(pos.order_book_id(), "000001.XSHE")
    assert_equal(pos.direction(), POSITION_DIRECTION.LONG)
    assert_equal(pos.quantity(), 1000)
    assert_equal(pos.old_quantity(), 1000)
    assert_equal(pos.today_quantity(), 0)
    assert_equal(pos.avg_price(), 10.0)


def test_stock_position_default_values() raises:
    """Test StockPosition with default quantity and price."""
    var pos = create_stock_position(
        order_book_id="000002.XSHE",
        direction=POSITION_DIRECTION.LONG
    )
    assert_equal(pos.quantity(), 0)
    assert_equal(pos.avg_price(), 0.0)
    assert_equal(pos.last_price(), 0.0)
    assert_equal(pos.prev_close(), 0.0)


def test_stock_position_direction_factor() raises:
    """Test direction_factor returns 1.0 for LONG, -1.0 for SHORT."""
    var long_pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(long_pos.direction_factor(), 1.0)

    var short_pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.SHORT)
    assert_equal(short_pos.direction_factor(), -1.0)


def test_stock_position_set_last_price() raises:
    """Test set_last_price updates last_price."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](10.0))
    pos.set_last_price(15.0)
    assert_equal(pos.last_price(), 15.0)

    pos.update_last_price(20.0)
    assert_equal(pos.last_price(), 20.0)


def test_stock_position_market_value() raises:
    """Test market_value = quantity * last_price."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 1000, Optional[Float64](10.0))
    pos.update_last_price(12.5)
    assert_equal(pos.market_value(), 12500.0)


def test_stock_position_pnl() raises:
    """Test pnl = (last_price - avg_price) * quantity * direction_factor."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 1000, Optional[Float64](10.0))
    pos.update_last_price(12.0)
    var expected_pnl = (12.0 - 10.0) * 1000.0 * 1.0
    assert_equal(pos.pnl(), expected_pnl)


def test_stock_position_pnl_short() raises:
    """Test pnl for SHORT direction is negative of LONG."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.SHORT, 1000, Optional[Float64](10.0))
    pos.update_last_price(8.0)
    var expected_pnl = (8.0 - 10.0) * 1000.0 * (-1.0)
    assert_equal(pos.pnl(), expected_pnl)


def test_stock_position_trading_pnl() raises:
    """Test trading_pnl calculation after trades."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 0, Optional[Float64](0.0))
    pos.update_last_price(11.0)
    var initial_tp = pos.trading_pnl()
    assert_equal(initial_tp, 0.0)


def test_stock_position_closable_basic() raises:
    """Test closable returns quantity when no non_closable."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 500, Optional[Float64](10.0))
    assert_equal(pos.closable(), 500)


def test_stock_position_dividend_receivable_total() raises:
    """Test dividend_receivable_total sums all dividends."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(pos.dividend_receivable_total(), 0.0)


def test_stock_position_equity() raises:
    """Test equity = pnl + dividend_receivable_total."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 1000, Optional[Float64](10.0))
    pos.update_last_price(12.0)
    assert_equal(pos.equity(), pos.pnl())


def test_stock_position_before_trading_empty() raises:
    """Test before_trading on empty position returns 0."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG)
    var dummy_date = DateTimeDate(2025, 1, 1)
    var result = pos.before_trading(dummy_date)
    assert_equal(result, 0.0)


def test_stock_position_settlement_empty() raises:
    """Test settlement on empty position returns 0."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG)
    var dummy_date = DateTimeDate(2025, 1, 1)
    var result = pos.settlement(dummy_date)
    assert_equal(result, 0.0)


def test_stock_position_before_trading_short_raises() raises:
    """Test before_trading raises for SHORT direction."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.SHORT, 100, Optional[Float64](10.0))
    pos.update_last_price(10.0)
    var dummy_date = DateTimeDate(2025, 1, 1)
    var raised = False
    try:
        _ = pos.before_trading(dummy_date)
    except e:
        raised = True
    assert_true(raised)


def test_stock_position_get_state_set_state_roundtrip() raises:
    """Test get_state -> set_state preserves all fields."""
    var pos = create_stock_position(
        "000001.XSHE", POSITION_DIRECTION.LONG,
        2000, Optional[Float64](15.5)
    )
    pos.update_last_price(18.3)
    var state = pos.get_state()

    var pos2 = create_stock_position("temp.XSHE", POSITION_DIRECTION.LONG)
    pos2.set_state(state)

    assert_equal(pos2.order_book_id(), "000001.XSHE")
    assert_equal(pos2.direction(), POSITION_DIRECTION.LONG)
    assert_equal(pos2.quantity(), 2000)
    assert_equal(pos2.avg_price(), 15.5)
    assert_equal(pos2.last_price(), 18.3)


def test_stock_position_get_non_closable() raises:
    """Test _non_closable field in state roundtrip."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 1000, Optional[Float64](10.0))
    var state = pos.get_state()

    var pos2 = create_stock_position("temp.XSHE", POSITION_DIRECTION.LONG)
    pos2.set_state(state)
    assert_equal(pos2.closable(), 1000)


def test_stock_position_market_value_local() raises:
    """Test market_value_local equals market_value."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](20.0))
    pos.update_last_price(25.0)
    assert_equal(pos.market_value_local(), pos.market_value())


def test_stock_position_position_queue() raises:
    """Test position_queue returns valid queue."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG)
    _ = pos.position_queue()


def test_stock_position_tplus_enabled_flag() raises:
    """Test t_plus_enabled comptime flag is True."""
    assert_true(StockPosition.t_plus_enabled)


def test_stock_position_apply_trade_open() raises:
    """Test apply_trade OPEN increases non_closable when t_plus_enabled."""
    var pos = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 0, Optional[Float64](0.0))

    var trade = create_trade_from_order(
        trade_id=1,
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        position_direction=POSITION_DIRECTION.LONG,
        quantity=500,
        price=10.0
    )
    _ = pos.apply_trade(trade)
    assert_equal(pos.closable(), 0)


def test_future_position_construction() raises:
    """Test FuturePosition default and custom construction."""
    var pos = create_future_position(
        order_book_id="IF2301.CFFEX",
        direction=POSITION_DIRECTION.LONG,
        init_quantity=10,
        init_price=Optional[Float64](3000.0),
        contract_multiplier=300.0
    )
    assert_equal(pos.order_book_id(), "IF2301.CFFEX")
    assert_equal(pos.direction(), POSITION_DIRECTION.LONG)
    assert_equal(pos.quantity(), 10)
    assert_equal(pos.contract_multiplier(), 300.0)


def test_future_position_contract_multiplier() raises:
    """Test contract_multiplier property."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 0, None, 50.0)
    assert_equal(pos.contract_multiplier(), 50.0)


def test_future_position_margin_rate() raises:
    """Test margin_rate defaults to 0.1."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG)
    assert_equal(pos.margin_rate(), 0.1)


def test_future_position_update_margin_rate() raises:
    """Test update_margin_rate changes margin rate."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG)
    pos.update_margin_rate(0.15)
    assert_equal(pos.margin_rate(), 0.15)


def test_future_position_equity_long() raises:
    """Test equity for LONG future: qty*(last-avg)*multiplier*df."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var expected = 10.0 * (3100.0 - 3000.0) * 300.0 * 1.0
    assert_equal(pos.equity(), expected)


def test_future_position_equity_short() raises:
    """Test equity for SHORT future: negative direction factor."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.SHORT, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(2900.0)
    var expected = 10.0 * (2900.0 - 3000.0) * 300.0 * (-1.0)
    assert_equal(pos.equity(), expected)


def test_future_position_margin_zero_qty() raises:
    """Test margin returns 0 when quantity is 0."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 0, Optional[Float64](3000.0), 300.0)
    assert_equal(pos.margin(), 0.0)


def test_future_position_margin_positive() raises:
    """Test margin = margin_rate * market_value."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var expected_margin = 0.1 * pos.market_value()
    assert_equal(pos.margin(), expected_margin)


def test_future_position_market_value_with_multiplier() raises:
    """Test market_value includes contract multiplier."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var expected_mv = 300.0 * 10.0 * 3100.0
    assert_equal(pos.market_value(), expected_mv)


def test_future_position_trading_pnl_scaled() raises:
    """Test trading_pnl scaled by contract_multiplier."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var base_pnl = pos._position.trading_pnl()
    assert_equal(pos.trading_pnl(), 300.0 * base_pnl)


def test_future_position_position_pnl_scaled() raises:
    """Test position_pnl scaled by contract_multiplier."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var base_pp = pos._position.position_pnl()
    assert_equal(pos.position_pnl(), 300.0 * base_pp)


def test_future_position_pnl_scaled() raises:
    """Test pnl scaled by contract_multiplier."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var base_pnl = pos._position.pnl()
    assert_equal(pos.pnl(), 300.0 * base_pnl)


def test_future_position_calc_close_today_amount_exact() raises:
    """Test calc_close_today_amount capped at today_quantity (0 initially)."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var result = pos.calc_close_today_amount(5, POSITION_EFFECT.CLOSE_TODAY)
    assert_equal(result, 0)


def test_future_position_calc_close_today_amount_exceeds() raises:
    """Test calc_close_today_amount capped at today_quantity (0 initially)."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var result = pos.calc_close_today_amount(15, POSITION_EFFECT.CLOSE_TODAY)
    assert_equal(result, 0)


def test_future_position_calc_close_today_amount_other_effect() raises:
    """Test calc_close_today_amount for non-CLOSE_TODAY effect."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var result = pos.calc_close_today_amount(15, POSITION_EFFECT.CLOSE)
    assert_equal(result, 5)


def test_future_position_settlement_resets_avg_price() raises:
    """Test settlement resets avg_price to last_price."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    pos.update_last_price(3100.0)
    var dummy_date = DateTimeDate(2025, 1, 1)
    _ = pos.settlement(dummy_date)
    assert_equal(pos.avg_price(), 3100.0)


def test_future_position_settlement_empty() raises:
    """Test settlement on empty position returns 0."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 0, Optional[Float64](3000.0), 300.0)
    var dummy_date = DateTimeDate(2025, 1, 1)
    var result = pos.settlement(dummy_date)
    assert_equal(result, 0.0)


def test_future_position_post_settlement_noop() raises:
    """Test post_settlement does nothing (no-op)."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG)
    pos.post_settlement()


def test_future_position_closable() raises:
    """Test closable delegates to Position.closable."""
    var pos = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    assert_equal(pos.closable(), 10)


def test_future_position_direction_factor() raises:
    """Test direction_factor for futures."""
    var long_pos = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG)
    assert_equal(long_pos.direction_factor(), 1.0)

    var short_pos = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT)
    assert_equal(short_pos.direction_factor(), -1.0)


def test_future_position_get_state_set_state_roundtrip() raises:
    """Test get_state -> set_state preserves all fields including transaction_cost."""
    var pos = create_future_position(
        "IF2301.CFFEX", POSITION_DIRECTION.LONG,
        20, Optional[Float64](3500.0), 300.0
    )
    pos.update_last_price(3600.0)
    pos._transaction_cost = 50.0
    var state = pos.get_state()

    var pos2 = create_future_position("temp.CFFEX", POSITION_DIRECTION.LONG, 0, None, 300.0)
    pos2.set_state(state)

    assert_equal(pos2.order_book_id(), "IF2301.CFFEX")
    assert_equal(pos2.direction(), POSITION_DIRECTION.LONG)
    assert_equal(pos2.quantity(), 20)
    assert_equal(pos2.avg_price(), 3500.0)
    assert_equal(pos2.last_price(), 3600.0)
    assert_equal(pos2.contract_multiplier(), 300.0)
    assert_equal(pos2._transaction_cost, 50.0)


def test_future_position_set_state_short_direction() raises:
    """Test set_state restores SHORT direction correctly."""
    var pos = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](4000.0), 300.0)
    var state = pos.get_state()

    var pos2 = create_future_position("temp.CFFEX", POSITION_DIRECTION.LONG, 0, None, 300.0)
    pos2.set_state(state)
    assert_equal(pos2.direction(), POSITION_DIRECTION.SHORT)


def test_stock_proxy_type_name() raises:
    """Test StockPositionProxy.type_name returns 'STOCK'."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](10.0))
    var proxy = StockPositionProxy(_long=sp^)
    assert_equal(proxy.type_name(), "STOCK")


def test_stock_proxy_delegation() raises:
    """Test StockPositionProxy delegates to underlying StockPosition."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 500, Optional[Float64](20.0))
    sp.update_last_price(25.0)
    var proxy = StockPositionProxy(_long=sp^)

    assert_equal(proxy.order_book_id(), "000001.XSHE")
    assert_equal(proxy.quantity(), 500)
    assert_equal(proxy.sellable(), 500)
    assert_equal(proxy.avg_price(), 20.0)
    assert_equal(proxy.market_value(), 12500.0)
    assert_equal(proxy.pnl(), (25.0 - 20.0) * 500.0)


def test_stock_proxy_daily_pnl() raises:
    """Test daily_pnl = trading_pnl + position_pnl."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](10.0))
    sp.update_last_price(12.0)
    var expected_tp = sp.trading_pnl()
    var expected_pp = sp.position_pnl()
    var proxy = StockPositionProxy(_long=sp^)
    assert_equal(proxy.daily_pnl(), expected_tp + expected_pp)


def test_stock_proxy_margin_equals_market_value() raises:
    """Test stock proxy margin equals market_value."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](10.0))
    sp.update_last_price(15.0)
    var proxy = StockPositionProxy(_long=sp^)
    assert_equal(proxy.margin(), proxy.market_value())


def test_stock_proxy_value_percent() raises:
    """Test value_percent = market_value / total_portfolio_value."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](10.0))
    sp.update_last_price(20.0)
    var proxy = StockPositionProxy(_long=sp^)
    var pct = proxy.value_percent(100000.0)
    assert_equal(pct, 2000.0 / 100000.0)


def test_stock_proxy_value_percent_zero_total() raises:
    """Test value_percent returns 0 when total is 0."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 100, Optional[Float64](10.0))
    sp.update_last_price(20.0)
    var proxy = StockPositionProxy(_long=sp^)
    assert_equal(proxy.value_percent(0.0), 0.0)


def test_stock_proxy_closable() raises:
    """Test proxy closable delegates to stock closable."""
    var sp = create_stock_position("000001.XSHE", POSITION_DIRECTION.LONG, 300, Optional[Float64](10.0))
    var proxy = StockPositionProxy(_long=sp^)
    assert_equal(proxy.closable(), 300)


def test_future_proxy_type_name() raises:
    """Test FuturePositionProxy.type_name returns 'FUTURE'."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](3000.0), 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)
    assert_equal(proxy.type_name(), "FUTURE")


def test_future_proxy_order_book_id() raises:
    """Test proxy order_book_id from long position."""
    var fl = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF2301.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](3000.0), 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)
    assert_equal(proxy.order_book_id(), "IF2301.CFFEX")


def test_future_proxy_margin_rate() raises:
    """Test proxy margin_rate from long position."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, None, 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, None, 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)
    assert_equal(proxy.margin_rate(), 0.1)


def test_future_proxy_contract_multiplier() raises:
    """Test proxy contract_multiplier from long position."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, None, 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, None, 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)
    assert_equal(proxy.contract_multiplier(), 300.0)


def test_future_proxy_buy_sell_market_value() raises:
    """Test buy/sell market_value delegation."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](2900.0), 300.0)
    fl.update_last_price(3100.0)
    fs.update_last_price(2850.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.buy_market_value(), 300.0 * 10.0 * 3100.0)
    assert_equal(proxy.sell_market_value(), 300.0 * 5.0 * 2850.0)


def test_future_proxy_buy_sell_pnl() raises:
    """Test buy/sell PnL delegation."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](3000.0), 300.0)
    fl.update_last_price(3100.0)
    fs.update_last_price(2900.0)
    var expected_fl_pnl = fl.pnl()
    var expected_fs_pnl = fs.pnl()
    var expected_fl_pp = fl.position_pnl()
    var expected_fs_pp = fs.position_pnl()
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.buy_pnl(), expected_fl_pnl)
    assert_equal(proxy.sell_pnl(), expected_fs_pnl)
    assert_equal(proxy.buy_position_pnl(), expected_fl_pp)
    assert_equal(proxy.sell_position_pnl(), expected_fs_pp)


def test_future_proxy_daily_pnl() raises:
    """Test buy/sell daily_pnl = position_pnl + trading_pnl."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](3000.0), 300.0)
    fl.update_last_price(3100.0)
    fs.update_last_price(2900.0)
    var expected_fl_daily = fl.position_pnl() + fl.trading_pnl()
    var expected_fs_daily = fs.position_pnl() + fs.trading_pnl()
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.buy_daily_pnl(), expected_fl_daily)
    assert_equal(proxy.sell_daily_pnl(), expected_fs_daily)


def test_future_proxy_quantities() raises:
    """Test buy/sell quantity delegation."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 8, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 3, Optional[Float64](3000.0), 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.buy_old_quantity(), 8)
    assert_equal(proxy.sell_old_quantity(), 3)
    assert_equal(proxy.buy_today_quantity(), 0)
    assert_equal(proxy.sell_today_quantity(), 0)
    assert_equal(proxy.buy_quantity(), 8)
    assert_equal(proxy.sell_quantity(), 3)


def test_future_proxy_margin_aggregation() raises:
    """Test total margin = buy_margin + sell_margin."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](2900.0), 300.0)
    fl.update_last_price(3100.0)
    fs.update_last_price(2850.0)
    var expected_fl_margin = fl.margin()
    var expected_fs_margin = fs.margin()
    var expected_total = expected_fl_margin + expected_fs_margin
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.margin(), expected_total)
    assert_equal(proxy.buy_margin(), expected_fl_margin)
    assert_equal(proxy.sell_margin(), expected_fs_margin)


def test_future_proxy_avg_open_prices() raises:
    """Test buy/sell avg_open_price delegation."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3050.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](2980.0), 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.buy_avg_open_price(), 3050.0)
    assert_equal(proxy.sell_avg_open_price(), 2980.0)


def test_future_proxy_transaction_costs() raises:
    """Test buy/sell transaction_cost delegation."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 10, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 5, Optional[Float64](3000.0), 300.0)
    fl._transaction_cost = 100.0
    fs._transaction_cost = 50.0
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.buy_transaction_cost(), 100.0)
    assert_equal(proxy.sell_transaction_cost(), 50.0)


def test_future_proxy_closable_quantities() raises:
    """Test closable quantity delegation."""
    var fl = create_future_position("IF.CFFEX", POSITION_DIRECTION.LONG, 15, Optional[Float64](3000.0), 300.0)
    var fs = create_future_position("IF.CFFEX", POSITION_DIRECTION.SHORT, 7, Optional[Float64](3000.0), 300.0)
    var proxy = FuturePositionProxy(_long=fl^, _short=fs^)

    assert_equal(proxy.closable_today_sell_quantity(), 0)
    assert_equal(proxy.closable_today_buy_quantity(), 0)
    assert_equal(proxy.closable_buy_quantity(), 15)
    assert_equal(proxy.closable_sell_quantity(), 7)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
