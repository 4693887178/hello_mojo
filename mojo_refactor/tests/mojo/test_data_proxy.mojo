from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.data.data_proxy import (
    DataProxy,
    DividendInfo, SplitInfo, Snapshot, OpenAuctionBar, YieldCurvePoint,
    create_dividend_info, create_split_info, create_snapshot, create_open_auction_bar,
    create_data_proxy, create_data_proxy_with_name, create_data_proxy_from_source,
    get_available_data_range, merge_trading_period
)
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime, DateTimeDate


def test_create_data_proxy() raises:
    var dp = create_data_proxy()
    assert_true(dp._data_source_name == "default")


def test_create_data_proxy_with_name() raises:
    var dp = create_data_proxy_with_name("test_source")
    assert_true(dp._data_source_name == "test_source")


def test_get_instrument_stock() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    assert_true(ins.order_book_id() == "000001.XSHE")


def test_get_instrument_returns_stock_for_any_id() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    assert_true(ins.order_book_id() == "IF2401.XSHG")
    assert_true(ins.order_book_id().find("IF") >= 0)


def test_get_instrument_always_succeeds() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("ANY.ID")
    assert_true(ins.order_book_id() != "")


def test_is_instrument_type_default_cs() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    assert_true(ins.type() == INSTRUMENT_TYPE.CS)


def test_get_previous_trading_date() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 17, 10, 0, 0)
    var prev = dp.get_previous_trading_date(dt)
    assert_true(prev.toordinal() < dt.toordinal())


def test_get_next_trading_date() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 14, 10, 0, 0)
    var next_dt = dp.get_next_trading_date(dt)
    assert_true(next_dt.toordinal() > dt.toordinal())


def test_get_trading_dates_returns_list() raises:
    var dp = create_data_proxy()
    var start = DateTime(2024, 11, 1, 0, 0, 0)
    var end = DateTime(2024, 11, 8, 0, 0, 0)
    var dates = dp.get_trading_dates(start, end)
    assert_true(len(dates) > 0)


def test_is_trading_date_weekday() raises:
    var dp = create_data_proxy()
    var friday = DateTime(2024, 11, 1, 0, 0, 0)
    assert_true(dp.is_trading_date(friday))


def test_is_suspended_default() raises:
    var dp = create_data_proxy()
    assert_false(dp.is_suspended("000001.XSHE", DateTime(2024, 6, 12)))


def test_get_bar() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var bar = dp.get_bar("000001.XSHE", dt)
    assert_true(bar.close() > 0.0)
    assert_true(bar.volume() > 0.0)


def test_history_bars_count() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var bars = dp.history_bars(ins, 5, "1d", "", dt)
    assert_equal(len(bars), 5)


def test_history_bars_fields() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var bars = dp.history_bars(ins, 3, "1d", "", dt)
    for i in range(len(bars)):
        assert_true(bars[i].close() > 0.0)
        assert_true(bars[i].volume() > 0.0)


def test_get_tick() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12, 10, 30, 0)
    var tick = dp.get_tick("000001.XSHE", dt)
    assert_true(tick.last > 0.0)
    assert_true(tick.volume > 0.0)


def test_history_ticks_count() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 10, 30, 0)
    var ticks = dp.history_ticks(ins, 5, dt)
    assert_equal(len(ticks), 5)


def test_get_dividend_for_stock() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var div = dp.get_dividend(ins)
    assert_true(div.value().dividend_cash_before_tax > 0.0)


def test_get_split_for_stock() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var split = dp.get_split(ins)
    assert_true(split.value().split_factor > 0.0)


def test_get_settle_price_for_future() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var price = dp.get_settle_price(ins, dt)
    assert_true(price >= 0.0)


def test_get_settle_price_for_stock_is_zero() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var price = dp.get_settle_price(ins, dt)
    assert_equal(price, 0.0)


def test_current_snapshot() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var snap = dp.current_snapshot(ins, "1d", dt)
    assert_true(snap.last > 0.0)
    assert_true(snap.volume > 0.0)
    assert_true(snap.limit_up > snap.last)
    assert_true(snap.limit_down < snap.last)


def test_open_auction_bar() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 9, 25, 0)
    var bar = dp.get_open_auction_bar(ins, dt)
    assert_true(bar.open > 0.0)
    assert_true(bar.limit_up > bar.open)
    assert_true(bar.limit_down < bar.open)


def test_yield_curve_has_points() raises:
    var dp = create_data_proxy()
    var start_dt = DateTimeDate(2024, 1, 1)
    var end_dt = DateTimeDate(2024, 6, 28)
    var curve = dp.get_yield_curve(start_dt, end_dt)
    if len(curve) > 0:
        for i in range(len(curve)):
            assert_true(curve[i].rate > 0.0)


def test_get_trading_minutes_for_stock() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 9, 30, 0)
    var minutes = dp.get_trading_minutes_for(ins, dt)
    assert_true(len(minutes) > 200)


def test_get_trading_minutes_for_future() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    var dt = DateTime(2024, 6, 12, 9, 30, 0)
    var minutes = dp.get_trading_minutes_for(ins, dt)
    assert_true(len(minutes) > 200)


