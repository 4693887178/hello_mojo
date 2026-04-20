"""
RQAlpha Mojo - Position Management
Ported from rqalpha/portfolio/position.py

Classes:
  Position              - Base position class with full lifecycle
  PositionProxy         - Long+Short position aggregation proxy
  PositionProxyDict     - Dict-like container for position proxies
"""

from std.collections import List, Dict
from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION
from rqmojo.model.instrument import Instrument
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.portfolio.position_queue import PositionQueue, PositionQueueItem, create_position_queue


struct Position(Movable):
    var order_book_id: String
    var direction: POSITION_DIRECTION
    var quantity: Int
    var old_quantity: Int
    var logical_old_quantity: Int
    var avg_price: Float64
    var trade_cost: Float64
    var transaction_cost: Float64
    var prev_close: Float64
    var last_price: Float64
    var direction_factor: Int
    var queue: PositionQueue

    def __init__(out self):
        self.order_book_id = ""
        self.direction = POSITION_DIRECTION.LONG
        self.quantity = 0
        self.old_quantity = 0
        self.logical_old_quantity = 0
        self.avg_price = 0.0
        self.trade_cost = 0.0
        self.transaction_cost = 0.0
        self.prev_close = 0.0
        self.last_price = 0.0
        self.direction_factor = 1
        self.queue = create_position_queue()

    def __init__(out self, *, deinit take: Self):
        self.order_book_id = take.order_book_id^
        self.direction = take.direction
        self.quantity = take.quantity
        self.old_quantity = take.old_quantity
        self.logical_old_quantity = take.logical_old_quantity
        self.avg_price = take.avg_price
        self.trade_cost = take.trade_cost
        self.transaction_cost = take.transaction_cost
        self.prev_close = take.prev_close
        self.last_price = take.last_price
        self.direction_factor = take.direction_factor
        self.queue = take.queue^

    def __str__(self) -> String:
        return "Position(" + self.order_book_id + ", qty=" + String(self.quantity) + ", avg=" + String(self.avg_price) + ")"

    def direction_factor_val(self) -> Int:
        return self.direction_factor

    def pnl(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        return (self.last_price - self.avg_price) * Float64(self.quantity) * Float64(self.direction_factor)

    def trading_pnl(self) -> Float64:
        var trade_qty = self.quantity - self.logical_old_quantity
        return (Float64(trade_qty) * self.last_price - self.trade_cost) * Float64(self.direction_factor)

    def position_pnl(self) -> Float64:
        if self.logical_old_quantity == 0:
            return 0.0
        return Float64(self.logical_old_quantity) * (self.last_price - self.prev_close) * Float64(self.direction_factor)

    def daily_pnl(self) -> Float64:
        return self.position_pnl() + self.trading_pnl()

    def market_value(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        return self.last_price * Float64(self.quantity)

    def equity(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        return self.last_price * Float64(self.quantity)

    def transaction_cost_val(self) -> Float64:
        return self.transaction_cost

    def avg_price_val(self) -> Float64:
        return self.avg_price

    def quantity_val(self) -> Int:
        return self.quantity

    def direction_val(self) -> POSITION_DIRECTION:
        return self.direction

    def order_book_id_val(self) -> String:
        return self.order_book_id

    def last_price_val(self) -> Float64:
        return self.last_price

    def prev_close_val(self) -> Float64:
        return self.prev_close

    def closable(self) -> Int:
        return self.quantity

    def today_closable(self) -> Int:
        return self.quantity - self.old_quantity

    def position_queue(self) -> PositionQueue:
        return self.queue.copy()

    def get_state(self) -> Dict[String, String]:
        var state = Dict[String, String]()
        state["old_quantity"] = String(self.old_quantity)
        state["logical_old_quantity"] = String(self.logical_old_quantity)
        state["quantity"] = String(self.quantity)
        state["avg_price"] = String(self.avg_price)
        state["trade_cost"] = String(self.trade_cost)
        state["transaction_cost"] = String(self.transaction_cost)
        state["prev_close"] = String(self.prev_close)
        return state^

    def set_state(mut self, state: Dict[String, String]) -> None:
        self.old_quantity = _get_int(state, "old_quantity", 0)
        self.logical_old_quantity = _get_int(state, "logical_old_quantity", self.old_quantity)
        if "quantity" in state:
            self.quantity = _get_int(state, "quantity", 0)
        else:
            self.quantity = self.old_quantity + _get_int(state, "today_quantity", 0)
        self.avg_price = _get_float(state, "avg_price", 0.0)
        self.trade_cost = _get_float(state, "trade_cost", 0.0)
        self.transaction_cost = _get_float(state, "transaction_cost", 0.0)
        self.prev_close = _get_float(state, "prev_close", 0.0)

    def before_trading(mut self) -> Float64:
        self.old_quantity = self.quantity
        self.logical_old_quantity = self.old_quantity
        self.trade_cost = 0.0
        self.transaction_cost = 0.0
        self.prev_close = 0.0
        return 0.0

    def _update_costs(mut self, trade: Trade) -> None:
        self.transaction_cost += trade.transaction_cost()
        var pe = trade.position_effect_resolved()
        if pe == POSITION_EFFECT.OPEN:
            self.trade_cost += trade.last_price * Float64(trade.last_quantity())
        else:
            self.trade_cost -= trade.last_price * Float64(trade.last_quantity())

    def apply_trade(mut self, trade: Trade) -> Float64:
        self._update_costs(trade)
        var pe = trade.position_effect_resolved()
        if pe == POSITION_EFFECT.OPEN:
            var qty = trade.last_quantity()
            self.queue.handle_trade_open(qty)
            if self.quantity < 0:
                if self.quantity + qty > 0:
                    self.avg_price = trade.last_price
                else:
                    self.avg_price = 0.0
            else:
                var cost = self.avg_price * Float64(self.quantity) + trade.last_price * Float64(qty)
                self.avg_price = cost / Float64(self.quantity + qty)
            self.quantity += qty
            return (-1.0 * trade.last_price * Float64(qty)) - trade.transaction_cost()
        elif pe == POSITION_EFFECT.CLOSE:
            var qty = trade.last_quantity()
            self.queue.handle_trade_close(qty)
            self.old_quantity -= min(qty, self.old_quantity)
            self.quantity -= qty
            return trade.last_price * Float64(qty) - trade.transaction_cost()
        else:
            return 0.0

    def settlement(mut self, trading_date: DateTimeDate) -> Float64:
        return 0.0

    def update_last_price(mut self, price: Float64) -> None:
        self.last_price = price

    def calc_close_today_amount(self, trade_amount: Int, position_effect: POSITION_EFFECT) -> Int:
        return 0


fn _get_int(state: Dict[String, String], key: String, default: Int) -> Int:
    if key in state:
        return Int(state[key])
    return default

fn _get_float(state: Dict[String, String], key: String, default: Float64) -> Float64:
    if key in state:
        return Float64(state[key])
    return default


def create_position(
    order_book_id: String,
    direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG,
    quantity: Int = 0,
    avg_price: Float64 = 0.0
) -> Position:
    var pos = Position()
    pos.order_book_id = order_book_id
    pos.direction = direction
    pos.quantity = quantity
    pos.old_quantity = quantity
    pos.logical_old_quantity = 0
    pos.avg_price = avg_price
    pos.trade_cost = 0.0
    pos.transaction_cost = 0.0
    pos.prev_close = avg_price
    pos.last_price = avg_price
    pos.direction_factor = 1 if direction == POSITION_DIRECTION.LONG else -1
    if quantity > 0:
        pos.queue.handle_trade_init(quantity)
    return pos


def create_stock_position(order_book_id: String, quantity: Int = 0, avg_price: Float64 = 0.0) -> Position:
    return create_position(order_book_id, POSITION_DIRECTION.LONG, quantity, avg_price)


def create_future_position(
    order_book_id: String,
    direction: POSITION_DIRECTION,
    quantity: Int = 0,
    avg_price: Float64 = 0.0
) -> Position:
    return create_position(order_book_id, direction, quantity, avg_price)


struct PositionProxy(Movable):
    var long_pos: Position
    var short_pos: Position

    def __init__(out self, *, deinit long_pos: Position, deinit short_pos: Position):
        self.long_pos = long_pos^
        self.short_pos = short_pos^

    def __str__(self) -> String:
        return "PositionProxy(" + self.long_pos.order_book_id + ")"

    def order_book_id(self) -> String:
        return self.long_pos.order_book_id

    def last_price(self) -> Float64:
        return self.long_pos.last_price

    def market_value(self) -> Float64:
        return self.long_pos.market_value() - self.short_pos.market_value()

    def position_pnl(self) -> Float64:
        return self.long_pos.position_pnl() + self.short_pos.position_pnl()

    def trading_pnl(self) -> Float64:
        return self.long_pos.trading_pnl() + self.short_pos.trading_pnl()

    def daily_pnl(self) -> Float64:
        return self.long_pos.position_pnl() + self.long_pos.trading_pnl() + self.short_pos.position_pnl() + \
               self.short_pos.trading_pnl() - self.transaction_cost()

    def pnl(self) -> Float64:
        return self.long_pos.pnl() + self.short_pos.pnl()

    def margin(self) -> Float64:
        return 0.0

    def transaction_cost(self) -> Float64:
        return self.long_pos.transaction_cost_val() + self.short_pos.transaction_cost_val()

    def long_position(self) -> Position:
        return self.long_pos

    def short_position(self) -> Position:
        return self.short_pos


def create_position_proxy(long_pos: Position, short_pos: Position) -> PositionProxy:
    return PositionProxy(long_pos=long_pos^, short_pos=short_pos^)


struct PositionProxyDict:
    var _data: Dict[String, Tuple[Position, Position]]

    def __init__(out self):
        self._data = Dict[String, Tuple[Position, Position]]()

    def __init__(out self, *, deinit take: Self):
        self._data = take._data^

    def keys(self) -> List[String]:
        var result = List[String]()
        for key in self._data.keys():
            result.append(key)
        return result^

    def len(self) -> Int:
        return len(self._data)

    def contains(self, order_book_id: String) -> Bool:
        return order_book_id in self._data

    def get_proxy(mut self, order_book_id: String) -> PositionProxy:
        if order_book_id not in self._data:
            var long_pos = create_position(order_book_id, POSITION_DIRECTION.LONG)
            var short_pos = create_position(order_book_id, POSITION_DIRECTION.SHORT)
            self._data[order_book_id] = (long_pos^, short_pos^)
        var entry = self._data.remove(order_book_id)
        var long_pos = entry.get[0, Position]()
        var short_pos = entry.get[1, Position]()
        self._data[order_book_id] = (long_pos^, short_pos^)
        return create_position_proxy(long_pos^, short_pos^)

    def set_positions(mut self, order_book_id: String, long_pos: Position, short_pos: Position) -> None:
        self._data[order_book_id] = (long_pos^, short_pos^)

    def items(self) -> List[Tuple[String, PositionProxy]]:
        var result = List[Tuple[String, PositionProxy]]()
        for key in self._data.keys():
            var entry = self._data.remove(key)
            var long_pos = entry.get[0, Position]()
            var short_pos = entry.get[1, Position]()
            var proxy = create_position_proxy(long_pos^, short_pos^__)
            result.append((key, proxy^))
            self._data[key] = (entry.get[0, Position](), entry.get[1, Position]())
        return result^
