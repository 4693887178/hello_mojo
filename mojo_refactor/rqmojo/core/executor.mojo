"""
RQAlpha Mojo - Executor
Ported from rqalpha/core/executor.py
"""

from std.collections import Dict, List
from rqmojo.const import EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.utils.typing import DateTime, DateTimeDate


@fieldwise_init
struct ExecutorConfig(Copyable, Movable, ImplicitlyCopyable):
    var start_date: DateTime
    var end_date: DateTime
    var frequency: String


@fieldwise_init
struct EventSplitTuple(Copyable, Movable, ImplicitlyCopyable):
    var pre: EVENT
    var main: EVENT
    var post: EVENT


@fieldwise_init
struct Executor(Movable):
    var _current_phase_name: String
    var _last_before_trading_date: Int
    var _event_bus: EventBus
    var _config: ExecutorConfig
    var _calendar_dt_year: Int
    var _calendar_dt_month: Int
    var _calendar_dt_day: Int
    var _trading_dt_year: Int
    var _trading_dt_month: Int
    var _trading_dt_day: Int

    def current_phase(self) -> EXECUTION_PHASE:
        return EXECUTION_PHASE.GLOBAL

    def set_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._current_phase_name = phase.name()

    def get_state(self) -> String:
        var year = self._last_before_trading_date // 10000
        var month = (self._last_before_trading_date % 10000) // 100
        var day = self._last_before_trading_date % 100
        return '{"last_before_trading": "' + String(year) + "-" + String(month) + "-" + String(day) + '"}'

    def set_state(mut self, state: String) -> None:
        pass

    @staticmethod
    def get_event_split_map() -> Dict[String, EventSplitTuple]:
        var result = Dict[String, EventSplitTuple]()
        result["BEFORE_TRADING"] = EventSplitTuple(
            EVENT.PRE_BEFORE_TRADING(),
            EVENT.BEFORE_TRADING(),
            EVENT.POST_BEFORE_TRADING()
        )
        result["BAR"] = EventSplitTuple(
            EVENT.PRE_BAR(),
            EVENT.BAR(),
            EVENT.POST_BAR()
        )
        result["TICK"] = EventSplitTuple(
            EVENT.PRE_TICK(),
            EVENT.TICK(),
            EVENT.POST_TICK()
        )
        result["AFTER_TRADING"] = EventSplitTuple(
            EVENT.PRE_AFTER_TRADING(),
            EVENT.AFTER_TRADING(),
            EVENT.POST_AFTER_TRADING()
        )
        result["SETTLEMENT"] = EventSplitTuple(
            EVENT.PRE_SETTLEMENT(),
            EVENT.SETTLEMENT(),
            EVENT.POST_SETTLEMENT()
        )
        result["OPEN_AUCTION"] = EventSplitTuple(
            EVENT.PRE_OPEN_AUCTION(),
            EVENT.OPEN_AUCTION(),
            EVENT.POST_OPEN_AUCTION()
        )
        return result^

    def run(mut self) -> None:
        pass

    def _handle_event(mut self, event: Event) raises -> None:
        var event_type_name = event.event_type
        
        if event_type_name == EVENT.TICK().name:
            self._ensure_before_trading(event)
            self._split_and_publish(event)
        elif event_type_name == EVENT.BAR().name:
            self._ensure_before_trading(event)
            self._calendar_dt_year = 2024
            self._calendar_dt_month = 1
            self._calendar_dt_day = 1
            self._split_and_publish(event)
        elif event_type_name == EVENT.OPEN_AUCTION().name:
            self._ensure_before_trading(event)
            self._calendar_dt_year = 2024
            self._calendar_dt_month = 1
            self._calendar_dt_day = 1
            self._split_and_publish(event)
        elif event_type_name == EVENT.BEFORE_TRADING().name:
            self._ensure_before_trading(event)
        elif event_type_name == EVENT.AFTER_TRADING().name:
            self._split_and_publish(event)
        else:
            self._event_bus.publish_event(event)

    def _ensure_before_trading(mut self, event: Event) raises -> Bool:
        var trading_date_int = 20240101
        
        if self._last_before_trading_date == trading_date_int:
            return True
        
        if self._last_before_trading_date > 0:
            var settlement_event = Event(EVENT.SETTLEMENT().name)
            self._split_and_publish(settlement_event)
        
        self._last_before_trading_date = trading_date_int
        self._trading_dt_year = 2024
        self._trading_dt_month = 1
        self._trading_dt_day = 1
        
        var before_trading_event = Event(EVENT.BEFORE_TRADING().name)
        self._split_and_publish(before_trading_event)
        return False

    def _split_and_publish(mut self, event: Event) raises -> None:
        self._calendar_dt_year = 2024
        self._calendar_dt_month = 1
        self._calendar_dt_day = 1
        self._trading_dt_year = 2024
        self._trading_dt_month = 1
        self._trading_dt_day = 1
        
        var event_split_map = Self.get_event_split_map()
        var event_type_name = event.event_type
        
        if event_split_map.__contains__(event_type_name):
            var split_tuple = event_split_map[event_type_name]
            var pre_event = Event(split_tuple.pre.name)
            var main_event = Event(split_tuple.main.name)
            var post_event = Event(split_tuple.post.name)
            self._event_bus.publish_event(pre_event)
            self._event_bus.publish_event(main_event)
            self._event_bus.publish_event(post_event)
        else:
            self._event_bus.publish_event(event)

    def get_calendar_dt(self) -> DateTime:
        return DateTime(self._calendar_dt_year, self._calendar_dt_month, self._calendar_dt_day, 0, 0, 0, 0)

    def get_trading_dt(self) -> DateTime:
        return DateTime(self._trading_dt_year, self._trading_dt_month, self._trading_dt_day, 0, 0, 0, 0)


def create_event_bus() -> EventBus:
    return EventBus(
        listeners=Dict[String, List[def(Event) -> Bool]](),
        user_listeners=Dict[String, List[def(Event) -> Bool]]()
    )


def create_executor() -> Executor:
    return Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=create_event_bus(),
        _config=ExecutorConfig(start_date=DateTime(2020, 1, 1, 0, 0, 0, 0), end_date=DateTime(2020, 12, 31, 0, 0, 0, 0), frequency="1d"),
        _calendar_dt_year=1970,
        _calendar_dt_month=1,
        _calendar_dt_day=1,
        _trading_dt_year=1970,
        _trading_dt_month=1,
        _trading_dt_day=1
    )


def create_executor_with_config(config: ExecutorConfig) -> Executor:
    return Executor(
        _current_phase_name="GLOBAL",
        _last_before_trading_date=0,
        _event_bus=create_event_bus(),
        _config=config,
        _calendar_dt_year=1970,
        _calendar_dt_month=1,
        _calendar_dt_day=1,
        _trading_dt_year=1970,
        _trading_dt_month=1,
        _trading_dt_day=1
    )
