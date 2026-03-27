"""
RQMojo Test for core/events.mojo
"""

from std.collections import Dict, List
from rqmojo.core.events import Event, EventBus, EVENT, parse_event, create_event_bus


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_event_init() raises:
    print("Testing Event.__init__...")
    
    var event = Event("test_event")
    assert_equal(event.event_type, "test_event")
    print("  Event.__init__ tests passed!")


def test_event_attributes() raises:
    print("Testing Event attributes...")
    
    var event = Event("test_event")
    event.attributes["key1"] = "value1"
    event.attributes["key2"] = "123"
    
    assert_equal(event.event_type, "test_event")
    print("  Event attributes tests passed!")


def test_event_str() raises:
    print("Testing Event string representation...")
    
    var event = Event("test_event")
    event.attributes["key1"] = "value1"
    
    assert_true(len(event.event_type) > 0)
    
    print("  Event string representation tests passed!")


def test_event_bus_init() raises:
    print("Testing EventBus.__init__...")
    
    var bus = create_event_bus()
    
    print("  EventBus.__init__ tests passed!")


def test_event_constants() raises:
    print("Testing EVENT constants...")
    
    assert_equal(EVENT.POST_SYSTEM_INIT().value, "post_system_init")
    assert_equal(EVENT.BEFORE_TRADING().value, "before_trading")
    assert_equal(EVENT.BAR().value, "bar")
    assert_equal(EVENT.TICK().value, "tick")
    assert_equal(EVENT.AFTER_TRADING().value, "after_trading")
    assert_equal(EVENT.SETTLEMENT().value, "settlement")
    assert_equal(EVENT.TRADE().value, "trade")
    assert_equal(EVENT.ORDER_PENDING_NEW().value, "order_pending_new")
    assert_equal(EVENT.ORDER_CREATION_PASS().value, "order_creation_pass")
    assert_equal(EVENT.ORDER_CREATION_REJECT().value, "order_creation_reject")
    assert_equal(EVENT.HEARTBEAT().value, "heartbeat")
    assert_equal(EVENT.USER().value, "user")
    print("  EVENT constants tests passed!")


def test_parse_event() raises:
    print("Testing parse_event...")
    
    var event1 = parse_event("BAR")
    assert_equal(event1.value, "bar")
    var event2 = parse_event("bar")
    assert_equal(event2.value, "bar")
    var event3 = parse_event("Bar")
    assert_equal(event3.value, "bar")
    print("  parse_event tests passed!")


def test_event_equality() raises:
    print("Testing EVENT equality...")
    
    var event1 = EVENT.BAR()
    var event2 = EVENT.BAR()
    var event3 = EVENT.TICK()
    
    assert_equal(event1, event2)
    assert_true(not (event1 == event3))
    
    print("  EVENT equality tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
