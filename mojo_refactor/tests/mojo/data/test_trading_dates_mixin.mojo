"""
Comprehensive tests for data/trading_dates_mixin.mojo
Tests all methods ported from rqalpha/data/trading_dates_mixin.py
Uses November 2018 trading calendar for validation:
  Trading days: 1,2,5,6,7,8,9,12,13,14,15,16,19,20,21,22,23,26,27,28,29,30
  Non-trading days (weekends): 3,4,10,11,17,18,24,25
"""

from rqmojo.data.trading_dates_mixin import (
    TradingDatesMixin,
    TradingDateResult,
    create_trading_date_result,
    create_trading_dates_mixin,
    create_trading_dates_mixin_with_november_2018,
    create_trading_dates_mixin_with_november_2024,
    create_trading_dates_mixin_with_multiple_months,
    _date_to_int,
    _int_to_year,
    _int_to_month,
    _int_to_day,
    _int_to_result,
    _days_in_month,
)
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_helper_date_to_int() raises:
    assert_equal(_date_to_int(2018, 11, 1), 20181101, "date_to_int basic")
    assert_equal(_date_to_int(2024, 1, 15), 20240115, "date_to_int with zero-padded month")
    assert_equal(_date_to_int(2024, 1, 5), 20240105, "date_to_int with zero-padded day")
    assert_equal(_date_to_int(2000, 12, 31), 20001231, "date_to_int year end")


def test_helper_int_to_year_month_day() raises:
    assert_equal(_int_to_year(20181101), 2018, "int_to_year")
    assert_equal(_int_to_month(20181101), 11, "int_to_month")
    assert_equal(_int_to_day(20181101), 1, "int_to_day")
    assert_equal(_int_to_year(20240105), 2024, "int_to_year zero month")
    assert_equal(_int_to_month(20240105), 1, "int_to_month jan")
    assert_equal(_int_to_day(20240105), 5, "int_to_day zero-padded")


def test_helper_int_to_result() raises:
    var r = _int_to_result(20181105)
    assert_equal(r.year, 2018, "int_to_result year")
    assert_equal(r.month, 11, "int_to_result month")
    assert_equal(r.day, 5, "int_to_result day")


def test_helper_days_in_month() raises:
    assert_equal(_days_in_month(2018, 1), 31, "January has 31 days")
    assert_equal(_days_in_month(2018, 2), 28, "Feb non-leap 28")
    assert_equal(_days_in_month(2020, 2), 29, "Feb leap year 29")
    assert_equal(_days_in_month(1900, 2), 28, "Feb century non-leap 28")
    assert_equal(_days_in_month(2000, 2), 29, "Feb 400-year leap 29")
    assert_equal(_days_in_month(2018, 3), 31, "March 31")
    assert_equal(_days_in_month(2018, 4), 30, "April 30")
    assert_equal(_days_in_month(2018, 5), 31, "May 31")
    assert_equal(_days_in_month(2018, 6), 30, "June 30")
    assert_equal(_days_in_month(2018, 7), 31, "July 31")
    assert_equal(_days_in_month(2018, 8), 31, "August 31")
    assert_equal(_days_in_month(2018, 9), 30, "September 30")
    assert_equal(_days_in_month(2018, 10), 31, "October 31")
    assert_equal(_days_in_month(2018, 11), 30, "November 30")
    assert_equal(_days_in_month(2018, 12), 31, "December 31")


def test_trading_date_result_to_int() raises:
    var r = create_trading_date_result(2018, 11, 5)
    assert_equal(r.to_int(), 20181105, "TradingDateResult.to_int()")


def test_create_trading_dates_mixin_empty() raises:
    var mixin = create_trading_dates_mixin()
    assert_equal(mixin.get_trading_dates_count(), 0, "empty mixin count")
    assert_false(mixin.is_trading_date(2018, 11, 1), "empty mixin is_trading_date")
    assert_equal(mixin.count_trading_dates(2018, 11, 1, 2018, 11, 30), 0, "empty mixin count_trading_dates")


def test_create_trading_dates_mixin_november_2018() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_equal(mixin.get_trading_dates_count(), 22, "Nov 2018 has 22 trading days")


def test_is_trading_date_trading_day() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_true(mixin.is_trading_date(2018, 11, 1), "Nov 1 is trading day")
    assert_true(mixin.is_trading_date(2018, 11, 2), "Nov 2 is trading day")
    assert_true(mixin.is_trading_date(2018, 11, 5), "Nov 5 is trading day")
    assert_true(mixin.is_trading_date(2018, 11, 30), "Nov 30 is trading day")


