from std.collections import Dict, List
from std.memory import ArcPointer


@fieldwise_init
struct Event(Copyable, Movable, Writable):
    var event_type: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Event(", self.event_type, ")")


struct SharedEnv(Movable):
    var management_fee: Float64
    var persist_count: Int

    def __init__(out self):
        self.management_fee = 0.0
        self.persist_count = 0


struct PersistHandlerState(Movable):
    var env_ref: ArcPointer[SharedEnv]

    def __init__(out self, env_ref: ArcPointer[SharedEnv]):
        self.env_ref = env_ref

    def should_persist(self, event_type: String) -> Bool:
        return (event_type == "post_before_trading"
            or event_type == "post_after_trading"
            or event_type == "post_bar"
            or event_type == "do_persist"
            or event_type == "post_settlement")

    def on_event(mut self, event: Event) -> Bool:
        if self.should_persist(event.event_type):
            self.env_ref[].persist_count += 1
        return False


struct ModHandlerState(Movable):
    var mod_name: String
    var env_ref: ArcPointer[SharedEnv]

    def __init__(out self, mod_name: String, env_ref: ArcPointer[SharedEnv]):
        self.mod_name = mod_name
        self.env_ref = env_ref

    def on_event(mut self, event: Event) -> Bool:
        if event.event_type == "POST_SYSTEM_INIT":
            self.env_ref[].management_fee = 0.0025
        return False


comptime TAG_PERSIST = 0
comptime TAG_MOD = 1
comptime TAG_GENERIC = 2

comptime EventListener = ArcPointer[ListenerBase]

struct ListenerBase(Movable, Copyable):
    var _tag: Int
    var _persist: ArcPointer[PersistHandlerState]
    var _mod: ArcPointer[ModHandlerState]
    var _generic: ArcPointer[Int]

    def __init__(out self):
        self._tag = TAG_GENERIC
        self._persist = ArcPointer(PersistHandlerState(ArcPointer(SharedEnv())))
        self._mod = ArcPointer(ModHandlerState("", ArcPointer(SharedEnv())))
        self._generic = ArcPointer[Int](0)

    def __init__(out self, *, copy: Self):
        self._tag = copy._tag
        self._persist = copy._persist.copy()
        self._mod = copy._mod.copy()
        self._generic = copy._generic.copy()

    def dispatch(mut self, event: Event) -> Bool:
        if self._tag == TAG_PERSIST:
            return self._persist[].on_event(event)
        elif self._tag == TAG_MOD:
            return self._mod[].on_event(event)
        else:
            self._generic[] += 1
            return False


def create_persist_listener(env: ArcPointer[SharedEnv]) -> EventListener:
    var base = ListenerBase()
    base._tag = TAG_PERSIST
    base._persist = ArcPointer(PersistHandlerState(env))
    return ArcPointer(base^)


def create_mod_listener(mod_name: String, env: ArcPointer[SharedEnv]) -> EventListener:
    var base = ListenerBase()
    base._tag = TAG_MOD
    base._mod = ArcPointer(ModHandlerState(mod_name, env))
    return ArcPointer(base^)


struct EventBus(Movable):
    var listeners: Dict[String, List[EventListener]]

    def __init__(out self):
        self.listeners = Dict[String, List[EventListener]]()

    def add_listener(mut self, event_type: String, listener: EventListener) raises:
        try:
            self.listeners[event_type].append(listener)
        except:
            self.listeners[event_type] = List[EventListener]()
            self.listeners[event_type].append(listener)

    def publish_event(mut self, event: Event) raises -> Bool:
        try:
            for listener in self.listeners[event.event_type]:
                if listener[].dispatch(event):
                    return True
        except:
            pass
        return False


def test_full_event_system_lifecycle() raises:
    print("=== Integration Test: Full Pure Mojo Event System ===\n")

    var env = ArcPointer(SharedEnv())
    print("[INIT] env.management_fee=", env[].management_fee)
    print("[INIT] env.persist_count=", env[].persist_count)

    var bus = EventBus()

    bus.add_listener("POST_SYSTEM_INIT", create_mod_listener("SimulationMod", env))
    bus.add_listener("post_before_trading", create_persist_listener(env))
    bus.add_listener("post_after_trading", create_persist_listener(env))
    bus.add_listener("post_bar", create_persist_listener(env))

    print("\n--- [1] POST_SYSTEM_INIT ---")
    _ = bus.publish_event(Event(event_type="POST_SYSTEM_INIT"))
    assert env[].management_fee == 0.0025
    print("management_fee =", env[].management_fee, "✓ (shared state modified via ArcPointer)")

    print("\n--- [2] POST_BEFORE_TRADING ---")
    _ = bus.publish_event(Event(event_type="post_before_trading"))
    assert env[].persist_count == 1

    print("\n--- [3] POST_BAR (x2) ---")
    _ = bus.publish_event(Event(event_type="post_bar"))
    _ = bus.publish_event(Event(event_type="post_bar"))
    assert env[].persist_count == 3

    print("\n--- [4] POST_AFTER_TRADING ---")
    _ = bus.publish_event(Event(event_type="post_after_trading"))
    assert env[].persist_count == 4

    print("\n--- [5] Non-persist event (ignored by persist listener) ---")
    _ = bus.publish_event(Event(event_type="SOME_OTHER_EVENT"))
    assert env[].persist_count == 4

    print("\n=== Final State ===")
    print("  management_fee:", env[].management_fee, "(expected: 0.0025)")
    print("  persist_count:", env[].persist_count, "(expected: 4)")

    assert env[].management_fee == 0.0025
    assert env[].persist_count == 4

    print("\n=== ALL ASSERTIONS PASSED! ===")
    print("  ✓ ArcPointer provides shared mutable state")
    print("  ✓ ListenerBase is Copyable (stored in List)")
    print("  ✓ EventBus.dispatch routes to correct handler")
    print("  ✓ No PythonObject used anywhere")
    print("  ✓ Reference semantics work correctly")


def main() raises:
    test_full_event_system_lifecycle()
