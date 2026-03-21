"""
RQAlpha Mojo - Instruments Mixin
Ported from rqalpha/data/instruments_mixin.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET, EXCHANGE_XSHE, EXCHANGE_SHFE, EXCHANGE_CFFEX, EXCHANGE_XSHE, EXCHANGE_SHFE, EXCHANGE_CFFEX
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.utils.datetime_func import DateTime, Date, TimeRange


@fieldwise_init
struct InstrumentsMixin(Movable):
    var _instruments: List[Instrument]
    var _default_instrument: Instrument
    
    fn get_instrument(self, order_book_id: String) -> Instrument:
        for i in range(len(self._instruments)):
            if self._instruments[i].order_book_id() == order_book_id:
                return self._instruments[i]
        return self._default_instrument
    
    fn has_instrument(self, order_book_id: String) -> Bool:
        for i in range(len(self._instruments)):
            if self._instruments[i].order_book_id() == order_book_id:
                return True
        return False
    
    fn get_trading_period(self, order_book_ids: List[String]) -> List[TimeRange]:
        var result = List[TimeRange]()
        for i in range(len(order_book_ids)):
            var order_book_id = order_book_ids[i]
            if order_book_id == "RB1912":
                result.append(TimeRange(21, 1, 23, 0))
                result.append(TimeRange(9, 1, 10, 15))
                result.append(TimeRange(10, 31, 11, 30))
                result.append(TimeRange(13, 31, 15, 0))
            elif order_book_id == "AG1912":
                result.append(TimeRange(21, 1, 23, 59))
                result.append(TimeRange(0, 0, 2, 30))
                result.append(TimeRange(9, 1, 11, 30))
                result.append(TimeRange(13, 31, 15, 0))
            elif order_book_id == "TF1912":
                result.append(TimeRange(9, 31, 11, 30))
                result.append(TimeRange(13, 1, 15, 15))
        return result^
    
    fn is_night_trading(self, order_book_ids: List[String]) -> Bool:
        for i in range(len(order_book_ids)):
            var order_book_id = order_book_ids[i]
            if order_book_id == "AG1912" or order_book_id == "RB1912":
                return True
        return False


fn create_instruments_mixin_with_test_data() -> InstrumentsMixin:
    var instruments = List[Instrument]()
    var default_ins = create_stock_instrument("", "", DateTime(1970, 1, 1, 0, 0, 0, 0), EXCHANGE_XSHE)
    
    instruments.append(create_future_instrument("RB1912", "螺纹钢1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 10.0, EXCHANGE_SHFE, "RB"))
    instruments.append(create_future_instrument("AG1912", "白银1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 15.0, EXCHANGE_SHFE, "AG"))
    instruments.append(create_future_instrument("TF1912", "五年期国债1912", DateTime(2019, 1, 1, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), DateTime(2019, 12, 15, 0, 0, 0, 0), 10000.0, EXCHANGE_CFFEX, "TF"))
    instruments.append(create_stock_instrument("000001.XSHE", "平安银行", DateTime(1991, 4, 3, 0, 0, 0, 0), EXCHANGE_XSHE))
    
    return InstrumentsMixin(_instruments=instruments^, _default_instrument=default_ins^)
