"""
RQAlpha Mojo - Account Management
Ported from rqalpha/portfolio/account.py
"""

from std.collections import List
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, SIDE, POSITION_DIRECTION, POSITION_EFFECT
from rqmojo.model.trade import Trade
from rqmojo.portfolio.position import Position, create_position, create_future_position
from rqmojo.utils.typing import DateTime


struct Account(ImplicitlyCopyable):
    var account_type: DEFAULT_ACCOUNT_TYPE
    var total_cash: Float64
    var total_value: Float64
    var positions_count: Int
    var frozen_cash: Float64
    var margin_val: Float64
    var daily_pnl: Float64
    var cash_liabilities: Float64
    var _positions: List[Position]

    def __str__(self) -> String:
        return "Account(" + self.account_type.value + ", cash=" + String(self.total_cash) + ", value=" + String(self.total_value) + ")"

    def __init__(out self, account_type: DEFAULT_ACCOUNT_TYPE, total_cash: Float64, total_value: Float64, 
                 positions_count: Int, frozen_cash: Float64, margin_val: Float64, daily_pnl: Float64,
                 cash_liabilities: Float64, var _positions: List[Position]):
        self.account_type = account_type
        self.total_cash = total_cash
        self.total_value = total_value
        self.positions_count = positions_count
        self.frozen_cash = frozen_cash
        self.margin_val = margin_val
        self.daily_pnl = daily_pnl
        self.cash_liabilities = cash_liabilities
        self._positions = _positions^

    def __init__(out self, *, copy: Self):
        self.account_type = copy.account_type
        self.total_cash = copy.total_cash
        self.total_value = copy.total_value
        self.positions_count = copy.positions_count
        self.frozen_cash = copy.frozen_cash
        self.margin_val = copy.margin_val
        self.daily_pnl = copy.daily_pnl
        self.cash_liabilities = copy.cash_liabilities
        self._positions = List[Position]()
        for i in range(len(copy._positions)):
            self._positions.append(copy._positions[i])

    def __init__(out self, *, deinit take: Self):
        self.account_type = take.account_type
        self.total_cash = take.total_cash
        self.total_value = take.total_value
        self.positions_count = take.positions_count
        self.frozen_cash = take.frozen_cash
        self.margin_val = take.margin_val
        self.daily_pnl = take.daily_pnl
        self.cash_liabilities = take.cash_liabilities
        self._positions = take._positions^

    def available_cash(self) -> Float64:
        return self.total_cash - self.frozen_cash - self.margin_val

    def add_cash(mut self, amount: Float64) -> None:
        self.total_cash += amount
        self.total_value += amount

    def subtract_cash(mut self, amount: Float64) -> None:
        self.total_cash -= amount
        self.total_value -= amount

    def _find_position_index(self, order_book_id: String, direction: POSITION_DIRECTION) -> Int:
        for i in range(len(self._positions)):
            if self._positions[i].order_book_id == order_book_id and self._positions[i].direction == direction:
                return i
        return -1

    def get_position(self, order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG) -> Position:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            return self._positions[idx]
        else:
            return create_position(order_book_id, direction)

    def get_or_create_position(mut self, order_book_id: String, direction: POSITION_DIRECTION) -> Position:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            return self._positions[idx]
        else:
            var new_pos = create_position(order_book_id, direction)
            self._positions.append(new_pos)
            self.positions_count += 1
            return new_pos

    def update_position(mut self, order_book_id: String, direction: POSITION_DIRECTION, pos: Position) -> None:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            self._positions[idx] = pos
        else:
            self._positions.append(pos)
            self.positions_count += 1

    def apply_trade(mut self, trade: Trade, commission: Float64 = 0.0) -> None:
        var pos = self.get_or_create_position(trade.order_book_id, trade.position_direction)
        var delta_cash = pos.apply_trade(trade)
        self.update_position(trade.order_book_id, trade.position_direction, pos)
        
        if trade.side == SIDE.BUY:
            self.total_cash -= trade.price * Float64(trade.quantity)
        else:
            self.total_cash += trade.price * Float64(trade.quantity)
        
        self.total_cash -= commission
        self.total_cash += delta_cash
        self._update_margin()

    def _update_margin(mut self) -> None:
        self.margin_val = 0.0
        for i in range(len(self._positions)):
            self.margin_val += self._positions[i].margin()

    def margin(self) -> Float64:
        return self.margin_val

    def update_positions_value(mut self) -> None:
        var positions_value: Float64 = 0.0
        for i in range(len(self._positions)):
            positions_value += self._positions[i].market_value
        self.total_value = self.total_cash + positions_value

    def update_last_price(mut self, order_book_id: String, price: Float64) -> None:
        for i in range(len(self._positions)):
            if self._positions[i].order_book_id == order_book_id:
                self._positions[i].update_last_price(price)
        self._update_margin()
        self.update_positions_value()

    def get_positions(self) -> List[Position]:
        var result = List[Position]()
        for i in range(len(self._positions)):
            result.append(self._positions[i])
        return result^

    def settlement(mut self) -> None:
        for i in range(len(self._positions)):
            self._positions[i].old_quantity = self._positions[i].quantity
            self._positions[i].today_quantity = 0
        self.daily_pnl = 0.0

    def calc_close_today_amount(
        self,
        order_book_id: String,
        quantity: Int,
        position_direction: POSITION_DIRECTION,
        position_effect: POSITION_EFFECT
    ) -> Int:
        if position_effect == POSITION_EFFECT.CLOSE_TODAY:
            return quantity
        return 0


def create_account(account_type: DEFAULT_ACCOUNT_TYPE, total_cash: Float64) -> Account:
    return Account(
        account_type=account_type,
        total_cash=total_cash,
        total_value=total_cash,
        positions_count=0,
        frozen_cash=0.0,
        margin_val=0.0,
        daily_pnl=0.0,
        cash_liabilities=0.0,
        _positions=List[Position]()
    )


def create_stock_account(total_cash: Float64 = 100000.0) -> Account:
    return create_account(DEFAULT_ACCOUNT_TYPE.STOCK, total_cash)


def create_future_account(total_cash: Float64 = 100000.0) -> Account:
    return create_account(DEFAULT_ACCOUNT_TYPE.FUTURE, total_cash)
