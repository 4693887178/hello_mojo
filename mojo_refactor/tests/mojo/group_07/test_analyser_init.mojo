"""
Test for mod/rqmojo_mod_sys_analyser/__init__.mojo
Group 07 - File 03
"""

from python import PythonObject
from rqmojo.mod.rqmojo_mod_sys_analyser import AnalyserConfig, create_config, get_cli_prefix


fn test_config_exists() raises -> Bool:
    print("Test: AnalyserConfig exists")
    var config = create_config()
    print("  PASSED")
    return True


fn test_config_defaults() raises -> Bool:
    print("Test: AnalyserConfig defaults")
    var config = create_config()
    if config.record != True:
        raise "record should be True by default"
    if config.plot != False:
        raise "plot should be False by default"
    print("  PASSED")
    return True


fn test_cli_prefix() -> Bool:
    print("Test: cli_prefix constant")
    var prefix = get_cli_prefix()
    if prefix != "mod__sys_analyser__":
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 03: Analyser Init Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_config_exists():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_config_defaults():
            passed += 1
    except:
        failed += 1
    
    if test_cli_prefix():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
