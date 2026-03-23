from .constants import MAX_TIMESTAMP, MAX_TIMESTAMP_MS, MAX_TIMESTAMP_US
from .constants import _DAYS_IN_MONTH, _DAYS_BEFORE_MONTH


def _pad_left(s: String, width: Int, fill_char: String = "0") -> String:
    var current_len = len(s)
    if current_len >= width:
        return s
    var padding = fill_char * (width - current_len)
    return padding + s


def _string_slice(s: String, start: Int, end: Int) -> String:
    var result = String()
    for i in range(start, min(end, len(s))):
        result += s[byte=i]
    return result


def _is_leap(year: Int) -> Bool:
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)


def _days_before_year(year: Int) -> Int:
    var y = year - 1
    return y * 365 + y // 4 - y // 100 + y // 400


def _days_in_month(year: Int, month: Int) -> Int:
    if month == 2 and _is_leap(year):
        return 29
    return _DAYS_IN_MONTH[month]


def _days_before_month(year: Int, month: Int) -> Int:
    if month > 2 and _is_leap(year):
        return _DAYS_BEFORE_MONTH[month] + 1
    return _DAYS_BEFORE_MONTH[month]


@always_inline
def _ymd2ord(year: Int, month: Int, day: Int) -> Int:
    var dim = _days_in_month(year, month)
    return _days_before_year(year) + _days_before_month(year, month) + day


def normalize_timestamp(ts: Float64) raises -> Float64:
    var result = ts
    if result > Float64(MAX_TIMESTAMP):
        if result < Float64(MAX_TIMESTAMP_MS):
            result = result / 1000.0
        elif result < Float64(MAX_TIMESTAMP_US):
            result = result / 1_000_000.0
        else:
            raise Error(
                "The specified timestamp " + String(result) + "is too large."
            )
    return result
