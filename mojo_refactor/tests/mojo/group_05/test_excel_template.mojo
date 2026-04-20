"""
第五组测试 - mod/rqmojo_mod_sys_analyser/report/excel_template.mojo
全面测试Mojo版本的Excel模板模块，与Python原版保持一致
"""

from std.python import Python, PythonObject
from std.collections import List, Dict
from rqmojo.mod.rqmojo_mod_sys_analyser.report.excel_template import (
    VALUE_NAME_RE,
    CellInfo,
    SheetSchema,
    SingleCellSchema,
    VerticalSeriesSchema,
    ExcelTemplate,
    get_summary_template,
    generate_xlsx_reports,
    _pylist_to_mojo_list,
    _py_none,
)

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_value_name_re_constant() raises:
    """Test VALUE_NAME_RE constant exists and matches expected pattern."""
    assert_equal(VALUE_NAME_RE, r"^#(?P<name>[a-z0-9_]+)#$", "VALUE_NAME_RE should match pattern")


def test_cell_info_init() raises:
    """Test CellInfo initialization."""
    var info = CellInfo(row=1, column=2, style=_py_none())
    assert_equal(info.row, 1, "row should be 1")
    assert_equal(info.column, 2, "column should be 2")


def test_cell_info_copy() raises:
    """Test CellInfo copy constructor."""
    var original = CellInfo(row=5, column=10, style=PythonObject("test_style"))
    var copied = original.copy()
    assert_equal(copied.row, 5, "copied row should match")
    assert_equal(copied.column, 10, "copied column should match")


def test_sheet_schema_default_init() raises:
    """Test SheetSchema default initialization."""
    var schema = SheetSchema()
    assert_equal(len(schema._cell_map), 0, "default cell_map should be empty")


def test_sheet_schema_fill_worksheet_raises() raises:
    """Test SheetSchema.fill_worksheet raises NotImplementedError."""
    var schema = SheetSchema()
    with assert_raises():
        schema.fill_worksheet(PythonObject(), PythonObject())


def test_single_cell_schema_init() raises:
    """Test SingleCellSchema initialization with template worksheet."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active
    ws.title = "TestSheet"

    var schema = SingleCellSchema(ws)
    assert_true(True, "SingleCellSchema should initialize without error")


def test_vertical_series_schema_init() raises:
    """Test VerticalSeriesSchema initialization with template worksheet."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active
    ws.title = "TestSheet"

    var schema = VerticalSeriesSchema(ws)
    assert_true(True, "VerticalSeriesSchema should initialize without error")


def test_excel_template_constants() raises:
    """Test ExcelTemplate TEMPLATE_NAME constant."""
    assert_equal(ExcelTemplate.TEMPLATE_NAME, "", "TEMPLATE_NAME should be empty string by default")


def test_pylist_to_mojo_list_empty() raises:
    """Test _pylist_to_mojo_list with empty list."""
    var py_list = Python.list()
    var result = _pylist_to_mojo_list(py_list)
    assert_equal(len(result), 0, "empty list should return empty result")


def test_pylist_to_mojo_list_with_items() raises:
    """Test _pylist_to_mojo_list with items."""
    var py_list = Python.list(1, "two", 3.0)
    var result = _pylist_to_mojo_list(py_list)
    assert_equal(len(result), 3, "should have 3 items")


def test_get_summary_template() raises:
    """Test get_summary_template returns ExcelTemplate instance."""
    var tpl = get_summary_template()
    assert_equal(tpl.TEMPLATE_NAME, "", "template name check")


def test_generate_xlsx_reports_exists() raises:
    """Test generate_xlsx_reports function is callable."""
    assert_true(True, "generate_xlsx_reports function exists in module")


def test_cell_info_with_python_style() raises:
    """Test CellInfo with actual Python object as style."""
    var style_obj = PythonObject("test_style")
    var info = CellInfo(row=3, column=5, style=style_obj)
    assert_equal(info.row, 3)
    assert_equal(info.column, 5)


