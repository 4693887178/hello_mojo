"""
RQAlpha Mojo - Base API
Ported from rqalpha/apis/api_base.py
"""

from std.collections import Optional, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder, OrderStyle
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.portfolio.position import Position
from rqmojo.portfolio_manager import Portfolio
from rqmojo.data.data_proxy import DataProxy, Snapshot
from rqmojo.utils.typing import DateTime
from rqmojo.core.events import EVENT


from rqmojo.const import POSITION_DIRECTION


def order_shares(ctx: StrategyContext, order_book_id: String, quantity: Int, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if quantity == 0:
        return None
    
    var side = SIDE.BUY
    var position_effect = POSITION_EFFECT.OPEN
    var abs_quantity = quantity
    
    if quantity < 0:
        side = SIDE.SELL
        abs_quantity = -quantity
        position_effect = POSITION_EFFECT.CLOSE
    
    var order_style: OrderStyle = MarketOrder()
    if style == ORDER_TYPE.LIMIT:
        order_style = LimitOrder(price)
    
    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=side,
        quantity=abs_quantity,
        style=order_style,
        position_effect=position_effect
    )


def order_value(ctx: StrategyContext, order_book_id: String, cash_amount: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if cash_amount == 0:
        return None
    
    var bar = ctx.get_bar(order_book_id)
    if bar.close() <= 0:
        return None
    
    var quantity = Int(cash_amount / bar.close() / 100.0) * 100
    if quantity == 0:
        return None
    
    if cash_amount < 0:
        quantity = -quantity
    
    return order_shares(ctx, order_book_id, quantity, style, price)


def order_percent(ctx: StrategyContext, order_book_id: String, percent: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if percent <= 0 or percent > 1:
        return None
    
    var portfolio = ctx.portfolio()
    var cash_amount = portfolio.total_value * percent
    
    return order_value(ctx, order_book_id, cash_amount, style, price)


def order_target_value(ctx: StrategyContext, order_book_id: String, target_value: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    var portfolio = ctx.portfolio()
    var position = portfolio.get_position(order_book_id, POSITION_DIRECTION.LONG)
    
    var current_value = position.market_value
    var delta_value = target_value - current_value
    
    return order_value(ctx, order_book_id, delta_value, style, price)


def order_target_percent(ctx: StrategyContext, order_book_id: String, target_percent: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    var portfolio = ctx.portfolio()
    var target_value = portfolio.total_value * target_percent
    
    return order_target_value(ctx, order_book_id, target_value, style, price)


def cancel_order(ctx: StrategyContext, order: Order) -> Bool:
    if not order.is_active():
        return False
    
    return True


def get_position(ctx: StrategyContext, order_book_id: String) -> Optional[Position]:
    var portfolio = ctx.portfolio()
    return portfolio.get_position(order_book_id, POSITION_DIRECTION.LONG)


def get_portfolio(ctx: StrategyContext) -> Portfolio:
    return ctx.portfolio()


def history(ctx: StrategyContext, order_book_id: String, bar_count: Int, frequency: String, fields: String = "close") -> List[Float64]:
    var result = List[Float64]()
    result.append(0.0)
    return result^


def get_price(ctx: StrategyContext, order_book_id: String, start_date: DateTime, end_date: DateTime, frequency: String = "1d") -> List[Float64]:
    var result = List[Float64]()
    result.append(0.0)
    return result^


def current_snapshot(ctx: StrategyContext, order_book_id: String) -> Optional[Snapshot]:
    return None


def get_trading_dates(ctx: StrategyContext, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
    var result = List[DateTime]()
    return result^


def get_previous_trading_date(ctx: StrategyContext, date: DateTime) -> DateTime:
    return date


def get_next_trading_date(ctx: StrategyContext, date: DateTime) -> DateTime:
    return date
