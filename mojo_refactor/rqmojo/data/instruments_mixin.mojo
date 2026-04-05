"""
RQAlpha Mojo - Instruments Mixin
Ported from rqalpha/data/instruments_mixin.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.datetime_func import TimeRange, TimeOfDay


@fieldwise_init
struct InstrumentsMixin(Movable):
    var _instruments: List[Instrument]
    var _default_instrument: Instrument
    
    def get_instrument(self, order_book_id: String) -> Instrument:
        for i in range(len(self._instruments)):
            if self._instruments[i].order_book_id() == order_book_id:
                return self._instruments[i]
        return self._default_instrument
    
    def has_instrument(self, order_book_id: String) -> Bool:
        for i in range(len(self._instruments)):
            if self._instruments[i].order_book_id() == order_book_id:
                return True
        return False
    
    def get_trading_period(self, order_book_ids: List[String]) -> List[TimeRange]:
        var result = List[TimeRange]()
        for i in range(len(order_book_ids)):
            var order_book_id = order_book_ids[i]
            if order_book_id == "RB1912":
                result.append(TimeRange(TimeOfDay(21, 1), TimeOfDay(23, 0)))
                result.append(TimeRange(TimeOfDay(9, 1), TimeOfDay(10, 15)))
                result.append(TimeRange(TimeOfDay(10, 31), TimeOfDay(11, 30)))
                result.append(TimeRange(TimeOfDay(13, 31), TimeOfDay(15, 0)))
            elif order_book_id == "AG1912":
                result.append(TimeRange(TimeOfDay(21, 1), TimeOfDay(23, 59)))
                result.append(TimeRange(TimeOfDay(0, 0), TimeOfDay(2, 30)))
                result.append(TimeRange(TimeOfDay(9, 1), TimeOfDay(11, 30)))
                result.append(TimeRange(TimeOfDay(13, 31), TimeOfDay(15, 0)))
            elif order_book_id == "TF1912":
                result.append(TimeRange(TimeOfDay(9, 31), TimeOfDay(11, 30)))
                result.append(TimeRange(TimeOfDay(13, 1), TimeOfDay(15, 15)))
        return result^
    
    def is_night_trading(self, order_book_ids: List[String]) -> Bool:
        for i in range(len(order_book_ids)):
            var order_book_id = order_book_ids[i]
            if order_book_id == "AG1912" or order_book_id == "RB1912":
                return True
        return False


def create_instruments_mixin_with_test_data() -> InstrumentsMixin:
    var instruments = List[Instrument]()
    var default_ins = create_stock_instrument("", "", DateTime(1970, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHE)
    
    instruments.append(create_future_instrument("RB1912", "螺纹钢1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 10.0, EXCHANGE.SHFE, "RB"))
    instruments.append(create_future_instrument("AG1912", "白银1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 15.0, EXCHANGE.SHFE, "AG"))
    instruments.append(create_future_instrument("TF1912", "五年期国债1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 10000.0, EXCHANGE.CFFEX, "TF"))
    instruments.append(create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE.XSHE))
    
    return InstrumentsMixin(_instruments=instruments^, _default_instrument=default_ins^)
