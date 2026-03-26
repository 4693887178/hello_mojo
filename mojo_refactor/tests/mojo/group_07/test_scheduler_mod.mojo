"""
Test for mod/rqmojo_mod_sys_scheduler/mod.mojo
Group 07 - File 06
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler.mod import (
    SchedulerMod, create_scheduler_mod
)
from rqmojo.const import EXIT_CODE


def test_scheduler_mod_init() -> Bool:
    print("Test: SchedulerMod init")
    
    var mod = create_scheduler_mod()
    
    if mod.name != "scheduler":
        raise "SchedulerMod name should be 'scheduler'"
    print("  PASSED")
    return True


def test_scheduler_mod_start_up() -> Bool:
    print("Test: SchedulerMod start_up")
    
    var mod = create_scheduler_mod()
    
    mod.start_up(None, None)
    
    print("  PASSED")
    return True


def test_scheduler_mod_tear_down() -> Bool:
    print("Test: SchedulerMod tear_down")
    
    var mod = create_scheduler_mod()
    
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)
    
    print("  PASSED")
    return True


def test_scheduler_mod_get_state() -> Bool:
    print("Test: SchedulerMod get_state")
    
    var mod = create_scheduler_mod()
    
    var state = mod.get_state()
    
    if len(state) != 0:
        raise "State should be empty without scheduler"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 07 File 06: Scheduler Mod Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_scheduler_mod_init():
        passed += 1
    else:
        failed += 1
    
    if test_scheduler_mod_start_up():
        passed += 1
    else:
        failed += 1
    
    if test_scheduler_mod_tear_down():
        passed += 1
    else:
        failed += 1
    
    if test_scheduler_mod_get_state():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
