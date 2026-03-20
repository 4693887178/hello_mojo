"""
RQAlpha Mojo - Executor
Ported from rqalpha/core/executor.py
"""

from collections import Dict, List
from rqmojo.const import EXECUTION_PHASE, EXECUTION_PHASE_GLOBAL, EXECUTION_PHASE_GLOBAL
from rqmojo.core.events import EVENT, Event, EventBus, create_event_bus
from rqmojo.utils.datetime_func import DateTime, Date


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

    fn current_phase(self) -> EXECUTION_PHASE:
        return EXECUTION_PHASE_GLOBAL

    fn set_phase(mut self, phase: EXECUTION_PHASE) -> None:
        self._current_phase_name = phase.name

    fn get_state(self) -> String:
        var year = self._last_before_trading_date // 10000
        var month = (self._last_before_trading_date % 10000) // 100
        var day = self._last_before_trading_date % 100
        return '{"last_before_trading": "' + String(year) + "-" + String(month) + "-" + String(day) + '"}'

    fn set_state(mut self, state: String) -> None:
        pass

    @staticmethod
    fn get_event_split_map() -> Dict[String, EventSplitTuple]:
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

    fn run(mut self, events: List[Event]) -> None:
        for i in range(len(events)):
            var event = events[i]
            self._handle_event(event)
        
        var end_year = self._config.end_date.year
        var end_month = self._config.end_date.month
        var end_day = self._config.end_date.day
        
        if self._trading_dt_year > 1970:
            if self._trading_dt_year == end_year and self._trading_dt_month == end_month and self._trading_dt_day == end_day:
                self._current_phase_name = "SETTLEMENT"
                var settlement_event = Event.create(EVENT.SETTLEMENT, DateTime(1970, 1, 1, 0, 0, 0, 0))
                self._split_and_publish(settlement_event)
        
        self._current_phase_name = "FINALIZED"

    fn _handle_event(mut self, event: Event) -> None:
        var event_type = event.event_type
        
        if event_type == EVENT.TICK:
            self._ensure_before_trading(event)
            self._split_and_publish(event)
        elif event_type == EVENT.BAR:
            self._ensure_before_trading(event)
            self._calendar_dt_year = event.calendar_dt.year
            self._calendar_dt_month = event.calendar_dt.month
            self._calendar_dt_day = event.calendar_dt.day
            self._split_and_publish(event)
        elif event_type == EVENT.OPEN_AUCTION:
            self._ensure_before_trading(event)
            self._calendar_dt_year = event.calendar_dt.year
            self._calendar_dt_month = event.calendar_dt.month
            self._calendar_dt_day = event.calendar_dt.day
            self._split_and_publish(event)
        elif event_type == EVENT.BEFORE_TRADING:
            self._ensure_before_trading(event)
        elif event_type == EVENT.AFTER_TRADING:
            self._split_and_publish(event)
        else:
            self._event_bus.publish(event)

    fn _ensure_before_trading(mut self, event: Event) -> Bool:
        var trading_year = event.trading_dt.year
        var trading_month = event.trading_dt.month
        var trading_day = event.trading_dt.day
        var trading_date_int = trading_year * 10000 + trading_month * 100 + trading_day
        
        if self._last_before_trading_date == trading_date_int:
            return True
        
        if self._last_before_trading_date > 0:
            self._split_and_publish(Event.create(EVENT.SETTLEMENT, DateTime(1970, 1, 1, 0, 0, 0, 0)))
        
        self._last_before_trading_date = trading_date_int
        self._trading_dt_year = trading_year
        self._trading_dt_month = trading_month
        self._trading_dt_day = trading_day
        
        var before_trading_event = Event.create_with_calendar(
            EVENT.BEFORE_TRADING,
            event.calendar_dt,
            event.trading_dt
        )
        self._split_and_publish(before_trading_event)
        return False

    fn _split_and_publish(mut self, event: Event) -> None:
        self._calendar_dt_year = event.calendar_dt.year
        self._calendar_dt_month = event.calendar_dt.month
        self._calendar_dt_day = event.calendar_dt.day
        self._trading_dt_year = event.trading_dt.year
        self._trading_dt_month = event.trading_dt.month
        self._trading_dt_day = event.trading_dt.day
        
        var event_split_map = Self.get_event_split_map()
        var event_type_name = event.event_type.name
        
        if event_type_name in event_split_map:
            var split_tuple = event_split_map[event_type_name]
            var event_types = List[EVENT]()
            event_types.append(split_tuple.pre)
            event_types.append(split_tuple.main)
            event_types.append(split_tuple.post)
            
            for j in range(len(event_types)):
                var sub_event_type = event_types[j]
                var sub_event = Event.create_with_calendar(
                    sub_event_type,
                    event.calendar_dt,
                    event.trading_dt,
                    event.data
                )
                self._event_bus.publish(sub_event)
        else:
            self._event_bus.publish(event)

    fn get_calendar_dt(self) -> DateTime:
        return DateTime(self._calendar_dt_year, self._calendar_dt_month, self._calendar_dt_day, 0, 0, 0, 0)

    fn get_trading_dt(self) -> DateTime:
        return DateTime(self._trading_dt_year, self._trading_dt_month, self._trading_dt_day, 0, 0, 0, 0)


fn create_executor() -> Executor:
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


fn create_executor_with_config(config: ExecutorConfig) -> Executor:
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
