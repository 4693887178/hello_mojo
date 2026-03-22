"""
RQAlpha Mojo - Mocking Utilities
Ported from rqalpha/utils/testing/mocking.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.model.order import Order, OrderStyle, MarketOrder, create_order_with_id
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime


struct MockDataProxy(Movable, Copyable):
    var _bars: Dict[String, BarObject]
    var _instruments: Dict[String, Instrument]
    
    def __init__(out self):
        self._bars = Dict[String, BarObject]()
        self._instruments = Dict[String, Instrument]()
    
    def get_bar(self, order_book_id: String, dt: DateTime) -> BarObject:
        if self._bars.contains(order_book_id):
            return self._bars[order_book_id]
        return create_bar_object(
            order_book_id=order_book_id,
            dt=dt,
            open=10.0,
            high=11.0,
            low=9.0,
            close=10.5,
            volume=1000000.0,
            total_turnover=10500000.0,
            limit_up=11.5,
            limit_down=9.5,
            suspended=False,
            trading=True
        )
    
    def get_instrument(self, order_book_id: String) -> Instrument:
        if self._instruments.contains(order_book_id):
            return self._instruments[order_book_id]
        return create_stock_instrument(order_book_id, order_book_id.split(".")[0], DateTime(1990, 1, 1, 0, 0, 0, 0), "XSHE")


def create_mock_data_proxy() -> MockDataProxy:
    return MockDataProxy()


def create_mock_order(order_book_id: String = "000001.XSHE", quantity: Int = 100, price: Float64 = 10.0) -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )
