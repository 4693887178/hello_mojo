"""
RQAlpha Mojo - Auto Update Bundle Mixin
Ported from rqalpha/data/auto_update_bundle_mixin.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.utils.typing import DateTime, DateTimeDate


@fieldwise_init
struct OpenAuctionData(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var order_book_id: String
    var datetime: DateTime
    var volume: Float64
    
    def __str__(self) -> String:
        return "OpenAuctionData(" + self.order_book_id + ", volume=" + String(self.volume) + ")"


@fieldwise_init
struct AutomaticUpdateBundle(Movable):
    var _path: String
    var _filename: String
    var _end_date: DateTimeDate
    var _data: List[OpenAuctionData]
    
    def add_data(mut self, data: OpenAuctionData) -> None:
        self._data.append(data)
    
    def get_data(self, order_book_id: String, dt: DateTimeDate) -> OpenAuctionData:
        for i in range(len(self._data)):
            var d = self._data[i]
            if d.order_book_id == order_book_id:
                return d
        return OpenAuctionData("", DateTime(1970, 1, 1, 0, 0, 0, 0), 0.0)
    
    def has_data(self, order_book_id: String, dt: DateTimeDate) -> Bool:
        for i in range(len(self._data)):
            var d = self._data[i]
            if d.order_book_id == order_book_id:
                return True
        return False
    
    def file_exists(self) -> Bool:
        return len(self._data) > 0


def create_auto_update_bundle(path: String, filename: String, end_date: DateTimeDate) -> AutomaticUpdateBundle:
    return AutomaticUpdateBundle(
        _path=path,
        _filename=filename,
        _end_date=end_date,
        _data=List[OpenAuctionData]()
    )


def create_auto_update_bundle_with_test_data() -> AutomaticUpdateBundle:
    var end_date = DateTimeDate(2024, 2, 28)
    var bundle = create_auto_update_bundle("/tmp/test_bundle", "open_auction_volume.h5", end_date)
    
    bundle.add_data(OpenAuctionData("000001.XSHE", DateTime(2023, 12, 28, 9, 25, 0, 0), 1500000.0))
    bundle.add_data(OpenAuctionData("A2401", DateTime(2023, 12, 28, 9, 0, 0, 0), 500000.0))
    
    return bundle^
