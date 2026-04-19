"""
RQAlpha Mojo - Trade Object Model
Ported from rqalpha/model/trade.py

Classes:
  TradeIdGenerator       - Trade ID generation counter
  Trade                  - Core trade model (represents a filled transaction)
"""

from std.collections import Dict
from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION, MARKET
from rqmojo.model.order import Order
from rqmojo.utils.typing import DateTime


struct TradeIdGenerator(Writable, Movable, Copyable, ImplicitlyCopyable):
    var counter: Int

    def __init__(out self):
        self.counter = 0

    def __init__(out self, start_value: Int):
        self.counter = start_value

    def __init__(out self, *, copy: Self):
        self.counter = copy.counter

    def __init__(out self, *, deinit take: Self):
        self.counter = take.counter

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TradeIdGenerator(", String(self.counter), ")")

    def next(mut self) -> Int:
        self.counter += 1
        return self.counter


def create_trade_id_generator(start_value: Int = 0) -> TradeIdGenerator:
    return TradeIdGenerator(start_value=start_value)


struct Trade(Writable, Movable, Copyable):
    var trade_id: Int
    var exec_id: String
    var order_id: Int
    var order_book_id: String
    var side: SIDE
    var position_effect: Optional[POSITION_EFFECT]
    var position_direction_val: POSITION_DIRECTION
    var quantity: Int
    var last_price: Float64
    var calendar_dt: DateTime
    var trading_dt: DateTime
    var commission: Float64
    var tax: Float64
    var frozen_price: Float64
    var close_today_amount: Int
    var kwargs: Dict[String, String]

    def __init__(
        out self,
        trade_id: Int,
        exec_id: String,
        order_id: Int,
        order_book_id: String,
        side: SIDE,
        position_effect: Optional[POSITION_EFFECT],
        position_direction_val: POSITION_DIRECTION,
        quantity: Int,
        last_price: Float64,
        calendar_dt: DateTime,
        trading_dt: DateTime,
        commission: Float64 = 0.0,
        tax: Float64 = 0.0,
        frozen_price: Float64 = 0.0,
        close_today_amount: Int = 0,
    ):
        self.trade_id = trade_id
        self.exec_id = exec_id
        self.order_id = order_id
        self.order_book_id = order_book_id
        self.side = side
        self.position_effect = position_effect
        self.position_direction_val = position_direction_val
        self.quantity = quantity
        self.last_price = last_price
        self.calendar_dt = calendar_dt
        self.trading_dt = trading_dt
        self.commission = commission
        self.tax = tax
        self.frozen_price = frozen_price
        self.close_today_amount = close_today_amount
        self.kwargs = Dict[String, String]()

    def __init__(out self, *, copy: Self):
        self.trade_id = copy.trade_id
        self.exec_id = copy.exec_id
        self.order_id = copy.order_id
        self.order_book_id = copy.order_book_id
        self.side = copy.side
        self.position_effect = copy.position_effect
        self.position_direction_val = copy.position_direction_val
        self.quantity = copy.quantity
        self.last_price = copy.last_price
        self.calendar_dt = copy.calendar_dt
        self.trading_dt = copy.trading_dt
        self.commission = copy.commission
        self.tax = copy.tax
        self.frozen_price = copy.frozen_price
        self.close_today_amount = copy.close_today_amount
        self.kwargs = copy.kwargs.copy()

    def __init__(out self, *, deinit take: Self):
        self.trade_id = take.trade_id
        self.exec_id = take.exec_id^
        self.order_id = take.order_id
        self.order_book_id = take.order_book_id^
        self.side = take.side
        self.position_effect = take.position_effect
        self.position_direction_val = take.position_direction_val
        self.quantity = take.quantity
        self.last_price = take.last_price
        self.calendar_dt = take.calendar_dt
        self.trading_dt = take.trading_dt
        self.commission = take.commission
        self.tax = take.tax
        self.frozen_price = take.frozen_price
        self.close_today_amount = take.close_today_amount
        self.kwargs = take.kwargs^

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "Trade(id=", String(self.trade_id),
            ", ", self.order_book_id,
            ", ", self.side.value,
            ", qty=", String(self.quantity),
            ", price=", String(self.last_price),
            ")"
        )

    def datetime(self) -> DateTime:
        return self.calendar_dt

    def trading_datetime(self) -> DateTime:
        return self.trading_dt

    def order_id_prop(self) -> Int:
        return self.order_id

    def last_quantity(self) -> Int:
        return self.quantity

    def transaction_cost(self) -> Float64:
        return self.commission + self.tax

    def position_effect_resolved(self) -> POSITION_EFFECT:
        var pe = self.position_effect
        if pe == None:
            if self.side == SIDE.BUY:
                return POSITION_EFFECT.OPEN
            else:
                return POSITION_EFFECT.CLOSE
        return pe.value()

    def position_direction(self) -> POSITION_DIRECTION:
        return self.position_direction_val

    def get_state(self) -> Dict[String, String]:
        var state = Dict[String, String]()
        state["trade_id"] = String(self.trade_id)
        state["exec_id"] = self.exec_id
        state["order_id"] = String(self.order_id)
        state["order_book_id"] = self.order_book_id
        state["side"] = self.side.value
        if self.position_effect != None:
            state["position_effect"] = self.position_effect.value().value
        else:
            state["position_effect"] = ""
        state["position_direction"] = self.position_direction_val.value
        state["quantity"] = String(self.quantity)
        state["last_price"] = String(self.last_price)
        state["commission"] = String(self.commission)
        state["tax"] = String(self.tax)
        state["transaction_cost"] = String(self.transaction_cost())
        state["frozen_price"] = String(self.frozen_price)
        state["close_today_amount"] = String(self.close_today_amount)
        return state^

    def get_kwargs(self) -> Dict[String, String]:
        return self.kwargs.copy()

    def get_kwarg(self, key: String) raises -> Optional[String]:
        if key in self.kwargs:
            return self.kwargs[key]
        return None

    def set_kwarg(mut self, key: String, value: String) -> None:
        self.kwargs[key] = value


