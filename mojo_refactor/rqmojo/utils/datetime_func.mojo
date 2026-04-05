"""
RQAlpha Mojo - DateTime Functions
Ported from rqalpha/utils/datetime_func.py
"""

from std.python import Python, PythonObject
from rqmojo.utils.typing import DateTimeDate, DateTime


def _py_int_to_int(py_obj: PythonObject) raises -> Int:
    var builtins = Python.import_module("builtins")
    var s = builtins.str(py_obj)
    return Int(String(s))


@fieldwise_init
struct TimeRange(Copyable, Movable, ImplicitlyCopyable):
    var start_hour: Int
    var start_minute: Int
    var end_hour: Int
    var end_minute: Int


def convert_date_to_date_int(dt: DateTimeDate) -> Int:
    return dt.year * 10000 + dt.month * 100 + dt.day


def convert_date_to_int(dt: DateTimeDate) -> Int:
    return dt.year * 10000000000000 + dt.month * 100000000000 + dt.day * 1000000000


def convert_dt_to_int(dt: DateTime) -> Int:
    var t = convert_date_to_int(dt.date())
    t += dt.hour * 10000000 + dt.minute * 100000 + dt.second * 1000
    return t


def convert_int_to_date(dt_int: Int) -> DateTime:
    var dt = dt_int
    if dt > 100000000:
        dt //= 1000000
    return _convert_int_to_date(dt)


def _convert_int_to_date(dt_int: Int) -> DateTime:
    var year = dt_int // 10000
    var r = dt_int % 10000
    var month = r // 100
    var day = r % 100
    return DateTime(year, month, day, 0, 0, 0, 0)


def convert_int_to_datetime(dt_int: Int) -> DateTime:
    var dt = dt_int
    var ms = 0
    if dt > 100000000000000:
        ms = dt % 1000
        dt //= 1000
    var year = dt // 10000000000
    var r = dt % 10000000000
    var month = r // 100000000
    r = r % 100000000
    var day = r // 1000000
    r = r % 1000000
    var hour = r // 10000
    r = r % 10000
    var minute = r // 100
    var second = r % 100
    return DateTime(year, month, day, hour, minute, second, ms * 1000)


def convert_ms_int_to_datetime(ms_dt_int: Int) -> DateTime:
    return convert_int_to_datetime(ms_dt_int)


def convert_date_time_ms_int_to_datetime(date_int: Int, time_int: Int) -> DateTime:
    var dt = _convert_int_to_date(date_int)
    var hours = time_int // 10000000
    var r = time_int % 10000000
    var minutes = r // 100000
    r = r % 100000
    var seconds = r // 1000
    var millisecond = r % 1000
    return dt.replace(hour=hours, minute=minutes, second=seconds, microsecond=millisecond * 1000)


def to_date_from_string(date_str: String) raises -> DateTimeDate:
    var parser = Python.import_module("dateutil.parser")
    var py_dt = parser.parse(date_str)
    return DateTimeDate(
        _py_int_to_int(py_dt.year),
        _py_int_to_int(py_dt.month),
        _py_int_to_int(py_dt.day)
    )


def to_date_from_datetime(dt: DateTime) -> DateTimeDate:
    return dt.date()


def to_date_from_date(d: DateTimeDate) -> DateTimeDate:
    return d


def to_date_from_py_datetime(py_dt: PythonObject) raises -> DateTimeDate:
    var datetime_module = Python.import_module("datetime")
    var builtins = Python.import_module("builtins")
    
    if builtins.isinstance(py_dt, datetime_module.datetime):
        return DateTimeDate(
            _py_int_to_int(py_dt.year),
            _py_int_to_int(py_dt.month),
            _py_int_to_int(py_dt.day)
        )
    elif builtins.isinstance(py_dt, datetime_module.date):
        return DateTimeDate(
            _py_int_to_int(py_dt.year),
            _py_int_to_int(py_dt.month),
            _py_int_to_int(py_dt.day)
        )
    else:
        raise Error("Invalid Python datetime object: " + builtins.str(py_dt))
