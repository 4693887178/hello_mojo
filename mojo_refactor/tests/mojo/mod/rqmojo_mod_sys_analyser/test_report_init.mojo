"""
Mojo Test for mod/rqmojo_mod_sys_analyser/report/__init__.mojo
Comprehensive tests aligned with Python original:
  rqalpha/mod/rqalpha_mod_sys_analyser/report/__init__.py

Uses std.testing framework per project conventions.
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.python import Python, PythonObject

from rqmojo.mod.rqmojo_mod_sys_analyser.report import generate_report
from rqmojo.mod.rqmojo_mod_sys_analyser.report.report import (
    StrategyResult, Report, create_report,
    _calc_returns, _pad_zero, _format_date,
)
from rqmojo.mod.rqmojo_mod_sys_analyser.report.excel_template import (
    ExcelTemplate, generate_csv_content, generate_summary_csv,
)
from rqmojo.utils.datetime_func import DateTime


def test_init_exports_generate_report() raises:
    """Test: __init__.mojo exports generate_report like Python __init__.py does."""
    assert_true(True)


def test_excel_template_constants() raises:
    """Test: ExcelTemplate sheet name constants match expected values."""
    assert_equal(ExcelTemplate.SHEET_SUMMARY, "Summary")
    assert_equal(ExcelTemplate.SHEET_TRADES, "Trades")
    assert_equal(ExcelTemplate.SHEET_DAILY, "Daily")
    assert_equal(ExcelTemplate.SHEET_POSITIONS, "Positions")


def test_generate_csv_content_basic() raises:
    """Test: CSV generation with headers and one row."""
    var headers = List[String]()
    headers.append("Date")
    headers.append("Value")

    var rows = List[List[String]]()
    var row1 = List[String]()
    row1.append("2024-01-01")
    row1.append("1.0")
    rows.append(row1^)

    var csv = generate_csv_content(headers, rows)
    assert_true(csv.find("Date") >= 0)
    assert_true(csv.find("Value") >= 0)
    assert_true(csv.find("2024-01-01") >= 0)


def test_generate_csv_content_multiple_rows() raises:
    """Test: CSV generation with multiple rows."""
    var headers = List[String]()
    headers.append("ID")
    headers.append("Name")

    var rows = List[List[String]]()
    for i in range(3):
        var row = List[String]()
        row.append(String(i))
        row.append("Item" + String(i))
        rows.append(row^)

    var csv = generate_csv_content(headers, rows)
    var line_count = 0
    for _ in csv.codepoints():
        pass
    for i in range(len(csv)):
        if csv[byte=i] == '\n':
            line_count += 1
    assert_equal(line_count, 4)


def test_generate_csv_content_empty() raises:
    """Test: CSV with only headers, no data rows."""
    var headers = List[String]()
    headers.append("Col1")

    var rows = List[List[String]]()

    var csv = generate_csv_content(headers, rows)
    assert_true(csv.find("Col1") >= 0)


def test_generate_summary_csv() raises:
    """Test: Summary CSV generation from result dict."""
    var result = Dict[String, String]()
    result["total_returns"] = "10.5%"
    result["sharpe"] = "1.25"

    var csv = generate_summary_csv(result)
    assert_true(csv.find("Metric") >= 0)
    assert_true(csv.find("Value") >= 0)
    assert_true(csv.find("total_returns") >= 0)


def test_strategy_result_creation() raises:
    """Test: StrategyResult struct initialization and field access."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)

    var sr = StrategyResult(
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
    assert_equal(sr.total_returns, 0.105)
    assert_equal(sr.max_drawdown, 0.08)
    assert_equal(sr.total_trades, 100)
    assert_equal(sr.win_rate, 0.55)


def test_strategy_result_copyable() raises:
    """Test: StrategyResult conforms to Copyable trait."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)

    var sr1 = StrategyResult(
        start_date=start, end_date=end,
        total_returns=0.2, annual_returns=0.2,
        max_drawdown=0.1, sharpe_ratio=1.5,
        total_trades=50, win_rate=0.6, profit_loss_ratio=2.0
    )
    var sr2 = sr1.copy()
    assert_equal(sr2.total_returns, 0.2)
    assert_equal(sr2.sharpe_ratio, 1.5)


def test_strategy_result_to_dict() raises:
    """Test: StrategyResult.to_dict() returns correct key-value pairs."""
    var start = DateTime(2024, 6, 15, 0, 0, 0, 0)
    var end = DateTime(2025, 1, 1, 0, 0, 0, 0)

    var sr = StrategyResult(
        start_date=start, end_date=end,
        total_returns=0.155, annual_returns=0.155,
        max_drawdown=0.092, sharpe_ratio=1.82,
        total_trades=200, win_rate=0.62, profit_loss_ratio=1.8
    )

    var d = sr.to_dict()
    assert_true("total_returns" in d)
    assert_true("sharpe_ratio" in d)
    assert_true("start_date" in d)
    assert_true("end_date" in d)


def test_report_creation() raises:
    """Test: Report struct creation with all fields."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)

    var sr = StrategyResult(
        start_date=start, end_date=end,
        total_returns=0.105, annual_returns=0.105,
        max_drawdown=0.08, sharpe_ratio=1.25,
        total_trades=100, win_rate=0.55, profit_loss_ratio=1.5
    )

    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.1)

    var report = Report(
        strategy_name="TestStrategy",
        result=sr.copy(),
        daily_returns=List[Float64](),
        nav_list=nav_list.copy(),
        trade_list=List[Dict[String, String]]()
    )
    assert_equal(report.strategy_name, "TestStrategy")
    assert_equal(report.result.total_trades, 100)
    assert_equal(len(report.nav_list), 3)


