"""
Comprehensive Test for data/base_data_source/data_source.mojo
Covers: BaseDataSource, BaseDataSourceProtocol, FuturesTradingParameters, ExchangeRate
Group 09 - test_base_data_source (rewritten)
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.data.base_data_source import (
    BaseDataSource,
    BaseDataSourceProtocol,
    FuturesTradingParameters,
    ExchangeRate,
    create_base_data_source,
    create_base_data_source_with_path,
    _store_key,
    get_BAR_RESAMPLE_FIELD_METHODS,
    get_OPEN_AUCTION_BAR_FIELDS,
)
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.utils.typing import DateTime, DateTimeDate

comptime BUNDLE_PATH = "/home/zhou/.rqalpha/bundle"


def test_store_key_function() raises:
    print("Test: _store_key function")
    var key = _store_key(INSTRUMENT_TYPE.CS, MARKET.CN)
    assert_equal(key, "CS|CN", "store key format should be TYPE|MARKET")

    key = _store_key(INSTRUMENT_TYPE.FUTURE, MARKET.CN)
    assert_equal(key, "Future|CN", "store key for future type")

    key = _store_key(INSTRUMENT_TYPE.INDX, MARKET.CN)
    assert_equal(key, "INDX|CN", "store key for index type")
    print("  PASSED")


def test_futures_trading_parameters_struct() raises:
    print("Test: FuturesTradingParameters struct")
    var params = FuturesTradingParameters(long_margin_ratio=0.1, short_margin_ratio=0.15)
    assert_equal(params.long_margin_ratio, 0.1, "long_margin_ratio should be 0.1")
    assert_equal(params.short_margin_ratio, 0.15, "short_margin_ratio should be 0.15")

    var params2 = FuturesTradingParameters(long_margin_ratio=0.2, short_margin_ratio=0.2)
    assert_equal(params2.long_margin_ratio, 0.2, "long_margin_ratio should be 0.2")
    print("  PASSED")


def test_futures_trading_parameters_writable() raises:
    print("Test: FuturesTradingParameters Writable trait")
    var params = FuturesTradingParameters(long_margin_ratio=0.1, short_margin_ratio=0.15)
    var s = String.write(params)
    assert_true(s.find("FuturesTradingParameters") >= 0, "should contain struct name")
    assert_true(s.find("long=") >= 0, "should contain long field")
    assert_true(s.find("short=") >= 0, "should contain short field")
    print("  PASSED")


def test_exchange_rate_struct() raises:
    print("Test: ExchangeRate struct")
    var rate = ExchangeRate(
        bid_reference=0.9,
        ask_reference=1.1,
        bid_settlement_sh=0.95,
        ask_settlement_sh=1.05,
        bid_settlement_sz=0.92,
        ask_settlement_sz=1.08
    )
    assert_equal(rate.bid_reference, 0.9, "bid_reference should be 0.9")
    assert_equal(rate.ask_reference, 1.1, "ask_reference should be 1.1")
    assert_equal(rate.bid_settlement_sh, 0.95, "bid_settlement_sh should be 0.95")
    assert_equal(rate.ask_settlement_sz, 1.08, "ask_settlement_sz should be 1.08")
    print("  PASSED")


def test_exchange_rate_writable() raises:
    print("Test: ExchangeRate Writable trait")
    var rate = ExchangeRate(
        bid_reference=1.0,
        ask_reference=1.0,
        bid_settlement_sh=1.0,
        ask_settlement_sh=1.0,
        bid_settlement_sz=1.0,
        ask_settlement_sz=1.0
    )
    var s = String.write(rate)
    assert_true(s.find("ExchangeRate") >= 0, "should contain struct name")
    assert_true(s.find("bid=") >= 0, "should contain bid field")
    assert_true(s.find("ask=") >= 0, "should contain ask field")
    print("  PASSED")


def test_bar_resample_field_methods() raises:
    print("Test: get_BAR_RESAMPLE_FIELD_METHODS function")
    var methods = get_BAR_RESAMPLE_FIELD_METHODS()
    assert_true(len(methods) > 0, "should have resample methods")

    assert_equal(methods["open"], "first", "open should use first")
    assert_equal(methods["close"], "last", "close should use last")
    assert_equal(methods["high"], "max", "high should use max")
    assert_equal(methods["low"], "min", "low should use min")
    assert_equal(methods["volume"], "sum", "volume should use sum")
    assert_equal(methods["total_turnover"], "sum", "total_turnover should use sum")
    print("  PASSED")


def test_open_auction_bar_fields() raises:
    print("Test: get_OPEN_AUCTION_BAR_FIELDS function")
    var fields = get_OPEN_AUCTION_BAR_FIELDS()
    assert_equal(len(fields), 6, "should have 6 open auction fields")

    assert_true("datetime" in fields, "should contain datetime")
    assert_true("open" in fields, "should contain open")
    assert_true("limit_up" in fields, "should contain limit_up")
    assert_true("limit_down" in fields, "should contain limit_down")
    assert_true("volume" in fields, "should contain volume")
    assert_true("total_turnover" in fields, "should contain total_turnover")
    print("  PASSED")


def test_base_data_source_init_with_real_bundle() raises:
    print("Test: BaseDataSource init with real bundle at ", BUNDLE_PATH)
    var source = create_base_data_source(BUNDLE_PATH)
    print("  PASSED")


def test_base_data_source_invalid_path_raises() raises:
    print("Test: BaseDataSource invalid path raises Error")
    try:
        var _ = create_base_data_source_with_path("/tmp/this_path_does_not_exist_for_sure_12345")
        assert False, "Should have raised Error for non-existent path"
    except e:
        var err_str = String(e)
        assert_true(err_str.find("not exist") >= 0, "Error message should mention path not exist")
    print("  PASSED")


def test_get_instruments_from_bundle() raises:
    print("Test: get_instruments from bundle")
    var source = create_base_data_source(BUNDLE_PATH)
    var instruments = source.get_instruments()
    assert_true(len(instruments) > 0, "should load instruments from bundle")
    print("  loaded ", len(instruments), " instruments")
    print("  PASSED")


def test_get_instruments_by_id() raises:
    print("Test: get_instruments by order_book_id")
    var source = create_base_data_source(BUNDLE_PATH)
    var ids = List[String]()
    ids.append("000001.XSHE")
    var instruments = source.get_instruments(id_or_syms=Optional[List[String]](ids.copy()))
    assert_true(len(instruments) > 0, "should find instrument by id")
    print("  found ", len(instruments), " instruments for 000001.XSHE")
    print("  PASSED")


def test_get_exchange_rate_same_market() raises:
    print("Test: get_exchange_rate same market returns identity rate")
    var source = create_base_data_source(BUNDLE_PATH)
    var dt = DateTimeDate(2024, 1, 5)
    var rate = source.get_exchange_rate(dt, MARKET.CN, MARKET.CN)
    assert_equal(rate.bid_reference, 1.0, "same market bid_reference should be 1.0")
    assert_equal(rate.ask_reference, 1.0, "same market ask_reference should be 1.0")
    print("  PASSED")


def test_get_exchange_rate_different_market_raises() raises:
    print("Test: get_exchange_rate different market raises NotImplementedError")
    var source = create_base_data_source(BUNDLE_PATH)
    var dt = DateTimeDate(2024, 1, 5)
    try:
        var _ = source.get_exchange_rate(dt, MARKET.CN, MARKET.HK)
        assert False, "Should raise NotImplementedError"
    except e:
        pass
    print("  PASSED")


def test_available_data_range() raises:
    print("Test: available_data_range returns date range")
    var source = create_base_data_source(BUNDLE_PATH)
    var range_result = source.available_data_range("1d")
    var range_start = range_result[0]
    var range_end = range_result[1]
    assert_true(range_start.year > 1990, "start year should be after 1990")
    assert_true(range_end.year < 9999, "end year should be before 9999")
    print("  range: ", range_start.year, "-", range_start.month, " to ", range_end.year, "-", range_end.month)
    print("  PASSED")


def test_available_data_range_tick_same_as_1d() raises:
    print("Test: available_data_range for tick returns same as 1d")
    var source = create_base_data_source(BUNDLE_PATH)
    var tick_range = source.available_data_range("tick")
    var day_range = source.available_data_range("1d")

    var tick_start = tick_range[0]
    var tick_end = tick_range[1]
    var day_start = day_range[0]
    var day_end = day_range[1]

    assert_equal(tick_start.year, day_start.year, "tick and 1d start year should match")
    assert_equal(tick_start.month, day_start.month, "tick and 1d start month should match")
    assert_equal(tick_end.year, day_end.year, "tick and 1d end year should match")
    assert_equal(tick_end.month, day_end.month, "tick and 1d end month should match")
    print("  PASSED")


def test_get_trading_calendars() raises:
    print("Test: get_trading_calendars")
    var source = create_base_data_source(BUNDLE_PATH)
    var calendars = source.get_trading_calendars()
    assert_true(len(calendars) > 0, "should have trading calendars")
    assert_true("CN_STOCK" in calendars, "should have CN_STOCK calendar")
    print("  found ", len(calendars), " calendars")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
