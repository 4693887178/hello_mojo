# -*- coding: utf-8 -*-
"""
Python Test for rqalpha/utils/datetime_func.py
Tests the datetime functions
"""

import pytest
import datetime


def test_convert_date_to_date_int():
    """Test convert_date_to_date_int function"""
    from rqalpha.utils.datetime_func import convert_date_to_date_int
    
    dt = datetime.date(2024, 1, 15)
    result = convert_date_to_date_int(dt)
    assert result == 20240115


def test_convert_date_to_int():
    """Test convert_date_to_int function"""
    from rqalpha.utils.datetime_func import convert_date_to_int
    
    dt = datetime.date(2024, 1, 15)
    result = convert_date_to_int(dt)
    assert result == 20240115000000


def test_convert_dt_to_int():
    """Test convert_dt_to_int function"""
    from rqalpha.utils.datetime_func import convert_dt_to_int
    
    dt = datetime.datetime(2024, 1, 15, 10, 30, 45)
    result = convert_dt_to_int(dt)
    assert result is not None


def test_convert_int_to_date():
    """Test convert_int_to_date function"""
    from rqalpha.utils.datetime_func import convert_int_to_date
    
    result = convert_int_to_date(20240115)
    assert result.year == 2024
    assert result.month == 1
    assert result.day == 15


def test_convert_int_to_datetime():
    """Test convert_int_to_datetime function"""
    from rqalpha.utils.datetime_func import convert_int_to_datetime
    
    result = convert_int_to_datetime(20240115103045)
    assert result.year == 2024
    assert result.month == 1
    assert result.day == 15
    assert result.hour == 10
    assert result.minute == 30
    assert result.second == 45


def test_convert_ms_int_to_datetime():
    """Test convert_ms_int_to_datetime function"""
    from rqalpha.utils.datetime_func import convert_ms_int_to_datetime
    
    result = convert_ms_int_to_datetime(20240115103045123)
    assert result.year == 2024
    assert result.microsecond == 123000


def test_to_date_from_string():
    """Test to_date function with string input"""
    from rqalpha.utils.datetime_func import to_date
    
    result = to_date("2024-01-15")
    assert result.year == 2024
    assert result.month == 1
    assert result.day == 15


def test_to_date_from_date():
    """Test to_date function with date input"""
    from rqalpha.utils.datetime_func import to_date
    
    dt = datetime.date(2024, 1, 15)
    result = to_date(dt)
    assert result.year == 2024
    assert result.month == 1
    assert result.day == 15


def test_to_date_from_datetime():
    """Test to_date function with datetime input"""
    from rqalpha.utils.datetime_func import to_date
    
    dt = datetime.datetime(2024, 1, 15, 10, 30, 45)
    result = to_date(dt)
    assert result.year == 2024
    assert result.month == 1
    assert result.day == 15


def test_time_range():
    """Test TimeRange namedtuple"""
    from rqalpha.utils.datetime_func import TimeRange
    
    tr = TimeRange(start=930, end=1130)
    assert tr.start == 930
    assert tr.end == 1130


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
