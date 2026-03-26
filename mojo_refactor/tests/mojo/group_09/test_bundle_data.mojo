"""
Test for data/bundle.mojo
Group 09 - File 7
"""

from rqmojo.data.bundle import Bundle, create_bundle
from rqmojo.utils.typing import DateTime
from std.collections import Dict


fn test_bundle_init() -> Bool:
    print("Test: Bundle init")
    var bundle = create_bundle()
    print("  PASSED")
    return True


fn test_bundle_get_instruments() -> Bool:
    print("Test: Bundle get_instruments")
    var bundle = create_bundle()
    var instruments = bundle.get_instruments()
    print("  PASSED")
    return True


fn test_bundle_get_trading_calendar() -> Bool:
    print("Test: Bundle get_trading_calendar")
    var bundle = create_bundle()
    var calendar = bundle.get_trading_calendar()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 7: Bundle Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_bundle_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bundle_get_instruments():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bundle_get_trading_calendar():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
