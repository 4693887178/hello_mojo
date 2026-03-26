"""
第五组测试 - mod/rqmojo_mod_sys_scheduler/__init__.mojo
测试Mojo版本的调度模块
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler import Scheduler, TimeRule, ScheduleEntry, TradingMinuteRange
from rqmojo.mod.rqmojo_mod_sys_scheduler import create_scheduler, market_open_minutes, market_close_minutes, physical_time_minutes


def test_create_scheduler() -> Bool:
    var scheduler = create_scheduler()
    return True


def test_scheduler_schedule_daily() -> Bool:
    var scheduler = create_scheduler()
    var rule = TimeRule.at_time(9, 30)
    scheduler.schedule_daily("test_callback", rule)
    return True


def test_scheduler_schedule_weekly() -> Bool:
    var scheduler = create_scheduler()
    var rule = TimeRule.at_time(9, 30)
    scheduler.schedule_weekly("test_callback", 1, rule)
    return True


def test_scheduler_schedule_monthly() -> Bool:
    var scheduler = create_scheduler()
    var rule = TimeRule.at_time(9, 30)
    scheduler.schedule_monthly("test_callback", 1, rule)
    return True


def test_time_rule_at_time() -> Bool:
    var rule = TimeRule.at_time(9, 30)
    return rule.minutes_since_midnight == 9 * 60 + 30


def test_time_rule_before_trading() -> Bool:
    var rule = TimeRule.before_trading()
    return rule.is_before_trading


def test_time_rule_market_open() -> Bool:
    var rule = TimeRule.market_open(0, 0)
    return not rule.is_before_trading


def test_time_rule_market_close() -> Bool:
    var rule = TimeRule.market_close(0, 0)
    return not rule.is_before_trading


def test_market_open_minutes() -> Bool:
    var minutes = market_open_minutes()
    return minutes > 0


def test_market_close_minutes() -> Bool:
    var minutes = market_close_minutes()
    return minutes > 0


def test_physical_time_minutes() -> Bool:
    var minutes = physical_time_minutes(9, 30)
    return minutes == 9 * 60 + 30


def test_scheduler_clear() -> Bool:
    var scheduler = create_scheduler()
    var rule = TimeRule.at_time(9, 30)
    scheduler.schedule_daily("test_callback", rule)
    scheduler.clear()
    return True


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_scheduler/__init__.mojo")
    print("=" * 60)
    
    if test_create_scheduler():
        print("PASS: test_create_scheduler")
        passed += 1
    else:
        print("FAIL: test_create_scheduler")
        failed += 1
    
    if test_scheduler_schedule_daily():
        print("PASS: test_scheduler_schedule_daily")
        passed += 1
    else:
        print("FAIL: test_scheduler_schedule_daily")
        failed += 1
    
    if test_scheduler_schedule_weekly():
        print("PASS: test_scheduler_schedule_weekly")
        passed += 1
    else:
        print("FAIL: test_scheduler_schedule_weekly")
        failed += 1
    
    if test_scheduler_schedule_monthly():
        print("PASS: test_scheduler_schedule_monthly")
        passed += 1
    else:
        print("FAIL: test_scheduler_schedule_monthly")
        failed += 1
    
    if test_time_rule_at_time():
        print("PASS: test_time_rule_at_time")
        passed += 1
    else:
        print("FAIL: test_time_rule_at_time")
        failed += 1
    
    if test_time_rule_before_trading():
        print("PASS: test_time_rule_before_trading")
        passed += 1
    else:
        print("FAIL: test_time_rule_before_trading")
        failed += 1
    
    if test_time_rule_market_open():
        print("PASS: test_time_rule_market_open")
        passed += 1
    else:
        print("FAIL: test_time_rule_market_open")
        failed += 1
    
    if test_time_rule_market_close():
        print("PASS: test_time_rule_market_close")
        passed += 1
    else:
        print("FAIL: test_time_rule_market_close")
        failed += 1
    
    if test_market_open_minutes():
        print("PASS: test_market_open_minutes")
        passed += 1
    else:
        print("FAIL: test_market_open_minutes")
        failed += 1
    
    if test_market_close_minutes():
        print("PASS: test_market_close_minutes")
        passed += 1
    else:
        print("FAIL: test_market_close_minutes")
        failed += 1
    
    if test_physical_time_minutes():
        print("PASS: test_physical_time_minutes")
        passed += 1
    else:
        print("FAIL: test_physical_time_minutes")
        failed += 1
    
    if test_scheduler_clear():
        print("PASS: test_scheduler_clear")
        passed += 1
    else:
        print("FAIL: test_scheduler_clear")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
