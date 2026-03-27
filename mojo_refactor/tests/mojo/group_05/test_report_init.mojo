"""
第五组测试 - mod/rqmojo_mod_sys_analyser/report/__init__.mojo
测试Mojo版本的报告模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report import StrategyResult, Report, create_report
from rqmojo.mod.rqmojo_mod_sys_analyser.report import ExcelTemplate, generate_csv_content, generate_summary_csv
from rqmojo.utils.typing import DateTime


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_strategy_result_creation() raises:
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
    assert_equal(result.total_returns, 0.1, "total_returns should match")


def test_strategy_result_to_dict() raises:
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
    assert_true("total_returns" in d, "should contain total_returns")


def test_report_creation() raises:
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
    assert_equal(report.strategy_name, "test_strategy", "strategy_name should match")


def test_report_generate_summary() raises:
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
    assert_true(summary.find("test_strategy") >= 0, "should contain strategy name")


def test_create_report() raises:
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
    assert_equal(report.strategy_name, "test", "strategy_name should match")


def test_excel_template_constants() raises:
    assert_equal(ExcelTemplate.SHEET_SUMMARY, "Summary", "SHEET_SUMMARY should match")
    assert_equal(ExcelTemplate.SHEET_TRADES, "Trades", "SHEET_TRADES should match")


def test_generate_csv_content() raises:
    var headers = List[String]()
    headers.append("Name")
    headers.append("Value")
    
    var rows = List[List[String]]()
    var row = List[String]()
    row.append("Test")
    row.append("100")
    rows.append(row^)
    
    var content = generate_csv_content(headers, rows)
    assert_true(content.find("Name") >= 0, "should contain Name")


def test_generate_summary_csv() raises:
    var data = Dict[String, String]()
    data["total_returns"] = "10%"
    data["sharpe"] = "1.5"
    
    var content = generate_summary_csv(data)
    assert_true(content.find("Metric") >= 0, "should contain Metric")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
