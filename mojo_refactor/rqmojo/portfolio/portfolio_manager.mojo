"""
RQAlpha Mojo - Portfolio Package
Ported from rqalpha/portfolio/__init__.py

Classes (matching Python original):
  Portfolio          - Investment portfolio, collection of all accounts (lines 43-297)
  MixedPositions     - Mapping interface for positions across all accounts (lines 299-327)
"""

from std.collections import Dict, List, Optional
from std.python import Python, PythonObject

from rqmojo.const import (
    DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION,
    RUN_TYPE, INSTRUMENT_TYPE
)
from rqmojo.model.trade import Trade
from rqmojo.portfolio.account import Account, create_account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position, PositionProxy, create_position, create_position_proxy
from rqmojo.utils.typing import DateTime, DateTimeDate


struct MixedPositions(Movable):
    """MixedPositions ported from Python MixedPositions(Mapping) lines 299-327."""
    var _accounts: Dict[String, Account]

    def __init__(out self, accounts: Dict[String, Account]):
        self._accounts = accounts.copy()

    def __init__(out self, *, deinit take: Self):
        self._accounts = take._accounts^

    def __init__(out self):
        self._accounts = Dict[String, Account]()

    @staticmethod
    def create(accounts: Dict[String, Account]) -> MixedPositions:
        var mp = MixedPositions()
        mp._accounts = accounts.copy()
        return mp^

    def contains(self, order_book_id: String) -> Bool:
        for entry in self._accounts.items():
            if entry.value.has_position(order_book_id):
                return True
        return False

    def get_position(self, order_book_id: String) -> Optional[Position]:
        for entry in self._accounts.items():
            var pos = entry.value.get_position_opt(order_book_id)
            if pos != None:
                return pos
        return None

    def len(self) -> Int:
        var count = 0
        for entry in self._accounts.items():
            count += entry.value.get_positions_count()
        return count

    def keys(self) -> List[String]:
        var result = List[String]()
        for entry in self._accounts.items():
            var pos_keys = entry.value.position_keys()
            for key in pos_keys:
                result.append(key)
        return result^


