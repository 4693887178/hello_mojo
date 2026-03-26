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


def test_tick_object_exists() -> Bool:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    return True


def test_tick_order_book_id() -> Bool:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    return tick.order_book_id() == "000001.XSHE"


def test_tick_last() -> Bool:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    return tick.last == 10.5


def test_tick_volume() -> Bool:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    return tick.volume == 1000000.0


def test_tick_total_turnover() -> Bool:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    return tick.total_turnover == 10500000.0


def test_tick_open() -> Bool:
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
    return tick.open == 10.0


def test_tick_high() -> Bool:
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
    return tick.high == 11.0


def test_tick_low() -> Bool:
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
    return tick.low == 10.0


def test_tick_prev_close() -> Bool:
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
    return tick.prev_close == 10.2


def test_tick_limit_up() -> Bool:
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
    return tick.limit_up == 11.22


def test_tick_limit_down() -> Bool:
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
    return tick.limit_down == 9.18


def test_tick_close() -> Bool:
    var ins = create_test_instrument()
    var dt = create_test_datetime()
    var tick = create_tick_object(
        instrument=ins,
        dt=dt,
        last=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
    )
    return tick.close() == 10.5


def test_tick_str() -> Bool:
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
    return s.find("TickObject") >= 0


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: model/tick.mojo")
    print("=" * 60)
    
    if test_tick_object_exists():
        print("PASS: test_tick_object_exists")
        passed += 1
    else:
        print("FAIL: test_tick_object_exists")
        failed += 1
    
    if test_tick_order_book_id():
        print("PASS: test_tick_order_book_id")
        passed += 1
    else:
        print("FAIL: test_tick_order_book_id")
        failed += 1
    
    if test_tick_last():
        print("PASS: test_tick_last")
        passed += 1
    else:
        print("FAIL: test_tick_last")
        failed += 1
    
    if test_tick_volume():
        print("PASS: test_tick_volume")
        passed += 1
    else:
        print("FAIL: test_tick_volume")
        failed += 1
    
    if test_tick_total_turnover():
        print("PASS: test_tick_total_turnover")
        passed += 1
    else:
        print("FAIL: test_tick_total_turnover")
        failed += 1
    
    if test_tick_open():
        print("PASS: test_tick_open")
        passed += 1
    else:
        print("FAIL: test_tick_open")
        failed += 1
    
    if test_tick_high():
        print("PASS: test_tick_high")
        passed += 1
    else:
        print("FAIL: test_tick_high")
        failed += 1
    
    if test_tick_low():
        print("PASS: test_tick_low")
        passed += 1
    else:
        print("FAIL: test_tick_low")
        failed += 1
    
    if test_tick_prev_close():
        print("PASS: test_tick_prev_close")
        passed += 1
    else:
        print("FAIL: test_tick_prev_close")
        failed += 1
    
    if test_tick_limit_up():
        print("PASS: test_tick_limit_up")
        passed += 1
    else:
        print("FAIL: test_tick_limit_up")
        failed += 1
    
    if test_tick_limit_down():
        print("PASS: test_tick_limit_down")
        passed += 1
    else:
        print("FAIL: test_tick_limit_down")
        failed += 1
    
    if test_tick_close():
        print("PASS: test_tick_close")
        passed += 1
    else:
        print("FAIL: test_tick_close")
        failed += 1
    
    if test_tick_str():
        print("PASS: test_tick_str")
        passed += 1
    else:
        print("FAIL: test_tick_str")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
