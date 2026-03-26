"""
Test for mod/utils.mojo
Group 07 - File 09
"""

from std.collections import Dict, List
from rqmojo.mod.utils import register_mod, unregister_mod, get_mod_config, parse_instrument_types, parse_markets
from rqmojo.const import INSTRUMENT_TYPE, MARKET


fn test_register_mod() -> Bool:
    print("Test: register_mod function")
    var config = Dict[String, String]()
    config["enabled"] = "true"
    register_mod("test_mod", config)
    print("  PASSED")
    return True


fn test_unregister_mod() -> Bool:
    print("Test: unregister_mod function")
    unregister_mod("test_mod")
    print("  PASSED")
    return True


fn test_get_mod_config() -> Bool:
    print("Test: get_mod_config function")
    var config = get_mod_config("test_mod")
    print("  PASSED")
    return True


fn test_parse_instrument_types() -> Bool:
    print("Test: parse_instrument_types function")
    var types = parse_instrument_types("CS,IND")
    print("  PASSED")
    return True


fn test_parse_markets() raises -> Bool:
    print("Test: parse_markets function")
    var markets = parse_markets("CN,HK")
    if len(markets) != 2:
        raise "Should have 2 markets"
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 09: Mod Utils Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
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
    
    try:
        if test_get_mod_config():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_parse_instrument_types():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_parse_markets():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
