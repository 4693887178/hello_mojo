# test_L00_07_events.mojo
# Module: rqmojo.core.events
# Python: rqalpha.core.events
# Level: L00 - Leaf module
# Dependencies: const

from rqmojo.core.events import (
    EVENT, Event, EventBus, ListenerEntry,
    create_event_bus, parse_event
)
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_event_values(mut self):
        var bar = EVENT.BAR()
        self.check(bar.name == "BAR", "EVENT.BAR name")
        self.check(bar.value == "bar", "EVENT.BAR value")
        
        var tick = EVENT.TICK()
        self.check(tick.name == "TICK", "EVENT.TICK name")
        self.check(tick.value == "tick", "EVENT.TICK value")
        
        var trade = EVENT.TRADE()
        self.check(trade.name == "TRADE", "EVENT.TRADE name")
        self.check(trade.value == "trade", "EVENT.TRADE value")

    fn test_event_equality(mut self):
        var bar1 = EVENT.BAR()
        var bar2 = EVENT.BAR()
        var tick = EVENT.TICK()
        
        self.check(bar1 == bar2, "EVENT.BAR == EVENT.BAR")
        self.check(bar1 != tick, "EVENT.BAR != EVENT.TICK")

    fn test_event_str(mut self):
        var bar = EVENT.BAR()
        self.check(bar.__str__() == "bar", "EVENT.__str__")

    fn test_all_event_types(mut self):
        self.check(EVENT.POST_SYSTEM_INIT().value == "post_system_init", "EVENT.POST_SYSTEM_INIT")
        self.check(EVENT.BEFORE_TRADING().value == "before_trading", "EVENT.BEFORE_TRADING")
        self.check(EVENT.AFTER_TRADING().value == "after_trading", "EVENT.AFTER_TRADING")
        self.check(EVENT.SETTLEMENT().value == "settlement", "EVENT.SETTLEMENT")
        self.check(EVENT.ORDER_PENDING_NEW().value == "order_pending_new", "EVENT.ORDER_PENDING_NEW")
        self.check(EVENT.HEARTBEAT().value == "heartbeat", "EVENT.HEARTBEAT")

    fn test_event_create(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 0, 0)
        var event = Event.create(EVENT.BAR(), dt, "test_data")
        self.check(event.event_type.value == "bar", "Event.create event_type")
        self.check(event.data == "test_data", "Event.create data")

    fn test_event_str_func(mut self):
        var dt = DateTime(2023, 1, 15, 14, 30, 0, 0)
        var event = Event.create(EVENT.BAR(), dt)
        var result = event.__str__()
        self.check(len(result) > 0, "Event.__str__ returns non-empty")

    fn test_listener_entry(mut self):
        var entry = ListenerEntry("test_listener", 10)
        self.check(entry.listener == "test_listener", "ListenerEntry listener")
        self.check(entry.priority == 10, "ListenerEntry priority")

    fn test_event_bus_create(mut self):
        var bus = create_event_bus()
        self.check(bus.listener_count == 0, "EventBus initial listener_count")

    fn test_event_bus_add_listener(mut self):
        var bus = create_event_bus()
        try:
            bus.add_listener(EVENT.BAR(), "listener1")
            self.check(bus.listener_count == 1, "EventBus add_listener count")
        except:
            self.check(False, "EventBus add_listener failed")

    fn test_event_bus_add_user_listener(mut self):
        var bus = create_event_bus()
        try:
            bus.add_listener(EVENT.BAR(), "listener1", user=True)
            self.check(bus.listener_count == 1, "EventBus add_user_listener count")
        except:
            self.check(False, "EventBus add_user_listener failed")

    fn test_event_bus_prepend_listener(mut self):
        var bus = create_event_bus()
        try:
            bus.add_listener(EVENT.BAR(), "listener1")
            bus.prepend_listener(EVENT.BAR(), "listener2")
            self.check(bus.listener_count == 2, "EventBus prepend_listener count")
        except:
            self.check(False, "EventBus prepend_listener failed")

    fn test_event_bus_remove_listener(mut self):
        var bus = create_event_bus()
        try:
            bus.add_listener(EVENT.BAR(), "listener1")
            bus.remove_listener(EVENT.BAR(), "listener1")
            self.check(bus.listener_count == 0, "EventBus remove_listener count")
        except:
            self.check(False, "EventBus remove_listener failed")

    fn test_event_bus_publish(mut self):
        var bus = create_event_bus()
        var dt = DateTime(2023, 1, 15, 14, 30, 0, 0)
        var event = Event.create(EVENT.BAR(), dt)
        try:
            bus.add_listener(EVENT.BAR(), "listener1")
            bus.publish(event)
            self.check(True, "EventBus publish executes")
        except:
            self.check(False, "EventBus publish failed")

    fn test_parse_event(mut self):
        try:
            var result = parse_event("BAR")
            self.check(result.value == "bar", "parse_event BAR")
            
            var result2 = parse_event("bar")
            self.check(result2.value == "bar", "parse_event bar lowercase")
            
            var result3 = parse_event("Bar")
            self.check(result3.value == "bar", "parse_event Bar mixed case")
        except:
            self.check(False, "parse_event failed")

    fn test_parse_event_all_types(mut self):
        try:
            self.check(parse_event("TICK").value == "tick", "parse_event TICK")
            self.check(parse_event("TRADE").value == "trade", "parse_event TRADE")
            self.check(parse_event("HEARTBEAT").value == "heartbeat", "parse_event HEARTBEAT")
        except:
            self.check(False, "parse_event all types failed")

    fn run_all(mut self):
        print("=" * 60)
        print("L00_07_events Module Tests")
        print("=" * 60)
        
        self.test_event_values()
        self.test_event_equality()
        self.test_event_str()
        self.test_all_event_types()
        self.test_event_create()
        self.test_event_str_func()
        self.test_listener_entry()
        self.test_event_bus_create()
        self.test_event_bus_add_listener()
        self.test_event_bus_add_user_listener()
        self.test_event_bus_prepend_listener()
        self.test_event_bus_remove_listener()
        self.test_event_bus_publish()
        self.test_parse_event()
        self.test_parse_event_all_types()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
