"""
Test for data/trading_dates_mixin.mojo
Group 08 - File 10
"""

from rqmojo.data.trading_dates_mixin import (
    TradingDatesMixin,
    TradingDateResult,
    create_trading_dates_mixin,
    create_trading_dates_mixin_with_november_2018,
    create_trading_dates_mixin_with_november_2024,
    create_trading_dates_mixin_with_multiple_months,
)
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_trading_dates_mixin_init() raises:
    var mixin = create_trading_dates_mixin()
    assert_equal(mixin.get_trading_dates_count(), 0, "empty init count")


def test_trading_dates_mixin_count_trading_dates() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var count = mixin.count_trading_dates(2018, 11, 1, 2018, 11, 30)
    assert_equal(count, 22, "Nov 2018 full month count")
    var count2 = mixin.count_trading_dates(2018, 11, 1, 2018, 11, 12)
    assert_equal(count2, 8, "Nov 2018 partial count")
    var count3 = mixin.count_trading_dates(2018, 11, 3, 2018, 11, 12)
    assert_equal(count3, 6, "Nov 2018 start on weekend")


def test_trading_dates_mixin_is_trading_date() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_true(mixin.is_trading_date(2018, 11, 1), "Nov 1 is trading day")
    assert_false(mixin.is_trading_date(2018, 11, 3), "Nov 3 is weekend")


def test_trading_dates_mixin_get_previous_trading_date() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var prev_date = mixin.get_previous_trading_date(2018, 11, 2)
    assert_equal(prev_date.day, 1, "Nov 2 prev -> Nov 1")


def test_trading_dates_mixin_get_next_trading_date() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var next_date = mixin.get_next_trading_date(2018, 11, 2)
    assert_equal(next_date.day, 5, "Nov 2 next -> Nov 5")


def test_trading_dates_mixin_get_trading_dates() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 1, 2018, 11, 9)
    assert_equal(len(dates), 7, "Nov 1-9 has 7 trading days")


def test_trading_dates_mixin_get_n_trading_dates_until() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_n_trading_dates_until(2018, 11, 9, 3)
    assert_equal(len(dates), 3, "3 dates until Nov 9")
    assert_equal(dates[2].day, 9, "last is Nov 9")


def test_trading_dates_mixin_get_future_trading_date() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 5, 9, 30, 0)
    assert_equal(result.day, 5, "9:30 AM -> same day")
    var result2 = mixin.get_future_trading_date(2018, 11, 5, 21, 0, 0)
    assert_equal(result2.day, 6, "9:00 PM -> next trading day")


def test_trading_dates_mixin_get_trading_dt() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dt = mixin.get_trading_dt(2018, 11, 5, 9, 30, 0)
    assert_equal(dt.day, 5, "trading_dt day")
    assert_equal(dt.hour, 9, "trading_dt hour")


def test_trading_dates_mixin_get_future_trading_date_invalid() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    with assert_raises():
        _ = mixin.get_future_trading_date(2018, 11, 3, 10, 0, 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
