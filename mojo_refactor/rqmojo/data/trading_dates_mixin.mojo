"""
RQAlpha Mojo - Trading Dates Mixin
Ported from rqalpha/data/trading_dates_mixin.py
"""

from rqmojo.const import TRADING_CALENDAR_TYPE
from rqmojo.utils.typing import DateTimeDate, DateLike


def _to_timestamp(d: DateLike) -> DateTimeDate:
    if d.isa[DateTimeDate]():
        return d[DateTimeDate]
    elif d.isa[Int]():
        var date_int = d[Int]
        var year = date_int // 10000
        var r = date_int % 10000
        var month = r // 100
        var day = r % 100
        return DateTimeDate(year, month, day)
    else:
        return DateTimeDate(1970, 1, 1)


@fieldwise_init
struct TradingDateResult(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var year: Int
    var month: Int
    var day: Int
    
    def __str__(self) -> String:
        return String(self.year) + "-" + String(self.month) + "-" + String(self.day)
    
    def to_date(self) -> DateTimeDate:
        return DateTimeDate(self.year, self.month, self.day)


def create_trading_date_result(year: Int, month: Int, day: Int) -> TradingDateResult:
    return TradingDateResult(year=year, month=month, day=day)


@fieldwise_init
struct TradingDatesMixin(Stringable, Movable):
    var _trading_dates: List[Int]
    var _initialized: Bool
    
    def __str__(self) -> String:
        return "TradingDatesMixin(count=" + String(len(self._trading_dates)) + ")"
    
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
            var result_int = self._trading_dates[pos - n]
            return create_trading_date_result(result_int // 10000, (result_int % 10000) // 100, result_int % 100)
        else:
            var result_int = self._trading_dates[0]
            return create_trading_date_result(result_int // 10000, (result_int % 10000) // 100, result_int % 100)
    
    def get_next_trading_date(self, year: Int, month: Int, day: Int, n: Int = 1) -> TradingDateResult:
        var date_int = Self._date_to_int(year, month, day)
        var pos = self._binary_search_right(date_int)
        if pos + n - 1 < len(self._trading_dates):
            var result_int = self._trading_dates[pos + n - 1]
            return create_trading_date_result(result_int // 10000, (result_int % 10000) // 100, result_int % 100)
        else:
            var result_int = self._trading_dates[len(self._trading_dates) - 1]
            return create_trading_date_result(result_int // 10000, (result_int % 10000) // 100, result_int % 100)
    
    def get_trading_dates_count(self) -> Int:
        return len(self._trading_dates)


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
