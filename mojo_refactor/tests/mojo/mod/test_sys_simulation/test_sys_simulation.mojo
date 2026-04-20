"""
RQAlpha Mojo - Simulation Module Comprehensive Unit Tests
Tests all components of rqmojo_mod_sys_simulation module
Using std.testing framework as required
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List, Optional

from rqmojo.const import (
    MATCHING_TYPE, SIDE, ORDER_TYPE, POSITION_EFFECT,
    ORDER_STATUS, RUN_TYPE, EXECUTION_PHASE, ALGO
)
from rqmojo.model.order import (
    Order, create_order_with_id, MarketOrder, LimitOrder
)
from rqmojo.core.events import EVENT, Event
from rqmojo.utils.typing import DateTime

from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import (
    PriceRatioSlippage,
    TickSizeSlippage,
    LimitPriceSlippage,
    SlippageDecider,
    create_slippage_decider,
    create_price_ratio_slippage,
    create_tick_size_slippage,
    create_limit_price_slippage,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import (
    DefaultBarMatcher,
    DefaultTickMatcher,
    create_default_bar_matcher,
    create_default_tick_matcher,
    _price_reaches_limit,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import (
    SignalBroker,
    create_signal_broker,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import (
    SimulationBroker,
    BrokerState,
    create_simulation_broker,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import (
    SimulationEventSource,
    create_simulation_event_source,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.validator import (
    OrderStyleValidator,
    create_order_style_validator,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.mod import (
    SimulationMod,
    load_mod,
    create_simulation_mod,
)


def _make_buy_order(order_id: Int) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


def _make_sell_order(order_id: Int) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )


def _make_limit_buy_order(order_id: Int, price: Float64) -> Order:
    return create_order_with_id(
        order_id=order_id,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(price),
        position_effect=POSITION_EFFECT.OPEN
    )


# ==================== Slippage Tests ====================

def test_price_ratio_slippage_init() raises:
    var s = create_price_ratio_slippage(0.0)
    assert_equal(s.rate, 0.0)

def test_price_ratio_slippage_custom_rate() raises:
    var s = create_price_ratio_slippage(0.01)
    assert_equal(s.rate, 0.01)

def test_price_ratio_slippage_invalid_rate_high() raises:
    var raised = False
    try:
        var s = PriceRatioSlippage(rate=1.0)
    except:
        raised = True
    assert_true(raised)

def test_price_ratio_slippage_invalid_rate_negative() raises:
    var raised = False
    try:
        var s = PriceRatioSlippage(rate=-0.1)
    except:
        raised = True
    assert_true(raised)

def test_price_ratio_slippage_buy_adjusts_up() raises:
    var s = PriceRatioSlippage(rate=0.1)
    var order = _make_buy_order(1)
    var price = s.get_trade_price(order, 10.0)
    assert_true(price > 10.0)
    assert_true(abs(price - 11.0) < 1e-6)

def test_price_ratio_slippage_sell_adjusts_down() raises:
    var s = PriceRatioSlippage(rate=0.1)
    var order = _make_sell_order(2)
    var price = s.get_trade_price(order, 10.0)
    assert_true(price < 10.0)
    assert_true(abs(price - 9.0) < 1e-6)


def test_tick_size_slippage_init() raises:
    var s = create_tick_size_slippage(0.001)
    assert_equal(s.rate, 0.001)

def test_tick_size_slippage_invalid_rate() raises:
    var raised = False
    try:
        var s = TickSizeSlippage(rate=-0.01)
    except:
        raised = True
    assert_true(raised)

def test_limit_price_slippage_returns_limit_for_limit_orders() raises:
    var s = LimitPriceSlippage()
    var order = _make_limit_buy_order(3, 15.5)
    var price = s.get_trade_price(order, 10.0)
    assert_equal(price, 15.5)

def test_limit_price_slippage_returns_market_for_market_orders() raises:
    var s = LimitPriceSlippage()
    var order = _make_buy_order(4)
    var price = s.get_trade_price(order, 10.0)
    assert_equal(price, 10.0)


def test_slippage_decider_price_ratio() raises:
    var decider = create_slippage_decider("PriceRatioSlippage", 0.02)
    var order = _make_buy_order(5)
    var price = decider.get_trade_price(order, 10.0)
    assert_true(price > 10.0)

def test_slippage_decider_tick_size() raises:
    var decider = create_slippage_decider("TickSizeSlippage", 0.002)
    var order = _make_sell_order(6)
    var price = decider.get_trade_price(order, 10.0)
    assert_true(price < 10.0)

def test_slippage_decider_limit_price() raises:
    var decider = create_slippage_decider("LimitPriceSlippage", 0.0)
    var order = _make_limit_buy_order(7, 20.0)
    var price = decider.get_trade_price(order, 10.0)
    assert_equal(price, 20.0)

def test_slippage_decider_unknown_model_raises() raises:
    var decider = SlippageDecider(module_name="UnknownModel", rate=0.0)
    var order = _make_buy_order(8)
    var raised = False
    try:
        var price = decider.get_trade_price(order, 10.0)
    except:
        raised = True
    assert_true(raised)


# ==================== Matcher Tests ====================

def test_create_default_bar_matcher() raises:
    var m = create_default_bar_matcher()
    assert_equal(m._volume_percent, 0.25)
    assert_true(m._price_limit)
    assert_true(m._volume_limit)
    assert_equal(m._matching_type, MATCHING_TYPE.CURRENT_BAR_CLOSE)

def test_create_bar_matcher_with_params() raises:
    var m = create_default_bar_matcher(
        matching_type=MATCHING_TYPE.VWAP,
        slippage_model="TickSizeSlippage",
        slippage=0.02,
        volume_percent=0.5,
        price_limit=False,
        volume_limit=False
    )
    assert_equal(m._matching_type, MATCHING_TYPE.VWAP)
    assert_false(m._price_limit)
    assert_false(m._volume_limit)

def test_create_default_tick_matcher() raises:
    var m = create_default_tick_matcher()
    assert_equal(m._matching_type, MATCHING_TYPE.NEXT_TICK_LAST)

def test_create_tick_matcher_with_liquidity_limit() raises:
    var m = create_default_tick_matcher(liquidity_limit=True)
    assert_true(m._liquidity_limit)

def test_price_reaches_limit_buy_at_limit_up() raises:
    var result = _price_reaches_limit("000001", SIDE.BUY, 12.0, 11.0, 9.0)
    assert_true(result)

def test_price_reaches_limit_buy_below_limit_up() raises:
    var result = _price_reaches_limit("000001", SIDE.BUY, 10.5, 11.0, 9.0)
    assert_false(result)

def test_price_reaches_limit_sell_at_limit_down() raises:
    var result = _price_reaches_limit("000001", SIDE.SELL, 8.0, 11.0, 9.0)
    assert_true(result)

def test_price_reaches_limit_sell_above_limit_down() raises:
    var result = _price_reaches_limit("000001", SIDE.SELL, 9.5, 11.0, 9.0)
    assert_false(result)

def test_bar_matcher_update_clears_turnover() raises:
    var m = create_default_bar_matcher()
    var evt = Event(EVENT.AFTER_TRADING.value)
    m._turnover["000001"] = 500
    m.update(evt)
    assert_equal(len(m._turnover), 0)


# ==================== SignalBroker Tests ====================

def test_create_signal_broker() raises:
    var sb = create_signal_broker()
    assert_true(sb._price_limit)

def test_create_signal_broker_with_params() raises:
    var sb = create_signal_broker(
        slippage_model="TickSizeSlippage",
        slippage=0.003,
        price_limit=False
    )
    assert_false(sb._price_limit)
    assert_equal(sb._slippage_decider._rate, 0.003)

def test_signal_broker_get_open_orders_empty() raises:
    var sb = create_signal_broker()
    var orders = sb.get_open_orders()
    assert_equal(len(orders), 0)


# ==================== SimulationBroker Tests ====================

def test_create_simulation_broker() raises:
    var broker = create_simulation_broker()
    assert_true(broker._match_immediately)
    assert_true(broker._price_limit)
    assert_equal(broker._frequency, "1d")

def test_create_simulation_broker_vwap_no_immediate() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.VWAP)
    assert_true(broker._match_immediately)

def test_create_simulation_broker_next_bar_not_immediate() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    assert_false(broker._match_immediately)

def test_simulation_broker_get_open_orders_empty() raises:
    var broker = create_simulation_broker()
    var orders = broker.get_open_orders()
    assert_equal(len(orders), 0)

def test_simulation_broker_get_state() raises:
    var broker = create_simulation_broker()
    var state = broker.get_state()
    assert_equal(len(state.open_orders_state), 0)
    assert_equal(len(state.open_auction_orders_state), 0)

def test_simulation_broker_write_to() raises:
    var broker = create_simulation_broker()
    var buf = String("")
    broker.write_to(buf)
    assert_true(buf.find("SimulationBroker") >= 0)

def test_simulation_broker_after_trading_clears_orders() raises:
    var broker = create_simulation_broker()
    broker._open_order_ids.append(12345)
    broker.after_trading()
    assert_equal(len(broker._open_order_ids), 0)


# ==================== SimulationEventSource Tests ====================

def test_create_event_source_daily() raises:
    var src = create_simulation_event_source("1d")
    assert_equal(src._frequency, "1d")

def test_create_event_source_minute() raises:
    var src = create_simulation_event_source("1m")
    assert_equal(src._frequency, "1m")

def test_create_event_source_tick() raises:
    var src = create_simulation_event_source("tick")
    assert_equal(src._frequency, "tick")

def test_event_source_generate_daily_events() raises:
    var src = create_simulation_event_source("1d")
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 31, 23, 59, 59, 0)
    var count = src.generate_daily_events(start, end)
    assert_true(count > 0)
    assert_equal(count % 4, 0)

def test_event_source_generate_minute_events() raises:
    var src = create_simulation_event_source("1m")
    var start = DateTime(2024, 1, 2, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 2, 16, 0, 0, 0)
    var count = src.generate_minute_events(start, end)
    assert_true(count > 0)

def test_event_source_events_daily_frequency() raises:
    var src = create_simulation_event_source("1d")
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 31, 23, 59, 59, 0)
    var count = src.events(start, end, "1d")
    assert_true(count >= 4)

def test_event_source_events_minute_frequency() raises:
    var src = create_simulation_event_source("1m")
    var start = DateTime(2024, 1, 2, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 2, 16, 0, 0, 0)
    var count = src.events(start, end, "1m")
    assert_true(count > 0)

def test_event_source_events_tick_frequency_zero() raises:
    var src = create_simulation_event_source("tick")
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 31, 23, 59, 59, 0)
    var count = src.events(start, end, "tick")
    assert_equal(count, 0)

def test_event_source_events_invalid_frequency_raises() raises:
    var src = create_simulation_event_source("1d")
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 31, 23, 59, 59, 0)
    var raised = False
    try:
        var count = src.events(start, end, "invalid_freq")
    except:
        raised = True
    assert_true(raised)


# ==================== Validator Tests ====================

def test_create_validator() raises:
    var v = create_order_style_validator("1d")
    assert_equal(v.frequency, "1d")

def test_create_validator_tick() raises:
    var v = create_order_style_validator("tick")
    assert_equal(v.frequency, "tick")

def test_validate_order_always_passes() raises:
    var v = create_order_style_validator("1d")
    var order = _make_buy_order(10)
    var result = v.validate_order(order)
    assert_true(result)

def test_can_submit_order_always_true() raises:
    var v = create_order_style_validator("1d")
    var order = _make_buy_order(11)
    assert_true(v.can_submit_order(order))

def test_can_cancel_order_always_true() raises:
    var v = create_order_style_validator("1d")
    assert_true(v.can_cancel_order(999))

def test_validate_submission_normal_order_none() raises:
    var v = create_order_style_validator("1d")
    var order = _make_buy_order(12)
    var result = v.validate_submission(order, "STOCK")
    assert_true(result == Optional[String](None))

def test_validate_cancellation_none() raises:
    var v = create_order_style_validator("1d")
    var order = _make_buy_order(13)
    var result = v.validate_cancellation(order, "STOCK")
    assert_true(result == Optional[String](None))


# ==================== Mod Tests ====================

def test_load_mod() raises:
    var mod = load_mod()
    assert_equal(mod._frequency, "1d")
    assert_equal(mod._run_type, RUN_TYPE.BACKTEST)
    assert_equal(mod._matching_type, MATCHING_TYPE.CURRENT_BAR_CLOSE)

def test_create_simulation_mod_defaults() raises:
    var mod = create_simulation_mod()
    assert_equal(mod._matching_type, MATCHING_TYPE.CURRENT_BAR_CLOSE)
    assert_equal(mod._slippage, 0.0)

def test_create_simulation_mod_with_params() raises:
    var mod = create_simulation_mod(
        matching_type=MATCHING_TYPE.NEXT_BAR_OPEN,
        slippage=0.05
    )
    assert_equal(mod._matching_type, MATCHING_TYPE.NEXT_BAR_OPEN)
    assert_equal(mod._slippage, 0.05)

def test_parse_matching_type_current_bar() raises:
    var mt = SimulationMod.parse_matching_type("current_bar", "1d")
    assert_equal(mt, MATCHING_TYPE.CURRENT_BAR_CLOSE)

def test_parse_matching_type_vwap() raises:
    var mt = SimulationMod.parse_matching_type("vwap", "1d")
    assert_equal(mt, MATCHING_TYPE.VWAP)

def test_parse_matching_type_next_bar() raises:
    var mt = SimulationMod.parse_matching_type("next_bar", "1d")
    assert_equal(mt, MATCHING_TYPE.NEXT_BAR_OPEN)

def test_parse_matching_type_last_tick() raises:
    var mt = SimulationMod.parse_matching_type("last", "tick")
    assert_equal(mt, MATCHING_TYPE.NEXT_TICK_LAST)

def test_parse_matching_type_best_own() raises:
    var mt = SimulationMod.parse_matching_type("best_own", "tick")
    assert_equal(mt, MATCHING_TYPE.NEXT_TICK_BEST_OWN)

def test_parse_matching_type_best_counterparty() raises:
    var mt = SimulationMod.parse_matching_type("best_counterparty", "tick")
    assert_equal(mt, MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY)

def test_parse_matching_type_counterparty_offer() raises:
    var mt = SimulationMod.parse_matching_type("counterparty_offer", "tick")
    assert_equal(mt, MATCHING_TYPE.COUNTERPARTY_OFFER)

def test_parse_matching_type_empty_defaults_current_bar() raises:
    var mt = SimulationMod.parse_matching_type("", "1d")
    assert_equal(mt, MATCHING_TYPE.CURRENT_BAR_CLOSE)

def test_parse_matching_type_empty_defaults_last_for_tick() raises:
    var mt = SimulationMod.parse_matching_type("", "tick")
    assert_equal(mt, MATCHING_TYPE.NEXT_TICK_LAST)

def test_parse_matching_type_invalid_raises() raises:
    var raised = False
    try:
        var mt = SimulationMod.parse_matching_type("invalid_type", "1d")
    except:
        raised = True
    assert_true(raised)

def test_parse_matching_type_empty_invalid_frequency_raises() raises:
    var raised = False
    try:
        var mt = SimulationMod.parse_matching_type("", "invalid_freq")
    except:
        raised = True
    assert_true(raised)

def test_mod_write_to() raises:
    var mod = create_simulation_mod()
    var buf = String("")
    mod.write_to(buf)
    assert_true(buf.find("SimulationMod") >= 0)

def test_mod_tear_down() raises:
    var mod = create_simulation_mod()
    mod.tear_down(0)

def test_mod_get_matching_type() raises:
    var mod = create_simulation_mod(matching_type=MATCHING_TYPE.VWAP)
    assert_equal(mod.get_matching_type(), MATCHING_TYPE.VWAP)

def test_mod_get_slippage() raises:
    var mod = create_simulation_mod(slippage=0.03)
    assert_equal(mod.get_slippage(), 0.03)


# ==================== Integration / Cross-Module Tests ====================

def test_full_pipeline_broker_creation() raises:
    var broker = create_simulation_broker(
        matching_type=MATCHING_TYPE.CURRENT_BAR_CLOSE,
        slippage_model="PriceRatioSlippage",
        slippage=0.01,
        frequency="1d"
    )
    assert_true(broker._match_immediately)
    assert_equal(broker._matching_type, MATCHING_TYPE.CURRENT_BAR_CLOSE)

def test_full_pipeline_event_source_and_broker() raises:
    var src = create_simulation_event_source("1d")
    var broker = create_simulation_broker(frequency="1d")
    assert_equal(src._frequency, broker._frequency)

def test_full_pipeline_signal_broker_with_slippage() raises:
    var sb = create_signal_broker(
        slippage_model="PriceRatioSlippage",
        slippage=0.005
    )
    var orders = sb.get_open_orders()
    assert_equal(len(orders), 0)

def test_full_pipeline_mod_start_up_creates_components() raises:
    var mod = create_simulation_mod(
        matching_type=MATCHING_TYPE.VWAP,
        slippage=0.02
    )
    mod.start_up(
        matching_type_str="vwap",
        slippage_model="PriceRatioSlippage",
        slippage=0.02,
        frequency="1d"
    )
    assert_equal(mod._matching_type, MATCHING_TYPE.VWAP)

def test_broker_state_roundtrip() raises:
    var broker = create_simulation_broker()
    broker._open_order_ids.append(111)
    broker._open_order_ids.append(222)
    var state = broker.get_state()
    assert_equal(len(state.open_orders_state), 2)

def test_multiple_matchers_different_types() raises:
    var bar_m = create_default_bar_matcher(matching_type=MATCHING_TYPE.VWAP)
    var tick_m = create_default_tick_matcher(matching_type=MATCHING_TYPE.NEXT_TICK_LAST)
    assert_equal(bar_m._matching_type, MATCHING_TYPE.VWAP)
    assert_equal(tick_m._matching_type, MATCHING_TYPE.NEXT_TICK_LAST)

def test_all_slippage_types_in_decider() raises:
    var pr = SlippageDecider(module_name="PriceRatioSlippage", rate=0.01)
    var ts = SlippageDecider(module_name="TickSizeSlippage", rate=0.001)
    var lp = SlippageDecider(module_name="LimitPriceSlippage", rate=0.0)
    var buy_order = _make_buy_order(99)
    var pr_buy_price = pr.get_trade_price(buy_order, 10.0)
    var ts_buy_price = ts.get_trade_price(buy_order, 10.0)
    var lp_buy_price = lp.get_trade_price(buy_order, 10.0)
    assert_true(pr_buy_price > 10.0)
    assert_true(ts_buy_price > 10.0)
    assert_equal(lp_buy_price, 10.0)
    var sell_order = _make_sell_order(98)
    var ts_sell_price = ts.get_trade_price(sell_order, 10.0)
    assert_true(ts_sell_price < 10.0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
