from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.data.data_proxy import (
    DataProxy,
    DividendInfo, SplitInfo, Snapshot, OpenAuctionBar, YieldCurvePoint,
    create_dividend_info, create_split_info, create_snapshot, create_open_auction_bar,
    create_data_proxy, create_data_proxy_with_name, create_data_proxy_from_source,
    get_available_data_range, merge_trading_period
)
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime


def test_create_data_proxy() raises:
    """Test default DataProxy creation."""
    var dp = create_data_proxy()
    assert_true(dp._data_source_name == "default")


def test_create_data_proxy_with_name() raises:
    """Test named DataProxy creation."""
    var dp = create_data_proxy_with_name("test_source")
    assert_true(dp._data_source_name == "test_source")


def test_get_instrument_stock() raises:
    """Test get_instrument returns stock instrument."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    assert_true(ins.order_book_id() == "000001.XSHE")


def test_get_instrument_future() raises:
    """Test get_instrument returns future instrument."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    assert_true(ins.order_book_id() == "IF2401.XSHG")
    assert_true(ins.order_book_id().find("IF") >= 0)


def test_get_instrument_not_found() raises:
    """Test get_instrument raises for unknown ID."""
    var dp = create_data_proxy()
    var raised = False
    try:
        dp.get_instrument("INVALID.ID")
    except:
        raised = True
    assert_true(raised)


def test_is_stock() raises:
    """Test is_stock identifies stocks correctly."""
    var dp = create_data_proxy()
    assert_true(dp.is_stock("000001.XSHE"))
    assert_true(dp.is_stock("600000.XSHG"))
    assert_false(dp.is_stock("IF2401.XSHG"))


def test_is_future() raises:
    """Test is_future identifies futures correctly."""
    var dp = create_data_proxy()
    assert_true(dp.is_future("IF2401.XSHG"))
    assert_true(dp.is_future("IC2401.XSHG"))
    assert_false(dp.is_future("000001.XSHE"))


def test_settle_date() raises:
    """Test settle_date returns correct date string."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 15, 10, 30, 0)
    var result = dp.settle_date(dt)
    assert_equal(result, "20240614")


def test_get_previous_trading_date() raises:
    """Test get_previous_trading_date returns earlier date."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 17, 10, 0, 0)
    var prev = dp.get_previous_trading_date(dt)
    assert_true(prev.toordinal() < dt.toordinal())


def test_get_next_trading_date() raises:
    """Test get_next_trading_date returns later date."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 14, 10, 0, 0)
    var next_dt = dp.get_next_trading_date(dt)
    assert_true(next_dt.toordinal() > dt.toordinal())


def test_get_trading_dates() raises:
    """Test get_trading_dates returns list of dates."""
    var dp = create_data_proxy()
    var start = DateTime(2024, 6, 10, 0, 0, 0)
    var end = DateTime(2024, 6, 17, 0, 0, 0)
    var dates = dp.get_trading_dates(start, end)
    assert_true(len(dates) > 0)


def test_is_trading_date() raises:
    """Test is_trading_date correctly identifies trading days."""
    var dp = create_data_proxy()
    var weekday = DateTime(2024, 6, 12, 0, 0, 0)
    assert_true(dp.is_trading_date(weekday))


def test_is_suspended_default() raises:
    """Test is_suspended returns false by default."""
    var dp = create_data_proxy()
    assert_false(dp.is_suspended("000001.XSHE", DateTime(2024, 6, 12)))


def test_get_price() raises:
    """Test get_price returns BarObject with expected fields."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var bar = dp.get_price(ins, dt)
    assert_true(bar.close() > 0.0)
    assert_true(bar.volume() > 0.0)


def test_get_price_with_adjustment() raises:
    """Test get_price with different adjustment types."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)

    var bar_none = dp.get_price(ins, dt, "none", dt)
    var bar_pre = dp.get_price(ins, dt, "pre", dt)
    var bar_post = dp.get_price(ins, dt, "post", dt)

    assert_true(bar_none.close() > 0.0)
    assert_true(bar_pre.close() > 0.0)
    assert_true(bar_post.close() > 0.0)


def test_history_bars_count() raises:
    """Test history_bars returns requested count of bars."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var bars = dp.history_bars(ins, 5, "1d", None, dt)
    assert_equal(len(bars), 5)


