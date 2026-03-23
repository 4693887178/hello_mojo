"""
RQAlpha Mojo - Portfolio Management
Ported from rqalpha/portfolio/__init__.py
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE, SIDE
from rqmojo.model.trade import Trade
from rqmojo.portfolio.position import Position, create_position, PositionProxy, create_position_proxy
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct Portfolio(Copyable, Movable, ImplicitlyCopyable):
    var total_value: Float64
    var daily_pnl: Float64
    var total_pnl: Float64
    var annualized_returns: Float64
    var unit_net_value: Float64
    var cash: Float64
    var positions_count: Int
    var start_cash: Float64
    
    def __str__(self) -> String:
        return "Portfolio(value=" + String(self.total_value) + ", cash=" + String(self.cash) + ")"
    
    def returns(self) -> Float64:
        if self.start_cash == 0:
            return 0.0
        return (self.total_value - self.start_cash) / self.start_cash
    
    def update_total_value(mut self, accounts_value: Float64, positions_value: Float64) -> None:
        self.total_value = accounts_value + positions_value
    
    def cal_daily_pnl(mut self, prev_total_value: Float64) -> None:
        self.daily_pnl = self.total_value - prev_total_value


def create_portfolio(start_cash: Float64 = 100000.0) -> Portfolio:
    return Portfolio(
        total_value=start_cash,
        daily_pnl=0.0,
        total_pnl=0.0,
        annualized_returns=0.0,
        unit_net_value=1.0,
        cash=start_cash,
        positions_count=0,
        start_cash=start_cash
    )


@fieldwise_init
struct PortfolioProxy(Copyable, Movable, ImplicitlyCopyable):
    var total_value: Float64
    var cash: Float64
    var daily_pnl: Float64
    var returns: Float64
    var positions_count: Int
    
    def __str__(self) -> String:
        return "PortfolioProxy(value=" + String(self.total_value) + ")"


def create_portfolio_proxy(portfolio: Portfolio) -> PortfolioProxy:
    return PortfolioProxy(
        total_value=portfolio.total_value,
        cash=portfolio.cash,
        daily_pnl=portfolio.daily_pnl,
        returns=portfolio.returns(),
        positions_count=portfolio.positions_count
    )
