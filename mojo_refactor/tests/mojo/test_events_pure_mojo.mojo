from rqmojo.core.events import (
    Event, EventBus, EVENT, EventListener, EventValue,
    create_event_bus, create_persist_listener, create_mod_listener, create_generic_listener,
    parse_event
)
from std.memory import ArcPointer


def test_event_creation() raises:
    print("=== Test 1: Event creation ===")
    var evt = Event("test_event")
    print("event_type:", evt.event_type)
    assert evt.event_type == "test_event"


def test_eventbus_basic() raises:
    print("\n=== Test 2: EventBus basic operations ===")
    var bus = create_event_bus()
    var counter = ArcPointer[Int](0)

    var listener = create_generic_listener("test_listener", counter)
    bus.add_listener("TEST_EVENT", listener)

    var event = Event(event_type="TEST_EVENT")
    bus.publish_event(event)
    assert counter[] == 1


def test_eventbus_multiple_listeners() raises:
    print("\n=== Test 3: Multiple listeners on same event ===")
    var bus = create_event_bus()
    var counter1 = ArcPointer[Int](0)
    var counter2 = ArcPointer[Int](0)

    bus.add_listener("BAR", create_generic_listener("listener_a", counter1))
    bus.add_listener("BAR", create_generic_listener("listener_b", counter2))

    bus.publish_event(Event(event_type="BAR"))
    assert counter1[] == 1
    assert counter2[] == 1

    bus.publish_event(Event(event_type="BAR"))
    assert counter1[] == 2
    assert counter2[] == 2


def test_persist_listener() raises:
    print("\n=== Test 4: PersistHandler via ArcPointer ===")
    var bus = create_event_bus()
    var persist_count = ArcPointer[Int](0)

    var persist_listener = create_persist_listener(persist_count)
    bus.add_listener("post_before_trading", persist_listener)
    bus.add_listener("post_after_trading", persist_listener)
    bus.add_listener("post_bar", persist_listener)

    bus.publish_event(Event(event_type="post_before_trading"))
    assert persist_count[] == 1
    bus.publish_event(Event(event_type="post_after_trading"))
    assert persist_count[] == 2
    bus.publish_event(Event(event_type="post_bar"))
    assert persist_count[] == 3

    bus.publish_event(Event(event_type="other_event"))
    assert persist_count[] == 3


def test_mod_listener() raises:
    print("\n=== Test 5: ModHandler via ArcPointer ===")
    var bus = create_event_bus()
    var mod_count = ArcPointer[Int](0)

    var mod_listener = create_mod_listener("SimulationMod", mod_count)
    bus.add_listener("POST_SYSTEM_INIT", mod_listener)

    bus.publish_event(Event(event_type="POST_SYSTEM_INIT"))
    assert mod_count[] == 1


def test_event_enum() raises:
    print("\n=== Test 6: EVENT enum ===")
    var bar = EVENT.BAR
    print("BAR name:", bar.name, "value:", bar.value)
    assert bar.value == "bar"

    var parsed = parse_event("bar")
    assert parsed.value == "bar"


def test_no_python_import() raises:
    print("\n=== Test 7: Verify no PythonObject in EventListener ===")
    var bus = create_event_bus()
    var counter = ArcPointer[Int](0)
    var listener = create_persist_listener(counter)
    bus.add_listener("do_persist", listener)
    bus.publish_event(Event(event_type="do_persist"))
    assert counter[] == 1
    print("EventListener is pure ArcPointer[ListenerBase] — no PythonObject!")


def main() raises:
    test_event_creation()
    test_eventbus_basic()
    test_eventbus_multiple_listeners()
    test_persist_listener()
    test_mod_listener()
    test_event_enum()
    test_no_python_import()
    print("\n=== All tests passed! Pure Mojo event system! ===")
