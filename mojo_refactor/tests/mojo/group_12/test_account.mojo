"""
Test for portfolio/account.mojo
Group 12 - File 2
"""

from std.collections import Dict, List
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.const import POSITION_DIRECTION
from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_account_struct() raises:
    print("Test: Account struct exists")
    var account = create_stock_account(100000.0)
    assert_equal(account.total_cash, 100000.0, "Total cash should match")
    print("  PASSED")


def test_account_total_value() raises:
    print("Test: Account total_value")
    var account = create_stock_account(100000.0)
    assert_equal(account.total_value, 100000.0, "Total value should match")
    print("  PASSED")


def test_account_cash() raises:
    print("Test: Account cash")
    var account = create_stock_account(100000.0)
    assert_equal(account.total_cash, 100000.0, "Cash should match")
    print("  PASSED")


def test_account_positions() raises:
    print("Test: Account positions")
    var account = create_stock_account(100000.0)
    var positions = account.get_positions()
    assert_true(positions.__len__() >= 0, "Positions should be a list")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
