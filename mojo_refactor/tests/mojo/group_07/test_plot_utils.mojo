"""
Test for mod/rqmojo_mod_sys_analyser/plot/utils.mojo
Group 07 - File 04
"""

from std.math import sqrt
from std.collections import List
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.utils import format_date, format_datetime, calculate_returns, calculate_max_drawdown, calculate_sharpe_ratio
from rqmojo.utils.typing import DateTime


fn test_format_date() raises -> Bool:
    print("Test: format_date function")
    var dt = DateTime(2024, 3, 26, 0, 0, 0, 0)
    var result = format_date(dt)
    if len(result) == 0:
        raise "Date string should not be empty"
    print("  PASSED")
    return True


fn test_format_datetime() raises -> Bool:
    print("Test: format_datetime function")
    var dt = DateTime(2024, 3, 26, 14, 30, 0, 0)
    var result = format_datetime(dt)
    if len(result) == 0:
        raise "Datetime string should not be empty"
    print("  PASSED")
    return True


fn test_calculate_returns() raises -> Bool:
    print("Test: calculate_returns function")
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.10)
    nav_list.append(1.08)
    var returns = calculate_returns(nav_list)
    if len(returns) != 3:
        raise "Returns should have 3 values"
    print("  PASSED")
    return True


fn test_calculate_max_drawdown() raises -> Bool:
    print("Test: calculate_max_drawdown function")
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.1)
    nav_list.append(1.0)
    nav_list.append(0.9)
    nav_list.append(1.0)
    var max_dd = calculate_max_drawdown(nav_list)
    if max_dd < 0:
        raise "Max drawdown should be positive"
    print("  PASSED")
    return True


fn test_calculate_sharpe_ratio() -> Bool:
    print("Test: calculate_sharpe_ratio function")
    var returns = List[Float64]()
    returns.append(0.01)
    returns.append(-0.01)
    returns.append(0.015)
    returns.append(0.005)
    var sharpe = calculate_sharpe_ratio(returns)
    print("  Sharpe ratio: ", sharpe)
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 04: Plot Utils Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_format_date():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_format_datetime():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_calculate_returns():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_calculate_max_drawdown():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_calculate_sharpe_ratio():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
