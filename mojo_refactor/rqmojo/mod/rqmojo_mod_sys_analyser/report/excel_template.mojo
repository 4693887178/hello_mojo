from std.python import Python, PythonObject
from std.collections import List, Dict

comptime VALUE_NAME_RE: String = r"^#(?P<name>[a-z0-9_]+)#$"


def _py_none() raises -> PythonObject:
    var builtins = Python.import_module("builtins")
    return builtins.__getattr__("None")


def _py_is_truthy(obj: PythonObject) raises -> Bool:
    var builtins = Python.import_module("builtins")
    return Bool(py=builtins.bool(obj))


struct CellInfo(Copyable):
    var row: Int
    var column: Int
    var style: PythonObject

    def __init__(out self, row: Int, column: Int, style: PythonObject):
        self.row = row
        self.column = column
        self.style = style

    def __init__(out self, *, copy: Self):
        self.row = copy.row
        self.column = copy.column
        self.style = copy.style


struct SheetSchema:
    var _cell_map: Dict[String, CellInfo]

    def __init__(out self) raises:
        self._cell_map = Dict[String, CellInfo]()

    def __init__(out self, template_ws: PythonObject) raises:
        self._cell_map = Dict[String, CellInfo]()
        var re_mod = Python.import_module("re")
        var max_row = Int(py=template_ws.max_row)
        var max_col = Int(py=template_ws.max_column)

        for row_idx in range(1, max_row + 1):
            for col_idx in range(1, max_col + 1):
                var cell = template_ws.cell(row_idx, col_idx)
                var value: PythonObject = cell.value
                if _py_is_truthy(value):
                    var result = re_mod.match(VALUE_NAME_RE, value)
                    if _py_is_truthy(result):
                        var name = String(py=result.groupdict()["name"])
                        var style_obj = _py_none()
                        try:
                            style_obj = cell._style
                        except:
                            pass
                        self._cell_map[name] = CellInfo(row=row_idx, column=col_idx, style=style_obj)

    def fill_worksheet(self, ws: PythonObject, data: PythonObject) raises:
        raise Error("fill_worksheet must be implemented by subclass")

    def _write_cell(self, ws: PythonObject, row: Int, col: Int, data: PythonObject, style: PythonObject) raises:
        var np = Python.import_module("numpy")
        var pd = Python.import_module("pandas")
        var dt = Python.import_module("datetime")
        var builtins = Python.import_module("builtins")

        var write_data = data
        if not _py_is_truthy(data):
            write_data = np.nan
        else:
            try:
                if builtins.isinstance(data, dt.date):
                    if data is pd.NaT:
                        write_data = PythonObject("")
            except:
                pass

        var cell = ws.cell(row, col, write_data)
        if _py_is_truthy(style):
            cell._style = style


struct SingleCellSchema:
    var _base: SheetSchema

    def __init__(out self, template_ws: PythonObject) raises:
        self._base = SheetSchema(template_ws)

    def fill_worksheet(self, ws: PythonObject, data: PythonObject) raises:
        var builtins = Python.import_module("builtins")
        for key in self._base._cell_map.keys():
            var info = self._base._cell_map[key].copy()
            var val = _py_none()
            if builtins.hasattr(data, "get"):
                val = data.get(key, _py_none())
            self._base._write_cell(ws, info.row, info.column, val, _py_none())


struct VerticalSeriesSchema:
    var _base: SheetSchema

    def __init__(out self, template_ws: PythonObject) raises:
        self._base = SheetSchema(template_ws)

    def fill_worksheet(self, ws: PythonObject, data: PythonObject) raises:
        var builtins = Python.import_module("builtins")
        if not _py_is_truthy(data):
            for key in self._base._cell_map.keys():
                var info = self._base._cell_map[key].copy()
                self._base._write_cell(ws, info.row, info.column, _py_none(), info.style)
        else:
            for key in self._base._cell_map.keys():
                var info = self._base._cell_map[key].copy()
                var items_list: List[PythonObject] = List[PythonObject]()
                if builtins.hasattr(data, "get"):
                    var raw_items = data.get(key, Python.list())
                    items_list = _pylist_to_mojo_list(raw_items)
                for i in range(len(items_list)):
                    self._base._write_cell(ws, info.row + i, info.column, items_list[i], info.style)


def _pylist_to_mojo_list(py_list: PythonObject) raises -> List[PythonObject]:
    var result = List[PythonObject]()
    var length = len(py_list)
    for i in range(length):
        result.append(py_list[i])
    return result^


struct ExcelTemplate:
    comptime TEMPLATE_NAME: String = ""

    var _template_wb: PythonObject
    var _single_keys: List[String]
    var _vertical_keys: List[String]

    def __init__(out self, template_name: String) raises:
        var os_mod = Python.import_module("os")
        var openpyxl = Python.import_module("openpyxl")

        var base_path = "/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages/rqalpha/mod/rqalpha_mod_sys_analyser/report"
        var template_path = os_mod.path.join(base_path, "templates", template_name + ".xlsx")
        self._template_wb = openpyxl.load_workbook(template_path)
        self._single_keys = List[String]()
        self._vertical_keys = List[String]()
        var worksheets = self._template_wb.worksheets
        var ws_count = len(worksheets)
        for i in range(ws_count):
            var ws = worksheets[i]
            var title = String(py=ws.title)
            if title == "概览":
                self._single_keys.append(title)
            elif title == "年度指标" or title == "月度收益" or title == "月度超额收益（几何）" or title == "个股权重" or title == "压力测试":
                self._vertical_keys.append(title)

    def new_workbook(self, data: PythonObject, filename: String) raises:
        var copy_code = Python.evaluate(
            "import copy\ndef _do_copy(wb):\n    return copy.copy(wb)\n_do_copy",
            file=True
        )
        var wb = copy_code(self._template_wb)
        var builtins = Python.import_module("builtins")
        for key in self._single_keys:
            var sheet_data: PythonObject = Python.dict()
            if builtins.hasattr(data, "get"):
                sheet_data = data.get(key, Python.dict())
            var ws = wb[key]
            var schema = SingleCellSchema(ws)
            schema.fill_worksheet(ws, sheet_data)
        for key in self._vertical_keys:
            var sheet_data: PythonObject = Python.dict()
            if builtins.hasattr(data, "get"):
                sheet_data = data.get(key, Python.dict())
            var ws = wb[key]
            var schema = VerticalSeriesSchema(ws)
            schema.fill_worksheet(ws, sheet_data)
        wb.save(filename)


def get_summary_template() raises -> ExcelTemplate:
    return ExcelTemplate(template_name="summary")


def generate_xlsx_reports(data: PythonObject, output_path: String) raises:
    """Generate XLSX report file using Python openpyxl.

    Ported from rqalpha/mod/rqalpha_mod_sys_analyser/report/excel_template.py::generate_xlsx_reports
    """
    var os_mod = Python.import_module("os")
    var tpl = get_summary_template()
    var out_file = String(py=os_mod.path.join(output_path, "summary.xlsx"))
    tpl.new_workbook(data, out_file)