def test_is_trading_date_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_false(mixin.is_trading_date(2018, 11, 3), "Nov 3 Sat is not trading day")
    assert_false(mixin.is_trading_date(2018, 11, 4), "Nov 4 Sun is not trading day")
    assert_false(mixin.is_trading_date(2018, 11, 10), "Nov 10 Sat is not trading day")
    assert_false(mixin.is_trading_date(2018, 11, 11), "Nov 11 Sun is not trading day")
    assert_false(mixin.is_trading_date(2018, 11, 17), "Nov 17 Sat is not trading day")
    assert_false(mixin.is_trading_date(2018, 11, 18), "Nov 18 Sun is not trading day")


def test_is_trading_date_outside_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_false(mixin.is_trading_date(2018, 10, 31), "Oct 31 outside range")
    assert_false(mixin.is_trading_date(2018, 12, 1), "Dec 1 outside range")
    assert_false(mixin.is_trading_date(2024, 1, 1), "2024 outside range")


def test_count_trading_dates_full_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_equal(mixin.count_trading_dates(2018, 11, 1, 2018, 11, 30), 22, "full Nov 2018")


def test_count_trading_dates_partial_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_equal(mixin.count_trading_dates(2018, 11, 1, 2018, 11, 12), 8, "Nov 1-12")
    assert_equal(mixin.count_trading_dates(2018, 11, 3, 2018, 11, 12), 6, "Nov 3-12 (start on weekend)")
    assert_equal(mixin.count_trading_dates(2018, 11, 3, 2018, 11, 18), 10, "Nov 3-18 (both weekends)")


def test_count_trading_dates_same_day() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_equal(mixin.count_trading_dates(2018, 11, 1, 2018, 11, 1), 1, "same trading day")
    assert_equal(mixin.count_trading_dates(2018, 11, 3, 2018, 11, 3), 0, "same non-trading day")


def test_count_trading_dates_outside_calendar() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    assert_equal(mixin.count_trading_dates(2018, 10, 1, 2018, 10, 31), 0, "before range")
    assert_equal(mixin.count_trading_dates(2024, 12, 1, 2024, 12, 31), 0, "after range")


def test_get_previous_trading_date_basic() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 2)
    assert_equal(result.year, 2018, "prev year")
    assert_equal(result.month, 11, "prev month")
    assert_equal(result.day, 1, "prev day: Nov 2 -> Nov 1")


def test_get_previous_trading_date_over_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 5)
    assert_equal(result.day, 2, "Nov 5 -> Nov 2 (skip weekend)")


def test_get_previous_trading_date_from_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 3)
    assert_equal(result.day, 2, "Nov 3 (Sat) -> Nov 2")


def test_get_previous_trading_date_n_equals_2() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 7, n=2)
    assert_equal(result.day, 5, "Nov 7 - 2 = Nov 5 (trading dates: 1,2,5,6,7; pos=4, pos-2=2 -> Nov 5)")


def test_get_previous_trading_date_n_equals_3_over_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 7, n=3)
    assert_equal(result.day, 2, "Nov 7 - 3 = Nov 2 (pos=4, pos-3=1 -> Nov 2)")


def test_get_previous_trading_date_n_exceeds_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 1, n=5)
    assert_equal(result.day, 1, "n exceeds range returns first trading day")


def test_get_next_trading_date_basic() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 1)
    assert_equal(result.day, 2, "Nov 1 -> Nov 2")


def test_get_next_trading_date_over_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 2)
    assert_equal(result.day, 5, "Nov 2 -> Nov 5 (skip weekend)")


def test_get_next_trading_date_from_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 3)
    assert_equal(result.day, 5, "Nov 3 (Sat) -> Nov 5")


def test_get_next_trading_date_n_equals_2() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 1, n=2)
    assert_equal(result.day, 5, "Nov 1 + 2 = Nov 5")


def test_get_next_trading_date_n_exceeds_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 29, n=5)
    assert_equal(result.day, 30, "n exceeds range returns last trading day")


def test_get_next_trading_date_after_last() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 30)
    assert_equal(result.day, 30, "after last returns last")


def test_get_trading_dates_basic() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 1, 2018, 11, 9)
    assert_equal(len(dates), 7, "Nov 1-9 has 7 trading days")
    assert_equal(dates[0].day, 1, "first date is Nov 1")
    assert_equal(dates[6].day, 9, "last date is Nov 9")


