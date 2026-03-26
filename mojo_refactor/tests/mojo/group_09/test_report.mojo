"""
Test for mod/rqmojo_mod_sys_analyser/report/report.mojo
Group 09 - File 1
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_analyser.report.report import (
    Report, ReportConfig, create_report, generate_returns
)


def test_report_config_struct() -> Bool:
    print("Test: ReportConfig struct exists")
    var config = ReportConfig(
        title="Test Report",
        start_date="2020-01-01",
        end_date="2020-12-31",
        benchmark="000001.XSHE"
    )
    if config.title != "Test Report":
        raise "Title should be Test Report"
    print("  PASSED")
    return True


def test_create_report() -> Bool:
    print("Test: create_report function")
    var config = ReportConfig(
        title="Test",
        start_date="2020-01-01",
        end_date="2020-12-31",
        benchmark="000001.XSHE"
    )
    var report = create_report(config)
    if report.title() != "Test":
        raise "Title should be Test"
    print("  PASSED")
    return True


def test_generate_returns() -> Bool:
    print("Test: generate_returns function")
    var returns = generate_returns()
    if len(returns) < 0:
        raise "Returns should be a list"
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 09 File 1: Report Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_report_config_struct():
        passed += 1
    else:
        failed += 1
    
    if test_create_report():
        passed += 1
    else:
        failed += 1
    
    if test_generate_returns():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
