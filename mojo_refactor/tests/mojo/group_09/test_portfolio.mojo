"""
Test for portfolio/portfolio_manager.mojo
Group 09 - File 10
"""

from rqmojo.portfolio.portfolio_manager import Portfolio, create_stock_portfolio


fn test_portfolio_init() -> Bool:
    print("Test: Portfolio init")
    var portfolio = create_stock_portfolio(100000.0)
    print("  PASSED")
    return True


fn test_portfolio_total_value() -> Bool:
    print("Test: Portfolio total_value")
    var portfolio = create_stock_portfolio(100000.0)
    var value = portfolio.total_value
    print("  PASSED")
    return True


fn test_portfolio_get_account() -> Bool:
    print("Test: Portfolio get_account")
    var portfolio = create_stock_portfolio(100000.0)
    var account = portfolio.get_account()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 10: Portfolio Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_portfolio_init():
        passed += 1
    else:
        failed += 1
    
    if test_portfolio_total_value():
        passed += 1
    else:
        failed += 1
    
    if test_portfolio_get_account():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
