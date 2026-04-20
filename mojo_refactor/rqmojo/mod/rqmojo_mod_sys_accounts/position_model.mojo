"""
RQAlpha Mojo - Position Model
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/position_model.py

Classes (matching Python original):
  StockPosition          - Stock position with dividend/split/settlement logic (lines 45-292)
  FuturePosition         - Futures position with margin/contract multiplier (lines 295-414)
  StockPositionProxy     - Proxy aggregating long stock position (lines 417-454)
  FuturePositionProxy    - Proxy aggregating long+short future positions (lines 457-670)
"""

from std.collections import Dict, List, Optional
from std.python import Python, PythonObject

from rqmojo.const import (
    POSITION_DIRECTION, SIDE, POSITION_EFFECT,
    DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, TRADING_CALENDAR_TYPE
)
from rqmojo.model.trade import Trade
from rqmojo.portfolio.position import Position, create_position
from rqmojo.portfolio.position_queue import PositionQueue
from rqmojo.utils.typing import DateTime, DateTimeDate


struct DividendReceivableItem(Copyable, Movable, ImplicitlyCopyable):
    var date: PythonObject
    var value: Float64

    def __init__(out self, date: PythonObject, value: Float64):
        self.date = date
        self.value = value


@fieldwise_init
struct StockPosition(Movable):
    """Stock position model ported from Python StockPosition(Position)."""
    var _position: Position
    var _dividend_receivable: List[DividendReceivableItem]
    var _non_closable: Int
    var _daily_dividend: Float64
    var _daily_split: Float64
    var _unadjusted_prev_close: Optional[Float64]

    comptime dividend_reinvestment: Bool = False
    comptime dividend_tax_rate: Float64 = 0.0
    comptime cash_return_by_stock_delisted: Bool = True
    comptime t_plus_enabled: Bool = True
    comptime calendar_type = TRADING_CALENDAR_TYPE.CN_STOCK

    def __init__(
        out self,
        order_book_id: String,
        direction: POSITION_DIRECTION,
        init_quantity: Int = 0,
        init_price: Optional[Float64] = None,
    ):
        var price = 0.0
        if init_price != None:
            price = init_price.value()
        self._position = create_position(
            order_book_id=order_book_id,
            direction=direction,
            quantity=init_quantity,
            avg_price=price,
            contract_multiplier=1.0,
            margin_rate=1.0
        )
        self._dividend_receivable = List[DividendReceivableItem]()
        self._non_closable = 0
        self._daily_dividend = 0.0
        self._daily_split = 1.0
        self._unadjusted_prev_close = None

    def __init__(out self, *, deinit take: Self):
        self._position = take._position^
        self._dividend_receivable = take._dividend_receivable^
        self._non_closable = take._non_closable
        self._daily_dividend = take._daily_dividend
        self._daily_split = take._daily_split
        self._unadjusted_prev_close = take._unadjusted_prev_close

    def order_book_id(self) -> String:
        return self._position.order_book_id

    def direction(self) -> POSITION_DIRECTION:
        return self._position.direction

    def quantity(self) -> Int:
        return self._position.quantity

    def old_quantity(self) -> Int:
        return self._position.old_quantity

    def today_quantity(self) -> Int:
        return self._position.today_quantity

    def avg_price(self) -> Float64:
        return self._position.avg_price

    def last_price(self) -> Float64:
        return self._position.last_price

    def prev_close(self) -> Float64:
        return self._position.prev_close

    def set_last_price(mut self, price: Float64) -> None:
        self._position.update_last_price(price)

    def update_last_price(mut self, price: Float64) -> None:
        self._position.update_last_price(price)

    def market_value(self) -> Float64:
        return self._position.market_value

    def market_value_local(self) -> Float64:
        return self.market_value()

    def pnl(self) -> Float64:
        return self._position.pnl()

    def direction_factor(self) -> Float64:
        if self._position.direction == POSITION_DIRECTION.LONG:
            return 1.0
        else:
            return -1.0

    def trading_pnl(self) -> Float64:
        var trade_qty = self._position.quantity - self._position._logical_old_quantity * Int(self._daily_split)
        var df = self.direction_factor()
        return (Float64(trade_qty) * self._position.last_price - self._position._trade_cost) * df

    def position_pnl(self) -> Float64:
        if self._position._logical_old_quantity == 0:
            return 0.0
        var unadjusted_pc = 0.0
        if self._unadjusted_prev_close != None:
            unadjusted_pc = self._unadjusted_prev_close.value()
        var df = self.direction_factor()
        return (
            Float64(self._position._logical_old_quantity) * self._daily_split *
            (self._position.last_price - unadjusted_pc / self._daily_split) +
            self._daily_dividend
        ) * df

    def equity(self) -> Float64:
        return self._position.pnl() + self.dividend_receivable_total()

    def dividend_receivable_total(self) -> Float64:
        var total = 0.0
        for item in self._dividend_receivable:
            total += item.value
        return total

    def closable(self) -> Int:
        return self._position.quantity - self._non_closable

    def apply_trade(mut self, trade: Trade) raises -> Float64:
        var delta_cash = self._position.apply_trade(trade)
        if trade.position_effect == POSITION_EFFECT.OPEN:
            var mtplus = self._get_market_tplus()
            if mtplus >= 1 and Self.t_plus_enabled:
                self._non_closable += Int(py=trade.quantity)
        return delta_cash

    def before_trading(mut self, trading_date: DateTimeDate) raises -> Float64:
        self._position.before_trading()
        if self._unadjusted_prev_close == None or self._position.last_price > 0:
            self._unadjusted_prev_close = Optional[Float64](self._position.last_price)
        if self._position.quantity == 0 and len(self._dividend_receivable) == 0:
            return 0.0
        if self._position.direction != POSITION_DIRECTION.LONG:
            raise Error("direction of stock position " + self._position.order_book_id + " is not supposed to be short")
        return 0.0

    def settlement(mut self, trading_date: DateTimeDate) raises -> Float64:
        self._position.settlement()
        if self._position.quantity == 0:
            return 0.0
        if self._position.direction != POSITION_DIRECTION.LONG:
            raise Error("direction of stock position " + self._position.order_book_id + " is not supposed to be short")
        return 0.0

    def get_state(self) raises -> Dict[String, PythonObject]:
        var state = Dict[String, PythonObject]()
        state["order_book_id"] = PythonObject(self._position.order_book_id)
        state["direction"] = PythonObject(self._position.direction.value)
        state["quantity"] = PythonObject(self._position.quantity)
        state["old_quantity"] = PythonObject(self._position.old_quantity)
        state["today_quantity"] = PythonObject(self._position.today_quantity)
        state["avg_price"] = PythonObject(self._position.avg_price)
        state["last_price"] = PythonObject(self._position.last_price)
        state["prev_close"] = PythonObject(self._position.prev_close)
        state["non_closable"] = PythonObject(self._non_closable)
        state["daily_dividend"] = PythonObject(self._daily_dividend)
        state["daily_split"] = PythonObject(self._daily_split)
        var dr_list = Python.list()
        for item in self._dividend_receivable:
            dr_list.append(Python.tuple(item.date, PythonObject(item.value)))
        state["dividend_receivable"] = dr_list
        if self._unadjusted_prev_close != None:
            state["unadjusted_prev_close"] = PythonObject(self._unadjusted_prev_close.value())
        else:
            state["unadjusted_prev_close"] = Python.none()
        return state^

    def set_state(mut self, state: Dict[String, PythonObject]) raises -> None:
        self._position.order_book_id = String(py=state["order_book_id"])
        self._position.quantity = Int(py=state["quantity"])
        self._position.old_quantity = Int(py=state["old_quantity"])
        self._position.today_quantity = Int(py=state["today_quantity"])
        self._position.avg_price = Float64(py=state["avg_price"])
        self._position.last_price = Float64(py=state["last_price"])
        self._position.prev_close = Float64(py=state["prev_close"])
        self._non_closable = Int(py=state["non_closable"])
        self._daily_dividend = Float64(py=state["daily_dividend"])
        self._daily_split = Float64(py=state["daily_split"])
        self._dividend_receivable = List[DividendReceivableItem]()
        var dr_list = state["dividend_receivable"]
        var dr_len = Int(py=len(dr_list))
        for i in range(dr_len):
            var item_py = dr_list[i]
            self._dividend_receivable.append(DividendReceivableItem(date=item_py[0], value=Float64(py=item_py[1])))
        var upc = state["unadjusted_prev_close"]
        if upc != Python.none():
            self._unadjusted_prev_close = Optional[Float64](Float64(py=upc))
        else:
            self._unadjusted_prev_close = None

    def _get_market_tplus(self) -> Int:
        return 1

    def position_queue(self) -> PositionQueue:
        return self._position.position_queue()


