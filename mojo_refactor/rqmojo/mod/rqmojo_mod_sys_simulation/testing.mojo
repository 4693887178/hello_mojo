"""
RQAlpha Mojo - Simulation Testing Utilities
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS
from rqmojo.model.order import Order, create_order
from rqmojo.model.bar import BarObject, create_bar
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime


fn create_test_order(order_book_id: String = "000001.XSHE", quantity: Int = 100, price: Float64 = 10.0, side: SIDE = SIDE.BUY()) -> Order:
    return create_order(
        order_book_id=order_book_id,
        quantity=quantity,
        price=price,
        side=side,
        position_effect=POSITION_EFFECT.OPEN()
    )


fn create_test_bar(open_price: Float64 = 10.0, high: Float64 = 11.0, low: Float64 = 9.0, close: Float64 = 10.5, volume: Int = 1000000) -> BarObject:
    return create_bar(
        datetime=DateTime(2020, 1, 1, 9, 30, 0, 0),
        open=open_price,
        high=high,
        low=low,
        close=close,
        volume=volume,
        total_turnover=close * Float64(volume)
    )


fn create_test_instrument(order_book_id: String = "000001.XSHE") -> Instrument:
    return create_stock_instrument(
        order_book_id=order_book_id,
        symbol=order_book_id.split(".")[0],
        listed_date=DateTime(1990, 1, 1, 0, 0, 0, 0),
        exchange="XSHE"
    )
