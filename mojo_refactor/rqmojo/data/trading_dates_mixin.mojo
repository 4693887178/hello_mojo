"""
RQAlpha Mojo - Trading Dates Mixin
Ported from rqalpha/data/trading_dates_mixin.py
"""

from rqmojo.const import TRADING_CALENDAR_TYPE
from rqmojo.utils.typing import DateTimeDate, DateTime


@fieldwise_init
struct TradingDateResult(Writable, Copyable, Movable, ImplicitlyCopyable):
    var year: Int
    var month: Int
    var day: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write(String(self.year), "-", String(self.month), "-", String(self.day))

    def to_date(self) -> DateTimeDate:
        return DateTimeDate(self.year, self.month, self.day)

    def to_int(self) -> Int:
        return self.year * 10000 + self.month * 100 + self.day


def create_trading_date_result(year: Int, month: Int, day: Int) -> TradingDateResult:
    return TradingDateResult(year=year, month=month, day=day)


def _date_to_int(year: Int, month: Int, day: Int) -> Int:
    return year * 10000 + month * 100 + day


def _int_to_year(date_int: Int) -> Int:
    return date_int // 10000


def _int_to_month(date_int: Int) -> Int:
    return (date_int % 10000) // 100


def _int_to_day(date_int: Int) -> Int:
    return date_int % 100


def _int_to_result(date_int: Int) -> TradingDateResult:
    return create_trading_date_result(
        _int_to_year(date_int),
        _int_to_month(date_int),
        _int_to_day(date_int),
    )


@fieldwise_init
struct TradingDatesMixin(Writable, Movable):
    var _trading_dates: List[Int]
    var _initialized: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TradingDatesMixin(count=", String(len(self._trading_dates)), ")")

    @staticmethod
    def _date_to_int(year: Int, month: Int, day: Int) -> Int:
        return year * 10000 + month * 100 + day

    def _binary_search_left(self, target: Int) -> Int:
        if len(self._trading_dates) == 0:
            return 0
        var left: Int = 0
        var right: Int = len(self._trading_dates)
        while left < right:
            var mid: Int = (left + right) // 2
            if self._trading_dates[mid] < target:
                left = mid + 1
            else:
                right = mid
        return left

    def _binary_search_right(self, target: Int) -> Int:
        if len(self._trading_dates) == 0:
            return 0
        var left: Int = 0
        var right: Int = len(self._trading_dates)
        while left < right:
            var mid: Int = (left + right) // 2
            if self._trading_dates[mid] <= target:
                left = mid + 1
            else:
                right = mid
        return left

    def get_trading_dates_count(self) -> Int:
        return len(self._trading_dates)

    def count_trading_dates(self, start_year: Int, start_month: Int, start_day: Int, end_year: Int, end_month: Int, end_day: Int) -> Int:
        var start_int = Self._date_to_int(start_year, start_month, start_day)
        var end_int = Self._date_to_int(end_year, end_month, end_day)
        var left = self._binary_search_left(start_int)
        var right = self._binary_search_right(end_int)
        return right - left

    def is_trading_date(self, year: Int, month: Int, day: Int) -> Bool:
        var date_int = Self._date_to_int(year, month, day)
        var pos = self._binary_search_left(date_int)
        if pos < len(self._trading_dates) and self._trading_dates[pos] == date_int:
            return True
        return False

    def get_previous_trading_date(self, year: Int, month: Int, day: Int, n: Int = 1) -> TradingDateResult:
        var date_int = Self._date_to_int(year, month, day)
        var pos = self._binary_search_left(date_int)
        if pos >= n:
            return _int_to_result(self._trading_dates[pos - n])
        else:
            return _int_to_result(self._trading_dates[0])

    def get_next_trading_date(self, year: Int, month: Int, day: Int, n: Int = 1) -> TradingDateResult:
        var date_int = Self._date_to_int(year, month, day)
        var pos = self._binary_search_right(date_int)
        if pos + n - 1 < len(self._trading_dates):
            return _int_to_result(self._trading_dates[pos + n - 1])
        else:
            return _int_to_result(self._trading_dates[len(self._trading_dates) - 1])

    def get_trading_dates(self, start_year: Int, start_month: Int, start_day: Int, end_year: Int, end_month: Int, end_day: Int) -> List[TradingDateResult]:
        var start_int = Self._date_to_int(start_year, start_month, start_day)
        var end_int = Self._date_to_int(end_year, end_month, end_day)
        var left = self._binary_search_left(start_int)
        var right = self._binary_search_right(end_int)
        var result = List[TradingDateResult]()
        for i in range(left, right):
            result.append(_int_to_result(self._trading_dates[i]))
        return result^

    def get_n_trading_dates_until(self, year: Int, month: Int, day: Int, n: Int) -> List[TradingDateResult]:
        var date_int = Self._date_to_int(year, month, day)
        var pos = self._binary_search_right(date_int)
        var result = List[TradingDateResult]()
        if pos >= n:
            for i in range(pos - n, pos):
                result.append(_int_to_result(self._trading_dates[i]))
        else:
            for i in range(0, pos):
                result.append(_int_to_result(self._trading_dates[i]))
        return result^

    def get_future_trading_date(self, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) raises -> TradingDateResult:
        var dt1_hour = hour - 4
        var dt1_day = day
        var dt1_month = month
        var dt1_year = year
        if dt1_hour < 0:
            dt1_hour = dt1_hour + 24
            dt1_day = dt1_day - 1
            if dt1_day < 1:
                dt1_month = dt1_month - 1
                if dt1_month < 1:
                    dt1_month = 12
                    dt1_year = dt1_year - 1
                dt1_day = _days_in_month(dt1_year, dt1_month)
        var td_int = Self._date_to_int(dt1_year, dt1_month, dt1_day)
        var pos = self._binary_search_left(td_int)
        if pos >= len(self._trading_dates) or self._trading_dates[pos] != td_int:
            raise Error("invalid future calendar datetime: " + String(year) + "-" + String(month) + "-" + String(day) + " " + String(hour) + ":" + String(minute) + ":" + String(second))
        if dt1_hour >= 16:
            if pos + 1 < len(self._trading_dates):
                return _int_to_result(self._trading_dates[pos + 1])
            else:
                return _int_to_result(self._trading_dates[pos])
        return _int_to_result(self._trading_dates[pos])

    def get_trading_dt(self, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) raises -> DateTime:
        var trading_date = self.get_future_trading_date(year, month, day, hour, minute, second)
        return DateTime(trading_date.year, trading_date.month, trading_date.day, hour, minute, second, 0)

    def batch_get_trading_date(self, datetimes: List[Tuple[Int, Int, Int, Int, Int, Int]]) raises -> List[TradingDateResult]:
        var result = List[TradingDateResult]()
        for i in range(len(datetimes)):
            var dt = datetimes[i]
            var trading_date = self.get_future_trading_date(dt[0], dt[1], dt[2], dt[3], dt[4], dt[5])
            result.append(trading_date)
        return result^


