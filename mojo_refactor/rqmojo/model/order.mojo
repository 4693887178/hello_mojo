"""
RQAlpha Mojo - Order Object Model
Ported from rqalpha/model/order.py

Classes:
  OrderIdGenerator       - Order ID generation counter
  OrderStyle             - Base order style (MARKET/LIMIT)
  AlgoOrderStyle         - Algorithmic order style base (TWAP/VWAP)
  Order                  - Core order model
"""

from std.collections import Dict
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, ORDER_TYPE, POSITION_DIRECTION, ALGO
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

    def get_limit_price(self) -> Optional[Float64]:
        if self.style_type == ORDER_TYPE.MARKET:
            return None
        else:
            return self.limit_price

    def round_price(mut self, tick_size: Float64) -> None:
        if self.style_type != ORDER_TYPE.LIMIT:
            return
        if tick_size > 0.0:
            var ratio = self.limit_price / tick_size
            var integral = Float64(Int(ratio))
            self.limit_price = integral * tick_size


def MarketOrder() -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.MARKET, limit_price=0.0)


def LimitOrder(price: Float64) -> OrderStyle:
    return OrderStyle(style_type=ORDER_TYPE.LIMIT, limit_price=price)


struct AlgoOrderStyle(Writable, Copyable, Movable, ImplicitlyCopyable):
    var algo_type: ALGO
    var start_min: Int
    var end_min: Int

    def __init__(out self, algo_type: ALGO, start_min: Int, end_min: Int):
        self.algo_type = algo_type
        self.start_min = start_min
        self.end_min = end_min

    def __init__(out self, *, copy: Self):
        self.algo_type = copy.algo_type
        self.start_min = copy.start_min
        self.end_min = copy.end_min

    def __init__(out self, *, deinit take: Self):
        self.algo_type = take.algo_type
        self.start_min = take.start_min
        self.end_min = take.end_min

    def write_to(self, mut writer: Some[Writer]):
        if self.algo_type == ALGO.TWAP:
            writer.write("TWAPOrder(start=", String(self.start_min), ", end=", String(self.end_min), ")")
        else:
            writer.write("VWAPOrder(start=", String(self.start_min), ", end=", String(self.end_min), ")")

    def get_limit_price(self) -> Optional[Float64]:
        return None


def TWAPOrder(start_min: Int, end_min: Int) -> AlgoOrderStyle:
    return AlgoOrderStyle(algo_type=ALGO.TWAP, start_min=start_min, end_min=end_min)


def VWAPOrder(start_min: Int, end_min: Int) -> AlgoOrderStyle:
    return AlgoOrderStyle(algo_type=ALGO.VWAP, start_min=start_min, end_min=end_min)


