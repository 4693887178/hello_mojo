"""
Test for portfolio/portfolio_manager.mojo
Group 09 - File 10
"""

from rqmojo.portfolio.portfolio_manager import Portfolio, create_stock_portfolio

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_portfolio_init() raises:
    print("Test: Portfolio init")
    var _ = create_stock_portfolio(100000.0)
    print("  PASSED")


def test_portfolio_total_value() raises:
    print("Test: Portfolio total_value")
    var portfolio = create_stock_portfolio(100000.0)
    var _ = portfolio.total_value
    print("  PASSED")


def test_portfolio_get_account() raises:
    print("Test: Portfolio get_account")
    var portfolio = create_stock_portfolio(100000.0)
    var _ = portfolio.get_account()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
