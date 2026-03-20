# test_L03_04_bar.mojo
# Module: rqmojo.model.bar
# Python: rqalpha.model.bar
# Level: L03 - Data Model
# Dependencies: instrument, datetime_func

from rqmojo.model.bar import BarObject, create_bar_object, create_simple_bar
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

    fn test_create_bar_object(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.open == 10.0, "BarObject open is 10.0")
        self.check(bar.high == 10.5, "BarObject high is 10.5")
        self.check(bar.low == 9.8, "BarObject low is 9.8")
        self.check(bar.close == 10.2, "BarObject close is 10.2")

    fn test_bar_object_volume(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.volume == 1000000.0, "BarObject volume is 1000000")
        self.check(bar.total_turnover == 10200000.0, "BarObject total_turnover is 10200000")

    fn test_bar_object_is_trading(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.is_trading() == True, "BarObject is_trading is True")

    fn test_bar_object_not_trading(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 0.0, 0.0, trading=False)
        self.check(bar.is_trading() == False, "BarObject is_trading is False when volume is 0")

    fn test_bar_object_limit_up_down(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0, 11.0, 9.0)
        self.check(bar.limit_up == 11.0, "BarObject limit_up is 11.0")
        self.check(bar.limit_down == 9.0, "BarObject limit_down is 9.0")

    fn test_bar_object_last(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.last() == bar.close, "BarObject last() equals close")

    fn test_bar_object_vwap(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.vwap() == 10.2, "BarObject vwap is total_turnover/volume")

    fn test_bar_object_vwap_zero_volume(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 0.0, 0.0)
        self.check(bar.vwap() == 0.0, "BarObject vwap is 0 when volume is 0")

    fn test_bar_object_suspended(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0, suspended=True)
        self.check(bar.suspended() == True, "BarObject suspended is True")

    fn test_bar_object_isnan(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.isnan() == False, "BarObject isnan is False for valid bar")

    fn test_bar_object_isnan_zero_close(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        self.check(bar.isnan() == True, "BarObject isnan is True for zero close")

    fn test_bar_object_str(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        var str_repr = bar.__str__()
        self.check(str_repr.find("BarObject") >= 0, "BarObject __str__ contains BarObject")
        self.check(str_repr.find("000001.XSHE") >= 0, "BarObject __str__ contains order_book_id")

    fn test_bar_object_future(mut self):
        var listed = DateTime(2023, 1, 1, 0, 0, 0, 0)
        var de_listed = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var maturity = DateTime(2024, 1, 19, 0, 0, 0, 0)
        var ins = create_future_instrument("IF2401.CFFEX", "沪深2401", listed, de_listed, maturity, 300.0, EXCHANGE.CFFEX, "IF")
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(
            ins, dt, 4000.0, 4050.0, 3980.0, 4020.0, 10000.0, 12000000000.0,
            prev_settlement=4000.0, settlement=4015.0, open_interest=50000.0
        )
        self.check(bar.settlement == 4015.0, "Future BarObject settlement is 4015.0")
        self.check(bar.prev_settlement == 4000.0, "Future BarObject prev_settlement is 4000.0")
        self.check(bar.open_interest == 50000.0, "Future BarObject open_interest is 50000")

    fn test_create_simple_bar(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_simple_bar(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0)
        self.check(bar.open == 10.0, "create_simple_bar open is 10.0")
        self.check(bar.close == 10.2, "create_simple_bar close is 10.2")
        self.check(bar.volume == 1000000.0, "create_simple_bar volume is 1000000")

    fn test_bar_object_datetime(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 6, 15, 14, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0)
        self.check(bar.datetime.year == 2024, "BarObject datetime year is 2024")
        self.check(bar.datetime.month == 6, "BarObject datetime month is 6")
        self.check(bar.datetime.day == 15, "BarObject datetime day is 15")

    fn test_bar_object_prev_close(mut self):
        var listed = DateTime(1991, 4, 3, 0, 0, 0, 0)
        var ins = create_stock_instrument("000001.XSHE", "平安银行", listed, EXCHANGE.XSHE)
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = create_bar_object(ins, dt, 10.0, 10.5, 9.8, 10.2, 1000000.0, 10200000.0, prev_close=10.0)
        self.check(bar.prev_close == 10.0, "BarObject prev_close is 10.0")

    fn run_all(mut self):
        print("=" * 60)
        print("L03_04_bar Module Tests")
        print("=" * 60)
        
        self.test_create_bar_object()
        self.test_bar_object_volume()
        self.test_bar_object_is_trading()
        self.test_bar_object_not_trading()
        self.test_bar_object_limit_up_down()
        self.test_bar_object_last()
        self.test_bar_object_vwap()
        self.test_bar_object_vwap_zero_volume()
        self.test_bar_object_suspended()
        self.test_bar_object_isnan()
        self.test_bar_object_isnan_zero_close()
        self.test_bar_object_str()
        self.test_bar_object_future()
        self.test_create_simple_bar()
        self.test_bar_object_datetime()
        self.test_bar_object_prev_close()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
