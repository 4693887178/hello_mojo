"""
Comprehensive Test for utils/testing/mocking.mojo
Group 07 - File 04 (Enhanced)

Coverage:
  1. mock_instrument() — default params, custom params, symbol extraction
  2. mock_bar() — default values, custom OHLCV, instrument propagation
  3. mock_tick() — default values, custom values, instrument/dt propagation
  4. MockDataProxy — get_bar (cached/uncached), get_instrument (cached/uncached)
  5. create_mock_order() — default params, custom params
  6. Cross-function integration — full workflow simulation
  7. Edge cases — empty order_book_id, different exchanges
  8. Alignment with Python original behavior
"""

from rqmojo.utils.testing.mocking import (
    mock_instrument,
    mock_bar,
    mock_tick,
    MockDataProxy,
    create_mock_data_proxy,
    create_mock_order,
)
from rqmojo.model.order import Order
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.instrument import Instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def _test_dt() -> DateTime:
    return DateTime(2024, 6, 15, 10, 30, 0, 0)


# ============================================================
# 1. mock_instrument tests
# ============================================================

def test_mock_instrument_default_params() raises:
    var ins = mock_instrument()
    assert_equal(ins.order_book_id(), "000001", "default order_book_id")
    assert_equal(ins.symbol(), "000001", "symbol extracted from order_book_id")
    assert_equal(ins.type(), INSTRUMENT_TYPE.CS, "default type is CS")
    assert_equal(ins.exchange(), EXCHANGE.XSHE, "default exchange is XSHE")


def test_mock_instrument_custom_order_book_id() raises:
    var ins = mock_instrument(order_book_id="600000.XSHG")
    assert_equal(ins.order_book_id(), "600000.XSHG")
    assert_equal(ins.symbol(), "600000", "symbol from order_book_id before dot")


def test_mock_instrument_custom_exchange() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE", exchange=EXCHANGE.XSHE)
    assert_equal(ins.exchange(), EXCHANGE.XSHE)

    var ins2 = mock_instrument(order_book_id="600000.XSHG", exchange=EXCHANGE.XSHG)
    assert_equal(ins2.exchange(), EXCHANGE.XSHG)


def test_mock_instrument_symbol_extraction_no_dot() raises:
    var ins = mock_instrument(order_book_id="000001")
    assert_equal(ins.symbol(), "000001", "no dot → full string as symbol")


def test_mock_instrument_listed_date() raises:
    var ins = mock_instrument()
    var ld = ins.listed_date()
    assert_equal(ld.year, 1990)
    assert_equal(ld.month, 1)
    assert_equal(ld.day, 1)


def test_mock_instrument_round_lot() raises:
    var ins = mock_instrument()
    assert_equal(ins.round_lot(), 100, "stock round_lot is 100")


def test_mock_instrument_status() raises:
    var ins = mock_instrument()
    assert_equal(ins.status(), "Active")


def test_mock_instrument_copyable() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var ins_copy = ins.copy()
    assert_equal(ins_copy.order_book_id(), ins.order_book_id())
    assert_equal(ins_copy.symbol(), ins.symbol())


# ============================================================
# 2. mock_bar tests
# ============================================================

def test_mock_bar_default_values() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    assert_equal(bar.order_book_id(), "000001.XSHE", "bar inherits order_book_id")
    assert_equal(bar.open(), 10.0, "default open")
    assert_equal(bar.high(), 11.0, "default high")
    assert_equal(bar.low(), 9.0, "default low")
    assert_equal(bar.close(), 10.5, "default close")
    assert_equal(bar.volume(), 1000000.0, "default volume")
    assert_equal(bar.total_turnover(), 10500000.0, "default total_turnover")


def test_mock_bar_custom_ohlcv() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(
        ins, dt,
        open=20.0,
        high=22.0,
        low=19.0,
        close=21.5,
        volume=500000.0,
        total_turnover=10750000.0,
    )
    assert_equal(bar.open(), 20.0)
    assert_equal(bar.high(), 22.0)
    assert_equal(bar.low(), 19.0)
    assert_equal(bar.close(), 21.5)
    assert_equal(bar.volume(), 500000.0)
    assert_equal(bar.total_turnover(), 10750000.0)


