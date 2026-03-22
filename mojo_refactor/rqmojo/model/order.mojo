"""
RQAlpha Mojo - Order Object Model
Ported from rqalpha/model/order.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, ORDER_TYPE, ORDER_TYPE_MARKET, ORDER_TYPE_LIMIT, ORDER_STATUS_FILLED, ORDER_STATUS_ACTIVE, ORDER_STATUS_CANCELLED, ORDER_STATUS_REJECTED, ORDER_STATUS_PENDING_NEW, SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct OrderIdGenerator(Writable, Movable):
    var counter: Int
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("OrderIdGenerator(", String(self.counter), ")")
    
    def next(mut self) -> Int:
        self.counter += 1
        return self.counter


def create_order_id_generator() -> OrderIdGenerator:
    return OrderIdGenerator(counter=0)


@fieldwise_init
struct OrderStyle(Writable, Copyable, Movable, ImplicitlyCopyable):
    var style_type: ORDER_TYPE
    var limit_price: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        if self.style_type == ORDER_TYPE_MARKET:
            writer.write("MarketOrder")
        else:
            writer.write("LimitOrder(", String(self.limit_price), ")")


def MarketOrder() -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE_MARKET, limit_price=0.0)


def LimitOrder(price: Float64) -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE_LIMIT, limit_price=price)


@fieldwise_init
struct Order(Writable, Copyable, Movable, ImplicitlyCopyable):
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
    var price: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("Order(", String(self.order_id), ", ", self.order_book_id, ", ", self.side.value(), ", qty=", String(self.quantity), ")")
    
    def order_type(self) -> ORDER_TYPE:
        return self.style.style_type
    
    def fill(mut self, quantity: Int, price: Float64) -> None:
        self.filled_quantity += quantity
        self.unfilled_quantity = self.quantity - self.filled_quantity
        if self.filled_quantity > 0:
            var old_total = self.avg_price * Float64(self.filled_quantity - quantity)
            var new_total = price * Float64(quantity)
            self.avg_price = (old_total + new_total) / Float64(self.filled_quantity)
        if self.unfilled_quantity == 0:
            self.status = ORDER_STATUS_FILLED
        elif self.filled_quantity > 0:
            self.status = ORDER_STATUS_ACTIVE
    
    def is_active(self) -> Bool:
        return self.status == ORDER_STATUS_ACTIVE or self.status == ORDER_STATUS_PENDING_NEW
    
    def is_filled(self) -> Bool:
        return self.status == ORDER_STATUS_FILLED
    
    def is_cancelled(self) -> Bool:
        return self.status == ORDER_STATUS_CANCELLED
    
    def is_rejected(self) -> Bool:
        return self.status == ORDER_STATUS_REJECTED


def create_order_with_id(
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    quantity: Int,
    style: OrderStyle,
    position_effect: POSITION_EFFECT = POSITION_EFFECT_OPEN
) -> Order:
    var price = style.limit_price
    return Order(
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        position_effect=position_effect,
        quantity=quantity,
        filled_quantity=0,
        unfilled_quantity=quantity,
        status=ORDER_STATUS_PENDING_NEW,
        style=style,
        avg_price=0.0,
        created_at=DateTime(1970, 1, 1, 0, 0, 0, 0),
        transaction_cost=0.0,
        price=price
    )


def buy(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(1, order_book_id, SIDE_BUY, quantity, style, POSITION_EFFECT_OPEN)


def sell(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(2, order_book_id, SIDE_SELL, quantity, style, POSITION_EFFECT_CLOSE)
