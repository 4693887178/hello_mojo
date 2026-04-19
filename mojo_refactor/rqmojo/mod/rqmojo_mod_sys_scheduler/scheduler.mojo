"""
RQAlpha Mojo - Scheduler
Ported from rqalpha/mod/rqalpha_mod_sys_scheduler/scheduler.py

Key differences from Python version:
  - Python uses callable functions; Mojo uses day_checker_id integers + func_name strings
  - Python uses closures for day/time checkers; Mojo uses integer-coded checker IDs
  - Python integrates with Environment singleton; Mojo takes trading_calendar as parameter
  - State serialization uses JSON-like format compatible with Python version
"""

from std.collections import Dict, List
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, EXECUTION_PHASE
from rqmojo.utils.typing import DateTime
from morrow import TimeDelta


comptime CHECKER_ALWAYS_TRUE = 0
comptime CHECKER_WEEKDAY_BASE = 100
comptime CHECKER_WEEKLY_TRADING_BASE = 200
comptime CHECKER_MONTHLY_TRADING_BASE = 300


def _parse_datetime(s: String) raises -> DateTime:
    return DateTime.strptime(s, "%Y-%m-%d")


def _format_date(dt: DateTime) -> String:
    var y = String(dt.year).ascii_rjust(4, "0")
    var m = String(dt.month).ascii_rjust(2, "0")
    var d = String(dt.day).ascii_rjust(2, "0")
    return y + "-" + m + "-" + d


def _minutes_since_midnight(hour: Int, minute: Int) -> Int:
    return hour * 60 + minute


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
        var total = _minutes_since_midnight(hour, minute)
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


