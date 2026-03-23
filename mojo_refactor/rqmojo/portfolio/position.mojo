"""
RQAlpha Mojo - Position Management
Ported from rqalpha/portfolio/position.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION, INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.portfolio.position_queue import PositionQueue, PositionQueueItem, create_position_queue


struct Position(Movable, ImplicitlyCopyable):
    var order_book_id: String
    var direction: POSITION_DIRECTION
    var quantity: Int
    var old_quantity: Int
    var today_quantity: Int
    var avg_price: Float64
    var trade_quantity: Int
    var market_value: Float64
    var last_price: Float64
    var prev_close: Float64
    var _margin_rate: Float64
    var _contract_multiplier: Float64
    var _position_queue: PositionQueue
    var _trade_cost: Float64
    var _logical_old_quantity: Int

    def __init__(out self):
        self.order_book_id = ""
        self.direction = POSITION_DIRECTION.LONG
        self.quantity = 0
        self.old_quantity = 0
        self.today_quantity = 0
        self.avg_price = 0.0
        self.trade_quantity = 0
        self.market_value = 0.0
        self.last_price = 0.0
        self.prev_close = 0.0
        self._margin_rate = 0.1
        self._contract_multiplier = 1.0
        self._position_queue = create_position_queue()
        self._trade_cost = 0.0
        self._logical_old_quantity = 0

    def __init__(out self, *, copy: Self):
        self.order_book_id = copy.order_book_id
        self.direction = copy.direction
        self.quantity = copy.quantity
        self.old_quantity = copy.old_quantity
        self.today_quantity = copy.today_quantity
        self.avg_price = copy.avg_price
        self.trade_quantity = copy.trade_quantity
        self.market_value = copy.market_value
        self.last_price = copy.last_price
        self.prev_close = copy.prev_close
        self._margin_rate = copy._margin_rate
        self._contract_multiplier = copy._contract_multiplier
        self._position_queue = copy._position_queue
        self._trade_cost = copy._trade_cost
        self._logical_old_quantity = copy._logical_old_quantity

    def __init__(out self, *, deinit take: Self):
        self.order_book_id = take.order_book_id
        self.direction = take.direction
        self.quantity = take.quantity
        self.old_quantity = take.old_quantity
        self.today_quantity = take.today_quantity
        self.avg_price = take.avg_price
        self.trade_quantity = take.trade_quantity
        self.market_value = take.market_value
        self.last_price = take.last_price
        self.prev_close = take.prev_close
        self._margin_rate = take._margin_rate
        self._contract_multiplier = take._contract_multiplier
        self._position_queue = take._position_queue^
        self._trade_cost = take._trade_cost
        self._logical_old_quantity = take._logical_old_quantity

    def __str__(self) -> String:
        return "Position(" + self.order_book_id + ", qty=" + String(self.quantity) + ", avg=" + String(self.avg_price) + ")"

    def pnl(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        var direction_factor: Float64 = 1.0
        if self.direction == POSITION_DIRECTION.SHORT:
            direction_factor = -1.0
        return direction_factor * (self.last_price - self.avg_price) * Float64(self.quantity) * self._contract_multiplier

    def daily_pnl(self) -> Float64:
        return self.position_pnl() + self.trading_pnl()

    def position_pnl(self) -> Float64:
        if self._logical_old_quantity == 0:
            return 0.0
        var direction_factor: Float64 = 1.0
        if self.direction == POSITION_DIRECTION_SHORT:
            direction_factor = -1.0
        return direction_factor * (self.last_price - self.prev_close) * Float64(self._logical_old_quantity) * self._contract_multiplier

    def trading_pnl(self) -> Float64:
        var trade_quantity = self.quantity - self._logical_old_quantity
        var direction_factor: Float64 = 1.0
        if self.direction == POSITION_DIRECTION_SHORT:
            direction_factor = -1.0
        return (Float64(trade_quantity) * self.last_price - self._trade_cost) * direction_factor * self._contract_multiplier

    def margin(self) -> Float64:
        if self.quantity == 0:
            return 0.0
        return self._margin_rate * self.market_value

    def closable(self) -> Int:
        return self.quantity

    def position_queue(self) -> PositionQueue:
        return self._position_queue.copy()

    def apply_trade(mut self, trade: Trade) -> Float64:
        var delta_cash: Float64 = 0.0
        var trade_amount = trade.price * Float64(trade.quantity) * self._contract_multiplier
        
        if trade.position_effect == POSITION_EFFECT.OPEN:
            var old_total = self.avg_price * Float64(self.quantity)
            self.quantity += trade.quantity
            self.today_quantity += trade.quantity
            if self.quantity > 0:
                self.avg_price = (old_total + trade.price * Float64(trade.quantity)) / Float64(self.quantity)
            self._trade_cost += trade.price * Float64(trade.quantity)
            delta_cash = -trade_amount
        elif trade.position_effect == POSITION_EFFECT_CLOSE:
            self.quantity -= trade.quantity
            if self.old_quantity >= trade.quantity:
                self.old_quantity -= trade.quantity
            else:
                self.today_quantity -= (trade.quantity - self.old_quantity)
                self.old_quantity = 0
            if self.quantity < 0:
                self.quantity = 0
            self._trade_cost -= trade.price * Float64(trade.quantity)
            delta_cash = trade_amount
        elif trade.position_effect == POSITION_EFFECT_CLOSE_TODAY:
            self.quantity -= trade.quantity
            self.today_quantity -= trade.quantity
            if self.today_quantity < 0:
                self.today_quantity = 0
            if self.quantity < 0:
                self.quantity = 0
            self._trade_cost -= trade.price * Float64(trade.quantity)
            delta_cash = trade_amount
        
        self._update_market_value()
        return delta_cash

    def apply_trade_with_date(mut self, trade: Trade, trade_date: DateTimeDate) -> Float64:
        var delta_cash: Float64 = 0.0
        var trade_amount = trade.price * Float64(trade.quantity) * self._contract_multiplier
        
        if trade.position_effect == POSITION_EFFECT_OPEN:
            var old_total = self.avg_price * Float64(self.quantity)
            self.quantity += trade.quantity
            self.today_quantity += trade.quantity
            if self.quantity > 0:
                self.avg_price = (old_total + trade.price * Float64(trade.quantity)) / Float64(self.quantity)
            self._trade_cost += trade.price * Float64(trade.quantity)
            delta_cash = -trade_amount
            self._position_queue.push(trade_date, trade.quantity)
        elif trade.position_effect == POSITION_EFFECT_CLOSE:
            self.quantity -= trade.quantity
            if self.old_quantity >= trade.quantity:
                self.old_quantity -= trade.quantity
            else:
                self.today_quantity -= (trade.quantity - self.old_quantity)
                self.old_quantity = 0
            if self.quantity < 0:
                self.quantity = 0
            self._trade_cost -= trade.price * Float64(trade.quantity)
            delta_cash = trade_amount
            self._position_queue.pop(trade.quantity)
        elif trade.position_effect == POSITION_EFFECT_CLOSE_TODAY:
            self.quantity -= trade.quantity
            self.today_quantity -= trade.quantity
            if self.today_quantity < 0:
                self.today_quantity = 0
            if self.quantity < 0:
                self.quantity = 0
            self._trade_cost -= trade.price * Float64(trade.quantity)
            delta_cash = trade_amount
            self._position_queue.pop(trade.quantity)
        
        if self.quantity == 0:
            self._position_queue.clear()
        
        self._update_market_value()
        return delta_cash

    def update_last_price(mut self, price: Float64) -> None:
        self.last_price = price
        self._update_market_value()

    def update_prev_close(mut self, prev_close: Float64) -> None:
        self.prev_close = prev_close

    def update_margin_rate(mut self, margin_rate: Float64) -> None:
        self._margin_rate = margin_rate

    def before_trading(mut self) -> None:
        self.old_quantity = self.quantity
        self._logical_old_quantity = self.quantity
        self.today_quantity = 0
        self.trade_quantity = 0
        self._trade_cost = 0.0

    def settlement(mut self) -> None:
        self.prev_close = self.last_price
        self.old_quantity = self.quantity

    def _update_market_value(mut self) -> None:
        self.market_value = self.last_price * Float64(self.quantity) * self._contract_multiplier


def create_position(
    order_book_id: String,
    direction: POSITION_DIRECTION = POSITION_DIRECTION_LONG,
    quantity: Int = 0,
    avg_price: Float64 = 0.0,
    contract_multiplier: Float64 = 1.0,
    margin_rate: Float64 = 0.1
) -> Position:
    var pos = Position()
    pos.order_book_id = order_book_id
    pos.direction = direction
    pos.quantity = quantity
    pos.old_quantity = quantity
    pos._logical_old_quantity = quantity
    pos.today_quantity = 0
    pos.avg_price = avg_price
    pos.trade_quantity = 0
    pos.market_value = avg_price * Float64(quantity) * contract_multiplier
    pos.last_price = avg_price
    pos.prev_close = avg_price
    pos._margin_rate = margin_rate
    pos._contract_multiplier = contract_multiplier
    pos._position_queue = create_position_queue()
    pos._trade_cost = 0.0
    return pos


def create_stock_position(order_book_id: String, quantity: Int = 0, avg_price: Float64 = 0.0) -> Position:
    return create_position(order_book_id, POSITION_DIRECTION.LONG, quantity, avg_price, 1.0, 1.0)


def create_future_position(
    order_book_id: String,
    direction: POSITION_DIRECTION,
    quantity: Int = 0,
    avg_price: Float64 = 0.0,
    contract_multiplier: Float64 = 10.0,
    margin_rate: Float64 = 0.1
) -> Position:
    return create_position(order_book_id, direction, quantity, avg_price, contract_multiplier, margin_rate)


@fieldwise_init
struct PositionProxy(Copyable, Movable, ImplicitlyCopyable):
    var order_book_id: String
    var direction: POSITION_DIRECTION
    var quantity: Int
    var avg_price: Float64
    var market_value: Float64
    var pnl: Float64
    var daily_pnl: Float64
    var margin: Float64
    var closable: Int

    def __str__(self) -> String:
        return "PositionProxy(" + self.order_book_id + ", qty=" + String(self.quantity) + ")"


def create_position_proxy(position: Position) -> PositionProxy:
    return PositionProxy(
        order_book_id=position.order_book_id,
        direction=position.direction,
        quantity=position.quantity,
        avg_price=position.avg_price,
        market_value=position.market_value,
        pnl=position.pnl(),
        daily_pnl=position.daily_pnl(),
        margin=position.margin(),
        closable=position.closable()
    )
