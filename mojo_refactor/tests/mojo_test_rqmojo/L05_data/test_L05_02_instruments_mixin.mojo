# test_L05_02_instruments_mixin.mojo
# Module: rqmojo.data.instruments_mixin
# Python: rqalpha.data.instruments_mixin
# Level: L05 - Data Layer
# Dependencies: const, instrument

from rqmojo.data.instruments_mixin import InstrumentsMixin, create_instruments_mixin_with_test_data


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

    fn test_get_instrument(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        var ins = mixin.get_instrument("000001.XSHE")
        self.check(ins.order_book_id == "000001.XSHE", "InstrumentsMixin get_instrument order_book_id is 000001.XSHE")
        self.check(ins.symbol == "平安银行", "InstrumentsMixin get_instrument symbol is 平安银行")

    fn test_get_future_instrument(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        var ins = mixin.get_instrument("RB1912")
        self.check(ins.order_book_id == "RB1912", "InstrumentsMixin get_future_instrument order_book_id is RB1912")
        self.check(ins.symbol == "螺纹钢1912", "InstrumentsMixin get_future_instrument symbol is 螺纹钢1912")

    fn test_has_instrument_true(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        self.check(mixin.has_instrument("000001.XSHE") == True, "InstrumentsMixin has_instrument 000001.XSHE is True")
        self.check(mixin.has_instrument("RB1912") == True, "InstrumentsMixin has_instrument RB1912 is True")

    fn test_has_instrument_false(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        self.check(mixin.has_instrument("NOTEXIST.XSHE") == False, "InstrumentsMixin has_instrument NOTEXIST.XSHE is False")

    fn test_get_trading_period(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        var order_book_ids = List[String]()
        order_book_ids.append("RB1912")
        var periods = mixin.get_trading_period(order_book_ids)
        self.check(len(periods) == 4, "InstrumentsMixin get_trading_period returns 4 periods for RB1912")

    fn test_is_night_trading_true(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        var order_book_ids = List[String]()
        order_book_ids.append("AG1912")
        self.check(mixin.is_night_trading(order_book_ids) == True, "InstrumentsMixin is_night_trading AG1912 is True")

    fn test_is_night_trading_false(mut self):
        var mixin = create_instruments_mixin_with_test_data()
        var order_book_ids = List[String]()
        order_book_ids.append("TF1912")
        self.check(mixin.is_night_trading(order_book_ids) == False, "InstrumentsMixin is_night_trading TF1912 is False")

    fn run_all(mut self):
        print("=" * 60)
        print("L05_02_instruments_mixin Module Tests")
        print("=" * 60)
        
        self.test_get_instrument()
        self.test_get_future_instrument()
        self.test_has_instrument_true()
        self.test_has_instrument_false()
        self.test_get_trading_period()
        self.test_is_night_trading_true()
        self.test_is_night_trading_false()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
