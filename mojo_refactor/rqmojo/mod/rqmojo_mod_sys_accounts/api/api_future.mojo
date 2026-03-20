"""
RQAlpha Mojo - Future API for Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/api_future.py
"""

from collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION, HEDGE_TYPE
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.datetime_func import DateTime


struct FutureAccountPositionResult(Copyable, Movable):
    var total_cash: Float64
    var long_quantity: Int
    var short_quantity: Int


fn _get_future_account_position(env: Environment, order_book_id: String) -> FutureAccountPositionResult:
    return FutureAccountPositionResult(
        total_cash=env._portfolio_cash,
        long_quantity=0,
        short_quantity=0
    )


fn buy_open(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> Optional[Order]:
    var price = env.get_last_price_from_proxy(order_book_id)
    
    if price <= 0:
        return None
    
    var order = create_order_with_id(
        0,
        order_book_id,
        quantity,
        SIDE.BUY,
        style,
        POSITION_EFFECT.OPEN
    )
    
    return env.submit_order(order)


fn sell_close(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) -> Optional[Order]:
    var price = env.get_last_price_from_proxy(order_book_id)
    
    if price <= 0:
        return None
    
    var position_effect = POSITION_EFFECT.CLOSE
    
    var order = create_order_with_id(
        0,
        order_book_id,
        quantity,
        SIDE.SELL,
        style,
        position_effect
    )
    
    return env.submit_order(order)


fn sell_open(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> Optional[Order]:
    var price = env.get_last_price_from_proxy(order_book_id)
    
    if price <= 0:
        return None
    
    var order = create_order_with_id(
        0,
        order_book_id,
        quantity,
        SIDE.SELL,
        style,
        POSITION_EFFECT.OPEN
    )
    
    return env.submit_order(order)


fn buy_close(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) -> Optional[Order]:
    var price = env.get_last_price_from_proxy(order_book_id)
    
    if price <= 0:
        return None
    
    var position_effect = POSITION_EFFECT.CLOSE
    
    var order = create_order_with_id(
        0,
        order_book_id,
        quantity,
        SIDE.BUY,
        style,
        position_effect
    )
    
    return env.submit_order(order)


fn future_order(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) -> List[Order]:
    var orders = List[Order]()
    
    if quantity == 0:
        return orders^
    
    var result: Optional[Order]
    
    if quantity > 0:
        result = buy_open(env, id_or_ins, quantity, style)
    else:
        result = sell_close(env, id_or_ins, -quantity, style, close_today)
    
    if result is not None:
        orders.append(result[])
    
    return orders^


fn future_order_to(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) -> List[Order]:
    var orders = List[Order]()
    
    var result = _get_future_account_position(env, id_or_ins)
    var long_qty = result.long_quantity
    var short_qty = result.short_quantity
    
    if quantity > 0:
        if short_qty > 0:
            var close_qty = min(short_qty, quantity)
            var close_order = buy_close(env, id_or_ins, close_qty, style, close_today)
            if close_order is not None:
                orders.append(close_order[])
            quantity -= close_qty
        
        if quantity > 0:
            var open_order = buy_open(env, id_or_ins, quantity, style)
            if open_order is not None:
                orders.append(open_order[])
    elif quantity < 0:
        quantity = -quantity
        
        if long_qty > 0:
            var close_qty = min(long_qty, quantity)
            var close_order = sell_close(env, id_or_ins, close_qty, style, close_today)
            if close_order is not None:
                orders.append(close_order[])
            quantity -= close_qty
        
        if quantity > 0:
            var open_order = sell_open(env, id_or_ins, quantity, style)
            if open_order is not None:
                orders.append(open_order[])
    
    return orders^


fn get_future_position(
    env: Environment,
    order_book_id: String,
    direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG
) -> Position:
    return env.portfolio.get_position(order_book_id)


fn get_future_positions(env: Environment) -> List[Position]:
    return env.portfolio.get_positions()
