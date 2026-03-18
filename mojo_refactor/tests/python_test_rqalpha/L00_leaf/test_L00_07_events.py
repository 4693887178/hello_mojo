# test_L00_07_events.py
# Module: rqalpha.core.events
# Mojo: rqmojo.core.events
# Level: L00 - Leaf module
# Dependencies: const

import pytest
from rqalpha.core import events
from rqalpha.const import EXECUTION_PHASE


class TestL00Events:
    """L00 - events module tests"""

    class TestEvent:
        """Event class tests"""

        def test_event_init(self):
            """Test Event initialization"""
            event = events.Event(events.EVENT.BAR, **{"bar": "test"})
            assert event.event_type == events.EVENT.BAR

        def test_event_repr(self):
            """Test Event __repr__"""
            event = events.Event(events.EVENT.BAR, **{"bar": "test"})
            result = repr(event)
            assert "bar" in result

    class TestEventBus:
        """EventBus class tests"""

        def test_event_bus_init(self):
            """Test EventBus initialization"""
            bus = events.EventBus()
            assert bus._listeners is not None
            assert bus._user_listeners is not None

        def test_add_listener(self):
            """Test add_listener"""
            bus = events.EventBus()
            called = []
            def listener(event):
                called.append(event)
                return False
            
            bus.add_listener(events.EVENT.BAR, listener)
            event = events.Event(events.EVENT.BAR)
            bus.publish_event(event)
            assert len(called) == 1

        def test_add_user_listener(self):
            """Test add_listener with user=True"""
            bus = events.EventBus()
            called = []
            def listener(event):
                called.append(event)
                return False
            
            bus.add_listener(events.EVENT.BAR, listener, user=True)
            event = events.Event(events.EVENT.BAR)
            bus.publish_event(event)
            assert len(called) == 1

        def test_prepend_listener(self):
            """Test prepend_listener"""
            bus = events.EventBus()
            order = []
            def listener1(event):
                order.append(1)
                return False
            def listener2(event):
                order.append(2)
                return False
            
            bus.add_listener(events.EVENT.BAR, listener1)
            bus.prepend_listener(events.EVENT.BAR, listener2)
            event = events.Event(events.EVENT.BAR)
            bus.publish_event(event)
            assert order == [2, 1]

        def test_listener_stops_propagation(self):
            """Test listener returning True stops propagation"""
            bus = events.EventBus()
            called = []
            def listener1(event):
                called.append(1)
                return True
            def listener2(event):
                called.append(2)
                return False
            
            bus.add_listener(events.EVENT.BAR, listener1)
            bus.add_listener(events.EVENT.BAR, listener2)
            event = events.Event(events.EVENT.BAR)
            bus.publish_event(event)
            assert called == [1]

    class TestEVENT:
        """EVENT enum tests"""

        def test_event_values(self):
            """Test EVENT enum values"""
            assert events.EVENT.BAR.value == "bar"
            assert events.EVENT.TICK.value == "tick"
            assert events.EVENT.TRADE.value == "trade"

        def test_event_contains(self):
            """Test EVENT contains"""
            assert "BAR" in events.EVENT.__members__

    class TestParseEvent:
        """parse_event function tests"""

        def test_parse_event_upper(self):
            """Test parse_event with uppercase"""
            result = events.parse_event("BAR")
            assert result == events.EVENT.BAR

        def test_parse_event_lower(self):
            """Test parse_event with lowercase"""
            result = events.parse_event("bar")
            assert result == events.EVENT.BAR

        def test_parse_event_mixed(self):
            """Test parse_event with mixed case"""
            result = events.parse_event("Bar")
            assert result == events.EVENT.BAR

    class TestModuleStructure:
        """Module structure tests"""

        def test_event_class_exists(self):
            """Test Event class exists"""
            assert hasattr(events, 'Event')

        def test_event_bus_class_exists(self):
            """Test EventBus class exists"""
            assert hasattr(events, 'EventBus')

        def test_event_enum_exists(self):
            """Test EVENT enum exists"""
            assert hasattr(events, 'EVENT')

        def test_parse_event_exists(self):
            """Test parse_event function exists"""
            assert hasattr(events, 'parse_event')
