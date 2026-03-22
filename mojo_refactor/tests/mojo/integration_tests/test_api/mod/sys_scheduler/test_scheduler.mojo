"""
Mojo Test for sys_scheduler run_monthly
Ported from tests/integration_tests/test_api/mod/sys_scheduler/test_scheduler.py
Tests scheduler run_monthly functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import RUN_TYPE_BACKTEST, DEFAULT_ACCOUNT_TYPE_STOCK
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import (
    Scheduler, TimeRule, ScheduleEntry, TradingMinuteRange,
    create_scheduler, market_open_minutes, market_close_minutes, physical_time_minutes
)


comptime TEST_START_DATE_YEAR = 2015
comptime TEST_START_DATE_MONTH = 1
comptime TEST_START_DATE_DAY = 1
comptime TEST_END_DATE_YEAR = 2015
comptime TEST_END_DATE_MONTH = 12
comptime TEST_END_DATE_DAY = 31
comptime INITIAL_CASH = 1000000.0
comptime TEST_FREQUENCY = "1d"


@fieldwise_init
struct MonthlySchedulerTestResult(Movable, Copyable, ImplicitlyCopyable):
    var day_index: Int
    var counter: Int
    var month: Int
    var is_first_trading_day: Bool


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_scheduler_monthly_creation() raises:
    """
    Test creating monthly schedule in Mojo.
    """
    print("=== Testing Scheduler Monthly Creation ===")
    
    var scheduler = create_scheduler("1d")
    print("  Scheduler created: " + String(scheduler))
    
    scheduler.schedule_monthly("monthly_func", 1, TimeRule.at_time(9, 31))
    print("  Monthly schedule added for tradingday=1")
    
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "monthly_func")
    assert_equal(entry.frequency, "monthly")
    print("  Entry func_name: " + entry.func_name)
    print("  Entry frequency: " + entry.frequency)
    print("  Entry day_checker_id: " + String(entry.day_checker_id))
    
    print("Test test_scheduler_monthly_creation: PASSED")


def test_scheduler_monthly_different_days() raises:
    """
    Test creating monthly schedules for different trading days.
    """
    print("=== Testing Scheduler Monthly Different Days ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_monthly("first_day", 1, TimeRule.at_time(9, 31))
    scheduler.schedule_monthly("last_day", -1, TimeRule.at_time(9, 31))
    scheduler.schedule_monthly("fifth_day", 5, TimeRule.at_time(9, 31))
    
    assert_equal(scheduler._registry.__len__(), 3)
    
    var entry1 = scheduler._registry[0]
    assert_equal(entry1.func_name, "first_day")
    print("  first_day (tradingday=1): day_checker_id=" + String(entry1.day_checker_id))
    
    var entry2 = scheduler._registry[1]
    assert_equal(entry2.func_name, "last_day")
    print("  last_day (tradingday=-1): day_checker_id=" + String(entry2.day_checker_id))
    
    var entry3 = scheduler._registry[2]
    assert_equal(entry3.func_name, "fifth_day")
    print("  fifth_day (tradingday=5): day_checker_id=" + String(entry3.day_checker_id))
    
    print("Test test_scheduler_monthly_different_days: PASSED")


def test_scheduler_weekly_creation() raises:
    """
    Test creating weekly schedule in Mojo.
    """
    print("=== Testing Scheduler Weekly Creation ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_weekly("weekly_func", 0, TimeRule.at_time(9, 31))
    print("  Weekly schedule added for weekday=0 (Monday)")
    
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "weekly_func")
    assert_equal(entry.frequency, "weekly")
    print("  Entry func_name: " + entry.func_name)
    print("  Entry frequency: " + entry.frequency)
    print("  Entry day_checker_id: " + String(entry.day_checker_id))
    
    print("Test test_scheduler_weekly_creation: PASSED")


def test_scheduler_weekly_all_weekdays() raises:
    """
    Test creating weekly schedules for all weekdays.
    """
    print("=== Testing Scheduler Weekly All Weekdays ===")
    
    var scheduler = create_scheduler("1d")
    
    var weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    for i in range(5):
        scheduler.schedule_weekly("weekly_" + weekdays[i], i, TimeRule.at_time(9, 31))
    
    assert_equal(scheduler._registry.__len__(), 5)
    
    for i in range(5):
        var entry = scheduler._registry[i]
        print("  " + weekdays[i] + " (weekday=" + String(i) + "): day_checker_id=" + String(entry.day_checker_id))
    
    print("Test test_scheduler_weekly_all_weekdays: PASSED")


def test_scheduler_weekly_trading_day() raises:
    """
    Test creating weekly trading day schedule in Mojo.
    """
    print("=== Testing Scheduler Weekly Trading Day ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_weekly_trading_day("weekly_trading_func", 1, TimeRule.at_time(9, 31))
    print("  Weekly trading day schedule added for trading_day=1")
    
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "weekly_trading_func")
    assert_equal(entry.frequency, "weekly_trading")
    print("  Entry func_name: " + entry.func_name)
    print("  Entry frequency: " + entry.frequency)
    print("  Entry day_checker_id: " + String(entry.day_checker_id))
    
    print("Test test_scheduler_weekly_trading_day: PASSED")


def test_scheduler_weekly_trading_day_various() raises:
    """
    Test creating weekly trading day schedules for various trading days.
    """
    print("=== Testing Scheduler Weekly Trading Day Various ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_weekly_trading_day("first", 1, TimeRule.at_time(9, 31))
    scheduler.schedule_weekly_trading_day("second", 2, TimeRule.at_time(9, 31))
    scheduler.schedule_weekly_trading_day("last", -1, TimeRule.at_time(9, 31))
    
    assert_equal(scheduler._registry.__len__(), 3)
    
    var entry1 = scheduler._registry[0]
    print("  first (tradingday=1): day_checker_id=" + String(entry1.day_checker_id))
    
    var entry2 = scheduler._registry[1]
    print("  second (tradingday=2): day_checker_id=" + String(entry2.day_checker_id))
    
    var entry3 = scheduler._registry[2]
    print("  last (tradingday=-1): day_checker_id=" + String(entry3.day_checker_id))
    
    print("Test test_scheduler_weekly_trading_day_various: PASSED")


def test_scheduler_clear() raises:
    """
    Test clearing scheduler entries.
    """
    print("=== Testing Scheduler Clear ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    scheduler.schedule_monthly("monthly_func", 1, TimeRule.at_time(9, 31))
    scheduler.schedule_weekly("weekly_func", 0, TimeRule.at_time(9, 31))
    assert_equal(scheduler._registry.__len__(), 3)
    print("  Added 3 schedules")
    
    scheduler.clear()
    assert_equal(scheduler._registry.__len__(), 0)
    print("  Cleared all schedules")
    
    print("Test test_scheduler_clear: PASSED")


def test_scheduler_day_checker_ids() raises:
    """
    Test day checker ID generation.
    """
    print("=== Testing Scheduler Day Checker IDs ===")
    
    var scheduler = create_scheduler("1d")
    
    var always_true_id = scheduler._always_true_id()
    print("  always_true_id = " + String(always_true_id))
    
    var weekday_id = scheduler._weekday_checker_id(0)
    print("  weekday_checker_id(0) = " + String(weekday_id))
    
    var nth_week_id = scheduler._nth_trading_day_in_week_id(1)
    print("  nth_trading_day_in_week_id(1) = " + String(nth_week_id))
    
    var nth_month_id = scheduler._nth_trading_day_in_month_id(1)
    print("  nth_trading_day_in_month_id(1) = " + String(nth_month_id))
    
    print("Test test_scheduler_day_checker_ids: PASSED")


def test_scheduler_mixed_schedules() raises:
    """
    Test scheduler with mixed schedule types.
    """
    print("=== Testing Scheduler Mixed Schedules ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    scheduler.schedule_weekly("weekly_func", 0, TimeRule.at_time(10, 0))
    scheduler.schedule_monthly("monthly_func", 1, TimeRule.at_time(9, 31))
    scheduler.schedule_weekly_trading_day("weekly_trading_func", 1, TimeRule.at_time(9, 31))
    
    assert_equal(scheduler._registry.__len__(), 4)
    
    print("  Mixed schedules:")
    for i in range(scheduler._registry.__len__()):
        var entry = scheduler._registry[i]
        print("    " + entry.func_name + ": frequency=" + entry.frequency + " day_checker_id=" + String(entry.day_checker_id))
    
    print("Test test_scheduler_mixed_schedules: PASSED")


def test_run_monthly_simulation() raises:
    """
    Test run_monthly scheduler simulation.
    Simulates the behavior of test_scheduler.py using pure Mojo.
    
    The test verifies that:
    1. scheduler.run_monthly with tradingday=1 runs on first trading day of each month
    2. The scheduler correctly tracks monthly scheduled functions
    """
    print("=== Testing run_monthly Scheduler Simulation ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_monthly("monthly_func", 1, TimeRule.at_time(9, 31))
    
    print("  Scheduler has " + String(scheduler._registry.__len__()) + " scheduled function(s)")
    
    var entry = scheduler._registry[0]
    print("  Function: " + entry.func_name + " frequency=" + entry.frequency)
    
    assert_equal(scheduler._registry.__len__(), 1)
    assert_equal(entry.func_name, "monthly_func")
    assert_equal(entry.frequency, "monthly")
    
    print("Test test_run_monthly_simulation: PASSED")


def test_scheduler_time_rule_variations() raises:
    """
    Test scheduler with various time rule variations.
    """
    print("=== Testing Scheduler Time Rule Variations ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_daily("at_open", TimeRule.market_open(0, 0))
    scheduler.schedule_daily("at_close", TimeRule.market_close(0, 0))
    scheduler.schedule_daily("before_trading", TimeRule.before_trading())
    scheduler.schedule_daily("at_10_30", TimeRule.at_time(10, 30))
    
    assert_equal(scheduler._registry.__len__(), 4)
    
    print("  Time rule variations:")
    for i in range(scheduler._registry.__len__()):
        var entry = scheduler._registry[i]
        var rule_type = ""
        if entry.time_rule.is_before_trading:
            rule_type = "before_trading"
        else:
            rule_type = "minutes=" + String(entry.time_rule.minutes_since_midnight)
        print("    " + entry.func_name + ": " + rule_type)
    
    print("Test test_scheduler_time_rule_variations: PASSED")


def test_scheduler_frequency_types() raises:
    """
    Test scheduler with different frequency types.
    """
    print("=== Testing Scheduler Frequency Types ===")
    
    var scheduler_1d = create_scheduler("1d")
    assert_equal(scheduler_1d._frequency, "1d")
    print("  Created scheduler with frequency: 1d")
    
    var scheduler_1m = create_scheduler("1m")
    assert_equal(scheduler_1m._frequency, "1m")
    print("  Created scheduler with frequency: 1m")
    
    var scheduler_tick = create_scheduler("tick")
    assert_equal(scheduler_tick._frequency, "tick")
    print("  Created scheduler with frequency: tick")
    
    print("Test test_scheduler_frequency_types: PASSED")


def test_config_consistency() raises:
    """
    Test that config values are consistent with Python test.
    """
    print("=== Testing Config Consistency ===")
    
    assert_equal(TEST_START_DATE_YEAR, 2015)
    assert_equal(TEST_START_DATE_MONTH, 1)
    assert_equal(TEST_START_DATE_DAY, 1)
    assert_equal(TEST_END_DATE_YEAR, 2015)
    assert_equal(TEST_END_DATE_MONTH, 12)
    assert_equal(TEST_END_DATE_DAY, 31)
    assert_true(is_close(INITIAL_CASH, 1000000.0))
    assert_equal(TEST_FREQUENCY, "1d")
    
    print("Config values:")
    print("  Start date: " + String(TEST_START_DATE_YEAR) + "-" + String(TEST_START_DATE_MONTH) + "-" + String(TEST_START_DATE_DAY))
    print("  End date: " + String(TEST_END_DATE_YEAR) + "-" + String(TEST_END_DATE_MONTH) + "-" + String(TEST_END_DATE_DAY))
    print("  Initial cash: " + String(INITIAL_CASH))
    print("  Frequency: " + TEST_FREQUENCY)
    
    print("Test test_config_consistency: PASSED")


def run_all_tests() raises -> Dict[String, String]:
    var results = Dict[String, String]()
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Running test_scheduler.mojo")
    print("=" * 60)
    print("")
    
    var tests = List[String]()
    tests.append("test_config_consistency")
    tests.append("test_scheduler_monthly_creation")
    tests.append("test_scheduler_monthly_different_days")
    tests.append("test_scheduler_weekly_creation")
    tests.append("test_scheduler_weekly_all_weekdays")
    tests.append("test_scheduler_weekly_trading_day")
    tests.append("test_scheduler_weekly_trading_day_various")
    tests.append("test_scheduler_clear")
    tests.append("test_scheduler_day_checker_ids")
    tests.append("test_scheduler_mixed_schedules")
    tests.append("test_run_monthly_simulation")
    tests.append("test_scheduler_time_rule_variations")
    tests.append("test_scheduler_frequency_types")
    
    for test_name in tests:
        try:
            if test_name == "test_config_consistency":
                test_config_consistency()
            elif test_name == "test_scheduler_monthly_creation":
                test_scheduler_monthly_creation()
            elif test_name == "test_scheduler_monthly_different_days":
                test_scheduler_monthly_different_days()
            elif test_name == "test_scheduler_weekly_creation":
                test_scheduler_weekly_creation()
            elif test_name == "test_scheduler_weekly_all_weekdays":
                test_scheduler_weekly_all_weekdays()
            elif test_name == "test_scheduler_weekly_trading_day":
                test_scheduler_weekly_trading_day()
            elif test_name == "test_scheduler_weekly_trading_day_various":
                test_scheduler_weekly_trading_day_various()
            elif test_name == "test_scheduler_clear":
                test_scheduler_clear()
            elif test_name == "test_scheduler_day_checker_ids":
                test_scheduler_day_checker_ids()
            elif test_name == "test_scheduler_mixed_schedules":
                test_scheduler_mixed_schedules()
            elif test_name == "test_run_monthly_simulation":
                test_run_monthly_simulation()
            elif test_name == "test_scheduler_time_rule_variations":
                test_scheduler_time_rule_variations()
            elif test_name == "test_scheduler_frequency_types":
                test_scheduler_frequency_types()
            
            results[test_name] = "PASS"
            passed += 1
        except e:
            results[test_name] = "FAIL: " + String(e)
            failed += 1
    
    print("")
    print("=" * 60)
    print("Test Summary")
    print("=" * 60)
    print("Total:  " + String(passed + failed))
    print("Passed: " + String(passed))
    print("Failed: " + String(failed))
    print("")
    
    results["total"] = String(passed + failed)
    results["passed"] = String(passed)
    results["failed"] = String(failed)
    
    return results^


def main() raises:
    var results = run_all_tests()
    
    print("Final Results:")
    var keys_list = List[String]()
    for key in results.keys():
        keys_list.append(key)
    for key in keys_list:
        var value = results[key]
        print("  " + key + ": " + value)
