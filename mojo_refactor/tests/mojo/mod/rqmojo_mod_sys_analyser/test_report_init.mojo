"""
Mojo Test for mod/rqmojo_mod_sys_analyser/report/__init__.mojo
Tests the report module exports
TDD: Write tests first, then verify implementation
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report import StrategyResult, Report, create_report
from rqmojo.mod.rqmojo_mod_sys_analyser.report import ExcelTemplate, generate_csv_content, generate_summary_csv
from rqmojo.utils.datetime_func import DateTime


def test_excel_template_constants():
    print("ExcelTemplate.SHEET_SUMMARY: " + ExcelTemplate.SHEET_SUMMARY)
    print("ExcelTemplate.SHEET_TRADES: " + ExcelTemplate.SHEET_TRADES)
    print("ExcelTemplate.SHEET_DAILY: " + ExcelTemplate.SHEET_DAILY)
    print("ExcelTemplate.SHEET_POSITIONS: " + ExcelTemplate.SHEET_POSITIONS)
    assert ExcelTemplate.SHEET_SUMMARY == "Summary"
    assert ExcelTemplate.SHEET_TRADES == "Trades"


def test_generate_csv_content():
    var headers = List[String]()
    headers.append("Date")
    headers.append("Value")
    
    var rows = List[List[String]]()
    var row1 = List[String]()
    row1.append("2024-01-01")
    row1.append("1.0")
    rows.append(row1)
    
    var csv = generate_csv_content(headers, rows)
    print("CSV content: " + csv[:50] + "...")
    assert csv.contains("Date")
    assert csv.contains("Value")
    assert csv.contains("2024-01-01")


def test_generate_summary_csv():
    var result = Dict[String, String]()
    result["total_returns"] = "10.5%"
    result["sharpe"] = "1.25"
    
    var csv = generate_summary_csv(result)
    print("Summary CSV: " + csv[:50] + "...")
    assert csv.contains("Metric")
    assert csv.contains("Value")


def test_strategy_result_creation():
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var result = StrategyResult(
        start_date=start,
        end_date=end,
        total_returns=0.105,
        annual_returns=0.105,
        max_drawdown=0.08,
        sharpe_ratio=1.25,
        total_trades=100,
        win_rate=0.55,
        profit_loss_ratio=1.5
    )
    print("StrategyResult created")
    assert result.total_returns == 0.105


def test_strategy_result_to_dict():
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var result = StrategyResult(
        start_date=start,
        end_date=end,
        total_returns=0.105,
        annual_returns=0.105,
        max_drawdown=0.08,
        sharpe_ratio=1.25,
        total_trades=100,
        win_rate=0.55,
        profit_loss_ratio=1.5
    )
    
    var d = result.to_dict()
    print("StrategyResult dict keys: " + String(len(d.keys())))
    assert len(d.keys()) > 0
    assert d.contains("total_returns")


def test_report_creation():
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var result = StrategyResult(
        start_date=start,
        end_date=end,
        total_returns=0.105,
        annual_returns=0.105,
        max_drawdown=0.08,
        sharpe_ratio=1.25,
        total_trades=100,
        win_rate=0.55,
        profit_loss_ratio=1.5
    )
    
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.1)
    
    var report = Report(
        strategy_name="Test Strategy",
        result=result,
        daily_returns=List[Float64](),
        nav_list=nav_list,
        trade_list=List[Dict[String, String]]()
    )
    print("Report created: " + report.strategy_name)
    assert report.strategy_name == "Test Strategy"


def test_report_generate_summary():
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var result = StrategyResult(
        start_date=start,
        end_date=end,
        total_returns=0.105,
        annual_returns=0.105,
        max_drawdown=0.08,
        sharpe_ratio=1.25,
        total_trades=100,
        win_rate=0.55,
        profit_loss_ratio=1.5
    )
    
    var report = Report(
        strategy_name="Test Strategy",
        result=result,
        daily_returns=List[Float64](),
        nav_list=List[Float64](),
        trade_list=List[Dict[String, String]]()
    )
    
    var summary = report.generate_summary()
    print("Summary: " + summary[:100] + "...")
    assert summary.contains("Strategy Report")
    assert summary.contains("Test Strategy")


def test_create_report():
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.1)
    nav_list.append(1.08)
    nav_list.append(1.15)
    
    var report = create_report(
        strategy_name="My Strategy",
        nav_list=nav_list,
        start_date=start,
        end_date=end,
        total_trades=50,
        win_count=30,
        loss_count=20
    )
    
    print("Created report: " + report.strategy_name)
    print("Total returns: " + String(report.result.total_returns))
    print("Max drawdown: " + String(report.result.max_drawdown))
    
    assert report.strategy_name == "My Strategy"
    assert report.result.total_trades == 50


def main():
    print("=== Testing mod/rqmojo_mod_sys_analyser/report ===")
    test_excel_template_constants()
    test_generate_csv_content()
    test_generate_summary_csv()
    test_strategy_result_creation()
    test_strategy_result_to_dict()
    test_report_creation()
    test_report_generate_summary()
    test_create_report()
    print("All report tests passed!")
