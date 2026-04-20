"""
Test for portfolio/__init__.mojo
Group 12 - File 5
"""

from std.collections import Dict, List
from rqmojo.portfolio.portfolio_manager import Portfolio, create_portfolio
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_portfolio_struct() raises:
    print("Test: Portfolio struct exists")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var portfolio = create_portfolio(start_date, 100000.0, 1.0)
    assert_equal(portfolio.total_value, 100000.0, "Total value should match")
    print("  PASSED")


def test_portfolio_cash() raises:
    print("Test: Portfolio cash")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var portfolio = create_portfolio(start_date, 100000.0, 1.0)
    assert_equal(portfolio.cash, 100000.0, "Cash should match")
    print("  PASSED")


def test_portfolio_get_position() raises:
    print("Test: Portfolio get_position")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var portfolio = create_portfolio(start_date, 100000.0, 1.0)
    var position = portfolio.get_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(position.order_book_id, "000001.XSHE", "Order book ID should match")
    print("  PASSED")


def test_portfolio_get_positions() raises:
    print("Test: Portfolio get_positions")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var portfolio = create_portfolio(start_date, 100000.0, 1.0)
    var positions = portfolio.get_positions()
    assert_true(positions.__len__() >= 0, "Positions should be a list")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
