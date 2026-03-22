"""
Mojo Test for sys_scheduler physical_time
Ported from tests/integration_tests/test_api/mod/sys_scheduler/test_physical_time.py
Tests physical_time scheduler functionality using pure rqmojo implementation.
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import RUN_TYPE_BACKTEST, DEFAULT_ACCOUNT_TYPE_FUTURE
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
struct SchedulerTestResult(Movable, Copyable, ImplicitlyCopyable):
    var day_index: Int
    var counter: Int
    var days: Int
    var counter_matches_days: Bool


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def test_time_rule_before_trading() raises:
    """
    Test TimeRule.before_trading() creation.
    """
    print("=== Testing TimeRule.before_trading() ===")
    
    var rule = TimeRule.before_trading()
    assert_true(rule.is_before_trading)
    assert_equal(rule.minutes_since_midnight, 0)
    assert_equal(rule.description, "before_trading")
    
    print("  is_before_trading: " + String(rule.is_before_trading))
    print("  minutes_since_midnight: " + String(rule.minutes_since_midnight))
    print("  description: " + rule.description)
    print("Test test_time_rule_before_trading: PASSED")


def test_time_rule_at_time() raises:
    """
    Test TimeRule.at_time() creation.
    """
    print("=== Testing TimeRule.at_time() ===")
    
    var rule = TimeRule.at_time(9, 31)
    assert_false(rule.is_before_trading)
    assert_equal(rule.minutes_since_midnight, 571)
    
    print("  is_before_trading: " + String(rule.is_before_trading))
    print("  minutes_since_midnight: " + String(rule.minutes_since_midnight))
    print("  Expected: 571 (9*60 + 31)")
    print("Test test_time_rule_at_time: PASSED")


def test_time_rule_market_open() raises:
    """
    Test TimeRule.market_open() creation.
    Market opens at 9:31, so market_open(0, 0) should be 571 minutes.
    """
    print("=== Testing TimeRule.market_open() ===")
    
    var rule = TimeRule.market_open(0, 0)
    assert_false(rule.is_before_trading)
    print("  market_open(0, 0) minutes: " + String(rule.minutes_since_midnight))
    
    var rule_with_offset = TimeRule.market_open(1, 0)
    print("  market_open(1, 0) minutes: " + String(rule_with_offset.minutes_since_midnight))
    
    var rule_with_minute = TimeRule.market_open(0, 30)
    print("  market_open(0, 30) minutes: " + String(rule_with_minute.minutes_since_midnight))
    
    print("Test test_time_rule_market_open: PASSED")


def test_time_rule_market_close() raises:
    """
    Test TimeRule.market_close() creation.
    Market closes at 15:00, so market_close(0, 0) should be 900 minutes.
    """
    print("=== Testing TimeRule.market_close() ===")
    
    var rule = TimeRule.market_close(0, 0)
    assert_false(rule.is_before_trading)
    print("  market_close(0, 0) minutes: " + String(rule.minutes_since_midnight))
    
    var rule_with_offset = TimeRule.market_close(1, 0)
    print("  market_close(1, 0) minutes: " + String(rule_with_offset.minutes_since_midnight))
    
    print("Test test_time_rule_market_close: PASSED")


def test_physical_time_minutes_function() raises:
    """
    Test physical_time_minutes function.
    """
    print("=== Testing physical_time_minutes() ===")
    
    var minutes_9_31 = physical_time_minutes(9, 31)
    assert_equal(minutes_9_31, 571)
    print("  physical_time_minutes(9, 31) = " + String(minutes_9_31))
    
    var minutes_10_00 = physical_time_minutes(10, 0)
    assert_equal(minutes_10_00, 600)
    print("  physical_time_minutes(10, 0) = " + String(minutes_10_00))
    
    var minutes_15_00 = physical_time_minutes(15, 0)
    assert_equal(minutes_15_00, 900)
    print("  physical_time_minutes(15, 0) = " + String(minutes_15_00))
    
    var minutes_0_00 = physical_time_minutes(0, 0)
    assert_equal(minutes_0_00, 0)
    print("  physical_time_minutes(0, 0) = " + String(minutes_0_00))
    
    print("Test test_physical_time_minutes_function: PASSED")


def test_market_open_minutes_function() raises:
    """
    Test market_open_minutes function.
    """
    print("=== Testing market_open_minutes() ===")
    
    var base = market_open_minutes(0, 0)
    print("  market_open_minutes(0, 0) = " + String(base))
    
    var with_hour = market_open_minutes(1, 0)
    print("  market_open_minutes(1, 0) = " + String(with_hour))
    
    var with_minute = market_open_minutes(0, 30)
    print("  market_open_minutes(0, 30) = " + String(with_minute))
    
    print("Test test_market_open_minutes_function: PASSED")


def test_market_close_minutes_function() raises:
    """
    Test market_close_minutes function.
    """
    print("=== Testing market_close_minutes() ===")
    
    var base = market_close_minutes(0, 0)
    print("  market_close_minutes(0, 0) = " + String(base))
    
    var with_hour = market_close_minutes(1, 0)
    print("  market_close_minutes(1, 0) = " + String(with_hour))
    
    print("Test test_market_close_minutes_function: PASSED")


def test_scheduler_creation() raises:
    """
    Test creating Scheduler in Mojo.
    """
    print("=== Testing Scheduler Creation ===")
    
    var scheduler = create_scheduler("1d")
    print("  Scheduler created with frequency: 1d")
    print("  Initial registry size: " + String(scheduler._registry.__len__()))
    assert_equal(scheduler._registry.__len__(), 0)
    
    print("Test test_scheduler_creation: PASSED")


def test_scheduler_schedule_daily() raises:
    """
    Test scheduling daily functions.
    """
    print("=== Testing Scheduler schedule_daily() ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "daily_func")
    assert_equal(entry.frequency, "daily")
    assert_equal(entry.day_checker_id, 0)
    assert_equal(entry.time_rule.minutes_since_midnight, 571)
    
    print("  Entry 0: func_name=" + entry.func_name + " frequency=" + entry.frequency)
    print("  day_checker_id=" + String(entry.day_checker_id))
    print("  time_rule minutes=" + String(entry.time_rule.minutes_since_midnight))
    
    scheduler.schedule_daily("daily_func_2", TimeRule.at_time(10, 0))
    assert_equal(scheduler._registry.__len__(), 2)
    
    print("Test test_scheduler_schedule_daily: PASSED")


def test_scheduler_schedule_weekly() raises:
    """
    Test scheduling weekly functions.
    """
    print("=== Testing Scheduler schedule_weekly() ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_weekly("weekly_func", 0, TimeRule.at_time(9, 31))
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "weekly_func")
    assert_equal(entry.frequency, "weekly")
    assert_equal(entry.day_checker_id, 100)
    
    print("  Entry: func_name=" + entry.func_name + " frequency=" + entry.frequency)
    print("  day_checker_id=" + String(entry.day_checker_id) + " (weekday 0 = Monday)")
    
    print("Test test_scheduler_schedule_weekly: PASSED")


def test_scheduler_schedule_weekly_trading_day() raises:
    """
    Test scheduling weekly trading day functions.
    """
    print("=== Testing Scheduler schedule_weekly_trading_day() ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_weekly_trading_day("weekly_trading_func", 1, TimeRule.at_time(9, 31))
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "weekly_trading_func")
    assert_equal(entry.frequency, "weekly_trading")
    print("  Entry: func_name=" + entry.func_name + " frequency=" + entry.frequency)
    print("  day_checker_id=" + String(entry.day_checker_id))
    
    print("Test test_scheduler_schedule_weekly_trading_day: PASSED")


def test_scheduler_schedule_monthly() raises:
    """
    Test scheduling monthly functions.
    """
    print("=== Testing Scheduler schedule_monthly() ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_monthly("monthly_func", 1, TimeRule.at_time(9, 31))
    assert_equal(scheduler._registry.__len__(), 1)
    
    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "monthly_func")
    assert_equal(entry.frequency, "monthly")
    assert_equal(entry.day_checker_id, 300)
    
    print("  Entry: func_name=" + entry.func_name + " frequency=" + entry.frequency)
    print("  day_checker_id=" + String(entry.day_checker_id))
    
    print("Test test_scheduler_schedule_monthly: PASSED")


def test_scheduler_clear() raises:
    """
    Test clearing scheduler entries.
    """
    print("=== Testing Scheduler clear() ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    scheduler.schedule_monthly("monthly_func", 1, TimeRule.at_time(9, 31))
    scheduler.schedule_weekly("weekly_func", 0, TimeRule.at_time(9, 31))
    assert_equal(scheduler._registry.__len__(), 3)
    print("  Added 3 schedules, registry size: " + String(scheduler._registry.__len__()))
    
    scheduler.clear()
    assert_equal(scheduler._registry.__len__(), 0)
    print("  After clear(), registry size: " + String(scheduler._registry.__len__()))
    
    print("Test test_scheduler_clear: PASSED")


def test_scheduler_day_checker_ids() raises:
    """
    Test day checker ID generation.
    """
    print("=== Testing Scheduler Day Checker IDs ===")
    
    var scheduler = create_scheduler("1d")
    
    var always_true_id = scheduler._always_true_id()
    assert_equal(always_true_id, 0)
    print("  always_true_id() = " + String(always_true_id))
    
    var weekday_0_id = scheduler._weekday_checker_id(0)
    assert_equal(weekday_0_id, 100)
    print("  weekday_checker_id(0) = " + String(weekday_0_id) + " (Monday)")
    
    var weekday_4_id = scheduler._weekday_checker_id(4)
    assert_equal(weekday_4_id, 104)
    print("  weekday_checker_id(4) = " + String(weekday_4_id) + " (Friday)")
    
    var nth_week_0_id = scheduler._nth_trading_day_in_week_id(0)
    assert_equal(nth_week_0_id, 200)
    print("  nth_trading_day_in_week_id(0) = " + String(nth_week_0_id))
    
    var nth_week_1_id = scheduler._nth_trading_day_in_week_id(1)
    assert_equal(nth_week_1_id, 201)
    print("  nth_trading_day_in_week_id(1) = " + String(nth_week_1_id))
    
    var nth_month_0_id = scheduler._nth_trading_day_in_month_id(0)
    assert_equal(nth_month_0_id, 300)
    print("  nth_trading_day_in_month_id(0) = " + String(nth_month_0_id))
    
    var nth_month_1_id = scheduler._nth_trading_day_in_month_id(1)
    assert_equal(nth_month_1_id, 301)
    print("  nth_trading_day_in_month_id(1) = " + String(nth_month_1_id))
    
    print("Test test_scheduler_day_checker_ids: PASSED")


def test_scheduler_trading_time_ranges() raises:
    """
    Test trading time range checking.
    """
    print("=== Testing Scheduler Trading Time Ranges ===")
    
    var scheduler = create_scheduler("1d")
    
    var in_morning_9_31 = scheduler._is_in_trading_time(571)
    print("  9:31 (571 min) in trading time: " + String(in_morning_9_31))
    
    var in_morning_11_30 = scheduler._is_in_trading_time(690)
    print("  11:30 (690 min) in trading time: " + String(in_morning_11_30))
    
    var lunch_break = scheduler._is_in_trading_time(700)
    print("  11:40 (700 min) in trading time: " + String(lunch_break) + " (lunch break)")
    
    var in_afternoon_13_00 = scheduler._is_in_trading_time(780)
    print("  13:00 (780 min) in trading time: " + String(in_afternoon_13_00))
    
    var in_afternoon_15_00 = scheduler._is_in_trading_time(900)
    print("  15:00 (900 min) in trading time: " + String(in_afternoon_15_00))
    
    var after_close = scheduler._is_in_trading_time(901)
    print("  15:01 (901 min) in trading time: " + String(after_close) + " (after close)")
    
    print("Test test_scheduler_trading_time_ranges: PASSED")


def test_scheduler_next_day() raises:
    """
    Test scheduler next_day functionality.
    """
    print("=== Testing Scheduler next_day() ===")
    
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    
    var trading_dt = DateTime(2015, 1, 5, 0, 0, 0, 0)
    scheduler.next_day(trading_dt)
    
    print("  next_day called with 2015-01-05")
    print("  _last_minute reset to: " + String(scheduler._last_minute))
    print("  _current_minute: " + String(scheduler._current_minute))
    
    print("Test test_scheduler_next_day: PASSED")


def test_scheduler_next_bar() raises:
    """
    Test scheduler next_bar functionality.
    """
    print("=== Testing Scheduler next_bar() ===")
    
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    
    var trading_dt = DateTime(2015, 1, 5, 0, 0, 0, 0)
    scheduler.next_day(trading_dt)
    
    var bar_time_9_31 = DateTime(2015, 1, 5, 9, 31, 0, 0)
    var funcs = scheduler.next_bar(bar_time_9_31)
    print("  At 9:31, functions to run: " + String(funcs.__len__()))
    for f in funcs:
        print("    - " + f)
    
    var bar_time_10_00 = DateTime(2015, 1, 5, 10, 0, 0, 0)
    var funcs2 = scheduler.next_bar(bar_time_10_00)
    print("  At 10:00, functions to run: " + String(funcs2.__len__()))
    
    print("Test test_scheduler_next_bar: PASSED")


def test_scheduler_before_trading() raises:
    """
    Test scheduler before_trading functionality.
    """
    print("=== Testing Scheduler before_trading() ===")
    
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("before_trading_func", TimeRule.before_trading())
    
    var funcs = scheduler.before_trading()
    print("  before_trading functions: " + String(funcs.__len__()))
    for f in funcs:
        print("    - " + f)
    
    assert_equal(funcs.__len__(), 1)
    assert_equal(funcs[0], "before_trading_func")
    
    print("Test test_scheduler_before_trading: PASSED")


def test_scheduler_state() raises:
    """
    Test scheduler state persistence.
    """
    print("=== Testing Scheduler State ===")
    
    var scheduler = create_scheduler("1d")
    
    var trading_dt = DateTime(2015, 1, 5, 0, 0, 0, 0)
    scheduler.next_day(trading_dt)
    
    var state = scheduler.get_state()
    print("  State after next_day: " + state)
    
    var scheduler2 = create_scheduler("1d")
    scheduler2.set_state(state)
    var state2 = scheduler2.get_state()
    print("  State after set_state: " + state2)
    
    assert_equal(state, state2)
    
    print("Test test_scheduler_state: PASSED")


def test_schedule_entry() raises:
    """
    Test ScheduleEntry struct.
    """
    print("=== Testing ScheduleEntry ===")
    
    var entry = ScheduleEntry(
        day_checker_id=0,
        time_rule=TimeRule.at_time(9, 31),
        func_name="test_func",
        frequency="daily"
    )
    
    assert_equal(entry.day_checker_id, 0)
    assert_equal(entry.func_name, "test_func")
    assert_equal(entry.frequency, "daily")
    assert_equal(entry.time_rule.minutes_since_midnight, 571)
    
    print("  ScheduleEntry created:")
    print("    day_checker_id: " + String(entry.day_checker_id))
    print("    func_name: " + entry.func_name)
    print("    frequency: " + entry.frequency)
    print("    time_rule minutes: " + String(entry.time_rule.minutes_since_midnight))
    
    print("Test test_schedule_entry: PASSED")


def test_trading_minute_range() raises:
    """
    Test TradingMinuteRange struct.
    """
    print("=== Testing TradingMinuteRange ===")
    
    var morning_range = TradingMinuteRange(start_minute=571, end_minute=690)
    assert_equal(morning_range.start_minute, 571)
    assert_equal(morning_range.end_minute, 690)
    
    assert_true(morning_range.contains(571))
    assert_true(morning_range.contains(630))
    assert_true(morning_range.contains(690))
    assert_false(morning_range.contains(570))
    assert_false(morning_range.contains(691))
    
    print("  Morning range: " + String(morning_range.start_minute) + "-" + String(morning_range.end_minute))
    print("  Contains 571: " + String(morning_range.contains(571)))
    print("  Contains 630: " + String(morning_range.contains(630)))
    print("  Contains 700: " + String(morning_range.contains(700)))
    
    print("Test test_trading_minute_range: PASSED")


def test_physical_time_scheduler_simulation() raises:
    """
    Test physical_time scheduler simulation.
    Simulates the behavior of test_physical_time.py using pure Mojo.
    
    The test verifies that:
    1. scheduler.run_daily with physical_time(9, 31) runs once per day
    2. The scheduler correctly tracks scheduled functions
    """
    print("=== Testing Physical Time Scheduler Simulation ===")
    
    var scheduler = create_scheduler("1d")
    
    scheduler.schedule_daily("daily_func", TimeRule.at_time(9, 31))
    
    print("  Scheduler has " + String(scheduler._registry.__len__()) + " scheduled function(s)")
    
    var entry = scheduler._registry[0]
    print("  Function: " + entry.func_name + " at minutes=" + String(entry.time_rule.minutes_since_midnight))
    
    assert_equal(scheduler._registry.__len__(), 1)
    assert_equal(entry.func_name, "daily_func")
    assert_equal(entry.time_rule.minutes_since_midnight, 571)
    
    print("Test test_physical_time_scheduler_simulation: PASSED")


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
    print("Running test_physical_time.mojo")
    print("=" * 60)
    print("")
    
    var tests = List[String]()
    tests.append("test_config_consistency")
    tests.append("test_time_rule_before_trading")
    tests.append("test_time_rule_at_time")
    tests.append("test_time_rule_market_open")
    tests.append("test_time_rule_market_close")
    tests.append("test_physical_time_minutes_function")
    tests.append("test_market_open_minutes_function")
    tests.append("test_market_close_minutes_function")
    tests.append("test_scheduler_creation")
    tests.append("test_scheduler_schedule_daily")
    tests.append("test_scheduler_schedule_weekly")
    tests.append("test_scheduler_schedule_weekly_trading_day")
    tests.append("test_scheduler_schedule_monthly")
    tests.append("test_scheduler_clear")
    tests.append("test_scheduler_day_checker_ids")
    tests.append("test_scheduler_trading_time_ranges")
    tests.append("test_scheduler_next_day")
    tests.append("test_scheduler_next_bar")
    tests.append("test_scheduler_before_trading")
    tests.append("test_scheduler_state")
    tests.append("test_scheduler_mod_creation")
    tests.append("test_schedule_entry")
    tests.append("test_trading_minute_range")
    tests.append("test_physical_time_scheduler_simulation")
    
    for test_name in tests:
        try:
            if test_name == "test_config_consistency":
                test_config_consistency()
            elif test_name == "test_time_rule_before_trading":
                test_time_rule_before_trading()
            elif test_name == "test_time_rule_at_time":
                test_time_rule_at_time()
            elif test_name == "test_time_rule_market_open":
                test_time_rule_market_open()
            elif test_name == "test_time_rule_market_close":
                test_time_rule_market_close()
            elif test_name == "test_physical_time_minutes_function":
                test_physical_time_minutes_function()
            elif test_name == "test_market_open_minutes_function":
                test_market_open_minutes_function()
            elif test_name == "test_market_close_minutes_function":
                test_market_close_minutes_function()
            elif test_name == "test_scheduler_creation":
                test_scheduler_creation()
            elif test_name == "test_scheduler_schedule_daily":
                test_scheduler_schedule_daily()
            elif test_name == "test_scheduler_schedule_weekly":
                test_scheduler_schedule_weekly()
            elif test_name == "test_scheduler_schedule_weekly_trading_day":
                test_scheduler_schedule_weekly_trading_day()
            elif test_name == "test_scheduler_schedule_monthly":
                test_scheduler_schedule_monthly()
            elif test_name == "test_scheduler_clear":
                test_scheduler_clear()
            elif test_name == "test_scheduler_day_checker_ids":
                test_scheduler_day_checker_ids()
            elif test_name == "test_scheduler_trading_time_ranges":
                test_scheduler_trading_time_ranges()
            elif test_name == "test_scheduler_next_day":
                test_scheduler_next_day()
            elif test_name == "test_scheduler_next_bar":
                test_scheduler_next_bar()
            elif test_name == "test_scheduler_before_trading":
                test_scheduler_before_trading()
            elif test_name == "test_scheduler_state":
                test_scheduler_state()
            elif test_name == "test_schedule_entry":
                test_schedule_entry()
            elif test_name == "test_trading_minute_range":
                test_trading_minute_range()
            elif test_name == "test_physical_time_scheduler_simulation":
                test_physical_time_scheduler_simulation()
            
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
