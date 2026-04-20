"""
Mojo Test for utils/datetime_func.mojo
Tests the datetime functions
"""

from rqmojo.utils.datetime_func import (
    Date, DateTime, TimeRange,
    convert_date_to_date_int,
    convert_date_to_int,
    convert_int_to_date,
    convert_int_to_datetime,
    to_date_from_string,
    to_date_from_datetime,
    to_date_from_date
)


def test_date_struct():
    var d = Date(2024, 1, 15)
    print("Date: " + d.__str__())
    assert d.year == 2024
    assert d.month == 1
    assert d.day == 15


def test_datetime_struct():
    var dt = DateTime(2024, 1, 15, 10, 30, 45, 0)
    print("DateTime: " + dt.__str__())
    assert dt.year == 2024
    assert dt.hour == 10
    assert dt.minute == 30


def test_convert_date_to_date_int():
    var d = Date(2024, 1, 15)
    var result = convert_date_to_date_int(d)
    print("Date to int: " + String(result))
    assert result == 20240115


def test_convert_int_to_date():
    var dt = convert_int_to_date(20240115)
    print("Int to date: " + dt.__str__())
    assert dt.year == 2024
    assert dt.month == 1
    assert dt.day == 15


def test_to_date_from_date():
    var d = Date(2024, 1, 15)
    var result = to_date_from_date(d)
    print("to_date_from_date: " + result.__str__())
    assert result.year == 2024


def test_to_date_from_datetime():
    var dt = DateTime(2024, 1, 15, 10, 30, 45, 0)
    var result = to_date_from_datetime(dt)
    print("to_date_from_datetime: " + result.__str__())
    assert result.year == 2024
    assert result.month == 1
    assert result.day == 15


def test_time_range():
    var tr = TimeRange(9, 30, 11, 30)
    print("TimeRange: " + String(tr.start_hour) + ":" + String(tr.start_minute) + " - " + String(tr.end_hour) + ":" + String(tr.end_minute))
    assert tr.start_hour == 9
    assert tr.end_hour == 11


def main():
    print("=== Testing utils/datetime_func.mojo ===")
    test_date_struct()
    test_datetime_struct()
    test_convert_date_to_date_int()
    test_convert_int_to_date()
    test_to_date_from_date()
    test_to_date_from_datetime()
    test_time_range()
    print("All datetime_func tests passed!")
