"""
RQAlpha Mojo - Order Object Model
Ported from rqalpha/model/order.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, ORDER_TYPE, POSITION_DIRECTION
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime


struct OrderIdGenerator(Writable, Movable, Copyable, ImplicitlyCopyable):
    var counter: Int
    
    def __init__(out self):
        self.counter = 0
    
    def __init__(out self, counter: Int):
        self.counter = counter
    
    def __init__(out self, *, copy: Self):
        self.counter = copy.counter
    
    def __init__(out self, *, deinit take: Self):
        self.counter = take.counter
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("OrderIdGenerator(", String(self.counter), ")")
    
    def next(mut self) -> Int:
        self.counter += 1
        return self.counter


def create_order_id_generator() -> OrderIdGenerator:
    return OrderIdGenerator()


struct OrderStyle(Writable, Copyable, Movable, ImplicitlyCopyable):
    var style_type: ORDER_TYPE
    var limit_price: Float64
    
    def __init__(out self, style_type: ORDER_TYPE, limit_price: Float64 = 0.0):
        self.style_type = style_type
        self.limit_price = limit_price
    
    def __init__(out self, *, copy: Self):
        self.style_type = copy.style_type
        self.limit_price = copy.limit_price
    
    def __init__(out self, *, deinit take: Self):
        self.style_type = take.style_type
        self.limit_price = take.limit_price
    
    def write_to(self, mut writer: Some[Writer]):
        if self.style_type == ORDER_TYPE.MARKET:
            writer.write("MarketOrder")
        else:
            writer.write("LimitOrder(", String(self.limit_price), ")")


def MarketOrder() -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.MARKET, limit_price=0.0)


def LimitOrder(price: Float64) -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.LIMIT, limit_price=price)


struct Order(Writable, Movable, Copyable, ImplicitlyCopyable):
    var order_id: Int
    var secondary_order_id: String
    var order_book_id: String
    var side: SIDE
    var position_effect: POSITION_EFFECT
    var quantity: Int
    var filled_quantity: Int
    var unfilled_quantity: Int
    var status: ORDER_STATUS
    var style: OrderStyle
    var avg_price: Float64
    var calendar_dt: DateTime
    var trading_dt: DateTime
    var transaction_cost: Float64
    var price: Float64
    var frozen_price: Float64
    var init_frozen_cash: Float64
    var message: String
    var estimated_transaction_cost: Float64
    
    def __init__(
        out self,
        order_id: Int,
        order_book_id: String,
        side: SIDE,
        position_effect: POSITION_EFFECT,
        quantity: Int,
        filled_quantity: Int,
        unfilled_quantity: Int,
        status: ORDER_STATUS,
        style: OrderStyle,
        avg_price: Float64,
        calendar_dt: DateTime,
        trading_dt: DateTime,
        transaction_cost: Float64,
        price: Float64,
    ):
        self.order_id = order_id
        self.secondary_order_id = ""
        self.order_book_id = order_book_id
        self.side = side
        self.position_effect = position_effect
        self.quantity = quantity
        self.filled_quantity = filled_quantity
        self.unfilled_quantity = unfilled_quantity
        self.status = status
        self.style = style
        self.avg_price = avg_price
        self.calendar_dt = calendar_dt
        self.trading_dt = trading_dt
        self.transaction_cost = transaction_cost
        self.price = price
        self.frozen_price = price
        self.init_frozen_cash = 0.0
        self.message = ""
        self.estimated_transaction_cost = 0.0
    
    def __init__(out self, *, copy: Self):
        self.order_id = copy.order_id
        self.secondary_order_id = copy.secondary_order_id
        self.order_book_id = copy.order_book_id
        self.side = copy.side
        self.position_effect = copy.position_effect
        self.quantity = copy.quantity
        self.filled_quantity = copy.filled_quantity
        self.unfilled_quantity = copy.unfilled_quantity
        self.status = copy.status
        self.style = copy.style
        self.avg_price = copy.avg_price
        self.calendar_dt = copy.calendar_dt
        self.trading_dt = copy.trading_dt
        self.transaction_cost = copy.transaction_cost
        self.price = copy.price
        self.frozen_price = copy.frozen_price
        self.init_frozen_cash = copy.init_frozen_cash
        self.message = copy.message
        self.estimated_transaction_cost = copy.estimated_transaction_cost
    
    def __init__(out self, *, deinit take: Self):
        self.order_id = take.order_id
        self.secondary_order_id = take.secondary_order_id
        self.order_book_id = take.order_book_id
        self.side = take.side
        self.position_effect = take.position_effect
        self.quantity = take.quantity
        self.filled_quantity = take.filled_quantity
        self.unfilled_quantity = take.unfilled_quantity
        self.status = take.status
        self.style = take.style
        self.avg_price = take.avg_price
        self.calendar_dt = take.calendar_dt
        self.trading_dt = take.trading_dt
        self.transaction_cost = take.transaction_cost
        self.price = take.price
        self.frozen_price = take.frozen_price
        self.init_frozen_cash = take.init_frozen_cash
        self.message = take.message
        self.estimated_transaction_cost = take.estimated_transaction_cost
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("Order(", String(self.order_id), ", ", self.order_book_id, ", ", self.side.value, ", qty=", String(self.quantity), ")")
    
    def order_type(self) -> ORDER_TYPE:
        return self.style.style_type
    
    def get_secondary_order_id(self) -> String:
        return self.secondary_order_id
    
    def trading_datetime(self) -> DateTime:
        return self.trading_dt
    
    def datetime(self) -> DateTime:
        return self.calendar_dt
    
    def position_direction(self) -> POSITION_DIRECTION:
        if self.side == SIDE.BUY:
            return POSITION_DIRECTION.LONG
        else:
            return POSITION_DIRECTION.SHORT
    
    def get_state(self) -> Dict[String, String]:
        var state = Dict[String, String]()
        state["order_id"] = String(self.order_id)
        state["secondary_order_id"] = self.secondary_order_id
        state["order_book_id"] = self.order_book_id
        state["quantity"] = String(self.quantity)
        state["filled_quantity"] = String(self.filled_quantity)
        state["side"] = self.side.value
        state["position_effect"] = self.position_effect.value
        state["status"] = self.status.value
        state["message"] = self.message
        state["frozen_price"] = String(self.frozen_price)
        state["init_frozen_cash"] = String(self.init_frozen_cash)
        state["transaction_cost"] = String(self.transaction_cost)
        state["avg_price"] = String(self.avg_price)
        return state
    
    def fill(mut self, quantity: Int, price: Float64) -> None:
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
    
    def is_active(self) -> Bool:
        return self.status == ORDER_STATUS.ACTIVE or self.status == ORDER_STATUS.PENDING_NEW
    
    def is_filled(self) -> Bool:
        return self.status == ORDER_STATUS.FILLED
    
    def is_cancelled(self) -> Bool:
        return self.status == ORDER_STATUS.CANCELLED
    
    def is_rejected(self) -> Bool:
        return self.status == ORDER_STATUS.REJECTED
    
    def is_final(self) -> Bool:
        return self.status not in [
            ORDER_STATUS.PENDING_NEW,
            ORDER_STATUS.ACTIVE,
            ORDER_STATUS.PENDING_CANCEL
        ]
    
    def active(mut self) -> None:
        self.status = ORDER_STATUS.ACTIVE
    
    def mark_rejected(mut self, reject_reason: String) -> None:
        if not self.is_final():
            self.message = reject_reason
            self.status = ORDER_STATUS.REJECTED
    
    def mark_cancelled(mut self, cancelled_reason: String) -> None:
        if not self.is_final():
            self.message = cancelled_reason
            self.status = ORDER_STATUS.CANCELLED
    
    def set_pending_cancel(mut self) -> None:
        if not self.is_final():
            self.status = ORDER_STATUS.PENDING_CANCEL


def create_order_with_id(
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    quantity: Int,
    style: OrderStyle,
    position_effect: POSITION_EFFECT = POSITION_EFFECT.OPEN
) -> Order:
    var price = style.limit_price
    var now = DateTime(1970, 1, 1, 0, 0, 0, 0)
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
        calendar_dt=now,
        trading_dt=now,
        transaction_cost=0.0,
        price=price
    )


def buy(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(1, order_book_id, SIDE.BUY, quantity, style, POSITION_EFFECT.OPEN)


def sell(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(2, order_book_id, SIDE.SELL, quantity, style, POSITION_EFFECT.CLOSE)
