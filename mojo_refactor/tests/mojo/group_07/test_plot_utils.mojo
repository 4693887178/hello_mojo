"""
Test for mod/rqmojo_mod_sys_analyser/plot/utils.mojo
Group 07 - File 04
"""

from std.math import sqrt
from std.collections import List
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import format_date, format_datetime, calculate_returns, calculate_max_drawdown, calculate_sharpe_ratio
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_format_date() raises:
    print("Test: format_date function")
    var dt = DateTime(2024, 3, 26, 0, 0, 0, 0)
    var result = format_date(dt)
    assert_true(len(result) > 0, "Date string should not be empty")
    print("  PASSED")


def test_format_datetime() raises:
    print("Test: format_datetime function")
    var dt = DateTime(2024, 3, 26, 14, 30, 0, 0)
    var result = format_datetime(dt)
    assert_true(len(result) > 0, "Datetime string should not be empty")
    print("  PASSED")


def test_calculate_returns() raises:
    print("Test: calculate_returns function")
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.10)
    nav_list.append(1.08)
    var returns = calculate_returns(nav_list)
    assert_equal(len(returns), 3, "Returns should have 3 values")
    print("  PASSED")


def test_calculate_max_drawdown() raises:
    print("Test: calculate_max_drawdown function")
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.1)
    nav_list.append(1.0)
    nav_list.append(0.9)
    nav_list.append(1.0)
    var max_dd = calculate_max_drawdown(nav_list)
    assert_true(max_dd >= 0, "Max drawdown should be positive")
    print("  PASSED")


def test_calculate_sharpe_ratio() raises:
    print("Test: calculate_sharpe_ratio function")
    var returns = List[Float64]()
    returns.append(0.01)
    returns.append(-0.01)
    returns.append(0.015)
    returns.append(0.005)
    var sharpe = calculate_sharpe_ratio(returns)
    print("  Sharpe ratio: ", sharpe)
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
