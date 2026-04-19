"""
RQAlpha Mojo - Executor
Ported from rqalpha/core/executor.py

Design Notes (vs Python original):
  Python: Executor(env) delegates to env.config/env.event_bus/env.data_proxy
  Mojo:  Self-contained Executor with injected config/bus/date_proxy callbacks

Key Behavioral Parity:
  - run() iterates events, dispatches by event_type matching Python exactly
  - _ensure_before_trading: same settlement/before_trading publishing order
  - _split_and_publish: same pre/main/post triplet pattern
  - get_state/set_state: JSON-compatible string serialization
"""

from std.collections import Dict, List, Optional
from std.utils.variant import Variant
from rqmojo.const import EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event, EventBus


comptime ExecutorEventValue = Variant[String, Int, Float64, Bool]


@fieldwise_init
struct ExecutorConfig(Movable):
    var start_date: Int
    var end_date: Int
    var frequency: String
    var is_hold: Bool


@fieldwise_init
struct EventSplitTuple(Copyable, Movable):
    var pre: EVENT
    var main: EVENT
    var post: EVENT


struct DateProxyInterface(Movable):
    var _fn_get_previous_trading_date: fn(Int) -> Int

    def __init__(out self, fn_get_previous_trading_date: fn(Int) -> Int):
        self._fn_get_previous_trading_date = fn_get_previous_trading_date


def default_date_proxy_fn(date_int: Int) -> Int:
    return date_int - 1


