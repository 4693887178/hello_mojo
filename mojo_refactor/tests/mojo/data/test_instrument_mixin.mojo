"""
Mojo Test for data/instruments_mixin.mojo
Ported from tests/unittest/test_data/test_instrument_mixin.py
Tests the InstrumentsMixin functionality

Python original:
    from datetime import time
    from rqalpha.utils.testing import DataProxyFixture, RQAlphaTestCase
    from rqalpha.utils import TimeRange
    
    class InstrumentMixinTestCase(DataProxyFixture, RQAlphaTestCase):
        def init_fixture(self):
            super(InstrumentMixinTestCase, self).init_fixture()
        
        def test_get_trading_period(self):
            rb_time_range = self.data_proxy.get_trading_period(["RB1912"])
            self.assertSetEqual(set(rb_time_range), {
                TimeRange(start=time(21, 1), end=time(23, 0)), 
                TimeRange(start=time(9, 1), end=time(10, 15)),
                TimeRange(start=time(10, 31), end=time(11, 30)), 
                TimeRange(start=time(13, 31), end=time(15, 0))
            })
        
        def test_is_night_trading(self):
            assert not self.data_proxy.is_night_trading(["TF1912"])
            assert self.data_proxy.is_night_trading(["AG1912", "000001.XSHE"])
"""

from rqmojo.utils.testing import DataProxyFixture, RQAlphaTestCase
from rqmojo.utils.datetime_func import Date, TimeRange
from rqmojo.data.data_proxy import DataProxy, create_data_proxy


struct InstrumentMixinTestCase:
    var data_proxy_fixture: DataProxyFixture
    var test_case: RQAlphaTestCase
    
    def __init__(out self):
        self.data_proxy_fixture = DataProxyFixture()
        self.test_case = RQAlphaTestCase()
    
    def init_fixture(mut self):
        self.data_proxy_fixture.init_fixture()
        self.test_case.init_fixture()
    
    def test_get_trading_period(mut self) raises -> Bool:
        var all_passed = True
        
        var order_book_ids = List[String]()
        order_book_ids.append("RB1912")
        
        var rb_time_range = self.data_proxy_fixture.data_proxy.get_trading_period(order_book_ids)
        
        var expected_ranges = List[TimeRange]()
        expected_ranges.append(TimeRange(21, 1, 23, 0))
        expected_ranges.append(TimeRange(9, 1, 10, 15))
        expected_ranges.append(TimeRange(10, 31, 11, 30))
        expected_ranges.append(TimeRange(13, 31, 15, 0))
        
        all_passed = self._assert_set_equal_time_ranges(rb_time_range, expected_ranges, "get_trading_period(['RB1912'])") and all_passed
        
        return all_passed
    
    def test_is_night_trading(mut self) raises -> Bool:
        var all_passed = True
        
        var tf_ids = List[String]()
        tf_ids.append("TF1912")
        var result1 = self.data_proxy_fixture.data_proxy.is_night_trading(tf_ids)
        all_passed = self.test_case.assert_false(result1, "is_night_trading(['TF1912']) should be False") and all_passed
        
        var ag_ids = List[String]()
        ag_ids.append("AG1912")
        ag_ids.append("000001.XSHE")
        var result2 = self.data_proxy_fixture.data_proxy.is_night_trading(ag_ids)
        all_passed = self.test_case.assert_true(result2, "is_night_trading(['AG1912', '000001.XSHE']) should be True") and all_passed
        
        return all_passed
    
    def _assert_set_equal_time_ranges(mut self, set1: List[TimeRange], set2: List[TimeRange], msg: String) -> Bool:
        if len(set1) != len(set2):
            print("FAIL: " + msg + " - set sizes differ: " + String(len(set1)) + " vs " + String(len(set2)))
            return False
        
        var matched = List[Bool]()
        for i in range(len(set2)):
            matched.append(False)
        
        for i in range(len(set1)):
            var found = False
            for j in range(len(set2)):
                if not matched[j]:
                    var tr1 = set1[i]
                    var tr2 = set2[j]
                    if tr1.start_hour == tr2.start_hour and \
                       tr1.start_minute == tr2.start_minute and \
                       tr1.end_hour == tr2.end_hour and \
                       tr1.end_minute == tr2.end_minute:
                        matched[j] = True
                        found = True
                        break
            if not found:
                print("FAIL: " + msg + " - sets not equal")
                return False
        
        print("PASS: " + msg)
        return True
    
    def run_all_tests(mut self) raises -> Bool:
        print("=== Testing InstrumentMixin ===")
        print("")
        
        self.init_fixture()
        
        print("--- test_get_trading_period ---")
        _ = self.test_get_trading_period()
        print("")
        
        print("--- test_is_night_trading ---")
        _ = self.test_is_night_trading()
        print("")
        
        return True


def main() raises:
    var test = InstrumentMixinTestCase()
    _ = test.run_all_tests()
