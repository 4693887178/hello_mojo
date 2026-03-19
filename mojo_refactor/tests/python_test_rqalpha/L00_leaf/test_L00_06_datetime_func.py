# test_L00_06_datetime_func.py
# Module: rqalpha.utils.datetime_func
# Mojo: rqmojo.utils.datetime_func
# Level: L00 - Leaf module
# Dependencies: functools, exception

import pytest
from datetime import datetime, date
from rqalpha.utils import datetime_func


class TestL00DatetimeFunc:
    """L00 - datetime_func module tests"""

    class TestTimeRange:
        """TimeRange tests"""

        def test_time_range(self):
            """Test TimeRange namedtuple"""
            tr = datetime_func.TimeRange(start=9, end=15)
            assert tr.start == 9
            assert tr.end == 15

    class TestConvertDateToDateInt:
        """convert_date_to_date_int tests"""

        def test_convert_date_to_date_int(self):
            """Test convert_date_to_date_int"""
            dt = date(2023, 1, 15)
            result = datetime_func.convert_date_to_date_int(dt)
            assert result == 20230115

        def test_convert_datetime_to_date_int(self):
            """Test convert_date_to_date_int with datetime"""
            dt = datetime(2023, 6, 20, 14, 30, 0)
            result = datetime_func.convert_date_to_date_int(dt)
            assert result == 20230620

    class TestConvertDateToInt:
        """convert_date_to_int tests"""

        def test_convert_date_to_int(self):
            """Test convert_date_to_int"""
            dt = date(2023, 1, 15)
            result = datetime_func.convert_date_to_int(dt)
            assert result == 20230115000000

    class TestConvertDtToInt:
        """convert_dt_to_int tests"""

        def test_convert_dt_to_int(self):
            """Test convert_dt_to_int"""
            dt = datetime(2023, 1, 15, 14, 30, 45)
            result = datetime_func.convert_dt_to_int(dt)
            assert result == 20230115143045

    class TestConvertIntToDate:
        """convert_int_to_date tests"""

        def test_convert_int_to_date(self):
            """Test convert_int_to_date"""
            result = datetime_func.convert_int_to_date(20230115)
            assert result.year == 2023
            assert result.month == 1
            assert result.day == 15

    class TestConvertIntToDatetime:
        """convert_int_to_datetime tests"""

        def test_convert_int_to_datetime(self):
            """Test convert_int_to_datetime"""
            result = datetime_func.convert_int_to_datetime(20230115143045)
            assert result.year == 2023
            assert result.month == 1
            assert result.day == 15
            assert result.hour == 14
            assert result.minute == 30
            assert result.second == 45

    class TestConvertMsIntToDatetime:
        """convert_ms_int_to_datetime tests"""

        def test_convert_ms_int_to_datetime(self):
            """Test convert_ms_int_to_datetime"""
            result = datetime_func.convert_ms_int_to_datetime(20230115143045123)
            assert result.year == 2023
            assert result.microsecond == 123000

    class TestToDate:
        """to_date tests"""

        def test_to_date_from_string(self):
            """Test to_date from string"""
            result = datetime_func.to_date("2023-01-15")
            assert result == date(2023, 1, 15)

        def test_to_date_from_date(self):
            """Test to_date from date"""
            result = datetime_func.to_date(date(2023, 1, 15))
            assert result == date(2023, 1, 15)

        def test_to_date_from_datetime(self):
            """Test to_date from datetime"""
            result = datetime_func.to_date(datetime(2023, 1, 15, 14, 30))
            assert result.year == 2023
            assert result.month == 1
            assert result.day == 15

    class TestModuleStructure:
        """Module structure tests"""

        def test_time_range_exists(self):
            """Test TimeRange exists"""
            assert hasattr(datetime_func, 'TimeRange')

        def test_convert_date_to_date_int_exists(self):
            """Test convert_date_to_date_int exists"""
            assert hasattr(datetime_func, 'convert_date_to_date_int')

        def test_convert_date_to_int_exists(self):
            """Test convert_date_to_int exists"""
            assert hasattr(datetime_func, 'convert_date_to_int')

        def test_convert_dt_to_int_exists(self):
            """Test convert_dt_to_int exists"""
            assert hasattr(datetime_func, 'convert_dt_to_int')

        def test_convert_int_to_date_exists(self):
            """Test convert_int_to_date exists"""
            assert hasattr(datetime_func, 'convert_int_to_date')

        def test_convert_int_to_datetime_exists(self):
            """Test convert_int_to_datetime exists"""
            assert hasattr(datetime_func, 'convert_int_to_datetime')
