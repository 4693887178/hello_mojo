"""
第五组测试 - mod/rqmojo_mod_sys_analyser/report/__init__.mojo
测试Mojo版本的报告模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report import StrategyResult, Report, create_report
from rqmojo.mod.rqmojo_mod_sys_analyser.report import ExcelTemplate, generate_csv_content, generate_summary_csv
from rqmojo.utils.typing import DateTime


def test_strategy_result_creation() -> Bool:
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var ed = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var result = StrategyResult(
        start_date=sd^,
        end_date=ed^,
        total_returns=0.1,
        annual_returns=0.1,
        max_drawdown=0.05,
        sharpe_ratio=1.5,
        total_trades=100,
        win_rate=0.6,
        profit_loss_ratio=2.0
    )
    return result.total_returns == 0.1


def test_strategy_result_to_dict() -> Bool:
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var ed = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var result = StrategyResult(
        start_date=sd^,
        end_date=ed^,
        total_returns=0.1,
        annual_returns=0.1,
        max_drawdown=0.05,
        sharpe_ratio=1.5,
        total_trades=100,
        win_rate=0.6,
        profit_loss_ratio=2.0
    )
    var d = result.to_dict()
    return "total_returns" in d


def test_report_creation() -> Bool:
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var ed = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var result = StrategyResult(
        start_date=sd^,
        end_date=ed^,
        total_returns=0.1,
        annual_returns=0.1,
        max_drawdown=0.05,
        sharpe_ratio=1.5,
        total_trades=100,
        win_rate=0.6,
        profit_loss_ratio=2.0
    )
    var report = Report(
        strategy_name="test_strategy",
        result=result^,
        daily_returns=List[Float64](),
        nav_list=List[Float64](),
        trade_list=List[Dict[String, String]]()
    )
    return report.strategy_name == "test_strategy"


def test_report_generate_summary() -> Bool:
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var ed = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var result = StrategyResult(
        start_date=sd^,
        end_date=ed^,
        total_returns=0.1,
        annual_returns=0.1,
        max_drawdown=0.05,
        sharpe_ratio=1.5,
        total_trades=100,
        win_rate=0.6,
        profit_loss_ratio=2.0
    )
    var report = Report(
        strategy_name="test_strategy",
        result=result^,
        daily_returns=List[Float64](),
        nav_list=List[Float64](),
        trade_list=List[Dict[String, String]]()
    )
    var summary = report.generate_summary()
    return summary.find("test_strategy") >= 0


def test_create_report() -> Bool:
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.03)
    nav_list.append(1.08)
    
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var ed = DateTime(2020, 12, 31, 0, 0, 0, 0)
    
    var report = create_report(
        strategy_name="test",
        nav_list=nav_list^,
        start_date=sd^,
        end_date=ed^,
        total_trades=10,
        win_count=6,
        loss_count=4
    )
    return report.strategy_name == "test"


def test_excel_template_constants() -> Bool:
    return ExcelTemplate.SHEET_SUMMARY == "Summary" and ExcelTemplate.SHEET_TRADES == "Trades"


def test_generate_csv_content() -> Bool:
    var headers = List[String]()
    headers.append("Name")
    headers.append("Value")
    
    var rows = List[List[String]]()
    var row = List[String]()
    row.append("Test")
    row.append("100")
    rows.append(row^)
    
    var content = generate_csv_content(headers, rows)
    return content.find("Name") >= 0


def test_generate_summary_csv() raises -> Bool:
    var data = Dict[String, String]()
    data["total_returns"] = "10%"
    data["sharpe"] = "1.5"
    
    var content = generate_summary_csv(data)
    return content.find("Metric") >= 0


def main() raises:
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_analyser/report/__init__.mojo")
    print("=" * 60)
    
    if test_strategy_result_creation():
        print("PASS: test_strategy_result_creation")
        passed += 1
    else:
        print("FAIL: test_strategy_result_creation")
        failed += 1
    
    if test_strategy_result_to_dict():
        print("PASS: test_strategy_result_to_dict")
        passed += 1
    else:
        print("FAIL: test_strategy_result_to_dict")
        failed += 1
    
    if test_report_creation():
        print("PASS: test_report_creation")
        passed += 1
    else:
        print("FAIL: test_report_creation")
        failed += 1
    
    if test_report_generate_summary():
        print("PASS: test_report_generate_summary")
        passed += 1
    else:
        print("FAIL: test_report_generate_summary")
        failed += 1
    
    if test_create_report():
        print("PASS: test_create_report")
        passed += 1
    else:
        print("FAIL: test_create_report")
        failed += 1
    
    if test_excel_template_constants():
        print("PASS: test_excel_template_constants")
        passed += 1
    else:
        print("FAIL: test_excel_template_constants")
        failed += 1
    
    if test_generate_csv_content():
        print("PASS: test_generate_csv_content")
        passed += 1
    else:
        print("FAIL: test_generate_csv_content")
        failed += 1
    
    if test_generate_summary_csv():
        print("PASS: test_generate_summary_csv")
        passed += 1
    else:
        print("FAIL: test_generate_summary_csv")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
