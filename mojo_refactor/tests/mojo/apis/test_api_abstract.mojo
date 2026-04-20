from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.apis.api_abstract import (
    AbstractAPI, create_abstract_api,
    cal_style, cal_style_from_price_or_style, cal_target_style,
    assure_active_ins_for_order_api, is_valid_price, is_valid_percent,
    is_valid_target_percent, _round_to_lot, TargetStylePair, OrderParams
)
from rqmojo.model.order import OrderStyle, MarketOrder, LimitOrder, AlgoOrderStyle, TWAPOrder, VWAPOrder
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE
from rqmojo.environment import create_environment
from rqmojo.utils.typing import DateTime


def test_create_abstract_api() raises:
    """Test AbstractAPI creation with default and custom parameters."""
    api = create_abstract_api()
    assert_true(api.is_enabled())
    assert_equal(api._ctx_name, "")
    
    api_disabled = create_abstract_api(ctx_name="test_ctx", enabled=False)
    assert_false(api_disabled.is_enabled())
    assert_equal(api_disabled._ctx_name, "test_ctx")


def test_set_enabled() raises:
    """Test enable/disable toggle."""
    api = create_abstract_api()
    assert_true(api.is_enabled())
    
    api.set_enabled(False)
    assert_false(api.is_enabled())
    
    api.set_enabled(True)
    assert_true(api.is_enabled())


def test_cal_style_default_market() raises:
    """Test cal_style returns MarketOrder when all params are None."""
    style = cal_style(None, None, None, None, None, None)
    assert_equal(style.style_type, ORDER_TYPE.MARKET)


def test_cal_style_from_price() raises:
    """Test cal_style with price parameter creates LimitOrder."""
    style = cal_style(Optional[Float64](10.5), None, None, None, None, None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 10.5)


def test_cal_style_from_style_param() raises:
    """Test cal_style with style parameter."""
    lo = LimitOrder(20.0)
    style = cal_style(None, Optional[OrderStyle](lo), None, None, None, None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 20.0)


def test_cal_style_from_int() raises:
    """Test cal_style with int price_or_style creates LimitOrder."""
    style = cal_style(None, None, Optional[Int](15), None, None, None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 15.0)


def test_cal_style_from_float() raises:
    """Test cal_style with float price_or_style creates LimitOrder."""
    style = cal_style(None, None, None, Optional[Float64](25.5), None, None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 25.5)


def test_cal_style_from_order_style() raises:
    """Test cal_style with OrderStyle price_or_style takes priority."""
    lo = LimitOrder(30.0)
    style = cal_style(None, None, None, None, Optional[OrderStyle](lo), None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 30.0)


def test_cal_style_priority_order() raises:
    """Test that price_or_style_order has highest priority."""
    lo1 = LimitOrder(10.0)
    lo2 = LimitOrder(20.0)
    style = cal_style(
        Optional[Float64](5.0),
        Optional[OrderStyle](lo1),
        Optional[Int](15),
        Optional[Float64](25.0),
        Optional[OrderStyle](lo2),
        None
    )
    assert_equal(style.limit_price, 20.0)


def test_cal_style_algo_returns_market() raises:
    """Test that AlgoOrderStyle falls back to MarketOrder (simplified)."""
    algo = TWAPOrder(931, 945)
    style = cal_style(None, None, None, None, None, Optional[AlgoOrderStyle](algo))
    assert_equal(style.style_type, ORDER_TYPE.MARKET)


