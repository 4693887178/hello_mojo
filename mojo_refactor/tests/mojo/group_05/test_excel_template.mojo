"""
第五组测试 - mod/rqmojo_mod_sys_analyser/report/excel_template.mojo
测试Mojo版本的Excel模板模块
"""

from rqmojo.mod.rqmojo_mod_sys_analyser.report.excel_template import ExcelTemplate, generate_csv_content, generate_summary_csv


def test_excel_template_constants() -> Bool:
    return ExcelTemplate.SHEET_SUMMARY == "Summary" and ExcelTemplate.SHEET_TRADES == "Trades"


def test_generate_csv_content_empty() -> Bool:
    var headers = List[String]()
    var rows = List[List[String]]()
    
    var content = generate_csv_content(headers, rows)
    return content == "\n"


def test_generate_csv_content_single_row() -> Bool:
    var headers = List[String]()
    headers.append("Name")
    headers.append("Value")
    
    var rows = List[List[String]]()
    var row = List[String]()
    row.append("Test")
    row.append("100")
    rows.append(row^)
    
    var content = generate_csv_content(headers, rows)
    return content.find("Name") >= 0 and content.find("Value") >= 0


def test_generate_csv_content_multiple_rows() -> Bool:
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
    return content.find("Returns") >= 0 and content.find("Sharpe") >= 0


def test_generate_summary_csv() raises -> Bool:
    var data = Dict[String, String]()
    data["total_returns"] = "10%"
    data["sharpe"] = "1.5"
    data["max_drawdown"] = "5%"
    
    var content = generate_summary_csv(data)
    return content.find("Metric") >= 0 and content.find("total_returns") >= 0


def test_generate_summary_csv_empty() raises -> Bool:
    var data = Dict[String, String]()
    
    var content = generate_summary_csv(data)
    return content.find("Metric") >= 0


def main() raises:
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_analyser/report/excel_template.mojo")
    print("=" * 60)
    
    if test_excel_template_constants():
        print("PASS: test_excel_template_constants")
        passed += 1
    else:
        print("FAIL: test_excel_template_constants")
        failed += 1
    
    if test_generate_csv_content_empty():
        print("PASS: test_generate_csv_content_empty")
        passed += 1
    else:
        print("FAIL: test_generate_csv_content_empty")
        failed += 1
    
    if test_generate_csv_content_single_row():
        print("PASS: test_generate_csv_content_single_row")
        passed += 1
    else:
        print("FAIL: test_generate_csv_content_single_row")
        failed += 1
    
    if test_generate_csv_content_multiple_rows():
        print("PASS: test_generate_csv_content_multiple_rows")
        passed += 1
    else:
        print("FAIL: test_generate_csv_content_multiple_rows")
        failed += 1
    
    if test_generate_summary_csv():
        print("PASS: test_generate_summary_csv")
        passed += 1
    else:
        print("FAIL: test_generate_summary_csv")
        failed += 1
    
    if test_generate_summary_csv_empty():
        print("PASS: test_generate_summary_csv_empty")
        passed += 1
    else:
        print("FAIL: test_generate_summary_csv_empty")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
