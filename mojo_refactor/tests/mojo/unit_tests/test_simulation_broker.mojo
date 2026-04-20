"""
Mojo Unit Tests for SimulationBroker
Uses std.testing framework (mojo test)
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from std.collections import Dict, List
from rqmojo.const import (
    ORDER_STATUS, SIDE, POSITION_EFFECT, MATCHING_TYPE, ORDER_TYPE
)
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.core.events import EVENT, Event
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import (
    SimulationBroker, OrderEntry, BrokerState, create_simulation_broker
)


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_broker_creation() raises:
    var broker = create_simulation_broker()
    var orders = broker.get_open_orders()
    assert_equal(len(orders), 0)
    assert_equal(broker._match_immediately, True)
    assert_equal(broker._matching_type, MATCHING_TYPE.CURRENT_BAR_CLOSE)
    assert_equal(broker._slippage_model, "PriceRatioSlippage")
    assert_true(is_close(broker._slippage, 0.0))
    assert_true(is_close(broker._volume_percent, 0.25))
    assert_equal(broker._price_limit, True)
    assert_equal(broker._inactive_limit, True)
    assert_equal(broker._volume_limit, True)
    assert_equal(broker._liquidity_limit, False)


def test_broker_creation_next_bar_open() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    assert_equal(broker._match_immediately, False)
    assert_equal(broker._matching_type, MATCHING_TYPE.NEXT_BAR_OPEN)


def test_broker_creation_vwap() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.VWAP)
    assert_equal(broker._match_immediately, True)


def test_submit_order_next_bar_open_stays_open() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    var orders = broker.get_open_orders()
    assert_equal(len(orders), 1)
    assert_equal(orders[0].order_book_id, "000001.XSHE")
    assert_equal(orders[0].order.order_id, 1)
    var events = broker.get_published_events()
    assert_equal(len(events), 2)
    assert_equal(events[0].event_type, EVENT.ORDER_PENDING_NEW.value)
    assert_equal(events[1].event_type, EVENT.ORDER_CREATION_PASS.value)


def test_submit_order_match_immediately_fills() raises:
    var broker = create_simulation_broker()
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_submit_order_position_effect_match_raises() raises:
    var broker = create_simulation_broker()
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.MATCH
    )
    with assert_raises():
        broker.submit_order(order)


def test_submit_exercise_order() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.EXERCISE
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)
    assert_equal(len(broker._open_exercise_orders), 1)


def test_cancel_order() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)
    broker.cancel_order(order)
    assert_equal(len(broker.get_open_orders()), 0)
    var events = broker.get_published_events()
    assert_true(len(events) >= 4)
    assert_equal(events[2].event_type, EVENT.ORDER_PENDING_CANCEL.value)
    assert_equal(events[3].event_type, EVENT.ORDER_CANCELLATION_PASS.value)


def test_cancel_order_only_removes_target() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order1 = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    var order2 = create_order_with_id(
        order_id=2,
        order_book_id="000002.XSHE",
        side=SIDE.BUY,
        quantity=200,
        style=LimitOrder(20.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order1)
    broker.submit_order(order2)
    assert_equal(len(broker.get_open_orders()), 2)
    broker.cancel_order(order1)
    assert_equal(len(broker.get_open_orders()), 1)
    assert_equal(broker.get_open_orders()[0].order.order_id, 2)


def test_get_open_orders_filter_by_symbol() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order1 = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    var order2 = create_order_with_id(
        order_id=2,
        order_book_id="000002.XSHE",
        side=SIDE.BUY,
        quantity=200,
        style=LimitOrder(20.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order1)
    broker.submit_order(order2)
    var filtered = broker.get_open_orders("000001.XSHE")
    assert_equal(len(filtered), 1)
    assert_equal(filtered[0].order_book_id, "000001.XSHE")
    var all_orders = broker.get_open_orders()
    assert_equal(len(all_orders), 2)


def test_bar_match_market_buy_fills() raises:
    var broker = create_simulation_broker()
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_bar_match_limit_buy_at_price_fills() raises:
    var broker = create_simulation_broker()
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_bar_match_limit_buy_below_price_no_fill() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(9.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)


def test_bar_match_limit_sell_above_price_no_fill() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=LimitOrder(11.0),
        position_effect=POSITION_EFFECT.CLOSE
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)


def test_bar_match_limit_sell_at_price_fills() raises:
    var broker = create_simulation_broker()
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.CLOSE
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_bar_match_no_data_order_stays_open() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)


def test_bar_match_no_volume_inactive_limit() raises:
    var broker = create_simulation_broker(inactive_limit=True)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 0, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_price_limit_buy_at_limit_up_rejected() raises:
    var broker = create_simulation_broker(price_limit=True)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 10.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_price_limit_sell_at_limit_down_rejected() raises:
    var broker = create_simulation_broker(price_limit=True)
    broker.update_bar_data("000001.XSHE", 9.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_volume_limit_partial_fill() raises:
    var broker = create_simulation_broker(volume_limit=True, volume_percent=0.25)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 100, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_no_price_limit_fills_at_limit_up() raises:
    var broker = create_simulation_broker(price_limit=False)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 10.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_no_volume_limit_fills_full() raises:
    var broker = create_simulation_broker(volume_limit=False)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 100, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_slippage_price_ratio_buy() raises:
    var broker = create_simulation_broker(
        slippage_model="PriceRatioSlippage",
        slippage=0.001
    )
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_slippage_price_ratio_sell() raises:
    var broker = create_simulation_broker(
        slippage_model="PriceRatioSlippage",
        slippage=0.001
    )
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.CLOSE
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_slippage_limit_price() raises:
    var broker = create_simulation_broker(slippage_model="LimitPriceSlippage")
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.5),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_slippage_tick_size() raises:
    var broker = create_simulation_broker(
        slippage_model="TickSizeSlippage",
        slippage=2.0
    )
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_on_bar_clears_turnover() raises:
    var broker = create_simulation_broker(volume_limit=True, volume_percent=0.25)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_true(len(broker._bar_turnover) > 0)
    var evt = Event("bar")
    broker.on_bar(evt)
    assert_equal(len(broker._bar_turnover), 0)


def test_before_trading_reactivates_orders() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    broker.before_trading()
    var events = broker.get_published_events()
    var creation_pass_count = 0
    for i in range(len(events)):
        if events[i].event_type == EVENT.ORDER_CREATION_PASS.value:
            creation_pass_count += 1
    assert_true(creation_pass_count >= 2)


def test_after_trading_rejects_open_orders() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)
    broker.after_trading()
    assert_equal(len(broker.get_open_orders()), 0)
    var events = broker.get_published_events()
    var unsolicited_count = 0
    for i in range(len(events)):
        if events[i].event_type == EVENT.ORDER_UNSOLICITED_UPDATE.value:
            unsolicited_count += 1
    assert_true(unsolicited_count >= 1)


def test_pre_settlement_processes_exercise() raises:
    var broker = create_simulation_broker()
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.EXERCISE
    )
    broker.submit_order(order)
    assert_equal(len(broker._open_exercise_orders), 1)
    broker.pre_settlement()
    assert_equal(len(broker._open_exercise_orders), 0)


def test_get_state() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    var state = broker.get_state()
    assert_equal(len(state.open_orders_state), 1)
    assert_equal(len(state.open_auction_orders_state), 0)
    var os = state.open_orders_state[0].copy()
    assert_equal(os["order_book_id"], "000001.XSHE")
    assert_equal(os["order_id"], "1")
    assert_equal(os["quantity"], "100")


def test_set_state() raises:
    var broker1 = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker1.submit_order(order)
    var state = broker1.get_state()
    var broker2 = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    assert_equal(len(broker2.get_open_orders()), 0)
    broker2.set_state(state)
    var restored = broker2.get_open_orders()
    assert_equal(len(restored), 1)
    assert_equal(restored[0].order_book_id, "000001.XSHE")


def test_event_publishing_order_lifecycle() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=LimitOrder(10.0),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    var events = broker.get_published_events()
    assert_equal(len(events), 2)
    assert_equal(events[0].event_type, EVENT.ORDER_PENDING_NEW.value)
    assert_equal(events[1].event_type, EVENT.ORDER_CREATION_PASS.value)
    broker.clear_published_events()
    events = broker.get_published_events()
    assert_equal(len(events), 0)


def test_vwap_matching() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.VWAP)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 0)


def test_next_bar_open_matching() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)
    var evt = Event("bar")
    broker.on_bar(evt)
    assert_equal(len(broker.get_open_orders()), 0)


def test_tick_matching() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_TICK_LAST)
    broker._match_immediately = False
    broker.update_tick_data("000001.XSHE", 10.0, 5000, 10.05, 9.95, False)
    var order = create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
    broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 1)
    var evt = Event("tick")
    broker.on_tick(evt, "000001.XSHE")
    assert_equal(len(broker.get_open_orders()), 0)


def test_multiple_orders_same_symbol() raises:
    var broker = create_simulation_broker(matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
    broker.update_bar_data("000001.XSHE", 10.0, 9.5, 1000000, 11.0, 9.0)
    for i in range(5):
        var order = create_order_with_id(
            order_id=i,
            order_book_id="000001.XSHE",
            side=SIDE.BUY,
            quantity=100,
            style=LimitOrder(10.0),
            position_effect=POSITION_EFFECT.OPEN
        )
        broker.submit_order(order)
    assert_equal(len(broker.get_open_orders()), 5)
    var evt = Event("bar")
    broker.on_bar(evt)
    assert_equal(len(broker.get_open_orders()), 0)


def test_order_entry_copyable() raises:
    var entry = OrderEntry(order_book_id="000001.XSHE", order=create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    ))
    var entry2 = entry.copy()
    assert_equal(entry2.order_book_id, "000001.XSHE")
    assert_equal(entry2.order.order_id, 1)
    entry2.order.order_id = 99
    assert_equal(entry.order.order_id, 1)


def test_broker_state_copyable() raises:
    var state = BrokerState(
        open_orders_state=List[Dict[String, String]](),
        open_auction_orders_state=List[Dict[String, String]]()
    )
    var d = Dict[String, String]()
    d["key"] = "value"
    state.open_orders_state.append(d^)
    assert_equal(len(state.open_orders_state), 1)


def test_update_bar_data() raises:
    var broker = create_simulation_broker()
    broker.update_bar_data("000001.XSHE", 10.5, 10.0, 2000000, 11.5, 9.5)
    assert_true(is_close(broker._bar_close["000001.XSHE"], 10.5))
    assert_true(is_close(broker._bar_open["000001.XSHE"], 10.0))
    assert_equal(broker._bar_volume["000001.XSHE"], 2000000)
    assert_true(is_close(broker._bar_limit_up["000001.XSHE"], 11.5))
    assert_true(is_close(broker._bar_limit_down["000001.XSHE"], 9.5))


def test_update_tick_data() raises:
    var broker = create_simulation_broker()
    broker.update_tick_data("000001.XSHE", 10.5, 5000, 10.55, 10.45, True)
    assert_true(is_close(broker._tick_last_price["000001.XSHE"], 10.5))
    assert_equal(broker._cur_tick_volume["000001.XSHE"], 5000)
    assert_true(is_close(broker._tick_a1_price["000001.XSHE"], 10.55))
    assert_true(is_close(broker._tick_b1_price["000001.XSHE"], 10.45))
    assert_equal(broker._tick_during_auction["000001.XSHE"], True)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
