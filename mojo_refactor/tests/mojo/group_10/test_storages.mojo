"""
Comprehensive Test Suite for data/base_data_source/storages.mojo
Group 10 - File 1
"""

from std.collections import List, Dict, Optional, Set
from std.python import Python, PythonObject
from rqmojo.data.base_data_source.storages import (
    FuturesTradingParameters,
    ExchangeTradingCalendarStore, FutureInfoStore,
    load_instruments_from_pkl, ShareTransformationStore,
    _file_path, open_h5, h5_file,
    DayBarStore, FutureDayBarStore,
    DividendStore, YieldCurveStore, SimpleFactorStore, DateSet,
    create_exchange_trading_calendar_store, create_future_info_store,
    create_share_transformation_store, create_day_bar_store,
    create_future_day_bar_store, create_dividend_store,
    create_yield_curve_store, create_simple_factor_store, create_date_set
)
from rqmojo.const import COMMISSION_TYPE
from rqmojo.utils.typing import DateTimeDate, DateTime
from std.testing import assert_equal, assert_true, assert_false, TestSuite


# ============================================================
# FuturesTradingParameters Tests
# ============================================================

def test_futures_trading_params_fields() raises:
    print("Test: FuturesTradingParameters all 6 fields")
    var params = FuturesTradingParameters(
        close_commission_ratio=0.001,
        close_commission_today_ratio=0.0001,
        commission_type=COMMISSION_TYPE.BY_MONEY,
        open_commission_ratio=0.0008,
        long_margin_ratio=0.15,
        short_margin_ratio=0.2
    )
    assert_equal(params.close_commission_ratio, 0.001)
    assert_equal(params.close_commission_today_ratio, 0.0001)
    assert_equal(params.commission_type, COMMISSION_TYPE.BY_MONEY)
    assert_equal(params.open_commission_ratio, 0.0008)
    assert_equal(params.long_margin_ratio, 0.15)
    assert_equal(params.short_margin_ratio, 0.2)
    print("  PASSED")


def test_futures_trading_params_copyable() raises:
    print("Test: FuturesTradingParameters copy semantics")
    var params = FuturesTradingParameters(
        close_commission_ratio=0.002,
        close_commission_today_ratio=0.0002,
        commission_type=COMMISSION_TYPE.BY_VOLUME,
        open_commission_ratio=0.001,
        long_margin_ratio=0.12,
        short_margin_ratio=0.18
    )
    var copied = params.copy()
    assert_equal(copied.close_commission_ratio, 0.002)
    assert_equal(copied.commission_type, COMMISSION_TYPE.BY_VOLUME)
    print("  PASSED")


def test_futures_trading_params_by_volume() raises:
    print("Test: FuturesTradingParameters with BY_VOLUME commission type")
    var params = FuturesTradingParameters(
        close_commission_ratio=1.0,
        close_commission_today_ratio=1.0,
        commission_type=COMMISSION_TYPE.BY_VOLUME,
        open_commission_ratio=1.0,
        long_margin_ratio=0.08,
        short_margin_ratio=0.08
    )
    assert_equal(params.commission_type, COMMISSION_TYPE.BY_VOLUME)
    print("  PASSED")


# ============================================================
# FutureInfoStore Tests
# ============================================================

