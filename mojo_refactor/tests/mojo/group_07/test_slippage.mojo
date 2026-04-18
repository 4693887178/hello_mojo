"""
Test for mod/rqmojo_mod_sys_simulation/slippage.mojo
Group 07 - Slippage Models

Tests cover all slippage models ported from rqalpha:
  - PriceRatioSlippage: rate-based slippage with limit price clamping
  - TickSizeSlippage: tick-size-based slippage
  - LimitPriceSlippage: limit order price slippage
  - SlippageDecider: dispatcher for slippage models
  - is_valid_price: NaN/invalid price detection
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import (
    SlippageModel,
    SlippageDecider,
    PriceRatioSlippage,
    TickSizeSlippage,
    LimitPriceSlippage,
    create_slippage_decider,
    create_price_ratio_slippage,
    create_tick_size_slippage,
    create_limit_price_slippage,
    is_valid_price,
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def assert_approx_equal(actual: Float64, expected: Float64, tolerance: Float64 = 1e-9) raises:
    var diff = actual - expected
    if diff < 0.0:
        diff = -diff
    assert_true(diff < tolerance, "Expected approximately " + String(expected) + " but got " + String(actual))


def create_buy_order() -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


def create_sell_order() -> Order:
    return create_order_with_id(
        order_id=2,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )


def create_exercise_order() -> Order:
    return create_order_with_id(
        order_id=3,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.EXERCISE
    )


def create_limit_buy_order(price: Float64 = 10.0) -> Order:
    return create_order_with_id(
        order_id=4,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.OPEN
    )


def create_limit_sell_order(price: Float64 = 10.0) -> Order:
    return create_order_with_id(
        order_id=5,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.CLOSE
    )


# ============================================================
# is_valid_price tests
# ============================================================

def test_is_valid_price_positive() raises:
    assert_true(is_valid_price(10.0))

def test_is_valid_price_small_positive() raises:
    assert_true(is_valid_price(0.001))

def test_is_valid_price_zero() raises:
    assert_false(is_valid_price(0.0))

def test_is_valid_price_negative() raises:
    assert_false(is_valid_price(-1.0))


# ============================================================
# PriceRatioSlippage tests
# ============================================================

def test_price_ratio_init_valid_rate() raises:
    var slippage = PriceRatioSlippage(rate=0.01)
    assert_equal(slippage.rate, 0.01)

def test_price_ratio_init_zero_rate() raises:
    var slippage = PriceRatioSlippage(rate=0.0)
    assert_equal(slippage.rate, 0.0)

def test_price_ratio_init_near_one_rate() raises:
    var slippage = PriceRatioSlippage(rate=0.999)
    assert_approx_equal(slippage.rate, 0.999)

def test_price_ratio_init_invalid_rate_negative() raises:
    with assert_raises():
        var _ = PriceRatioSlippage(rate=-0.01)

def test_price_ratio_init_invalid_rate_one() raises:
    with assert_raises():
        var _ = PriceRatioSlippage(rate=1.0)

def test_price_ratio_init_invalid_rate_above_one() raises:
    with assert_raises():
        var _ = PriceRatioSlippage(rate=1.5)

def test_price_ratio_buy_increases_price() raises:
    var slippage = PriceRatioSlippage(rate=0.01)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_true(result > 10.0)

def test_price_ratio_sell_decreases_price() raises:
    var slippage = PriceRatioSlippage(rate=0.01)
    var order = create_sell_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_true(result < 10.0)

def test_price_ratio_exercise_raises() raises:
    var slippage = PriceRatioSlippage(rate=0.01)
    var order = create_exercise_order()
    with assert_raises():
        _ = slippage.get_trade_price(order, 10.0)

def test_price_ratio_zero_rate_no_change() raises:
    var slippage = PriceRatioSlippage(rate=0.0)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 10.0)

def test_price_ratio_buy_exact_calculation() raises:
    var slippage = PriceRatioSlippage(rate=0.02)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_approx_equal(result, 10.2)

def test_price_ratio_sell_exact_calculation() raises:
    var slippage = PriceRatioSlippage(rate=0.02)
    var order = create_sell_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_approx_equal(result, 9.8)

def test_price_ratio_limit_up_clamp() raises:
    var slippage = PriceRatioSlippage(rate=0.5)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 11.0)

def test_price_ratio_limit_down_clamp() raises:
    var slippage = PriceRatioSlippage(rate=0.5)
    var order = create_sell_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 9.0)

def test_price_ratio_no_clamp_within_limits() raises:
    var slippage = PriceRatioSlippage(rate=0.01)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_true(result < 11.0)
    assert_true(result > 9.0)


# ============================================================
# TickSizeSlippage tests
# ============================================================

def test_tick_size_init_valid_rate() raises:
    var slippage = TickSizeSlippage(rate=2.0)
    assert_equal(slippage.rate, 2.0)

def test_tick_size_init_zero_rate() raises:
    var slippage = TickSizeSlippage(rate=0.0)
    assert_equal(slippage.rate, 0.0)

def test_tick_size_init_large_rate() raises:
    var slippage = TickSizeSlippage(rate=100.0)
    assert_equal(slippage.rate, 100.0)

def test_tick_size_init_invalid_rate() raises:
    with assert_raises():
        var _ = TickSizeSlippage(rate=-1.0)

def test_tick_size_buy_increases_price() raises:
    var slippage = TickSizeSlippage(rate=1.0)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_approx_equal(result, 10.01)

def test_tick_size_sell_decreases_price() raises:
    var slippage = TickSizeSlippage(rate=1.0)
    var order = create_sell_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_approx_equal(result, 9.99)

def test_tick_size_exercise_raises() raises:
    var slippage = TickSizeSlippage(rate=1.0)
    var order = create_exercise_order()
    with assert_raises():
        _ = slippage.get_trade_price(order, 10.0)

def test_tick_size_zero_rate_no_change() raises:
    var slippage = TickSizeSlippage(rate=0.0)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 10.0)

def test_tick_size_multiple_ticks() raises:
    var slippage = TickSizeSlippage(rate=5.0)
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_approx_equal(result, 10.05)

def test_tick_size_sell_multiple_ticks() raises:
    var slippage = TickSizeSlippage(rate=5.0)
    var order = create_sell_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_approx_equal(result, 9.95)


# ============================================================
# LimitPriceSlippage tests
# ============================================================

def test_limit_price_limit_order_returns_order_price() raises:
    var slippage = LimitPriceSlippage()
    var order = create_limit_buy_order(10.0)
    var result = slippage.get_trade_price(order, 12.0)
    assert_equal(result, 10.0)

def test_limit_price_market_order_returns_input_price() raises:
    var slippage = LimitPriceSlippage()
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 12.0)
    assert_equal(result, 12.0)

def test_limit_price_limit_sell_order() raises:
    var slippage = LimitPriceSlippage()
    var order = create_limit_sell_order(9.5)
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 9.5)

def test_limit_price_market_sell_order() raises:
    var slippage = LimitPriceSlippage()
    var order = create_sell_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 10.0)


# ============================================================
# SlippageDecider tests
# ============================================================

def test_decider_price_ratio() raises:
    var decider = SlippageDecider(module_name="PriceRatioSlippage", rate=0.01)
    var order = create_buy_order()
    var result = decider.get_trade_price(order, 10.0)
    assert_true(result > 10.0)

def test_decider_tick_size() raises:
    var decider = SlippageDecider(module_name="TickSizeSlippage", rate=1.0)
    var order = create_buy_order()
    var result = decider.get_trade_price(order, 10.0)
    assert_approx_equal(result, 10.01)

def test_decider_limit_price() raises:
    var decider = SlippageDecider(module_name="LimitPriceSlippage", rate=0.0)
    var order = create_limit_buy_order(10.0)
    var result = decider.get_trade_price(order, 12.0)
    assert_equal(result, 10.0)

def test_decider_invalid_model_raises() raises:
    with assert_raises():
        var _ = SlippageDecider(module_name="InvalidModel", rate=0.01)

def test_decider_price_ratio_exercise_raises() raises:
    var decider = SlippageDecider(module_name="PriceRatioSlippage", rate=0.01)
    var order = create_exercise_order()
    with assert_raises():
        _ = decider.get_trade_price(order, 10.0)

def test_decider_tick_size_exercise_raises() raises:
    var decider = SlippageDecider(module_name="TickSizeSlippage", rate=1.0)
    var order = create_exercise_order()
    with assert_raises():
        _ = decider.get_trade_price(order, 10.0)

def test_decider_price_ratio_limit_up_clamp() raises:
    var decider = SlippageDecider(module_name="PriceRatioSlippage", rate=0.5)
    var order = create_buy_order()
    var result = decider.get_trade_price(order, 10.0)
    assert_equal(result, 11.0)

def test_decider_price_ratio_limit_down_clamp() raises:
    var decider = SlippageDecider(module_name="PriceRatioSlippage", rate=0.5)
    var order = create_sell_order()
    var result = decider.get_trade_price(order, 10.0)
    assert_equal(result, 9.0)

def test_decider_limit_price_market_order() raises:
    var decider = SlippageDecider(module_name="LimitPriceSlippage", rate=0.0)
    var order = create_buy_order()
    var result = decider.get_trade_price(order, 10.0)
    assert_equal(result, 10.0)


# ============================================================
# Factory function tests
# ============================================================

def test_create_price_ratio_slippage() raises:
    var slippage = create_price_ratio_slippage(rate=0.01)
    assert_equal(slippage.rate, 0.01)

def test_create_tick_size_slippage() raises:
    var slippage = create_tick_size_slippage(rate=2.0)
    assert_equal(slippage.rate, 2.0)

def test_create_limit_price_slippage() raises:
    var slippage = create_limit_price_slippage()
    var order = create_buy_order()
    var result = slippage.get_trade_price(order, 10.0)
    assert_equal(result, 10.0)

def test_create_slippage_decider() raises:
    var decider = create_slippage_decider(module_name="PriceRatioSlippage", rate=0.01)
    var order = create_buy_order()
    var result = decider.get_trade_price(order, 10.0)
    assert_true(result > 10.0)


# ============================================================
# Cross-model consistency tests
# ============================================================

def test_price_ratio_and_decider_consistent() raises:
    var slippage = PriceRatioSlippage(rate=0.02)
    var decider = SlippageDecider(module_name="PriceRatioSlippage", rate=0.02)
    var order = create_buy_order()
    var result1 = slippage.get_trade_price(order, 10.0)
    var result2 = decider.get_trade_price(order, 10.0)
    assert_approx_equal(result1, result2)

def test_tick_size_and_decider_consistent() raises:
    var slippage = TickSizeSlippage(rate=3.0)
    var decider = SlippageDecider(module_name="TickSizeSlippage", rate=3.0)
    var order = create_buy_order()
    var result1 = slippage.get_trade_price(order, 10.0)
    var result2 = decider.get_trade_price(order, 10.0)
    assert_approx_equal(result1, result2)

def test_limit_price_and_decider_consistent() raises:
    var slippage = LimitPriceSlippage()
    var decider = SlippageDecider(module_name="LimitPriceSlippage", rate=0.0)
    var order = create_limit_buy_order(10.0)
    var result1 = slippage.get_trade_price(order, 12.0)
    var result2 = decider.get_trade_price(order, 12.0)
    assert_equal(result1, result2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
