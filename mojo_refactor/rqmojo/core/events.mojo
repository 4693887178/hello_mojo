"""
RQAlpha Mojo - Event System
Ported from rqalpha/core/events.py

EventListener 使用 PythonObject 的原因:
  Mojo 所有集合类型要求元素 Copyable，而捕获非 Copyable 引用的闭包
  是 escaping 且非 ImplicitlyDestructible，无法存入集合。
  PythonObject 天然是 ImplicitlyCopyable，作为桥接类型。
"""

from std.collections import Dict, List
from std.python import Python, PythonObject
from std.reflection import get_base_type_name
from std.utils.variant import Variant


comptime EventValue = Variant[String, Int, Float64, Bool]


@fieldwise_init
struct Event(Writable, Movable):
    var event_type: String
    var attributes: Dict[String, EventValue]

    def __init__(event_type: String) -> Self:
        return Self(event_type, Dict[String, EventValue]())

    def write_to(self, mut writer: Some[Writer]):
        writer.write("event_type:", self.event_type)
        for key in self.attributes:
            var key_str = String(key)
            var value = self.attributes.get(key_str, EventValue(""))
            writer.write(" ", key_str, ":", Self._variant_to_string(value))

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

    def to_python_object(self) raises -> PythonObject:
        var py_dict: PythonObject = {}
        py_dict["event_type"] = self.event_type
        for key in self.attributes:
            var key_str = String(key)
            var value = self.attributes.get(key_str, EventValue(""))
            if value.isa[String]():
                py_dict[key_str] = value[String]
            elif value.isa[Int]():
                py_dict[key_str] = value[Int]
            elif value.isa[Float64]():
                py_dict[key_str] = value[Float64]
            elif value.isa[Bool]():
                py_dict[key_str] = value[Bool]
        return py_dict


comptime EventListener = PythonObject


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
            var py_event = event.to_python_object()
            for listener in self.listeners[event.event_type]:
                var result = listener(py_event)
                if Bool(py=result):
                    return True
        except:
            pass
        return False