def test_mock_bar_datetime_propagation() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    var bar_dt = bar.datetime()
    assert_equal(bar_dt.year, 2024)
    assert_equal(bar_dt.month, 6)
    assert_equal(bar_dt.day, 15)
    assert_equal(bar_dt.hour, 10)
    assert_equal(bar_dt.minute, 30)


def test_mock_bar_instrument_reference() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    assert_equal(bar.instrument().order_book_id(), "000001.XSHE")
    assert_true(len(bar.symbol()) > 0, "bar has a symbol")


def test_mock_bar_last_equals_close() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    assert_equal(bar.last(), bar.close(), "last should equal close for bars")


def test_mock_bar_is_trading() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    assert_true(bar.is_trading(), "bar with volume > 0 is trading")


def test_mock_bar_suspended_false() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    assert_false(bar.suspended())


def test_mock_bar_vwap() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    var expected_vwap = bar.total_turnover() / bar.volume()
    assert_equal(bar.vwap(), expected_vwap)


def test_mock_bar_copyable() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    var bar_copy = bar.copy()
    assert_equal(bar_copy.order_book_id(), bar.order_book_id())
    assert_equal(bar_copy.close(), bar.close())
    assert_equal(bar_copy.volume(), bar.volume())


# ============================================================
# 3. mock_tick tests
# ============================================================

def test_mock_tick_default_values() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_equal(tick.order_book_id(), "000001.XSHE")
    assert_equal(tick.last, 10.5, "default last")
    assert_equal(tick.volume, 10000.0, "default volume")
    assert_equal(tick.total_turnover, 105000.0, "default total_turnover")


def test_mock_tick_custom_values() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(
        ins, dt,
        last=15.8,
        volume=20000.0,
        total_turnover=316000.0,
    )
    assert_equal(tick.last, 15.8)
    assert_equal(tick.volume, 20000.0)
    assert_equal(tick.total_turnover, 316000.0)


def test_mock_tick_datetime_propagation() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_equal(tick.datetime.year, 2024)
    assert_equal(tick.datetime.month, 6)
    assert_equal(tick.datetime.day, 15)


def test_mock_tick_close_equals_last() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_equal(tick.close(), tick.last, "tick close() returns last")


def test_mock_tick_instrument_reference() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_equal(tick.instrument().order_book_id(), "000001.XSHE")


def test_mock_tick_not_nan() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_false(tick.isnan())


def test_mock_tick_open_high_low_defaults() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_equal(tick.open, 10.0, "default open from create_tick_object")
    assert_equal(tick.high, 11.0, "default high")
    assert_equal(tick.low, 9.0, "default low")


def test_mock_tick_getitem_access() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    assert_equal(tick["last"], tick.last)
    assert_equal(tick["volume"], tick.volume)
    assert_equal(tick["open"], tick.open)
    assert_equal(tick["high"], tick.high)
    assert_equal(tick["low"], tick.low)


def test_mock_tick_copyable() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var tick = mock_tick(ins, dt)
    var tick_copy = tick.copy()
    assert_equal(tick_copy.last, tick.last)
    assert_equal(tick_copy.volume, tick.volume)
    assert_equal(tick_copy.order_book_id(), tick.order_book_id())


# ============================================================
# 4. MockDataProxy tests
# ============================================================

def test_mock_data_proxy_init() raises:
    var proxy = create_mock_data_proxy()
    var bar = proxy.get_bar("000001.XSHE", _test_dt())
    assert_equal(bar.order_book_id(), "000001.XSHE", "proxy works")


def test_mock_data_proxy_get_bar_uncached() raises:
    var proxy = create_mock_data_proxy()
    var dt = _test_dt()
    var bar = proxy.get_bar("000001.XSHE", dt)
    assert_equal(bar.order_book_id(), "000001.XSHE")
    assert_equal(bar.open(), 10.0, "default uncached bar open")
    assert_equal(bar.close(), 10.5, "default uncached bar close")


