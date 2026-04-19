from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import (
    is_valid_price,
    _price_reaches_limit,
    _is_supported_position_effect,
    _is_supported_side,
    MatcherInterface,
    DefaultBarMatcher,
    DefaultTickMatcher,
    CounterPartyOfferMatcher,
    create_default_bar_matcher,
    create_default_tick_matcher,
    create_counter_party_offer_matcher,
)
from rqmojo.const import MATCHING_TYPE, SIDE, ORDER_TYPE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.core.events import EVENT, Event, EventValue


def test_is_valid_price() raises:
    """Test is_valid_price utility function."""
    assert_true(is_valid_price(10.0) == True)
    assert_true(is_valid_price(0.0) == False)
    assert_true(is_valid_price(-1.0) == False)


def test_price_reaches_limit_buy() raises:
    """Test _price_reaches_limit for BUY side."""
    assert_true(_price_reaches_limit(SIDE.BUY, 10.0, 10.0, 9.0) == True)
    assert_true(_price_reaches_limit(SIDE.BUY, 11.0, 10.0, 9.0) == True)
    assert_true(_price_reaches_limit(SIDE.BUY, 9.5, 10.0, 9.0) == False)


def test_price_reaches_limit_sell() raises:
    """Test _price_reaches_limit for SELL side."""
    assert_true(_price_reaches_limit(SIDE.SELL, 8.0, 10.0, 8.0) == True)
    assert_true(_price_reaches_limit(SIDE.SELL, 7.5, 10.0, 8.0) == True)
    assert_true(_price_reaches_limit(SIDE.SELL, 8.5, 10.0, 8.0) == False)


def test_is_supported_position_effect() raises:
    """Test position effect validation."""
    assert_true(_is_supported_position_effect(POSITION_EFFECT.OPEN) == True)
    assert_true(_is_supported_position_effect(POSITION_EFFECT.CLOSE) == True)
    assert_true(_is_supported_position_effect(POSITION_EFFECT.CLOSE_TODAY) == True)
    assert_true(_is_supported_position_effect(None) == False)


def test_is_supported_side() raises:
    """Test side validation."""
    assert_true(_is_supported_side(SIDE.BUY) == True)
    assert_true(_is_supported_side(SIDE.SELL) == True)
    assert_true(_is_supported_side(None) == False)


def test_default_bar_matcher_creation() raises:
    """Test DefaultBarMatcher can be created via factory."""
    var matcher = create_default_bar_matcher()
    assert_true(matcher._volume_percent > 0.0)
    assert_true(matcher._price_limit == True)
    assert_true(matcher._inactive_limit == True)
    assert_true(matcher._volume_limit == True)


def test_default_bar_matcher_with_config() raises:
    """Test DefaultBarMatcher with custom config."""
    var matcher = create_default_bar_matcher(
        matching_type=MATCHING_TYPE.VWAP,
        slippage=0.01,
        volume_percent=0.5,
        price_limit=False,
        inactive_limit=False
    )
    assert_true(matcher._matching_type == MATCHING_TYPE.VWAP)
    assert_true(matcher._volume_percent == 0.5)
    assert_true(matcher._price_limit == False)
    assert_true(matcher._inactive_limit == False)


def test_default_bar_matcher_update_clears_turnover() raises:
    """Test update clears turnover dict."""
    var matcher = create_default_bar_matcher()
    matcher._turnover["test"] = 100
    var event = Event("SYSTEM", Dict[String, EventValue]())
    matcher.update(event)
    assert_true(len(matcher._turnover) == 0)


def test_default_tick_matcher_creation() raises:
    """Test DefaultTickMatcher can be created via factory."""
    var matcher = create_default_tick_matcher()
    assert_true(matcher._volume_percent > 0.0)
    assert_true(matcher._price_limit == True)
    assert_true(matcher._liquidity_limit == False)
    assert_true(matcher._volume_limit == True)


def test_default_tick_matcher_with_call_auction() raises:
    """Test DefaultTickMatcher call auction state."""
    var matcher = create_default_tick_matcher()
    matcher._during_call_auction["000001.XSHE"] = True
    assert_true(matcher._is_call_auction("000001.XSHE") == True)
    assert_true(matcher._is_call_auction("nonexistent") == False)


def test_default_tick_matcher_update_updates_state() raises:
    """Test update updates tick state."""
    var matcher = create_default_tick_matcher()
    matcher._cur_tick_volume["000001.XSHE"] = 500

    var attrs = Dict[String, EventValue]()
    attrs["order_book_id"] = EventValue("000001.XSHE")
    attrs["tick_volume"] = EventValue(600)
    var event = Event("TICK", attrs^)

    matcher.update(event)
    assert_true(matcher._last_tick_volume["000001.XSHE"] == 500)
    assert_true(matcher._cur_tick_volume["000001.XSHE"] == 600)


def test_counter_party_offer_matcher_creation() raises:
    """Test CounterPartyOfferMatcher can be created."""
    var matcher = create_counter_party_offer_matcher()
    assert_true(matcher._base_matcher._volume_percent > 0.0)
    assert_true(len(matcher._a_volume) == 0)
    assert_true(len(matcher._b_volume) == 0)


def test_counter_party_offer_pre_tick_update() raises:
    """Test pre_tick_update sets ask/bid data."""
    var matcher = create_counter_party_offer_matcher()
    var asks: List[Int] = [100, 200]
    var bids: List[Int] = [150, 250]
    var a_prices: List[Float64] = [10.5, 10.6]
    var b_prices: List[Float64] = [10.4, 10.3]

    matcher.pre_tick_update(
        "000001.XSHE",
        asks.copy(),
        bids.copy(),
        a_prices.copy(),
        b_prices.copy()
    )

    assert_true(len(matcher._a_volume["000001.XSHE"]) == 2)
    assert_true(matcher._a_volume["000001.XSHE"][0] == 100)
    assert_true(matcher._b_volume["000001.XSHE"][0] == 150)
    assert_true(matcher._a_price["000001.XSHE"][0] == 10.5)
    assert_true(matcher._b_price["000001.XSHE"][0] == 10.4)


def test_factory_functions_return_correct_types() raises:
    """Verify factory functions return correct matcher types."""
    var bar_m = create_default_bar_matcher()
    var tick_m = create_default_tick_matcher()
    var cpo_m = create_counter_party_offer_matcher()

    assert_true(bar_m._matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE)
    assert_true(tick_m._matching_type == MATCHING_TYPE.NEXT_TICK_LAST)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
