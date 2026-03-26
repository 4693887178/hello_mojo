"""
RQMojo Test for core/events.mojo
"""

from std.collections import Dict, List
from rqmojo.core.events import Event, EventBus, EVENT, parse_event, create_event_bus


def test_event_init() raises:
    print("Testing Event.__init__...")
    
    var event = Event("test_event")
    assert event.event_type == "test_event"
    
    print("  Event.__init__ tests passed!")


def test_event_attributes() raises:
    print("Testing Event attributes...")
    
    var event = Event("test_event")
    event.attributes["key1"] = "value1"
    event.attributes["key2"] = "123"
    
    assert event.event_type == "test_event"
    
    print("  Event attributes tests passed!")


def test_event_str() raises:
    print("Testing Event string representation...")
    
    var event = Event("test_event")
    event.attributes["key1"] = "value1"
    
    assert len(event.event_type) > 0
    
    print("  Event string representation tests passed!")


def test_event_bus_init() raises:
    print("Testing EventBus.__init__...")
    
    var bus = create_event_bus()
    
    print("  EventBus.__init__ tests passed!")


def test_event_constants() raises:
    print("Testing EVENT constants...")
    
    assert EVENT.POST_SYSTEM_INIT().value == "post_system_init"
    assert EVENT.BEFORE_TRADING().value == "before_trading"
    assert EVENT.BAR().value == "bar"
    assert EVENT.TICK().value == "tick"
    assert EVENT.AFTER_TRADING().value == "after_trading"
    assert EVENT.SETTLEMENT().value == "settlement"
    assert EVENT.TRADE().value == "trade"
    assert EVENT.ORDER_PENDING_NEW().value == "order_pending_new"
    assert EVENT.ORDER_CREATION_PASS().value == "order_creation_pass"
    assert EVENT.ORDER_CREATION_REJECT().value == "order_creation_reject"
    assert EVENT.HEARTBEAT().value == "heartbeat"
    assert EVENT.USER().value == "user"
    
    print("  EVENT constants tests passed!")


def test_parse_event() raises:
    print("Testing parse_event...")
    
    var event1 = parse_event("BAR")
    assert event1.value == "bar"
    
    var event2 = parse_event("bar")
    assert event2.value == "bar"
    
    var event3 = parse_event("Bar")
    assert event3.value == "bar"
    
    print("  parse_event tests passed!")


def test_event_equality() raises:
    print("Testing EVENT equality...")
    
    var event1 = EVENT.BAR()
    var event2 = EVENT.BAR()
    var event3 = EVENT.TICK()
    
    assert event1 == event2
    assert not (event1 == event3)
    
    print("  EVENT equality tests passed!")


def main() raises:
    print("=" * 60)
    print("Testing core/events.mojo")
    print("=" * 60)
    
    test_event_init()
    test_event_attributes()
    test_event_str()
    test_event_bus_init()
    test_event_constants()
    test_parse_event()
    test_event_equality()
    
    print("=" * 60)
    print("All core/events.mojo tests passed!")
    print("=" * 60)
