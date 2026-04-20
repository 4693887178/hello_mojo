"""
Comprehensive Test Suite for model/bar.mojo
Group 11 - File 1

Covers:
  - BarData struct (NaN values)
  - PartialBarObject (open_auction subset: NO close/high/low)
  - BarObject (full bar with all properties)
  - BarMap (dictionary-like container)
  - Factory functions
  - Edge cases (NaN handling, limit_up/down, suspended, etc.)

Parity targets from Python rqalpha/model/bar.py:
  - PartialBarObject: order_book_id, symbol, instrument, datetime, open,
    last, volume, total_turnover, limit_up, limit_down, prev_close,
    prev_settlement, isnan
  - BarObject: all PartialBarObject props + close, high, low, settlement,
    open_interest, discount_rate, acc_net_value, unit_net_value,
    basis_spread, is_trading, suspended, isnan, vwap(intervals,freq), mavg(intervals,freq)
  - BarMap: update_dt, update_universe, get, set, contains, len, items,
    keys, values, dt, frequency, __str__
"""

from std.collections import Dict, List, Set
from rqmojo.model.bar import (
    BarData, BarObject, PartialBarObject, BarMap,
    create_bar_object, create_simple_bar, create_nan_bar_object,
    create_nan_bar_data, create_partial_bar_object, create_bar_map,
    create_bar_object_with_instrument, bar_object_from_dict
)
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.typing import DateTime
from std.testing import assert_equal, assert_true, assert_false, TestSuite

comptime NAN_VALUE: Float64 = 0.0 / 0.0


# ============================================================
# BarData Tests
# ============================================================

def test_bar_data_nan() raises:
    print("Test: BarData NaN values")
    var data = create_nan_bar_data()
    assert_true(data.open != data.open, "open should be NaN")
    assert_true(data.close != data.close, "close should be NaN")
    assert_true(data.high != data.high, "high should be NaN")
    assert_true(data.low != data.low, "low should be NaN")
    assert_true(data.limit_up != data.limit_up, "limit_up should be NaN")
    assert_true(data.limit_down != data.limit_down, "limit_down should be NaN")
    assert_true(data.settlement != data.settlement, "settlement should be NaN")
    assert_true(data.prev_settlement != data.prev_settlement, "prev_settlement should be NaN")
    assert_true(data.discount_rate != data.discount_rate, "discount_rate should be NaN")
    assert_true(data.acc_net_value != data.acc_net_value, "acc_net_value should be NaN")
    assert_true(data.unit_net_value != data.unit_net_value, "unit_net_value should be NaN")
    assert_true(data.basis_spread != data.basis_spread, "basis_spread should be NaN")
    assert_true(data.prev_close != data.prev_close, "prev_close should be NaN")
    assert_true(data.last != data.last, "last should be NaN")
    assert_equal(data.volume, 0.0, "volume should be 0")
    assert_equal(data.total_turnover, 0.0, "total_turnover should be 0")
    assert_equal(data.open_interest, 0.0, "open_interest should be 0")
    assert_equal(data.datetime_int, 0, "datetime_int should be 0")
    print("  PASSED")


def test_bar_data_valid() raises:
    print("Test: BarData valid values")
    var data = BarData(
        open=10.0, close=10.5, high=11.0, low=9.5,
        volume=1000.0, total_turnover=10500.0,
        limit_up=11.5, limit_down=9.0,
        settlement=10.3, prev_settlement=10.2,
        open_interest=500.0, discount_rate=0.05,
        acc_net_value=1.5, unit_net_value=1.4,
        basis_spread=0.2, datetime_int=20240101100000,
        prev_close=10.0, last=10.5
    )
    assert_equal(data.open, 10.0)
    assert_equal(data.close, 10.5)
    assert_equal(data.high, 11.0)
    assert_equal(data.low, 9.5)
    assert_equal(data.volume, 1000.0)
    assert_equal(data.limit_up, 11.5)
    assert_equal(data.limit_down, 9.0)
    print("  PASSED")