def _days_in_month(year: Int, month: Int) -> Int:
    if month == 2:
        if (year % 4 == 0 and year % 100 != 0) or year % 400 == 0:
            return 29
        return 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31


def create_trading_dates_mixin_with_november_2018() -> TradingDatesMixin:
    var dates = List[Int]()

    dates.append(20181101)
    dates.append(20181102)
    dates.append(20181105)
    dates.append(20181106)
    dates.append(20181107)
    dates.append(20181108)
    dates.append(20181109)
    dates.append(20181112)
    dates.append(20181113)
    dates.append(20181114)
    dates.append(20181115)
    dates.append(20181116)
    dates.append(20181119)
    dates.append(20181120)
    dates.append(20181121)
    dates.append(20181122)
    dates.append(20181123)
    dates.append(20181126)
    dates.append(20181127)
    dates.append(20181128)
    dates.append(20181129)
    dates.append(20181130)

    return TradingDatesMixin(_trading_dates=dates^, _initialized=True)


def create_trading_dates_mixin_with_november_2024() -> TradingDatesMixin:
    var dates = List[Int]()

    dates.append(20241101)
    dates.append(20241104)
    dates.append(20241105)
    dates.append(20241106)
    dates.append(20241107)
    dates.append(20241108)
    dates.append(20241111)
    dates.append(20241112)
    dates.append(20241113)
    dates.append(20241114)
    dates.append(20241115)
    dates.append(20241118)
    dates.append(20241119)
    dates.append(20241120)
    dates.append(20241121)
    dates.append(20241122)
    dates.append(20241125)
    dates.append(20241126)
    dates.append(20241127)
    dates.append(20241128)
    dates.append(20241129)

    return TradingDatesMixin(_trading_dates=dates^, _initialized=True)


def create_trading_dates_mixin_with_multiple_months() -> TradingDatesMixin:
    var dates = List[Int]()

    dates.append(20181101)
    dates.append(20181102)
    dates.append(20181105)
    dates.append(20181106)
    dates.append(20181107)
    dates.append(20181108)
    dates.append(20181109)
    dates.append(20181112)
    dates.append(20181113)
    dates.append(20181114)
    dates.append(20181115)
    dates.append(20181116)
    dates.append(20181119)
    dates.append(20181120)
    dates.append(20181121)
    dates.append(20181122)
    dates.append(20181123)
    dates.append(20181126)
    dates.append(20181127)
    dates.append(20181128)
    dates.append(20181129)
    dates.append(20181130)

    dates.append(20241101)
    dates.append(20241104)
    dates.append(20241105)
    dates.append(20241106)
    dates.append(20241107)
    dates.append(20241108)
    dates.append(20241111)
    dates.append(20241112)
    dates.append(20241113)
    dates.append(20241114)
    dates.append(20241115)
    dates.append(20241118)
    dates.append(20241119)
    dates.append(20241120)
    dates.append(20241121)
    dates.append(20241122)
    dates.append(20241125)
    dates.append(20241126)
    dates.append(20241127)
    dates.append(20241128)
    dates.append(20241129)

    return TradingDatesMixin(_trading_dates=dates^, _initialized=True)


def create_trading_dates_mixin() -> TradingDatesMixin:
    return TradingDatesMixin(_trading_dates=List[Int](), _initialized=False)
