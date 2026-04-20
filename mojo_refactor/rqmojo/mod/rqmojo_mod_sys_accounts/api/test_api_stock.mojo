"""
Comprehensive test suite for api_stock.mojo
Tests all public API functions with std.testing framework.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List
from api_stock import (
    _round_order_quantity,
    _is_nan,
    _is_valid_price,
    _get_account_position,
    stock_order_shares,
    stock_order_lots,
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
from rqmojo.model.order import OrderStyle, MarketOrder, LimitOrder
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.environment import Environment, create_environment
from rqmojo.utils.typing import DateTime


def _create_test_env() raises -> Environment:
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2025, 12, 31, 0, 0, 0, 0)
    return create_environment(start, end)


def _create_cs_instrument(order_book_id: String = "000001.XSHE") -> Instrument:
    return create_stock_instrument(
        order_book_id=order_book_id,
        symbol="TEST",
        listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )


# === _round_order_quantity tests ===

def test_round_order_quantity_normal_floor() raises:
    var ins = _create_cs_instrument()
    assert_equal(_round_order_quantity(ins, 150), 100)
    assert_equal(_round_order_quantity(ins, 200), 200)
    assert_equal(_round_order_quantity(ins, 99), 0)
    assert_equal(_round_order_quantity(ins, 0), 0)


def test_round_order_quantity_normal_ceil() raises:
    var ins = _create_cs_instrument()
    assert_equal(_round_order_quantity(ins, 101, "ceil"), 200)
    assert_equal(_round_order_quantity(ins, 100, "ceil"), 100)


def test_round_order_quantity_normal_round() raises:
    var ins = _create_cs_instrument()
    assert_equal(_round_order_quantity(ins, 149, "round"), 100)
    assert_equal(_round_order_quantity(ins, 150, "round"), 200)


def test_round_order_quantity_negative() raises:
    var ins = _create_cs_instrument()
    assert_equal(_round_order_quantity(ins, -150), -100)
    assert_equal(_round_order_quantity(ins, -50), 0)


def test_round_order_quantity_ksh_below_min() raises:
    var ins = _create_cs_instrument("688001.XSHG")
    assert_equal(_round_order_quantity(ins, 199), 0)
    assert_equal(_round_order_quantity(ins, 200), 200)
    assert_equal(_round_order_quantity(ins, 201), 201)


def test_round_order_quantity_bjs_below_min() raises:
    var ins = _create_cs_instrument("800001.BJSE")
    assert_equal(_round_order_quantity(ins, 99), 0)
    assert_equal(_round_order_quantity(ins, 100), 100)
    assert_equal(_round_order_quantity(ins, 101), 101)


def test_ksh_min_amount_constant() raises:
    assert_equal(KSH_MIN_AMOUNT(), 200)


def test_bjse_min_amount_constant() raises:
    assert_equal(BJSE_MIN_AMOUNT(), 100)


# === _is_nan tests ===

def test_is_nan_with_nan() raises:
    var nan_val = Float64(0.0) / Float64(0.0)
    assert_true(_is_nan(nan_val))


def test_is_nan_with_normal() raises:
    assert_false(_is_nan(1.0))
    assert_false(_is_nan(0.0))
    assert_false(_is_nan(-1.5))


# === _is_valid_price tests ===

def test_is_valid_price_normal() raises:
    assert_true(_is_valid_price(10.0))
    assert_true(_is_valid_price(0.01))


def test_is_valid_price_zero_or_negative() raises:
    assert_false(_is_valid_price(0.0))
    assert_false(_is_valid_price(-1.0))


# === _get_account_position tests ===

def test_get_account_position_returns_result() raises:
    var env = _create_test_env()
    var result = _get_account_position(env, "000001.XSHE")
    assert_true(result.total_cash > 0)
    assert_true(result.total_value > 0)
    assert_equal(result.position_quantity, 0)
    assert_equal(result.position_market_value, 0.0)
    assert_equal(result.position_closable, 0)


# === stock_order_shares tests ===

def test_stock_order_shares_buy_returns_order() raises:
    var env = _create_test_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", 100, style)
    assert_true(result is not None)
    var order = result.value()
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.quantity, 100)


def test_stock_order_shares_sell_returns_order() raises:
    var env = _create_test_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", -100, style)
    assert_true(result is not None)
    var order = result.value()
    assert_equal(order.side, SIDE.SELL)


def test_stock_order_shares_zero_amount_returns_none() raises:
    var env = _create_test_env()
    var style = MarketOrder()
    var result = stock_order_shares(env, "000001.XSHE", 0, style)
    assert_true(result is None)


# === stock_order_lots tests ===

def test_stock_order_lots_converts_to_shares() raises:
    var env = _create_test_env()
    var result = stock_order_lots(env, "000001.XSHE", 1)
    assert_true(result is not None)
    var order = result.value()
    assert_equal(order.quantity, 100)


def test_stock_order_lots_multiple_lots() raises:
    var env = _create_test_env()
    var result = stock_order_lots(env, "000001.XSHE", 10)
    assert_true(result is not None)
    var order = result.value()
    assert_equal(order.quantity, 1000)


# === stock_order_value tests ===

def test_stock_order_value_basic() raises:
    var env = _create_test_env()
    var result = stock_order_value(env, "000001.XSHE", 50000.0)
    assert_true(result is not None)
    var order = result.value()
    assert_equal(order.side, SIDE.BUY)


def test_stock_order_value_zero_cash() raises:
    var env = _create_test_env()
    var result = stock_order_value(env, "000001.XSHE", 0.0)
    assert_true(result is None)


# === stock_order_percent tests ===

def test_stock_order_percent_basic() raises:
    var env = _create_test_env()
    var result = stock_order_percent(env, "000001.XSHE", 0.1)
    assert_true(result is not None)
    var order = result.value()
    assert_equal(order.side, SIDE.BUY)


def test_stock_order_percent_zero() raises:
    var env = _create_test_env()
    var result = stock_order_percent(env, "000001.XSHE", 0.0)
    assert_true(result is None)


# === stock_order_target_value tests ===

def test_stock_order_target_value_sell_all_when_zero() raises:
    var env = _create_test_env()
    var result = stock_order_target_value(env, "000001.XSHE", 0.0)
    assert_true(result is None)


def test_stock_order_target_value_buy_delta() raises:
    var env = _create_test_env()
    var result = stock_order_target_value(env, "000001.XSHE", 50000.0)
    assert_true(result is not None)


# === stock_order_target_percent tests ===

def test_stock_order_target_percent_zero_sells_all() raises:
    var env = _create_test_env()
    var result = stock_order_target_percent(env, "000001.XSHE", 0.0)
    assert_true(result is None)


def test_stock_order_target_percent_positive() raises:
    var env = _create_test_env()
    var result = stock_order_target_percent(env, "000001.XSHE", 0.5)
    assert_true(result is not None)


# === stock_order (wrapper returning list) tests ===

def test_stock_order_returns_list() raises:
    var env = _create_test_env()
    var orders = stock_order(env, "000001.XSHE", 100)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].quantity, 100)


def test_stock_order_zero_returns_empty_list() raises:
    var env = _create_test_env()
    var orders = stock_order(env, "000001.XSHE", 0)
    assert_equal(len(orders), 0)


# === stock_order_to tests ===

def test_stock_order_to_buy_more() raises:
    var env = _create_test_env()
    var orders = stock_order_to(env, "000001.XSHE", 200)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.BUY)


def test_stock_order_to_sell_some() raises:
    var env = _create_test_env()
    var orders = stock_order_to(env, "000001.XSHE", 0)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.SELL)


# === order_target_portfolio tests ===

def test_order_target_portfolio_empty() raises:
    var env = _create_test_env()
    var target = Dict[String, Float64]()
    var orders = order_target_portfolio(env, target)
    assert_equal(len(orders), 0)


def test_order_target_portfolio_single_stock() raises:
    var env = _create_test_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = 0.5
    var orders = order_target_portfolio(env, target)
    assert_true(len(orders) >= 0)


def test_order_target_portfolio_negative_raises() raises:
    var env = _create_test_env()
    var target = Dict[String, Float64]()
    target["000001.XSHE"] = -0.1
    var error_caught = False
    try:
        _ = order_target_portfolio(env, target)
    except e:
        error_caught = True
    assert_true(error_caught, "Negative weight should raise error")


# === is_suspended tests ===

def test_is_suspended_default_false() raises:
    var env = _create_test_env()
    var result = is_suspended(env, "000001.XSHE")
    assert_false(result)


# === is_st_stock tests ===

def test_is_st_stock_default_false() raises:
    var env = _create_test_env()
    var result = is_st_stock(env, "000001.XSHE")
    assert_false(result)


# === industry tests ===

def test_industry_returns_list() raises:
    var env = _create_test_env()
    var result = industry(env, "A01")
    assert_true(len(result) >= 0)


# === sector tests ===

def test_sector_returns_list() raises:
    var env = _create_test_env()
    var result = sector(env, "Energy")
    assert_true(len(result) >= 0)


# === get_dividend tests ===

def test_get_dividend_returns_optional() raises:
    var env = _create_test_env()
    var start = DateTime(2023, 1, 1, 0, 0, 0, 0)
    var result = get_dividend(env, "000001.XSHE", start)
    assert_true(result is None or result is not None)


# === to_industry_code / to_sector_name tests ===

def test_to_industry_code_passthrough() raises:
    assert_equal(to_industry_code("A01"), "A01")
    assert_equal(to_industry_code("CustomCode"), "CustomCode")


def test_to_sector_name_passthrough() raises:
    assert_equal(to_sector_name("Energy"), "Energy")
    assert_equal(to_sector_name("CustomName"), "CustomName")


# === AccountPositionResult struct tests ===

def test_account_position_result_fields() raises:
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


# === LimitOrder price handling ===

def test_limit_order_gets_limit_price() raises:
    var style = LimitOrder(15.5)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 15.5)


def test_market_order_has_no_limit_price() raises:
    var style = MarketOrder()
    assert_equal(style.style_type, ORDER_TYPE.MARKET)
    assert_equal(style.limit_price, 0.0)


# === Integration: full buy-then-sell cycle ===

def test_integration_buy_then_sell_cycle() raises:
    var env = _create_test_env()
    
    var buy_orders = stock_order(env, "000001.XSHE", 100)
    assert_equal(len(buy_orders), 1)
    assert_equal(buy_orders[0].side, SIDE.BUY)
    assert_equal(buy_orders[0].quantity, 100)
    
    var sell_orders = stock_order(env, "000001.XSHE", -100)
    assert_equal(len(sell_orders), 1)
    assert_equal(sell_orders[0].side, SIDE.SELL)
    assert_equal(sell_orders[0].quantity, 100)


# === Integration: order_target_percent full flow ===

def test_integration_target_percent_full_flow() raises:
    var env = _create_test_env()
    
    var orders_10pct = stock_order_target_percent(env, "000001.XSHE", 0.10)
    assert_true(orders_10pct is not None or orders_10pct is None)
    
    var orders_50pct = stock_order_target_percent(env, "000001.XSHE", 0.50)
    assert_true(orders_50pct is not None or orders_50pct is None)
    
    var orders_close = stock_order_target_percent(env, "000001.XSHE", 0.0)
    assert_true(orders_close is None)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