# ============================================================
# PartialBarObject Tests
# ============================================================

def test_partial_bar_basic_props() raises:
    print("Test: PartialBarObject basic properties")
    var dt = DateTime(2024, 6, 15, 10, 30, 0, 0)
    var ins = create_stock_instrument("000001.XSHE", "000001", dt, EXCHANGE.XSHE)
    var data = BarData(
        open=10.0, close=NAN_VALUE, high=NAN_VALUE, low=NAN_VALUE,
        volume=1000.0, total_turnover=10500.0,
        limit_up=11.0, limit_down=9.0,
        last=10.3,
        datetime_int=0, prev_close=9.8, prev_settlement=9.9,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )
    var pbo = create_partial_bar_object("000001.XSHE", ins, dt, data)

    assert_equal(pbo.order_book_id(), "000001.XSHE")
    assert_equal(pbo.symbol(), "000001")
    assert_equal(pbo.open(), 10.0)
    assert_equal(pbo.last(), 10.3)
    assert_equal(pbo.volume(), 1000.0)
    assert_equal(pbo.total_turnover(), 10500.0)
    assert_equal(pbo.prev_close(), 9.8)
    assert_equal(pbo.prev_settlement(), 9.9)
    print("  PASSED")


def test_partial_bar_datetime_priority() raises:
    print("Test: PartialBarObject datetime priority (_dt > data > fallback)")
    var dt = DateTime(2024, 6, 15, 10, 30, 0, 0)
    var ins = create_stock_instrument("000001.XSHE", "000001", dt, EXCHANGE.XSHE)

    var data_with_dt = BarData(
        open=10.0, close=NAN_VALUE, high=NAN_VALUE, low=NAN_VALUE,
        volume=1000.0, total_turnover=10500.0,
        last=10.0, datetime_int=20240101100000,
        prev_close=0.0, prev_settlement=0.0,
        limit_up=0.0, limit_down=0.0,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )

    var pbo_valid_dt = create_partial_bar_object("000001.XSHE", ins, dt, data_with_dt)
    assert_equal(pbo_valid_dt.datetime().year, 2024, "_dt takes priority when year > 1970")

    var epoch_dt = DateTime(1970, 1, 1, 0, 0, 0, 0)
    var pbo_fallback = create_partial_bar_object("000001.XSHE", ins, epoch_dt, data_with_dt)
    var result_dt = pbo_fallback.datetime()
    assert_true(result_dt.year > 1970, "Should parse datetime_int when _dt is epoch")

    var data_no_dt = BarData(
        open=10.0, close=NAN_VALUE, high=NAN_VALUE, low=NAN_VALUE,
        volume=1000.0, total_turnover=10500.0,
        last=10.0, datetime_int=0,
        prev_close=0.0, prev_settlement=0.0,
        limit_up=0.0, limit_down=0.0,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )
    var pbo_epoch = create_partial_bar_object("000001.XSHE", ins, epoch_dt, data_no_dt)
    assert_equal(pbo_epoch.datetime().year, 1970, "Returns _dt when no datetime_int")
    print("  PASSED")