def create_stock_position(
    order_book_id: String,
    direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG,
    init_quantity: Int = 0,
    init_price: Optional[Float64] = None,
) -> StockPosition:
    return StockPosition(
        order_book_id=order_book_id,
        direction=direction,
        init_quantity=init_quantity,
        init_price=init_price
    )


@fieldwise_init
struct FuturePosition(Movable):
    """Future position model ported from Python FuturePosition(Position)."""
    var _position: Position
    var _contract_multiplier: Float64
    var _futures_settlement_price_type: String
    var _transaction_cost: Float64

    def __init__(
        out self,
        order_book_id: String,
        direction: POSITION_DIRECTION,
        init_quantity: Int = 0,
        init_price: Optional[Float64] = None,
        contract_multiplier: Float64 = 10.0,
    ):
        var price = 0.0
        if init_price != None:
            price = init_price.value()
        self._position = create_position(
            order_book_id=order_book_id,
            direction=direction,
            quantity=init_quantity,
            avg_price=price,
            contract_multiplier=1.0,
            margin_rate=0.1
        )
        self._contract_multiplier = contract_multiplier
        self._futures_settlement_price_type = "close"
        self._transaction_cost = 0.0

    def __init__(out self, *, deinit take: Self):
        self._position = take._position^
        self._contract_multiplier = take._contract_multiplier
        self._futures_settlement_price_type = take._futures_settlement_price_type
        self._transaction_cost = take._transaction_cost

    def order_book_id(self) -> String:
        return self._position.order_book_id

    def direction(self) -> POSITION_DIRECTION:
        return self._position.direction

    def quantity(self) -> Int:
        return self._position.quantity

    def old_quantity(self) -> Int:
        return self._position.old_quantity

    def today_quantity(self) -> Int:
        return self._position.today_quantity

    def avg_price(self) -> Float64:
        return self._position.avg_price

    def last_price(self) -> Float64:
        return self._position.last_price

    def prev_close(self) -> Float64:
        return self._position.prev_close

    def set_last_price(mut self, price: Float64) -> None:
        self._position.update_last_price(price)

    def update_last_price(mut self, price: Float64) -> None:
        self._position.update_last_price(price)

    def contract_multiplier(self) -> Float64:
        return self._contract_multiplier

    def direction_factor(self) -> Float64:
        if self._position.direction == POSITION_DIRECTION.LONG:
            return 1.0
        else:
            return -1.0

    def margin_rate(self) -> Float64:
        return self._position._margin_rate

    def update_margin_rate(mut self, rate: Float64) -> None:
        self._position.update_margin_rate(rate)

    def equity(self) -> Float64:
        var df = self.direction_factor()
        return Float64(self._position.quantity) * (self._position.last_price - self._position.avg_price) * self._contract_multiplier * df

    def margin(self) -> Float64:
        if self._position.quantity == 0:
            return 0.0
        return self.margin_rate() * self.market_value()

    def market_value(self) -> Float64:
        return self._contract_multiplier * self._position.market_value

    def trading_pnl(self) -> Float64:
        return self._contract_multiplier * self._position.trading_pnl()

    def position_pnl(self) -> Float64:
        return self._contract_multiplier * self._position.position_pnl()

    def pnl(self) -> Float64:
        return self._position.pnl() * self._contract_multiplier

    def calc_close_today_amount(self, trade_amount: Int, position_effect: POSITION_EFFECT) -> Int:
        if position_effect == POSITION_EFFECT.CLOSE_TODAY:
            if trade_amount <= self.today_quantity():
                return trade_amount
            else:
                return self.today_quantity()
        else:
            var result = trade_amount - self._position.old_quantity
            if result > 0:
                return result
            else:
                return 0

    def apply_trade(mut self, trade: Trade) raises -> Float64:
        if trade.position_effect == POSITION_EFFECT.CLOSE_TODAY:
            self._transaction_cost += trade.transaction_cost()
            var qty = Int(py=trade.quantity)
            self._position.quantity -= qty
            self._position._trade_cost -= trade.last_price * Float64(qty)
            self._position._position_queue.pop(qty)
        else:
            _ = self._position.apply_trade(trade)

        if trade.position_effect == POSITION_EFFECT.OPEN:
            return -1.0 * trade.transaction_cost()
        else:
            var df = self.direction_factor()
            var qty = Int(py=trade.quantity)
            return -1.0 * trade.transaction_cost() + (
                trade.last_price - self._position.avg_price
            ) * Float64(qty) * self._contract_multiplier * df

    def settlement(mut self, trading_date: DateTimeDate) -> Float64:
        self._position.settlement()
        if self._position.quantity == 0:
            return 0.0
        var delta_cash = self.equity()
        self._position.avg_price = self._position.last_price
        return delta_cash

    def post_settlement(mut self) -> None:
        pass

    def closable(self) -> Int:
        return self._position.closable()

    def position_queue(self) -> PositionQueue:
        return self._position.position_queue()

    def get_state(self) raises -> Dict[String, PythonObject]:
        var state = Dict[String, PythonObject]()
        state["order_book_id"] = PythonObject(self._position.order_book_id)
        state["direction"] = PythonObject(self._position.direction.value)
        state["quantity"] = PythonObject(self._position.quantity)
        state["old_quantity"] = PythonObject(self._position.old_quantity)
        state["today_quantity"] = PythonObject(self._position.today_quantity)
        state["avg_price"] = PythonObject(self._position.avg_price)
        state["last_price"] = PythonObject(self._position.last_price)
        state["prev_close"] = PythonObject(self._position.prev_close)
        state["contract_multiplier"] = PythonObject(self._contract_multiplier)
        state["transaction_cost"] = PythonObject(self._transaction_cost)
        state["trade_cost"] = PythonObject(self._position._trade_cost)
        return state^

    def set_state(mut self, state: Dict[String, PythonObject]) raises -> None:
        self._position.order_book_id = String(py=state["order_book_id"])
        var dir_val = String(py=state["direction"])
        if dir_val == "LONG":
            self._position.direction = POSITION_DIRECTION.LONG
        else:
            self._position.direction = POSITION_DIRECTION.SHORT
        self._position.quantity = Int(py=state["quantity"])
        self._position.old_quantity = Int(py=state["old_quantity"])
        self._position.today_quantity = Int(py=state["today_quantity"])
        self._position.avg_price = Float64(py=state["avg_price"])
        self._position.last_price = Float64(py=state["last_price"])
        self._position.prev_close = Float64(py=state["prev_close"])
        self._contract_multiplier = Float64(py=state["contract_multiplier"])
        self._transaction_cost = Float64(py=state["transaction_cost"])
        self._position._trade_cost = Float64(py=state["trade_cost"])


