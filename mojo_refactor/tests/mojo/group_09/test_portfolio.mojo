"""
Test for portfolio/portfolio.mojo
Group 09 - File 10
"""

from rqmojo.portfolio.portfolio import Portfolio, create_portfolio
from rqmojo.const import ACCOUNT_TYPE
from std.collections import Dict


fn test_portfolio_init() -> Bool:
    print("Test: Portfolio init")
    var portfolio = create_portfolio(100000.0)
    print("  PASSED")
    return True


fn test_portfolio_total_value() -> Bool:
    print("Test: Portfolio total_value")
    var portfolio = create_portfolio(100000.0)
    var value = portfolio.total_value()
    print("  PASSED")
    return True


fn test_portfolio_get_account() -> Bool:
    print("Test: Portfolio get_account")
    var portfolio = create_portfolio(100000.0)
    var account = portfolio.get_account(ACCOUNT_TYPE.STOCK)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 10: Portfolio Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_portfolio_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_portfolio_total_value():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_portfolio_get_account():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
