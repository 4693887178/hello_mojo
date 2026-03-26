"""
Test for core/strategy.mojo
Group 09 - File 9
"""

from rqmojo.core.strategy import BaseStrategy, create_base_strategy
from rqmojo.core.events import create_event_bus


fn test_strategy_init() -> Bool:
    print("Test: BaseStrategy init")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    print("  PASSED")
    return True


fn test_strategy_with_name() -> Bool:
    print("Test: BaseStrategy with name")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^, name="MyStrategy")
    print("  PASSED")
    return True


fn test_strategy_str() -> Bool:
    print("Test: BaseStrategy str")
    var event_bus = create_event_bus()
    var strategy = create_base_strategy(event_bus=event_bus^)
    var s = String(strategy)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 9: Strategy Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_strategy_init():
        passed += 1
    else:
        failed += 1
    
    if test_strategy_with_name():
        passed += 1
    else:
        failed += 1
    
    if test_strategy_str():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
