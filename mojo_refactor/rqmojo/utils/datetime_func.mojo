"""
RQAlpha Mojo - DateTime Functions
Ported from rqalpha/utils/datetime_func.py
"""

from std.python import Python, PythonObject
from morrow import Morrow
from rqmojo.utils.typing import DateTimeDate, DateTime


@fieldwise_init
struct TimeOfDay(Copyable, Movable, ImplicitlyCopyable):
    var hour: Int
    var minute: Int


@fieldwise_init
struct TimeRange(Copyable, Movable, ImplicitlyCopyable):
    var start: TimeOfDay
    var end: TimeOfDay


def convert_date_to_date_int(dt: DateTime) -> Int:
    return dt.year * 10000 + dt.month * 100 + dt.day


def convert_date_to_int(dt: DateTime) -> Int:
    return dt.year * 10000000000 + dt.month * 100000000 + dt.day * 1000000


def convert_dt_to_int(dt: DateTime) -> Int:
    var t = convert_date_to_int(dt)
    t += dt.hour * 10000 + dt.minute * 100 + dt.second
    return t


def convert_int_to_date(dt_int: Int) -> DateTime:
    var dt = dt_int
    if dt > 100000000:
        dt //= 1000000
    return _convert_int_to_date(dt)


def _convert_int_to_date(dt_int: Int) -> DateTime:
    var (year, r) = divmod(dt_int, 10000)
    var (month, day) = divmod(r, 100)
    return DateTime(year, month, day, 0, 0, 0, 0)


def convert_int_to_datetime(dt_int: Int) -> DateTime:
    var year: Int; var month: Int; var day: Int; var hour: Int; var minute: Int; var second: Int; var r: Int

    (year, r) = divmod(dt_int, 10000000000)
    (month, r) = divmod(r, 100000000)
    (day, r) = divmod(r, 1000000)
    (hour, r) = divmod(r, 10000)
    (minute, second) = divmod(r, 100)
    return DateTime(year, month, day, hour, minute, second, 0)


def convert_ms_int_to_datetime(ms_dt_int: Int) -> DateTime:
    var (dt_int, ms_int) = divmod(ms_dt_int, 1000)
    var dt = convert_int_to_datetime(dt_int)
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, ms_int * 1000)


def convert_date_time_ms_int_to_datetime(date_int: Int, time_int: Int) -> DateTime:
    var dt = _convert_int_to_date(date_int)
    var hours: Int; var minutes: Int; var seconds: Int; var millisecond: Int; var r: Int

    (hours, r) = divmod(time_int, 10000000)
    (minutes, r) = divmod(r, 100000)
    (seconds, millisecond) = divmod(r, 1000)
    return DateTime(dt.year, dt.month, dt.day, hours, minutes, seconds, millisecond * 1000)


from rqmojo.utils.exception import RQInvalidArgument


def to_date(date_str: String) raises -> DateTimeDate:
    return Morrow.strptime(date_str, "%Y-%m-%d")


def to_date(dt: DateTime) -> DateTimeDate:
    return DateTime(dt.year, dt.month, dt.day)


def to_date(date: PythonObject) raises -> DateTimeDate:
    var builtins = Python.import_module("builtins")
    var s = String(builtins.str(date))

    if builtins.hasattr(date, "year") and builtins.hasattr(date, "month") and builtins.hasattr(date, "day"):
        return DateTime(Int(py=date.year), Int(py=date.month), Int(py=date.day))
    else:
        raise RQInvalidArgument.create("unknown date value: " + s)