def test_partial_bar_limit_up_down() raises:
    print("Test: PartialBarObject limit_up/limit_down (NaN when 0 or missing)")
    var dt = DateTime(2024, 6, 15, 10, 30, 0, 0)
    var ins = create_stock_instrument("000001.XSHE", "000001", dt, EXCHANGE.XSHE)

    var data_with_limits = BarData(
        open=10.0, close=NAN_VALUE, high=NAN_VALUE, low=NAN_VALUE,
        volume=1000.0, total_turnover=10500.0,
        limit_up=11.0, limit_down=9.0,
        last=10.0, datetime_int=0,
        prev_close=0.0, prev_settlement=0.0,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )
    var pbo = create_partial_bar_object("000001.XSHE", ins, dt, data_with_limits)
    assert_equal(pbo.limit_up(), 11.0, "limit_up returns value when non-zero")
    assert_equal(pbo.limit_down(), 9.0, "limit_down returns value when non-zero")

    var data_zero_limit = BarData(
        open=10.0, close=NAN_VALUE, high=NAN_VALUE, low=NAN_VALUE,
        volume=1000.0, total_turnover=10500.0,
        limit_up=0.0, limit_down=0.0,
        last=10.0, datetime_int=0,
        prev_close=0.0, prev_settlement=0.0,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )
    var pbo_zero = create_partial_bar_object("000001.XSHE", ins, dt, data_zero_limit)
    assert_true(pbo_zero.limit_up() != pbo_zero.limit_up(), "limit_up is NaN when 0")
    assert_true(pbo_zero.limit_down() != pbo_zero.limit_down(), "limit_down is NaN when 0")
    print("  PASSED")


def test_partial_bar_isnan() raises:
    print("Test: PartialBarObject isnan")
    var dt = DateTime(2024, 6, 15, 10, 30, 0, 0)
    var ins = create_stock_instrument("000001.XSHE", "000001", dt, EXCHANGE.XSHE)

    var nan_data = create_nan_bar_data()
    var pbo_nan = create_partial_bar_object("000001.XSHE", ins, dt, nan_data)
    assert_true(pbo_nan.isnan(), "isnan True when close is NaN")

    var valid_data = BarData(
        open=10.0, close=10.5, high=NAN_VALUE, low=NAN_VALUE,
        volume=1000.0, total_turnover=10500.0,
        limit_up=0.0, limit_down=0.0,
        last=10.5, datetime_int=0,
        prev_close=0.0, prev_settlement=0.0,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )
    var pbo_valid = create_partial_bar_object("000001.XSHE", ins, dt, valid_data)
    assert_false(pbo_valid.isnan(), "isnan False when close is valid")
    print("  PASSED")


# ============================================================
# BarObject Tests - Basic Properties
# ============================================================

def test_bar_object_all_ohlcv() raises:
    print("Test: BarObject OHLCV properties")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0,
        high=11.0,
        low=9.5,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0
    )
    assert_equal(bar.order_book_id(), "000001.XSHE")
    assert_equal(bar.symbol(), "000001.XSHE", "symbol equals order_book_id when created via create_bar_object")
    assert_equal(bar.open(), 10.0)
    assert_equal(bar.high(), 11.0)
    assert_equal(bar.low(), 9.5)
    assert_equal(bar.close(), 10.5)
    assert_equal(bar.volume(), 1000000.0)
    assert_equal(bar.total_turnover(), 10500000.0)
    print("  PASSED")


def test_bar_object_last_equals_close() raises:
    print("Test: BarObject.last == BarObject.close (Python parity)")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    assert_equal(bar.last(), bar.close(), "last must equal close in BarObject")
    print("  PASSED")


def test_bar_object_is_trading() raises:
    print("Test: BarObject.is_trading based on volume")
    var trading = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    assert_true(trading.is_trading())

    var not_trading = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(4, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=0.0, total_turnover=0.0
    )
    assert_false(not_trading.is_trading())
    print("  PASSED")


def test_bar_object_suspended() raises:
    print("Test: BarObject.suspended (True for NaN bars)")
    var nan_bar = create_nan_bar_object("000001.XSHE")
    assert_true(nan_bar.suspended(), "NaN bar should be suspended")

    var normal_bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0,
        suspended=False
    )
    assert_false(normal_bar.suspended(), "Normal non-suspended bar")

    var susp_bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0,
        suspended=True
    )
    assert_true(susp_bar.suspended(), "Explicitly suspended bar")
    print("  PASSED")


def test_bar_object_isnan() raises:
    print("Test: BarObject.isnan")
    var nan_bar = create_nan_bar_object("000001.XSHE")
    assert_true(nan_bar.isnan())

    var valid_bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    assert_false(valid_bar.isnan())
    print("  PASSED")


