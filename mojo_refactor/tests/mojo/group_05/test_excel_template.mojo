"""
第五组测试 - mod/rqmojo_mod_sys_analyser/report/excel_template.mojo
测试Mojo版本的Excel模板模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report.excel_template import ExcelTemplate, generate_csv_content, generate_summary_csv


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_excel_template_constants() raises:
    assert_equal(ExcelTemplate.SHEET_SUMMARY, "Summary", "SHEET_SUMMARY should match")
    assert_equal(ExcelTemplate.SHEET_TRADES, "Trades", "SHEET_TRADES should match")


def test_generate_csv_content_empty() raises:
    var headers = List[String]()
    var rows = List[List[String]]()
    
    var content = generate_csv_content(headers, rows)
    assert_equal(content, "\n", "empty content should be newline")


def test_generate_csv_content_single_row() raises:
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
    assert_true(content.find("Value") >= 0, "should contain Value")


def test_generate_csv_content_multiple_rows() raises:
    var headers = List[String]()
    headers.append("Metric")
    headers.append("Value")
    
    var rows = List[List[String]]()
    
    var row1 = List[String]()
    row1.append("Returns")
    row1.append("10%")
    rows.append(row1^)
    
    var row2 = List[String]()
    row2.append("Sharpe")
    row2.append("1.5")
    rows.append(row2^)
    
    var content = generate_csv_content(headers, rows)
    assert_true(content.find("Returns") >= 0, "should contain Returns")
    assert_true(content.find("Sharpe") >= 0, "should contain Sharpe")


def test_generate_summary_csv() raises:
    var data = Dict[String, String]()
    data["total_returns"] = "10%"
    data["sharpe"] = "1.5"
    data["max_drawdown"] = "5%"
    
    var content = generate_summary_csv(data)
    assert_true(content.find("Metric") >= 0, "should contain Metric")
    assert_true(content.find("total_returns") >= 0, "should contain total_returns")


def test_generate_summary_csv_empty() raises:
    var data = Dict[String, String]()
    
    var content = generate_summary_csv(data)
    assert_true(content.find("Metric") >= 0, "should contain Metric")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
