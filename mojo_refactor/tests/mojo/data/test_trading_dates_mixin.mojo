"""
Mojo Test for data/trading_dates_mixin.mojo
Ported from tests/unittest/test_data/test_trading_dates_mixin.py
Tests the TradingDatesMixin functionality

Python original:
    from rqalpha.utils.testing import DataProxyFixture, RQAlphaTestCase
    
    class TradingDateMixinTestCase(DataProxyFixture, RQAlphaTestCase):
        def init_fixture(self):
            super(TradingDateMixinTestCase, self).init_fixture()
        
        def test_count_trading_dates(self):
            from datetime import date
            assert self.data_proxy.count_trading_dates(date(2018, 11, 1), date(2018, 11, 12)) == 8
            assert self.data_proxy.count_trading_dates(date(2018, 11, 3), date(2018, 11, 12)) == 6
            assert self.data_proxy.count_trading_dates(date(2018, 11, 3), date(2018, 11, 18)) == 10
"""

from rqmojo.utils.testing import DataProxyFixture, RQAlphaTestCase
from rqmojo.utils.datetime_func import Date
from rqmojo.data.data_proxy import DataProxy, create_data_proxy


struct TradingDateMixinTestCase:
    var data_proxy_fixture: DataProxyFixture
    var test_case: RQAlphaTestCase
    
    def __init__(out self):
        self.data_proxy_fixture = DataProxyFixture()
        self.test_case = RQAlphaTestCase()
    
    def init_fixture(mut self):
        self.data_proxy_fixture.init_fixture()
        self.test_case.init_fixture()
    
    def test_count_trading_dates(mut self) -> Bool:
        var all_passed = True
        
        var result1 = self.data_proxy_fixture.data_proxy.count_trading_dates(Date(2018, 11, 1), Date(2018, 11, 12))
        all_passed = self.test_case.assert_equal(result1, 8, "count_trading_dates(2018-11-01, 2018-11-12)") and all_passed
        
        var result2 = self.data_proxy_fixture.data_proxy.count_trading_dates(Date(2018, 11, 3), Date(2018, 11, 12))
        all_passed = self.test_case.assert_equal(result2, 6, "count_trading_dates(2018-11-03, 2018-11-12)") and all_passed
        
        var result3 = self.data_proxy_fixture.data_proxy.count_trading_dates(Date(2018, 11, 3), Date(2018, 11, 18))
        all_passed = self.test_case.assert_equal(result3, 10, "count_trading_dates(2018-11-03, 2018-11-18)") and all_passed
        
        return all_passed
    
    def run_all_tests(mut self) -> Bool:
        print("=== Testing TradingDatesMixin ===")
        print("")
        
        self.init_fixture()
        
        print("--- test_count_trading_dates ---")
        _ = self.test_count_trading_dates()
        
        return True


def main():
    var test = TradingDateMixinTestCase()
    _ = test.run_all_tests()
