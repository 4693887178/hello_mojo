from std.collections import List, Dict
from std.memory import ArcPointer


@fieldwise_init
struct Event(Copyable, Movable, Writable):
    var event_type: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Event(", self.event_type, ")")


struct SharedState(Movable):
    var management_fee: Float64

    def __init__(out self):
        self.management_fee = 0.0


struct FnListener(Movable, Copyable):
    """Wraps a closure as a copyable listener using ArcPointer for shared state."""
    var _name: String
    var _state: ArcPointer[SharedState]

    def __init__(out self, name: String, state: ArcPointer[SharedState]):
        self._name = name
        self._state = state

    def __init__(out self, *, copy: Self):
        self._name = copy._name
        self._state = copy._state.copy()

    def call(mut self, event: Event) -> Bool:
        if event.event_type == "POST_SYSTEM_INIT":
            print("[", self._name, "] setting fee via shared state...")
            self._state[].management_fee = 0.0025
            print("[", self._name, "] fee =", self._state[].management_fee)
        return False


struct CounterListener(Movable, Copyable):
    var _prefix: String
    var _count: ArcPointer[Int]

    def __init__(out self, prefix: String, count: ArcPointer[Int]):
        self._prefix = prefix
        self._count = count

    def __init__(out self, *, copy: Self):
        self._prefix = copy._prefix
        self._count = copy._count.copy()

    def call(mut self, event: Event) -> Bool:
        self._count[] += 1
        print("[", self._prefix, "] count=", self._count[])
        return False


comptime EventListener = ArcPointer[FnWrapper]
struct FnWrapper(Movable, Copyable):
    var _tag: Int
    var _fn_listener: ArcPointer[FnListener]
    var _counter_listener: ArcPointer[CounterListener]

    def __init__(out self, var listener: FnListener):
        self._tag = 1
        self._fn_listener = ArcPointer(listener^)
        self._counter_listener = ArcPointer(CounterListener("", ArcPointer[Int](0)))

    def __init__(out self, var listener: CounterListener):
        self._tag = 2
        self._fn_listener = ArcPointer(FnListener("", ArcPointer(SharedState())))
        self._counter_listener = ArcPointer(listener^)

    def __init__(out self, *, copy: Self):
        self._tag = copy._tag
        self._fn_listener = copy._fn_listener.copy()
        self._counter_listener = copy._counter_listener.copy()

    def dispatch(mut self, event: Event) -> Bool:
        if self._tag == 1:
            return self._fn_listener[].call(event)
        else:
            return self._counter_listener[].call(event)


struct EventBus(Movable):
    var listeners: Dict[String, List[ArcPointer[FnWrapper]]]

    def __init__(out self):
        self.listeners = Dict[String, List[ArcPointer[FnWrapper]]]()

    def add_listener(mut self, event_type: String, listener: ArcPointer[FnWrapper]) raises:
        try:
            self.listeners[event_type].append(listener)
        except:
            self.listeners[event_type] = List[ArcPointer[FnWrapper]]()
            self.listeners[event_type].append(listener)

    def publish_event(mut self, event: Event) raises -> Bool:
        try:
            for listener in self.listeners[event.event_type]:
                if listener[].dispatch(event):
                    return True
        except:
            pass
        return False


def main() raises:
    print("=== Pure Mojo EventBus with ArcPointer (no PythonObject) ===\n")

    var env_state = ArcPointer(SharedState())
    var persist_count = ArcPointer[Int](0)

    var bus = EventBus()

    bus.add_listener(
        "POST_SYSTEM_INIT",
        ArcPointer(FnWrapper(FnListener(name="SimulationMod", state=env_state.copy())))
    )

    bus.add_listener(
        "POST_BAR",
        ArcPointer(FnWrapper(CounterListener(prefix="Persist", count=persist_count.copy())))
    )
    bus.add_listener(
        "POST_AFTER_TRADING",
        ArcPointer(FnWrapper(CounterListener(prefix="Persist", count=persist_count.copy())))
    )

    print("--- Publishing POST_SYSTEM_INIT ---")
    bus.publish_event(Event(event_type="POST_SYSTEM_INIT"))
    print("env_state.management_fee:", env_state[].management_fee)

    print("\n--- Publishing POST_BAR ---")
    bus.publish_event(Event(event_type="POST_BAR"))
    print("persist_count:", persist_count[])

    print("\n--- Publishing POST_AFTER_TRADING ---")
    bus.publish_event(Event(event_type="POST_AFTER_TRADING"))
    print("persist_count:", persist_count[])

    print("\n=== Success! Pure Mojo, no Python interop! ===")
