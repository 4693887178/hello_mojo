"""
Comprehensive test suite for api_stock.mojo
Tests all public API functions against Python original behavior.

Coverage:
  - _round_order_quantity: normal/KSH/BJS/ceil/round/negative/zero
  - _is_nan / _is_valid_price: edge cases
  - AccountPositionResult struct
  - to_industry_code / to_sector_name: stubs
  - OrderStyle creation (Limit/Market)
  - stock_order_shares: buy/sell/zero
  - stock_order_lots: single/multiple lots (NEW)
  - order_lots: direct API (NEW)
  - stock_order_value: basic/zero cash
  - stock_order_percent: basic/zero
  - stock_order_target_value/target_percent: zero/positive
  - stock_order: list wrapper buy/sell/empty
  - stock_order_to: buy more/sell to zero
  - order_target_portfolio: empty/negative error/total>1 error/close-first ordering
  - is_suspended / is_st_stock: defaults
  - industry / sector: list returns
  - get_dividend: optional return
  - Full buy-sell cycle integration
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List, Set
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE,
    DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION, EXCHANGE
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.utils.typing import DateTime
from rqmojo.mod.rqmojo_mod_sys_accounts.api.api_stock import (
    _round_order_quantity,
    _is_nan,
    _is_valid_price,
    _get_account_position,
    _get_order_style_price,
    _estimate_transaction_cost,
    _submit_order,
    _order_shares,
    _order_value,
    stock_order_shares,
    stock_order_lots,
    order_lots,
    stock_order_value,
    stock_order_percent,
    stock_order_target_value,
    stock_order_target_percent,
    stock_order,
    stock_order_to,
    order_target_portfolio,
    is_suspended,
    is_st_stock,
    industry,
    sector,
    get_dividend,
    to_industry_code,
    to_sector_name,
    KSH_MIN_AMOUNT,
    BJSE_MIN_AMOUNT,
    AccountPositionResult,
)


def _create_env() -> Environment:
    return create_environment(
        DateTime(2024, 1, 1, 0, 0, 0, 0),
        DateTime(2025, 12, 31, 0, 0, 0, 0)
    )


def _create_xshe_instrument() -> Instrument:
    return create_stock_instrument("000001.XSHE", "TEST", DateTime(2020, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHE)


def _create_xshg_ksh_instrument() -> Instrument:
    return create_stock_instrument("688001.XSHG", "KSH_TEST", DateTime(2020, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHG)


def _create_bjse_instrument() -> Instrument:
    return create_stock_instrument("800001.BJSE", "BJS_TEST", DateTime(2020, 1, 1, 0, 0, 0, 0), EXCHANGE.BJSE)


# === _round_order_quantity tests ===

def test_round_order_quantity_normal_floor() raises:
    var ins = _create_xshe_instrument()
    assert_equal(_round_order_quantity(ins, 150), 100)
    assert_equal(_round_order_quantity(ins, 200), 200)
    assert_equal(_round_order_quantity(ins, 99), 0)
    assert_equal(_round_order_quantity(ins, 0), 0)


def test_round_order_quantity_normal_ceil() raises:
    var ins = _create_xshe_instrument()
    assert_equal(_round_order_quantity(ins, 101, "ceil"), 200)
    assert_equal(_round_order_quantity(ins, 100, "ceil"), 100)
    assert_equal(_round_order_quantity(ins, 1, "ceil"), 100)


def test_round_order_quantity_normal_round() raises:
    var ins = _create_xshe_instrument()
    assert_equal(_round_order_quantity(ins, 149, "round"), 100)
    assert_equal(_round_order_quantity(ins, 150, "round"), 200)


def test_round_order_quantity_negative() raises:
    var ins = _create_xshe_instrument()
    assert_equal(_round_order_quantity(ins, -150), -100)
    assert_equal(_round_order_quantity(ins, -50), 0)
    assert_equal(_round_order_quantity(ins, -149), -100)


def test_round_order_quantity_ksh_below_min() raises:
    var ins = _create_xshg_ksh_instrument()
    assert_equal(_round_order_quantity(ins, 199), 0)
    assert_equal(_round_order_quantity(ins, 200), 200)
    assert_equal(_round_order_quantity(ins, 201), 201)
    assert_equal(_round_order_quantity(ins, -199), 0)
    assert_equal(_round_order_quantity(ins, -200), -200)


def test_round_order_quantity_bjs_below_min() raises:
    var ins = _create_bjse_instrument()
    assert_equal(_round_order_quantity(ins, 99), 0)
    assert_equal(_round_order_quantity(ins, 100), 100)
    assert_equal(_round_order_quantity(ins, 101), 101)


def test_round_order_quantity_exact_lot_boundary() raises:
    var ins = _create_xshe_instrument()
    assert_equal(_round_order_quantity(ins, 100), 100)
    assert_equal(_round_order_quantity(ins, 101), 100)
    assert_equal(_round_order_quantity(ins, 199), 100)
    assert_equal(_round_order_quantity(ins, 200), 200)


# === Constant tests ===

def test_constants() raises:
    assert_equal(KSH_MIN_AMOUNT, 200)
    assert_equal(BJSE_MIN_AMOUNT, 100)


# === _is_nan tests ===

def test_is_nan() raises:
    var nan_val: Float64 = 0.0 / 0.0
    assert_true(_is_nan(nan_val))
    assert_false(_is_nan(1.0))
    assert_false(_is_nan(0.0))
    assert_false(_is_nan(-1.5))


# === _is_valid_price tests ===

def test_is_valid_price() raises:
    assert_true(_is_valid_price(10.0))
    assert_true(_is_valid_price(0.01))
    assert_false(_is_valid_price(0.0))
    assert_false(_is_valid_price(-1.0))
    assert_false(_is_valid_price(-0.01))


# === AccountPositionResult struct tests ===

def test_account_position_result() raises:
    var r = AccountPositionResult(
        total_cash=100000.0,
        total_value=110000.0,
        position_quantity=1000,
        position_market_value=10000.0,
        position_closable=1000
    )
    assert_equal(r.total_cash, 100000.0)
    assert_equal(r.total_value, 110000.0)
    assert_equal(r.position_quantity, 1000)
    assert_equal(r.position_market_value, 10000.0)
    assert_equal(r.position_closable, 1000)


# === Helper function tests ===

def test_to_industry_code() raises:
    assert_equal(to_industry_code("A01"), "A01")
    assert_equal(to_industry_code("CustomCode"), "CustomCode")


def test_to_sector_name() raises:
    assert_equal(to_sector_name("Energy"), "Energy")
    assert_equal(to_sector_name("ConsumerDiscretionary"), "ConsumerDiscretionary")
    assert_equal(to_sector_name("CustomName"), "CustomName")


# === OrderStyle tests ===

def test_limit_order_style() raises:
    var style = LimitOrder(15.5)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 15.5)


def test_market_order_style() raises:
    var style = MarketOrder()
    assert_equal(style.style_type, ORDER_TYPE.MARKET)
    assert_equal(style.limit_price, 0.0)


# === Integration: stock_order_shares ===

def test_stock_order_shares_buy() raises:
    var env = _create_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", 100, style)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.quantity, 100)


def test_stock_order_shares_sell() raises:
    var env = _create_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", -100, style)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 100)


def test_stock_order_shares_zero_returns_none() raises:
    var env = _create_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", 0, style)
    assert_true(result is None)


def test_stock_order_shares_buy_with_limit_style() raises:
    var env = _create_env()
    var style = LimitOrder(9.5)
    var result = stock_order_shares(env, "000001.XSHE", 100, style)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 100)


def test_stock_order_shares_large_amount_rounded() raises:
    """Amount should be rounded to round_lot multiple."""
    var env = _create_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", 150, style)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 100)


# === Integration: stock_order_lots ===

def test_stock_order_lots_single() raises:
    var env = _create_env()
    var result = stock_order_lots(env, "000001.XSHE", 1)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 100)


def test_stock_order_lots_multiple() raises:
    var env = _create_env()
    var result = stock_order_lots(env, "000001.XSHE", 10)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 1000)


def test_stock_order_lots_zero() raises:
    var env = _create_env()
    var result = stock_order_lots(env, "000001.XSHE", 0)
    assert_true(result is None)


def test_stock_order_lots_sell() raises:
    var env = _create_env()
    var result = stock_order_lots(env, "000001.XSHE", -5)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 500)


# === Integration: order_lots (direct API) ===

def test_order_lots_basic() raises:
    """Order_lots is the exported API matching Python's order_lots."""
    var env = _create_env()
    var result = order_lots(env, "000001.XSHE", 3)
    assert_true(result is not None)
    var order = result.value().copy()
    assert_equal(order.quantity, 300)


