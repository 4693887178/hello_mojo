"""
RQAlpha Mojo - Event System
Ported from rqalpha/core/events.py
"""

from std.collections import Dict, List
from std.utils.variant import Variant


comptime EventValue = Variant[String, Int, Float64, Bool]


@fieldwise_init
struct Event(Stringable, Movable):
    var event_type: String
    var attributes: Dict[String, EventValue]

    def __init__(event_type: String) -> Self:
        return Self(event_type, Dict[String, EventValue]())

    def __str__(self) -> String:
        var parts = List[String]()
        parts.append("event_type:" + self.event_type)
        for key in self.attributes:
            var key_str = String(key)
            var value = self.attributes.get(key_str, EventValue(""))
            parts.append(key_str + ":" + Self._variant_to_string(value))
        return " ".join(parts)

    @staticmethod
    def _variant_to_string(mut value: EventValue) -> String:
        if value.isa[String]():
            return value[String]
        elif value.isa[Int]():
            return String(value[Int])
        elif value.isa[Float64]():
            return String(value[Float64])
        elif value.isa[Bool]():
            return String(value[Bool])
        else:
            return ""


comptime EventListener = def(Event) -> Bool


@fieldwise_init
struct EventBus(Movable):
    var listeners: Dict[String, List[EventListener]]
    var user_listeners: Dict[String, List[EventListener]]
    
    def __init__(out self):
        self.listeners = Dict[String, List[EventListener]]()
        self.user_listeners = Dict[String, List[EventListener]]()

    def add_listener(mut self, event_type: String, listener: EventListener, user: Bool = False) raises -> None:
        if user:
            try:
                self.user_listeners[event_type].append(listener)
            except:
                self.user_listeners[event_type] = List[EventListener]()
                self.user_listeners[event_type].append(listener)
        else:
            try:
                self.listeners[event_type].append(listener)
            except:
                self.listeners[event_type] = List[EventListener]()
                self.listeners[event_type].append(listener)

    def prepend_listener(mut self, event_type: String, listener: EventListener, user: Bool = False) raises -> None:
        if user:
            try:
                var new_vec = List[EventListener]()
                new_vec.append(listener)
                for entry in self.user_listeners[event_type]:
                    new_vec.append(entry)
                self.user_listeners[event_type] = new_vec^
            except:
                self.user_listeners[event_type] = List[EventListener]()
                self.user_listeners[event_type].append(listener)
        else:
            try:
                var new_vec = List[EventListener]()
                new_vec.append(listener)
                for entry in self.listeners[event_type]:
                    new_vec.append(entry)
                self.listeners[event_type] = new_vec^
            except:
                self.listeners[event_type] = List[EventListener]()
                self.listeners[event_type].append(listener)

    def publish_event(mut self, event: Event) -> Bool:
        try:
            for listener in self.listeners[event.event_type]:
                if listener(event):
                    return True
        except:
            pass

        try:
            for listener in self.user_listeners[event.event_type]:
                _ = listener(event)
        except:
            pass

        return False


