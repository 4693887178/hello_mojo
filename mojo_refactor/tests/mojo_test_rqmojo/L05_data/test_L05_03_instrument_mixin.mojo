# test_L05_03_instrument_mixin.mojo
# Module: rqmojo.data.data_proxy
# Python: rqalpha.data.data_proxy
# Level: L05 - Data Layer
# Dependencies: data_proxy, instrument, datetime_func
# Test: test_instrument_mixin.py

from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.utils.datetime_func import TimeRange


fn time_range_equal(tr1: TimeRange, tr2: TimeRange) -> Bool:
    return tr1.start_hour == tr2.start_hour and 
           tr1.start_minute == tr2.start_minute and 
           tr1.end_hour == tr2.end_hour and 
           tr1.end_minute == tr2.end_minute


fn time_range_set_equal(set1: List[TimeRange], set2: List[TimeRange]) -> Bool:
    if len(set1) != len(set2):
        return False
    
    var matched = List[Bool]()
    for i in range(len(set1)):
        matched.append(False)
    
    for i in range(len(set1)):
        var found = False
        for j in range(len(set2)):
            if not matched[j] and time_range_equal(set1[i], set2[j]):
                matched[j] = True
                found = True
                break
        if not found:
            return False
    
    return True


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    var data_proxy: DataProxy
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_get_trading_period(mut self):
        var rb_order_book_ids = List[String]()
        rb_order_book_ids.append("RB1912")
        
        var rb_time_range = self.data_proxy.get_trading_period(rb_order_book_ids)
        
        var expected_rb = List[TimeRange]()
        expected_rb.append(TimeRange(9, 0, 10, 15))
        expected_rb.append(TimeRange(10, 30, 11, 30))
        expected_rb.append(TimeRange(13, 30, 15, 0))
        expected_rb.append(TimeRange(21, 0, 23, 0))
        
        self.check(
            time_range_set_equal(rb_time_range, expected_rb), 
            "get_trading_period RB1912 returns correct time ranges"
        )
        
        var merged_order_book_ids = List[String]()
        merged_order_book_ids.append("AG1912")
        merged_order_book_ids.append("TF1912")
        
        var default_period = List[TimeRange]()
        default_period.append(TimeRange(9, 31, 11, 30))
        default_period.append(TimeRange(13, 1, 15, 0))
        
        var merged_time_range = self.data_proxy.get_trading_period(merged_order_book_ids, default_period)
        
        var expected_merged = List[TimeRange]()
        expected_merged.append(TimeRange(0, 0, 2, 30))
        expected_merged.append(TimeRange(9, 0, 11, 30))
        expected_merged.append(TimeRange(13, 1, 15, 15))
        expected_merged.append(TimeRange(21, 0, 23, 59))
        
        self.check(
            time_range_set_equal(merged_time_range, expected_merged),
            "get_trading_period AG1912+TF1912 with default returns merged time ranges"
        )

    fn test_is_night_trading(mut self):
        var tf_order_book_ids = List[String]()
        tf_order_book_ids.append("TF1912")
        
        self.check(
            not self.data_proxy.is_night_trading(tf_order_book_ids),
            "is_night_trading TF1912 is False"
        )
        
        var mixed_order_book_ids = List[String]()
        mixed_order_book_ids.append("AG1912")
        mixed_order_book_ids.append("000001.XSHE")
        
        self.check(
            self.data_proxy.is_night_trading(mixed_order_book_ids),
            "is_night_trading AG1912+000001.XSHE is True"
        )

    fn run_all(mut self):
        print("=" * 60)
        print("L05_03_instrument_mixin (DataProxy) Tests")
        print("=" * 60)
        
        self.test_get_trading_period()
        self.test_is_night_trading()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var data_proxy = create_data_proxy()
    var runner = TestRunner(0, 0, data_proxy^)
    runner.run_all()