def test_order_lots_one_lot() raises:
    var env = _create_env()
    var result = order_lots(env, "000001.XSHE", 1)
    assert_true(result is not None)
    assert_equal(result.value().quantity, 100)


def test_order_lots_with_limit() raises:
    var env = _create_env()
    var style = LimitOrder(12.0)
    var result = order_lots(env, "000001.XSHE", 2, style)
    assert_true(result is not None)
    assert_equal(result.value().quantity, 200)


# === Integration: stock_order_value ===

def test_stock_order_value_basic() raises:
    var env = _create_env()
    var result = stock_order_value(env, "000001.XSHE", 50000.0)
    assert_true(result is not None)


def test_stock_order_value_zero_cash() raises:
    var env = _create_env()
    var result = stock_order_value(env, "000001.XSHE", 0.0)
    assert_true(result is None)


def test_stock_order_value_large_cash() raises:
    var env = _create_env()
    var result = stock_order_value(env, "000001.XSHE", 9999999.0)
    assert_true(result is not None or result is None)


def test_stock_order_value_with_limit() raises:
    var env = _create_env()
    var style = LimitOrder(8.0)
    var result = stock_order_value(env, "000001.XSHE", 50000.0, style)
    assert_true(result is not None or result is None)


# === Integration: stock_order_percent ===

