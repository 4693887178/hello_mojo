# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/datetime_func.py
Tests for datetime conversion functions
"""

import pytest
import datetime


class TestConvertDateToDateInt:
    """Tests for convert_date_to_date_int function"""

    def test_convert_date_to_date_int_exists(self):
        """Test that convert_date_to_date_int function exists"""
        from rqalpha.utils.datetime_func import convert_date_to_date_int
        assert callable(convert_date_to_date_int)

    def test_convert_date_to_date_int_value(self):
        """Test that convert_date_to_date_int returns correct value"""
        from rqalpha.utils.datetime_func import convert_date_to_date_int
        dt = datetime.date(2020, 1, 15)
        result = convert_date_to_date_int(dt)
        assert result == 20200115


class TestConvertDateToInt:
    """Tests for convert_date_to_int function"""

    def test_convert_date_to_int_exists(self):
        """Test that convert_date_to_int function exists"""
        from rqalpha.utils.datetime_func import convert_date_to_int
        assert callable(convert_date_to_int)

    def test_convert_date_to_int_value(self):
        """Test that convert_date_to_int returns correct value"""
        from rqalpha.utils.datetime_func import convert_date_to_int
        dt = datetime.date(2020, 1, 15)
        result = convert_date_to_int(dt)
        assert result > 0


class TestConvertIntToDate:
    """Tests for convert_int_to_date function"""

    def test_convert_int_to_date_exists(self):
        """Test that convert_int_to_date function exists"""
        from rqalpha.utils.datetime_func import convert_int_to_date
        assert callable(convert_int_to_date)

    def test_convert_int_to_date_value(self):
        """Test that convert_int_to_date returns correct value"""
        from rqalpha.utils.datetime_func import convert_int_to_date
        result = convert_int_to_date(20200115)
        assert result.year == 2020
        assert result.month == 1
        assert result.day == 15


class TestToInt:
    """Tests for convert_dt_to_int function"""

    def test_convert_dt_to_int_exists(self):
        """Test that convert_dt_to_int function exists"""
        from rqalpha.utils.datetime_func import convert_dt_to_int
        assert callable(convert_dt_to_int)
