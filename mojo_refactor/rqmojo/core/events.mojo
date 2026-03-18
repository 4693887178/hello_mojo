"""
RQAlpha Mojo - Event System
Ported from rqalpha/core/events.py
"""

from collections import Dict, List
from utils import Variant


comptime EventValue = Variant[String, Int, Float64, Bool]


@fieldwise_init
struct Event(Stringable, Movable):
    var event_type: String
    var attributes: Dict[String, EventValue]

    fn __init__(event_type: String) -> Self:
        return Self(event_type, Dict[String, EventValue]())

    fn __str__(self) -> String:
        var parts = List[String]()
        parts.append("event_type:" + self.event_type)
        for key in self.attributes:
            var key_str = String(key)
            var value = self.attributes.get(key_str, EventValue(""))
            parts.append(key_str + ":" + Self._variant_to_string(value))
        return " ".join(parts)

    @staticmethod
    fn _variant_to_string(mut value: EventValue) -> String:
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


comptime EventListener = fn(Event) -> Bool


@fieldwise_init
struct EventBus(Movable):
    var listeners: Dict[String, List[EventListener]]
    var user_listeners: Dict[String, List[EventListener]]

    fn add_listener(mut self, event_type: String, listener: EventListener, user: Bool = False) raises -> None:
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

    fn prepend_listener(mut self, event_type: String, listener: EventListener, user: Bool = False) raises -> None:
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

    fn publish_event(mut self, event: Event) -> Bool:
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
struct EVENT(Stringable, Copyable, Movable, Equatable, ImplicitlyCopyable):
    var name: String
    var value: String

    fn __str__(self) -> String:
        return self.value

    @staticmethod
    fn POST_SYSTEM_INIT() -> EVENT:
        return EVENT("POST_SYSTEM_INIT", "post_system_init")

    @staticmethod
    fn BEFORE_SYSTEM_RESTORED() -> EVENT:
        return EVENT("BEFORE_SYSTEM_RESTORED", "before_system_restored")

    @staticmethod
    fn POST_SYSTEM_RESTORED() -> EVENT:
        return EVENT("POST_SYSTEM_RESTORED", "post_system_restored")

    @staticmethod
    fn POST_USER_INIT() -> EVENT:
        return EVENT("POST_USER_INIT", "post_user_init")

    @staticmethod
    fn POST_UNIVERSE_CHANGED() -> EVENT:
        return EVENT("POST_UNIVERSE_CHANGED", "post_universe_changed")

    @staticmethod
    fn PRE_BEFORE_TRADING() -> EVENT:
        return EVENT("PRE_BEFORE_TRADING", "pre_before_trading")

    @staticmethod
    fn BEFORE_TRADING() -> EVENT:
        return EVENT("BEFORE_TRADING", "before_trading")

    @staticmethod
    fn POST_BEFORE_TRADING() -> EVENT:
        return EVENT("POST_BEFORE_TRADING", "post_before_trading")

    @staticmethod
    fn PRE_OPEN_AUCTION() -> EVENT:
        return EVENT("PRE_OPEN_AUCTION", "pre_open_auction")

    @staticmethod
    fn OPEN_AUCTION() -> EVENT:
        return EVENT("OPEN_AUCTION", "open_auction")

    @staticmethod
    fn POST_OPEN_AUCTION() -> EVENT:
        return EVENT("POST_OPEN_AUCTION", "post_open_auction")

    @staticmethod
    fn PRE_BAR() -> EVENT:
        return EVENT("PRE_BAR", "pre_bar")

    @staticmethod
    fn BAR() -> EVENT:
        return EVENT("BAR", "bar")

    @staticmethod
    fn POST_BAR() -> EVENT:
        return EVENT("POST_BAR", "post_bar")

    @staticmethod
    fn PRE_TICK() -> EVENT:
        return EVENT("PRE_TICK", "pre_tick")

    @staticmethod
    fn TICK() -> EVENT:
        return EVENT("TICK", "tick")

    @staticmethod
    fn POST_TICK() -> EVENT:
        return EVENT("POST_TICK", "post_tick")

    @staticmethod
    fn PRE_SCHEDULED() -> EVENT:
        return EVENT("PRE_SCHEDULED", "pre_scheduled")

    @staticmethod
    fn POST_SCHEDULED() -> EVENT:
        return EVENT("POST_SCHEDULED", "post_scheduled")

    @staticmethod
    fn PRE_AFTER_TRADING() -> EVENT:
        return EVENT("PRE_AFTER_TRADING", "pre_after_trading")

    @staticmethod
    fn AFTER_TRADING() -> EVENT:
        return EVENT("AFTER_TRADING", "after_trading")

    @staticmethod
    fn POST_AFTER_TRADING() -> EVENT:
        return EVENT("POST_AFTER_TRADING", "post_after_trading")

    @staticmethod
    fn PRE_SETTLEMENT() -> EVENT:
        return EVENT("PRE_SETTLEMENT", "pre_settlement")

    @staticmethod
    fn SETTLEMENT() -> EVENT:
        return EVENT("SETTLEMENT", "settlement")

    @staticmethod
    fn POST_SETTLEMENT() -> EVENT:
        return EVENT("POST_SETTLEMENT", "post_settlement")

    @staticmethod
    fn ORDER_PENDING_NEW() -> EVENT:
        return EVENT("ORDER_PENDING_NEW", "order_pending_new")

    @staticmethod
    fn ORDER_CREATION_PASS() -> EVENT:
        return EVENT("ORDER_CREATION_PASS", "order_creation_pass")

    @staticmethod
    fn ORDER_CREATION_REJECT() -> EVENT:
        return EVENT("ORDER_CREATION_REJECT", "order_creation_reject")

    @staticmethod
    fn ORDER_PENDING_CANCEL() -> EVENT:
        return EVENT("ORDER_PENDING_CANCEL", "order_pending_cancel")

    @staticmethod
    fn ORDER_CANCELLATION_PASS() -> EVENT:
        return EVENT("ORDER_CANCELLATION_PASS", "order_cancellation_pass")

    @staticmethod
    fn ORDER_CANCELLATION_REJECT() -> EVENT:
        return EVENT("ORDER_CANCELLATION_REJECT", "order_cancellation_reject")

    @staticmethod
    fn ORDER_UNSOLICITED_UPDATE() -> EVENT:
        return EVENT("ORDER_UNSOLICITED_UPDATE", "order_unsolicited_update")

    @staticmethod
    fn TRADE() -> EVENT:
        return EVENT("TRADE", "trade")

    @staticmethod
    fn ON_LINE_PROFILER_RESULT() -> EVENT:
        return EVENT("ON_LINE_PROFILER_RESULT", "on_line_profiler_result")

    @staticmethod
    fn DO_PERSIST() -> EVENT:
        return EVENT("DO_PERSIST", "do_persist")

    @staticmethod
    fn DO_RESTORE() -> EVENT:
        return EVENT("DO_RESTORE", "do_restore")

    @staticmethod
    fn STRATEGY_HOLD_SET() -> EVENT:
        return EVENT("STRATEGY_HOLD_SET", "strategy_hold_set")

    @staticmethod
    fn STRATEGY_HOLD_CANCELLED() -> EVENT:
        return EVENT("STRATEGY_HOLD_CANCELLED", "strategy_hold_canceled")

    @staticmethod
    fn HEARTBEAT() -> EVENT:
        return EVENT("HEARTBEAT", "heartbeat")

    @staticmethod
    fn BEFORE_STRATEGY_RUN() -> EVENT:
        return EVENT("BEFORE_STRATEGY_RUN", "before_strategy_run")

    @staticmethod
    fn POST_STRATEGY_RUN() -> EVENT:
        return EVENT("POST_STRATEGY_RUN", "post_strategy_run")

    @staticmethod
    fn USER() -> EVENT:
        return EVENT("USER", "user")


