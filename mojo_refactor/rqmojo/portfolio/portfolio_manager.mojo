"""
RQAlpha Mojo - Portfolio Manager
Ported from rqalpha/portfolio/
"""

from std.collections import Dict, List
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, POSITION_DIRECTION
from rqmojo.model.trade import Trade
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position, PositionProxy, create_position_proxy
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct Portfolio(Movable):
    var account_type: DEFAULT_ACCOUNT_TYPE
    var total_value: Float64
    var cash: Float64
    var start_date_val: DateTime
    var static_unit_net_value: Float64
    var daily_return: Float64
    var units_val: Float64
    var _account: Account

    def __str__(self) -> String:
        return "Portfolio(total_value=" + String(self.total_value) + ", cash=" + String(self.cash) + ")"

    def get_account(self) -> Account:
        return self._account

    def stock_account(self) -> Account:
        return self._account

    def future_account(self) -> Account:
        return create_future_account(0.0)

    def get_position(mut self, order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG) -> Position:
        return self._account.get_position(order_book_id, direction)

    def get_positions(self) -> List[Position]:
        return self._account.get_positions()

    def get_trade_positions(self) -> List[PositionProxy]:
        var positions = self._account.get_positions()
        var result = List[PositionProxy]()
        for pos in positions:
            if pos.quantity > 0:
                result.append(create_position_proxy(pos))
        return result^

    def total_value_calc(mut self) -> Float64:
        self._account.update_positions_value()
        return self._account.total_value

    def cash_val(self) -> Float64:
        return self._account.total_cash

    def positions_value(self) -> Float64:
        var positions = self._account.get_positions()
        var total: Float64 = 0.0
        for pos in positions:
            total += pos.market_value
        return total

    def start_date(self) -> DateTime:
        return self.start_date_val

    def units(self) -> Float64:
        return self.units_val

    def static_unit_net_value_calc(self) -> Float64:
        return self.static_unit_net_value

    def daily_return_val(self) -> Float64:
        return self.daily_return

    def apply_trade(mut self, trade: Trade) -> None:
        self._account.apply_trade(trade)

    def update_last_price(mut self, order_book_id: String, price: Float64) -> None:
        self._account.update_last_price(order_book_id, price)

    def update_portfolio(mut self) -> None:
        self._account.update_positions_value()
        self.total_value = self._account.total_value

    def settlement(mut self, trading_date: DateTime) -> None:
        self._account.settlement()
        self.static_unit_net_value = self.total_value / self.units_val


def create_portfolio(
    start_date: DateTime,
    total_cash: Float64 = 100000.0,
    units: Float64 = 1.0
) -> Portfolio:
    var stock_account = create_stock_account(total_cash)
    
    return Portfolio(
        account_type=DEFAULT_ACCOUNT_TYPE.STOCK,
        total_value=total_cash,
        cash=total_cash,
        start_date_val=start_date,
        static_unit_net_value=1.0,
        daily_return=0.0,
        units_val=units,
        _account=stock_account^
    )


def create_stock_portfolio(total_cash: Float64 = 100000.0) -> Portfolio:
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    return create_portfolio(start_date, total_cash, 1.0)
