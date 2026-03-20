"""
RQAlpha Mojo - Base API
Ported from rqalpha/apis/api_base.py
"""

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, ORDER_TYPE_MARKET, SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE, ORDER_TYPE_MARKET, SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE
from rqmojo.model.order import Order, create_order
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy, Snapshot
from rqmojo.utils.datetime_func import DateTime
from rqmojo.core.events import EVENT


fn order_shares(ctx: StrategyContext, order_book_id: String, quantity: Int, style: ORDER_TYPE = ORDER_TYPE_MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if quantity == 0:
        return None
    
    var side = SIDE_BUY
    var position_effect = POSITION_EFFECT_OPEN
    
    if quantity < 0:
        side = SIDE_SELL
        quantity = -quantity
        position_effect = POSITION_EFFECT_CLOSE
    
    return create_order(
        order_book_id=order_book_id,
        quantity=quantity,
        price=price,
        side=side,
        position_effect=position_effect,
        order_type=style
    )


fn order_value(ctx: StrategyContext, order_book_id: String, cash_amount: Float64, style: ORDER_TYPE = ORDER_TYPE_MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if cash_amount == 0:
        return None
    
    var bar = ctx.get_bar(order_book_id)
    if bar.close <= 0:
        return None
    
    var quantity = Int(cash_amount / bar.close / 100.0) * 100
    if quantity == 0:
        return None
    
    if cash_amount < 0:
        quantity = -quantity
    
    return order_shares(ctx, order_book_id, quantity, style, price)


fn order_percent(ctx: StrategyContext, order_book_id: String, percent: Float64, style: ORDER_TYPE = ORDER_TYPE_MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if percent <= 0 or percent > 1:
        return None
    
    var portfolio = ctx.portfolio()
    var cash_amount = portfolio.total_value * percent
    
    return order_value(ctx, order_book_id, cash_amount, style, price)


fn order_target_value(ctx: StrategyContext, order_book_id: String, target_value: Float64, style: ORDER_TYPE = ORDER_TYPE_MARKET, price: Float64 = 0.0) -> Optional[Order]:
    var portfolio = ctx.portfolio()
    var position = portfolio.get_position(order_book_id)
    
    var current_value = position.market_value
    var delta_value = target_value - current_value
    
    return order_value(ctx, order_book_id, delta_value, style, price)


fn order_target_percent(ctx: StrategyContext, order_book_id: String, target_percent: Float64, style: ORDER_TYPE = ORDER_TYPE_MARKET, price: Float64 = 0.0) -> Optional[Order]:
    var portfolio = ctx.portfolio()
    var target_value = portfolio.total_value * target_percent
    
    return order_target_value(ctx, order_book_id, target_value, style, price)


fn cancel_order(ctx: StrategyContext, order: Order) -> None:
    pass


fn get_open_orders(ctx: StrategyContext, order_book_id: String = "") -> List[Order]:
    return List[Order]()


fn update_universe(ctx: StrategyContext, order_book_ids: List[String]) -> None:
    ctx.update_universe(order_book_ids)


fn subscribe(ctx: StrategyContext, order_book_id: String) -> None:
    ctx.subscribe(order_book_id)


fn unsubscribe(ctx: StrategyContext, order_book_id: String) -> None:
    ctx.unsubscribe(order_book_id)


fn history_bars(ctx: StrategyContext, order_book_id: String, bar_count: Int, frequency: String, fields: String = "") -> List[BarObject]:
    return ctx._data_proxy.history_bars(order_book_id, bar_count, frequency, fields, ctx.current_dt())


fn current_snapshot(ctx: StrategyContext, order_book_id: String, frequency: String = "1d") -> Snapshot:
    return ctx._data_proxy.current_snapshot(ctx.get_instrument(order_book_id), frequency, ctx.current_dt())


fn get_position(ctx: StrategyContext, order_book_id: String) -> Position:
    return ctx.portfolio().get_position(order_book_id)


fn get_positions(ctx: StrategyContext) -> List[Position]:
    return ctx.portfolio().get_positions()


fn all_instruments(ctx: StrategyContext, type: String = "") -> List[Instrument]:
    return ctx._data_proxy.get_all_instruments(type)


fn instruments(ctx: StrategyContext, order_book_id: String) -> Instrument:
    return ctx.get_instrument(order_book_id)


fn subscribe_event(ctx: StrategyContext, event_type: EVENT, handler: String) -> None:
    ctx._env.get_event_bus().add_listener(event_type, handler, user=True)


fn get_trading_dates(ctx: StrategyContext, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
    return ctx._data_proxy.get_trading_dates(start_date, end_date)


fn get_previous_trading_date(ctx: StrategyContext, date: DateTime, n: Int = 1) -> DateTime:
    return ctx._data_proxy.get_previous_trading_date(date, n)


fn get_next_trading_date(ctx: StrategyContext, date: DateTime, n: Int = 1) -> DateTime:
    return ctx._data_proxy.get_next_trading_date(date, n)
