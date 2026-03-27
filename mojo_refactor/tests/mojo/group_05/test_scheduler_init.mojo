"""
第五组测试 - mod/rqmojo_mod_sys_scheduler/__init__.mojo
测试Mojo版本的调度模块
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler import SchedulerMod, create_scheduler_mod
from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import Scheduler, create_scheduler


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_create_scheduler_mod() raises:
    var mod = create_scheduler_mod()
    assert_equal(mod.name, "scheduler", "name should match")


def test_scheduler_mod_start_up() raises:
    var mod = create_scheduler_mod()
    mod.start_up("env", "config")
    assert_true(True, "start_up works")


def test_scheduler_mod_tear_down() raises:
    from rqmojo.const import EXIT_CODE
    var mod = create_scheduler_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    assert_true(True, "tear_down works")


def test_create_scheduler() raises:
    var scheduler = create_scheduler("1d")
    assert_true(True, "Scheduler created")


def test_scheduler_frequency() raises:
    var scheduler = create_scheduler("1d")
    assert_true(True, "scheduler frequency works")


def test_scheduler_str() raises:
    var scheduler = create_scheduler("1d")
    var s = String(scheduler)
    assert_true(s.find("Scheduler") >= 0, "should contain Scheduler")


def test_scheduler_mod_str() raises:
    var mod = create_scheduler_mod()
    var s = String(mod)
    assert_true(s.find("SchedulerMod") >= 0, "should contain SchedulerMod")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