fn parse_event(event_str: String) raises -> EVENT:
    var upper_str = event_str.upper()
    
    if upper_str == "POST_SYSTEM_INIT":
        return EVENT.POST_SYSTEM_INIT()
    elif upper_str == "BEFORE_SYSTEM_RESTORED":
        return EVENT.BEFORE_SYSTEM_RESTORED()
    elif upper_str == "POST_SYSTEM_RESTORED":
        return EVENT.POST_SYSTEM_RESTORED()
    elif upper_str == "POST_USER_INIT":
        return EVENT.POST_USER_INIT()
    elif upper_str == "POST_UNIVERSE_CHANGED":
        return EVENT.POST_UNIVERSE_CHANGED()
    elif upper_str == "PRE_BEFORE_TRADING":
        return EVENT.PRE_BEFORE_TRADING()
    elif upper_str == "BEFORE_TRADING":
        return EVENT.BEFORE_TRADING()
    elif upper_str == "POST_BEFORE_TRADING":
        return EVENT.POST_BEFORE_TRADING()
    elif upper_str == "PRE_OPEN_AUCTION":
        return EVENT.PRE_OPEN_AUCTION()
    elif upper_str == "OPEN_AUCTION":
        return EVENT.OPEN_AUCTION()
    elif upper_str == "POST_OPEN_AUCTION":
        return EVENT.POST_OPEN_AUCTION()
    elif upper_str == "PRE_BAR":
        return EVENT.PRE_BAR()
    elif upper_str == "BAR":
        return EVENT.BAR()
    elif upper_str == "POST_BAR":
        return EVENT.POST_BAR()
    elif upper_str == "PRE_TICK":
        return EVENT.PRE_TICK()
    elif upper_str == "TICK":
        return EVENT.TICK()
    elif upper_str == "POST_TICK":
        return EVENT.POST_TICK()
    elif upper_str == "PRE_SCHEDULED":
        return EVENT.PRE_SCHEDULED()
    elif upper_str == "POST_SCHEDULED":
        return EVENT.POST_SCHEDULED()
    elif upper_str == "PRE_AFTER_TRADING":
        return EVENT.PRE_AFTER_TRADING()
    elif upper_str == "AFTER_TRADING":
        return EVENT.AFTER_TRADING()
    elif upper_str == "POST_AFTER_TRADING":
        return EVENT.POST_AFTER_TRADING()
    elif upper_str == "PRE_SETTLEMENT":
        return EVENT.PRE_SETTLEMENT()
    elif upper_str == "SETTLEMENT":
        return EVENT.SETTLEMENT()
    elif upper_str == "POST_SETTLEMENT":
        return EVENT.POST_SETTLEMENT()
    elif upper_str == "ORDER_PENDING_NEW":
        return EVENT.ORDER_PENDING_NEW()
    elif upper_str == "ORDER_CREATION_PASS":
        return EVENT.ORDER_CREATION_PASS()
    elif upper_str == "ORDER_CREATION_REJECT":
        return EVENT.ORDER_CREATION_REJECT()
    elif upper_str == "ORDER_PENDING_CANCEL":
        return EVENT.ORDER_PENDING_CANCEL()
    elif upper_str == "ORDER_CANCELLATION_PASS":
        return EVENT.ORDER_CANCELLATION_PASS()
    elif upper_str == "ORDER_CANCELLATION_REJECT":
        return EVENT.ORDER_CANCELLATION_REJECT()
    elif upper_str == "ORDER_UNSOLICITED_UPDATE":
        return EVENT.ORDER_UNSOLICITED_UPDATE()
    elif upper_str == "TRADE":
        return EVENT.TRADE()
    elif upper_str == "ON_LINE_PROFILER_RESULT":
        return EVENT.ON_LINE_PROFILER_RESULT()
    elif upper_str == "DO_PERSIST":
        return EVENT.DO_PERSIST()
    elif upper_str == "DO_RESTORE":
        return EVENT.DO_RESTORE()
    elif upper_str == "STRATEGY_HOLD_SET":
        return EVENT.STRATEGY_HOLD_SET()
    elif upper_str == "STRATEGY_HOLD_CANCELLED":
        return EVENT.STRATEGY_HOLD_CANCELLED()
    elif upper_str == "HEARTBEAT":
        return EVENT.HEARTBEAT()
    elif upper_str == "BEFORE_STRATEGY_RUN":
        return EVENT.BEFORE_STRATEGY_RUN()
    elif upper_str == "POST_STRATEGY_RUN":
        return EVENT.POST_STRATEGY_RUN()
    elif upper_str == "USER":
        return EVENT.USER()
    else:
        raise Error("Unknown event type: " + event_str)
