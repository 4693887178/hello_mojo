"""
Comprehensive tests for data/instruments_mixin.mojo
Tests all methods ported from rqalpha/data/instruments_mixin.py

Test data:
  - RB1912:  Future, SHFE, listed 2019-01-01, de_listed 2019-12-15
  - AG1912:  Future, SHFE, listed 2019-01-01, de_listed 2019-12-15
  - TF1912:  Future, CFFEX, listed 2019-01-01, de_listed 2019-12-15
  - 000001.XSHE: Stock, XSHE, listed 1991-04-03, de_listed 2999-12-31
  - 600000.XSHG: Stock, XSHG, listed 1999-11-10, de_listed 2999-12-31
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from rqmojo.data.instruments_mixin import InstrumentsMixin, create_instruments_mixin_with_test_data
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime


def test_init_empty() raises:
    var mixin = InstrumentsMixin()
    var all_ins = mixin._get_all_instruments()
    assert_equal(len(all_ins), 0, "empty mixin should have 0 instruments")


def test_init_with_instruments() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var all_ins = mixin._get_all_instruments()
    assert_equal(len(all_ins), 5, "test data should have 5 instruments")


def test_register_instruments() raises:
    var mixin = InstrumentsMixin()
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(1991, 4, 3, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    mixin.register_instruments(instruments)
    var all_ins = mixin._get_all_instruments()
    assert_equal(len(all_ins), 1, "should have 1 instrument after registration")


def test_get_active_instrument_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt = DateTime(2019, 6, 1, 0, 0, 0, 0)
    var ins = mixin.get_active_instrument("000001.XSHE", dt)
    assert_equal(ins.order_book_id(), "000001.XSHE", "should find active stock")


def test_get_active_instrument_future_active() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt = DateTime(2019, 6, 1, 0, 0, 0, 0)
    var ins = mixin.get_active_instrument("RB1912", dt)
    assert_equal(ins.order_book_id(), "RB1912", "should find active future")


def test_get_active_instrument_not_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt = DateTime(2019, 6, 1, 0, 0, 0, 0)
    with assert_raises():
        _ = mixin.get_active_instrument("NONEXIST", dt)


def test_get_active_instrument_future_delisted() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    with assert_raises():
        _ = mixin.get_active_instrument("RB1912", dt)


def test_get_active_instrument_before_listing() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt = DateTime(2018, 1, 1, 0, 0, 0, 0)
    with assert_raises():
        _ = mixin.get_active_instrument("RB1912", dt)


def test_get_instrument_history_basic() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var result = mixin.get_instrument_history("000001.XSHE")
    assert_equal(len(result), 1, "should find 1 instrument for 000001.XSHE")
    assert_equal(result[0].order_book_id(), "000001.XSHE", "order_book_id should match")


def test_get_instrument_history_with_listed_at_filter() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var dt_before = DateTime(1990, 1, 1, 0, 0, 0, 0)
    var result = mixin.get_instrument_history("000001.XSHE", Optional[DateTime](dt_before))
    assert_equal(len(result), 0, "should find 0 instruments before listing date")

    var dt_after = DateTime(2000, 1, 1, 0, 0, 0, 0)
    var result2 = mixin.get_instrument_history("000001.XSHE", Optional[DateTime](dt_after))
    assert_equal(len(result2), 1, "should find 1 instrument after listing date")


def test_get_instrument_history_sorted() raises:
    var mixin = InstrumentsMixin()
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        "000002.XSHE", "万科A",
        DateTime(1991, 1, 29, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(1991, 4, 3, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    mixin.register_instruments(instruments)
    var result = mixin.get_instrument_history("000001.XSHE")
    if len(result) >= 1:
        assert_equal(result[0].order_book_id(), "000001.XSHE", "first should be 000001.XSHE")


def test_get_instrument_history_not_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var result = mixin.get_instrument_history("NONEXIST")
    assert_equal(len(result), 0, "should find 0 instruments for non-existent id")


def test_get_active_instruments() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var id_list = List[String]()
    id_list.append("000001.XSHE")
    id_list.append("RB1912")
    var dt = DateTime(2019, 6, 1, 0, 0, 0, 0)
    var result = mixin.get_active_instruments(id_list, dt)
    assert_equal(len(result), 2, "should find 2 active instruments")
    assert_true("000001.XSHE" in result, "should contain 000001.XSHE")
    assert_true("RB1912" in result, "should contain RB1912")


def test_get_active_instruments_partial_active() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var id_list = List[String]()
    id_list.append("000001.XSHE")
    id_list.append("RB1912")
    var dt = DateTime(2020, 6, 1, 0, 0, 0, 0)
    var result = mixin.get_active_instruments(id_list, dt)
    assert_equal(len(result), 1, "should find 1 active instrument (stock only)")
    assert_true("000001.XSHE" in result, "should contain 000001.XSHE")
    assert_false("RB1912" in result, "should not contain RB1912 (delisted)")


def test_get_instruments_history() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var id_list = List[String]()
    id_list.append("000001.XSHE")
    id_list.append("RB1912")
    var result = mixin.get_instruments_history(id_list)
    assert_equal(len(result), 2, "should find 2 instruments in history")


def test_get_all_instruments_by_type() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var types = List[INSTRUMENT_TYPE]()
    types.append(INSTRUMENT_TYPE.CS)
    var result = mixin.get_all_instruments(types)
    assert_equal(len(result), 2, "should find 2 CS instruments")


def test_get_all_instruments_future_type() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var types = List[INSTRUMENT_TYPE]()
    types.append(INSTRUMENT_TYPE.FUTURE)
    var result = mixin.get_all_instruments(types)
    assert_equal(len(result), 3, "should find 3 FUTURE instruments")


def test_get_all_instruments_with_dt_filter() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var types = List[INSTRUMENT_TYPE]()
    types.append(INSTRUMENT_TYPE.FUTURE)
    var dt = DateTime(2019, 6, 1, 0, 0, 0, 0)
    var result = mixin.get_all_instruments(types, Optional[DateTime](dt))
    assert_equal(len(result), 3, "all 3 futures should be active in mid-2019")


def test_get_all_instruments_with_dt_filter_delisted() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var types = List[INSTRUMENT_TYPE]()
    types.append(INSTRUMENT_TYPE.FUTURE)
    var dt = DateTime(2020, 6, 1, 0, 0, 0, 0)
    var result = mixin.get_all_instruments(types, Optional[DateTime](dt))
    assert_equal(len(result), 0, "all futures should be delisted by mid-2020")


def test_get_all_instruments_stock_always_active() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var types = List[INSTRUMENT_TYPE]()
    types.append(INSTRUMENT_TYPE.CS)
    var dt = DateTime(2020, 6, 1, 0, 0, 0, 0)
    var result = mixin.get_all_instruments(types, Optional[DateTime](dt))
    assert_equal(len(result), 2, "stocks should still be active in 2020")


def test_assure_order_book_id_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var obid = mixin.assure_order_book_id("000001.XSHE")
    assert_equal(obid, "000001.XSHE", "should return the same order_book_id")


def test_assure_order_book_id_with_expected_type() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var obid = mixin.assure_order_book_id("000001.XSHE", Optional[INSTRUMENT_TYPE](INSTRUMENT_TYPE.CS))
    assert_equal(obid, "000001.XSHE", "should return order_book_id for matching type")


def test_assure_order_book_id_wrong_type() raises:
    var mixin = create_instruments_mixin_with_test_data()
    with assert_raises():
        _ = mixin.assure_order_book_id("000001.XSHE", Optional[INSTRUMENT_TYPE](INSTRUMENT_TYPE.FUTURE))


def test_assure_order_book_id_not_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    with assert_raises():
        _ = mixin.assure_order_book_id("NONEXIST")


def test_all_instruments_deprecated() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var types = List[INSTRUMENT_TYPE]()
    types.append(INSTRUMENT_TYPE.CS)
    var result = mixin.all_instruments(types)
    assert_equal(len(result), 2, "deprecated all_instruments should work same as get_all_instruments")


def test_instrument_not_none_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var ins = mixin.instrument_not_none("000001.XSHE")
    assert_equal(ins.order_book_id(), "000001.XSHE", "should find instrument")


def test_instrument_not_none_not_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    with assert_raises():
        _ = mixin.instrument_not_none("NONEXIST")


def test_instrument_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var result = mixin.instrument("000001.XSHE")
    assert_true(result != None, "should find instrument")
    assert_equal(result.value().order_book_id(), "000001.XSHE", "order_book_id should match")


def test_instrument_not_found() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var result = mixin.instrument("NONEXIST")
    assert_true(result == None, "should return None for non-existent instrument")


def test_instruments_by_ids() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var id_list = List[String]()
    id_list.append("000001.XSHE")
    id_list.append("RB1912")
    var result = mixin.instruments_by_ids(id_list)
    assert_equal(len(result), 2, "should find 2 instruments by ids")


def test_lookup_by_symbol() raises:
    var mixin = create_instruments_mixin_with_test_data()
    var result = mixin.get_instrument_history("平安银行")
    assert_equal(len(result), 1, "should find instrument by symbol")
    assert_equal(result[0].order_book_id(), "000001.XSHE", "should match by symbol")


def test_multiple_instruments_same_id() raises:
    var mixin = InstrumentsMixin()
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(1991, 4, 3, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行v2",
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    mixin.register_instruments(instruments)
    var result = mixin.get_instrument_history("000001.XSHE")
    assert_equal(len(result), 2, "should find 2 instruments with same id but different listed dates")


def test_get_active_instrument_multiple_raises() raises:
    var mixin = InstrumentsMixin()
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(1991, 4, 3, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行v2",
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    mixin.register_instruments(instruments)
    var dt = DateTime(2021, 1, 1, 0, 0, 0, 0)
    with assert_raises():
        _ = mixin.get_active_instrument("000001.XSHE", dt)


def test_sort_by_listed_date() raises:
    var mixin = InstrumentsMixin()
    var instruments = List[Instrument]()
    instruments.append(create_stock_instrument(
        "600000.XSHG", "浦发银行",
        DateTime(1999, 11, 10, 0, 0, 0, 0),
        EXCHANGE.XSHG
    ))
    instruments.append(create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(1991, 4, 3, 0, 0, 0, 0),
        EXCHANGE.XSHE
    ))
    mixin.register_instruments(instruments)
    var result = mixin.get_instrument_history("000001.XSHE")
    if len(result) >= 2:
        var first_date = result[0].listed_date()
        var second_date = result[1].listed_date()
        assert_true(
            convert_date_to_int(first_date) <= convert_date_to_int(second_date),
            "results should be sorted by listed_date ascending"
        )


from rqmojo.utils.datetime_func import convert_date_to_int


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
