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


struct ModListener(Movable):
    var mod_name: String
    var env_state: ArcPointer[SharedState]

    def __init__(out self, mod_name: String, env_state: ArcPointer[SharedState]):
        self.mod_name = mod_name
        self.env_state = env_state

    def on_event(mut self, event: Event) -> Bool:
        if event.event_type == "POST_SYSTEM_INIT":
            print("[", self.mod_name, "] setting management fee...")
            self.env_state[].management_fee = 0.0025
            print("[", self.mod_name, "] fee set to", self.env_state[].management_fee)
        return False


struct PersistListener(Movable):
    var persist_count: ArcPointer[Int]

    def __init__(out self, persist_count: ArcPointer[Int]):
        self.persist_count = persist_count

    def on_event(mut self, event: Event) -> Bool:
        if event.event_type.startswith("POST_"):
            self.persist_count[] += 1
            print("[Persist] count=", self.persist_count[])
        return False


comptime EventListener = ArcPointer[ListenerBase]

struct ListenerBase(Movable):
    var _tag: Int

    def __init__(out self):
        self._tag = 0

    def dispatch(mut self, event: Event) -> Bool:
        return False


struct SimulationModListener(ListenerBase, Movable):
    var _inner: ModListener

    def __init__(out self, inner: ModListener):
        self._inner = inner^

    def dispatch(mut self, event: Event) -> Bool:
        return self._inner.on_event(event)


struct SystemPersistListener(ListenerBase, Movable):
    var _inner: PersistListener

    def __init__(out self, inner: PersistListener):
        self._inner = inner^

    def dispatch(mut self, event: Event) -> Bool:
        return self._inner.on_event(event)


struct EventBus(Movable):
    var listeners: Dict[String, List[ArcPointer[ListenerBase]]]

    def __init__(out self):
        self.listeners = Dict[String, List[ArcPointer[ListenerBase]]]()

    def add_listener(mut self, event_type: String, listener: ArcPointer[ListenerBase]) raises:
        try:
            self.listeners[event_type].append(listener)
        except:
            self.listeners[event_type] = List[ArcPointer[ListenerBase]]()
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
    print("=== Pure Mojo EventBus with ArcPointer ===\n")

    var env_state = ArcPointer(SharedState())
    var persist_count = ArcPointer[Int](0)

    var bus = EventBus()

    var sim_mod_listener = ArcPointer[ListenerBase](
        SimulationModListener(ModListener(
            mod_name="SimulationMod",
            env_state=env_state.copy()
        ))
    )
    bus.add_listener("POST_SYSTEM_INIT", sim_mod_listener)

    var persist_listener = ArcPointer[ListenerBase](
        SystemPersistListener(PersistListener(
            persist_count=persist_count.copy()
        ))
    )

    bus.add_listener("POST_BAR", persist_listener)
    bus.add_listener("POST_AFTER_TRADING", persist_listener)

    print("--- Publishing POST_SYSTEM_INIT ---")
    bus.publish_event(Event(event_type="POST_SYSTEM_INIT"))
    print("env_state.management_fee:", env_state[].management_fee)

    print("\n--- Publishing POST_BAR ---")
    bus.publish_event(Event(event_type="POST_BAR"))
    print("persist_count:", persist_count[])

    print("\n--- Publishing POST_AFTER_TRADING ---")
    bus.publish_event(Event(event_type="POST_AFTER_TRADING"))
    print("persist_count:", persist_count[])

    print("\n=== All done! No PythonObject needed! ===")
