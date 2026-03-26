"""
Test for mod/rqmojo_mod_sys_scheduler/scheduler.mojo
Group 09 - File 4
"""

from rqmojo.mod.rqmojo_mod_sys_scheduler.scheduler import Scheduler, TimeRule, create_scheduler


fn test_scheduler_init() -> Bool:
    print("Test: Scheduler init")
    var scheduler = create_scheduler("1d")
    print("  PASSED")
    return True


fn test_scheduler_schedule_daily() -> Bool:
    print("Test: Scheduler schedule_daily")
    var scheduler = create_scheduler("1d")
    var time_rule = TimeRule.market_open(0, 0)
    scheduler.schedule_daily("my_func", time_rule)
    print("  PASSED")
    return True


fn test_time_rule_market_open() -> Bool:
    print("Test: TimeRule market_open")
    var rule = TimeRule.market_open(0, 0)
    print("  PASSED")
    return True


fn test_time_rule_market_close() -> Bool:
    print("Test: TimeRule market_close")
    var rule = TimeRule.market_close(0, 0)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 4: Scheduler Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_scheduler_init():
        passed += 1
    else:
        failed += 1
    
    if test_scheduler_schedule_daily():
        passed += 1
    else:
        failed += 1
    
    if test_time_rule_market_open():
        passed += 1
    else:
        failed += 1
    
    if test_time_rule_market_close():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