def test_mock_data_proxy_get_bar_cached() raises:
    var proxy = create_mock_data_proxy()
    var dt = _test_dt()

    var bar1 = proxy.get_bar("000001.XSHE", dt)
    var bar2 = proxy.get_bar("000001.XSHE", dt)
    assert_equal(bar1.order_book_id(), bar2.order_book_id())
    assert_equal(bar1.close(), bar2.close())


def test_mock_data_proxy_get_bar_different_ids() raises:
    var proxy = create_mock_data_proxy()
    var dt = _test_dt()

    var bar1 = proxy.get_bar("000001.XSHE", dt)
    var bar2 = proxy.get_bar("600000.XSHG", dt)
    assert_equal(bar1.order_book_id(), "000001.XSHE")
    assert_equal(bar2.order_book_id(), "600000.XSHG")


def test_mock_data_proxy_get_instrument_uncached() raises:
    var proxy = create_mock_data_proxy()
    var ins = proxy.get_instrument("000001.XSHE")
    assert_equal(ins.order_book_id(), "000001.XSHE")
    assert_equal(ins.symbol(), "000001")
    assert_equal(ins.exchange(), EXCHANGE.XSHE)


def test_mock_data_proxy_get_instrument_cached() raises:
    var proxy = create_mock_data_proxy()
    var ins1 = proxy.get_instrument("000001.XSHE")
    var ins2 = proxy.get_instrument("000001.XSHE")
    assert_equal(ins1.order_book_id(), ins2.order_book_id())


def test_mock_data_proxy_get_instrument_no_dot() raises:
    var proxy = create_mock_data_proxy()
    var ins = proxy.get_instrument("000001")
    assert_equal(ins.symbol(), "000001")


def test_mock_data_proxy_copyable() raises:
    var proxy = create_mock_data_proxy()
    var proxy_copy = proxy.copy()
    var dt = _test_dt()
    var bar = proxy_copy.get_bar("000001.XSHE", dt)
    assert_equal(bar.order_book_id(), "000001.XSHE")


# ============================================================
# 5. create_mock_order tests
# ============================================================

def test_create_mock_order_default_params() raises:
    var order = create_mock_order()
    assert_equal(order.order_book_id, "000001.XSHE", "default order_book_id")
    assert_equal(order.quantity, 100, "default quantity")
    assert_equal(order.side, SIDE.BUY, "default side is BUY")
    assert_equal(order.status, ORDER_STATUS.PENDING_NEW, "initial status PENDING_NEW")
    assert_equal(order.filled_quantity, 0, "initial filled_quantity is 0")
    assert_equal(order.unfilled_quantity, 100, "unfilled equals quantity initially")


def test_create_mock_order_custom_params() raises:
    var order = create_mock_order(
        order_book_id="600000.XSHG",
        quantity=1000,
        price=25.5,
    )
    assert_equal(order.order_book_id, "600000.XSHG")
    assert_equal(order.quantity, 1000)


def test_create_mock_order_is_active() raises:
    var order = create_mock_order()
    assert_true(order.is_active(), "PENDING_NEW orders are active")


def test_create_mock_order_not_filled() raises:
    var order = create_mock_order()
    assert_false(order.is_filled())


def test_create_mock_order_style_market() raises:
    var order = create_mock_order()
    assert_equal(order.order_type().name, "MARKET", "default style is MARKET")


def test_create_mock_order_position_effect_open() raises:
    var order = create_mock_order()
    assert_equal(order.position_effect.name, "OPEN")


def test_create_mock_order_copyable() raises:
    var order = create_mock_order()
    var order_copy = order.copy()
    assert_equal(order_copy.order_book_id, order.order_book_id)
    assert_equal(order_copy.quantity, order.quantity)
    assert_equal(order_copy.side.name, order.side.name)


# ============================================================
# 6. Integration / Workflow tests
# ============================================================