@fieldwise_init
struct EVENT(Equatable, ImplicitlyCopyable, Hashable, Writable):
    var name: String
    var value: String

    comptime POST_SYSTEM_INIT = EVENT("POST_SYSTEM_INIT", "post_system_init")
    comptime BEFORE_SYSTEM_RESTORED = EVENT("BEFORE_SYSTEM_RESTORED", "before_system_restored")
    comptime POST_SYSTEM_RESTORED = EVENT("POST_SYSTEM_RESTORED", "post_system_restored")
    comptime POST_USER_INIT = EVENT("POST_USER_INIT", "post_user_init")
    comptime POST_UNIVERSE_CHANGED = EVENT("POST_UNIVERSE_CHANGED", "post_universe_changed")
    comptime PRE_BEFORE_TRADING = EVENT("PRE_BEFORE_TRADING", "pre_before_trading")
    comptime BEFORE_TRADING = EVENT("BEFORE_TRADING", "before_trading")
    comptime POST_BEFORE_TRADING = EVENT("POST_BEFORE_TRADING", "post_before_trading")
    comptime PRE_OPEN_AUCTION = EVENT("PRE_OPEN_AUCTION", "pre_open_auction")
    comptime OPEN_AUCTION = EVENT("OPEN_AUCTION", "open_auction")
    comptime POST_OPEN_AUCTION = EVENT("POST_OPEN_AUCTION", "post_open_auction")
    comptime PRE_BAR = EVENT("PRE_BAR", "pre_bar")
    comptime BAR = EVENT("BAR", "bar")
    comptime POST_BAR = EVENT("POST_BAR", "post_bar")
    comptime PRE_TICK = EVENT("PRE_TICK", "pre_tick")
    comptime TICK = EVENT("TICK", "tick")
    comptime POST_TICK = EVENT("POST_TICK", "post_tick")
    comptime PRE_SCHEDULED = EVENT("PRE_SCHEDULED", "pre_scheduled")
    comptime POST_SCHEDULED = EVENT("POST_SCHEDULED", "post_scheduled")
    comptime PRE_AFTER_TRADING = EVENT("PRE_AFTER_TRADING", "pre_after_trading")
    comptime AFTER_TRADING = EVENT("AFTER_TRADING", "after_trading")
    comptime POST_AFTER_TRADING = EVENT("POST_AFTER_TRADING", "post_after_trading")
    comptime PRE_SETTLEMENT = EVENT("PRE_SETTLEMENT", "pre_settlement")
    comptime SETTLEMENT = EVENT("SETTLEMENT", "settlement")
    comptime POST_SETTLEMENT = EVENT("POST_SETTLEMENT", "post_settlement")
    comptime ORDER_PENDING_NEW = EVENT("ORDER_PENDING_NEW", "order_pending_new")
    comptime ORDER_CREATION_PASS = EVENT("ORDER_CREATION_PASS", "order_creation_pass")
    comptime ORDER_CREATION_REJECT = EVENT("ORDER_CREATION_REJECT", "order_pending_new")
    comptime ORDER_PENDING_CANCEL = EVENT("ORDER_PENDING_CANCEL", "order_pending_cancel")
    comptime ORDER_CANCELLATION_PASS = EVENT("ORDER_CANCELLATION_PASS", "order_cancellation_pass")
    comptime ORDER_CANCELLATION_REJECT = EVENT("ORDER_CANCELLATION_REJECT", "order_order_UNSOLICITED_UPDATE")
    comptime ORDER_UNSOLICITED_UPDATE = EVENT("ORDER_UNSOLICITED_UPDATE", "order_unsolicited_update")
    comptime TRADE = EVENT("TRADE", "trade")
    comptime ON_LINE_PROFILER_RESULT = EVENT("ON_LINE_PROFILER_RESULT", "on_line_profiler_result")
    comptime DO_PERSIST = EVENT("DO_PERSIST", "do_persist")
    comptime DO_RESTORE = EVENT("DO_RESTORE", "do_restore")
    comptime STRATEGY_HOLD_SET = EVENT("STRATEGY_HOLD_SET", "strategy_hold_set")
    comptime STRATEGY_HOLD_CANCELLED = EVENT("STRATEGY_HOLD_CANCELLED", "strategy_hold_canceled")
    comptime HEARTBEAT = EVENT("HEARTBEAT", "heartbeat")
    comptime BEFORE_STRATEGY_RUN = EVENT("BEFORE_STRATEGY_RUN", "before_strategy_run")
    comptime POST_STRATEGY_RUN = EVENT("POST_STRATEGY_RUN", "post_strategy_run")
    comptime USER = EVENT("USER", "user")

    def write_to(self, mut writer: Some[Writer]):
        t"{get_base_type_name[Self]()}.{self.name}".write_to(writer)

    @staticmethod
    def __getitem__(s: String) -> Optional[EVENT]:
        for m in Self.members():
            if m.name == s or m.value == s:
                return m.copy()
        return None

    @staticmethod
    def contains(s: String) -> Bool:
        return Self.__getitem__(s) != None

    @staticmethod
    def members() -> List[EVENT]:
        return [Self.POST_SYSTEM_INIT, Self.BEFORE_SYSTEM_RESTORED,
                Self.POST_SYSTEM_RESTORED, Self.POST_USER_INIT,
                Self.POST_UNIVERSE_CHANGED, Self.PRE_BEFORE_TRADING,
                Self.BEFORE_TRADING, Self.POST_BEFORE_TRADING,
                Self.PRE_OPEN_AUCTION, Self.OPEN_AUCTION,
                Self.POST_OPEN_AUCTION, Self.PRE_BAR, Self.BAR,
                Self.POST_BAR, Self.PRE_TICK, Self.TICK,
                Self.POST_TICK, Self.PRE_SCHEDULED, Self.POST_SCHEDULED,
                Self.PRE_AFTER_TRADING, Self.AFTER_TRADING,
                Self.POST_AFTER_TRADING, Self.PRE_SETTLEMENT,
                Self.SETTLEMENT, Self.POST_SETTLEMENT,
                Self.ORDER_PENDING_NEW, Self.ORDER_CREATION_PASS,
                Self.ORDER_CREATION_REJECT, Self.ORDER_PENDING_CANCEL,
                Self.ORDER_CANCELLATION_PASS, Self.ORDER_CANCELLATION_REJECT,
                Self.ORDER_UNSOLICITED_UPDATE, Self.TRADE,
                Self.ON_LINE_PROFILER_RESULT, Self.DO_PERSIST,
                Self.DO_RESTORE, Self.STRATEGY_HOLD_SET,
                Self.STRATEGY_HOLD_CANCELLED, Self.HEARTBEAT,
                Self.BEFORE_STRATEGY_RUN, Self.POST_STRATEGY_RUN,
                Self.USER]


def parse_event(event_str: String) raises -> EVENT:
    var upper_str = event_str.upper()
    var result = EVENT.__getitem__(upper_str)
    if result != None:
        return result.value()
    raise Error("Unknown event type: " + event_str)
