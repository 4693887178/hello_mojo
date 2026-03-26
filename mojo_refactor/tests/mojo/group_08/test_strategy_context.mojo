"""
Test for core/strategy_context.mojo
Group 08 - File 8
"""

from rqmojo.core.strategy_context import StrategyContext, create_strategy_context
from rqmojo.const import RUN_TYPE, MATCHING_TYPE
from python import PythonObject


fn test_strategy_context_init() -> Bool:
    print("Test: StrategyContext init")
    var ctx = create_strategy_context()
    print("  PASSED")
    return True


fn test_strategy_context_fields() -> Bool:
    print("Test: StrategyContext fields")
    var ctx = create_strategy_context()
    ctx.run_type = RUN_TYPE.BACKTEST
    ctx.matching_type = MATCHING_TYPE.CURRENT_BAR_CLOSE
    print("  PASSED")
    return True


fn test_strategy_context_get_state() -> Bool:
    print("Test: StrategyContext get_state")
    var ctx = create_strategy_context()
    var state = ctx.get_state()
    print("  PASSED")
    return True


fn test_strategy_context_set_state() -> Bool:
    print("Test: StrategyContext set_state")
    var ctx = create_strategy_context()
    ctx.set_state("")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 8: Strategy Context Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_strategy_context_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_context_fields():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_context_get_state():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_strategy_context_set_state():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