def create_trade_with_id(
    trade_id: Int,
    order: Order,
    quantity: Int,
    price: Float64,
    commission: Float64 = 0.0,
    tax: Float64 = 0.0,
    close_today_amount: Int = 0,
    frozen_price: Float64 = 0.0,
) -> Trade:
    var now = DateTime(1970, 1, 1, 0, 0, 0, 0)
    return Trade(
        trade_id=trade_id,
        exec_id=String(trade_id),
        order_id=order.order_id,
        order_book_id=order.order_book_id,
        side=order.side,
        position_effect=order.position_effect,
        position_direction_val=order.position_direction(),
        quantity=quantity,
        last_price=price,
        calendar_dt=now,
        trading_dt=now,
        commission=commission,
        tax=tax,
        frozen_price=frozen_price,
        close_today_amount=close_today_amount,
    )


def create_trade(
    order: Order,
    quantity: Int,
    price: Float64,
    commission: Float64 = 0.0,
    tax: Float64 = 0.0,
    close_today_amount: Int = 0,
    frozen_price: Float64 = 0.0,
) -> Trade:
    return create_trade_with_id(1, order, quantity, price, commission, tax, close_today_amount, frozen_price)


def create_trade_from_order(
    trade_id: Int,
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    position_effect: Optional[POSITION_EFFECT],
    position_direction: POSITION_DIRECTION,
    quantity: Int,
    price: Float64,
    commission: Float64 = 0.0,
    tax: Float64 = 0.0,
    close_today_amount: Int = 0,
    frozen_price: Float64 = 0.0,
) -> Trade:
    var now = DateTime(1970, 1, 1, 0, 0, 0, 0)
    return Trade(
        trade_id=trade_id,
        exec_id=String(trade_id),
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        position_effect=position_effect,
        position_direction_val=position_direction,
        quantity=quantity,
        last_price=price,
        calendar_dt=now,
        trading_dt=now,
        commission=commission,
        tax=tax,
        frozen_price=frozen_price,
        close_today_amount=close_today_amount,
    )


def create_trade_full(
    trade_id: Int,
    exec_id: String,
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    position_effect: Optional[POSITION_EFFECT],
    position_direction: POSITION_DIRECTION,
    quantity: Int,
    price: Float64,
    datetime_val: DateTime,
    trading_datetime_val: DateTime,
    commission: Float64 = 0.0,
    tax: Float64 = 0.0,
    frozen_price: Float64 = 0.0,
    close_today_amount: Int = 0,
) -> Trade:
    return Trade(
        trade_id=trade_id,
        exec_id=exec_id,
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        position_effect=position_effect,
        position_direction_val=position_direction,
        quantity=quantity,
        last_price=price,
        calendar_dt=datetime_val,
        trading_dt=trading_datetime_val,
        commission=commission,
        tax=tax,
        frozen_price=frozen_price,
        close_today_amount=close_today_amount,
    )