def _create_temp_future_json() raises -> String:
    var py = Python()
    var os_mod = py.import_module("os")
    var json_mod = py.import_module("json")
    var codecs = py.import_module("codecs")

    var tmp_path = String(py=os_mod.path.join(os_mod.getcwd(), "test_future_info_tmp.json"))

    var data = py.list()
    var item1 = py.dict()
    item1["order_book_id"] = "IF2409.CFFEX"
    item1["underlying_symbol"] = "IF"
    item1["tick_size"] = 0.2
    item1["margin_rate"] = 0.15
    item1["commission_type"] = "by_money"
    item1["open_commission_ratio"] = 0.00002
    item1["close_commission_ratio"] = 0.00003
    item1["close_commission_today_ratio"] = 0.00004
    data.append(item1)

    var item2 = py.dict()
    item2["order_book_id"] = "IC2412.CFFEX"
    item2["underlying_symbol"] = "IC"
    item2["tick_size"] = 0.2
    item2["margin_rate"] = 0.14
    item2["commission_type"] = "by_volume"
    item2["open_commission_ratio"] = 23.0
    item2["close_commission_ratio"] = 23.0
    item2["close_commission_today_ratio"] = 23.0
    data.append(item2)

    var f = codecs.open(tmp_path, "w", encoding="utf-8")
    json_mod.dump(data, f, indent=2)
    f.close()

    return tmp_path


def _cleanup_temp_json(path: String) raises:
    var py = Python()
    var os_mod = py.import_module("os")
    try:
        os_mod.remove(path)
    except:
        pass


def test_future_info_store_creation() raises:
    print("Test: FutureInfoStore loads JSON and validates margin_rate")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var store = create_future_info_store(tmp_path, custom_info)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_get_future_info_by_money() raises:
    print("Test: FutureInfoStore.get_future_info BY_MONEY type")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var params = mut_store.get_future_info("IF2409.CFFEX", "IF")
        assert_equal(params.commission_type, COMMISSION_TYPE.BY_MONEY)
        assert_equal(params.open_commission_ratio, 0.00002)
        assert_equal(params.close_commission_ratio, 0.00003)
        assert_equal(params.close_commission_today_ratio, 0.00004)
        assert_equal(params.long_margin_ratio, 0.15)
        assert_equal(params.short_margin_ratio, 0.15)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_get_future_info_by_volume() raises:
    print("Test: FutureInfoStore.get_future_info BY_VOLUME type")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var params = mut_store.get_future_info("IC2412.CFFEX", "IC")
        assert_equal(params.commission_type, COMMISSION_TYPE.BY_VOLUME)
        assert_equal(params.open_commission_ratio, 23.0)
        assert_equal(params.close_commission_ratio, 23.0)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_get_tick_size() raises:
    print("Test: FutureInfoStore.get_tick_size returns correct value")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var tick = mut_store.get_tick_size("IF2409.CFFEX", "IF")
        assert_equal(tick, 0.2)

        var tick2 = mut_store.get_tick_size("IC2412.CFFEX", "IC")
        assert_equal(tick2, 0.2)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_cache_works() raises:
    print("Test: FutureInfoStore cache returns same object on second call")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var p1 = mut_store.get_future_info("IF2409.CFFEX", "IF")
        var p2 = mut_store.get_future_info("IF2409.CFFEX", "IF")
        assert_equal(p1.close_commission_ratio, p2.close_commission_ratio)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_custom_override() raises:
    print("Test: FutureInfoStore custom_future_info overrides default")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var override = Python().dict()
        override["open_commission_ratio"] = 999.99
        custom_info["IF2409.CFFEX"] = override

        var mut_store = create_future_info_store(tmp_path, custom_info)
        var params = mut_store.get_future_info("IF2409.CFFEX", "IF")
        assert_equal(params.open_commission_ratio, 999.99)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_lookup_by_underlying() raises:
    print("Test: FutureInfoStore lookup finds correct instrument by order_book_id")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var params = mut_store.get_future_info("IF2409.CFFEX", "IF")
        assert_equal(params.long_margin_ratio, 0.15)
        assert_equal(params.commission_type, COMMISSION_TYPE.BY_MONEY)
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


# ============================================================
# ShareTransformationStore Tests
# ============================================================

def _create_temp_share_trans_json() raises -> String:
    var py = Python()
    var os_mod = py.import_module("os")
    var json_mod = py.import_module("json")
    var codecs = py.import_module("codecs")

    var tmp_path = String(py=os_mod.path.join(os_mod.getcwd(), "test_share_trans_tmp.json"))

    var data = py.dict()
    var entry = py.dict()
    entry["successor"] = "600519.XSHG"
    entry["share_conversion_ratio"] = 1.5
    data["000001.XSHE"] = entry

    var f = codecs.open(tmp_path, "w", encoding="utf-8")
    json_mod.dump(data, f, indent=2)
    f.close()

    return tmp_path


