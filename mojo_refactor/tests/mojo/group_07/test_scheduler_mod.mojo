"""
Test for mod/rqmojo_mod_sys_scheduler/mod.mojo
Group 07 - File 06
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler.mod import SchedulerMod, create_scheduler_mod
from rqmojo.const import EXIT_CODE
from python import PythonObject


fn test_scheduler_mod_init() -> Bool:
    print("Test: SchedulerMod init")
    var mod = create_scheduler_mod()
    if mod.name != "scheduler":
        return False
    print("  PASSED")
    return True


fn test_scheduler_mod_start_up() -> Bool:
    print("Test: SchedulerMod start up")
    var mod = create_scheduler_mod()
    mod.start_up(PythonObject(None), PythonObject(None))
    print("  PASSED")
    return True


fn test_scheduler_mod_tear_down() -> Bool:
    print("Test: SchedulerMod tear_down")
    var mod = create_scheduler_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, PythonObject(None))
    print("  PASSED")
    return True


fn test_scheduler_mod_get_state() -> Bool:
    print("Test: SchedulerMod get state")
    var mod = create_scheduler_mod()
    var state = mod.get_state()
    print("  State: ", state)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 06: SchedulerMod Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_scheduler_mod_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_scheduler_mod_start_up():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_scheduler_mod_tear_down():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_scheduler_mod_get_state():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
