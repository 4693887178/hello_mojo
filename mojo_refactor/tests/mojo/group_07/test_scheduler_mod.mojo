"""
Test for mod/rqmojo_mod_sys_scheduler/scheduler.mojo
Group 07 - File 10
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import TimeRule, market_open_minutes, market_close_minutes

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_time_rule() raises:
    print("Test: TimeRule creation")
    var _ = TimeRule.before_trading()
    print("  PASSED")


def test_market_minutes() raises:
    print("Test: market minutes calculation")
    var open_min = market_open_minutes(0, 0)
    var close_min = market_close_minutes(0, 0)
    assert_equal(open_min, 571, "Market open minutes (9:31) should be 571")
    assert_equal(close_min, 900, "Market close minutes (15:00) should be 900")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
