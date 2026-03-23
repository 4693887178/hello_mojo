"""
RQAlpha Mojo - Scheduler
Ported from rqalpha/mod/rqalpha_mod_sys_scheduler/scheduler.py
"""

from std.collections import Dict, List, Set
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, EXECUTION_PHASE
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.environment import Environment
from rqmojo.utils.typing import DateTime
from rqmojo.model.bar import BarObject


def _parse_datetime(s: String) -> DateTime:
    try:
        return DateTime.parse(s)
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


@fieldwise_init
struct TimeRule(Writable, Copyable, Movable, ImplicitlyCopyable, Equatable):
    var minutes_since_midnight: Int
    var is_before_trading: Bool
    var description: String

    def write_to(self, mut writer: Some[Writer]):
        if self.is_before_trading:
            writer.write("TimeRule(before_trading)")
        else:
            writer.write("TimeRule(", String(self.minutes_since_midnight), " minutes)")

    @staticmethod
    def before_trading() -> TimeRule:
        return TimeRule(minutes_since_midnight=0, is_before_trading=True, description="before_trading")

    @staticmethod
    def at_time(hour: Int, minute: Int) -> TimeRule:
        var total = hour * 60 + minute
        return TimeRule(minutes_since_midnight=total, is_before_trading=False, description="at_time")

    @staticmethod
    def market_open(hour: Int = 0, minute: Int = 0) -> TimeRule:
        var base = 9 * 60 + 31
        var total = base + hour * 60 + minute
        if total > 11 * 60 + 30:
            total += 90
        return TimeRule(minutes_since_midnight=total, is_before_trading=False, description="market_open")

    @staticmethod
    def market_close(hour: Int = 0, minute: Int = 0) -> TimeRule:
        var base = 15 * 60
        var total = base - hour * 60 - minute
        if total < 13 * 60:
            total -= 90
        return TimeRule(minutes_since_midnight=total, is_before_trading=False, description="market_close")


def market_open_minutes(hour: Int = 0, minute: Int = 0) -> Int:
    var base = 9 * 60 + 31
    var total = base + hour * 60 + minute
    if total > 11 * 60 + 30:
        total += 90
    return total


def market_close_minutes(hour: Int = 0, minute: Int = 0) -> Int:
    var base = 15 * 60
    var total = base - hour * 60 - minute
    if total < 13 * 60:
        total -= 90
    return total


def physical_time_minutes(hour: Int = 0, minute: Int = 0) -> Int:
    return hour * 60 + minute


