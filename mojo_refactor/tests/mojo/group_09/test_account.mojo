"""
Test for portfolio/account.mojo
Group 09 - File 9
"""

from rqmojo.portfolio.account import Account, create_account
from rqmojo.const import DEFAULT_ACCOUNT_TYPE

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_account_init() raises:
    print("Test: Account init")
    var _ = create_account(DEFAULT_ACCOUNT_TYPE.STOCK, 100000.0)
    print("  PASSED")


def test_account_total_value() raises:
    print("Test: Account total_value")
    var account = create_account(DEFAULT_ACCOUNT_TYPE.STOCK, 100000.0)
    var _ = account.total_value
    print("  PASSED")


def test_account_get_positions() raises:
    print("Test: Account get_positions")
    var account = create_account(DEFAULT_ACCOUNT_TYPE.STOCK, 100000.0)
    var _ = account.get_positions()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