struct Order(Writable, Movable, Copyable):
    var order_id: Int
    var secondary_order_id: String
    var order_book_id: String
    var side: SIDE
    var position_effect: Optional[POSITION_EFFECT]
    var quantity: Int
    var filled_quantity: Int
    var status: ORDER_STATUS
    var frozen_price: Float64
    var init_frozen_cash: Float64
    var order_type_val: ORDER_TYPE
    var avg_price: Float64
    var transaction_cost: Float64
    var estimated_transaction_cost_val: Float64
    var message: String
    var calendar_dt: DateTime
    var trading_dt: DateTime
    var style_order: OrderStyle
    var style_algo: Optional[AlgoOrderStyle]
    var kwargs: Dict[String, String]

    def __init__(
        out self,
        order_id: Int,
        order_book_id: String,
        side: SIDE,
        quantity: Int,
        position_effect: Optional[POSITION_EFFECT],
        frozen_price: Float64,
        calendar_dt: DateTime,
        trading_dt: DateTime,
        order_type_val: ORDER_TYPE,
        style_order: OrderStyle,
        style_algo: Optional[AlgoOrderStyle],
    ):
        self.order_id = order_id
        self.secondary_order_id = ""
        self.order_book_id = order_book_id
        self.side = side
        self.position_effect = position_effect
        self.quantity = quantity
        self.filled_quantity = 0
        self.status = ORDER_STATUS.PENDING_NEW
        self.frozen_price = frozen_price
        self.init_frozen_cash = 0.0
        self.order_type_val = order_type_val
        self.avg_price = 0.0
        self.transaction_cost = 0.0
        self.estimated_transaction_cost_val = 0.0
        self.message = ""
        self.calendar_dt = calendar_dt
        self.trading_dt = trading_dt
        self.style_order = style_order
        self.style_algo = style_algo
        self.kwargs = Dict[String, String]()

    def __init__(out self, *, copy: Self):
        self.order_id = copy.order_id
        self.secondary_order_id = copy.secondary_order_id
        self.order_book_id = copy.order_book_id
        self.side = copy.side
        self.position_effect = copy.position_effect
        self.quantity = copy.quantity
        self.filled_quantity = copy.filled_quantity
        self.status = copy.status
        self.frozen_price = copy.frozen_price
        self.init_frozen_cash = copy.init_frozen_cash
        self.order_type_val = copy.order_type_val
        self.avg_price = copy.avg_price
        self.transaction_cost = copy.transaction_cost
        self.estimated_transaction_cost_val = copy.estimated_transaction_cost_val
        self.message = copy.message
        self.calendar_dt = copy.calendar_dt
        self.trading_dt = copy.trading_dt
        self.style_order = copy.style_order
        self.style_algo = copy.style_algo
        self.kwargs = copy.kwargs.copy()

    def __init__(out self, *, deinit take: Self):
        self.order_id = take.order_id
        self.secondary_order_id = take.secondary_order_id^
        self.order_book_id = take.order_book_id^
        self.side = take.side
        self.position_effect = take.position_effect
        self.quantity = take.quantity
        self.filled_quantity = take.filled_quantity
        self.status = take.status
        self.frozen_price = take.frozen_price
        self.init_frozen_cash = take.init_frozen_cash
        self.order_type_val = take.order_type_val
        self.avg_price = take.avg_price
        self.transaction_cost = take.transaction_cost
        self.estimated_transaction_cost_val = take.estimated_transaction_cost_val
        self.message = take.message^
        self.calendar_dt = take.calendar_dt
        self.trading_dt = take.trading_dt
        self.style_order = take.style_order^
        self.style_algo = take.style_algo
        self.kwargs = take.kwargs^

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "Order(id=", String(self.order_id),
            ", ", self.order_book_id,
            ", ", self.side.value,
            ", qty=", String(self.quantity),
            ", status=", self.status.value,
            ")"
        )

    def order_type(self) -> ORDER_TYPE:
        return self.order_type_val

    def get_secondary_order_id(self) -> String:
        return self.secondary_order_id

    def trading_datetime(self) -> DateTime:
        return self.trading_dt

    def datetime(self) -> DateTime:
        return self.calendar_dt

    def unfilled_quantity(self) -> Int:
        return self.quantity - self.filled_quantity

    def price(self) -> Float64:
        if self.order_type_val == ORDER_TYPE.MARKET:
            return 0.0
        return self.frozen_price

    def position_effect_resolved(self) -> POSITION_EFFECT:
        var pe = self.position_effect
        if pe == None:
            if self.side == SIDE.BUY:
                return POSITION_EFFECT.OPEN
            else:
                return POSITION_EFFECT.CLOSE
        return pe.value()

    def position_direction(self) -> POSITION_DIRECTION:
        var pe = self.position_effect_resolved()
        if self.side == SIDE.BUY:
            if pe == POSITION_EFFECT.CLOSE or pe == POSITION_EFFECT.CLOSE_TODAY:
                return POSITION_DIRECTION.SHORT
            return POSITION_DIRECTION.LONG
        else:
            if pe == POSITION_EFFECT.OPEN:
                return POSITION_DIRECTION.SHORT
            return POSITION_DIRECTION.LONG

    def estimated_transaction_cost(self) -> Float64:
        return self.estimated_transaction_cost_val

    def set_estimated_transaction_cost(mut self, value: Float64) -> None:
        self.estimated_transaction_cost_val = value

    def get_state(self) -> Dict[String, String]:
        var state = Dict[String, String]()
        state["order_id"] = String(self.order_id)
        state["secondary_order_id"] = self.secondary_order_id
        state["order_book_id"] = self.order_book_id
        state["quantity"] = String(self.quantity)
        state["filled_quantity"] = String(self.filled_quantity)
        state["side"] = self.side.value
        if self.position_effect != None:
            state["position_effect"] = self.position_effect.value().value
        else:
            state["position_effect"] = ""
        state["status"] = self.status.value
        state["message"] = self.message
        state["frozen_price"] = String(self.frozen_price)
        state["type"] = self.order_type_val.value
        state["transaction_cost"] = String(self.transaction_cost)
        state["avg_price"] = String(self.avg_price)
        state["init_frozen_cash"] = String(self.init_frozen_cash)
        return state^

    def fill(
        mut self,
        quantity: Int,
        price: Float64,
        trade_cost: Float64 = 0.0,
        trade_position_effect: Optional[POSITION_EFFECT] = None,
    ) -> None:
        assert self.filled_quantity + quantity <= self.quantity, "fill quantity exceeds order quantity"
        var new_qty = self.filled_quantity + quantity
        self.transaction_cost += trade_cost
        var should_update_avg = True
        if trade_position_effect != None:
            if trade_position_effect.value() == POSITION_EFFECT.MATCH:
                should_update_avg = False
        if should_update_avg and new_qty > 0:
            var old_total = self.avg_price * Float64(self.filled_quantity)
            var new_total = price * Float64(quantity)
            self.avg_price = (old_total + new_total) / Float64(new_qty)
        self.filled_quantity = new_qty
        if self.unfilled_quantity() == 0:
            self.status = ORDER_STATUS.FILLED

    def is_active(self) -> Bool:
        return self.status == ORDER_STATUS.ACTIVE

    def is_filled(self) -> Bool:
        return self.status == ORDER_STATUS.FILLED

    def is_cancelled(self) -> Bool:
        return self.status == ORDER_STATUS.CANCELLED

    def is_rejected(self) -> Bool:
        return self.status == ORDER_STATUS.REJECTED

    def is_final(self) -> Bool:
        return not (
            self.status == ORDER_STATUS.PENDING_NEW
            or self.status == ORDER_STATUS.ACTIVE
            or self.status == ORDER_STATUS.PENDING_CANCEL
        )

    def active(mut self) -> None:
        self.status = ORDER_STATUS.ACTIVE

    def mark_rejected(mut self, reject_reason: String) -> None:
        if not self.is_final():
            self.message = reject_reason
            self.status = ORDER_STATUS.REJECTED

    def mark_cancelled(mut self, cancelled_reason: String, user_warn: Bool = True) -> None:
        if not self.is_final():
            self.message = cancelled_reason
            self.status = ORDER_STATUS.CANCELLED

    def set_pending_cancel(mut self) -> None:
        if not self.is_final():
            self.status = ORDER_STATUS.PENDING_CANCEL

    def set_frozen_price(mut self, value: Float64) -> None:
        self.frozen_price = value

    def set_frozen_cash(mut self, value: Float64) -> None:
        self.init_frozen_cash = value

    def set_secondary_order_id(mut self, secondary_order_id: String) -> None:
        self.secondary_order_id = secondary_order_id

    def get_kwargs(self) -> Dict[String, String]:
        return self.kwargs.copy()

    def get_kwarg(self, key: String) raises -> Optional[String]:
        if key in self.kwargs:
            return self.kwargs[key]
        return None

    def set_kwarg(mut self, key: String, value: String) -> None:
        self.kwargs[key] = value

    def style(self) -> ORDER_TYPE:
        return self.order_type_val


