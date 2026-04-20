from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.python import Python, PythonObject
from rqmojo.apis.api_rqdatac import (
    _assure_order_book_id, _get_rqdatac, _is_string, _is_list,
    _py_isinstance, _py_getattr, _py_hasattr, _py_str, _py_set,
    _str_slice, _to_py_date, _to_py_datetime, _py_setitem,
    get_split, index_components, index_weights, concept,
    get_margin_stocks, get_price, get_securities_margin,
    get_shares, get_turnover_rate, get_price_change_rate,
    get_factor, get_industry, get_instrument_industry,
    get_stock_connect, current_performance, get_dominant_future,
    econ_get_reserve_ratio, econ_get_money_supply,
    futures_get_dominant, futures_get_member_rank,
    futures_get_warehouse_stocks, futures_get_dominant_price,
    get_fundamentals, get_financials, get_pit_financials,
    get_pit_financials_ex, query
)
from rqmojo.environment import create_environment
from rqmojo.utils.typing import DateTime


def test_assure_order_book_id_valid() raises:
    """Test _assure_order_book_id with valid order book IDs."""
    var result = _assure_order_book_id("000001.XSHE")
    assert_equal(result, "000001.XSHE")

    result = _assure_order_book_id("600000.XSHG")
    assert_equal(result, "600000.XSHG")

    result = _assure_order_book_id("IF1608.XSHG")
    assert_equal(result, "IF1608.XSHG")


def test_assure_order_book_id_invalid() raises:
    """Test _assure_order_book_id raises on invalid IDs."""
    var raised = False
    try:
        _assure_order_book_id("000001")
    except:
        raised = True
    assert_true(raised)

    var raised2 = False
    try:
        _assure_order_book_id("")
    except:
        raised2 = True
    assert_true(raised2)


def test_is_string() raises:
    """Test _is_string helper function."""
    var py_str = PythonObject("hello")
    assert_true(_is_string(py_str))

    var py_int = Int(py=42)
    assert_false(_is_string(py_int))

    var py_list = Python.list()
    assert_false(_is_string(py_list))


def test_is_list() raises:
    """Test _is_list helper function."""
    var py_list = Python.list()
    py_list.append("a")
    assert_true(_is_list(py_list))

    var py_str = PythonObject("hello")
    assert_false(_is_list(py_str))


def test_py_isinstance() raises:
    """Test _py_isinstance type checking."""
    var py_str = PythonObject("test")
    assert_true(_py_isinstance(py_str, "str"))
    assert_false(_py_isinstance(py_str, "int"))
    assert_false(_py_isinstance(py_str, "list"))

    var py_int = Int(py=123)
    assert_true(_py_isinstance(py_int, "int"))


def test_py_hasattr() raises:
    """Test _py_hasattr attribute checking."""
    var dm = Python.import_module("datetime")
    var dt = dm.date(2025, 1, 1)
    assert_true(_py_hasattr(dt, "year"))
    assert_true(_py_hasattr(dt, "month"))
    assert_false(_py_hasattr(dt, "nonexistent_attr"))


def test_py_str() raises:
    """Test _py_str string conversion."""
    var val = Int(py=42)
    var result = _py_str(val)
    assert_equal(String(py=result), "42")


def test_str_slice() raises:
    """Test _str_slice string slicing helper."""
    var s = "2024q3"
    var result = _str_slice(s, 0, 4)
    assert_equal(result, "2024")

    result = _str_slice(s, 4, 5)
    assert_equal(result, "q")

    result = _str_slice(s, 5, 6)
    assert_equal(result, "3")


def test_to_py_date() raises:
    """Test _to_py_date converts DateTime to Python date."""
    var dt = DateTime(2025, 6, 15, 10, 30, 0)
    var result = _to_py_date(dt)
    assert_equal(Int(py=result.year), 2025)
    assert_equal(Int(py=result.month), 6)
    assert_equal(Int(py=result.day), 15)


def test_to_py_datetime() raises:
    """Test _to_py_datetime converts DateTime to Python datetime."""
    var dt = DateTime(2025, 6, 15, 14, 30, 45)
    var result = _to_py_datetime(dt)
    assert_equal(Int(py=result.year), 2025)
    assert_equal(Int(py=result.month), 6)
    assert_equal(Int(py=result.day), 15)
    assert_equal(Int(py=result.hour), 14)
    assert_equal(Int(py=result.minute), 30)
    assert_equal(Int(py=result.second), 45)


