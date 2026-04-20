"""
RQAlpha Mojo - Storage Interface
Ported from rqalpha/data/base_data_source/storage_interface.py

Defines abstract storage interface traits (equivalent to Python ABC classes)
and the DataArray columnar storage struct.
"""

from std.collections import List, Dict
from std.python import PythonObject
from std.utils import Variant
from rqmojo.data.base_data_source.deprecated import AbstractInstrumentStore


comptime ColumnData = Variant[List[Int], List[Float64]]


trait AbstractDayBarStore:
    def get_bars(mut self, order_book_id: String) raises -> PythonObject:
        ...

    def get_date_range(mut self, order_book_id: String) raises -> PythonObject:
        ...


trait AbstractCalendarStore:
    def get_trading_calendar(ref self) raises -> PythonObject:
        ...


trait AbstractDateSet:
    def contains(mut self, order_book_id: String, dates: List[Int]) raises -> Optional[List[Bool]]:
        ...


trait AbstractDividendStore:
    def get_dividend(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        ...


trait AbstractSimpleFactorStore:
    def get_factors(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        ...


struct DataArray(Movable, Copyable):
    var field_names: List[String]
    var columns: List[ColumnData]
    var _field_index: Dict[String, Int]

    def __init__(out self):
        self.field_names = List[String]()
        self.columns = List[ColumnData]()
        self._field_index = Dict[String, Int]()

    def __init__(out self, *, copy: Self):
        self.field_names = copy.field_names.copy()
        self.columns = List[ColumnData]()
        for col in copy.columns:
            self.columns.append(col)
        self._field_index = copy._field_index.copy()

    def build_index(mut self):
        self._field_index = Dict[String, Int]()
        for i in range(len(self.field_names)):
            self._field_index[self.field_names[i]] = i

    def column_index(ref self, field_name: String) -> Optional[Int]:
        try:
            return self._field_index[field_name]
        except:
            return None

    def get_int(ref self, field_name: String, row: Int) -> Optional[Int]:
        var idx = self.column_index(field_name)
        if idx is None:
            return None
        var col_ref = self.columns[idx.value()]
        if col_ref.isa[List[Int]]():
            if row < len(col_ref[List[Int]]):
                return col_ref[List[Int]][row]
        return None

    def get_float(ref self, field_name: String, row: Int) -> Optional[Float64]:
        var idx = self.column_index(field_name)
        if idx is None:
            return None
        var col_ref = self.columns[idx.value()]
        if col_ref.isa[List[Float64]]():
            if row < len(col_ref[List[Float64]]):
                return col_ref[List[Float64]][row]
        return None

    def row_count(ref self) -> Int:
        if len(self.columns) == 0:
            return 0
        var col_ref = self.columns[0]
        if col_ref.isa[List[Int]]():
            return len(col_ref[List[Int]])
        elif col_ref.isa[List[Float64]]():
            return len(col_ref[List[Float64]])
        return 0

    def is_empty(ref self) -> Bool:
        return len(self.columns) == 0

    def add_int_column(mut self, name: String, var data: List[Int]):
        self.field_names.append(name)
        self.columns.append(ColumnData(data^))
        self.build_index()

    def add_float_column(mut self, name: String, var data: List[Float64]):
        self.field_names.append(name)
        self.columns.append(ColumnData(data^))
        self.build_index()

    def slice(ref self, start: Int, end: Int) -> DataArray:
        var result = DataArray()
        for name in self.field_names:
            result.field_names.append(name)
        for col_idx in range(len(self.columns)):
            var col_ref = self.columns[col_idx]
            if col_ref.isa[List[Int]]():
                var sliced = List[Int]()
                var col_len = len(col_ref[List[Int]])
                var limit = min(end, col_len)
                for i in range(start, limit):
                    sliced.append(col_ref[List[Int]][i])
                result.columns.append(ColumnData(sliced^))
            elif col_ref.isa[List[Float64]]():
                var sliced = List[Float64]()
                var col_len = len(col_ref[List[Float64]])
                var limit = min(end, col_len)
                for i in range(start, limit):
                    sliced.append(col_ref[List[Float64]][i])
                result.columns.append(ColumnData(sliced^))
        result.build_index()
        return result^


def create_data_array() -> DataArray:
    return DataArray()