def create_order_with_id(
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    quantity: Int,
    style: OrderStyle,
    position_effect: Optional[POSITION_EFFECT] = None,
    frozen_price: Float64 = 0.0,
) -> Order:
    var actual_frozen_price = frozen_price
    if style.style_type == ORDER_TYPE.LIMIT:
        actual_frozen_price = style.limit_price
    var now = DateTime(1970, 1, 1, 0, 0, 0, 0)
    return Order(
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        quantity=quantity,
        position_effect=position_effect,
        frozen_price=actual_frozen_price,
        calendar_dt=now,
        trading_dt=now,
        order_type_val=style.style_type,
        style_order=style,
        style_algo=None,
    )


def create_algo_order_with_id(
    order_id: Int,
    order_book_id: String,
    side: SIDE,
    quantity: Int,
    style: AlgoOrderStyle,
    position_effect: Optional[POSITION_EFFECT] = None,
    frozen_price: Float64 = 0.0,
) -> Order:
    var now = DateTime(1970, 1, 1, 0, 0, 0, 0)
    return Order(
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        quantity=quantity,
        position_effect=position_effect,
        frozen_price=frozen_price,
        calendar_dt=now,
        trading_dt=now,
        order_type_val=ORDER_TYPE.ALGO,
        style_order=OrderStyle(style_type=ORDER_TYPE.MARKET, limit_price=0.0),
        style_algo=style,
    )


def buy(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(1, order_book_id, SIDE.BUY, quantity, style, POSITION_EFFECT.OPEN)


def sell(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    return create_order_with_id(2, order_book_id, SIDE.SELL, quantity, style, POSITION_EFFECT.CLOSE)
