# test_L02_02_strategy_context.mojo
# Module: rqmojo.core.strategy_context
# Python: rqalpha.core.strategy_context
# Level: L02 - Core Base
# Dependencies: const, datetime_func

from rqmojo.core.strategy_context import RunInfo, create_run_info
from rqmojo.const import RUN_TYPE, MATCHING_TYPE
from rqmojo.utils.datetime_func import Date


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

    fn test_run_info_create(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1d")
        self.check(run_info.start_date().year == 2024, "RunInfo start_date year 2024")
        self.check(run_info.end_date().year == 2024, "RunInfo end_date year 2024")

    fn test_run_info_frequency(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1m")
        self.check(run_info.frequency() == "1m", "RunInfo frequency is 1m")

    fn test_run_info_starting_cash(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(
            start, end, "1d",
            stock_starting_cash=200000.0,
            future_starting_cash=50000.0
        )
        self.check(run_info.stock_starting_cash() == 200000.0, "RunInfo stock_starting_cash 200000")
        self.check(run_info.future_starting_cash() == 50000.0, "RunInfo future_starting_cash 50000")

    fn test_run_info_run_type(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1d", run_type=RUN_TYPE.PAPER_TRADING)
        self.check(run_info.run_type() == RUN_TYPE.PAPER_TRADING, "RunInfo run_type PAPER_TRADING")

    fn test_run_info_matching_type(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1d", matching_type=MATCHING_TYPE.NEXT_BAR_OPEN)
        self.check(run_info.matching_type() == MATCHING_TYPE.NEXT_BAR_OPEN, "RunInfo matching_type NEXT_BAR_OPEN")

    fn test_run_info_slippage(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1d", slippage=0.01)
        self.check(run_info.slippage() == 0.01, "RunInfo slippage 0.01")

    fn test_run_info_margin_multiplier(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1d", margin_multiplier=1.5)
        self.check(run_info.margin_multiplier() == 1.5, "RunInfo margin_multiplier 1.5")

    fn test_run_info_commission(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(
            start, end, "1d",
            stock_commission_multiplier=0.0005,
            futures_commission_multiplier=0.0002
        )
        self.check(run_info.stock_commission_multiplier() == 0.0005, "RunInfo stock_commission 0.0005")
        self.check(run_info.futures_commission_multiplier() == 0.0002, "RunInfo futures_commission 0.0002")

    fn test_run_info_str(mut self):
        var start = Date(2024, 1, 1)
        var end = Date(2024, 12, 31)
        var run_info = create_run_info(start, end, "1d")
        var str_repr = run_info.__str__()
        self.check(str_repr.find("RunInfo") >= 0, "RunInfo __str__ contains RunInfo")

    fn run_all(mut self):
        print("=" * 60)
        print("L02_02_strategy_context Module Tests")
        print("=" * 60)
        
        self.test_run_info_create()
        self.test_run_info_frequency()
        self.test_run_info_starting_cash()
        self.test_run_info_run_type()
        self.test_run_info_matching_type()
        self.test_run_info_slippage()
        self.test_run_info_margin_multiplier()
        self.test_run_info_commission()
        self.test_run_info_str()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
