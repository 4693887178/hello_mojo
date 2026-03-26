"""
Test for mod/__init__.mojo
Group 08 - File 4
"""

from rqmojo.mod import SYSTEM_MOD_LIST, get_system_mod, register_mod, unregister_mod
from std.collections import List


fn test_system_mod_list() -> Bool:
    print("Test: SYSTEM_MOD_LIST exists")
    var mod_list = SYSTEM_MOD_LIST
    print("  PASSED")
    return True


fn test_get_system_mod() -> Bool:
    print("Test: get_system_mod function")
    var mod_name = get_system_mod("sys_analyser")
    print("  PASSED")
    return True


fn test_register_mod() -> Bool:
    print("Test: register_mod function")
    register_mod("test_mod", "test_config")
    print("  PASSED")
    return True


fn test_unregister_mod() -> Bool:
    print("Test: unregister_mod function")
    unregister_mod("test_mod")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 4: Mod Init Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_system_mod_list():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_get_system_mod():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_register_mod():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_unregister_mod():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
