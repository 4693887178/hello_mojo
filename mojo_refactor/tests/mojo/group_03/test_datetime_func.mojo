"""
RQAlpha Mojo - DateTime Functions Module Test
Tests for utils/datetime_func.mojo
"""

from rqmojo.utils.datetime_func import (
    convert_date_to_date_int, convert_date_to_int,
    convert_int_to_date, convert_int_to_datetime,
    TimeRange
)
from rqmojo.utils.typing import DateTime, DateTimeDate


def test_convert_date_to_date_int() raises:
    """Test that convert_date_to_date_int returns correct value."""
    var dt = DateTimeDate(2020, 1, 15)
    var result = convert_date_to_date_int(dt)
    assert result == 20200115, "convert_date_to_date_int should return 20200115"
    print("  convert_date_to_date_int test passed!")


def test_convert_date_to_int() raises:
    """Test that convert_date_to_int returns correct value."""
    var dt = DateTimeDate(2020, 1, 15)
    var result = convert_date_to_int(dt)
    assert result > 0, "convert_date_to_int should return positive value"
    print("  convert_date_to_int test passed!")


def test_convert_int_to_date() raises:
    """Test that convert_int_to_date returns correct value."""
    var result = convert_int_to_date(20200115)
    assert result.year == 2020, "Year should be 2020"
    assert result.month == 1, "Month should be 1"
    assert result.day == 15, "Day should be 15"
    print("  convert_int_to_date test passed!")


def test_convert_int_to_datetime() raises:
    """Test that convert_int_to_datetime returns correct value."""
    var result = convert_int_to_datetime(20200115143000)
    assert result.year == 2020, "Year should be 2020"
    assert result.month == 1, "Month should be 1"
    assert result.day == 15, "Day should be 15"
    print("  convert_int_to_datetime test passed!")


def main() raises:
    print("============================================================")
    print("Testing utils/datetime_func.mojo")
    print("============================================================")
    
    test_convert_date_to_date_int()
    test_convert_date_to_int()
    test_convert_int_to_date()
    test_convert_int_to_datetime()
    
    print("============================================================")
    print("All utils/datetime_func.mojo tests passed!")
    print("============================================================")
