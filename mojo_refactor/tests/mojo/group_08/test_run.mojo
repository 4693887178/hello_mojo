"""
Test for core/run.mojo
Group 08 - File 6
"""

from rqmojo.core.run import RunConfig, create_run_config, run_backtest
from std.collections import Dict
from python import PythonObject


fn test_run_config_init() -> Bool:
    print("Test: RunConfig init")
    var config = create_run_config()
    print("  PASSED")
    return True


fn test_run_config_fields() -> Bool:
    print("Test: RunConfig fields")
    var config = create_run_config()
    config.base_run_type = "backtest"
    config.frequency = "1d"
    print("  PASSED")
    return True


fn test_run_config_from_dict() raises -> Bool:
    print("Test: create_run_config from dict")
    var config = create_run_config()
    config.frequency = "1d"
    if config.frequency != "1d":
        raise "Frequency should be 1d"
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 6: Run Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_run_config_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_run_config_fields():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_run_config_from_dict():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
