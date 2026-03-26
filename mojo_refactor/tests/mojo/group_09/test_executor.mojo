"""
Test for core/executor.mojo
Group 09 - File 5
"""

from rqmojo.core.executor import Executor, create_executor
from rqmojo.core.events import EventBus
from rqmojo.const import MATCHING_TYPE


fn test_executor_init() -> Bool:
    print("Test: Executor init")
    var event_bus = EventBus()
    var executor = create_executor(event_bus, MATCHING_TYPE.CURRENT_BAR_CLOSE)
    print("  PASSED")
    return True


fn test_executor_get_state() -> Bool:
    print("Test: Executor get_state")
    var event_bus = EventBus()
    var executor = create_executor(event_bus, MATCHING_TYPE.CURRENT_BAR_CLOSE)
    var state = executor.get_state()
    print("  PASSED")
    return True


fn test_executor_set_state() -> Bool:
    print("Test: Executor set_state")
    var event_bus = EventBus()
    var executor = create_executor(event_bus, MATCHING_TYPE.CURRENT_BAR_CLOSE)
    executor.set_state("")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 5: Executor Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_executor_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_executor_get_state():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_executor_set_state():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