def test_get_trading_dates_over_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 2, 2018, 11, 5)
    assert_equal(len(dates), 2, "Nov 2-5 has 2 trading days")
    assert_equal(dates[0].day, 2, "first is Nov 2")
    assert_equal(dates[1].day, 5, "second is Nov 5")


def test_get_trading_dates_full_month() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 1, 2018, 11, 30)
    assert_equal(len(dates), 22, "full Nov 2018 has 22 trading days")


def test_get_trading_dates_empty_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 10, 1, 2018, 10, 31)
    assert_equal(len(dates), 0, "outside range returns empty")


def test_get_trading_dates_same_day() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 1, 2018, 11, 1)
    assert_equal(len(dates), 1, "same trading day")
    assert_equal(dates[0].day, 1, "same day is Nov 1")


def test_get_n_trading_dates_until_basic() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_n_trading_dates_until(2018, 11, 9, 3)
    assert_equal(len(dates), 3, "3 dates until Nov 9")
    assert_equal(dates[0].day, 7, "first is Nov 7")
    assert_equal(dates[1].day, 8, "second is Nov 8")
    assert_equal(dates[2].day, 9, "third is Nov 9")


def test_get_n_trading_dates_until_from_weekend() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_n_trading_dates_until(2018, 11, 4, 2)
    assert_equal(len(dates), 2, "2 dates until Nov 4 (Sun)")
    assert_equal(dates[0].day, 1, "first is Nov 1")
    assert_equal(dates[1].day, 2, "second is Nov 2")


def test_get_n_trading_dates_until_n_exceeds() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_n_trading_dates_until(2018, 11, 2, 10)
    assert_equal(len(dates), 2, "n exceeds available returns all available")
    assert_equal(dates[0].day, 1, "first is Nov 1")
    assert_equal(dates[1].day, 2, "second is Nov 2")


def test_get_n_trading_dates_until_before_range() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_n_trading_dates_until(2018, 10, 31, 3)
    assert_equal(len(dates), 0, "before range returns empty")


def test_get_future_trading_date_morning() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 5, 9, 30, 0)
    assert_equal(result.day, 5, "9:30 AM on trading day -> same day")


def test_get_future_trading_date_afternoon() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 5, 15, 0, 0)
    assert_equal(result.day, 5, "3:00 PM on trading day -> same day")


def test_get_future_trading_date_night_session() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 5, 21, 0, 0)
    assert_equal(result.day, 6, "9:00 PM (night session) -> next trading day")


def test_get_future_trading_date_8pm_boundary() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 5, 20, 0, 0)
    assert_equal(result.day, 6, "8:00 PM exactly -> next trading day")


def test_get_future_trading_date_before_8pm() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 5, 19, 59, 0)
    assert_equal(result.day, 5, "7:59 PM -> same day")


def test_get_future_trading_date_midnight_cross() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 6, 1, 0, 0)
    assert_equal(result.day, 6, "1:00 AM Nov 6: dt1=Nov5 21:00, hour>=16 -> Nov 6")
    var result2 = mixin.get_future_trading_date(2018, 11, 6, 0, 30, 0)
    assert_equal(result2.day, 6, "0:30 AM Nov 6: dt1=Nov5 20:30, hour>=16 -> Nov 6")


def test_get_future_trading_date_4am_boundary() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 6, 3, 0, 0)
    assert_equal(result.day, 6, "3:00 AM Nov 6: dt1=Nov5 23:00, hour>=16 -> Nov 6")
    var result2 = mixin.get_future_trading_date(2018, 11, 6, 4, 0, 0)
    assert_equal(result2.day, 6, "4:00 AM Nov 6: dt1=Nov6 0:00, hour<16 -> Nov 6")


def test_get_future_trading_date_invalid() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    with assert_raises():
        _ = mixin.get_future_trading_date(2018, 11, 3, 10, 0, 0)


def test_get_future_trading_date_friday_night() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_future_trading_date(2018, 11, 9, 21, 0, 0)
    assert_equal(result.day, 12, "Friday night -> next Monday (Nov 12)")


def test_get_trading_dt_basic() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dt = mixin.get_trading_dt(2018, 11, 5, 9, 30, 0)
    assert_equal(dt.year, 2018, "trading_dt year")
    assert_equal(dt.month, 11, "trading_dt month")
    assert_equal(dt.day, 5, "trading_dt day")
    assert_equal(dt.hour, 9, "trading_dt hour")
    assert_equal(dt.minute, 30, "trading_dt minute")
    assert_equal(dt.second, 0, "trading_dt second")