# ============================================================
# BarObject Tests - Limit Up/Down
# ============================================================

def test_bar_object_limit_up_down_valid() raises:
    print("Test: BarObject limit_up/limit_down with valid values")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0,
        limit_up=11.55, limit_down=9.45
    )
    assert_equal(bar.limit_up(), 11.55)
    assert_equal(bar.limit_down(), 9.45)
    print("  PASSED")


def test_bar_object_limit_up_down_zero_is_nan() raises:
    print("Test: BarObject limit_up/limit_down return NaN when 0")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0,
        limit_up=0.0, limit_down=0.0
    )
    assert_true(bar.limit_up() != bar.limit_up(), "limit_up NaN when 0")
    assert_true(bar.limit_down() != bar.limit_down(), "limit_down NaN when 0")
    print("  PASSED")


# ============================================================
# BarObject Tests - Futures Properties
# ============================================================

def test_bar_object_futures_props() raises:
    print("Test: BarObject futures-specific properties")
    var bar = create_bar_object(
        order_book_id="IF2409.CFFEX",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=3500.0, high=3550.0, low=3480.0, close=3520.0,
        volume=10000.0, total_turnover=352000000.0,
        settlement=3515.0, prev_settlement=3490.0,
        open_interest=50000.0
    )
    assert_equal(bar.settlement(), 3515.0)
    assert_equal(bar.prev_settlement(), 3490.0)
    assert_equal(bar.open_interest(), 50000.0)
    print("  PASSED")


def test_bar_object_fund_props() raises:
    print("Test: BarObject fund properties (discount_rate, net values)")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=1.0, high=1.1, low=0.95, close=1.05,
        volume=500.0, total_turnover=525.0
    )
    assert_true(bar.discount_rate() != bar.discount_rate(), "default NaN")
    assert_true(bar.acc_net_value() != bar.acc_net_value(), "default NaN")
    assert_true(bar.unit_net_value() != bar.unit_net_value(), "default NaN")
    print("  PASSED")


def test_bar_object_prev_close_prev_settlement() raises:
    print("Test: BarObject prev_close and prev_settlement")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0,
        prev_close=10.3, prev_settlement=10.25
    )
    assert_equal(bar.prev_close(), 10.3)
    assert_equal(bar.prev_settlement(), 10.25)
    print("  PASSED")


# ============================================================
# BarObject Tests - VWAP and MAVG
# ============================================================

def test_bar_vwap_with_volume() raises:
    print("Test: BarObject.vwap with volume > 0")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000000.0, total_turnover=10500000.0
    )
    var result = bar.vwap(5)
    assert_equal(result, 10.5, "VWAP = total_turnover / volume")
    print("  PASSED")


def test_bar_vwap_no_volume() raises:
    print("Test: BarObject.vwap with volume == 0")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=0.0, total_turnover=0.0
    )
    var result = bar.vwap(5)
    assert_equal(result, 0.0, "VWAP = 0 when no volume")
    print("  PASSED")


def test_bar_vwap_frequency_param() raises:
    print("Test: BarObject.vwap accepts frequency parameter")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=2000.0, total_turnover=21000.0
    )
    var result_d = bar.vwap(10, "1d")
    var result_m = bar.vwap(30, "1m")
    assert_equal(result_d, 10.5)
    assert_equal(result_m, 10.5)
    print("  PASSED")


def test_bar_mavg_returns_close() raises:
    print("Test: BarObject.mavg returns close price (standalone stub)")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    var result = bar.mavg(5)
    assert_equal(result, 10.5, "mavg returns close in standalone mode")
    print("  PASSED")


def test_bar_mavg_frequency_param() raises:
    print("Test: BarObject.mavg accepts intervals and frequency params")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    var r1 = bar.mavg(5, "1d")
    var r2 = bar.mavg(20, "1m")
    assert_equal(r1, 10.5)
    assert_equal(r2, 10.5)
    print("  PASSED")


