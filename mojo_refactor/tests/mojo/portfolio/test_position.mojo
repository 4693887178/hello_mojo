"""
Unit tests for portfolio/position.mojo
Tests matching Python original rqalpha/portfolio/position.py (527 lines)

Coverage:
  Position: construction, properties, pnl, market_value, equity, state, lifecycle, apply_trade
  PositionProxy: long/short aggregation, pnl, market_value, transaction_cost
  PositionProxyDict: auto-creation, keys, items, contains
  PositionQueue integration
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List

from rqmojo.portfolio.position import (
    Position, PositionProxy, PositionProxyDict,
    create_position, create_stock_position, create_future_position,
    create_position_proxy, create_position_proxy_dict,
    _hash_key
)
from rqmojo.const import POSITION_EFFECT, POSITION_DIRECTION, SIDE
from rqmojo.model.trade import Trade


def test_position_default_construction() raises:
    var pos = Position()
    assert_equal(pos.order_book_id, "")
    assert_equal(pos.quantity, 0)
    assert_equal(pos.old_quantity, 0)
    assert_equal(pos.avg_price, 0.0)
    assert_equal(pos.transaction_cost, 0.0)
    assert_equal(pos.trade_cost, 0.0)
    assert_equal(pos.direction_factor, 1)


def test_position_create_stock_position() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.5)
    assert_equal(pos.order_book_id, "000001.XSHE")
    assert_equal(pos.quantity, 100)
    assert_equal(pos.old_quantity, 100)
    assert_equal(pos.avg_price, 10.5)
    assert_equal(pos.last_price, 10.5)
    assert_equal(pos.prev_close, 10.5)
    assert_equal(pos.direction_factor, 1)
    assert_equal(pos.transaction_cost, 0.0)


def test_position_create_future_long() raises:
    var pos = create_future_position("IF2312.XCFF", POSITION_DIRECTION.LONG, 200, 3800.0)
    assert_equal(pos.order_book_id, "IF2312.XCFF")
    assert_equal(pos.quantity, 200)
    assert_equal(pos.direction, POSITION_DIRECTION.LONG)
    assert_equal(pos.direction_factor, 1)


def test_position_create_future_short() raises:
    var pos = create_future_position("IF2312.XCFF", POSITION_DIRECTION.SHORT, 150, 3900.0)
    assert_equal(pos.direction, POSITION_DIRECTION.SHORT)
    assert_equal(pos.direction_factor, -1)


def test_position_pnl_zero_quantity() raises:
    var pos = create_stock_position("000001.XSHE", 0, 10.0)
    pos.update_last_price(12.0)
    assert_equal(pos.pnl(), 0.0)


def test_position_pnl_long_profit() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(12.0)
    var expected = (12.0 - 10.0) * Float64(100) * Float64(1)
    assert_equal(pos.pnl(), expected)


def test_position_pnl_short_loss() raises:
    var pos = create_future_position("IF2312.XCFF", POSITION_DIRECTION.SHORT, 50, 4000.0)
    pos.update_last_price(4100.0)
    var expected = (4100.0 - 4000.0) * Float64(50) * Float64(-1)
    assert_equal(pos.pnl(), expected)


def test_position_market_value_zero() raises:
    var pos = create_stock_position("000001.XSHE", 0, 10.0)
    assert_equal(pos.market_value(), 0.0)


def test_position_market_value_normal() raises:
    var pos = create_stock_position("000001.XSHE", 200, 15.5)
    pos.update_last_price(16.8)
    assert_equal(pos.market_value(), 16.8 * Float64(200))


def test_position_equity_same_as_market_value() raises:
    var pos = create_stock_position("000001.XSHE", 300, 20.0)
    pos.update_last_price(25.0)
    assert_equal(pos.equity(), pos.market_value())


def test_position_equity_zero_qty() raises:
    var pos = create_stock_position("000001.XSHE", 0, 10.0)
    assert_equal(pos.equity(), 0.0)


def test_position_trading_pnl_initial() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(11.0)
    var trade_qty = pos.quantity - pos.logical_old_quantity
    assert_equal(trade_qty, 100)
    assert_equal(pos.trading_pnl(), (Float64(trade_qty) * 11.0 - 0.0) * Float64(1))


def test_position_position_pnl_after_before_trading() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(11.0)
    _ = pos.before_trading()
    pos.update_last_price(12.0)
    var expected = Float64(100) * (12.0 - 10.0) * Float64(1)
    assert_equal(pos.position_pnl(), expected)


def test_position_daily_pnl_sum() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = pos.before_trading()
    pos.update_last_price(12.0)
    assert_equal(pos.daily_pnl(), pos.position_pnl() + pos.trading_pnl())


def test_position_transaction_cost_initial() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    assert_equal(pos.transaction_cost_val(), 0.0)


def test_position_closable_equals_quantity() raises:
    var pos = create_stock_position("000001.XSHE", 500, 20.0)
    assert_equal(pos.closable(), 500)


def test_position_today_closable_initial() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    assert_equal(pos.today_closable(), 0)


def test_position_today_closable_after_open() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = pos.before_trading()
    from rqmojo.utils.typing import DateTime as DT
    var dt = DT.now()
    var trade = Trade(
        1, "exec_001", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        50, 11.0, dt, dt,
        commission=0.55
    )
    _ = pos.apply_trade(trade)
    assert_equal(pos.today_closable(), 50)


def test_position_direction_factor_val() raises:
    var long_pos = create_future_position("IF.XCFF", POSITION_DIRECTION.LONG, 10, 100)
    var short_pos = create_future_position("IF.XCFF", POSITION_DIRECTION.SHORT, 10, 100)
    assert_equal(long_pos.direction_factor_val(), 1)
    assert_equal(short_pos.direction_factor_val(), -1)


def test_position_get_state_roundtrip() raises:
    var pos = create_stock_position("000001.XSHE", 200, 15.5)
    pos.update_last_price(18.0)
    var state = pos.get_state()
    assert_true(len(state) > 0)
    assert_equal(state["quantity"], "200")
    assert_equal(state["old_quantity"], "200")
    assert_equal(state["avg_price"], "15.5")


def test_position_set_state_restores_values() raises:
    var pos1 = create_stock_position("000001.XSHE", 300, 20.0)
    var state = pos1.get_state()
    var pos2 = Position()
    pos2.order_book_id = "000001.XSHE"
    pos2.set_state(state^)
    assert_equal(pos2.quantity, 300)
    assert_equal(pos2.old_quantity, 300)
    assert_equal(pos2.avg_price, 20.0)


def test_position_set_state_with_today_quantity() raises:
    var pos = Position()
    pos.order_book_id = "000001.XSHE"
    var state = Dict[String, String]()
    state["old_quantity"] = String(100)
    state["logical_old_quantity"] = String(100)
    state["today_quantity"] = String(50)
    state["avg_price"] = String(10.0)
    state["trade_cost"] = String(550.0)
    state["transaction_cost"] = String(5.5)
    state["prev_close"] = String(9.8)
    pos.set_state(state^)
    assert_equal(pos.quantity, 150)
    assert_equal(pos.old_quantity, 100)
    assert_equal(pos.avg_price, 10.0)
    assert_equal(pos.trade_cost, 550.0)
    assert_equal(pos.transaction_cost, 5.5)


def test_position_before_trading_resets_costs() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.transaction_cost = 5.5
    pos.trade_cost = 100.0
    var result = _ = pos.before_trading()
    assert_equal(result, 0.0)
    assert_equal(pos.old_quantity, 100)
    assert_equal(pos.logical_old_quantity, 100)
    assert_equal(pos.trade_cost, 0.0)
    assert_equal(pos.transaction_cost, 0.0)


def test_position_before_trading_updates_quantities() raises:
    var pos = create_stock_position("000001.XSHE", 80, 10.0)
    _ = pos.before_trading()
    assert_equal(pos.old_quantity, 80)
    assert_equal(pos.logical_old_quantity, 80)


def test_position_apply_trade_open_increases_quantity() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    from rqmojo.utils.typing import DateTime as DT2
    var dt2 = DT2.now()
    var trade = Trade(
        1, "exec_001", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        50, 11.0, dt2, dt2,
        commission=0.55
    )
    var cash_delta = _ = pos.apply_trade(trade)
    assert_equal(pos.quantity, 150)
    assert_equal(cash_delta, (-1.0 * 11.0 * Float64(50)) - 0.55)


def test_position_apply_trade_open_avg_price_update() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    from rqmojo.utils.typing import DateTime as DT3
    var dt3 = DT3.now()
    var trade = Trade(
        2, "exec_002", 2, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        100, 14.0, dt3, dt3,
        commission=7.0
    )
    _ = pos.apply_trade(trade)
    var expected_avg = (10.0 * Float64(100) + 14.0 * Float64(100)) / Float64(200)
    assert_equal(pos.avg_price, expected_avg)


def test_position_apply_trade_close_decreases_quantity() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = pos.before_trading()
    from rqmojo.utils.typing import DateTime as DT4
    var dt4 = DT4.now()
    var trade = Trade(
        3, "exec_003", 3, "000001.XSHE",
        SIDE.SELL, POSITION_EFFECT.CLOSE, POSITION_DIRECTION.LONG,
        30, 12.0, dt4, dt4,
        commission=1.5
    )
    var cash_delta = _ = pos.apply_trade(trade)
    assert_equal(pos.quantity, 70)
    assert_equal(cash_delta, 12.0 * Float64(30) - 1.5)


def test_position_apply_trade_close_reduces_old_quantity() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = pos.before_trading()
    from rqmojo.utils.typing import DateTime as DT5
    var dt5 = DT5.now()
    var trade = Trade(
        4, "exec_004", 4, "000001.XSHE",
        SIDE.SELL, POSITION_EFFECT.CLOSE, POSITION_DIRECTION.LONG,
        40, 12.0, dt5, dt5,
        commission=2.0
    )
    _ = pos.apply_trade(trade)
    assert_equal(pos.old_quantity, 60)


def test_position_apply_trade_updates_transaction_cost() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    from rqmojo.utils.typing import DateTime as DT6
    var dt6 = DT6.now()
    var trade1 = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        50, 11.0, dt6, dt6,
        commission=0.55
    )
    var trade2 = Trade(
        2, "e2", 2, "000001.XSHE",
        SIDE.SELL, POSITION_EFFECT.CLOSE, POSITION_DIRECTION.LONG,
        20, 13.0, dt6, dt6,
        commission=1.3
    )
    _ = pos.apply_trade(trade1)
    _ = pos.apply_trade(trade2)
    assert_equal(pos.transaction_cost, 0.55 + 1.3)


def test_position_apply_trade_updates_trade_cost() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    from rqmojo.utils.typing import DateTime as DT7
    var dt7 = DT7.now()
    var trade = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        50, 11.0, dt7, dt7,
        commission=0.55
    )
    _ = pos.apply_trade(trade)
    assert_equal(pos.trade_cost, 11.0 * Float64(50))


def test_position_settlement_returns_zero() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    from rqmojo.utils.typing import DateTimeDate
    var d = DateTimeDate(2024, 1, 15)
    var result = pos.settlement(d)
    assert_equal(result, 0.0)


def test_position_update_last_price() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(15.5)
    assert_equal(pos.last_price, 15.5)
    assert_equal(pos.last_price_val(), 15.5)


def test_position_calc_close_today_amount_default() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    var result = pos.calc_close_today_amount(50, POSITION_EFFECT.OPEN)
    assert_equal(result, 0)


def test_position_copy_constructor() raises:
    var pos1 = create_stock_position("000001.XSHE", 200, 15.5)
    pos1.update_last_price(18.0)
    pos1.transaction_cost = 5.5
    var pos2 = Position(copy=pos1)
    assert_equal(pos2.order_book_id, "000001.XSHE")
    assert_equal(pos2.quantity, 200)
    assert_equal(pos2.avg_price, 15.5)
    assert_equal(pos2.last_price, 18.0)
    assert_equal(pos2.transaction_cost, 5.5)


def test_position_str_representation() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.5)
    var s = pos.__str__()
    assert_true(len(s) > 0)
    assert_equal(pos.order_book_id, "000001.XSHE")


def test_position_multiple_opens_and_closes() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = pos.before_trading()
    from rqmojo.utils.typing import DateTime as DT8
    var dt8 = DT8.now()
    var t1 = Trade(1, "e1", 1, "000001.XSHE", SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG, 50, 11.0, dt8, dt8, commission=0.55)
    var t2 = Trade(2, "e2", 2, "000001.XSHE", SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG, 30, 12.0, dt8, dt8, commission=0.36)
    var t3 = Trade(3, "e3", 3, "000001.XSHE", SIDE.SELL, POSITION_EFFECT.CLOSE, POSITION_DIRECTION.LONG, 60, 13.0, dt8, dt8, commission=0.78)
    _ = pos.apply_trade(t1)
    _ = pos.apply_trade(t2)
    _ = pos.apply_trade(t3)
    assert_equal(pos.quantity, 120)
    assert_equal(pos.old_quantity, 40)


def test_proxy_construction() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.order_book_id(), "000001.XSHE")


def test_proxy_market_value_aggregation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    long_pos.update_last_price(12.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    short_pos.update_last_price(12.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.market_value(), long_pos.market_value() - short_pos.market_value())


def test_proxy_pnl_aggregation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    long_pos.update_last_price(12.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    short_pos.update_last_price(12.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.pnl(), long_pos.pnl() + short_pos.pnl())


def test_proxy_position_pnl_aggregation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = long_pos.before_trading()
    long_pos.update_last_price(12.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    _ = short_pos.before_trading()
    short_pos.update_last_price(12.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.position_pnl(), long_pos.position_pnl() + short_pos.position_pnl())


def test_proxy_trading_pnl_aggregation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.trading_pnl(), long_pos.trading_pnl() + short_pos.trading_pnl())


def test_proxy_daily_pnl_calculation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = long_pos.before_trading()
    long_pos.update_last_price(12.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    _ = short_pos.before_trading()
    short_pos.update_last_price(12.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    var expected = long_pos.position_pnl() + long_pos.trading_pnl() + \
                  short_pos.position_pnl() + short_pos.trading_pnl() - \
                  proxy.transaction_cost()
    assert_equal(proxy.daily_pnl(), expected)


def test_proxy_margin_default() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.margin(), 0.0)


def test_proxy_transaction_cost_aggregation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    long_pos.transaction_cost = 5.5
    short_pos.transaction_cost = 2.3
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.transaction_cost(), 5.5 + 2.3)


def test_proxy_last_price_from_long() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    long_pos.update_last_price(15.5)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.last_price(), 15.5)


def test_proxy_long_short_accessors() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    assert_equal(proxy.long_position().quantity, 100)
    assert_equal(proxy.short_position().quantity, 0)


def test_proxy_str_representation() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    var s = proxy.__str__()
    assert_true(len(s) > 0)


def test_proxy_copy_constructor() raises:
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    var proxy1 = create_position_proxy(long_pos, short_pos)
    var proxy2 = PositionProxy(copy=proxy1)
    assert_equal(proxy2.order_book_id(), "000001.XSHE")


def test_proxy_both_directions_with_pnl() raises:
    var long_pos = create_future_position("IF.XCFF", POSITION_DIRECTION.LONG, 10, 4000.0)
    long_pos.update_last_price(4100.0)
    var short_pos = create_future_position("IF.XCFF", POSITION_DIRECTION.SHORT, 5, 3950.0)
    short_pos.update_last_price(4100.0)
    var proxy = create_position_proxy(long_pos, short_pos)
    var expected_pnl = long_pos.pnl() + short_pos.pnl()
    assert_equal(proxy.pnl(), expected_pnl)


def test_dict_construction() raises:
    var pd = create_position_proxy_dict()
    assert_equal(pd.len(), 0)


def test_dict_get_proxy_creates_new() raises:
    var pd = create_position_proxy_dict()
    var proxy = pd.get_proxy("000001.XSHE")
    assert_equal(pd.len(), 1)
    assert_true(pd.contains("000001.XSHE"))
    assert_equal(proxy.order_book_id(), "000001.XSHE")


def test_dict_get_proxy_returns_existing() raises:
    var pd = create_position_proxy_dict()
    var proxy1 = pd.get_proxy("000001.XSHE")
    var lp = proxy1.long_position()
    lp.update_last_price(12.0)
    _ = pd.get_proxy("000001.XSHE")
    assert_equal(pd.len(), 1)


def test_dict_set_positions() raises:
    var pd = create_position_proxy_dict()
    var long_pos = create_stock_position("000001.XSHE", 100, 10.0)
    var short_pos = create_position("000001.XSHE", POSITION_DIRECTION.SHORT, 0, 10.0)
    pd.set_positions("000001.XSHE", long_pos, short_pos)
    assert_true(pd.contains("000001.XSHE"))
    assert_equal(pd.len(), 1)


def test_dict_keys() raises:
    var pd = create_position_proxy_dict()
    _ = pd.get_proxy("000001.XSHE")
    _ = pd.get_proxy("600000.XSHG")
    var keys = pd.keys()
    assert_equal(len(keys), 2)


def test_dict_contains_false() raises:
    var pd = create_position_proxy_dict()
    assert_false(pd.contains("nonexistent"))


def test_dict_items_iteration() raises:
    var pd = create_position_proxy_dict()
    _ = pd.get_proxy("000001.XSHE")
    _ = pd.get_proxy("600000.XSHG")
    var items = pd.items()
    assert_equal(len(items), 2)


def test_dict_multiple_proxies() raises:
    var pd = create_position_proxy_dict()
    _ = pd.get_proxy("000001.XSHE")
    _ = pd.get_proxy("600000.XSHG")
    _ = pd.get_proxy("IF2312.XCFF")
    assert_equal(pd.len(), 3)


def test_dict_copy_constructor() raises:
    var pd1 = create_position_proxy_dict()
    _ = pd1.get_proxy("000001.XSHE")
    var pd2 = PositionProxyDict(copy=pd1)
    assert_equal(pd2.len(), 1)
    assert_true(pd2.contains("000001.XSHE"))


def test_queue_initialized_on_create() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    var q = pos.position_queue()
    assert_equal(q.total_quantity(), 100)


def test_queue_after_open_trade() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    from rqmojo.utils.typing import DateTime as DT9
    var dt9 = DT9.now()
    var trade = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        50, 11.0, dt9, dt9,
        commission=0.55
    )
    _ = pos.apply_trade(trade)
    var q = pos.position_queue()
    assert_equal(q.total_quantity(), 150)


def test_queue_after_close_trade() raises:
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    _ = pos.before_trading()
    from rqmojo.utils.typing import DateTime as DT10
    var dt10 = DT10.now()
    var trade = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.SELL, POSITION_EFFECT.CLOSE, POSITION_DIRECTION.LONG,
        30, 12.0, dt10, dt10,
        commission=1.5
    )
    _ = pos.apply_trade(trade)
    var q = pos.position_queue()
    assert_equal(q.total_quantity(), 70)


def test_hash_key_consistent() raises:
    var h1 = _hash_key("000001.XSHE")
    var h2 = _hash_key("000001.XSHE")
    assert_equal(h1, h2)


def test_hash_key_different() raises:
    var h1 = _hash_key("000001.XSHE")
    var h2 = _hash_key("600000.XSHG")
    assert_true(h1 != h2)


def main() raises:
    print("\n=== Testing Position ===")
    test_position_default_construction()
    print("[1/62] PASSED: default_construction")
    test_position_create_stock_position()
    print("[2/62] PASSED: create_stock_position")
    test_position_create_future_long()
    print("[3/62] PASSED: create_future_long")
    test_position_create_future_short()
    print("[4/62] PASSED: create_future_short")
    test_position_pnl_zero_quantity()
    print("[5/62] PASSED: pnl_zero_quantity")
    test_position_pnl_long_profit()
    print("[6/62] PASSED: pnl_long_profit")
    test_position_pnl_short_loss()
    print("[7/62] PASSED: pnl_short_loss")
    test_position_market_value_zero()
    print("[8/62] PASSED: market_value_zero")
    test_position_market_value_normal()
    print("[9/62] PASSED: market_value_normal")
    test_position_equity_same_as_market_value()
    print("[10/62] PASSED: equity_same_as_market_value")
    test_position_equity_zero_qty()
    print("[11/62] PASSED: equity_zero_qty")
    test_position_trading_pnl_initial()
    print("[12/62] PASSED: trading_pnl_initial")
    test_position_position_pnl_after_before_trading()
    print("[13/62] PASSED: position_pnl_after_before_trading")
    test_position_daily_pnl_sum()
    print("[14/62] PASSED: daily_pnl_sum")
    test_position_transaction_cost_initial()
    print("[15/62] PASSED: transaction_cost_initial")
    test_position_closable_equals_quantity()
    print("[16/62] PASSED: closable_equals_quantity")
    test_position_today_closable_initial()
    print("[17/62] PASSED: today_closable_initial")
    test_position_today_closable_after_open()
    print("[18/62] PASSED: today_closable_after_open")
    test_position_direction_factor_val()
    print("[19/62] PASSED: direction_factor_val")
    test_position_get_state_roundtrip()
    print("[20/62] PASSED: get_state_roundtrip")
    test_position_set_state_restores_values()
    print("[21/62] PASSED: set_state_restores_values")
    test_position_set_state_with_today_quantity()
    print("[22/62] PASSED: set_state_with_today_quantity")
    test_position_before_trading_resets_costs()
    print("[23/62] PASSED: before_trading_resets_costs")
    test_position_before_trading_updates_quantities()
    print("[24/62] PASSED: before_trading_updates_quantities")
    test_position_apply_trade_open_increases_quantity()
    print("[25/62] PASSED: apply_trade_open_increases_quantity")
    test_position_apply_trade_open_avg_price_update()
    print("[26/62] PASSED: apply_trade_open_avg_price_update")
    test_position_apply_trade_close_decreases_quantity()
    print("[27/62] PASSED: apply_trade_close_decreases_quantity")
    test_position_apply_trade_close_reduces_old_quantity()
    print("[28/62] PASSED: apply_trade_close_reduces_old_quantity")
    test_position_apply_trade_updates_transaction_cost()
    print("[29/62] PASSED: apply_trade_updates_transaction_cost")
    test_position_apply_trade_updates_trade_cost()
    print("[30/62] PASSED: apply_trade_updates_trade_cost")
    test_position_settlement_returns_zero()
    print("[31/62] PASSED: settlement_returns_zero")
    test_position_update_last_price()
    print("[32/62] PASSED: update_last_price")
    test_position_calc_close_today_amount_default()
    print("[33/62] PASSED: calc_close_today_amount_default")
    test_position_copy_constructor()
    print("[34/62] PASSED: copy_constructor")
    test_position_str_representation()
    print("[35/62] PASSED: str_representation")
    test_position_multiple_opens_and_closes()
    print("[36/62] PASSED: multiple_opens_and_closes")

    print("\n=== Testing PositionProxy (37-51) ===")
    test_proxy_construction()
    print("[37/62] PASSED: proxy_construction")
    test_proxy_market_value_aggregation()
    print("[38/62] PASSED: proxy_market_value_aggregation")
    test_proxy_pnl_aggregation()
    print("[39/62] PASSED: proxy_pnl_aggregation")
    test_proxy_position_pnl_aggregation()
    print("[40/62] PASSED: proxy_position_pnl_aggregation")
    test_proxy_trading_pnl_aggregation()
    print("[41/62] PASSED: proxy_trading_pnl_aggregation")
    test_proxy_daily_pnl_calculation()
    print("[42/62] PASSED: proxy_daily_pnl_calculation")
    test_proxy_margin_default()
    print("[43/62] PASSED: proxy_margin_default")
    test_proxy_transaction_cost_aggregation()
    print("[44/62] PASSED: proxy_transaction_cost_aggregation")
    test_proxy_last_price_from_long()
    print("[45/62] PASSED: proxy_last_price_from_long")
    test_proxy_long_short_accessors()
    print("[46/62] PASSED: proxy_long_short_accessors")
    test_proxy_str_representation()
    print("[47/62] PASSED: proxy_str_representation")
    test_proxy_copy_constructor()
    print("[48/62] PASSED: proxy_copy_constructor")
    test_proxy_both_directions_with_pnl()
    print("[49/62] PASSED: proxy_both_directions_with_pnl")

    print("\n=== Testing PositionProxyDict (50-58) ===")
    test_dict_construction()
    print("[50/62] PASSED: dict_construction")
    test_dict_get_proxy_creates_new()
    print("[51/62] PASSED: dict_get_proxy_creates_new")
    test_dict_get_proxy_returns_existing()
    print("[52/62] PASSED: dict_get_proxy_returns_existing")
    test_dict_set_positions()
    print("[53/62] PASSED: dict_set_positions")
    test_dict_keys()
    print("[54/62] PASSED: dict_keys")
    test_dict_contains_false()
    print("[55/62] PASSED: dict_contains_false")
    test_dict_items_iteration()
    print("[56/62] PASSED: dict_items_iteration")
    test_dict_multiple_proxies()
    print("[57/62] PASSED: dict_multiple_proxies")
    test_dict_copy_constructor()
    print("[58/62] PASSED: dict_copy_constructor")

    print("\n=== Testing Queue Integration (59-61) ===")
    test_queue_initialized_on_create()
    print("[59/62] PASSED: queue_initialized_on_create")
    test_queue_after_open_trade()
    print("[60/62] PASSED: queue_after_open_trade")
    test_queue_after_close_trade()
    print("[61/62] PASSED: queue_after_close_trade")

    print("\n=== Testing HashKey (62) ===")
    test_hash_key_consistent()
    print("[62/62] PASSED: hash_key_consistent")
    test_hash_key_different()
    print("[63/63] PASSED: hash_key_different")

    print("\n=== All 63 tests passed! ===")
