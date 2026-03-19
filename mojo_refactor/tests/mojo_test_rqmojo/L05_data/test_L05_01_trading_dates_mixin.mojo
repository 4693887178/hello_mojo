# test_L05_01_trading_dates_mixin.mojo
# Module: rqmojo.data.trading_dates_mixin
# Python: rqalpha.data.trading_dates_mixin
# Level: L05 - Data Layer
# Dependencies: const, datetime_func

from rqmojo.data.trading_dates_mixin import (
    TradingDateResult, TradingDatesMixin,
    create_trading_date_result, create_trading_dates_mixin_with_november_2018
)


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

    fn test_trading_date_result(mut self):
        var result = create_trading_date_result(2018, 11, 1)
        self.check(result.year == 2018, "TradingDateResult year is 2018")
        self.check(result.month == 11, "TradingDateResult month is 11")
        self.check(result.day == 1, "TradingDateResult day is 1")

    fn test_trading_date_result_to_date(mut self):
        var result = create_trading_date_result(2018, 11, 15)
        var d = result.to_date()
        self.check(d.year == 2018, "TradingDateResult to_date year is 2018")
        self.check(d.month == 11, "TradingDateResult to_date month is 11")
        self.check(d.day == 15, "TradingDateResult to_date day is 15")

    fn test_trading_dates_mixin_count(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        var count = mixin.count_trading_dates(2018, 11, 1, 2018, 11, 30)
        self.check(count == 22, "TradingDatesMixin count_trading_dates is 22")

    fn test_is_trading_date_true(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        self.check(mixin.is_trading_date(2018, 11, 1) == True, "TradingDatesMixin is_trading_date 2018-11-01 is True")
        self.check(mixin.is_trading_date(2018, 11, 15) == True, "TradingDatesMixin is_trading_date 2018-11-15 is True")

    fn test_is_trading_date_false(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        self.check(mixin.is_trading_date(2018, 11, 3) == False, "TradingDatesMixin is_trading_date 2018-11-03 is False (Saturday)")
        self.check(mixin.is_trading_date(2018, 11, 4) == False, "TradingDatesMixin is_trading_date 2018-11-04 is False (Sunday)")

    fn test_get_previous_trading_date(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        var prev = mixin.get_previous_trading_date(2018, 11, 5, 1)
        self.check(prev.year == 2018, "get_previous_trading_date year is 2018")
        self.check(prev.month == 11, "get_previous_trading_date month is 11")
        self.check(prev.day == 2, "get_previous_trading_date day is 2")

    fn test_get_next_trading_date(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        var next_date = mixin.get_next_trading_date(2018, 11, 2, 1)
        self.check(next_date.year == 2018, "get_next_trading_date year is 2018")
        self.check(next_date.month == 11, "get_next_trading_date month is 11")
        self.check(next_date.day == 5, "get_next_trading_date day is 5")

    fn test_get_trading_dates_count(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        self.check(mixin.get_trading_dates_count() == 22, "TradingDatesMixin get_trading_dates_count is 22")

    fn test_trading_dates_mixin_str(mut self):
        var mixin = create_trading_dates_mixin_with_november_2018()
        var str_repr = mixin.__str__()
        self.check(str_repr.find("TradingDatesMixin") >= 0, "TradingDatesMixin __str__ contains TradingDatesMixin")

    fn run_all(mut self):
        print("=" * 60)
        print("L05_01_trading_dates_mixin Module Tests")
        print("=" * 60)
        
        self.test_trading_date_result()
        self.test_trading_date_result_to_date()
        self.test_trading_dates_mixin_count()
        self.test_is_trading_date_true()
        self.test_is_trading_date_false()
        self.test_get_previous_trading_date()
        self.test_get_next_trading_date()
        self.test_get_trading_dates_count()
        self.test_trading_dates_mixin_str()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