@fieldwise_init
struct ScheduleEntry(Writable, Copyable, Movable, ImplicitlyCopyable, Equatable):
    var day_checker_id: Int
    var time_rule: TimeRule
    var func_name: String
    var frequency: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ScheduleEntry(", self.func_name, ", ")
        self.time_rule.write_to(writer)
        writer.write(")")


@fieldwise_init
struct TradingMinuteRange(Writable, Copyable, Movable, ImplicitlyCopyable, Equatable):
    var start_minute: Int
    var end_minute: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TradingMinuteRange(", String(self.start_minute), "-", String(self.end_minute), ")")

    def contains(self, minute: Int) -> Bool:
        return self.start_minute <= minute and minute <= self.end_minute


@fieldwise_init
struct Scheduler(Writable, Movable):
    var _registry: List[ScheduleEntry]
    var _frequency: String
    var _today: Optional[DateTime]
    var _this_week: List[DateTime]
    var _this_month: List[DateTime]
    var _last_minute: Int
    var _current_minute: Int
    var _stage: String
    var _trading_minute_ranges: List[TradingMinuteRange]
    var _start_minute: Int
    var _day_checkers: Dict[Int, String]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Scheduler(entries=", String(self._registry.__len__()), ")")

    def __init__(out self, frequency: String):
        var trading_ranges = List[TradingMinuteRange]()
        trading_ranges.append(TradingMinuteRange(571, 690))
        trading_ranges.append(TradingMinuteRange(780, 900))
        
        self._registry = List[ScheduleEntry]()
        self._frequency = frequency
        self._today = Optional[DateTime](None)
        self._this_week = List[DateTime]()
        self._this_month = List[DateTime]()
        self._last_minute = 0
        self._current_minute = 0
        self._stage = ""
        self._trading_minute_ranges = trading_ranges^
        self._start_minute = 571
        self._day_checkers = Dict[Int, String]()

    def _always_true_id(self) -> Int:
        return 0

    def _weekday_checker_id(self, weekday: Int) -> Int:
        return 100 + weekday

    def _nth_trading_day_in_week_id(self, n: Int) -> Int:
        return 200 + n

    def _nth_trading_day_in_month_id(self, n: Int) -> Int:
        return 300 + n

    def _is_in_trading_time(self, minute: Int) -> Bool:
        for r in self._trading_minute_ranges:
            if r.contains(minute):
                return True
        return False

    def _check_time_rule(self, time_rule: TimeRule) -> Bool:
        if time_rule.is_before_trading:
            return self._stage == "before_trading"

        var n = time_rule.minutes_since_midnight
        
        if not self._is_in_trading_time(n):
            return False

        if self._stage == "before_trading":
            return False

        if self._frequency == "1d":
            return True

        if n == 0 and self._current_minute == n:
            return True

        return self._last_minute < n and n <= self._current_minute

    def schedule_daily(mut self, func_name: String, time_rule: TimeRule) -> None:
        var entry = ScheduleEntry(
            day_checker_id=self._always_true_id(),
            time_rule=time_rule,
            func_name=func_name,
            frequency="daily"
        )
        self._registry.append(entry)

    def schedule_weekly(mut self, func_name: String, weekday: Int, time_rule: TimeRule) -> None:
        var checker_id = self._weekday_checker_id(weekday)
        var entry = ScheduleEntry(
            day_checker_id=checker_id,
            time_rule=time_rule,
            func_name=func_name,
            frequency="weekly"
        )
        self._registry.append(entry)

    def schedule_weekly_trading_day(mut self, func_name: String, trading_day: Int, time_rule: TimeRule) -> None:
        var n = trading_day
        if trading_day > 0:
            n = trading_day - 1
        var checker_id = self._nth_trading_day_in_week_id(n)
        var entry = ScheduleEntry(
            day_checker_id=checker_id,
            time_rule=time_rule,
            func_name=func_name,
            frequency="weekly_trading"
        )
        self._registry.append(entry)

    def schedule_monthly(mut self, func_name: String, trading_day: Int, time_rule: TimeRule) -> None:
        var n = trading_day
        if trading_day > 0:
            n = trading_day - 1
        var checker_id = self._nth_trading_day_in_month_id(n)
        var entry = ScheduleEntry(
            day_checker_id=checker_id,
            time_rule=time_rule,
            func_name=func_name,
            frequency="monthly"
        )
        self._registry.append(entry)

    def clear(mut self) -> None:
        self._registry.clear()

    def next_day(mut self, trading_dt: DateTime) -> None:
        if self._registry.__len__() == 0:
            return

        self._today = Optional[DateTime](trading_dt)
        self._last_minute = self._start_minute
        self._current_minute = 0

    def next_bar(mut self, current_time: DateTime) -> List[String]:
        self._current_minute = current_time.hour * 60 + current_time.minute
        
        var result = List[String]()
        
        for entry in self._registry:
            if self._check_time_rule(entry.time_rule):
                result.append(entry.func_name)
        
        self._last_minute = self._current_minute
        return result^

    def before_trading(mut self) -> List[String]:
        self._stage = "before_trading"
        var result = List[String]()
        
        for entry in self._registry:
            if entry.time_rule.is_before_trading:
                result.append(entry.func_name)
        
        self._stage = ""
        return result^

    def set_trading_ranges(mut self, ranges: List[TradingMinuteRange]) -> None:
        self._trading_minute_ranges = ranges.copy()

    def get_state(self) -> String:
        if self._today:
            var today = self._today.value()
            return today.to_string() + "|" + String(self._last_minute)
        return ""

    def set_state(mut self, state: String) raises:
        var parts = state.split("|")
        if parts.__len__() >= 2:
            var minute_str = String(parts[1])
            self._last_minute = _parse_int(minute_str)
            self._today = Optional[DateTime](_parse_datetime(String(parts[0])))


def _parse_int(s: String) raises -> Int:
    var result = 0
    for cp in s.codepoints():
        var c = Int(cp)
        if c >= 48 and c <= 57:
            result = result * 10 + (c - 48)
    return result


def create_scheduler(frequency: String = "1d") -> Scheduler:
    return Scheduler(
        _registry=List[ScheduleEntry](),
        _frequency=frequency,
        _today=Optional[DateTime](None),
        _this_week=List[DateTime](),
        _this_month=List[DateTime](),
        _last_minute=0,
        _current_minute=0,
        _stage="",
        _trading_minute_ranges=List[TradingMinuteRange](),
        _start_minute=571,
        _day_checkers=Dict[Int, String]()
    )
