"""
Test for core/strategy_context.mojo
Group 08 - File 2
"""

from std.collections import Dict, Set
from rqmojo.core.strategy_context import (
    RunInfo, StrategyContext, create_run_info, create_strategy_context
)
from rqmojo.const import RUN_TYPE, MATCHING_TYPE
from rqmojo.utils.typing import DateTime, DateTimeDate


def test_run_info_struct() -> Bool:
    print("Test: RunInfo struct exists")
    var info = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d"
    )
    if info.frequency() != "1d":
        raise "Frequency should be 1d"
    print("  PASSED")
    return True


def test_run_info_properties() -> Bool:
    print("Test: RunInfo properties")
    var info = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d",
        stock_starting_cash=100000.0,
        future_starting_cash=50000.0,
        margin_multiplier=1.5
    )
    
    if info.start_date().year() != 2020:
        raise "Start date year should be 2020"
    
    if info.stock_starting_cash() != 100000.0:
        raise "Stock starting cash should be 100000.0"
    
    if info.future_starting_cash() != 50000.0:
        raise "Future starting cash should be 50000.0"
    
    if info.margin_multiplier() != 1.5:
        raise "Margin multiplier should be 1.5"
    print("  PASSED")
    return True


def test_run_info_run_type() -> Bool:
    print("Test: RunInfo run_type")
    var info = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d",
        run_type=RUN_TYPE.PAPER_TRADING
    )
    
    if info.run_type() != RUN_TYPE.PAPER_TRADING:
        raise "Run type should be PAPER_TRADING"
    print("  PASSED")
    return True


def test_run_info_string() -> Bool:
    print("Test: RunInfo __str__")
    var info = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d"
    )
    var s = info.__str__()
    if len(s) < 1:
        raise "String representation should not be empty"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 08 File 2: Strategy Context Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_run_info_struct():
        passed += 1
    else:
        failed += 1
    
    if test_run_info_properties():
        passed += 1
    else:
        failed += 1
    
    if test_run_info_run_type():
        passed += 1
    else:
        failed += 1
    
    if test_run_info_string():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
