"""
RQAlpha Mojo - Abstract API
Ported from rqalpha/apis/api_abstract.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE
from rqmojo.model.order import Order
from rqmojo.core.strategy_context import StrategyContext


trait TradingAPI:
    fn order_shares(self, ctx: StrategyContext, order_book_id: String, quantity: Int, style: ORDER_TYPE, price: Float64) -> Optional[Order]
    fn order_value(self, ctx: StrategyContext, order_book_id: String, cash_amount: Float64, style: ORDER_TYPE, price: Float64) -> Optional[Order]
    fn order_percent(self, ctx: StrategyContext, order_book_id: String, percent: Float64, style: ORDER_TYPE, price: Float64) -> Optional[Order]
    fn order_target_value(self, ctx: StrategyContext, order_book_id: String, target_value: Float64, style: ORDER_TYPE, price: Float64) -> Optional[Order]
    fn order_target_percent(self, ctx: StrategyContext, order_book_id: String, target_percent: Float64, style: ORDER_TYPE, price: Float64) -> Optional[Order]
    fn cancel_order(self, ctx: StrategyContext, order: Order) -> None
    fn get_open_orders(self, ctx: StrategyContext, order_book_id: String) -> List[Order]


trait DataAPI:
    fn history_bars(self, ctx: StrategyContext, order_book_id: String, bar_count: Int, frequency: String, fields: String) -> List[Dict[String, Float64]]
    fn history_ticks(self, ctx: StrategyContext, order_book_id: String, count: Int) -> List[Dict[String, Float64]]
    fn current_snapshot(self, ctx: StrategyContext, order_book_id: String) -> Dict[String, Float64]
    fn get_instruments(self, ctx: StrategyContext, order_book_ids: List[String]) -> List[Dict[String, String]]
    fn get_trading_dates(self, ctx: StrategyContext, start_date: String, end_date: String) -> List[String]


trait PortfolioAPI:
    fn get_portfolio(self, ctx: StrategyContext) -> Dict[String, Float64]
    fn get_position(self, ctx: StrategyContext, order_book_id: String) -> Dict[String, Float64]
    fn get_account(self, ctx: StrategyContext, account_type: String) -> Dict[String, Float64]
