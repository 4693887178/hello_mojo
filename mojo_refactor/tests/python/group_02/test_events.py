"""
Test for rqalpha/core/events.py
"""

import pytest
from rqalpha.core.events import Event, EventBus, EVENT, parse_event


class TestEvent:
    def test_event_init(self):
        event = Event("test_event")
        assert event.event_type == "test_event"

    def test_event_with_kwargs(self):
        event = Event("test_event", key1="value1", key2=123)
        assert event.event_type == "test_event"
        assert event.key1 == "value1"
        assert event.key2 == 123

    def test_event_repr(self):
        event = Event("test_event", key1="value1")
        repr_str = repr(event)
        assert "event_type:test_event" in repr_str
        assert "key1:value1" in repr_str


class TestEventBus:
    def test_event_bus_init(self):
        bus = EventBus()
        assert bus._listeners is not None
        assert bus._user_listeners is not None

    def test_add_listener(self):
        bus = EventBus()
        called = []
        
        def listener(event):
            called.append(event.event_type)
            return False
        
        bus.add_listener("test_event", listener)
        event = Event("test_event")
        bus.publish_event(event)
        assert "test_event" in called

    def test_add_user_listener(self):
        bus = EventBus()
        called = []
        
        def listener(event):
            called.append("user_" + event.event_type)
            return False
        
        bus.add_listener("test_event", listener, user=True)
        event = Event("test_event")
        bus.publish_event(event)
        assert "user_test_event" in called

    def test_prepend_listener(self):
        bus = EventBus()
        order = []
        
        def listener1(event):
            order.append(1)
            return False
        
        def listener2(event):
            order.append(2)
            return False
        
        bus.add_listener("test_event", listener1)
        bus.prepend_listener("test_event", listener2)
        event = Event("test_event")
        bus.publish_event(event)
        assert order == [2, 1]

    def test_listener_stop_propagation(self):
        bus = EventBus()
        called = []
        
        def listener1(event):
            called.append(1)
            return True  # Stop propagation
        
        def listener2(event):
            called.append(2)
            return False
        
        bus.add_listener("test_event", listener1)
        bus.add_listener("test_event", listener2)
        event = Event("test_event")
        bus.publish_event(event)
        assert called == [1]  # listener2 should not be called


class TestEVENT:
    def test_post_system_init(self):
        assert EVENT.POST_SYSTEM_INIT.value == "post_system_init"

    def test_before_trading(self):
        assert EVENT.BEFORE_TRADING.value == "before_trading"

    def test_bar(self):
        assert EVENT.BAR.value == "bar"

    def test_tick(self):
        assert EVENT.TICK.value == "tick"

    def test_after_trading(self):
        assert EVENT.AFTER_TRADING.value == "after_trading"

    def test_settlement(self):
        assert EVENT.SETTLEMENT.value == "settlement"

    def test_trade(self):
        assert EVENT.TRADE.value == "trade"

    def test_order_pending_new(self):
        assert EVENT.ORDER_PENDING_NEW.value == "order_pending_new"

    def test_order_creation_pass(self):
        assert EVENT.ORDER_CREATION_PASS.value == "order_creation_pass"

    def test_order_creation_reject(self):
        assert EVENT.ORDER_CREATION_REJECT.value == "order_creation_reject"

    def test_heartbeat(self):
        assert EVENT.HEARTBEAT.value == "heartbeat"

    def test_user(self):
        assert EVENT.USER.value == "user"


class TestParseEvent:
    def test_parse_event_uppercase(self):
        event = parse_event("BAR")
        assert event == EVENT.BAR

    def test_parse_event_lowercase(self):
        event = parse_event("bar")
        assert event == EVENT.BAR

    def test_parse_event_mixed_case(self):
        event = parse_event("Bar")
        assert event == EVENT.BAR

    def test_parse_event_invalid(self):
        with pytest.raises(KeyError):
            parse_event("INVALID_EVENT")


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
