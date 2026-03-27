"""
RQMojo Test for mod/rqmojo_mod_sys_accounts/api/__init__.mojo
"""

from rqmojo.mod.rqmojo_mod_sys_accounts.api import (
    stock_order_shares, stock_order_lots, stock_order_value, stock_order_percent,
    stock_order_target_value, stock_order_target_percent,
    stock_order, stock_order_to,
    buy_open, sell_close, sell_open, buy_close,
    future_order, future_order_to,
    get_future_position, get_future_positions,
    order_target_portfolio
)



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_api_module_imports() raises:
    print("Testing mod/rqmojo_mod_sys_accounts/api/__init__.mojo imports...")
    print("  All API functions imported successfully!")
    print("  mod/rqmojo_mod_sys_accounts/api/__init__.mojo tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()