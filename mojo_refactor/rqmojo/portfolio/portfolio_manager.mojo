"""
RQAlpha Mojo - Portfolio Manager
Ported from rqalpha/portfolio/
"""

from collections import Dict, List
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, POSITION_DIRECTION, POSITION_DIRECTION_LONG, DEFAULT_ACCOUNT_TYPE_STOCK, POSITION_DIRECTION_LONG, DEFAULT_ACCOUNT_TYPE_STOCK
from rqmojo.model.trade import Trade
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position, PositionProxy, create_position_proxy
from rqmojo.utils.datetime_func import DateTime


struct Portfolio:
    var account_type: DEFAULT_ACCOUNT_TYPE
    var total_value: Float64
    var cash: Float64
    var start_date_val: DateTime
    var static_unit_net_value: Float64
    var daily_return: Float64
    var units_val: Float64
    var _account: Account

    fn __str__(self) -> String:
        return "Portfolio(total_value=" + String(self.total_value) + ", cash=" + String(self.cash) + ")"

    fn __init__(out self, account_type: DEFAULT_ACCOUNT_TYPE, total_value: Float64, cash: Float64,
                 start_date_val: DateTime, static_unit_net_value: Float64, daily_return: Float64,
                 units_val: Float64, var _account: Account):
        self.account_type = account_type
        self.total_value = total_value
        self.cash = cash
        self.start_date_val = start_date_val
        self.static_unit_net_value = static_unit_net_value
        self.daily_return = daily_return
        self.units_val = units_val
        self._account = _account^

    fn __copyinit__(out self, existing: Self):
        self.account_type = existing.account_type
        self.total_value = existing.total_value
        self.cash = existing.cash
        self.start_date_val = existing.start_date_val
        self.static_unit_net_value = existing.static_unit_net_value
        self.daily_return = existing.daily_return
        self.units_val = existing.units_val
        self._account = existing._account

    fn __moveinit__(out self, deinit existing: Self):
        self.account_type = existing.account_type
        self.total_value = existing.total_value
        self.cash = existing.cash
        self.start_date_val = existing.start_date_val
        self.static_unit_net_value = existing.static_unit_net_value
        self.daily_return = existing.daily_return
        self.units_val = existing.units_val
        self._account = existing._account^

    fn get_account(self) -> Account:
        return self._account

    fn stock_account(self) -> Account:
        return self._account

    fn future_account(self) -> Account:
        return create_future_account(0.0)

    fn get_position(mut self, order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION_LONG) -> Position:
        return self._account.get_position(order_book_id, direction)

    fn get_positions(self) -> List[Position]:
        return self._account.get_positions()

    fn get_trade_positions(self) -> List[PositionProxy]:
        var positions = self._account.get_positions()
        var result = List[PositionProxy]()
        for pos in positions:
            if pos.quantity > 0:
                result.append(create_position_proxy(pos))
        return result^

    fn total_value_calc(mut self) -> Float64:
        self._account.update_positions_value()
        return self._account.total_value

    fn cash_val(self) -> Float64:
        return self._account.total_cash

    fn positions_value(self) -> Float64:
        var positions = self._account.get_positions()
        var total: Float64 = 0.0
        for pos in positions:
            total += pos.market_value
        return total

    fn start_date(self) -> DateTime:
        return self.start_date_val

    fn units(self) -> Float64:
        return self.units_val

    fn static_unit_net_value_calc(self) -> Float64:
        return self.static_unit_net_value

    fn daily_return_val(self) -> Float64:
        return self.daily_return

    fn apply_trade(mut self, trade: Trade) -> None:
        self._account.apply_trade(trade)

    fn update_last_price(mut self, order_book_id: String, price: Float64) -> None:
        self._account.update_last_price(order_book_id, price)

    fn update_portfolio(mut self) -> None:
        self._account.update_positions_value()
        self.total_value = self._account.total_value

    fn settlement(mut self, trading_date: DateTime) -> None:
        self._account.settlement()
        self.static_unit_net_value = self.total_value / self.units_val


fn create_portfolio(
    start_date: DateTime,
    total_cash: Float64 = 100000.0,
    units: Float64 = 1.0
) -> Portfolio:
    var stock_account = create_stock_account(total_cash)
    
    return Portfolio(
        account_type=DEFAULT_ACCOUNT_TYPE_STOCK,
        total_value=total_cash,
        cash=total_cash,
        start_date_val=start_date,
        static_unit_net_value=1.0,
        daily_return=0.0,
        units_val=units,
        _account=stock_account^
    )


fn create_stock_portfolio(total_cash: Float64 = 100000.0) -> Portfolio:
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    return create_portfolio(start_date, total_cash, 1.0)