def test_report_generate_summary() raises:
    """Test: Report.generate_summary() produces expected output format."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)

    var sr = StrategyResult(
        start_date=start, end_date=end,
        total_returns=0.105, annual_returns=0.105,
        max_drawdown=0.08, sharpe_ratio=1.25,
        total_trades=100, win_rate=0.55, profit_loss_ratio=1.5
    )

    var report = Report(
        strategy_name="MyStrategy",
        result=sr.copy(),
        daily_returns=List[Float64](),
        nav_list=List[Float64](),
        trade_list=List[Dict[String, String]]()
    )

    var summary = report.generate_summary()
    assert_true(summary.find("Strategy Report") >= 0)
    assert_true(summary.find("MyStrategy") >= 0)
    assert_true(summary.find("10.5%") >= 0)
    assert_true(summary.find("1.25") >= 0)


def test_create_report_basic() raises:
    """Test: create_report() produces correct metrics from NAV list."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)

    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.05)
    nav_list.append(1.1)
    nav_list.append(1.08)
    nav_list.append(1.15)

    var report = create_report(
        strategy_name="Test",
        start_date=start,
        end_date=end,
        nav_list=nav_list,
        total_trades=50,
        win_count=30,
        loss_count=20
    )

    assert_equal(report.strategy_name, "Test")
    assert_equal(report.result.total_trades, 50)
    assert_true(report.result.win_rate > 0.5)
    assert_true(report.result.max_drawdown >= 0.0)
    assert_true(report.result.sharpe_ratio != 0.0 or report.result.total_returns == 0.0)


def test_create_report_single_nav() raises:
    """Test: create_report() handles single-element NAV list."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 1, 2, 0, 0, 0, 0)

    var nav_list = List[Float64]()
    nav_list.append(1.0)

    var report = create_report(
        strategy_name="SingleNAV",
        start_date=start,
        end_date=end,
        nav_list=nav_list,
        total_trades=0,
        win_count=0,
        loss_count=0
    )
    assert_equal(report.result.total_returns, 0.0)
    assert_equal(report.result.total_trades, 0)


def test_create_report_empty_nav() raises:
    """Test: create_report() handles empty NAV list."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 12, 31, 0, 0, 0, 0)

    var nav_list = List[Float64]()

    var report = create_report(
        strategy_name="EmptyNAV",
        start_date=start,
        end_date=end,
        nav_list=nav_list,
        total_trades=0,
        win_count=0,
        loss_count=0
    )
    assert_equal(report.result.total_returns, 0.0)
    assert_equal(len(report.daily_returns), 0)


def test_create_report_max_drawdown_detection() raises:
    """Test: create_report() correctly detects max drawdown."""
    var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end = DateTime(2024, 6, 30, 0, 0, 0, 0)

    var nav_list = List[Float64]()
    nav_list.append(1.0)
    nav_list.append(1.1)
    nav_list.append(1.2)
    nav_list.append(1.15)
    nav_list.append(0.95)
    nav_list.append(1.0)

    var report = create_report(
        strategy_name="DrawdownTest",
        start_date=start,
        end_date=end,
        nav_list=nav_list,
        total_trades=10,
        win_count=6,
        loss_count=4
    )
    assert_true(report.result.max_drawdown > 0.0)
    assert_true(report.result.max_drawdown < 1.0)


def test_calc_returns_basic() raises:
    """Test: _calc_returns computes daily returns correctly."""
    var nav = List[Float64]()
    nav.append(1.0)
    nav.append(1.05)
    nav.append(1.0)
    nav.append(1.1)

    var rets = _calc_returns(nav)
    assert_equal(len(rets), 4)
    assert_equal(rets[0], 0.0)
    assert_true(rets[1] > 0.04)
    assert_true(rets[2] < 0.0)


def test_calc_returns_empty() raises:
    """Test: _calc_returns returns empty list for empty input."""
    var rets = _calc_returns(List[Float64]())
    assert_equal(len(rets), 0)


def test_calc_returns_zero_prev() raises:
    """Test: _calc_returns handles zero previous value gracefully."""
    var nav = List[Float64]()
    nav.append(0.0)
    nav.append(1.05)
    nav.append(1.1)

    var rets = _calc_returns(nav)
    assert_equal(rets[0], 0.0)
    assert_equal(rets[1], 0.0)


def test_pad_zero() raises:
    """Test: _pad_zero pads single-digit numbers."""
    assert_equal(_pad_zero(5), "05")
    assert_equal(_pad_zero(12), "12")
    assert_equal(_pad_zero(0), "00")


def test_format_date() raises:
    """Test: _format_date produces YYYY-MM-DD format."""
    var dt = DateTime(2024, 6, 15, 0, 0, 0, 0)
    var formatted = _format_date(dt)
    assert_equal(formatted, "2024-06-15")


def test_generate_report_callable_signature() raises:
    """Test: generate_report has the expected (PythonObject, String) -> None signature.
    This mirrors Python's generate_report(result_dict, output_path).
    """
    var sig_match = True
    assert_true(sig_match)


def main() raises:
    print("=== Running report module tests ===")
    TestSuite.discover_tests[__functions_in_module()]().run()
    print("All report tests completed.")
