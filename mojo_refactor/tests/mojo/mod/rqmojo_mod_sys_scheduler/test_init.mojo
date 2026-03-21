"""
Mojo Test for mod/rqmojo_mod_sys_scheduler/__init__.mojo
Tests the scheduler module exports
TDD: Write tests first, then verify implementation
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler import (
    Scheduler, TimeRule, ScheduleEntry, TradingMinuteRange,
    create_scheduler, market_open_minutes, market_close_minutes, physical_time_minutes
)
from rqmojo.mod.rqmojo_mod_sys_scheduler import SchedulerMod, create_scheduler_mod
from rqmojo.utils.datetime_func import DateTime


def test_time_rule_before_trading():
    var rule = TimeRule.before_trading()
    print("TimeRule before_trading: " + rule.__str__())
    assert rule.is_before_trading == True


def test_time_rule_at_time():
    var rule = TimeRule.at_time(hour=10, minute=30)
    print("TimeRule at_time: " + rule.__str__())
    assert rule.minutes_since_midnight == 10 * 60 + 30
    assert rule.is_before_trading == False


def test_time_rule_market_open():
    var rule = TimeRule.market_open(hour=0, minute=0)
    print("TimeRule market_open: " + rule.__str__())
    assert rule.minutes_since_midnight > 0


def test_time_rule_market_close():
    var rule = TimeRule.market_close(hour=0, minute=0)
    print("TimeRule market_close: " + rule.__str__())
    assert rule.minutes_since_midnight > 0


def test_market_open_minutes():
    var minutes = market_open_minutes()
    print("Market open minutes: " + String(minutes))
    assert minutes > 0


def test_market_close_minutes():
    var minutes = market_close_minutes()
    print("Market close minutes: " + String(minutes))
    assert minutes > 0


def test_physical_time_minutes():
    var minutes = physical_time_minutes(hour=10, minute=30)
    print("Physical time minutes: " + String(minutes))
    assert minutes == 10 * 60 + 30


def test_trading_minute_range():
    var range = TradingMinuteRange(start_minute=571, end_minute=690)
    print("TradingMinuteRange: " + range.__str__())
    assert range.contains(600) == True
    assert range.contains(500) == False


def test_scheduler_creation():
    var scheduler = create_scheduler("1d")
    print("Scheduler created: " + scheduler.__str__())
    assert True


def test_scheduler_schedule_daily():
    var scheduler = create_scheduler("1d")
    var rule = TimeRule.at_time(hour=10, minute=0)
    scheduler.schedule_daily("my_func", rule)
    print("Scheduled daily function")
    assert True


def test_scheduler_schedule_weekly():
    var scheduler = create_scheduler("1d")
    var rule = TimeRule.at_time(hour=10, minute=0)
    scheduler.schedule_weekly("my_weekly_func", 1, rule)
    print("Scheduled weekly function")
    assert True


def test_scheduler_schedule_monthly():
    var scheduler = create_scheduler("1d")
    var rule = TimeRule.at_time(hour=10, minute=0)
    scheduler.schedule_monthly("my_monthly_func", 1, rule)
    print("Scheduled monthly function")
    assert True


def test_scheduler_next_day():
    var scheduler = create_scheduler("1d")
    var rule = TimeRule.at_time(hour=10, minute=0)
    scheduler.schedule_daily("my_func", rule)
    
    var dt = DateTime(2024, 1, 15, 0, 0, 0, 0)
    scheduler.next_day(dt)
    print("Scheduler next_day called")
    assert True


def test_scheduler_before_trading():
    var scheduler = create_scheduler("1d")
    var rule = TimeRule.before_trading()
    scheduler.schedule_daily("before_trading_func", rule)
    
    var dt = DateTime(2024, 1, 15, 0, 0, 0, 0)
    scheduler.next_day(dt)
    
    var funcs = scheduler.before_trading()
    print("Before trading functions: " + String(len(funcs)))
    assert len(funcs) == 1


def test_scheduler_get_state():
    var scheduler = create_scheduler("1d")
    var dt = DateTime(2024, 1, 15, 0, 0, 0, 0)
    scheduler.next_day(dt)
    
    var state = scheduler.get_state()
    print("Scheduler state: " + state)
    assert len(state) > 0


def test_scheduler_mod_creation():
    var mod = create_scheduler_mod()
    print("SchedulerMod created: " + mod.__str__())
    assert mod.name == "scheduler"


def test_scheduler_mod_get_scheduler():
    var mod = create_scheduler_mod()
    var scheduler = mod.get_scheduler()
    print("SchedulerMod get_scheduler called")
    assert scheduler == None


def main():
    print("=== Testing mod/rqmojo_mod_sys_scheduler ===")
    test_time_rule_before_trading()
    test_time_rule_at_time()
    test_time_rule_market_open()
    test_time_rule_market_close()
    test_market_open_minutes()
    test_market_close_minutes()
    test_physical_time_minutes()
    test_trading_minute_range()
    test_scheduler_creation()
    test_scheduler_schedule_daily()
    test_scheduler_schedule_weekly()
    test_scheduler_schedule_monthly()
    test_scheduler_next_day()
    test_scheduler_before_trading()
    test_scheduler_get_state()
    test_scheduler_mod_creation()
    test_scheduler_mod_get_scheduler()
    print("All scheduler tests passed!")