@fieldwise_init
struct EVENT(Writable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.value)

    @staticmethod
    def POST_SYSTEM_INIT() -> EVENT:
        return EVENT("POST_SYSTEM_INIT", "post_system_init")

    @staticmethod
    def BEFORE_SYSTEM_RESTORED() -> EVENT:
        return EVENT("BEFORE_SYSTEM_RESTORED", "before_system_restored")

    @staticmethod
    def POST_SYSTEM_RESTORED() -> EVENT:
        return EVENT("POST_SYSTEM_RESTORED", "post_system_restored")

    @staticmethod
    def POST_USER_INIT() -> EVENT:
        return EVENT("POST_USER_INIT", "post_user_init")

    @staticmethod
    def POST_UNIVERSE_CHANGED() -> EVENT:
        return EVENT("POST_UNIVERSE_CHANGED", "post_universe_changed")

    @staticmethod
    def PRE_BEFORE_TRADING() -> EVENT:
        return EVENT("PRE_BEFORE_TRADING", "pre_before_trading")

    @staticmethod
    def BEFORE_TRADING() -> EVENT:
        return EVENT("BEFORE_TRADING", "before_trading")

    @staticmethod
    def POST_BEFORE_TRADING() -> EVENT:
        return EVENT("POST_BEFORE_TRADING", "post_before_trading")

    @staticmethod
    def PRE_OPEN_AUCTION() -> EVENT:
        return EVENT("PRE_OPEN_AUCTION", "pre_open_auction")

    @staticmethod
    def OPEN_AUCTION() -> EVENT:
        return EVENT("OPEN_AUCTION", "open_auction")

    @staticmethod
    def POST_OPEN_AUCTION() -> EVENT:
        return EVENT("POST_OPEN_AUCTION", "post_open_auction")

    @staticmethod
    def PRE_BAR() -> EVENT:
        return EVENT("PRE_BAR", "pre_bar")

    @staticmethod
    def BAR() -> EVENT:
        return EVENT("BAR", "bar")

    @staticmethod
    def POST_BAR() -> EVENT:
        return EVENT("POST_BAR", "post_bar")

    @staticmethod
    def PRE_TICK() -> EVENT:
        return EVENT("PRE_TICK", "pre_tick")

    @staticmethod
    def TICK() -> EVENT:
        return EVENT("TICK", "tick")

    @staticmethod
    def POST_TICK() -> EVENT:
        return EVENT("POST_TICK", "post_tick")

    @staticmethod
    def PRE_SCHEDULED() -> EVENT:
        return EVENT("PRE_SCHEDULED", "pre_scheduled")

    @staticmethod
    def POST_SCHEDULED() -> EVENT:
        return EVENT("POST_SCHEDULED", "post_scheduled")

    @staticmethod
    def PRE_AFTER_TRADING() -> EVENT:
        return EVENT("PRE_AFTER_TRADING", "pre_after_trading")

    @staticmethod
    def AFTER_TRADING() -> EVENT:
        return EVENT("AFTER_TRADING", "after_trading")

    @staticmethod
    def POST_AFTER_TRADING() -> EVENT:
        return EVENT("POST_AFTER_TRADING", "post_after_trading")

    @staticmethod
    def PRE_SETTLEMENT() -> EVENT:
        return EVENT("PRE_SETTLEMENT", "pre_settlement")

    @staticmethod
    def SETTLEMENT() -> EVENT:
        return EVENT("SETTLEMENT", "settlement")

    @staticmethod
    def POST_SETTLEMENT() -> EVENT:
        return EVENT("POST_SETTLEMENT", "post_settlement")

    @staticmethod
    def ORDER_PENDING_NEW() -> EVENT:
        return EVENT("ORDER_PENDING_NEW", "order_pending_new")

    @staticmethod
    def ORDER_CREATION_PASS() -> EVENT:
        return EVENT("ORDER_CREATION_PASS", "order_creation_pass")

    @staticmethod
    def ORDER_CREATION_REJECT() -> EVENT:
        return EVENT("ORDER_CREATION_REJECT", "order_creation_reject")

    @staticmethod
    def ORDER_PENDING_CANCEL() -> EVENT:
        return EVENT("ORDER_PENDING_CANCEL", "order_pending_cancel")

    @staticmethod
    def ORDER_CANCELLATION_PASS() -> EVENT:
        return EVENT("ORDER_CANCELLATION_PASS", "order_cancellation_pass")

    @staticmethod
    def ORDER_CANCELLATION_REJECT() -> EVENT:
        return EVENT("ORDER_CANCELLATION_REJECT", "order_cancellation_reject")

    @staticmethod
    def ORDER_UNSOLICITED_UPDATE() -> EVENT:
        return EVENT("ORDER_UNSOLICITED_UPDATE", "order_unsolicited_update")

    @staticmethod
    def TRADE() -> EVENT:
        return EVENT("TRADE", "trade")

    @staticmethod
    def ON_LINE_PROFILER_RESULT() -> EVENT:
        return EVENT("ON_LINE_PROFILER_RESULT", "on_line_profiler_result")

    @staticmethod
    def DO_PERSIST() -> EVENT:
        return EVENT("DO_PERSIST", "do_persist")

    @staticmethod
    def DO_RESTORE() -> EVENT:
        return EVENT("DO_RESTORE", "do_restore")

    @staticmethod
    def STRATEGY_HOLD_SET() -> EVENT:
        return EVENT("STRATEGY_HOLD_SET", "strategy_hold_set")

    @staticmethod
    def STRATEGY_HOLD_CANCELLED() -> EVENT:
        return EVENT("STRATEGY_HOLD_CANCELLED", "strategy_hold_canceled")

    @staticmethod
    def HEARTBEAT() -> EVENT:
        return EVENT("HEARTBEAT", "heartbeat")

    @staticmethod
    def BEFORE_STRATEGY_RUN() -> EVENT:
        return EVENT("BEFORE_STRATEGY_RUN", "before_strategy_run")

    @staticmethod
    def POST_STRATEGY_RUN() -> EVENT:
        return EVENT("POST_STRATEGY_RUN", "post_strategy_run")

    @staticmethod
    def USER() -> EVENT:
        return EVENT("USER", "user")