def create_future_position(
    order_book_id: String,
    direction: POSITION_DIRECTION,
    init_quantity: Int = 0,
    init_price: Optional[Float64] = None,
    contract_multiplier: Float64 = 10.0,
) -> FuturePosition:
    return FuturePosition(
        order_book_id=order_book_id,
        direction=direction,
        init_quantity=init_quantity,
        init_price=init_price,
        contract_multiplier=contract_multiplier
    )


@fieldwise_init
struct StockPositionProxy(Movable):
    """Stock position proxy ported from Python StockPositionProxy(PositionProxy)."""
    var _long: StockPosition

    def type_name(self) -> String:
        return "STOCK"

    def order_book_id(self) -> String:
        return self._long.order_book_id()

    def quantity(self) -> Int:
        return self._long.quantity()

    def sellable(self) -> Int:
        return self._long.closable()

    def avg_price(self) -> Float64:
        return self._long.avg_price()

    def market_value(self) -> Float64:
        return self._long.market_value()

    def pnl(self) -> Float64:
        return self._long.pnl()

    def daily_pnl(self) -> Float64:
        return self._long.trading_pnl() + self._long.position_pnl()

    def margin(self) -> Float64:
        return self._long.market_value()

    def closable(self) -> Int:
        return self._long.closable()

    def value_percent(self, total_portfolio_value: Float64) -> Float64:
        if total_portfolio_value == 0.0:
            return 0.0
        return self.market_value() / total_portfolio_value