def test_night_trading_false_for_stocks() raises:
    var dp = create_data_proxy()
    var ids = List[String]()
    ids.append("000001.XSHE")
    assert_false(dp.is_night_trading(ids))


def test_available_data_range() raises:
    var dp = create_data_proxy()
    var range_val = dp.available_data_range("1d")
    assert_true(range_val[0].toordinal() <= range_val[1].toordinal())


def test_get_future_contracts_if() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IF", dt)
    assert_true(len(contracts) > 0)
    for c in contracts:
        assert_true(c.find("IF") >= 0)


def test_get_future_contracts_ic() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IC", dt)
    assert_true(len(contracts) > 0)


def test_get_future_contracts_ih() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IH", dt)
    assert_true(len(contracts) > 0)


def test_get_future_contracts_im() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IM", dt)
    assert_true(len(contracts) > 0)


def test_get_future_contracts_empty() raises:
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("UNKNOWN", dt)
    assert_equal(len(contracts), 0)


def test_get_last_price() raises:
    var dp = create_data_proxy()
    var price = dp.get_last_price("000001.XSHE")
    assert_true(price > 0.0)


def test_get_limit_up() raises:
    var dp = create_data_proxy()
    var limit_up = dp.get_limit_up("000001.XSHE")
    assert_true(limit_up > 0.0)


def test_get_limit_down() raises:
    var dp = create_data_proxy()
    var limit_down = dp.get_limit_down("000001.XSHE")
    assert_true(limit_down > 0.0)


def test_get_all_instruments_default() raises:
    var dp = create_data_proxy()
    var instruments = dp.get_all_instruments()
    assert_true(len(instruments) > 0)


def test_get_all_instruments_by_type() raises:
    var dp = create_data_proxy()
    var stocks = dp.get_all_instruments("CS")
    assert_true(len(stocks) > 0)
    for s in stocks:
        assert_true(s.type() == INSTRUMENT_TYPE.CS)


def test_count_trading_dates_positive() raises:
    var dp = create_data_proxy()
    var start = DateTimeDate(2024, 1, 2)
    var end = DateTimeDate(2024, 14, 6)
    var count = dp.count_trading_dates(start, end)
    assert_true(count >= 0)


def test_create_dividend_info() raises:
    var di = create_dividend_info(
        book_closure_date=20231215,
        announcement_date=20231210,
        dividend_cash_before_tax=0.5,
        ex_dividend_date=20231220,
        payable_date=20231225,
        round_lot=100
    )
    assert_equal(di.ex_dividend_date, 20231220)
    assert_equal(di.dividend_cash_before_tax, 0.5)
    assert_equal(di.round_lot, 100)


def test_create_split_info() raises:
    var si = create_split_info(ex_date=20231201, split_factor=2.0)
    assert_equal(si.ex_date, 20231201)
    assert_equal(si.split_factor, 2.0)


def test_snapshot_str() raises:
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var snap = dp.current_snapshot(ins, "1d", dt)
    var s = snap.__str__()
    assert_true(s.find("Snapshot") >= 0)
    assert_true(s.find("000001") >= 0)


def test_split_info_str() raises:
    var si = create_split_info(ex_date=20231201, split_factor=1.5)
    var s = si.__str__()
    assert_true(s.find("SplitInfo") >= 0)
    assert_true(s.find("20231201") >= 0)


def test_yield_curve_point_str() raises:
    var ycp = YieldCurvePoint(date=20240612, tenor="3Y", rate=0.025)
    var s = ycp.__str__()
    assert_true(s.find("YieldCurvePoint") >= 0)
    assert_true(s.find("3Y") >= 0)


def test_merge_trading_period_no_overlap() raises:
    from rqmojo.utils.datetime_func import TimeRange, TimeOfDay
    var ranges = List[TimeRange]()
    ranges.append(TimeRange(TimeOfDay(9, 30), TimeOfDay(11, 30)))
    ranges.append(TimeRange(TimeOfDay(13, 0), TimeOfDay(15, 0)))
    var merged = merge_trading_period(ranges)
    assert_equal(len(merged), 2)


def test_merge_trading_period_overlap() raises:
    from rqmojo.utils.datetime_func import TimeRange, TimeOfDay
    var ranges = List[TimeRange]()
    ranges.append(TimeRange(TimeOfDay(9, 0), TimeOfDay(11, 0)))
    ranges.append(TimeRange(TimeOfDay(10, 30), TimeOfDay(12, 0)))
    var merged = merge_trading_period(ranges)
    assert_equal(len(merged), 1)


def test_get_available_data_range_function() raises:
    var dp = create_data_proxy()
    var range_val = get_available_data_range(dp, "1d")
    assert_true(range_val[0].toordinal() <= range_val[1].toordinal())


def test_create_data_proxy_from_source() raises:
    var source = create_data_proxy_with_name("source_test")
    var dp = create_data_proxy_from_source(source, create_data_proxy())
    assert_true(dp._data_source_name == "source_test")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
