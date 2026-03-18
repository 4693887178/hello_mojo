# test_L00_08_risk_free_helper.mojo
# Module: rqmojo.utils.risk_free_helper
# Python: rqalpha.utils.risk_free_helper
# Level: L00 - Leaf module
# Dependencies: datetime_func

from rqmojo.utils.risk_free_helper import (
    get_yield_curve_tenors,
    get_yield_curve_duration,
    get_tenor_for,
    get_tenors_for
)
from rqmojo.utils.datetime_func import Date, DateTime
from collections import Dict, List


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

    fn test_get_yield_curve_tenors(mut self) raises:
        var tenors = get_yield_curve_tenors()
        self.check(tenors.__len__() == 21, "get_yield_curve_tenors returns 21 entries")

    fn test_get_yield_curve_duration(mut self) raises:
        var durations = get_yield_curve_duration()
        self.check(durations.__len__() == 21, "get_yield_curve_duration returns 21 entries")

    fn test_get_tenor_for_zero_days(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2024, 1, 1)
        var tenor = get_tenor_for(start, end)
        self.check(tenor == "0S", "get_tenor_for zero days returns 0S")

    fn test_get_tenor_for_one_month(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2024, 2, 1)
        var tenor = get_tenor_for(start, end)
        self.check(tenor == "1M", "get_tenor_for one month returns 1M")

    fn test_get_tenor_for_one_year(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2025, 1, 1)
        var tenor = get_tenor_for(start, end)
        self.check(tenor == "1Y", "get_tenor_for one year returns 1Y")

    fn test_get_tenor_for_ten_years(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2034, 1, 1)
        var tenor = get_tenor_for(start, end)
        self.check(tenor == "10Y", "get_tenor_for ten years returns 10Y")

    fn test_get_tenors_for_zero_days(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2024, 1, 1)
        var tenors = get_tenors_for(start, end)
        self.check(tenors.__len__() == 1, "get_tenors_for zero days returns 1 tenor")

    fn test_get_tenors_for_one_year(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2025, 1, 1)
        var tenors = get_tenors_for(start, end)
        self.check(tenors.__len__() == 7, "get_tenors_for one year returns 7 tenors")

    fn test_get_tenors_for_ten_years(mut self) raises:
        var start = Date(2024, 1, 1)
        var end = Date(2034, 1, 1)
        var tenors = get_tenors_for(start, end)
        self.check(tenors.__len__() == 16, "get_tenors_for ten years returns 16 tenors")

    fn run_all(mut self) raises:
        print("=" * 60)
        print("L00_08_risk_free_helper Module Tests")
        print("=" * 60)
        
        self.test_get_yield_curve_tenors()
        self.test_get_yield_curve_duration()
        self.test_get_tenor_for_zero_days()
        self.test_get_tenor_for_one_month()
        self.test_get_tenor_for_one_year()
        self.test_get_tenor_for_ten_years()
        self.test_get_tenors_for_zero_days()
        self.test_get_tenors_for_one_year()
        self.test_get_tenors_for_ten_years()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main() raises:
    var runner = TestRunner(0, 0)
    runner.run_all()
