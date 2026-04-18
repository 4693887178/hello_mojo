"""
Comprehensive Unit Tests for rqmojo_mod_sys_scheduler
Tests all core scheduler functionality against Python original behavior.
Uses Mojo standard testing framework (std.testing.TestSuite).
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List, Optional
from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import (
    Scheduler, TimeRule, ScheduleEntry, TradingMinuteRange,
    create_scheduler,
    market_open_minutes, market_close_minutes, physical_time_minutes
)
from rqmojo.mod.rqmojo_mod_sys_scheduler.mod import (
    SchedulerMod, create_scheduler_mod
)
from rqmojo.const import EXIT_CODE
from rqmojo.utils.typing import DateTime


# ============================================================
# TimeRule Tests
# ============================================================

def test_time_rule_before_trading() raises:
    var rule = TimeRule.before_trading()
    assert_true(rule.is_before_trading, "before_trading should have is_before_trading=True")
    assert_equal(rule.minutes_since_midnight, 0, "before_trading minutes should be 0")
    assert_equal(rule.description, "before_trading", "description should match")


def test_time_rule_at_time() raises:
    var rule = TimeRule.at_time(10, 30)
    assert_false(rule.is_before_trading, "at_time should not be before_trading")
    assert_equal(rule.minutes_since_midnight, 630, "10:30 = 630 minutes")
    assert_equal(rule.description, "at_time", "description should match")

    var rule2 = TimeRule.at_time(9, 0)
    assert_equal(rule2.minutes_since_midnight, 540, "9:00 = 540 minutes")

    var rule3 = TimeRule.at_time(15, 0)
    assert_equal(rule3.minutes_since_midnight, 900, "15:00 = 900 minutes")


def test_time_rule_market_open_default() raises:
    var rule = TimeRule.market_open()
    assert_equal(rule.minutes_since_midnight, 571, "market_open default = 9:31 = 571 min")
    assert_false(rule.is_before_trading)


def test_time_rule_market_open_with_offset() raises:
    var rule = TimeRule.market_open(1, 0)
    assert_equal(rule.minutes_since_midnight, 631, "market_open(1h) = 10:31 = 631 min")

    var rule2 = TimeRule.market_open(0, 30)
    assert_equal(rule2.minutes_since_midnight, 601, "market_open(30m) = 10:01 = 601 min")


def test_time_rule_market_open_afternoon_session() raises:
    var rule = TimeRule.market_open(2, 0)
    assert_true(rule.minutes_since_midnight > 11 * 60 + 30, "should cross into afternoon session")
    assert_equal(rule.minutes_since_midnight, 781, "market_open(2h) = 13:31 = 781 min (with +90 lunch)")


def test_time_rule_market_close_default() raises:
    var rule = TimeRule.market_close()
    assert_equal(rule.minutes_since_midnight, 900, "market_close default = 15:00 = 900 min")
    assert_false(rule.is_before_trading)


def test_time_rule_market_close_with_offset() raises:
    var rule = TimeRule.market_close(0, 30)
    assert_equal(rule.minutes_since_midnight, 870, "market_close(30m) = 14:30 = 870 min")


def test_time_rule_market_close_morning_session() raises:
    var rule = TimeRule.market_close(2, 0)
    assert_true(rule.minutes_since_midnight >= 13 * 60, "market_close(2h) = 780 which is NOT < 780, so no lunch adjustment")
    assert_equal(rule.minutes_since_midnight, 780, "market_close(2h) = 13:00 = 780 min (with -90 lunch)")


def test_time_rule_equatable() raises:
    var r1 = TimeRule.before_trading()
    var r2 = TimeRule.before_trading()
    assert_equal(r1, r2, "identical before_trading rules should be equal")

    var r3 = TimeRule.at_time(10, 0)
    var r4 = TimeRule.at_time(10, 0)
    assert_equal(r3, r4, "identical at_time rules should be equal")

    var r5 = TimeRule.at_time(10, 30)
    assert_true(r3 != r5, "different time rules should not be equal")


def test_time_rule_writable() raises:
    var rule = TimeRule.before_trading()
    var s = String(rule)
    assert_true(s.find("TimeRule") >= 0, "string representation should contain TimeRule")
    assert_true(s.find("before_trading") >= 0, "should indicate before_trading")

    var rule2 = TimeRule.at_time(10, 30)
    var s2 = String(rule2)
    assert_true(s2.find("630") >= 0, "should contain minute count")


# ============================================================
# TradingMinuteRange Tests
# ============================================================

def test_trading_minute_range_contains() raises:
    var range_ = TradingMinuteRange(571, 690)
    assert_true(range_.contains(571), "should contain start boundary")
    assert_true(range_.contains(690), "should contain end boundary")
    assert_true(range_.contains(600), "should contain middle value")
    assert_false(range_.contains(570), "should not contain below start")
    assert_false(range_.contains(691), "should not contain above end")


def test_trading_minute_range_afternoon() raises:
    var range_ = TradingMinuteRange(780, 900)
    assert_true(range_.contains(780), "afternoon session start")
    assert_true(range_.contains(900), "afternoon session end")
    assert_false(range_.contains(779), "before afternoon start")
    assert_false(range_.contains(901), "after afternoon end")


def test_trading_minute_range_writable() raises:
    var range_ = TradingMinuteRange(571, 690)
    var s = String(range_)
    assert_true(s.find("571") >= 0, "should show start minute")
    assert_true(s.find("690") >= 0, "should show end minute")


# ============================================================
# ScheduleEntry Tests
# ============================================================

def test_schedule_entry_fields() raises:
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


def test_schedule_entry_writable() raises:
    var entry = ScheduleEntry(
        day_checker_id=100,
        time_rule=TimeRule.before_trading(),
        func_name="my_handler",
        frequency="weekly"
    )
    var s = String(entry)
    assert_true(s.find("ScheduleEntry") >= 0)
    assert_true(s.find("my_handler") >= 0)


# ============================================================
# Free Function Tests (market_open/close/physical_time)
# ============================================================

def test_market_open_minutes_default() raises:
    assert_equal(market_open_minutes(), 571, "default market_open = 571 (9:31)")
    assert_equal(market_open_minutes(0, 0), 571)


def test_market_open_minutes_with_offset() raises:
    assert_equal(market_open_minutes(1, 0), 631, "+1h = 631")
    assert_equal(market_open_minutes(0, 30), 601, "+30m = 601")


def test_market_close_minutes_default() raises:
    assert_equal(market_close_minutes(), 900, "default market_close = 900 (15:00)")
    assert_equal(market_close_minutes(0, 0), 900)


def test_market_close_minutes_with_offset() raises:
    assert_equal(market_close_minutes(0, 30), 870, "-30m = 870")
    assert_equal(market_close_minutes(1, 0), 840, "-1h = 840")


def test_physical_time_minutes() raises:
    assert_equal(physical_time_minutes(), 0, "default = 0")
    assert_equal(physical_time_minutes(1, 0), 60, "1h = 60min")
    assert_equal(physical_time_minutes(2, 30), 150, "2h30m = 150min")
    assert_equal(physical_time_minutes(23, 59), 1439, "23:59 = 1439min")


# ============================================================
# Scheduler Init & Basic Tests
# ============================================================

def test_scheduler_init_default_ranges() raises:
    var scheduler = create_scheduler("1d")
    assert_equal(len(scheduler._trading_minute_ranges), 2, "should have 2 default ranges")
    assert_equal(scheduler._trading_minute_ranges[0].start_minute, 571, "first range starts at 571")
    assert_equal(scheduler._trading_minute_ranges[0].end_minute, 690, "first range ends at 690")
    assert_equal(scheduler._trading_minute_ranges[1].start_minute, 780, "second range starts at 780")
    assert_equal(scheduler._trading_minute_ranges[1].end_minute, 900, "second range ends at 900")
    assert_equal(scheduler._start_minute, 571, "_start_minute should be 571")
    assert_equal(scheduler._frequency, "1d", "frequency should match")


def test_scheduler_init_empty_registry() raises:
    var scheduler = create_scheduler("1d")
    assert_equal(len(scheduler._registry), 0, "registry should be empty initially")
    assert_false(scheduler._today != None, "_today should be None initially")
    assert_equal(scheduler._last_minute, 0)
    assert_equal(scheduler._current_minute, 0)
    assert_equal(scheduler._stage, "", "_stage should be empty string")


def test_scheduler_init_constructor() raises:
    var scheduler = Scheduler(frequency="1m")
    assert_equal(scheduler._frequency, "1m", "constructor frequency should match")
    assert_equal(len(scheduler._trading_minute_ranges), 2, "constructor should also set default ranges")


def test_scheduler_writable() raises:
    var scheduler = create_scheduler("1d")
    var s = String(scheduler)
    assert_true(s.find("Scheduler") >= 0, "should contain Scheduler")
    assert_true(s.find("entries=") >= 0, "should show entries count")


# ============================================================
# Scheduler schedule_* Tests
# ============================================================

def test_schedule_daily() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("func_a", TimeRule.at_time(10, 0))
    assert_equal(len(scheduler._registry), 1)

    var entry = scheduler._registry[0]
    assert_equal(entry.func_name, "func_a")
    assert_equal(entry.day_checker_id, 0, "daily uses always_true checker id=0")
    assert_equal(entry.frequency, "daily")
    assert_equal(entry.time_rule.minutes_since_midnight, 600)


def test_schedule_multiple_daily() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("func_a", TimeRule.at_time(9, 31))
    scheduler.schedule_daily("func_b", TimeRule.at_time(14, 0))
    scheduler.schedule_daily("func_c", TimeRule.before_trading())
    assert_equal(len(scheduler._registry), 3)

    assert_equal(scheduler._registry[0].func_name, "func_a")
    assert_equal(scheduler._registry[1].func_name, "func_b")
    assert_equal(scheduler._registry[2].func_name, "func_c")
    assert_true(scheduler._registry[2].time_rule.is_before_trading)


def test_schedule_weekly() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_weekly("monday_func", 0, TimeRule.at_time(10, 0))
    assert_equal(len(scheduler._registry), 1)

    var entry = scheduler._registry[0]
    assert_equal(entry.day_checker_id, 100, "weekday 0 -> checker_id 100")
    assert_equal(entry.frequency, "weekly")


def test_schedule_weekly_all_days() raises:
    var scheduler = create_scheduler("1d")
    for i in range(7):
        scheduler.schedule_weekly("day_" + String(i), i, TimeRule.at_time(9, 31))

    assert_equal(len(scheduler._registry), 7)
    assert_equal(scheduler._registry[0].day_checker_id, 100, "Monday(0)=100")
    assert_equal(scheduler._registry[1].day_checker_id, 101, "Tuesday(1)=101")
    assert_equal(scheduler._registry[6].day_checker_id, 106, "Sunday(6)=106")


def test_schedule_weekly_trading_day_positive() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_weekly_trading_day("first_td", 1, TimeRule.at_time(10, 0))
    var entry = scheduler._registry[0]
    assert_equal(entry.day_checker_id, 200, "trading_day 1 -> 0 -> checker_id 200")
    assert_equal(entry.frequency, "weekly_trading")


def test_schedule_weekly_trading_day_negative() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_weekly_trading_day("last_td", -1, TimeRule.at_time(10, 0))
    var entry = scheduler._registry[0]
    assert_equal(entry.day_checker_id, 199, "trading_day -1 -> -1 -> checker_id 199")


def test_schedule_monthly() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_monthly("first_day_func", 1, TimeRule.at_time(9, 31))
    var entry = scheduler._registry[0]
    assert_equal(entry.day_checker_id, 300, "trading_day 1 -> 0 -> checker_id 300")
    assert_equal(entry.frequency, "monthly")


def test_schedule_monthly_negative() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_monthly("last_day_func", -1, TimeRule.at_time(9, 31))
    var entry = scheduler._registry[0]
    assert_equal(entry.day_checker_id, 299, "trading_day -1 -> -1 -> checker_id 299")


def test_clear() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("a", TimeRule.at_time(9, 31))
    scheduler.schedule_weekly("b", 0, TimeRule.at_time(10, 0))
    scheduler.schedule_monthly("c", 1, TimeRule.at_time(9, 31))
    assert_equal(len(scheduler._registry), 3)

    scheduler.clear()
    assert_equal(len(scheduler._registry), 0, "clear should empty registry")


# ============================================================
# Scheduler Day Checker ID Tests
# ============================================================

def test_always_true_id() raises:
    var scheduler = create_scheduler("1d")
    assert_equal(scheduler._always_true_id(), 0)


def test_weekday_checker_id() raises:
    var scheduler = create_scheduler("1d")
    assert_equal(scheduler._weekday_checker_id(0), 100, "Monday")
    assert_equal(scheduler._weekday_checker_id(1), 101, "Tuesday")
    assert_equal(scheduler._weekday_checker_id(4), 104, "Friday(4)=104")
    assert_equal(scheduler._weekday_checker_id(6), 106, "Sunday")


def test_nth_trading_day_in_week_id() raises:
    var scheduler = create_scheduler("1d")
    assert_equal(scheduler._nth_trading_day_in_week_id(0), 200, "index 0")
    assert_equal(scheduler._nth_trading_day_in_week_id(4), 204, "index 4")


def test_nth_trading_day_in_month_id() raises:
    var scheduler = create_scheduler("1d")
    assert_equal(scheduler._nth_trading_day_in_month_id(0), 300, "index 0")
    assert_equal(scheduler._nth_trading_day_in_month_id(20), 320, "index 20")


# ============================================================
# Scheduler _is_in_trading_time Tests
# ============================================================

def test_is_in_trading_time_morning() raises:
    var scheduler = create_scheduler("1d")
    assert_true(scheduler._is_in_trading_time(571), "9:31 in morning session")
    assert_true(scheduler._is_in_trading_time(600), "10:00 in morning session")
    assert_true(scheduler._is_in_trading_time(690), "11:30 end of morning")


def test_is_in_trading_time_afternoon() raises:
    var scheduler = create_scheduler("1d")
    assert_true(scheduler._is_in_trading_time(780), "13:00 start of afternoon")
    assert_true(scheduler._is_in_trading_time(840), "14:00 in afternoon")
    assert_true(scheduler._is_in_trading_time(900), "15:00 end of afternoon")


def test_is_in_trading_time_outside() raises:
    var scheduler = create_scheduler("1d")
    assert_false(scheduler._is_in_trading_time(0), "midnight")
    assert_false(scheduler._is_in_trading_time(400), "6:40 AM pre-market")
    assert_false(scheduler._is_in_trading_time(570), "9:30 just before open")
    assert_false(scheduler._is_in_trading_time(691), "11:31 lunch break")
    assert_false(scheduler._is_in_trading_time(779), "12:59 just before afternoon")
    assert_false(scheduler._is_in_trading_time(901), "15:01 after close")


def test_is_in_trading_time_custom_ranges() raises:
    var scheduler = create_scheduler("1d")
    var custom_ranges = List[TradingMinuteRange]()
    custom_ranges.append(TradingMinuteRange(480, 720))
    scheduler.set_trading_ranges(custom_ranges^)

    assert_true(scheduler._is_in_trading_time(500), "in custom range")
    assert_false(scheduler._is_in_trading_time(800), "outside custom range")


# ============================================================
# Scheduler _check_time_rule Tests
# ============================================================

def test_check_time_rule_before_trading_stage() raises:
    var scheduler = create_scheduler("1d")
    scheduler._stage = "before_trading"

    var bt_rule = TimeRule.before_trading()
    assert_true(scheduler._check_time_rule(bt_rule), "before_trading rule triggers in before_trading stage")

    var normal_rule = TimeRule.at_time(10, 0)
    assert_false(scheduler._check_time_rule(normal_rule), "normal rule does NOT trigger in before_trading stage")


def test_check_time_rule_normal_stage_1d() raises:
    var scheduler = create_scheduler("1d")
    scheduler._stage = ""
    scheduler._last_minute = 570
    scheduler._current_minute = 600

    var rule = TimeRule.at_time(10, 0)
    assert_true(scheduler._check_time_rule(rule), "1d frequency: any trading time triggers")


def test_check_time_rule_outside_trading_time() raises:
    var scheduler = create_scheduler("1d")
    scheduler._stage = ""
    scheduler._last_minute = 570
    scheduler._current_minute = 600

    var rule = TimeRule.at_time(6, 0)
    assert_false(scheduler._check_time_rule(rule), "non-trading time should not trigger")


def test_check_time_rule_1m_frequency() raises:
    var scheduler = create_scheduler("1m")
    scheduler._stage = ""
    scheduler._last_minute = 570
    scheduler._current_minute = 600

    var rule = TimeRule.at_time(10, 0)
    assert_true(scheduler._check_time_rule(rule), "1m: 570 < 600 <= 600, should trigger")

    var rule2 = TimeRule.at_time(9, 31)
    assert_true(scheduler._check_time_rule(rule2), "1m: 570 < 571 <= 600, SHOULD trigger (boundary: 571 > 570 AND 571 <= 600)")


def test_check_time_rule_1m_not_yet_reached() raises:
    var scheduler = create_scheduler("1m")
    scheduler._stage = ""
    scheduler._last_minute = 570
    scheduler._current_minute = 580

    var rule = TimeRule.at_time(10, 0)
    assert_false(scheduler._check_time_rule(rule), "1m: 570 < 600 is False when current=580")


# ============================================================
# Scheduler next_day / next_bar / before_trading Tests
# ============================================================

def test_next_day_sets_state() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("my_func", TimeRule.at_time(10, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    assert_true(scheduler._today != None, "_today should be set after next_day")
    assert_equal(scheduler._last_minute, 571, "_last_minute reset to _start_minute")
    assert_equal(scheduler._current_minute, 0, "_current_minute reset to 0")


def test_next_day_empty_registry_noop() raises:
    var scheduler = create_scheduler("1d")
    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)
    assert_false(scheduler._today != None, "_today should remain None for empty registry")


def test_next_bar_triggers_scheduled() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("func_10", TimeRule.at_time(10, 0))
    scheduler.schedule_daily("func_14", TimeRule.at_time(14, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var bar_time_10 = DateTime(2020, 1, 2, 10, 0, 0, 0)
    var result = scheduler.next_bar(bar_time_10)
    assert_equal(len(result), 2, "1d mode: ALL trading-time rules trigger on every bar during trading hours")


def test_next_bar_multiple_triggers() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("func_a", TimeRule.at_time(10, 0))
    scheduler.schedule_daily("func_b", TimeRule.at_time(10, 0))
    scheduler.schedule_daily("func_c", TimeRule.at_time(14, 30))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var bar_time = DateTime(2020, 1, 2, 10, 0, 0, 0)
    var result = scheduler.next_bar(bar_time)
    assert_equal(len(result), 3, "1d mode: all 3 functions trigger (all have trading-time rules)")


def test_next_bar_1d_mode_triggers_if_scheduled_time_in_trading() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("my_func", TimeRule.at_time(10, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var bar_time_9 = DateTime(2020, 1, 2, 9, 30, 0, 0)
    var result = scheduler.next_bar(bar_time_9)
    assert_equal(len(result), 1, "1d mode: triggers because scheduled time(10:00=600) is in trading hours, regardless of bar time")


def test_next_bar_updates_last_minute() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("f", TimeRule.at_time(10, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var bar_time = DateTime(2020, 1, 2, 10, 0, 0, 0)
    _ = scheduler.next_bar(bar_time)
    assert_equal(scheduler._last_minute, 600, "_last_minute updated to current bar time")


def test_before_trading_triggers() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("bt_func", TimeRule.before_trading())
    scheduler.schedule_daily("normal_func", TimeRule.at_time(10, 0))

    var result = scheduler.before_trading()
    assert_equal(len(result), 1, "only before_trading function should trigger")
    assert_equal(result[0], "bt_func")
    assert_equal(scheduler._stage, "", "_stage should be reset after before_trading")


def test_before_trading_no_match() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("normal_func", TimeRule.at_time(10, 0))

    var result = scheduler.before_trading()
    assert_equal(len(result), 0, "no before_trading functions to trigger")


# ============================================================
# Scheduler get_state / set_state Tests
# ============================================================

def test_get_state_initial() raises:
    var scheduler = create_scheduler("1d")
    var state = scheduler.get_state()
    assert_equal(state, "", "initial state should be empty string")


def test_get_state_after_next_day() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("f", TimeRule.at_time(10, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var state = scheduler.get_state()
    assert_true(len(state) > 0, "state should not be empty after next_day")
    var parts = state.split("|")
    assert_true(len(parts) >= 2, "state should have date|minute format")


def test_set_state_roundtrip() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("f", TimeRule.at_time(10, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var bar_time = DateTime(2020, 1, 2, 10, 30, 0, 0)
    _ = scheduler.next_bar(bar_time)

    var state = scheduler.get_state()

    var scheduler2 = create_scheduler("1d")
    scheduler2.schedule_daily("f", TimeRule.at_time(10, 0))
    scheduler2.set_state(state)

    assert_equal(scheduler2._last_minute, scheduler._last_minute, "last_minute should match after restore")
    assert_true(scheduler2._today != None, "_today should be restored")


def test_set_state_empty_string() raises:
    var scheduler = create_scheduler("1d")
    scheduler.set_state("")
    assert_false(scheduler._today != None, "empty state should not change anything")


# ============================================================
# Scheduler set_trading_ranges Tests
# ============================================================

def test_set_trading_ranges() raises:
    var scheduler = create_scheduler("1d")
    var new_ranges = List[TradingMinuteRange]()
    new_ranges.append(TradingMinuteRange(500, 800))
    new_ranges.append(TradingMinuteRange(900, 1000))
    scheduler.set_trading_ranges(new_ranges^)

    assert_equal(len(scheduler._trading_minute_ranges), 2)
    assert_equal(scheduler._trading_minute_ranges[0].start_minute, 500)
    assert_equal(scheduler._trading_minute_ranges[1].end_minute, 1000)

    assert_true(scheduler._is_in_trading_time(550), "new range should work")
    assert_false(scheduler._is_in_trading_time(850), "gap should not be in range")


# ============================================================
# SchedulerMod Tests
# ============================================================

def test_create_scheduler_mod_basic() raises:
    var mod = create_scheduler_mod()
    assert_equal(mod.name, "scheduler")
    assert_false(mod._enabled, "not enabled initially")
    assert_false(mod._scheduler != None, "no scheduler initially")


def test_scheduler_mod_start_up() raises:
    var mod = create_scheduler_mod()
    mod.start_up("test_env", "test_config")
    assert_true(mod._enabled, "should be enabled after start_up")
    assert_true(mod._scheduler != None, "scheduler should exist after start_up")


def test_scheduler_mod_tear_down() raises:
    var mod = create_scheduler_mod()
    mod.start_up("env", "cfg")
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))
    assert_true(mod._enabled, "tear_down should not change enabled state")


def test_scheduler_mod_get_state() raises:
    var mod = create_scheduler_mod()
    mod.start_up("test_env", "test_config")
    assert_true(mod.has_scheduler(), "should have scheduler after start_up")
    assert_true(mod.is_enabled(), "should be enabled after start_up")

    var state = mod.get_state()
    assert_equal(state, "", "no next_day called yet, state should be empty")


def test_scheduler_mod_state_lifecycle() raises:
    var mod = create_scheduler_mod()
    mod.start_up("env", "cfg")

    var state_initial = mod.get_state()
    assert_equal(state_initial, "", "initial state should be empty")

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("test_fn", TimeRule.at_time(10, 0))
    scheduler.next_day(dt)
    var bar_time = DateTime(2020, 1, 2, 10, 30, 0, 0)
    _ = scheduler.next_bar(bar_time)

    var state = scheduler.get_state()
    assert_true(len(state) > 0, "state should not be empty after next_day+next_bar")

    var mod2 = create_scheduler_mod()
    mod2.start_up("env2", "cfg2")
    mod2.set_state(state)
    var restored = mod2.get_state()
    assert_true(len(restored) > 0, "restored state should not be empty")


def test_scheduler_mod_writable() raises:
    var mod = create_scheduler_mod()
    var s = String(mod)
    assert_true(s.find("SchedulerMod") >= 0)
    assert_true(s.find("scheduler") >= 0)


# ============================================================
# Edge Case Tests
# ============================================================

def test_schedule_daily_with_market_open() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("at_open", TimeRule.market_open())
    var entry = scheduler._registry[0]
    assert_equal(entry.time_rule.minutes_since_midnight, 571)


def test_schedule_daily_with_market_close() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("at_close", TimeRule.market_close())
    var entry = scheduler._registry[0]
    assert_equal(entry.time_rule.minutes_since_midnight, 900)


def test_scheduler_frequency_variants() raises:
    var s1 = create_scheduler("1d")
    var s2 = create_scheduler("1m")
    var s3 = create_scheduler("tick")

    assert_equal(s1._frequency, "1d")
    assert_equal(s2._frequency, "1m")
    assert_equal(s3._frequency, "tick")


def test_next_bar_lunch_break() raises:
    """Verify that during lunch break (11:30-13:00), no 1m-scheduled functions trigger."""
    var scheduler = create_scheduler("1m")
    scheduler.schedule_daily("lunch_test", TimeRule.at_time(12, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var lunch_time = DateTime(2020, 1, 2, 12, 0, 0, 0)
    var result = scheduler.next_bar(lunch_time)
    assert_equal(len(result), 0, "12:00 is during lunch break, no trigger expected")


def test_next_bar_afternoon_session() raises:
    var scheduler = create_scheduler("1d")
    scheduler.schedule_daily("afternoon_func", TimeRule.at_time(14, 0))

    var dt = DateTime(2020, 1, 2, 0, 0, 0, 0)
    scheduler.next_day(dt)

    var afternoon = DateTime(2020, 1, 2, 14, 0, 0, 0)
    var result = scheduler.next_bar(afternoon)
    assert_equal(len(result), 1, "afternoon function should trigger")
    assert_equal(result[0], "afternoon_func")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