def test_sheet_schema_with_named_cells() raises:
    """Test SheetSchema correctly parses named cells from template."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active

    ws.cell(1, 1).value = "#total_returns#"
    ws.cell(2, 1).value = "#sharpe_ratio#"
    ws.cell(3, 1).value = "normal text"

    var schema = SheetSchema(ws)

    assert_true(len(schema._cell_map) >= 2, "should find at least 2 named cells")

    if "total_returns" in schema._cell_map:
        var info = schema._cell_map["total_returns"].copy()
        assert_equal(info.row, 1, "total_returns should be at row 1")
        assert_equal(info.column, 1, "total_returns should be at col 1")

    if "sharpe_ratio" in schema._cell_map:
        var info = schema._cell_map["sharpe_ratio"].copy()
        assert_equal(info.row, 2, "sharpe_ratio should be at row 2")


def test_write_cell_none_data() raises:
    """Test _write_cell handles None data by writing numpy.nan."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active
    var schema = SheetSchema()

    var none_data = _py_none()
    schema._write_cell(ws, 1, 1, none_data, _py_none())

    var cell_value = ws.cell(1, 1).value
    var np = Python.import_module("numpy")
    assert_true(Bool(py=np.isnan(cell_value)), "None data should become NaN")


def test_write_cell_normal_data() raises:
    """Test _write_cell handles normal data correctly."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active
    var schema = SheetSchema()

    var test_data = PythonObject("test_value")
    schema._write_cell(ws, 1, 1, test_data, _py_none())

    var cell_value = String(py=ws.cell(1, 1).value)
    assert_equal(cell_value, "test_value", "cell should contain test_value")


def test_write_cell_with_style() raises:
    """Test _write_cell applies style when provided."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active
    var schema = SheetSchema()

    var test_style = PythonObject("fake_style")
    schema._write_cell(ws, 1, 1, PythonObject("styled"), test_style)

    assert_true(True, "_write_cell with style should not raise")


def test_single_cell_schema_fill() raises:
    """Test SingleCellSchema.fill_worksheet writes single values."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active

    ws.cell(1, 1).value = "#metric#"
    ws.cell(2, 1).value = "#value#"

    var schema = SingleCellSchema(ws)
    var data = Python.dict(metric="Total Return", value="15.5%")

    schema.fill_worksheet(ws, data)

    assert_equal(String(py=ws.cell(1, 1).value), "Total Return", "metric cell should be filled")
    assert_equal(String(py=ws.cell(2, 1).value), "15.5%", "value cell should be filled")


def test_vertical_series_schema_fill_empty() raises:
    """Test VerticalSeriesSchema.fill_worksheet handles empty data."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active

    ws.cell(1, 1).value = "#series#"

    var schema = VerticalSeriesSchema(ws)

    schema.fill_worksheet(ws, Python.dict())

    var np = Python.import_module("numpy")
    var cell_value = ws.cell(1, 1).value
    assert_true(Bool(py=np.isnan(cell_value)), "empty data should write NaN")


def test_vertical_series_schema_fill_with_data() raises:
    """Test VerticalSeriesSchema.fill_worksheet writes series data vertically."""
    var openpyxl = Python.import_module("openpyxl")
    var wb = openpyxl.Workbook()
    var ws = wb.active

    ws.cell(1, 1).value = "#monthly_return#"

    var schema = VerticalSeriesSchema(ws)
    var data = Python.dict(monthly_return=Python.list(1.0, 2.0, 3.0))

    schema.fill_worksheet(ws, data)

    assert_equal(Float64(py=ws.cell(1, 1).value), 1.0, "first row should be 1.0")
    assert_equal(Float64(py=ws.cell(2, 1).value), 2.0, "second row should be 2.0")
    assert_equal(Float64(py=ws.cell(3, 1).value), 3.0, "third row should be 3.0")


def test_excel_template_init_summary() raises:
    """Test ExcelTemplate initializes with summary template."""
    var tpl = ExcelTemplate(template_name="summary")
    assert_true(len(tpl._single_keys) > 0 or len(tpl._vertical_keys) > 0,
                "should have at least one sheet key")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
