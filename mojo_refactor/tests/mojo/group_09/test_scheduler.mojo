"""
Test for mod/rqmojo_mod_sys_scheduler/scheduler.mojo
Group 09 - File 4
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import Scheduler, TimeRule, create_scheduler

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_scheduler_init() raises:
    print("Test: Scheduler init")
    var _ = create_scheduler("1d")
    print("  PASSED")


def test_scheduler_schedule_daily() raises:
    print("Test: Scheduler schedule_daily")
    var scheduler = create_scheduler("1d")
    var time_rule = TimeRule.market_open(0, 0)
    scheduler.schedule_daily("my_func", time_rule)
    print("  PASSED")


def test_time_rule_market_open() raises:
    print("Test: TimeRule market_open")
    var _ = TimeRule.market_open(0, 0)
    print("  PASSED")


def test_time_rule_market_close() raises:
    print("Test: TimeRule market_close")
    var _ = TimeRule.market_close(0, 0)
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