def test_full_workflow_instrument_bar_tick() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt)
    var tick = mock_tick(ins, dt)

    assert_equal(ins.order_book_id(), bar.order_book_id(), "ins-bar order_book_id match")
    assert_equal(bar.order_book_id(), tick.order_book_id(), "bar-tick order_book_id match")
    assert_equal(tick.instrument().order_book_id(), ins.order_book_id(), "tick-ins order_book_id match")


def test_full_workflow_with_proxy() raises:
    var proxy = create_mock_data_proxy()
    var dt = _test_dt()

    var ins = proxy.get_instrument("000001.XSHE")
    var bar = proxy.get_bar("000001.XSHE", dt)
    var tick = mock_tick(ins, dt)
    var order = create_mock_order(order_book_id="000001.XSHE")

    assert_equal(ins.order_book_id(), "000001.XSHE")
    assert_equal(bar.order_book_id(), "000001.XSHE")
    assert_equal(tick.order_book_id(), "000001.XSHE")
    assert_equal(order.order_book_id, "000001.XSHE")


def test_multiple_instruments_different_exchanges() raises:
    var xshe_ins = mock_instrument(order_book_id="000001.XSHE", exchange=EXCHANGE.XSHE)
    var xshg_ins = mock_instrument(order_book_id="600000.XSHG", exchange=EXCHANGE.XSHG)

    assert_equal(xshe_ins.exchange(), EXCHANGE.XSHE)
    assert_equal(xshg_ins.exchange(), EXCHANGE.XSHG)
    assert_not_equal(xshe_ins.exchange().name, xshg_ins.exchange().name)


def test_bar_and_tick_same_instrument_different_dts() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt1 = DateTime(2024, 1, 1, 9, 35, 0, 0)
    var dt2 = DateTime(2024, 1, 1, 10, 30, 0, 0)

    var bar1 = mock_bar(ins, dt1)
    var bar2 = mock_bar(ins, dt2)
    assert_equal(bar1.order_book_id(), bar2.order_book_id())

    var tick1 = mock_tick(ins, dt1)
    var tick2 = mock_tick(ins, dt2)
    assert_equal(tick1.order_book_id(), tick2.order_book_id())


# ============================================================
# 7. Edge cases
# ============================================================

def test_edge_empty_string_order_book_id() raises:
    var ins = mock_instrument(order_book_id="")
    assert_equal(ins.order_book_id(), "")
    assert_equal(ins.symbol(), "")


def test_edge_long_order_book_id() raises:
    var long_id = "12345678901234567890.XSHE"
    var ins = mock_instrument(order_book_id=long_id)
    assert_equal(ins.order_book_id(), long_id)
    assert_equal(ins.symbol(), "12345678901234567890")


def test_edge_zero_volume_bar() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(ins, dt, volume=0.0, total_turnover=0.0)
    assert_equal(bar.volume(), 0.0)
    assert_false(bar.is_trading(), "zero volume → not trading")


def test_edge_large_values() raises:
    var ins = mock_instrument(order_book_id="000001.XSHE")
    var dt = _test_dt()
    var bar = mock_bar(
        ins, dt,
        open=999999.0,
        high=999999.99,
        low=0.01,
        close=888888.88,
        volume=9999999999.0,
        total_turnover=99999999999999.0,
    )
    assert_true(bar.high() > bar.low(), "high > low always")
    assert_true(bar.volume() > 0)


def test_edge_all_shfe_exchange() raises:
    var ins = mock_instrument(order_book_id="CU2409.SHFE", exchange=EXCHANGE.SHFE)
    assert_equal(ins.exchange(), EXCHANGE.SHFE)
    assert_equal(ins.symbol(), "CU2409")


# ============================================================
# Helper assertion
# ============================================================

def assert_not_equal[T: Equatable](a: T, b: T, msg: String = "") raises:
    if a == b:
        if len(msg) > 0:
            raise Error(String("assert_not_equal failed: (") + msg + ")")
        else:
            raise Error("assert_not_equal failed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