def _get_event_map() -> Dict[String, EVENT]:
    var m = Dict[String, EVENT]()
    m["POST_SYSTEM_INIT"] = EVENT.POST_SYSTEM_INIT()
    m["BEFORE_SYSTEM_RESTORED"] = EVENT.BEFORE_SYSTEM_RESTORED()
    m["POST_SYSTEM_RESTORED"] = EVENT.POST_SYSTEM_RESTORED()
    m["POST_USER_INIT"] = EVENT.POST_USER_INIT()
    m["POST_UNIVERSE_CHANGED"] = EVENT.POST_UNIVERSE_CHANGED()
    m["PRE_BEFORE_TRADING"] = EVENT.PRE_BEFORE_TRADING()
    m["BEFORE_TRADING"] = EVENT.BEFORE_TRADING()
    m["POST_BEFORE_TRADING"] = EVENT.POST_BEFORE_TRADING()
    m["PRE_OPEN_AUCTION"] = EVENT.PRE_OPEN_AUCTION()
    m["OPEN_AUCTION"] = EVENT.OPEN_AUCTION()
    m["POST_OPEN_AUCTION"] = EVENT.POST_OPEN_AUCTION()
    m["PRE_BAR"] = EVENT.PRE_BAR()
    m["BAR"] = EVENT.BAR()
    m["POST_BAR"] = EVENT.POST_BAR()
    m["PRE_TICK"] = EVENT.PRE_TICK()
    m["TICK"] = EVENT.TICK()
    m["POST_TICK"] = EVENT.POST_TICK()
    m["PRE_SCHEDULED"] = EVENT.PRE_SCHEDULED()
    m["POST_SCHEDULED"] = EVENT.POST_SCHEDULED()
    m["PRE_AFTER_TRADING"] = EVENT.PRE_AFTER_TRADING()
    m["AFTER_TRADING"] = EVENT.AFTER_TRADING()
    m["POST_AFTER_TRADING"] = EVENT.POST_AFTER_TRADING()
    m["PRE_SETTLEMENT"] = EVENT.PRE_SETTLEMENT()
    m["SETTLEMENT"] = EVENT.SETTLEMENT()
    m["POST_SETTLEMENT"] = EVENT.POST_SETTLEMENT()
    m["ORDER_PENDING_NEW"] = EVENT.ORDER_PENDING_NEW()
    m["ORDER_CREATION_PASS"] = EVENT.ORDER_CREATION_PASS()
    m["ORDER_CREATION_REJECT"] = EVENT.ORDER_CREATION_REJECT()
    m["ORDER_PENDING_CANCEL"] = EVENT.ORDER_PENDING_CANCEL()
    m["ORDER_CANCELLATION_PASS"] = EVENT.ORDER_CANCELLATION_PASS()
    m["ORDER_CANCELLATION_REJECT"] = EVENT.ORDER_CANCELLATION_REJECT()
    m["ORDER_UNSOLICITED_UPDATE"] = EVENT.ORDER_UNSOLICITED_UPDATE()
    m["TRADE"] = EVENT.TRADE()
    m["ON_LINE_PROFILER_RESULT"] = EVENT.ON_LINE_PROFILER_RESULT()
    m["DO_PERSIST"] = EVENT.DO_PERSIST()
    m["DO_RESTORE"] = EVENT.DO_RESTORE()
    m["STRATEGY_HOLD_SET"] = EVENT.STRATEGY_HOLD_SET()
    m["STRATEGY_HOLD_CANCELLED"] = EVENT.STRATEGY_HOLD_CANCELLED()
    m["HEARTBEAT"] = EVENT.HEARTBEAT()
    m["BEFORE_STRATEGY_RUN"] = EVENT.BEFORE_STRATEGY_RUN()
    m["POST_STRATEGY_RUN"] = EVENT.POST_STRATEGY_RUN()
    m["USER"] = EVENT.USER()
    return m^


def parse_event(event_str: String) raises -> EVENT:
    var upper_str = event_str.upper()
    var event_map = _get_event_map()
    if event_map.__contains__(upper_str):
        return event_map[upper_str]
    raise Error("Unknown event type: " + event_str)


def create_event_bus() -> EventBus:
    return EventBus(
        listeners=Dict[String, List[EventListener]](),
        user_listeners=Dict[String, List[EventListener]]()
    )