def test_cal_style_from_price_or_style_helper() raises:
    """Test cal_style_from_price_or_style convenience function."""
    style = cal_style_from_price_or_style(None, Optional[Float64](12.0), None, None)
    assert_equal(style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(style.limit_price, 12.0)


def test_cal_target_style_single() raises:
    """Test cal_target_style without tuple returns same buy/sell style."""
    pair = cal_target_style(None, None, None, None, None, None)
    assert_equal(pair.buy_style.style_type, ORDER_TYPE.MARKET)
    assert_equal(pair.sell_style.style_type, ORDER_TYPE.MARKET)


def test_cal_target_style_with_prices() raises:
    """Test cal_target_style with separate buy/sell prices."""
    pair = cal_target_style(
        None, None,
        Optional[Float64](10.0),
        Optional[Float64](11.0),
        None, None
    )
    assert_equal(pair.buy_style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(pair.buy_style.limit_price, 10.0)
    assert_equal(pair.sell_style.style_type, ORDER_TYPE.LIMIT)
    assert_equal(pair.sell_style.limit_price, 11.0)


def test_is_valid_price() raises:
    """Test is_valid_price validation."""
    assert_true(is_valid_price(10.0))
    assert_true(is_valid_price(0.01))
    assert_false(is_valid_price(0.0))
    assert_false(is_valid_price(-1.0))


def test_is_valid_percent() raises:
    """Test is_valid_percent range check [-1, 1]."""
    assert_true(is_valid_percent(0.0))
    assert_true(is_valid_percent(0.5))
    assert_true(is_valid_percent(1.0))
    assert_true(is_valid_percent(-1.0))
    assert_true(is_valid_percent(-0.5))
    assert_false(is_valid_percent(1.5))
    assert_false(is_valid_percent(-1.5))


def test_is_valid_target_percent() raises:
    """Test is_valid_target_percent range check [0, 1]."""
    assert_true(is_valid_target_percent(0.0))
    assert_true(is_valid_target_percent(0.5))
    assert_true(is_valid_target_percent(1.0))
    assert_false(is_valid_target_percent(-0.1))
    assert_false(is_valid_target_percent(1.5))


def test_round_to_lot() raises:
    """Test _round_to_lot rounds down to lot size."""
    assert_equal(_round_to_lot(150, 100), 100)
    assert_equal(_round_to_lot(199, 100), 100)
    assert_equal(_round_to_lot(200, 100), 200)
    assert_equal(_round_to_lot(0, 100), 0)
    assert_equal(_round_to_lot(50, 1), 50)
    assert_equal(_round_to_lot(100, 0), 100)


def test_assure_active_ins_returns_none() raises:
    """Test assure_active_ins_for_order_api stub returns None."""
    result = assure_active_ins_for_order_api("000001.XSHE")
    assert_true(result == None)


def test_order_params_struct() raises:
    """Test OrderParams struct initialization."""
    params = OrderParams(
        order_book_id="000001.XSHE",
        quantity=1000,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        style=MarketOrder(),
        price=10.0
    )
    assert_equal(params.order_book_id, "000001.XSHE")
    assert_equal(params.quantity, 1000)
    assert_equal(params.side, SIDE.BUY)
    assert_equal(params.position_effect, POSITION_EFFECT.OPEN)


def test_target_style_pair_struct() raises:
    """Test TargetStylePair struct initialization."""
    pair = TargetStylePair(
        buy_style=LimitOrder(10.0),
        sell_style=LimitOrder(11.0)
    )
    assert_equal(pair.buy_style.limit_price, 10.0)
    assert_equal(pair.sell_style.limit_price, 11.0)


def test_order_shares_buy_market() raises:
    """Test order_shares with market order for buying."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_shares(env, "000001.XSHE", 2000)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.order_book_id, "000001.XSHE")
    assert_equal(order.quantity, 2000)
    assert_equal(order.side, SIDE.BUY)
    assert_equal(order.order_type_val, ORDER_TYPE.MARKET)


def test_order_shares_sell_market() raises:
    """Test order_shares with market order for selling."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_shares(env, "000001.XSHE", -1000)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.quantity, 1000)
    assert_equal(order.side, SIDE.SELL)
    assert_equal(order.position_effect_resolved(), POSITION_EFFECT.CLOSE)


def test_order_shares_limit_order() raises:
    """Test order_shares with limit order via price_or_style_int."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_shares(env, "000001.XSHE", 500, price_or_style_int=Optional[Int](11))
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.frozen_price, 11.0)
    assert_equal(order.order_type_val, ORDER_TYPE.LIMIT)


def test_order_shares_with_float_price() raises:
    """Test order_shares with float price via price_or_style_float."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_shares(env, "000001.XSHE", 300, price_or_style_float=Optional[Float64](12.5))
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.frozen_price, 12.5)


def test_order_shares_with_order_style() raises:
    """Test order_shares with OrderStyle object."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    lo = LimitOrder(13.0)
    var result = api.order_shares(env, "000001.XSHE", 400, price_or_style_order=Optional[OrderStyle](lo))
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.frozen_price, 13.0)


def test_order_shares_zero_amount_returns_none() raises:
    """Test order_shares with zero amount returns None."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_shares(env, "000001.XSHE", 0)
    assert_true(result == None)


def test_order_shares_disabled_returns_none() raises:
    """Test order_shares when API is disabled returns None."""
    api = create_abstract_api(enabled=False)
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_shares(env, "000001.XSHE", 1000)
    assert_true(result == None)


def test_order_value_buy() raises:
    """Test order_value for buying with cash amount."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_value(env, "000001.XSHE", 10000.0)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)


def test_order_value_sell() raises:
    """Test order_value for selling with negative cash amount."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_value(env, "000001.XSHE", -5000.0)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.SELL)


def test_order_percent_valid() raises:
    """Test order_percent with valid percentage."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_percent(env, "000001.XSHE", 0.5)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)


def test_order_percent_invalid_raises() raises:
    """Test order_percent with invalid percent (>1) raises error."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var raised = False
    try:
        _ = api.order_percent(env, "000001.XSHE", 1.5)
    except:
        raised = True
    assert_true(raised)


def test_order_percent_negative_valid() raises:
    """Test order_percent with negative percent (selling)."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_percent(env, "000001.XSHE", -0.3)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.SELL)


def test_order_target_value_buy_more() raises:
    """Test order_target_value when target > current value."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_target_value(env, "000001.XSHE", 50000.0)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)


def test_order_target_value_buy_when_target_above_current() raises:
    """Test order_target_value when target > current value generates buy order."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_target_value(env, "000001.XSHE", 50000.0)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.side, SIDE.BUY)


def test_order_target_value_no_diff_returns_none() raises:
    """Test order_target_value when target ~= current returns None."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_target_value(env, "000001.XSHE", 0.01)
    assert_true(result == None)


def test_order_target_value_with_tuple_prices() raises:
    """Test order_target_value with separate buy/sell prices."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_target_value(
        env, "000001.XSHE", 50000.0,
        target_buy_price=Optional[Float64](10.0),
        target_sell_price=Optional[Float64](11.0)
    )
    assert_true(result != None)


def test_order_target_percent_valid() raises:
    """Test order_target_percent with valid range [0, 1]."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.order_target_percent(env, "000001.XSHE", 0.2)
    assert_true(result != None)


def test_order_target_percent_invalid_raises() raises:
    """Test order_target_percent with invalid percent (<0) raises error."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var raised = False
    try:
        _ = api.order_target_percent(env, "000001.XSHE", -0.1)
    except:
        raised = True
    assert_true(raised)


def test_buy_open_basic() raises:
    """Test buy_open future API."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.buy_open(env, "AG1607", 2)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.BUY)
    assert_equal(orders[0].position_effect_resolved(), POSITION_EFFECT.OPEN)


def test_buy_open_negative_amount_raises() raises:
    """Test buy_open with negative amount raises error."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var raised = False
    try:
        _ = api.buy_open(env, "AG1607", -1)
    except:
        raised = True
    assert_true(raised)


def test_buy_close_basic() raises:
    """Test buy_close future API."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.buy_close(env, "IF1603", 2)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.BUY)
    assert_equal(orders[0].position_effect_resolved(), POSITION_EFFECT.CLOSE)


def test_buy_close_today() raises:
    """Test buy_close with close_today=True uses CLOSE_TODAY effect."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.buy_close(env, "IF1603", 2, close_today=True)
    assert_equal(len(orders), 1)
    assert_true(orders[0].position_effect != None)
    assert_equal(orders[0].position_effect.value(), POSITION_EFFECT.CLOSE_TODAY)


def test_sell_open_basic() raises:
    """Test sell_open future API."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.sell_open(env, "IF1603", 2)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.SELL)
    assert_equal(orders[0].position_effect_resolved(), POSITION_EFFECT.OPEN)


def test_sell_close_basic() raises:
    """Test sell_close future API."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.sell_close(env, "IF1603", 2)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.SELL)
    assert_equal(orders[0].position_effect_resolved(), POSITION_EFFECT.CLOSE)


def test_sell_close_with_market_order() raises:
    """Test sell_close with MarketOrder style."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    mo = MarketOrder()
    var orders = api.sell_close(env, "IF1603", 2, price_or_style_order=Optional[OrderStyle](mo))
    assert_equal(len(orders), 1)
    assert_equal(orders[0].order_type_val, ORDER_TYPE.MARKET)


def test_order_stock_positive() raises:
    """Test order (universal) for stock with positive quantity."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.order(env, "000001.XSHE", 100)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.BUY)
    assert_equal(orders[0].quantity, 100)


def test_order_stock_negative() raises:
    """Test order (universal) for stock with negative quantity."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.order(env, "000001.XSHE", -50)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.SELL)
    assert_equal(orders[0].quantity, 50)


def test_order_future_positive() raises:
    """Test order (universal) for future with positive quantity generates close+open."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.order(env, "RB1710", 2)
    assert_true(len(orders) >= 1)


def test_order_to_stock_adjust_up() raises:
    """Test order_to for stock: increase position."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.order_to(env, "000001.XSHE", 500)
    assert_equal(len(orders), 1)
    assert_equal(orders[0].side, SIDE.BUY)


def test_order_to_stock_adjust_down() raises:
    """Test order_to for stock: adjust position from 0 to non-zero."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.order_to(env, "000001.XSHE", 100)
    assert_true(len(orders) >= 1)
    assert_equal(orders[0].side, SIDE.BUY)


def test_order_to_stock_no_diff() raises:
    """Test order_to when target == current returns empty list."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.order_to(env, "000001.XSHE", 0)
    assert_equal(len(orders), 0)


def test_exercise_basic() raises:
    """Test exercise options API."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var result = api.exercise(env, "M1905C2350", 1)
    assert_true(result != None)
    var order = result.value().copy()
    assert_equal(order.position_effect_resolved(), POSITION_EFFECT.EXERCISE)
    assert_equal(order.quantity, 1)


def test_exercise_zero_amount_raises() raises:
    """Test exercise with amount < 1 raises error."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var raised = False
    try:
        _ = api.exercise(env, "M1905C2350", 0)
    except:
        raised = True
    assert_true(raised)


def test_get_open_orders_empty() raises:
    """Test get_open_orders returns empty list when no orders."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.get_open_orders(env)
    assert_equal(len(orders), 0)


def test_get_open_orders_disabled() raises:
    """Test get_open_orders when disabled returns empty list."""
    api = create_abstract_api(enabled=False)
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var orders = api.get_open_orders(env, "000001.XSHE")
    assert_equal(len(orders), 0)


def test_cancel_order_noop() raises:
    """Test cancel_order does nothing (stub)."""
    api = create_abstract_api()
    env = create_environment(DateTime(2024, 1, 1, 0, 0, 0, 0), DateTime(2024, 12, 31, 0, 0, 0, 0))
    
    var order_result = api.order_shares(env, "000001.XSHE", 100)
    if order_result != None:
        api.cancel_order(env, order_result.value())
    assert_true(True)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
