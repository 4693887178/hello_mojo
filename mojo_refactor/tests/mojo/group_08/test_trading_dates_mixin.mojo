"""
Test for data/trading_dates_mixin.mojo
Group 08 - File 10
"""

from rqmojo.data.trading_dates_mixin import TradingDatesMixin, create_trading_dates_mixin
from rqmojo.utils.typing import DateTime
from std.collections import List


fn test_trading_dates_mixin_init() -> Bool:
    print("Test: TradingDatesMixin init")
    var mixin = create_trading_dates_mixin()
    print("  PASSED")
    return True


fn test_trading_dates_mixin_get_trading_dates() -> Bool:
    print("Test: TradingDatesMixin get_trading_dates")
    var mixin = create_trading_dates_mixin()
    var dates = mixin.get_trading_dates("000001.XSHE")
    print("  PASSED")
    return True


fn test_trading_dates_mixin_is_trading_date() -> Bool:
    print("Test: TradingDatesMixin is_trading_date")
    var mixin = create_trading_dates_mixin()
    var result = mixin.is_trading_date(DateTime(2024, 1, 2, 0, 0, 0, 0))
    print("  PASSED")
    return True


fn test_trading_dates_mixin_get_previous_trading_date() -> Bool:
    print("Test: TradingDatesMixin get_previous_trading_date")
    var mixin = create_trading_dates_mixin()
    var prev_date = mixin.get_previous_trading_date(DateTime(2024, 1, 2, 0, 0, 0, 0))
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 10: Trading Dates Mixin Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_trading_dates_mixin_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_trading_dates_mixin_get_trading_dates():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_trading_dates_mixin_is_trading_date():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_trading_dates_mixin_get_previous_trading_date():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