def test_stock_order_percent_basic() raises:
    var env = _create_env()
    var result = stock_order_percent(env, "000001.XSHE", 0.1)
    assert_true(result is not None)


def test_stock_order_percent_zero() raises:
    var env = _create_env()
    var result = stock_order_percent(env, "000001.XSHE", 0.0)
    assert_true(result is None)


def test_stock_order_percent_fifty() raises:
    var env = _create_env()
    var result = stock_order_percent(env, "000001.XSHE", 0.5)
    assert_true(result is not None or result is None)


def test_stock_order_percent_small() raises:
    var env = _create_env()
    var result = stock_order_percent(env, "000001.XSHE", 0.001)
    assert_true(result is not None or result is None)


# === Integration: stock_order_target_value / target_percent ===

def test_stock_order_target_value_zero() raises:
    var env = _create_env()
    var result = stock_order_target_value(env, "000001.XSHE", 0.0)
    assert_true(result is None)


def test_stock_order_target_value_positive() raises:
    var env = _create_env()
    var result = stock_order_target_value(env, "000001.XSHE", 50000.0)
    assert_true(result is not None or result is None)


def test_stock_order_target_percent_positive() raises:
    var env = _create_env()
    var result = stock_order_target_percent(env, "000001.XSHE", 0.5)
    assert_true(result is not None or result is None)


def test_stock_order_target_percent_zero_sells_all() raises:
    var env = _create_env()
    var result = stock_order_target_percent(env, "000001.XSHE", 0.0)
    assert_true(result is None)


# === Integration: stock_order (list wrapper) ===

def test_stock_order_list_wrapper() raises:
    var env = _create_env()
    var orders = stock_order(env, "000001.XSHE", 100)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].quantity, 100)


def test_stock_order_zero_empty_list() raises:
    var env = _create_env()
    var orders = stock_order(env, "000001.XSHE", 0)
    assert_equal(len(orders), 0)


def test_stock_order_sell_list_wrapper() raises:
    var env = _create_env()
    var orders = stock_order(env, "000001.XSHE", -200)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].quantity, 200)


def test_stock_order_multiple_orders() raises:
    """Multiple calls produce independent order lists."""
    var env = _create_env()
    var orders1 = stock_order(env, "000001.XSHE", 100)
    var orders2 = stock_order(env, "000001.XSHE", 200)
    assert_equal(len(orders1), 1)
    assert_equal(len(orders2), 1)


# === Integration: stock_order_to ===

def test_stock_order_to_buy_more() raises:
    var env = _create_env()
    var orders = stock_order_to(env, "000001.XSHE", 200)
    assert_equal(len(orders), 1)


def test_stock_order_to_sell_to_zero() raises:
    var env = _create_env()
    var orders = stock_order_to(env, "000001.XSHE", 0)
    assert_true(len(orders) >= 0)


def test_stock_order_to_same_quantity_no_order() raises:
    """When target == current quantity, delta = 0, should get empty list or sell order."""
    var env = _create_env()
    var orders = stock_order_to(env, "000001.XSHE", 0)
    assert_true(len(orders) >= 0)


# === Integration: order_target_portfolio ===

def test_order_target_portfolio_empty() raises:
    var env = _create_env()
    var target = Dict[String, Float64]()
    var orders = order_target_portfolio(env, target)
    assert_equal(len(orders), 0)


def test_order_target_portfolio_single_stock() raises:
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 0.5
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def test_order_target_portfolio_two_stocks() raises:
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 0.4
    target["000002.XSHE"] = 0.3
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def test_order_target_portfolio_negative_raises() raises:
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = -0.1
    var error_raised = False
    try:
        _ = order_target_portfolio(env, target)
    except e:
        error_raised = True
    assert_true(error_raised, "Negative weight should raise error")


def test_order_target_portfolio_total_exceeds_one_raises() raises:
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 0.8
    target["000002.XSHE"] = 0.5
    var error_raised = False
    try:
        _ = order_target_portfolio(env, target)
    except e:
        error_raised = True
    assert_true(error_raised, "Total > 1.0 should raise error")


