"""Bison (pandas-like) library integration test for RQAlpha Mojo refactor."""
from std.python import Python, PythonObject
from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false

from bison import (
    DataFrame,
    Series,
    ColumnData,
    Index,
    BisonDtype,
    int64,
    float64,
)


def test_bison_import() raises:
    """Test 1: Verify bison can be imported and version is accessible."""
    from bison import __version__
    print("[PASS] bison imported successfully, version: " + __version__)


def test_dataframe_from_dict() raises:
    """Test 2: Create DataFrame from dict (pure Mojo, no Python needed)."""
    var d = Dict[String, ColumnData]()
    var col_a = List[Int64]()
    col_a.append(1)
    col_a.append(2)
    col_a.append(3)
    var col_b = List[Float64]()
    col_b.append(4.0)
    col_b.append(5.0)
    col_b.append(6.0)
    d["a"] = ColumnData(col_a^)
    d["b"] = ColumnData(col_b^)

    var df = DataFrame.from_dict(d)
    assert_equal(df.shape()[0], 3)
    assert_equal(df.shape()[1], 2)
    assert_equal(df.columns()[0], "a")
    assert_equal(df.columns()[1], "b")
    print("[PASS] DataFrame.from_dict works: shape=3x2")


def test_dataframe_from_pandas() raises:
    """Test 3: Create DataFrame wrapping a pandas DataFrame via interop."""
    var pd = Python.import_module("pandas")
    var pd_df = pd.DataFrame(Python.evaluate("{'open': [10.0, 20.0, 30.0], 'close': [11.0, 21.0, 31.0]}"))
    var df = DataFrame(pd_df)

    assert_equal(df.shape()[0], 3)
    assert_equal(df.shape()[1], 2)
    assert_equal(df.ndim(), 2)
    assert_equal(df.size(), 6)
    assert_false(df.empty())
    print("[PASS] DataFrame from pandas works: shape=3x2")


def test_series_from_pandas() raises:
    """Test 4: Create Series wrapping a pandas Series."""
    var pd = Python.import_module("pandas")
    var pd_s = pd.Series(Python.evaluate("[100.0, 200.0, 300.0]"), name="price")
    var s = Series(pd_s)

    assert_equal(s.__len__(), 3)
    assert_equal(s.size(), 3)
    assert_equal(s.name.value(), "price")
    assert_false(s.empty())
    print("[PASS] Series from pandas works: name=price, len=3")


def test_series_aggregation() raises:
    """Test 5: Series aggregation methods (sum, mean, min, max)."""
    var pd = Python.import_module("pandas")
    var pd_s = pd.Series(Python.evaluate("[10.0, 20.0, 30.0, 40.0, 50.0]"))
    var s = Series(pd_s)

    assert_true(s.sum() == 150.0)
    print("[PASS] Series.sum() = 150.0")

    assert_true(s.mean() == 30.0)
    print("[PASS] Series.mean() = 30.0")

    assert_true(s.min() == 10.0)
    assert_true(s.max() == 50.0)


def test_dataframe_column_access() raises:
    """Test 6: DataFrame column selection and indexing."""
    var pd = Python.import_module("pandas")
    var pd_df = pd.DataFrame(Python.evaluate("{'high': [15.0, 25.0], 'low': [8.0, 18.0], 'volume': [1000, 2000]}"))
    var df = DataFrame(pd_df)

    var high_col = df["high"]
    assert_equal(high_col.size(), 2)

    assert_true(df.__contains__("high"))
    assert_true(df.__contains__("low"))
    assert_true(df.__contains__("volume"))
    assert_false(df.__contains__("nonexistent"))
    print("[PASS] DataFrame column access works")


def test_dataframe_aggregation() raises:
    """Test 7: DataFrame aggregation (sum per column)."""
    var pd = Python.import_module("pandas")
    var pd_df = pd.DataFrame(Python.evaluate("{'a': [1.0, 2.0, 3.0], 'b': [4.0, 5.0, 6.0]}"))
    var df = DataFrame(pd_df)

    var totals = df.sum()
    print("[PASS] DataFrame.sum() works")

    var means = df.mean()
    print("[PASS] DataFrame.mean() works")


def test_roundtrip_pandas() raises:
    """Test 8: DataFrame/Series roundtrip to pandas and back."""
    var pd = Python.import_module("pandas")
    var pd_df = pd.DataFrame(Python.evaluate("{'x': [1, 2, 3]}"))
    var df = DataFrame.from_pandas(pd_df)
    var back = df.to_pandas()
    assert_equal(back.__len__(), 3)

    var pd_s = pd.Series(Python.evaluate("[7, 8, 9]"))
    var s = Series(pd_s)
    var s_back = s.to_pandas()
    assert_equal(s_back.__len__(), 3)
    print("[PASS] Pandas roundtrip works for both DataFrame and Series")


def main() raises:
    print("=" * 60)
    print("Bison Library Integration Test")
    print("=" * 60)

    test_bison_import()
    test_dataframe_from_dict()
    test_dataframe_from_pandas()
    test_series_from_pandas()
    test_series_aggregation()
    test_dataframe_column_access()
    test_dataframe_aggregation()
    test_roundtrip_pandas()

    print("=" * 60)
    print("All 8 tests PASSED!")
    print("=" * 60)
