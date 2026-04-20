"""
Test for data/base_data_source/storage_interface.mojo
Covers: AbstractDayBarStore, AbstractCalendarStore, AbstractDateSet,
        AbstractDividendStore, AbstractSimpleFactorStore traits,
        DataArray struct, and create_data_array factory.
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from std.collections import List, Dict
from std.python import Python, PythonObject
from std.utils import Variant

from rqmojo.data.base_data_source.storage_interface import (
    AbstractDayBarStore,
    AbstractCalendarStore,
    AbstractDateSet,
    AbstractDividendStore,
    AbstractSimpleFactorStore,
    DataArray,
    ColumnData,
    create_data_array,
)


struct MockDayBarStore(AbstractDayBarStore, Movable):
    var _bars_data: Dict[String, PythonObject]
    var _date_range_data: Dict[String, PythonObject]
    var _py: Python

    def __init__(out self):
        self._bars_data = Dict[String, PythonObject]()
        self._date_range_data = Dict[String, PythonObject]()
        self._py = Python()

    def get_bars(mut self, order_book_id: String) raises -> PythonObject:
        if order_book_id in self._bars_data:
            return self._bars_data[order_book_id]
        var np = self._py.import_module("numpy")
        return np.empty(0)

    def get_date_range(mut self, order_book_id: String) raises -> PythonObject:
        if order_book_id in self._date_range_data:
            return self._date_range_data[order_book_id]
        var result = self._py.list()
        result.append(20050104)
        result.append(20050104)
        return result^


struct MockCalendarStore(AbstractCalendarStore, Movable):
    var _calendar: PythonObject
    var _py: Python

    def __init__(out self) raises:
        self._py = Python()
        self._calendar = self._py.list()

    def get_trading_calendar(ref self) raises -> PythonObject:
        return self._calendar


struct MockDateSet(AbstractDateSet, Movable):
    var _data: Dict[String, List[Int]]
    var _has_key: Dict[String, Bool]

    def __init__(out self):
        self._data = Dict[String, List[Int]]()
        self._has_key = Dict[String, Bool]()

    def contains(mut self, order_book_id: String, dates: List[Int]) raises -> Optional[List[Bool]]:
        if not (order_book_id in self._has_key):
            return None
        var stored = self._data[order_book_id].copy()
        var stored_set = Dict[Int, Bool]()
        for d in stored:
            stored_set[d] = True
        var result = List[Bool]()
        for d in dates:
            if d in stored_set:
                result.append(True)
            else:
                result.append(False)
        return result^


struct MockDividendStore(AbstractDividendStore, Movable):
    var _dividends: Dict[String, PythonObject]
    var _py: Python

    def __init__(out self):
        self._dividends = Dict[String, PythonObject]()
        self._py = Python()

    def get_dividend(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        if order_book_id in self._dividends:
            return self._dividends[order_book_id]
        return None


struct MockSimpleFactorStore(AbstractSimpleFactorStore, Movable):
    var _factors: Dict[String, PythonObject]
    var _py: Python

    def __init__(out self):
        self._factors = Dict[String, PythonObject]()
        self._py = Python()

    def get_factors(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        if order_book_id in self._factors:
            return self._factors[order_book_id]
        return None


# --- AbstractDayBarStore trait tests ---

def test_abstract_day_bar_store_trait_exists() raises:
    var _ = MockDayBarStore()
    assert_true(True, "AbstractDayBarStore trait can be implemented")


def test_abstract_day_bar_store_has_get_bars() raises:
    var store = MockDayBarStore()
    var result = store.get_bars("NONEXIST")
    assert_true(result is not None, "get_bars should return a value")


def test_abstract_day_bar_store_has_get_date_range() raises:
    var store = MockDayBarStore()
    var result = store.get_date_range("NONEXIST")
    assert_true(result is not None, "get_date_range should return a value")


# --- AbstractCalendarStore trait tests ---

def test_abstract_calendar_store_trait_exists() raises:
    var store = MockCalendarStore()
    assert_true(True, "AbstractCalendarStore trait can be implemented")


def test_abstract_calendar_store_has_get_trading_calendar() raises:
    var store = MockCalendarStore()
    var result = store.get_trading_calendar()
    assert_true(result is not None, "get_trading_calendar should return a value")


# --- AbstractDateSet trait tests ---

def test_abstract_date_set_trait_exists() raises:
    var _ = MockDateSet()
    assert_true(True, "AbstractDateSet trait can be implemented")


def test_abstract_date_set_contains_returns_none_for_missing_key() raises:
    var store = MockDateSet()
    var result = store.contains("MISSING", [20200101])
    assert_true(result is None, "contains should return None for missing order_book_id")


def test_abstract_date_set_contains_returns_bool_list() raises:
    var store = MockDateSet()
    store._has_key["000001.XSHE"] = True
    store._data["000001.XSHE"] = [20200101, 20200102, 20200103]
    var result = store.contains("000001.XSHE", [20200101, 20200105])
    if result is None:
        raise "contains should not return None for existing key"
    assert_equal(len(result.value()), 2, "should return 2 bools")
    assert_true(result.value()[0], "20200101 should be in the set")
    assert_false(result.value()[1], "20200105 should not be in the set")


# --- AbstractDividendStore trait tests ---

def test_abstract_dividend_store_trait_exists() raises:
    var _ = MockDividendStore()
    assert_true(True, "AbstractDividendStore trait can be implemented")


def test_abstract_dividend_store_has_get_dividend() raises:
    var store = MockDividendStore()
    var result = store.get_dividend("MISSING")
    assert_true(result is None, "get_dividend should return None for missing key")


# --- AbstractSimpleFactorStore trait tests ---

def test_abstract_simple_factor_store_trait_exists() raises:
    var _ = MockSimpleFactorStore()
    assert_true(True, "AbstractSimpleFactorStore trait can be implemented")


def test_abstract_simple_factor_store_has_get_factors() raises:
    var store = MockSimpleFactorStore()
    var result = store.get_factors("MISSING")
    assert_true(result is None, "get_factors should return None for missing key")


# --- DataArray struct tests ---

def test_data_array_init() raises:
    var da = create_data_array()
    assert_true(da.is_empty(), "new DataArray should be empty")
    assert_equal(da.row_count(), 0, "new DataArray should have 0 rows")


def test_data_array_add_int_column() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(1)
    data.append(2)
    data.append(3)
    da.add_int_column("id", data^)
    assert_false(da.is_empty(), "DataArray should not be empty after adding column")
    assert_equal(da.row_count(), 3, "DataArray should have 3 rows")


def test_data_array_add_float_column() raises:
    var da = create_data_array()
    var data = List[Float64]()
    data.append(1.5)
    data.append(2.5)
    da.add_float_column("price", data^)
    assert_false(da.is_empty(), "DataArray should not be empty after adding column")
    assert_equal(da.row_count(), 2, "DataArray should have 2 rows")


def test_data_array_column_index() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(10)
    da.add_int_column("col_a", data^)
    var idx = da.column_index("col_a")
    assert_true(idx is not None, "col_a should be found")
    assert_equal(idx.value(), 0, "col_a should be at index 0")


def test_data_array_column_index_missing() raises:
    var da = create_data_array()
    var idx = da.column_index("nonexistent")
    assert_true(idx is None, "nonexistent column should return None")


def test_data_array_get_int() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(100)
    data.append(200)
    data.append(300)
    da.add_int_column("value", data^)
    var val = da.get_int("value", 0)
    assert_true(val is not None, "value at row 0 should exist")
    assert_equal(val.value(), 100, "value at row 0 should be 100")
    var val2 = da.get_int("value", 2)
    assert_true(val2 is not None, "value at row 2 should exist")
    assert_equal(val2.value(), 300, "value at row 2 should be 300")


def test_data_array_get_int_out_of_bounds() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(10)
    da.add_int_column("id", data^)
    var val = da.get_int("id", 5)
    assert_true(val is None, "out of bounds row should return None")


def test_data_array_get_int_missing_column() raises:
    var da = create_data_array()
    var val = da.get_int("missing", 0)
    assert_true(val is None, "missing column should return None")


def test_data_array_get_float() raises:
    var da = create_data_array()
    var data = List[Float64]()
    data.append(3.14)
    data.append(2.71)
    da.add_float_column("ratio", data^)
    var val = da.get_float("ratio", 0)
    assert_true(val is not None, "ratio at row 0 should exist")
    assert_equal(val.value(), 3.14, "ratio at row 0 should be 3.14")


def test_data_array_get_float_out_of_bounds() raises:
    var da = create_data_array()
    var data = List[Float64]()
    data.append(1.0)
    da.add_float_column("price", data^)
    var val = da.get_float("price", 10)
    assert_true(val is None, "out of bounds row should return None")


def test_data_array_get_float_missing_column() raises:
    var da = create_data_array()
    var val = da.get_float("missing", 0)
    assert_true(val is None, "missing column should return None")


def test_data_array_get_int_on_float_column() raises:
    var da = create_data_array()
    var data = List[Float64]()
    data.append(1.5)
    da.add_float_column("price", data^)
    var val = da.get_int("price", 0)
    assert_true(val is None, "get_int on float column should return None")


def test_data_array_get_float_on_int_column() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(42)
    da.add_int_column("count", data^)
    var val = da.get_float("count", 0)
    assert_true(val is None, "get_float on int column should return None")


def test_data_array_multiple_columns() raises:
    var da = create_data_array()
    var ids = List[Int]()
    ids.append(1)
    ids.append(2)
    ids.append(3)
    da.add_int_column("id", ids^)
    var prices = List[Float64]()
    prices.append(10.5)
    prices.append(20.5)
    prices.append(30.5)
    da.add_float_column("price", prices^)
    assert_equal(da.row_count(), 3, "should have 3 rows")
    var id_val = da.get_int("id", 1)
    assert_true(id_val is not None, "id at row 1 should exist")
    assert_equal(id_val.value(), 2, "id at row 1 should be 2")
    var price_val = da.get_float("price", 1)
    assert_true(price_val is not None, "price at row 1 should exist")
    assert_equal(price_val.value(), 20.5, "price at row 1 should be 20.5")


def test_data_array_build_index() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(1)
    da.add_int_column("col1", data^)
    var data2 = List[Int]()
    data2.append(2)
    da.add_int_column("col2", data2^)
    var idx1 = da.column_index("col1")
    var idx2 = da.column_index("col2")
    assert_true(idx1 is not None, "col1 should be found")
    assert_true(idx2 is not None, "col2 should be found")
    assert_equal(idx1.value(), 0, "col1 should be at index 0")
    assert_equal(idx2.value(), 1, "col2 should be at index 1")


def test_data_array_slice() raises:
    var da = create_data_array()
    var ids = List[Int]()
    ids.append(1)
    ids.append(2)
    ids.append(3)
    ids.append(4)
    ids.append(5)
    da.add_int_column("id", ids^)
    var sliced = da.slice(1, 3)
    assert_equal(sliced.row_count(), 2, "sliced should have 2 rows")
    var val0 = sliced.get_int("id", 0)
    assert_true(val0 is not None, "id at row 0 should exist")
    assert_equal(val0.value(), 2, "sliced row 0 should be 2")
    var val1 = sliced.get_int("id", 1)
    assert_true(val1 is not None, "id at row 1 should exist")
    assert_equal(val1.value(), 3, "sliced row 1 should be 3")


def test_data_array_slice_preserves_field_names() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(10)
    data.append(20)
    da.add_int_column("col_a", data^)
    var sliced = da.slice(0, 1)
    var idx = sliced.column_index("col_a")
    assert_true(idx is not None, "col_a should be found in sliced DataArray")


def test_data_array_slice_multiple_columns() raises:
    var da = create_data_array()
    var ids = List[Int]()
    ids.append(1)
    ids.append(2)
    ids.append(3)
    da.add_int_column("id", ids^)
    var prices = List[Float64]()
    prices.append(10.0)
    prices.append(20.0)
    prices.append(30.0)
    da.add_float_column("price", prices^)
    var sliced = da.slice(0, 2)
    assert_equal(sliced.row_count(), 2, "sliced should have 2 rows")
    var id_val = sliced.get_int("id", 0)
    assert_true(id_val is not None, "id at row 0 should exist")
    assert_equal(id_val.value(), 1, "sliced id at row 0 should be 1")
    var price_val = sliced.get_float("price", 1)
    assert_true(price_val is not None, "price at row 1 should exist")
    assert_equal(price_val.value(), 20.0, "sliced price at row 1 should be 20.0")


def test_data_array_slice_empty_range() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(1)
    data.append(2)
    da.add_int_column("id", data^)
    var sliced = da.slice(2, 2)
    assert_equal(sliced.row_count(), 0, "empty slice should have 0 rows")


def test_data_array_slice_beyond_end() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(1)
    data.append(2)
    da.add_int_column("id", data^)
    var sliced = da.slice(0, 100)
    assert_equal(sliced.row_count(), 2, "slice beyond end should clamp to data length")


def test_data_array_copy() raises:
    var da = create_data_array()
    var data = List[Int]()
    data.append(42)
    da.add_int_column("id", data^)
    var da_copy = da.copy()
    assert_equal(da_copy.row_count(), 1, "copy should have 1 row")
    var val = da_copy.get_int("id", 0)
    assert_true(val is not None, "id at row 0 should exist in copy")
    assert_equal(val.value(), 42, "copy id at row 0 should be 42")


def test_data_array_empty_row_count() raises:
    var da = create_data_array()
    assert_equal(da.row_count(), 0, "empty DataArray should have 0 rows")


def test_create_data_array_factory() raises:
    var da = create_data_array()
    assert_true(da.is_empty(), "factory-created DataArray should be empty")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