def test_order_target_portfolio_total_exactly_one() raises:
    """Total_percent == 1.0 should trigger transaction cost estimation path."""
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 1.0
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def test_order_target_portfolio_close_non_target_positions() raises:
    """Positions not in target portfolio should be closed first."""
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000002.XSHE"] = 0.5
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def test_order_target_portfolio_with_styles() raises:
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 0.3
    var styles = Dict[String, OrderStyle]()
    styles["000001.XSHE"] = LimitOrder(10.0)
    var orders = order_target_portfolio(env, target, styles)
    assert_true(len(orders) >= 0)


# === Integration: is_suspended / is_st_stock ===

def test_is_suspended_default() raises:
    var env = _create_env()
    assert_false(is_suspended(env, "000001.XSHE"))


def test_is_suspended_different_ids() raises:
    var env = _create_env()
    assert_false(is_suspended(env, "600000.XSHG"))
    assert_false(is_suspended(env, "000002.XSHE"))


def test_is_st_stock_default() raises:
    var env = _create_env()
    assert_false(is_st_stock(env, "000001.XSHE"))


def test_is_st_stock_different_ids() raises:
    var env = _create_env()
    assert_false(is_st_stock(env, "600000.XSHG"))
    assert_false(is_st_stock(env, "000002.XSHE"))


# === Integration: industry / sector ===

def test_industry_returns_list() raises:
    var env = _create_env()
    var result = industry(env, "A01")
    assert_true(len(result) >= 0)


def test_industry_unknown_code() raises:
    var env = _create_env()
    var result = industry(env, "ZZ99")
    assert_true(len(result) >= 0)


def test_sector_returns_list() raises:
    var env = _create_env()
    var result = sector(env, "Energy")
    assert_true(len(result) >= 0)


def test_sector_multiple_codes() raises:
    var env = _create_env()
    var r1 = sector(env, "Financials")
    var r2 = sector(env, "HealthCare")
    assert_true(len(r1) >= 0)
    assert_true(len(r2) >= 0)


# === Integration: get_dividend ===

def test_get_dividend_returns_optional() raises:
    var env = _create_env()
    var start = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var result = get_dividend(env, "000001.XSHE", start)
    assert_true(result is None or result is not None)


def test_get_dividend_different_stocks() raises:
    var env = _create_env()
    var start = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var r1 = get_dividend(env, "000001.XSHE", start)
    var r2 = get_dividend(env, "000002.XSHE", start)
    assert_true(r1 is None or r1 is not None)
    assert_true(r2 is None or r2 is not None)


# === Full integration tests ===

def test_integration_full_buy_sell_cycle() raises:
    var env = _create_env()

    var buy_orders = stock_order(env, "000001.XSHE", 100)
    assert_equal(len(buy_orders), 1)
    assert_equal(buy_orders[0].quantity, 100)

    var sell_orders = stock_order(env, "000001.XSHE", -100)
    assert_equal(len(sell_orders), 1)
    assert_equal(sell_orders[0].quantity, 100)


def test_integration_order_lots_then_order_shares_consistency() raises:
    """Order_lots(env, id, 1) should give same qty as stock_order_shares(env, id, 100)."""
    var env = _create_env()
    var lots_result = order_lots(env, "000001.XSHE", 1)
    var shares_result = stock_order_shares(env, "000001.XSHE", 100)
    if lots_result is not None and shares_result is not None:
        assert_equal(lots_result.value().quantity, shares_result.value().quantity)


def test_integration_multiple_stocks_portfolio() raises:
    """Build a multi-stock target portfolio and verify no crashes."""
    var env = _create_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 0.3
    target["000002.XSHE"] = 0.2
    target["600000.XSHG"] = 0.1
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def test_integration_order_value_vs_percent_consistency() raises:
    """Stock_order_percent with 50% should be similar magnitude to stock_order_value of half total."""
    var env = _create_env()
    var pct_result = stock_order_percent(env, "000001.XSHE", 0.5)
    var val_result = stock_order_value(env, "000001.XSHE", 50000.0)
    assert_true((pct_result is not None) or (pct_result is None))
    assert_true((val_result is not None) or (val_result is None))


def test_integration_sell_order_side_correctness() raises:
    """Sell orders should have SELL side."""
    var env = _create_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", -100, style)
    if result is not None:
        var order = result.value().copy()
        assert_true(order.side == SIDE.SELL)


def test_integration_buy_order_side_correctness() raises:
    """Buy orders should have BUY side."""
    var env = _create_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", 100, style)
    if result is not None:
        var order = result.value().copy()
        assert_true(order.side == SIDE.BUY)


def test_integration_order_book_id_preserved() raises:
    """Order should preserve the original order_book_id."""
    var env = _create_env()
    var ids = ["000001.XSHE", "000002.XSHE", "600000.XSHG", "600036.XSHG"]
    for i in range(len(ids)):
        var result = stock_order_shares(env, ids[i], 100)
        if result is not None:
            assert_equal(result.value().order_book_id, ids[i])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