def test_history_bars_fields() raises:
    """Test history_bars bars have correct field values."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var bars = dp.history_bars(ins, 3, "1d", None, dt)
    for i in range(len(bars)):
        assert_true(bars[i].close() > 0.0)
        assert_true(bars[i].volume() > 0.0)


def test_get_tick() raises:
    """Test get_tick returns TickObject."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12, 10, 30, 0)
    var tick = dp.get_tick("000001.XSHE", dt)
    assert_true(tick.last > 0.0)
    assert_true(tick.volume > 0.0)


def test_history_ticks_count() raises:
    """Test history_ticks returns requested count."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 10, 30, 0)
    var ticks = dp.history_ticks(ins, 5, dt)
    assert_equal(len(ticks), 5)


def test_get_dividend_for_stock() raises:
    """Test get_dividend returns info for CS type."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var div = dp.get_dividend(ins)
    assert_true(div is not None and not div.is_none())
    if div is not None and not div.is_none():
        assert_true(div.value().dividend_cash_before_tax > 0.0)


def test_get_dividend_for_future() raises:
    """Test get_dividend returns None for futures."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    var div = dp.get_dividend(ins)
    assert_true(div is None or (div is not None and div.is_none()))


def test_get_split_for_stock() raises:
    """Test get_split returns info for CS type."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var split = dp.get_split(ins)
    assert_true(split is not None and not split.is_none())
    if split is not None and not split.is_none():
        assert_true(split.value().split_factor > 0.0)


def test_get_settle_price_for_future() raises:
    """Test get_settle_price returns value for futures."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var price = dp.get_settle_price(ins, dt)
    assert_true(price >= 0.0)


def test_get_settle_price_for_stock() raises:
    """Test get_settle_price returns 0 for non-futures."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var price = dp.get_settle_price(ins, dt)
    assert_equal(price, 0.0)


def test_current_snapshot() raises:
    """Test current_snapshot returns valid snapshot."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var snap = dp.current_snapshot(ins, "1d", dt)
    assert_true(snap.last > 0.0)
    assert_true(snap.volume > 0.0)
    assert_true(snap.limit_up > snap.last)
    assert_true(snap.limit_down < snap.last)


def test_open_auction_bar() raises:
    """Test get_open_auction_bar returns valid bar."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 9, 25, 0)
    var bar = dp.get_open_auction_bar(ins, dt)
    assert_true(bar.open > 0.0)
    assert_true(bar.limit_up > bar.open)
    assert_true(bar.limit_down < bar.open)


def test_yield_curve() raises:
    """Test get_yield_curve returns yield curve points."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var curve = dp.get_yield_curve(dt)
    assert_true(len(curve) > 0)


def test_yield_curve_points_have_rate() raises:
    """Test yield curve points have valid rates."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var curve = dp.get_yield_curve(dt)
    for i in range(len(curve)):
        assert_true(curve[i].rate > 0.0)


def test_get_trading_minutes_for_stock() raises:
    """Test get_trading_minutes_for returns minutes for CS."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 9, 30, 0)
    var minutes = dp.get_trading_minutes_for(ins, dt)
    assert_true(len(minutes) > 200)


def test_get_trading_minutes_for_future() raises:
    """Test get_trading_minutes_for returns minutes for futures."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("IF2401.XSHG")
    var dt = DateTime(2024, 6, 12, 9, 30, 0)
    var minutes = dp.get_trading_minutes_for(ins, dt)
    assert_true(len(minutes) > 200)


def test_night_trading_true() raises:
    """Test is_night_trading returns true for night-trading instruments."""
    var dp = create_data_proxy()
    var ids = List[String]()
    ids.append("IF2401.XSHG")
    assert_true(dp.is_night_trading(ids))


def test_night_trading_false() raises:
    """Test is_night_trading returns false for stocks."""
    var dp = create_data_proxy()
    var ids = List[String]()
    ids.append("000001.XSHE")
    assert_false(dp.is_night_trading(ids))


def test_available_data_range() raises:
    """Test available_data_range returns tuple."""
    var dp = create_data_proxy()
    var range_val = dp.available_data_range("1d")
    assert_true(range_val[0].toordinal() <= range_val[1].toordinal())


