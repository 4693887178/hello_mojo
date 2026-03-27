"""
Test for mod/rqmojo_mod_sys_analyser/report/report.mojo
Group 09 - File 3
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report.report import Report, create_report
from std.collections import List
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_report_init() raises:
    print("Test: Report init")
    var nav_list = List[Float64]()
    nav_list.append(100000.0)
    nav_list.append(101000.0)
    nav_list.append(102000.0)
    var _ = create_report(
        strategy_name="TestStrategy",
        start_date=DateTime(2024, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2024, 12, 31, 0, 0, 0, 0),
        nav_list=nav_list^,
        total_trades=10,
        win_count=6,
        loss_count=4
    )
    print("  PASSED")


def test_report_generate_summary() raises:
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
    var _ = report.generate_summary()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
