"""
RQAlpha Mojo - Order Object Model
Ported from rqalpha/model/order.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, ORDER_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct OrderIdGenerator(Stringable, Movable):
    var counter: Int
    
    fn __str__(self) -> String:
        return "OrderIdGenerator(" + String(self.counter) + ")"
    
    fn next(mut self) -> Int:
        self.counter += 1
        return self.counter


fn create_order_id_generator() -> OrderIdGenerator:
    return OrderIdGenerator(counter=0)


@fieldwise_init
struct OrderStyle(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var style_type: ORDER_TYPE
    var limit_price: Float64
    
    fn __str__(self) -> String:
        if self.style_type == ORDER_TYPE.MARKET:
            return "MarketOrder"
        else:
            return "LimitOrder(" + String(self.limit_price) + ")"


fn MarketOrder() -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.MARKET, limit_price=0.0)


fn LimitOrder(price: Float64) -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.LIMIT, limit_price=price)


@fieldwise_init
struct Order(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var order_id: Int
    var order_book_id: String
    var side: SIDE
    var position_effect: POSITION_EFFECT
    var quantity: Int
    var filled_quantity: Int
    var unfilled_quantity: Int
    var status: ORDER_STATUS
    var style: OrderStyle
    var avg_price: Float64
    var created_at: DateTime
    var transaction_cost: Float64
    
    fn __str__(self) -> String:
        return "Order(" + String(self.order_id) + ", " + self.order_book_id + ", " + self.side.value + ", qty=" + String(self.quantity) + ")"
    
    fn fill(mut self, quantity: Int, price: Float64) -> None:
        self.filled_quantity += quantity
        self.unfilled_quantity = self.quantity - self.filled_quantity
        if self.filled_quantity > 0:
            var old_total = self.avg_price * Float64(self.filled_quantity - quantity)
            var new_total = price * Float64(quantity)
            self.avg_price = (old_total + new_total) / Float64(self.filled_quantity)
        if self.unfilled_quantity == 0:
            self.status = ORDER_STATUS.FILLED
        elif self.filled_quantity > 0:
            self.status = ORDER_STATUS.ACTIVE
    
    fn is_active(self) -> Bool:
        return self.status == ORDER_STATUS.ACTIVE or self.status == ORDER_STATUS.PENDING_NEW
    
    fn is_filled(self) -> Bool:
        return self.status == ORDER_STATUS.FILLED
    
    fn is_cancelled(self) -> Bool:
        return self.status == ORDER_STATUS.CANCELLED
    
    fn is_rejected(self) -> Bool:
        return self.status == ORDER_STATUS.REJECTED


fn create_order_with_id(
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    quantity: Int,
    style: OrderStyle,
    position_effect: POSITION_EFFECT = POSITION_EFFECT.OPEN
) -> Order:
    return Order(
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        position_effect=position_effect,
        quantity=quantity,
        filled_quantity=0,
        unfilled_quantity=quantity,
        status=ORDER_STATUS.PENDING_NEW,
        style=style,
        avg_price=0.0,
        created_at=DateTime(1970, 1, 1, 0, 0, 0, 0),
        transaction_cost=0.0
    )


fn buy(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(1, order_book_id, SIDE.BUY, quantity, style, POSITION_EFFECT.OPEN)


fn sell(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(2, order_book_id, SIDE.SELL, quantity, style, POSITION_EFFECT.CLOSE)
