"""
Test for mod/rqmojo_mod_sys_analyser/__init__.mojo
Group 07 - File 03
"""

from python import PythonObject
from rqmojo.mod.rqmojo_mod_sys_analyser import __config__, load_mod, cli_prefix


def test_config_exists() -> Bool:
    print("Test: __config__ exists")
    if __config__ is None:
        raise "__config__ should not be None"
    print("  PASSED")
    return True


def test_config_keys() -> Bool:
    print("Test: __config__ keys")
    var expected_keys = ["benchmark", "record", "strategy_name", "output_file", 
                         "report_save_path", "plot", "plot_save_file", "plot_config"]
    for key in expected_keys:
        if key not in __config__:
            raise "Missing config key: " + key
 print("  PASSED")
    return True


def test_load_mod_function() -> Bool:
    print("Test: load_mod function")
    if not callable(load_mod):
        raise "load_mod should be callable"
    print("  PASSED")
    return True


def test_cli_prefix() -> Bool:
    print("Test: cli_prefix constant")
    if cli_prefix != "mod__sys_analyser__":
    raise "cli_prefix should be 'mod__sys_analyser__'"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 07 File 03: Analyser Init Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_config_exists():
        passed += 1
    else:
        failed += 1
    
    if test_config_keys():
        passed += 1
    else:
        failed += 1
    
    if test_load_mod_function():
        passed += 1
    else:
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
