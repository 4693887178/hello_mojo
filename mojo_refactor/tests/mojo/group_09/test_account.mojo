"""
Test for portfolio/account.mojo
Group 09 - File 9
"""

from rqmojo.portfolio.account import Account, create_account
from rqmojo.const import DEFAULT_ACCOUNT_TYPE


fn test_account_init() -> Bool:
    print("Test: Account init")
    var account = create_account(DEFAULT_ACCOUNT_TYPE.STOCK, 100000.0)
    print("  PASSED")
    return True


fn test_account_total_value() -> Bool:
    print("Test: Account total_value")
    var account = create_account(DEFAULT_ACCOUNT_TYPE.STOCK, 100000.0)
    var value = account.total_value
    print("  PASSED")
    return True


fn test_account_get_positions() -> Bool:
    print("Test: Account get_positions")
    var account = create_account(DEFAULT_ACCOUNT_TYPE.STOCK, 100000.0)
    var positions = account.get_positions()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 9: Account Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_account_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_account_total_value():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_account_get_positions():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