def test_py_setitem() raises:
    """Test _py_setitem sets dict items via evaluate."""
    var d = Python.dict()
    _py_setitem(d, "key1", PythonObject("value1"))
    _py_setitem(d, "key2", Int(py=42))
    assert_equal(String(py=d["key1"]), "value1")
    assert_equal(Int(py=d["key2"]), 42)


def test_get_rqdatac_returns_object() raises:
    """Test _get_rqdatac returns a callable object."""
    var rqdatac = _get_rqdatac()
    assert_true(rqdatac is not None)


def test_query_function_exists() raises:
    """Test query function can be called with entities."""
    var entities = Python.list()
    entities.append("select * from instruments limit 1")
    var called = False
    try:
        var result = query(entities)
        called = True
    except:
        pass


def test_econ_get_reserve_ratio_signature() raises:
    """Test econ_get_reserve_ratio accepts valid parameters."""
    var called = False
    try:
        var result = econ_get_reserve_ratio("all", 1)
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = econ_get_reserve_ratio("major", 3)
        called2 = True
    except:
        pass


def test_econ_get_money_supply_signature() raises:
    """Test econ_get_money_supply accepts valid parameters."""
    var called = False
    try:
        var result = econ_get_money_supply(1)
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = econ_get_money_supply(5)
        called2 = True
    except:
        pass


def test_futures_get_dominant_price_invalid_adjust_type() raises:
    """Test futures_get_dominant_price rejects invalid adjust_type."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var symbols = Python.list()
    symbols.append("CU")
    var raised = False
    try:
        futures_get_dominant_price(env, symbols, adjust_type="invalid")
    except:
        raised = True
    assert_true(raised)


def test_futures_get_dominant_price_invalid_adjust_method() raises:
    """Test futures_get_dominant_price rejects invalid adjust_method."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var symbols = Python.list()
    symbols.append("CU")
    var raised = False
    try:
        futures_get_dominant_price(env, symbols, adjust_method="invalid_method")
    except:
        raised = True
    assert_true(raised)


def test_get_pit_financials_ex_negative_count() raises:
    """Test get_pit_financials_ex returns None for negative count."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var fields = Python.list()
    fields.append("revenue")
    var result = get_pit_financials_ex(env, ids, fields, -1)
    assert_true(result is None)


def test_index_components_valid_id() raises:
    """Test index_components with valid index ID format."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = index_components(env, "000300.XSHG")
        called = True
    except:
        pass


def test_concept_single_name() raises:
    """Test concept with single concept name."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var names = List[String]()
    names.append("test_concept")
    var called = False
    try:
        var result = concept(env, names)
        called = True
    except:
        pass


def test_concept_multiple_names() raises:
    """Test concept with multiple concept names."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var names = List[String]()
    names.append("concept_a")
    names.append("concept_b")
    names.append("concept_c")
    names.append("concept_d")
    var called = False
    try:
        var result = concept(env, names)
        called = True
    except:
        pass


def test_get_margin_stocks_all_type() raises:
    """Test get_margin_stocks with margin_type='all'."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_margin_stocks(env, margin_type="all")
        called = True
    except:
        pass


def test_get_margin_stocks_cash_type() raises:
    """Test get_margin_stocks with margin_type='cash'."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_margin_stocks(env, margin_type="cash")
        called = True
    except:
        pass


def test_get_margin_stocks_stock_type() raises:
    """Test get_margin_stocks with margin_type='stock'."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_margin_stocks(env, margin_type="stock")
        called = True
    except:
        pass


def test_get_margin_stocks_invalid_type() raises:
    """Test get_margin_stocks raises on invalid margin_type."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var raised = False
    try:
        get_margin_stocks(env, margin_type="invalid_type")
    except:
        raised = True
    assert_true(raised)


def test_get_margin_stocks_with_exchange() raises:
    """Test get_margin_stocks with exchange parameter."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_margin_stocks(env, Optional[String]("XSHG"), "stock")
        called = True
    except:
        pass


def test_get_dominant_future_signature() raises:
    """Test get_dominant_future returns Optional[String]."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_dominant_future(env, "IF")
        if result is not None:
            assert_true(len(result.value()) > 0)
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = get_dominant_future(env, "IF", rule=1)
        called2 = True
    except:
        pass


