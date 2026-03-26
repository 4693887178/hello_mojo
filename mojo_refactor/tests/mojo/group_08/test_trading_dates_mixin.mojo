"""
Test for data/trading_dates_mixin.mojo
Group 08 - File 5
"""

from std.collections import Dict, List
from rqmojo.data.trading_dates_mixin import TradingDatesMixin, create_trading_dates_mixin
from rqmojo.const import TRADING_CALENDAR_TYPE
from rqmojo.utils.typing import DateTime


def test_trading_dates_mixin_struct() -> Bool:
    print("Test: TradingDatesMixin struct exists")
    var mixin = create_trading_dates_mixin()
    print("  PASSED")
    return True


def test_trading_dates_mixin_methods() -> Bool:
    print("Test: TradingDatesMixin methods exist")
    var mixin = create_trading_dates_mixin()
    
    if not hasattr(mixin, "get_trading_dates"):
        raise "Should have get_trading_dates method"
    
    if not hasattr(mixin, "is_trading_date"):
        raise "Should have is_trading_date method"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 08 File 5: Trading Dates Mixin Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_trading_dates_mixin_struct():
        passed += 1
    else:
        failed += 1
    
    if test_trading_dates_mixin_methods():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
