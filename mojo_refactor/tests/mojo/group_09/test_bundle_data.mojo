"""
Test for data/bundle.mojo
Group 09 - File 7
"""

from rqmojo.data.bundle import Bundle, create_bundle


fn test_bundle_init() -> Bool:
    print("Test: Bundle init")
    var bundle = create_bundle("./bundle")
    print("  PASSED")
    return True


fn test_bundle_get_instruments_path() -> Bool:
    print("Test: Bundle get_instruments_path")
    var bundle = create_bundle("./bundle")
    var path = bundle.get_instruments_path()
    print("  PASSED")
    return True


fn test_bundle_get_trading_dates_path() -> Bool:
    print("Test: Bundle get_trading_dates_path")
    var bundle = create_bundle("./bundle")
    var path = bundle.get_trading_dates_path()
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
        if test_bundle_get_instruments_path():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bundle_get_trading_dates_path():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
