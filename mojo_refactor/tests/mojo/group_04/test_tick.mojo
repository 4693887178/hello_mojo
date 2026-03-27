"""
第四组测试 - model/tick.mojo
测试Mojo版本的Tick对象模块
"""

from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import INSTRUMENT_TYPE, MARKET, EXCHANGE
from rqmojo.utils.typing import DateTime
from std.collections import Dict


def create_test_instrument() -> Instrument:
    return create_stock_instrument(
        order_book_id="000001.XSHE",
        symbol="平安银行",
        listed_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE,
    )


def create_test_datetime() -> DateTime:
    return DateTime(2024, 1, 15, 10, 30, 0)


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_tick_object_exists() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var _ = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    assert_true(True, "TickObject created")


def test_tick_order_book_id() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    assert_equal(tick.order_book_id(), "000001.XSHE", "order_book_id should match")


def test_tick_last() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    assert_equal(tick.last, 10.5, "last should be 10.5")


def test_tick_volume() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    assert_equal(tick.volume, 1000000.0, "volume should be 1000000.0")


def test_tick_total_turnover() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    assert_equal(tick.total_turnover, 10500000.0, "total_turnover should match")


def test_tick_open() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        open=10.0,
    )
    assert_equal(tick.open, 10.0, "open should be 10.0")


def test_tick_high() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        high=11.0,
    )
    assert_equal(tick.high, 11.0, "high should be 11.0")


def test_tick_low() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        low=10.0,
    )
    assert_equal(tick.low, 10.0, "low should be 10.0")


def test_tick_prev_close() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        prev_close=10.2,
    )
    assert_equal(tick.prev_close, 10.2, "prev_close should be 10.2")


def test_tick_limit_up() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        limit_up=11.22,
    )
    assert_equal(tick.limit_up, 11.22, "limit_up should be 11.22")


def test_tick_limit_down() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        limit_down=9.18,
    )
    assert_equal(tick.limit_down, 9.18, "limit_down should be 9.18")


def test_tick_close() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    assert_equal(tick.close(), 10.5, "close should be 10.5")


def test_tick_str() raises:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    var s = String(tick)
    assert_true(s.find("TickObject") >= 0, "String should contain TickObject")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
