"""
RQAlpha Mojo - Simulation Event Source
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_event_source.py
"""

from rqmojo.const import EXECUTION_PHASE, RUN_TYPE, DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.model.tick import TickObject
from rqmojo.model.instrument import Instrument


@fieldwise_init
struct Event(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var event_type: String
    var calendar_dt: DateTime
    var trading_dt: DateTime
    var order_book_id: String
    
    def __str__(self) -> String:
        return "Event(" + self.event_type + ")"


@fieldwise_init
struct SimulationEventSource(Movable):
    var _start_date: DateTime
    var _end_date: DateTime
    var _frequency: String
    var _events: List[Event]
    
    def add_event(mut self, event: Event) -> None:
        self._events.append(event)
    
    def get_event(self, index: Int) -> Event:
        return self._events[index]
    
    def events_count(self) -> Int:
        return len(self._events)
    
    def generate_daily_events(mut self, trading_dates: List[Date]) -> None:
        for i in range(len(trading_dates)):
            var date = trading_dates[i]
            var dt_before_trading = DateTime(date.year, date.month, date.day, 0, 0, 0, 0)
            var dt_bar = DateTime(date.year, date.month, date.day, 15, 0, 0, 0)
            var dt_after_trading = DateTime(date.year, date.month, date.day, 15, 30, 0, 0)
            
            self._events.append(Event("BEFORE_TRADING", dt_before_trading, dt_before_trading, ""))
            self._events.append(Event("OPEN_AUCTION", dt_before_trading, dt_before_trading, ""))
            self._events.append(Event("BAR", dt_bar, dt_bar, ""))
            self._events.append(Event("AFTER_TRADING", dt_after_trading, dt_after_trading, ""))
    
    def generate_tick_events(mut self, ticks: List[TickObject]) -> None:
        for i in range(len(ticks)):
            var tick = ticks[i]
            var ob_id = tick.instrument.order_book_id
            self._events.append(Event("TICK", tick.datetime, tick.datetime, ob_id))


def create_simulation_event_source(var start_date: DateTime, var end_date: DateTime, frequency: String) -> SimulationEventSource:
    return SimulationEventSource(
        _start_date=start_date^,
        _end_date=end_date^,
        _frequency=frequency,
        _events=List[Event]()
    )


def create_simulation_event_source_with_test_data() -> SimulationEventSource:
    var source = create_simulation_event_source(DateTime(2018, 9, 14, 0, 0, 0, 0), DateTime(2018, 9, 14, 23, 59, 59, 0), "tick")
    
    source.add_event(Event("BEFORE_TRADING", DateTime(2018, 9, 13, 20, 29, 0, 500000), DateTime(2018, 9, 14, 20, 29, 0, 500000), ""))
    source.add_event(Event("TICK", DateTime(2018, 9, 14, 9, 14, 0, 400000), DateTime(2018, 9, 14, 9, 14, 0, 400000), "TF1812"))
    source.add_event(Event("TICK", DateTime(2018, 9, 14, 9, 14, 3, 500000), DateTime(2018, 9, 14, 9, 14, 3, 500000), "AU1812"))
    
    return source^
