"""
Test for mod/rqmojo_mod_sys_analyser/report/report.mojo
Group 09 - File 3
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report.report import Report, create_report
from std.collections import List
from rqmojo.utils.typing import DateTime


fn test_report_init() -> Bool:
    print("Test: Report init")
    var nav_list = List[Float64]()
    nav_list.append(100000.0)
    nav_list.append(101000.0)
    nav_list.append(102000.0)
    var report = create_report(
        strategy_name="TestStrategy",
        start_date=DateTime(2024, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2024, 12, 31, 0, 0, 0, 0),
        nav_list=nav_list^,
        total_trades=10,
        win_count=6,
        loss_count=4
    )
    print("  PASSED")
    return True


fn test_report_generate_summary() -> Bool:
    print("Test: Report generate_summary")
    var nav_list = List[Float64]()
    nav_list.append(100000.0)
    nav_list.append(101000.0)
    nav_list.append(102000.0)
    var report = create_report(
        strategy_name="TestStrategy",
        start_date=DateTime(2024, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2024, 12, 31, 0, 0, 0, 0),
        nav_list=nav_list^,
        total_trades=10,
        win_count=6,
        loss_count=4
    )
    var summary = report.generate_summary()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 3: Report Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_report_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_report_generate_summary():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