struct Portfolio(Movable):
    """Portfolio ported from Python Portfolio(object) lines 43-297."""
    var _accounts: Dict[String, Account]
    var _static_unit_net_value: Float64
    var _units: Float64
    var _start_date: DateTime
    var _trading_days_per_year: Float64
    var _trading_dt: DateTime

    def __init__(
        out self,
        starting_cash: Dict[String, Float64],
        init_positions: List[PythonObject],
        financing_rate: Float64,
        start_date: DateTime,
        trading_days_per_year: Float64 = 245.0,
    ):
        self._accounts = Self._init_accounts(starting_cash, init_positions, financing_rate)
        self._static_unit_net_value = 1.0
        self._units = 0.0
        for entry in self._accounts.items():
            self._units += entry.value.total_value
        self._start_date = start_date
        self._trading_days_per_year = trading_days_per_year
        self._trading_dt = start_date

    def __init__(out self, *, deinit take: Self):
        self._accounts = take._accounts^
        self._static_unit_net_value = take._static_unit_net_value
        self._units = take._units
        self._start_date = take._start_date
        self._trading_days_per_year = take._trading_days_per_year
        self._trading_dt = take._trading_dt

    @staticmethod
    def _init_accounts(
        starting_cash: Dict[String, Float64],
        init_positions: List[PythonObject],
        financing_rate: Float64,
    ) -> Dict[String, Account]:
        var accounts = Dict[String, Account]()
        for entry in starting_cash.items():
            var acct = create_stock_account(entry.value)
            accounts[entry.key] = acct
        return accounts^

    def get_state(self) raises -> String:
        var state_dict = Python.dict()
        state_dict["static_unit_net_value"] = PythonObject(self._static_unit_net_value)
        state_dict["units"] = PythonObject(self._units)
        var accounts_dict = Python.dict()
        for entry in self._accounts.items():
            accounts_dict[entry.key] = entry.value.get_state_py()
        state_dict["accounts"] = accounts_dict
        var json_mod = Python.import_module("json")
        var encoded = json_mod.dumps(state_dict)
        return String(py=encoded)

    def set_state(mut self, state: String) raises -> None:
        var json_mod = Python.import_module("json")
        var state_obj = json_mod.loads(PythonObject(state))
        self._static_unit_net_value = Float64(py=state_obj["static_unit_net_value"])
        self._units = Float64(py=state_obj["units"])
        var accounts_data = state_obj["accounts"]
        var keys_py = Python.list(accounts_data.keys())
        var n_keys = Int(py=len(keys_py))
        for i in range(n_keys):
            var k = String(py=keys_py[i])
            if k in self._accounts:
                self._accounts[k].set_state_py(accounts_data[k])

    def get_positions(self) -> List[Position]:
        var result = List[Position]()
        for entry in self._accounts.items():
            var acct_positions = entry.value.get_positions()
            for pos in acct_positions:
                result.append(pos)
        return result^

    def get_position(self, order_book_id: String, direction: POSITION_DIRECTION) -> Position:
        for entry in self._accounts.items():
            var pos = entry.value.get_position(order_book_id, direction)
            if pos.quantity > 0 or pos.old_quantity > 0:
                return pos
        return create_position(order_book_id, direction)

    @staticmethod
    def get_account_type(order_book_id: String) -> String:
        if order_book_id.find(".XSHE") >= 0 or order_book_id.find(".XSHG") >= 0:
            return DEFAULT_ACCOUNT_TYPE.STOCK.value
        elif order_book_id.find(".CFFEX") >= 0 or order_book_id.find(".CZCE") >= 0 or \
             order_book_id.find(".SHFE") >= 0 or order_book_id.find(".DCE") >= 0 or \
             order_book_id.find(".INE") >= 0:
            return DEFAULT_ACCOUNT_TYPE.FUTURE.value
        else:
            return DEFAULT_ACCOUNT_TYPE.STOCK.value

    def get_account(self, order_book_id: String) raises -> Account:
        var atype = Self.get_account_type(order_book_id)
        if atype in self._accounts:
            return self._accounts[atype]
        else:
            var first_key = ""
            for entry in self._accounts.items():
                first_key = entry.key
                break
            return self._accounts[first_key]

    def accounts(self) -> Dict[String, Account]:
        return self._accounts.copy()

    def stock_account(self) raises -> Optional[Account]:
        var key = DEFAULT_ACCOUNT_TYPE.STOCK.value
        if key in self._accounts:
            return Optional[Account](self._accounts[key])
        else:
            return None

    def future_account(self) raises -> Optional[Account]:
        var key = DEFAULT_ACCOUNT_TYPE.FUTURE.value
        if key in self._accounts:
            return Optional[Account](self._accounts[key])
        else:
            return None

    def start_date(self) -> DateTime:
        return self._start_date

    def units(self) -> Float64:
        return self._units

    def unit_net_value(self) -> Float64:
        if self._units == 0.0:
            return 0.0
        return self.total_value() / self._units

    def static_unit_net_value(self) -> Float64:
        return self._static_unit_net_value

    def daily_pnl(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.daily_pnl
        return total

    def daily_returns(self) -> Float64:
        if self._static_unit_net_value == 0.0:
            return 0.0
        return self.unit_net_value() / self._static_unit_net_value - 1.0

    def total_returns(self) -> Float64:
        return self.unit_net_value() - 1.0

    def annualized_returns(self) -> Float64:
        var unv = self.unit_net_value()
        if unv <= 0.0:
            return -1.0
        if unv == 1.0:
            return 0.0
        var tpy = self._trading_days_per_year
        var base = unv
        var exponent = tpy / 1.0
        var result = base ** exponent - 1.0
        return result

    def total_value(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.total_value
        return total

    def portfolio_value(self) -> Float64:
        return self.total_value()

    def positions(self) -> MixedPositions:
        return MixedPositions.create(self._accounts.copy())

    def cash(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.total_cash
        return total

    def transaction_cost(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.transaction_cost()
        return total

    def market_value(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.market_value()
        return total

    def pnl(self) -> Float64:
        return (self.unit_net_value() - 1.0) * self._units

    def starting_cash(self) -> Float64:
        return self._units

    def frozen_cash(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.frozen_cash
        return total

    def cash_liabilities(self) -> Float64:
        var total = 0.0
        for entry in self._accounts.items():
            total += entry.value.cash_liabilities
        return total

    def pre_before_trading(mut self) -> None:
        self._static_unit_net_value = self.unit_net_value()

    def deposit_withdraw(mut self, account_type: String, amount: Float64, receiving_days: Int = 0) raises -> None:
        var upper_type = account_type.upper()
        if upper_type not in self._accounts:
            raise Error("invalid account type " + upper_type + ", choose in available accounts")
        var unit_nv = self.unit_net_value()
        self._accounts[upper_type].deposit_withdraw(amount, receiving_days)
        var new_units = self.total_value() / unit_nv
        self._units = new_units

    def finance_repay(mut self, amount: Float64, account_type: String) raises -> None:
        if account_type not in self._accounts:
            raise Error("invalid account type " + account_type + ", choose in available accounts")
        self._accounts[account_type].finance_repay(amount)

    def apply_trade(mut self, trade: Trade) raises -> None:
        var atype = Self.get_account_type(trade.order_book_id)
        if atype in self._accounts:
            self._accounts[atype].apply_trade(trade)

    def update_last_price(mut self, order_book_id: String, price: Float64) -> None:
        for entry in self._accounts.items():
            var acct = entry.value
            acct.update_last_price(order_book_id, price)

    def update_portfolio(mut self) -> None:
        for entry in self._accounts.items():
            var acct = entry.value
            acct.update_positions_value()

    def settlement(mut self, trading_date: DateTimeDate) -> None:
        for entry in self._accounts.items():
            var acct = entry.value
            acct.settlement()
        self._static_unit_net_value = self.unit_net_value()

    def set_trading_dt(mut self, dt: DateTime) -> None:
        self._trading_dt = dt


def create_portfolio(
    starting_cash: Dict[String, Float64],
    start_date: DateTime,
    init_positions: List[PythonObject] = List[PythonObject](),
    financing_rate: Float64 = 0.0,
    trading_days_per_year: Float64 = 245.0,
) -> Portfolio:
    return Portfolio(
        starting_cash=starting_cash,
        init_positions=init_positions,
        financing_rate=financing_rate,
        start_date=start_date,
        trading_days_per_year=trading_days_per_year,
    )


def create_stock_portfolio(total_cash: Float64 = 100000.0) -> Portfolio:
    var sc = Dict[String, Float64]()
    sc[DEFAULT_ACCOUNT_TYPE.STOCK.value] = total_cash
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    return create_portfolio(sc, sd)


def create_future_portfolio(total_cash: Float64 = 100000.0) -> Portfolio:
    var fc = Dict[String, Float64]()
    fc[DEFAULT_ACCOUNT_TYPE.FUTURE.value] = total_cash
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    return create_portfolio(fc, sd)