@fieldwise_init
struct FuturePositionProxy(Movable):
    """Future position proxy ported from Python FuturePositionProxy(PositionProxy)."""
    var _long: FuturePosition
    var _short: FuturePosition

    def type_name(self) -> String:
        return "FUTURE"

    def order_book_id(self) -> String:
        return self._long.order_book_id()

    def margin_rate(self) -> Float64:
        return self._long.margin_rate()

    def contract_multiplier(self) -> Float64:
        return self._long.contract_multiplier()

    def buy_market_value(self) -> Float64:
        return self._long.market_value()

    def sell_market_value(self) -> Float64:
        return self._short.market_value()

    def buy_position_pnl(self) -> Float64:
        return self._long.position_pnl()

    def sell_position_pnl(self) -> Float64:
        return self._short.position_pnl()

    def buy_trading_pnl(self) -> Float64:
        return self._long.trading_pnl()

    def sell_trading_pnl(self) -> Float64:
        return self._short.trading_pnl()

    def buy_daily_pnl(self) -> Float64:
        return self.buy_position_pnl() + self.buy_trading_pnl()

    def sell_daily_pnl(self) -> Float64:
        return self.sell_position_pnl() + self.sell_trading_pnl()

    def buy_pnl(self) -> Float64:
        return self._long.pnl()

    def sell_pnl(self) -> Float64:
        return self._short.pnl()

    def buy_old_quantity(self) -> Int:
        return self._long.old_quantity()

    def sell_old_quantity(self) -> Int:
        return self._short.old_quantity()

    def buy_today_quantity(self) -> Int:
        return self._long.today_quantity()

    def sell_today_quantity(self) -> Int:
        return self._short.today_quantity()

    def buy_quantity(self) -> Int:
        return self.buy_old_quantity() + self.buy_today_quantity()

    def sell_quantity(self) -> Int:
        return self.sell_old_quantity() + self.sell_today_quantity()

    def margin(self) -> Float64:
        return self._long.margin() + self._short.margin()

    def buy_margin(self) -> Float64:
        return self._long.margin()

    def sell_margin(self) -> Float64:
        return self._short.margin()

    def buy_avg_open_price(self) -> Float64:
        return self._long.avg_price()

    def sell_avg_open_price(self) -> Float64:
        return self._short.avg_price()

    def buy_transaction_cost(self) -> Float64:
        return self._long._transaction_cost

    def sell_transaction_cost(self) -> Float64:
        return self._short._transaction_cost

    def closable_today_sell_quantity(self) -> Int:
        return self._long.today_quantity()

    def closable_today_buy_quantity(self) -> Int:
        return self._long.today_quantity()

    def closable_buy_quantity(self) -> Int:
        return self._long.closable()

    def closable_sell_quantity(self) -> Int:
        return self._short.closable()