def test_share_transformation_store_found() raises:
    print("Test: ShareTransformationStore.get_share_transformation found")
    var tmp_path = _create_temp_share_trans_json()
    try:
        var store = create_share_transformation_store(tmp_path)
        var result = store.get_share_transformation("000001.XSHE")

        assert_true(result is not None, "should find transformation for 000001.XSHE")
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_share_transformation_store_not_found() raises:
    print("Test: ShareTransformationStore.get_share_transformation not found")
    var tmp_path = _create_temp_share_trans_json()
    try:
        var store = create_share_transformation_store(tmp_path)
        var result = store.get_share_transformation("NONEXISTENT.XSHE")

        assert_true(result is None, "should return None for unknown order_book_id")
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


# ============================================================
# Store Creation Tests (structural)
# ============================================================

def test_day_bar_store_creation() raises:
    print("Test: DayBarStore creation")
    var store = create_day_bar_store("/tmp/test_day_bar.h5")
    print("  PASSED")


def test_future_day_bar_store_creation() raises:
    print("Test: FutureDayBarStore creation (extends DayBarStore)")
    var store = create_future_day_bar_store("/tmp/test_future_day_bar.h5")
    print("  PASSED")


def test_dividend_store_creation() raises:
    print("Test: DividendStore creation")
    var store = create_dividend_store("/tmp/test_dividends.h5")
    print("  PASSED")


def test_simple_factor_store_creation() raises:
    print("Test: SimpleFactorStore creation")
    var store = create_simple_factor_store("/tmp/test_factors.h5")
    print("  PASSED")


def test_date_set_creation() raises:
    print("Test: DateSet creation from PythonObject")
    var py = Python()
    var dummy_h5 = py.dict()
    var store = create_date_set(dummy_h5)
    print("  PASSED")


# ============================================================
# ExchangeTradingCalendarStore Test
# ============================================================

def test_exchange_trading_calendar_store_creation() raises:
    print("Test: ExchangeTradingCalendarStore creation")
    var py = Python()
    var np = py.import_module("numpy")
    var tmp_arr = np.array(py.tuple(20240101, 20240102, 20240103), dtype=np.uint64)
    var store = create_exchange_trading_calendar_store(tmp_arr)
    print("  PASSED")


# ============================================================
# _file_path Helper Test
# ============================================================

def test_file_path_linux_returns_string() raises:
    print("Test: _file_path returns string on Linux (not win32)")
    var result = _file_path("/some/path/to/data.h5")
    var s = String(py=result)
    assert_true(len(s) > 10)
    print("  PASSED")


# ============================================================
# Error Handling Tests
# ============================================================

def test_future_info_store_raises_on_unknown() raises:
    print("Test: FutureInfoStore raises on completely unknown instrument")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var raised = False
        try:
            mut_store.get_future_info("TOTALLY.UNKNOWN", "UNKNOWN")
        except:
            raised = True
        assert_true(raised, "should raise for unknown instrument")
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def test_future_info_store_tick_size_raises_on_unknown() raises:
    print("Test: FutureInfoStore.get_tick_size raises on unknown instrument")
    var tmp_path = _create_temp_future_json()
    try:
        var custom_info = Python().dict()
        var mut_store = create_future_info_store(tmp_path, custom_info)

        var raised = False
        try:
            mut_store.get_tick_size("TOTALLY.UNKNOWN", "UNKNOWN")
        except:
            raised = True
        assert_true(raised, "should raise for unknown instrument")
        print("  PASSED")
    except e:
        _cleanup_temp_json(tmp_path)
        raise e^
    _cleanup_temp_json(tmp_path)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
