"""
RQAlpha Mojo - Trade Object Model
Ported from rqalpha/model/trade.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION, POSITION_DIRECTION_LONG
from rqmojo.model.order import Order
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TradeIdGenerator(Stringable, Movable):
    var counter: Int
    
    fn __str__(self) -> String:
        return "TradeIdGenerator(" + String(self.counter) + ")"
    
    fn next(mut self) -> Int:
        self.counter += 1
        return self.counter


fn create_trade_id_generator() -> TradeIdGenerator:
    return TradeIdGenerator(counter=0)


@fieldwise_init
struct Trade(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var trade_id: Int
    var exec_id: String
    var order_id: Int
    var order_book_id: String
    var side: SIDE
    var position_effect: POSITION_EFFECT
    var position_direction: POSITION_DIRECTION
    var quantity: Int
    var price: Float64
    var datetime: DateTime
    var commission: Float64
    var tax: Float64
    
    fn __str__(self) -> String:
        return "Trade(" + String(self.trade_id) + ", " + self.order_book_id + ", " + self.side.value + ", qty=" + String(self.quantity) + ", price=" + String(self.price) + ")"


fn create_trade_with_id(
    trade_id: Int,
    order: Order,
    quantity: Int,
    price: Float64,
    commission: Float64 = 0.0,
    tax: Float64 = 0.0
) -> Trade:
    return Trade(
        trade_id=trade_id,
        exec_id=String(trade_id),
        order_id=order.order_id,
        order_book_id=order.order_book_id,
        side=order.side,
        position_effect=order.position_effect,
        position_direction=POSITION_DIRECTION_LONG,
        quantity=quantity,
        price=price,
        datetime=DateTime(1970, 1, 1, 0, 0, 0, 0),
        commission=commission,
        tax=tax
    )


fn create_trade(
    order: Order,
    quantity: Int,
    price: Float64,
    commission: Float64 = 0.0,
    tax: Float64 = 0.0
) -> Trade:
    return create_trade_with_id(1, order, quantity, price, commission, tax)


fn create_trade_from_order(
    trade_id: Int,
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    position_direction: POSITION_DIRECTION,
    quantity: Int,
    price: Float64
) -> Trade:
    return Trade(
        trade_id=trade_id,
        exec_id=String(trade_id),
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        position_effect=position_effect,
        position_direction=position_direction,
        quantity=quantity,
        price=price,
        datetime=DateTime(1970, 1, 1, 0, 0, 0, 0),
        commission=0.0,
        tax=0.0
    )
