"""
RQAlpha Mojo - Simulation Event Source
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_event_source.py
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.model.tick import TickObject
from rqmojo.core.events import EVENT, Event


struct SimulationEventSource(Movable):
    var _frequency: String
    var _universe_changed: Bool
    var _event_count: Int

    def __init__(out self, frequency: String = "1d"):
        self._frequency = frequency
        self._universe_changed = False
        self._event_count = 0

    def generate_daily_events(mut self, start_date: DateTime, end_date: DateTime) -> Int:
        var count = 0
        var current = start_date
        while current.year < end_date.year or (
            current.year == end_date.year and current.month <= end_date.month
        ):
            count += 4
            if current.month == 12:
                current = DateTime(current.year + 1, 1, 1, 0, 0, 0, 0)
            else:
                current = DateTime(current.year, current.month + 1, 1, 0, 0, 0, 0)
        self._event_count = count
        return count

    def generate_minute_events(mut self, start_date: DateTime, end_date: DateTime) -> Int:
        var count = 0
        var current = start_date
        while current.year < end_date.year or (
            current.year == end_date.year and current.month <= end_date.month
        ):
            for hour in range(9, 16):
                for minute in range(0, 60):
                    if (hour == 11 and minute > 30) or (hour >= 12 and hour < 13) or hour >= 15:
                        continue
                    count += 1
            if current.month == 12:
                current = DateTime(current.year + 1, 1, 1, 0, 0, 0, 0)
            else:
                current = DateTime(current.year, current.month + 1, 1, 0, 0, 0, 0)
        if count > 0:
            count += 1
        self._event_count = count
        return count

    def events(
        mut self,
        start_date: DateTime,
        end_date: DateTime,
        frequency: String
    ) raises -> Int:
        if frequency == "1d":
            return self.generate_daily_events(start_date, end_date)
        elif frequency == "1m":
            return self.generate_minute_events(start_date, end_date)
        elif frequency == "tick":
            return 0
        else:
            raise Error("Frequency " + frequency + " is not supported.")

    def _on_universe_changed(mut self, event: Event) -> None:
        self._universe_changed = True

    def get_event_count(self) -> Int:
        return self._event_count


def create_simulation_event_source(frequency: String = "1d") -> SimulationEventSource:
    return SimulationEventSource(frequency=frequency)


def create_simulation_event_source_with_test_data() -> SimulationEventSource:
    var source = create_simulation_event_source("tick")
    return source^
