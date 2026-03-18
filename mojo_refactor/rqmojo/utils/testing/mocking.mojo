"""
RQAlpha Mojo - Mocking Utilities
Ported from rqalpha/utils/testing/mocking.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.model.order import Order, create_order
from rqmojo.model.bar import BarObject, create_bar
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct MockDataProxy(Movable):
    var _bars: Dict[String, List[BarObject]]
    var _instruments: Dict[String, Instrument]
    
    fn get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        if self._bars.contains(order_book_id):
            var bars = self._bars[order_book_id]
            if len(bars) > 0:
                return bars[0]
        return create_bar(dt, 10.0, 11.0, 9.0, 10.5, 1000000, 10500000.0)
    
    fn get_instrument(self, order_book_id: String) -> Instrument:
        if self._instruments.contains(order_book_id):
            return self._instruments[order_book_id]
        return create_stock_instrument(order_book_id, order_book_id.split(".")[0], DateTime(1990, 1, 1, 0, 0, 0, 0), "XSHE")


fn create_mock_data_proxy() -> MockDataProxy:
    return MockDataProxy(
        _bars=Dict[String, List[BarObject]](),
        _instruments=Dict[String, Instrument]()
    )


fn create_mock_order(order_book_id: String = "000001.XSHE", quantity: Int = 100, price: Float64 = 10.0) -> Order:
    return create_order(
        order_book_id=order_book_id,
        quantity=quantity,
        price=price,
        side=SIDE.BUY(),
        position_effect=POSITION_EFFECT.OPEN()
    )
