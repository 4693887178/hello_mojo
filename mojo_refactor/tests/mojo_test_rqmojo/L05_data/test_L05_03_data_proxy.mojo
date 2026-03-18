# test_L05_03_data_proxy.mojo
# Module: rqmojo.data.data_proxy
# Python: rqalpha.data.data_proxy
# Level: L05 - Data Layer
# Dependencies: interface, model

from rqmojo.data.data_proxy import (
    DataProxy, DividendInfo, SplitInfo, Snapshot, OpenAuctionBar, YieldCurvePoint,
    create_data_proxy, create_dividend_info, create_split_info, create_snapshot
)
from rqmojo.model.instrument import create_stock_instrument
from rqmojo.const import EXCHANGE
from rqmojo.utils.datetime_func import DateTime, Date


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

    fn test_create_data_proxy(mut self):
        var proxy = create_data_proxy()
        self.check(True, "DataProxy created successfully")

    fn test_get_instrument(mut self):
        var proxy = create_data_proxy()
        var ins = proxy.get_instrument("000001.XSHE")
        self.check(ins.order_book_id == "000001.XSHE", "DataProxy get_instrument order_book_id is 000001.XSHE")

    fn test_get_last_price(mut self):
        var proxy = create_data_proxy()
        var price = proxy.get_last_price("000001.XSHE")
        self.check(price == 10.0, "DataProxy get_last_price is 10.0")

    fn test_get_all_instruments(mut self):
        var proxy = create_data_proxy()
        var instruments = proxy.get_all_instruments()
        self.check(len(instruments) == 4, "DataProxy get_all_instruments returns 4 instruments")

    fn test_get_bar(mut self):
        var proxy = create_data_proxy()
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var bar = proxy.get_bar("000001.XSHE", dt)
        self.check(bar.open == 10.0, "DataProxy get_bar open is 10.0")
        self.check(bar.close == 10.2, "DataProxy get_bar close is 10.2")

    fn test_get_tick(mut self):
        var proxy = create_data_proxy()
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var tick = proxy.get_tick("000001.XSHE", dt)
        self.check(tick.last == 10.2, "DataProxy get_tick last is 10.2")

    fn test_is_trading_date(mut self):
        var proxy = create_data_proxy()
        var dt = DateTime(2018, 11, 1, 0, 0, 0, 0)
        self.check(proxy.is_trading_date(dt) == True, "DataProxy is_trading_date 2018-11-01 is True")

    fn test_count_trading_dates(mut self):
        var proxy = create_data_proxy()
        var start = Date(2018, 11, 1)
        var end = Date(2018, 11, 30)
        var count = proxy.count_trading_dates(start, end)
        self.check(count == 22, "DataProxy count_trading_dates is 22")

    fn test_get_previous_trading_date(mut self):
        var proxy = create_data_proxy()
        var dt = DateTime(2018, 11, 5, 0, 0, 0, 0)
        var prev = proxy.get_previous_trading_date(dt)
        self.check(prev.day == 2, "DataProxy get_previous_trading_date day is 2")

    fn test_get_next_trading_date(mut self):
        var proxy = create_data_proxy()
        var dt = DateTime(2018, 11, 2, 0, 0, 0, 0)
        var next_dt = proxy.get_next_trading_date(dt)
        self.check(next_dt.day == 5, "DataProxy get_next_trading_date day is 5")

    fn test_dividend_info(mut self):
        var dividend = create_dividend_info(
            book_closure_date=20231215,
            announcement_date=20231210,
            dividend_cash_before_tax=0.5,
            ex_dividend_date=20231216,
            payable_date=20231220,
            round_lot=10
        )
        self.check(dividend.dividend_cash_before_tax == 0.5, "DividendInfo dividend_cash_before_tax is 0.5")
        self.check(dividend.ex_dividend_date == 20231216, "DividendInfo ex_dividend_date is 20231216")

    fn test_split_info(mut self):
        var split = create_split_info(ex_date=20230515, split_factor=1.5)
        self.check(split.ex_date == 20230515, "SplitInfo ex_date is 20230515")
        self.check(split.split_factor == 1.5, "SplitInfo split_factor is 1.5")

    fn test_snapshot(mut self):
        var ins = create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE())
        var dt = DateTime(2024, 1, 1, 9, 30, 0, 0)
        var snapshot = create_snapshot(
            instrument=ins,
            datetime=dt,
            open=10.0,
            high=10.5,
            low=9.8,
            last=10.2,
            volume=1000000.0,
            total_turnover=10200000.0
        )
        self.check(snapshot.last == 10.2, "Snapshot last is 10.2")
        self.check(snapshot.volume == 1000000.0, "Snapshot volume is 1000000")

    fn run_all(mut self):
        print("=" * 60)
        print("L05_03_data_proxy Module Tests")
        print("=" * 60)
        
        self.test_create_data_proxy()
        self.test_get_instrument()
        self.test_get_last_price()
        self.test_get_all_instruments()
        self.test_get_bar()
        self.test_get_tick()
        self.test_is_trading_date()
        self.test_count_trading_dates()
        self.test_get_previous_trading_date()
        self.test_get_next_trading_date()
        self.test_dividend_info()
        self.test_split_info()
        self.test_snapshot()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
