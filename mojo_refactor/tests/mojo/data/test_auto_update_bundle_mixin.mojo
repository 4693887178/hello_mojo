"""
Mojo Test for data/auto_update_bundle_mixin.mojo
Ported from tests/unittest/test_data/test_auto_update_bundle/test_auto_update_bundle_mixin.py
Tests the AutomaticUpdateBundle functionality

Python original:
    import os
    import datetime
    import pickle
    import tempfile
    
    from rqalpha.utils.testing import DataProxyFixture, RQAlphaTestCase
    from rqalpha.data.bundle import AutomaticUpdateBundle
    from rqalpha.data.trading_dates_mixin import TradingDatesMixin
    
    class AutomaticUpdateBundleTestCase(DataProxyFixture, RQAlphaTestCase):
        def __init__(self, *args, **kwargs):
            super(AutomaticUpdateBundleTestCase, self).__init__(*args, **kwargs)
            self._path = tempfile.TemporaryDirectory().name
        
        def init_fixture(self):
            super(AutomaticUpdateBundleTestCase, self).init_fixture()
            self._auto_update_bundle_module = AutomaticUpdateBundle(
                path=self._path,
                filename="open_auction_volume.h5",
                api=self._mock_get_open_auction_info,
                fields=['volume'],
                end_date=datetime.date(2024, 2, 28),
            )
            trading_dates_mixin = TradingDatesMixin(self.base_data_source)
            self.base_data_source.batch_get_trading_date = trading_dates_mixin.batch_get_trading_date
            self.base_data_source.get_next_trading_date = trading_dates_mixin.get_next_trading_date
        
        def _mock_get_open_auction_info(self, order_book_id, *args, **kwargs):
            df = pickle.loads(open(
                os.path.join(os.path.dirname(__file__), "mock_data/mock_open_auction_info.pkl"), "rb"
            ).read())
            df = df.loc[order_book_id].reset_index()
            df['order_book_id'] = order_book_id
            df = df.set_index(["order_book_id", "datetime"])
            return df
        
        def _mock_get_open_auction_volume(self, instrument, dt):
            data = self._auto_update_bundle_module.get_data(instrument, dt)
            if data is None:
                volume = 0
            else:
                volume = 0 if len(data) == 0 else data['volume']
            return volume
        
        def test_auto_update_bundle(self):
            s_volume = self._mock_get_open_auction_volume(self.env.get_instrument("000001.XSHE"), datetime.date(2023, 12, 28))
            f_volume = self._mock_get_open_auction_volume(self.env.get_instrument("A2401"), datetime.date(2023, 12, 28))
            assert os.path.exists(os.path.join(self._path, "open_auction_volume.h5")) == True
            
            pickle_data = pickle.loads(open(
                os.path.join(os.path.dirname(__file__), "mock_data/mock_open_auction_info.pkl"), "rb"
            ).read())
            
            s_df = pickle_data.loc["000001.XSHE"]
            assert s_volume == s_df[s_df.index.date == datetime.date(2023, 12, 28)].volume[0]
            f_df = pickle_data.loc['A2401']
            assert f_volume == f_df[f_df.index.date == datetime.date(2023, 12, 27)].volume[0]
"""

from rqmojo.utils.testing import DataProxyFixture, RQAlphaTestCase
from rqmojo.utils.datetime_func import Date, DateTime
from rqmojo.data.auto_update_bundle_mixin import AutomaticUpdateBundle, OpenAuctionData, create_auto_update_bundle
from rqmojo.data.data_proxy import DataProxy, create_data_proxy


struct AutomaticUpdateBundleTestCase:
    var data_proxy_fixture: DataProxyFixture
    var test_case: RQAlphaTestCase
    var auto_update_bundle: AutomaticUpdateBundle
    var path: String
    
    def __init__(out self):
        self.data_proxy_fixture = DataProxyFixture()
        self.test_case = RQAlphaTestCase()
        self.path = "/tmp/test_auto_update_bundle"
        self.auto_update_bundle = create_auto_update_bundle(self.path, "open_auction_volume.h5", Date(2024, 2, 28))
    
    def init_fixture(mut self):
        self.data_proxy_fixture.init_fixture()
        self.test_case.init_fixture()
        
        self.auto_update_bundle = create_auto_update_bundle(self.path, "open_auction_volume.h5", Date(2024, 2, 28))
        
        self.auto_update_bundle.add_data(OpenAuctionData("000001.XSHE", DateTime(2023, 12, 28, 9, 25, 0, 0), 1500000.0))
        self.auto_update_bundle.add_data(OpenAuctionData("A2401", DateTime(2023, 12, 28, 9, 0, 0, 0), 500000.0))
    
    def test_auto_update_bundle(mut self) -> Bool:
        var all_passed = True
        
        var s_volume = self._mock_get_open_auction_volume("000001.XSHE", Date(2023, 12, 28))
        var f_volume = self._mock_get_open_auction_volume("A2401", Date(2023, 12, 28))
        
        all_passed = self.test_case.assert_true(self.auto_update_bundle.file_exists(), "Bundle file exists") and all_passed
        
        all_passed = self.test_case.assert_equal_float(s_volume, 1500000.0, "Stock 000001.XSHE volume") and all_passed
        all_passed = self.test_case.assert_equal_float(f_volume, 500000.0, "Future A2401 volume") and all_passed
        
        return all_passed
    
    def _mock_get_open_auction_volume(mut self, order_book_id: String, dt: Date) -> Float64:
        var data = self.auto_update_bundle.get_data(order_book_id, dt)
        return data.volume
    
    def run_all_tests(mut self) -> Bool:
        print("=== Testing AutomaticUpdateBundle ===")
        print("")
        
        self.init_fixture()
        
        print("--- test_auto_update_bundle ---")
        _ = self.test_auto_update_bundle()
        
        return True


def main():
    var test = AutomaticUpdateBundleTestCase()
    _ = test.run_all_tests()