def test_get_trading_dt_night_session() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dt = mixin.get_trading_dt(2018, 11, 5, 21, 0, 0)
    assert_equal(dt.day, 6, "night session trading_dt day")
    assert_equal(dt.hour, 21, "night session trading_dt hour")


def test_multiple_months_count() raises:
    var mixin = create_trading_dates_mixin_with_multiple_months()
    var count_nov2018 = mixin.count_trading_dates(2018, 11, 1, 2018, 11, 30)
    assert_equal(count_nov2018, 22, "Nov 2018 in multi-month")
    var count_nov2024 = mixin.count_trading_dates(2024, 11, 1, 2024, 11, 30)
    assert_equal(count_nov2024, 21, "Nov 2024 in multi-month")


def test_multiple_months_is_trading_date() raises:
    var mixin = create_trading_dates_mixin_with_multiple_months()
    assert_true(mixin.is_trading_date(2018, 11, 1), "2018 Nov 1 in multi")
    assert_true(mixin.is_trading_date(2024, 11, 1), "2024 Nov 1 in multi")
    assert_false(mixin.is_trading_date(2018, 11, 3), "2018 Nov 3 weekend in multi")
    assert_false(mixin.is_trading_date(2024, 11, 2), "2024 Nov 2 weekend in multi")


def test_multiple_months_cross_year() raises:
    var mixin = create_trading_dates_mixin_with_multiple_months()
    var count = mixin.count_trading_dates(2018, 11, 1, 2024, 11, 30)
    assert_equal(count, 43, "cross-year count = 22 + 21")


def test_november_2024_calendar() raises:
    var mixin = create_trading_dates_mixin_with_november_2024()
    assert_equal(mixin.get_trading_dates_count(), 21, "Nov 2024 has 21 trading days")
    assert_true(mixin.is_trading_date(2024, 11, 1), "Nov 1 2024 is trading day")
    assert_false(mixin.is_trading_date(2024, 11, 2), "Nov 2 2024 is Saturday")
    assert_false(mixin.is_trading_date(2024, 11, 3), "Nov 3 2024 is Sunday")
    assert_true(mixin.is_trading_date(2024, 11, 4), "Nov 4 2024 is trading day")


def test_binary_search_left_empty() raises:
    var mixin = create_trading_dates_mixin()
    assert_equal(mixin.count_trading_dates(2018, 11, 1, 2018, 11, 30), 0, "empty count")
    assert_false(mixin.is_trading_date(2018, 11, 1), "empty is_trading_date")


def test_get_previous_trading_date_from_non_trading() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_previous_trading_date(2018, 11, 4)
    assert_equal(result.day, 2, "Nov 4 (Sun) prev -> Nov 2")


def test_get_next_trading_date_from_non_trading() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var result = mixin.get_next_trading_date(2018, 11, 4)
    assert_equal(result.day, 5, "Nov 4 (Sun) next -> Nov 5")


def test_get_trading_dates_non_trading_start() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 3, 2018, 11, 5)
    assert_equal(len(dates), 1, "Nov 3-5: 1 trading day (only Nov 5, weekends excluded)")
    assert_equal(dates[0].day, 5, "only trading day in range is Nov 5")


def test_get_trading_dates_non_trading_end() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_trading_dates(2018, 11, 1, 2018, 11, 3)
    assert_equal(len(dates), 2, "Nov 1-3: 2 trading days (1,2)")
    assert_equal(dates[0].day, 1, "first is Nov 1")
    assert_equal(dates[1].day, 2, "second is Nov 2")


def test_get_n_trading_dates_until_end_of_month() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var dates = mixin.get_n_trading_dates_until(2018, 11, 30, 5)
    assert_equal(len(dates), 5, "5 dates until Nov 30")
    assert_equal(dates[4].day, 30, "last is Nov 30")
    assert_equal(dates[0].day, 26, "first is Nov 26")


def test_trading_date_result_write_to() raises:
    var r = create_trading_date_result(2024, 11, 5)
    var s = String.write(r)
    assert_equal(s, "2024-11-5", "write_to format")


def test_mixin_write_to() raises:
    var mixin = create_trading_dates_mixin_with_november_2018()
    var s = String.write(mixin)
    assert_equal(s, "TradingDatesMixin(count=22)", "write_to format")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