def test_get_future_contracts_if() raises:
    """Test get_future_contracts for IF."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IF", dt)
    assert_true(len(contracts) > 0)
    for c in contracts:
        assert_true(c.find("IF") >= 0)


def test_get_future_contracts_ic() raises:
    """Test get_future_contracts for IC."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IC", dt)
    assert_true(len(contracts) > 0)


def test_get_future_contracts_ih() raises:
    """Test get_future_contracts for IH."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IH", dt)
    assert_true(len(contracts) > 0)


def test_get_future_contracts_im() raises:
    """Test get_future_contracts for IM."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("IM", dt)
    assert_true(len(contracts) > 0)


def test_get_future_contracts_empty() raises:
    """Test get_future_contracts returns empty for unknown symbol."""
    var dp = create_data_proxy()
    var dt = DateTime(2024, 6, 12)
    var contracts = dp.get_future_contracts("UNKNOWN", dt)
    assert_equal(len(contracts), 0)


def test_create_dividend_info() raises:
    """Test create_dividend_info helper function."""
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
    """Test create_split_info helper function."""
    var si = create_split_info(ex_date=20231201, split_factor=2.0)
    assert_equal(si.ex_date, 20231201)
    assert_equal(si.split_factor, 2.0)


def test_snapshot_str() raises:
    """Test Snapshot __str__ method."""
    var dp = create_data_proxy()
    var ins = dp.get_instrument("000001.XSHE")
    var dt = DateTime(2024, 6, 12, 15, 0, 0)
    var snap = dp.current_snapshot(ins, "1d", dt)
    var s = snap.__str__()
    assert_true(s.find("Snapshot") >= 0)
    assert_true(s.find("000001") >= 0)


def test_split_info_str() raises:
    """Test SplitInfo __str__ method."""
    var si = create_split_info(ex_date=20231201, split_factor=1.5)
    var s = si.__str__()
    assert_true(s.find("SplitInfo") >= 0)
    assert_true(s.find("20231201") >= 0)


def test_yield_curve_point_str() raises:
    """Test YieldCurvePoint __str__ method."""
    var ycp = YieldCurvePoint(date=20240612, tenor="3Y", rate=0.025)
    var s = ycp.__str__()
    assert_true(s.find("YieldCurvePoint") >= 0)
    assert_true(s.find("3Y") >= 0)


def test_dividend_info_write_to() raises:
    """Test DividendInfo write_to method."""
    var di = create_dividend_info(
        book_closure_date=20231215,
        announcement_date=20231210,
        dividend_cash_before_tax=0.5,
        ex_dividend_date=20231220,
        payable_date=20231225,
        round_lot=100
    )
    var s = di.__str__()
    assert_true(s.find("DividendInfo") >= 0)


def test_merge_trading_period_no_overlap() raises:
    """Test merge_trading_period with non-overlapping ranges."""
    from rqmojo.utils.datetime_func import TimeRange, TimeOfDay
    var ranges = List[TimeRange]()
    ranges.append(TimeRange(TimeOfDay(9, 30), TimeOfDay(11, 30)))
    ranges.append(TimeRange(TimeOfDay(13, 0), TimeOfDay(15, 0)))
    var merged = merge_trading_period(ranges)
    assert_equal(len(merged), 2)


def test_merge_trading_period_overlap() raises:
    """Test merge_trading_period with overlapping ranges."""
    from rqmojo.utils.datetime_func import TimeRange, TimeOfDay
    var ranges = List[TimeRange]()
    ranges.append(TimeRange(TimeOfDay(9, 0), TimeOfDay(11, 0)))
    ranges.append(TimeRange(TimeOfDay(10, 30), TimeOfDay(12, 0)))
    var merged = merge_trading_period(ranges)
    assert_equal(len(merged), 1)


def test_get_available_data_range_function() raises:
    """Test module-level get_available_data_range function."""
    var dp = create_data_proxy()
    var range_val = get_available_data_range(dp, "1d")
    assert_true(range_val[0].toordinal() <= range_val[1].toordinal())


def test_create_data_proxy_from_source() raises:
    """Test create_data_proxy_from_source creates proxy with same name."""
    var source = create_data_proxy_with_name("source_test")
    var dp = create_data_proxy_from_source(source, create_data_proxy())
    assert_true(dp._data_source_name == "source_test")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