# ============================================================
# BarObject Tests - basis_spread
# ============================================================

def test_bar_basis_spread_default_nan() raises:
    print("Test: BarObject.basis_spread default NaN")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    assert_true(bar.basis_spread() != bar.basis_spread(), "default basis_spread is NaN")
    print("  PASSED")


# ============================================================
# BarObject Tests - datetime priority
# ============================================================

def test_bar_datetime_priority() raises:
    print("Test: BarObject datetime _dt > data.int > fallback")
    var dt = DateTime(2024, 6, 15, 14, 50, 0, 0)
    var bar = create_bar_object(
        order_book_id="000001.XSHE", dt=dt,
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    assert_equal(bar.datetime().year, 2024)
    assert_equal(bar.datetime().month, 6)
    print("  PASSED")


def test_bar_instrument_access() raises:
    print("Test: BarObject.instrument() returns correct type")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 0, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    var ins = bar.instrument()
    assert_equal(ins.order_book_id(), "000001.XSHE")
    assert_equal(ins.symbol(), "000001.XSHE", "symbol matches order_book_id in create_bar_object")
    assert_equal(ins.type(), INSTRUMENT_TYPE.CS)
    print("  PASSED")


# ============================================================
# Factory Function Tests
# ============================================================

def test_create_simple_bar() raises:
    print("Test: create_simple_bar calculates turnover as vol*close")
    var bar = create_simple_bar(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 0, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0
    )
    assert_equal(bar.order_book_id(), "000001.XSHE")
    assert_equal(bar.total_turnover(), 10500.0, "turnover = volume * close")
    print("  PASSED")


def test_create_nan_bar_object() raises:
    print("Test: create_nan_bar_object")
    var bar = create_nan_bar_object("IF2409.CFFEX")
    assert_equal(bar.order_book_id(), "IF2409.CFFEX")
    assert_true(bar.isnan())
    assert_true(bar.suspended())
    assert_false(bar.is_trading())
    print("  PASSED")


def test_create_bar_object_with_instrument() raises:
    print("Test: create_bar_object_with_instrument")
    var dt = DateTime(2024, 6, 15, 10, 0, 0, 0)
    var ins = create_stock_instrument("600000.XSHG", "600000", dt, EXCHANGE.XSHG)
    var data = BarData(
        open=12.0, close=12.5, high=13.0, low=11.8,
        volume=2000.0, total_turnover=25000.0,
        limit_up=13.75, limit_down=11.25,
        settlement=12.3, prev_settlement=12.1,
        open_interest=0.0, discount_rate=NAN_VALUE,
        acc_net_value=NAN_VALUE, unit_net_value=NAN_VALUE,
        basis_spread=NAN_VALUE, datetime_int=0,
        prev_close=12.1, last=12.5
    )
    var bar = create_bar_object_with_instrument(ins, dt, data, suspended=False)
    assert_equal(bar.order_book_id(), "600000.XSHG")
    assert_equal(bar.close(), 12.5)
    assert_equal(bar.limit_up(), 13.75)
    print("  PASSED")


def test_bar_object_from_dict_full() raises:
    print("Test: bar_object_from_dict with full data")
    var dt = DateTime(2024, 6, 15, 10, 0, 0, 0)
    var data = Dict[String, Float64]()
    data["open"] = 10.0
    data["close"] = 10.5
    data["high"] = 11.0
    data["low"] = 9.5
    data["volume"] = 1000.0
    data["total_turnover"] = 10500.0
    data["limit_up"] = 11.55
    data["limit_down"] = 9.45
    data["settlement"] = 10.3
    data["prev_settlement"] = 10.2
    data["open_interest"] = 500.0
    data["prev_close"] = 10.3

    var bar = bar_object_from_dict("000001.XSHE", dt, data)
    assert_equal(bar.open(), 10.0)
    assert_equal(bar.close(), 10.5)
    assert_equal(bar.high(), 11.0)
    assert_equal(bar.low(), 9.5)
    assert_equal(bar.volume(), 1000.0)
    assert_equal(bar.limit_up(), 11.55)
    assert_equal(bar.limit_down(), 9.45)
    assert_equal(bar.settlement(), 10.3)
    assert_equal(bar.prev_settlement(), 10.2)
    assert_equal(bar.open_interest(), 500.0)
    assert_equal(bar.prev_close(), 10.3)
    print("  PASSED")


def test_bar_object_from_dict_partial() raises:
    print("Test: bar_object_from_dict with partial data (missing = NaN)")
    var dt = DateTime(2024, 6, 15, 10, 0, 0, 0)
    var data = Dict[String, Float64]()
    data["close"] = 10.5
    data["volume"] = 500.0

    var bar = bar_object_from_dict("000001.XSHE", dt, data)
    assert_equal(bar.close(), 10.5)
    assert_equal(bar.volume(), 500.0)
    assert_true(bar.open() != bar.open(), "missing open -> NaN")
    assert_true(bar.high() != bar.high(), "missing high -> NaN")
    assert_true(bar.low() != bar.low(), "missing low -> NaN")
    print("  PASSED")


# ============================================================
# BarMap Tests
# ============================================================

def test_bar_map_creation() raises:
    print("Test: BarMap creation with default and custom frequency")
    var bm1 = create_bar_map()
    assert_equal(bm1.frequency(), "1d")

    var bm2 = create_bar_map("1m")
    assert_equal(bm2.frequency(), "1m")
    print("  PASSED")


def test_bar_map_update_dt() raises:
    print("Test: BarMap.update_dt clears cache")
    var bm = create_bar_map()
    var dt1 = DateTime(2024, 6, 15, 10, 0, 0, 0)
    var dt2 = DateTime(2024, 6, 16, 10, 0, 0, 0)

    bm.update_dt(dt1)
    assert_equal(bm.dt().year, 2024)
    assert_equal(bm.dt().day, 15)

    bm.update_dt(dt2)
    assert_equal(bm.dt().day, 16)
    print("  PASSED")


def test_bar_map_update_universe() raises:
    print("Test: BarMap.update_universe")
    var bm = create_bar_map()
    var universe = Set[String]()
    universe.add("000001.XSHE")
    universe.add("600000.XSHG")
    universe.add("IF2409.CFFEX")
    bm.update_universe(universe^)

    assert_true(bm.contains("000001.XSHE"))
    assert_true(bm.contains("600000.XSHG"))
    assert_true(bm.contains("IF2409.CFFEX"))
    assert_false(bm.contains("NONEXISTENT"))
    assert_equal(bm.len(), 3)
    print("  PASSED")


def test_bar_map_get_and_set() raises:
    print("Test: BarMap.get and set operations")
    var bm = create_bar_map()
    var universe = Set[String]()
    universe.add("000001.XSHE")
    bm.update_universe(universe^)

    var bar = create_simple_bar(
        "000001.XSHE", DateTime(2024, 6, 15, 10, 0, 0, 0),
        10.0, 11.0, 9.5, 10.5, 1000.0
    )
    bm.set("000001.XSHE", bar)

    var retrieved = bm.get("000001.XSHE")
    assert_equal(retrieved.close(), 10.5)
    print("  PASSED")


def test_bar_map_get_missing_returns_nan() raises:
    print("Test: BarMap.get missing key returns NaN bar")
    var bm = create_bar_map()
    var universe = Set[String]()
    universe.add("000001.XSHE")
    bm.update_universe(universe^)

    var nan_bar = bm.get("000001.XSHE")
    assert_true(nan_bar.isnan(), "Missing key returns NaN bar")
    assert_equal(nan_bar.order_book_id(), "000001.XSHE")
    print("  PASSED")


def test_bar_map_keys_values_items() raises:
    print("Test: BarMap keys, values, items")
    var bm = create_bar_map()
    var universe = Set[String]()
    universe.add("000001.XSHE")
    universe.add("600000.XSHG")
    bm.update_universe(universe^)

    var bar1 = create_simple_bar(
        "000001.XSHE", DateTime(2024, 6, 15, 10, 0, 0, 0),
        10.0, 11.0, 9.5, 10.5, 1000.0
    )
    var bar2 = create_simple_bar(
        "600000.XSHG", DateTime(2024, 6, 15, 10, 0, 0, 0),
        20.0, 21.0, 19.5, 20.5, 2000.0
    )
    bm.set("000001.XSHE", bar1)
    bm.set("600000.XSHG", bar2)

    var keys = bm.keys()
    assert_equal(len(keys), 2)

    var vals = bm.values()
    assert_equal(len(vals), 2)

    var items = bm.items()
    assert_equal(len(items), 2)
    print("  PASSED")


def test_bar_map_str_representation() raises:
    print("Test: BarMap string representation")
    var bm = create_bar_map()
    var universe = Set[String]()
    for i in range(15):
        universe.add("STOCK" + String(i))
    bm.update_universe(universe^)

    var s = bm.__str__()
    assert_true(len(s) > 10, "BarMap str should have content")
    print("  PASSED")


def test_bar_map_empty() raises:
    print("Test: BarMap empty state")
    var bm = create_bar_map()
    assert_equal(bm.len(), 0)
    assert_false(bm.contains("anything"))
    print("  PASSED")


# ============================================================
# Copyable Tests
# ============================================================

def test_bar_object_copyable() raises:
    print("Test: BarObject copy semantics")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    var copied = bar.copy()
    assert_equal(copied.order_book_id(), bar.order_book_id())
    assert_equal(copied.close(), bar.close())
    assert_equal(copied.volume(), bar.volume())
    print("  PASSED")


def test_bar_data_copyable() raises:
    print("Test: BarData copy semantics")
    var data = BarData(
        open=10.0, close=10.5, high=11.0, low=9.5,
        volume=1000.0, total_turnover=10500.0,
        limit_up=11.0, limit_down=9.0,
        settlement=10.3, prev_settlement=10.2,
        open_interest=500.0, discount_rate=0.05,
        acc_net_value=1.5, unit_net_value=1.4,
        basis_spread=0.2, datetime_int=20240101100000,
        prev_close=10.0, last=10.5
    )
    var copied = data.copy()
    assert_equal(copied.open, 10.0)
    assert_equal(copied.close, 10.5)
    print("  PASSED")


# ============================================================
# Writable / repr Tests
# ============================================================

def test_bar_object_writable() raises:
    print("Test: BarObject write_to (repr)")
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 6, 15, 10, 30, 0, 0),
        open=10.0, high=11.0, low=9.5, close=10.5,
        volume=1000.0, total_turnover=10500.0
    )
    var s = String(bar)
    assert_true(len(s) > 10, "BarObject repr should have content")
    print("  PASSED")


def test_partial_bar_writable() raises:
    print("Test: PartialBarObject write_to (repr)")
    var dt = DateTime(2024, 6, 15, 9, 25, 0, 0)
    var ins = create_stock_instrument("000001.XSHE", "000001", dt, EXCHANGE.XSHE)
    var data = BarData(
        open=10.0, close=NAN_VALUE, high=NAN_VALUE, low=NAN_VALUE,
        volume=100.0, total_turnover=1000.0,
        limit_up=0.0, limit_down=0.0,
        last=10.0, datetime_int=0,
        prev_close=0.0, prev_settlement=0.0,
        settlement=NAN_VALUE, open_interest=0.0,
        discount_rate=NAN_VALUE, acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE, basis_spread=NAN_VALUE
    )
    var pbo = create_partial_bar_object("000001.XSHE", ins, dt, data)
    var s = String(pbo)
    assert_true(len(s) > 10, "PartialBarObject repr should have content")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
