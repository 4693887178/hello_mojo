# test_L03_03_tick.mojo
# Module: rqmojo.model.tick
# Python: rqalpha.model.tick
# Level: L03 - Data Model
# Dependencies: instrument, datetime_func

from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.model.instrument import create_stock_instrument, create_future_instrument
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_create_tick_object(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 10.5, 1000000.0, 10500000.0)
        self.check(tick.last == 10.5, "TickObject last is 10.5")
        self.check(tick.volume == 1000000.0, "TickObject volume is 1000000")
        self.check(tick.total_turnover == 10500000.0, "TickObject total_turnover is 10500000")

    fn test_tick_object_order_book_id(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 10.5, 1000000.0, 10500000.0)
        self.check(tick.order_book_id() == "000001.XSHE", "TickObject order_book_id is 000001.XSHE")

    fn test_tick_object_datetime(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 10.5, 1000000.0, 10500000.0)
        self.check(tick.datetime.year == 2024, "TickObject datetime year is 2024")
        self.check(tick.datetime.month == 1, "TickObject datetime month is 1")
        self.check(tick.datetime.day == 1, "TickObject datetime day is 1")

    fn test_tick_object_ohlc(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(
            ins, dt, 10.5, 1000000.0, 10500000.0,
            open=10.0, high=10.8, low=9.9, prev_close=10.0
        )
        self.check(tick.open == 10.0, "TickObject open is 10.0")
        self.check(tick.high == 10.8, "TickObject high is 10.8")
        self.check(tick.low == 9.9, "TickObject low is 9.9")
        self.check(tick.prev_close == 10.0, "TickObject prev_close is 10.0")

    fn test_tick_object_limit(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(
            ins, dt, 10.5, 1000000.0, 10500000.0,
            limit_up=11.0, limit_down=9.0
        )
        self.check(tick.limit_up == 11.0, "TickObject limit_up is 11.0")
        self.check(tick.limit_down == 9.0, "TickObject limit_down is 9.0")

    fn test_tick_object_close(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 10.5, 1000000.0, 10500000.0)
        self.check(tick.close() == 10.5, "TickObject close() returns last")

    fn test_tick_object_str(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 10.5, 1000000.0, 10500000.0)
        var str_repr = tick.__str__()
        self.check(str_repr.find("TickObject") >= 0, "TickObject __str__ contains TickObject")
        self.check(str_repr.find("000001.XSHE") >= 0, "TickObject __str__ contains order_book_id")

    fn test_tick_object_future(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX, "IF")
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 4000.0, 10000.0, 12000000000.0)
        self.check(tick.last == 4000.0, "Future TickObject last is 4000.0")
        self.check(tick.order_book_id() == "IF2401.CFFEX", "Future TickObject order_book_id")

    fn test_tick_object_copy(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick1 = create_tick_object(ins, dt, 10.5, 1000000.0, 10500000.0)
        var tick2 = tick1
        self.check(tick2.last == 10.5, "TickObject copy last is 10.5")
        self.check(tick2.volume == 1000000.0, "TickObject copy volume is 1000000")

    fn test_tick_object_zero_values(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = create_tick_object(ins, dt, 0.0, 0.0, 0.0)
        self.check(tick.last == 0.0, "TickObject zero last is 0.0")
        self.check(tick.volume == 0.0, "TickObject zero volume is 0.0")

    fn run_all(mut self):
        print("=" * 60)
        print("L03_03_tick Module Tests")
        print("=" * 60)
        
        self.test_create_tick_object()
        self.test_tick_object_order_book_id()
        self.test_tick_object_datetime()
        self.test_tick_object_ohlc()
        self.test_tick_object_limit()
        self.test_tick_object_close()
        self.test_tick_object_str()
        self.test_tick_object_future()
        self.test_tick_object_copy()
        self.test_tick_object_zero_values()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