struct Scheduler(Writable, Movable):
    var _registry: List[ScheduleEntry]
    var _frequency: String
    var _today: Optional[DateTime]
    var _last_minute: Int
    var _current_minute: Int
    var _stage: String
    var _trading_minute_ranges: List[TradingMinuteRange]
    var _start_minute: Int
    var _this_week: List[DateTime]
    var _this_month: List[DateTime]
    var _trading_calendar: List[DateTime]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Scheduler(entries=", String(len(self._registry)), ")")

    def __init__(out self, frequency: String):
        var trading_ranges = List[TradingMinuteRange]()
        trading_ranges.append(TradingMinuteRange(571, 690))
        trading_ranges.append(TradingMinuteRange(780, 900))

        self._registry = List[ScheduleEntry]()
        self._frequency = frequency
        self._today = Optional[DateTime](None)
        self._last_minute = 0
        self._current_minute = 0
        self._stage = ""
        self._trading_minute_ranges = trading_ranges^
        self._start_minute = 571
        self._this_week = List[DateTime]()
        self._this_month = List[DateTime]()
        self._trading_calendar = List[DateTime]()

    def _always_true_id(self) -> Int:
        return CHECKER_ALWAYS_TRUE

    def _weekday_checker_id(self, weekday: Int) -> Int:
        return CHECKER_WEEKDAY_BASE + weekday

    def _nth_trading_day_in_week_id(self, n: Int) -> Int:
        return CHECKER_WEEKLY_TRADING_BASE + n

    def _nth_trading_day_in_month_id(self, n: Int) -> Int:
        return CHECKER_MONTHLY_TRADING_BASE + n

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

    def _is_weekday(self, wd: Int) raises -> Bool:
        if self._today is None:
            return False
        var today = self._today.value()
        var py_wd = today.isoweekday() - 1
        return py_wd == wd

    def _is_nth_trading_day_in_week(self, n: Int) raises -> Bool:
        if self._today is None:
            return False
        if n < 0 or n >= len(self._this_week):
            return False
        var today = self._today.value()
        return self._this_week[n].toordinal() == today.toordinal()

    def _is_nth_trading_day_in_month(self, n: Int) raises -> Bool:
        if self._today is None:
            return False
        if n < 0 or n >= len(self._this_month):
            return False
        var today = self._today.value()
        return self._this_month[n].toordinal() == today.toordinal()

    def _check_day_rule(self, day_checker_id: Int) raises -> Bool:
        if day_checker_id == CHECKER_ALWAYS_TRUE:
            return True

        if day_checker_id >= CHECKER_MONTHLY_TRADING_BASE:
            var n = day_checker_id - CHECKER_MONTHLY_TRADING_BASE
            return self._is_nth_trading_day_in_month(n)

        if day_checker_id >= CHECKER_WEEKLY_TRADING_BASE:
            var n = day_checker_id - CHECKER_WEEKLY_TRADING_BASE
            return self._is_nth_trading_day_in_week(n)

        if day_checker_id >= CHECKER_WEEKDAY_BASE:
            var wd = day_checker_id - CHECKER_WEEKDAY_BASE
            return self._is_weekday(wd)

        return False

    def _fill_week(mut self) raises:
        if self._today is None:
            return
        var today = self._today.value()
        var iso_wd = today.isoweekday()
        var days_to_sunday = 7 - iso_wd
        var weekend_ord = today.toordinal() + days_to_sunday
        var week_start_ord = weekend_ord - 6

        self._this_week = List[DateTime]()
        for dt in self._trading_calendar:
            var dt_ord = dt.toordinal()
            if dt_ord >= week_start_ord and dt_ord <= weekend_ord:
                self._this_week.append(dt)

    def _fill_month(mut self) raises:
        if self._today is None:
            return
        var today = self._today.value()

        var month_begin = DateTime(today.year, today.month, 1, 0, 0, 0, 0)
        var month_end_year = today.year
        var month_end_month = today.month + 1
        if month_end_month > 12:
            month_end_month = 1
            month_end_year = today.year + 1
        var month_end = DateTime(month_end_year, month_end_month, 1, 0, 0, 0, 0)

        var month_begin_ord = month_begin.toordinal()
        var month_end_ord = month_end.toordinal()

        self._this_month = List[DateTime]()
        for dt in self._trading_calendar:
            var dt_ord = dt.toordinal()
            if dt_ord >= month_begin_ord and dt_ord < month_end_ord:
                self._this_month.append(dt)

    def schedule_daily(mut self, func_name: String, time_rule: TimeRule) -> None:
        var entry = ScheduleEntry(
            day_checker_id=self._always_true_id(),
            time_rule=time_rule,
            func_name=func_name,
            frequency="daily"
        )
        self._registry.append(entry)

    def schedule_weekly(mut self, func_name: String, weekday: Int, time_rule: TimeRule) -> None:
        var checker_id = self._weekday_checker_id(weekday - 1)
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

    def next_day(mut self, trading_dt: DateTime) raises:
        if len(self._registry) == 0:
            return

        self._today = Optional[DateTime](trading_dt)
        self._last_minute = self._start_minute
        self._current_minute = 0

        if len(self._trading_calendar) > 0:
            if len(self._this_week) == 0 or trading_dt.toordinal() > self._this_week[len(self._this_week) - 1].toordinal():
                self._fill_week()
            if len(self._this_month) == 0 or trading_dt.toordinal() > self._this_month[len(self._this_month) - 1].toordinal():
                self._fill_month()

    def next_bar(mut self, current_time: DateTime) raises -> List[String]:
        self._current_minute = _minutes_since_midnight(current_time.hour, current_time.minute)

        var result = List[String]()

        for entry in self._registry:
            if self._check_day_rule(entry.day_checker_id) and self._check_time_rule(entry.time_rule):
                result.append(entry.func_name)

        self._last_minute = self._current_minute
        return result^

    def before_trading(mut self) raises -> List[String]:
        self._stage = "before_trading"
        var result = List[String]()

        for entry in self._registry:
            if self._check_day_rule(entry.day_checker_id) and self._check_time_rule(entry.time_rule):
                result.append(entry.func_name)

        self._stage = ""
        return result^

    def set_trading_ranges(mut self, ranges: List[TradingMinuteRange]) -> None:
        self._trading_minute_ranges = ranges.copy()

    def set_trading_calendar(mut self, calendar: List[DateTime]) -> None:
        self._trading_calendar = calendar.copy()
        self._this_week = List[DateTime]()
        self._this_month = List[DateTime]()

    def universe_change(mut self, universe_instruments: List[String], get_instrument_fn: String) -> None:
        self._trading_minute_ranges.clear()

    def get_state(self) -> String:
        if self._today is None:
            return ""
        var today = self._today.value()
        var date_str = _format_date(today)
        return '{"today":"' + date_str + '","last_minute":' + String(self._last_minute) + '}'

    def set_state(mut self, state: String) raises:
        if len(state) == 0:
            return

        var today_key = '"today":"'
        var today_start = state.find(today_key)
        if today_start == -1:
            var parts = state.split("|")
            if len(parts) >= 2:
                self._last_minute = _parse_int(String(parts[1]))
                self._today = Optional[DateTime](_parse_datetime(String(parts[0])))
            return

        today_start += len(today_key)
        var today_end = state.find('"', today_start)
        if today_end == -1:
            return
        var date_str = String(state[byte=today_start:today_end])
        self._today = Optional[DateTime](_parse_datetime(date_str))

        var minute_key = '"last_minute":'
        var minute_start = state.find(minute_key)
        if minute_start == -1:
            return
        minute_start += len(minute_key)
        var minute_end_comma = state.find(',', minute_start)
        var minute_end_brace = state.find('}', minute_start)
        var minute_end = len(state)
        if minute_end_comma != -1 and minute_end_comma < minute_end:
            minute_end = minute_end_comma
        if minute_end_brace != -1 and minute_end_brace < minute_end:
            minute_end = minute_end_brace
        var minute_str = String(state[byte=minute_start:minute_end])
        self._last_minute = _parse_int(minute_str)

        if len(self._trading_calendar) > 0:
            self._fill_month()
            self._fill_week()


def _parse_int(s: String) raises -> Int:
    var result = 0
    var found = False
    var is_negative = False
    for cp in s.codepoints():
        var c = Int(cp)
        if c >= 48 and c <= 57:
            result = result * 10 + (c - 48)
            found = True
        elif c == 45 and not found:
            is_negative = True
        else:
            break
    if is_negative:
        result = -result
    return result


def create_scheduler(frequency: String = "1d") -> Scheduler:
    var s = Scheduler(frequency)
    return s^