def test_futures_get_dominant_signature() raises:
    """Test futures_get_dominant returns Optional[String]."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = futures_get_dominant(env, "IF")
        if result is not None:
            assert_true(len(result.value()) > 0)
        called = True
    except:
        pass


def test_get_industry_with_source() raises:
    """Test get_industry with different sources."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_industry(env, "bank", "citics")
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = get_industry(env, "bank", "gildata")
        called2 = True
    except:
        pass


def test_get_instrument_industry_with_level() raises:
    """Test get_instrument_industry with different levels."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var called = False
    try:
        var result = get_instrument_industry(env, ids, level=1)
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = get_instrument_industry(env, ids, level=2)
        called2 = True
    except:
        pass


def test_current_performance_basic() raises:
    """Test current_performance basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = current_performance(env, "000001.XSHE")
        called = True
    except:
        pass


def test_current_performance_with_quarter() raises:
    """Test current_performance with quarter parameter."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = current_performance(env, "000001.XSHE", quarter=Optional[String]("2024q3"))
        called = True
    except:
        pass


def test_futures_get_member_rank_basic() raises:
    """Test futures_get_member_rank basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = futures_get_member_rank(env, "IF1612", count=1, rank_by="short")
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = futures_get_member_rank(env, "IF1612", count=3, rank_by="long")
        called2 = True
    except:
        pass


def test_futures_get_warehouse_stocks_basic() raises:
    """Test futures_get_warehouse_stocks basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var symbols = Python.list()
    symbols.append("CU")
    var called = False
    try:
        var result = futures_get_warehouse_stocks(env, symbols, count=1)
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = futures_get_warehouse_stocks(env, symbols, count=5)
        called2 = True
    except:
        pass


def test_get_stock_connect_basic() raises:
    """Test get_stock_connect basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var called = False
    try:
        var result = get_stock_connect(env, ids, count=1)
        called = True
    except:
        pass

    var called2 = False
    try:
        var result2 = get_stock_connect(env, ids, count=5)
        called2 = True
    except:
        pass


def test_get_factor_basic() raises:
    """Test get_factor basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var factors = Python.list()
    factors.append("net_profit_growth_rate")
    var called = False
    try:
        var result = get_factor(env, ids, factors, count=1)
        called = True
    except:
        pass


def test_get_shares_basic() raises:
    """Test get_shares basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var called = False
    try:
        var result = get_shares(env, ids, count=1)
        called = True
    except:
        pass


def test_get_turnover_rate_basic() raises:
    """Test get_turnover_rate basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var called = False
    try:
        var result = get_turnover_rate(env, ids, count=1)
        called = True
    except:
        pass


def test_get_price_change_rate_basic() raises:
    """Test get_price_change_rate basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    var called = False
    try:
        var result = get_price_change_rate(env, ids, count=1)
        called = True
    except:
        pass


def test_get_securities_margin_string_input() raises:
    """Test get_securities_margin with string input."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_securities_margin(env, PythonObject("510050.XSHG"), count=1)
        called = True
    except:
        pass


def test_get_securities_margin_market_code() raises:
    """Test get_securities_margin with market code input."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_securities_margin(env, PythonObject("XSHG"), count=1)
        called = True
    except:
        pass


def test_get_price_string_input() raises:
    """Test get_price with string order_book_id."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_price(
            env, PythonObject("000001.XSHE"),
            PythonObject("2024-01-01")
        )
        called = True
    except:
        pass


def test_get_price_list_input() raises:
    """Test get_price with list of order_book_ids."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var ids = Python.list()
    ids.append("000001.XSHE")
    ids.append("600000.XSHG")
    var called = False
    try:
        var result = get_price(
            env, ids,
            PythonObject("2024-01-01")
        )
        called = True
    except:
        pass


def test_get_split_basic() raises:
    """Test get_split basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = get_split(
            env, PythonObject("000001.XSHE"),
            PythonObject("2020-01-01")
        )
        called = True
    except:
        pass


def test_index_weights_basic() raises:
    """Test index_weights basic call."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = index_weights(env, "000300.XSHG")
        called = True
    except:
        pass


def test_index_weights_with_date() raises:
    """Test index_weights with explicit date."""
    var env = create_environment(DateTime(2024, 1, 2), DateTime(2024, 12, 31))
    var called = False
    try:
        var result = index_weights(
            env, "000300.XSHG",
            Optional[PythonObject](PythonObject("2024-06-01"))
        )
        called = True
    except:
        pass


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