@fieldwise_init
struct Executor(Movable):
    var _current_phase_name: String
    var _last_before_trading_date: Int
    var _event_bus: EventBus
    var _config: ExecutorConfig
    var _calendar_dt: Int
    var _trading_dt: Int
    var _date_proxy: DateProxyInterface

    def current_phase(self) -> EXECUTION_PHASE:
        return EXECUTION_PHASE.GLOBAL

    def set_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._current_phase_name = phase.name

    def get_state(self) -> String:
        if self._last_before_trading_date == 0:
            return '{"last_before_trading": null}'
        var year = self._last_before_trading_date // 10000
        var month = (self._last_before_trading_date % 10000) // 100
        var day = self._last_before_trading_date % 100
        return '{"last_before_trading": "' + String(year) + "-" + String(month) + "-" + String(day) + '"}'

    def set_state(mut self, state: String) raises -> None:
        if state == "" or state == "{}" or state == "null":
            self._last_before_trading_date = 0
            return
        var start_idx = state.find('"last_before_trading":')
        if start_idx == -1:
            self._last_before_trading_date = 0
            return
        var val_start = state.find('"', start_idx + 21)
        if val_start == -1:
            self._last_before_trading_date = 0
            return
        val_start += 1
        if len(state) > val_start and (state[byte=val_start] == 'n' or state[byte=val_start] == 'N'):
            self._last_before_trading_date = 0
            return
        var val_end = state.find('"', val_start)
        if val_end == -1:
            self._last_before_trading_date = 0
            return
        var date_str = state[byte=val_start:val_end]
        var parts = date_str.split("-")
        if len(parts) == 3:
            var y = Int(parts[0])
            var m = Int(parts[1])
            var d = Int(parts[2])
            self._last_before_trading_date = y * 10000 + m * 100 + d
        else:
            self._last_before_trading_date = 0

    @staticmethod
    def get_event_split_map() -> Dict[String, EventSplitTuple]:
        var result = Dict[String, EventSplitTuple]()
        result["BEFORE_TRADING"] = EventSplitTuple(
            EVENT.PRE_BEFORE_TRADING,
            EVENT.BEFORE_TRADING,
            EVENT.POST_BEFORE_TRADING
        )
        result["BAR"] = EventSplitTuple(
            EVENT.PRE_BAR,
            EVENT.BAR,
            EVENT.POST_BAR
        )
        result["TICK"] = EventSplitTuple(
            EVENT.PRE_TICK,
            EVENT.TICK,
            EVENT.POST_TICK
        )
        result["AFTER_TRADING"] = EventSplitTuple(
            EVENT.PRE_AFTER_TRADING,
            EVENT.AFTER_TRADING,
            EVENT.POST_AFTER_TRADING
        )
        result["SETTLEMENT"] = EventSplitTuple(
            EVENT.PRE_SETTLEMENT,
            EVENT.SETTLEMENT,
            EVENT.POST_SETTLEMENT
        )
        result["OPEN_AUCTION"] = EventSplitTuple(
            EVENT.PRE_OPEN_AUCTION,
            EVENT.OPEN_AUCTION,
            EVENT.POST_OPEN_AUCTION
        )
        return result^

    def run(mut self, events: List[Event]) raises -> None:
        for event in events:
            var event_type_name = event.event_type
            if event_type_name == EVENT.TICK.name:
                _ = self._ensure_before_trading(event)
                self._split_and_publish(event)
            elif event_type_name == EVENT.BAR.name:
                _ = self._ensure_before_trading(event)
                self._update_time_from_event(event)
                self._split_and_publish(event)
            elif event_type_name == EVENT.OPEN_AUCTION.name:
                _ = self._ensure_before_trading(event)
                self._update_time_from_event(event)
                self._split_and_publish(event)
            elif event_type_name == EVENT.BEFORE_TRADING.name:
                _ = self._ensure_before_trading(event)
            elif event_type_name == EVENT.AFTER_TRADING.name:
                self._split_and_publish(event)
            else:
                _ = self._event_bus.publish_event(event)

        if self._trading_dt == self._config.end_date:
            var settlement_event = Event(EVENT.SETTLEMENT.name)
            self._split_and_publish(settlement_event)

    def _update_time_from_event(mut self, event: Event) -> None:
        var cal_attr = event.attributes.get("calendar_dt", ExecutorEventValue(0))
        if cal_attr.isa[Int]():
            self._calendar_dt = cal_attr[Int]
        var trd_attr = event.attributes.get("trading_dt", ExecutorEventValue(0))
        if trd_attr.isa[Int]():
            self._trading_dt = trd_attr[Int]

    def _ensure_before_trading(mut self, event: Event) raises -> Bool:
        var trading_date_int: Int = 0
        var trd_attr = event.attributes.get("trading_dt", ExecutorEventValue(0))
        if trd_attr.isa[Int]():
            trading_date_int = trd_attr[Int]

        if self._last_before_trading_date == trading_date_int or self._config.is_hold:
            return True

        if self._last_before_trading_date > 0:
            prev_date = self._date_proxy._fn_get_previous_trading_date(trading_date_int)
            if self._trading_dt != prev_date:
                self._calendar_dt = prev_date
                self._trading_dt = prev_date
            var settlement_event = Event(EVENT.SETTLEMENT.name)
            self._split_and_publish(settlement_event)

        self._last_before_trading_date = trading_date_int
        var cal_attr = event.attributes.get("calendar_dt", ExecutorEventValue(0))
        if cal_attr.isa[Int]():
            self._calendar_dt = cal_attr[Int]
        self._trading_dt = trading_date_int

        var before_trading_event = Event(EVENT.BEFORE_TRADING.name)
        before_trading_event.attributes["calendar_dt"] = ExecutorEventValue(self._calendar_dt)
        before_trading_event.attributes["trading_dt"] = ExecutorEventValue(self._trading_dt)
        self._split_and_publish(before_trading_event)
        return False

    def _split_and_publish(mut self, event: Event) raises -> None:
        var cal_attr = event.attributes.get("calendar_dt", ExecutorEventValue(0))
        if cal_attr.isa[Int]():
            self._calendar_dt = cal_attr[Int]
        var trd_attr = event.attributes.get("trading_dt", ExecutorEventValue(0))
        if trd_attr.isa[Int]():
            self._trading_dt = trd_attr[Int]

        var event_split_map = Self.get_event_split_map()
        var event_type_name = event.event_type

        if event_split_map.__contains__(event_type_name):
            var split_tuple = event_split_map[event_type_name].copy()
            var pre_event = copy_event_with_type(event, split_tuple.pre.name)
            var main_event = copy_event_with_type(event, split_tuple.main.name)
            var post_event = copy_event_with_type(event, split_tuple.post.name)
            _ = self._event_bus.publish_event(pre_event)
            _ = self._event_bus.publish_event(main_event)
            _ = self._event_bus.publish_event(post_event)
        else:
            _ = self._event_bus.publish_event(event)

    def get_calendar_dt(self) -> Int:
        return self._calendar_dt

    def get_trading_dt(self) -> Int:
        return self._trading_dt

    def get_last_before_trading_date(self) -> Int:
        return self._last_before_trading_date


def copy_event_with_type(source: Event, new_type: String) raises -> Event:
    var e = Event(new_type)
    for key in source.attributes:
        var val = source.attributes[key]
        if val.isa[String]():
            e.attributes[key] = ExecutorEventValue(val[String])
        elif val.isa[Int]():
            e.attributes[key] = ExecutorEventValue(val[Int])
        elif val.isa[Float64]():
            e.attributes[key] = ExecutorEventValue(val[Float64])
        elif val.isa[Bool]():
            e.attributes[key] = ExecutorEventValue(val[Bool])
    return e^


def create_event_bus() -> EventBus:
    return EventBus()


def create_executor() -> Executor:
    return Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=create_event_bus(),
        _config=ExecutorConfig(start_date=20200101, end_date=20201231, frequency="1d", is_hold=False),
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )


def create_executor_with_config(config: ExecutorConfig) -> Executor:
    return Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=create_event_bus(),
        _config=ExecutorConfig(
            start_date=config.start_date,
            end_date=config.end_date,
            frequency=config.frequency,
            is_hold=config.is_hold
        ),
        _calendar_dt=0,
        _trading_dt=0,
        _date_proxy=DateProxyInterface(default_date_proxy_fn)
    )
