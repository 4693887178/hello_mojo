"""
RQAlpha Mojo - DateTime Functions Module Test
Tests for utils/datetime_func.mojo
"""

from rqmojo.utils.datetime_func import (
    TimeOfDay, TimeRange,
    convert_date_to_date_int, convert_date_to_int,
    convert_dt_to_int,
    convert_int_to_date, convert_int_to_datetime,
    convert_ms_int_to_datetime, convert_date_time_ms_int_to_datetime,
    to_date
)
from rqmojo.utils.typing import DateTime, DateTimeDate
from std.python import Python
from std.testing import assert_equal, assert_true, assert_raises, TestSuite


def test_time_of_day_struct() raises:
    var tod = TimeOfDay(9, 30)
    assert_equal(tod.hour, 9)
    assert_equal(tod.minute, 30)


def test_time_range_struct() raises:
    var start = TimeOfDay(9, 30)
    var end = TimeOfDay(15, 0)
    var tr = TimeRange(start, end)
    assert_equal(tr.start.hour, 9)
    assert_equal(tr.start.minute, 30)
    assert_equal(tr.end.hour, 15)
    assert_equal(tr.end.minute, 0)


def test_convert_date_to_date_int() raises:
    var dt = DateTime(2020, 1, 15, 0, 0, 0, 0)
    var result = convert_date_to_date_int(dt)
    assert_equal(result, 20200115)


def test_convert_date_to_int() raises:
    var dt = DateTime(2020, 1, 15, 10, 30, 45, 0)
    var result = convert_date_to_int(dt)
    assert_equal(result, 20200115000000)


def test_convert_dt_to_int() raises:
    var dt = DateTime(2020, 1, 15, 14, 30, 0, 0)
    var result = convert_dt_to_int(dt)
    assert_equal(result, 20200115143000)


def test_convert_int_to_date() raises:
    var result = convert_int_to_date(20200115)
    assert_equal(result.year, 2020)
    assert_equal(result.month, 1)
    assert_equal(result.day, 15)


def test_convert_int_to_date_with_time_component() raises:
    var result = convert_int_to_date(20200115000000)
    assert_equal(result.year, 2020)
    assert_equal(result.month, 1)
    assert_equal(result.day, 15)


def test_convert_int_to_datetime() raises:
    var result = convert_int_to_datetime(20200115143000)
    assert_equal(result.year, 2020)
    assert_equal(result.month, 1)
    assert_equal(result.day, 15)
    assert_equal(result.hour, 14)
    assert_equal(result.minute, 30)
    assert_equal(result.second, 0)


def test_convert_ms_int_to_datetime() raises:
    var result = convert_ms_int_to_datetime(20200115143000123)
    assert_equal(result.year, 2020)
    assert_equal(result.month, 1)
    assert_equal(result.day, 15)
    assert_equal(result.hour, 14)
    assert_equal(result.minute, 30)
    assert_equal(result.second, 0)
    assert_equal(result.microsecond, 123000)


def test_convert_date_time_ms_int_to_datetime() raises:
    var date_int = 20200115
    var time_int = 143000500
    var result = convert_date_time_ms_int_to_datetime(date_int, time_int)
    assert_equal(result.year, 2020)
    assert_equal(result.month, 1)
    assert_equal(result.day, 15)
    assert_equal(result.hour, 14)
    assert_equal(result.minute, 30)
    assert_equal(result.second, 0)
    assert_equal(result.microsecond, 500000)


def test_to_date_from_string() raises:
    var result = to_date("2025-01-15")
    assert_equal(result.year, 2025)
    assert_equal(result.month, 1)
    assert_equal(result.day, 15)


def test_to_date_from_datetime() raises:
    var dt = DateTime(2025, 3, 20, 12, 45, 30, 999999)
    var result = to_date(dt)
    assert_equal(result.year, 2025)
    assert_equal(result.month, 3)
    assert_equal(result.day, 20)


def test_to_date_from_date() raises:
    var d = DateTimeDate(2025, 6, 10)
    var result = to_date(d)
    assert_equal(result.year, 2025)
    assert_equal(result.month, 6)
    assert_equal(result.day, 10)


def test_to_date_from_py_datetime() raises:
    var dt_module = Python.import_module("datetime")
    var py_dt = dt_module.datetime(2025, 9, 1, 0, 0, 0)
    var result = to_date(py_dt)
    assert_equal(result.year, 2025)
    assert_equal(result.month, 9)
    assert_equal(result.day, 1)


def test_to_date_from_py_date() raises:
    var dt_module = Python.import_module("datetime")
    var py_d = dt_module.date(2025, 12, 25)
    var result = to_date(py_d)
    assert_equal(result.year, 2025)
    assert_equal(result.month, 12)
    assert_equal(result.day, 25)


def test_to_date_invalid_type() raises:
    with assert_raises():
        _ = to_date(42)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
