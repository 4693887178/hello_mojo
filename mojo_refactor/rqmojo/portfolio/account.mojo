"""
RQAlpha Mojo - Account Management
Ported from rqalpha/portfolio/account.py (556 lines)

Account: Collection of positions and cash.
Different instrument types belong to different accounts:
  - Stock/Convertible Bond/Fund/ETF Option -> STOCK account
  - Future/Future Option -> FUTURE account

Key differences from Python original (env-dependent features simplified):
  - No Environment/EventBus integration (standalone mode)
  - No metaclass margin optimization
  - _positions uses List[Position] instead of Dict[str, Dict[DIR, Position]]
"""

from std.collections import List, Dict
from std.python import Python, PythonObject
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, SIDE, POSITION_DIRECTION, POSITION_EFFECT, DAYS_CNT
from rqmojo.model.trade import Trade
from rqmojo.model.instrument import Instrument
from rqmojo.portfolio.position import Position, create_position, create_stock_position, create_future_position


struct Account(Copyable, Movable, ImplicitlyCopyable):
    var account_type: String
    var total_cash: Float64
    var frozen_cash: Float64
    var cash_liabilities: Float64
    var financing_rate: Float64
    var management_fee_rate: Float64
    var management_fees: Float64
    var _positions: List[Position]
    var _backward_trade_set: Dict[String, Bool]

    def __init__(out self):
        self.account_type = "STOCK"
        self.total_cash = 0.0
        self.frozen_cash = 0.0
        self.cash_liabilities = 0.0
        self.financing_rate = 0.0
        self.management_fee_rate = 0.0
        self.management_fees = 0.0
        self._positions = List[Position]()
        self._backward_trade_set = Dict[String, Bool]()

    def __init__(out self, *, copy: Self):
        self.account_type = copy.account_type
        self.total_cash = copy.total_cash
        self.frozen_cash = copy.frozen_cash
        self.cash_liabilities = copy.cash_liabilities
        self.financing_rate = copy.financing_rate
        self.management_fee_rate = copy.management_fee_rate
        self.management_fees = copy.management_fees
        self._positions = List[Position]()
        for i in range(len(copy._positions)):
            self._positions.append(copy._positions[i])
        self._backward_trade_set = copy._backward_trade_set.copy()

    def __str__(self) -> String:
        return "Account(" + self.account_type + ", cash=" + String(self.cash()) + ", value=" + String(self.total_value()) + ")"

    # ========================
    # Properties - Cash
    # ========================

    def type_val(self) -> String:
        return self.account_type

    def frozen_cash_val(self) -> Float64:
        return self.frozen_cash

    def cash(self) -> Float64:
        return self.total_cash - self.margin() - self.frozen_cash

    def total_cash_prop(self) -> Float64:
        return self.total_cash - self.margin()

    def cash_liabilities_val(self) -> Float64:
        return self.cash_liabilities

    def cash_liabilities_interest(self) -> Float64:
        var days_a_year = 245.0
        if days_a_year == 0:
            return 0.0
        return self.cash_liabilities * self.financing_rate / days_a_year

    # ========================
    # Properties - Positions Value
    # ========================

    def market_value(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            var p = self._positions[i]
            if p.direction == POSITION_DIRECTION.LONG:
                total += p.market_value()
            else:
                total -= p.market_value()
        return total

    def transaction_cost(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            total += self._positions[i].transaction_cost_val()
        return total

    def position_equity(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            total += self._positions[i].equity()
        return total

    # ========================
    # Properties - Margin
    # ========================

    def margin(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            total += self._positions[i].margin()
        return total

    def buy_margin(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            if self._positions[i].direction == POSITION_DIRECTION.LONG:
                total += self._positions[i].margin()
        return total

    def sell_margin(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            if self._positions[i].direction == POSITION_DIRECTION.SHORT:
                total += self._positions[i].margin()
        return total

    # ========================
    # Properties - PnL
    # ========================

    def position_pnl(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            total += self._positions[i].position_pnl()
        return total

    def trading_pnl(self) -> Float64:
        var total = 0.0
        for i in range(len(self._positions)):
            total += self._positions[i].trading_pnl()
        return total

    def daily_pnl(self) -> Float64:
        return self.trading_pnl() + self.position_pnl() - self.transaction_cost() - self.cash_liabilities_interest()

    # ========================
    # Properties - Total Value
    # ========================

    def total_value(self) -> Float64:
        return self.total_cash + self.position_equity() - self.cash_liabilities - self.cash_liabilities_interest()

    # ========================
    # Properties - Management Fee
    # ========================

    def management_fees_val(self) -> Float64:
        return self.management_fees

    # ========================
    # Position Access
    # ========================

    def get_positions(self) -> List[Position]:
        var result = List[Position]()
        for i in range(len(self._positions)):
            if self._positions[i].quantity != 0 or self._positions[i].equity() != 0:
                result.append(self._positions[i])
        return result^

    def get_position(self, order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG) -> Position:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            return self._positions[idx]
        else:
            return create_position(order_book_id, direction)

    def has_position(self, order_book_id: String) -> Bool:
        return self._find_position_index_any(order_book_id) >= 0

    def get_positions_count(self) -> Int:
        return len(self._positions)

    def position_keys(self) -> List[String]:
        var seen = Dict[String, Bool]()
        var result = List[String]()
        for i in range(len(self._positions)):
            var key = self._positions[i].order_book_id
            if key not in seen:
                seen[key] = True
                result.append(key)
        return result^

    # ========================
    # Position Management
    # ========================

    def _find_position_index(self, order_book_id: String, direction: POSITION_DIRECTION) -> Int:
        for i in range(len(self._positions)):
            if self._positions[i].order_book_id == order_book_id and self._positions[i].direction == direction:
                return i
        return -1

    def _find_position_index_any(self, order_book_id: String) -> Int:
        for i in range(len(self._positions)):
            if self._positions[i].order_book_id == order_book_id:
                return i
        return -1

    def get_or_create_position(mut self, order_book_id: String, direction: POSITION_DIRECTION) -> Position:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            return self._positions[idx]
        else:
            var new_pos = create_position(order_book_id, direction)
            self._positions.append(new_pos)
            return new_pos

    def update_last_price(mut self, order_book_id: String, price: Float64) -> None:
        for i in range(len(self._positions)):
            if self._positions[i].order_book_id == order_book_id:
                self._positions[i].update_last_price(price)

    def calc_close_today_amount(
        mut self,
        order_book_id: String,
        quantity: Int,
        position_direction: POSITION_DIRECTION,
        position_effect: POSITION_EFFECT
    ) -> Int:
        var pos = self.get_or_create_position(order_book_id, position_direction)
        return pos.calc_close_today_amount(quantity, position_effect)

    # ========================
    # Trading
    # ========================

    def available_cash_for(self, instrument: Instrument) -> Float64:
        return self.cash()

    def available_cash(self) -> Float64:
        return self.cash()

    def apply_trade(mut self, trade: Trade) -> None:
        var exec_id_str = trade.exec_id
        if exec_id_str in self._backward_trade_set:
            return
        var order_book_id = trade.order_book_id
        var pe = trade.position_effect_resolved()
        if pe == POSITION_EFFECT.MATCH:
            var long_pos = self.get_or_create_pos_internal(order_book_id, POSITION_DIRECTION.LONG)
            var short_pos = self.get_or_create_pos_internal(order_book_id, POSITION_DIRECTION.SHORT)
            var delta1 = long_pos.apply_trade(trade)
            var delta2 = short_pos.apply_trade(trade)
            self._update_position_in_list(order_book_id, POSITION_DIRECTION.LONG, long_pos)
            self._update_position_in_list(order_book_id, POSITION_DIRECTION.SHORT, short_pos)
            self.total_cash += delta1 + delta2
        else:
            var pos = self.get_or_create_pos_internal(order_book_id, trade.position_direction_val)
            var delta_cash = pos.apply_trade(trade)
            self._update_position_in_list(order_book_id, trade.position_direction_val, pos)
            self.total_cash += delta_cash
        self._backward_trade_set[exec_id_str] = True

    def get_or_create_pos_internal(mut self, order_book_id: String, direction: POSITION_DIRECTION) -> Position:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            return Position(copy=self._positions[idx])
        var new_pos = create_position(order_book_id, direction)
        var result = Position(copy=new_pos)
        self._positions.append(new_pos^)
        return result

    def _update_position_in_list(mut self, order_book_id: String, direction: POSITION_DIRECTION, pos: Position) -> None:
        var idx = self._find_position_index(order_book_id, direction)
        if idx >= 0:
            self._positions[idx] = pos
        else:
            self._positions.append(pos)

    # ========================
    # Lifecycle
    # ========================

    def before_trading(mut self) -> None:
        var new_positions = List[Position]()
        for i in range(len(self._positions)):
            var p = self._positions[i]
            if p.quantity != 0 or p.equity() != 0:
                _ = p.before_trading()
                new_positions.append(p)
        self._positions = new_positions^
        if self.cash_liabilities > 0:
            self.cash_liabilities += self.cash_liabilities_interest()

    def settlement(mut self) -> None:
        from rqmojo.utils.typing import DateTimeDate
        var d = DateTimeDate(2024, 1, 15)
        for i in range(len(self._positions)):
            var delta = self._positions[i].settlement(d)
            self.total_cash += delta
        self._backward_trade_set.clear()
        var fee = self._management_fee_calc()
        self.management_fees += fee
        self.total_cash -= fee

    def _management_fee_calc(self) -> Float64:
        if self.management_fee_rate == 0.0:
            return 0.0
        return self.total_value() * self.management_fee_rate

    # ========================
    # Cash Operations
    # ========================

    def deposit_withdraw(mut self, amount: Float64, receiving_days: Int = 0) -> None:
        if amount < 0 and self.cash() < (-1.0 * amount):
            pass
        self.total_cash += amount

    def finance_repay(mut self, amount: Float64) -> None:
        if self.account_type == "STOCK":
            if amount > 0:
                self.cash_liabilities += amount
                self.total_cash += amount
            elif amount < 0:
                var repay_amount = -amount
                self.cash_liabilities = max(0.0, self.cash_liabilities - repay_amount)
                self.total_cash -= repay_amount
        else:
            pass

    def add_cash(mut self, amount: Float64) -> None:
        self.total_cash += amount

    def subtract_cash(mut self, amount: Float64) -> None:
        self.total_cash -= amount

    # ========================
    # State Serialization
    # ========================

    def get_state(self) -> Dict[String, String]:
        var state = Dict[String, String]()
        state["total_cash"] = String(self.total_cash)
        state["frozen_cash"] = String(self.frozen_cash)
        state["cash_liabilities"] = String(self.cash_liabilities)
        state["financing_rate"] = String(self.financing_rate)
        state["management_fee_rate"] = String(self.management_fee_rate)
        state["management_fees"] = String(self.management_fees)
        state["account_type"] = self.account_type
        return state^

    def set_state(mut self, state: Dict[String, String]) -> None:
        self.total_cash = _state_get_float(state, "total_cash", 0.0)
        self.frozen_cash = _state_get_float(state, "frozen_cash", 0.0)
        self.cash_liabilities = _state_get_float(state, "cash_liabilities", 0.0)
        self.financing_rate = _state_get_float(state, "financing_rate", 0.0)
        self.management_fee_rate = _state_get_float(state, "management_fee_rate", 0.0)
        self.management_fees = _state_get_float(state, "management_fees", 0.0)


def _state_get_float(state: Dict[String, String], key: String, default: Float64) -> Float64:
    var result = default
    try:
        if key in state:
            var val = state[key]
            try:
                result = Float64(val)
            except:
                pass
    except:
        pass
    return result

def _hash_string(s: String) -> Int:
    var h = 0
    for c in s.codepoints():
        h = h * 31 + Int(c)
    return h


def create_account(account_type: String, total_cash: Float64 = 100000.0) -> Account:
    var acc = Account()
    acc.account_type = account_type
    acc.total_cash = total_cash
    return acc


def create_stock_account(total_cash: Float64 = 100000.0) -> Account:
    return create_account("STOCK", total_cash)


def create_future_account(total_cash: Float64 = 100000.0) -> Account:
    return create_account("FUTURE", total_cash)
