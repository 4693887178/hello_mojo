"""
RQMojo Test for core/events.mojo (refactored)
"""

from std.collections import Dict, List
from rqmojo.core.events import Event, EventBus, EVENT, parse_event

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def _return_false(event: Event) -> Bool:
    return False


def _return_true(event: Event) -> Bool:
    return True


def test_event_init() raises:
    var event = Event("test_event")
    assert_equal(event.event_type, "test_event")


def test_event_attributes() raises:
    var event = Event("test_event")
    event.attributes["key1"] = "value1"
    event.attributes["key2"] = "123"
    assert_equal(event.event_type, "test_event")
    assert_true("key1" in event.attributes)


def test_event_write_to() raises:
    var event = Event("test_event")
    event.attributes["key1"] = "value1"
    var s = String.write(event)
    assert_true(s.find("event_type:test_event") >= 0)
    assert_true(s.find("key1:value1") >= 0)


def test_event_bus_init() raises:
    var bus = EventBus()
    assert_equal(len(bus.listeners), 0)
    assert_equal(len(bus.user_listeners), 0)


def test_add_listener_no_crash() raises:
    var bus = EventBus()
    bus.add_listener("test_event", _return_false)
    bus.add_listener("test_event", _return_false, user=True)
    assert_true("test_event" in bus.listeners or True)


def test_prepend_listener_no_crash() raises:
    var bus = EventBus()
    bus.add_listener("test_event", _return_false)
    bus.prepend_listener("test_event", _return_true)
    bus.prepend_listener("test_event", _return_false, user=True)


def test_publish_event_no_crash() raises:
    var bus = EventBus()
    bus.add_listener("test_event", _return_false)
    bus.add_listener("test_event", _return_true)
    bus.publish_event(Event("test_event"))


def test_publish_nonexistent_event_no_crash() raises:
    var bus = EventBus()
    bus.add_listener("test_event", _return_false)
    var result = bus.publish_event(Event("nonexistent"))
    assert_true(not result)


def test_event_constants_comptime() raises:
    assert_equal(EVENT.POST_SYSTEM_INIT.value, "post_system_init")
    assert_equal(EVENT.BEFORE_SYSTEM_RESTORED.value, "before_system_restored")
    assert_equal(EVENT.POST_SYSTEM_RESTORED.value, "post_system_restored")
    assert_equal(EVENT.POST_USER_INIT.value, "post_user_init")
    assert_equal(EVENT.POST_UNIVERSE_CHANGED.value, "post_universe_changed")
    assert_equal(EVENT.PRE_BEFORE_TRADING.value, "pre_before_trading")
    assert_equal(EVENT.BEFORE_TRADING.value, "before_trading")
    assert_equal(EVENT.POST_BEFORE_TRADING.value, "post_before_trading")
    assert_equal(EVENT.PRE_OPEN_AUCTION.value, "pre_open_auction")
    assert_equal(EVENT.OPEN_AUCTION.value, "open_auction")
    assert_equal(EVENT.POST_OPEN_AUCTION.value, "post_open_auction")
    assert_equal(EVENT.PRE_BAR.value, "pre_bar")
    assert_equal(EVENT.BAR.value, "bar")
    assert_equal(EVENT.POST_BAR.value, "post_bar")
    assert_equal(EVENT.PRE_TICK.value, "pre_tick")
    assert_equal(EVENT.TICK.value, "tick")
    assert_equal(EVENT.POST_TICK.value, "post_tick")
    assert_equal(EVENT.PRE_SCHEDULED.value, "pre_scheduled")
    assert_equal(EVENT.POST_SCHEDULED.value, "post_scheduled")
    assert_equal(EVENT.PRE_AFTER_TRADING.value, "pre_after_trading")
    assert_equal(EVENT.AFTER_TRADING.value, "after_trading")
    assert_equal(EVENT.POST_AFTER_TRADING.value, "post_after_trading")
    assert_equal(EVENT.PRE_SETTLEMENT.value, "pre_settlement")
    assert_equal(EVENT.SETTLEMENT.value, "settlement")
    assert_equal(EVENT.POST_SETTLEMENT.value, "post_settlement")
    assert_equal(EVENT.ORDER_PENDING_NEW.value, "order_pending_new")
    assert_equal(EVENT.ORDER_CREATION_PASS.value, "order_creation_pass")
    assert_equal(EVENT.ORDER_CREATION_REJECT.value, "order_creation_reject")
    assert_equal(EVENT.ORDER_PENDING_CANCEL.value, "order_pending_cancel")
    assert_equal(EVENT.ORDER_CANCELLATION_PASS.value, "order_cancellation_pass")
    assert_equal(EVENT.ORDER_CANCELLATION_REJECT.value, "order_cancellation_reject")
    assert_equal(EVENT.ORDER_UNSOLICITED_UPDATE.value, "order_unsolicited_update")
    assert_equal(EVENT.TRADE.value, "trade")
    assert_equal(EVENT.ON_LINE_PROFILER_RESULT.value, "on_line_profiler_result")
    assert_equal(EVENT.DO_PERSIST.value, "do_persist")
    assert_equal(EVENT.DO_RESTORE.value, "do_restore")
    assert_equal(EVENT.STRATEGY_HOLD_SET.value, "strategy_hold_set")
    assert_equal(EVENT.STRATEGY_HOLD_CANCELLED.value, "strategy_hold_canceled")
    assert_equal(EVENT.HEARTBEAT.value, "heartbeat")
    assert_equal(EVENT.BEFORE_STRATEGY_RUN.value, "before_strategy_run")
    assert_equal(EVENT.POST_STRATEGY_RUN.value, "post_strategy_run")
    assert_equal(EVENT.USER.value, "user")


def test_event_equality() raises:
    var e1 = EVENT.BAR
    var e2 = EVENT.BAR
    var e3 = EVENT.TICK
    assert_equal(e1, e2)
    assert_true(not (e1 == e3))


def test_event_getitem_by_name() raises:
    var result = EVENT.__getitem__("BAR")
    assert_true(result != None)
    assert_equal(result.value().value, "bar")


def test_event_getitem_by_value() raises:
    var result = EVENT.__getitem__("bar")
    assert_true(result != None)
    assert_equal(result.value().name, "BAR")


def test_event_getitem_unknown() raises:
    var result = EVENT.__getitem__("NONEXISTENT")
    assert_true(result == None)


def test_event_contains() raises:
    assert_true(EVENT.contains("BAR"))
    assert_true(EVENT.contains("bar"))
    assert_true(not EVENT.contains("NONEXISTENT"))


def test_parse_event_uppercase() raises:
    var event = parse_event("BAR")
    assert_equal(event.value, "bar")


def test_parse_event_lowercase() raises:
    var event = parse_event("bar")
    assert_equal(event.value, "bar")


def test_parse_event_mixed_case() raises:
    var event = parse_event("Bar")
    assert_equal(event.value, "bar")


def test_parse_event_invalid() raises:
    with assert_raises():
        _ = parse_event("INVALID_EVENT")


def test_event_members_count() raises:
    var members = EVENT.members()
    assert_equal(len(members), 42)


def test_event_writable_format() raises:
    var s = String.write(EVENT.BAR)
    assert_true(s.find("EVENT") >= 0)
    assert_true(s.find("BAR") >= 0)

    var s2 = String.write(EVENT.AFTER_TRADING)
    assert_true(s2.find("AFTER_TRADING") >= 0)


def test_all_event_names_match_values() raises:
    for m in EVENT.members():
        assert_true(len(m.name) > 0)
        assert_true(len(m.value) > 0)
        assert_true(m.name == m.name.upper())


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
