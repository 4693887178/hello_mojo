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



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_convert_date_to_date_int() raises:
    """Test that convert_date_to_date_int returns correct value."""
    var dt = DateTimeDate(2020, 1, 15)
    var result = convert_date_to_date_int(dt)
    assert_equal(result, 20200115, "convert_date_to_date_int should return 20200115")
    print("  convert_date_to_date_int test passed!")


def test_convert_date_to_int() raises:
    """Test that convert_date_to_int returns correct value."""
    var dt = DateTimeDate(2020, 1, 15)
    var result = convert_date_to_int(dt)
    assert_true(result > 0, "convert_date_to_int should return positive value")
    print("  convert_date_to_int test passed!")


def test_convert_int_to_date() raises:
    """Test that convert_int_to_date returns correct value."""
    var result = convert_int_to_date(20200115)
    assert_equal(result.year, 2020, "Year should be 2020")
    assert_true(result.month == 1, "Month should be 1")
    assert_equal(result.day, 15, "Day should be 15")
    print("  convert_int_to_date test passed!")


def test_convert_int_to_datetime() raises:
    """Test that convert_int_to_datetime returns correct value."""
    var result = convert_int_to_datetime(20200115143000)
    assert_equal(result.year, 2020, "Year should be 2020")
    assert_true(result.month == 1, "Month should be 1")
    assert_equal(result.day, 15, "Day should be 15")
    print("  convert_int_to_datetime test passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()