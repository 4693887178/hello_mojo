"""
RQAlpha Mojo - Future API for Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/api_future.py
"""

from std.collections import Dict, List, Optional
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE,
    POSITION_DIRECTION, HEDGE_TYPE, RUN_TYPE
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.typing import DateTime
from rqmojo.utils.exception import RQInvalidArgument
from rqmojo.utils.i18n import gettext


@fieldwise_init
struct FutureAccountPositionResult(Movable, Copyable, ImplicitlyCopyable):
    var total_cash: Float64
    var long_quantity: Int
    var short_quantity: Int
    var long_closable: Int
    var short_closable: Int


def _get_future_account_position(env: Environment, order_book_id: String) -> FutureAccountPositionResult:
    return FutureAccountPositionResult(
        total_cash=env.get_portfolio_cash(),
        long_quantity=0,
        short_quantity=0,
        long_closable=0,
        short_closable=0
    )


def _submit_order(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    style: OrderStyle
) -> Optional[Order]:
    if amount == 0:
        return None
    
    var price = env.get_last_price_from_proxy(order_book_id)
    if price <= 0:
        return None
    
    var order = create_order_with_id(
        env.next_order_id(),
        order_book_id,
        side,
        amount,
        style,
        position_effect
    )
    
    return env.submit_order(order)


def buy_open(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> Optional[Order]:
    return _submit_order(env, order_book_id, quantity, SIDE.BUY, POSITION_EFFECT.OPEN, style)


def sell_close(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) -> Optional[Order]:
    var position_effect = POSITION_EFFECT.CLOSE
    return _submit_order(env, order_book_id, quantity, SIDE.SELL, position_effect, style)


def sell_open(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> Optional[Order]:
    return _submit_order(env, order_book_id, quantity, SIDE.SELL, POSITION_EFFECT.OPEN, style)


def buy_close(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) -> Optional[Order]:
    var position_effect = POSITION_EFFECT.CLOSE
    return _submit_order(env, order_book_id, quantity, SIDE.BUY, position_effect, style)


def future_order(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> List[Order]:
    var orders = List[Order]()
    
    if quantity == 0:
        return orders^
    
    var result: Optional[Order]
    
    if quantity > 0:
        result = buy_open(env, id_or_ins, quantity, style)
    else:
        result = sell_close(env, id_or_ins, -quantity, style)
    
    if result != None:
        orders.append(result.value())
    
    return orders^


def future_order_to(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> List[Order]:
    var orders = List[Order]()
    
    var result = _get_future_account_position(env, id_or_ins)
    var long_qty = result.long_quantity
    var short_qty = result.short_quantity
    var remaining_qty = quantity
    
    if remaining_qty > 0:
        if short_qty > 0:
            var close_qty = min(short_qty, remaining_qty)
            var close_order = buy_close(env, id_or_ins, close_qty, style)
            if close_order != None:
                orders.append(close_order.value())
            remaining_qty = remaining_qty - close_qty
        
        if remaining_qty > 0:
            var open_order = buy_open(env, id_or_ins, remaining_qty, style)
            if open_order != None:
                orders.append(open_order.value())
    elif remaining_qty < 0:
        remaining_qty = -remaining_qty
        
        if long_qty > 0:
            var close_qty = min(long_qty, remaining_qty)
            var close_order = sell_close(env, id_or_ins, close_qty, style)
            if close_order != None:
                orders.append(close_order.value())
            remaining_qty = remaining_qty - close_qty
        
        if remaining_qty > 0:
            var open_order = sell_open(env, id_or_ins, remaining_qty, style)
            if open_order != None:
                orders.append(open_order.value())
    
    return orders^


def get_future_position(
    env: Environment,
    order_book_id: String,
    direction: POSITION_DIRECTION = POSITION_DIRECTION_LONG
) -> Position:
    return env.portfolio.get_position(order_book_id)


def get_future_positions(env: Environment) -> List[Position]:
    return env.portfolio.get_positions()


@fieldwise_init
struct TargetPortfolioItem(Movable, Copyable, ImplicitlyCopyable):
    var order_book_id: String
    var target_percent: Float64
    var open_style: OrderStyle
    var close_style: OrderStyle
    var last_price: Float64


def _round_order_quantity_for_portfolio(env: Environment, order_book_id: String, quantity: Int) -> Int:
    var ins = env.get_instrument(order_book_id)
    var round_lot = 1
    if quantity % round_lot != 0:
        return quantity / round_lot * round_lot
    return quantity


def order_target_portfolio_future(
    mut env: Environment,
    target_portfolio: Dict[String, Float64],
    open_styles: Dict[String, OrderStyle] = Dict[String, OrderStyle](),
    close_styles: Dict[String, OrderStyle] = Dict[String, OrderStyle]()
) -> List[Order]:
    var target = List[TargetPortfolioItem]()
    
    for order_book_id in target_portfolio.keys():
        try:
            var percent = target_portfolio[order_book_id]
            if percent < 0:
                continue
            
            var last_price = env.get_last_price_from_proxy(order_book_id)
            if last_price <= 0:
                continue
            
            var open_style = MarketOrder()
            var close_style = MarketOrder()
            
            try:
                open_style = open_styles[order_book_id]
            except:
                pass
            
            try:
                close_style = close_styles[order_book_id]
            except:
                pass
            
            target.append(TargetPortfolioItem(
                order_book_id=order_book_id,
                target_percent=percent,
                open_style=open_style,
                close_style=close_style,
                last_price=last_price
            ))
        except:
            pass
    
    var total_percent: Float64 = 0.0
    for item in target:
        total_percent += item.target_percent
    
    if total_percent > 1.0:
        return List[Order]()
    
    var account_value = env.get_portfolio_total_value()
    var current_quantities = Dict[String, Int]()
    
    var orders = List[Order]()
    
    for item in target:
        var current_qty = 0
        try:
            current_qty = current_quantities[item.order_book_id]
        except:
            pass
        
        var close_price = item.last_price
        var open_price = item.last_price
        
        if item.close_style.style_type == ORDER_TYPE.LIMIT:
            close_price = item.close_style.limit_price
        if item.open_style.style_type == ORDER_TYPE.LIMIT:
            open_price = item.open_style.limit_price
        
        if close_price <= 0 or open_price <= 0:
            continue
        
        var delta_quantity = Int(account_value * item.target_percent / close_price) - current_qty
        delta_quantity = _round_order_quantity_for_portfolio(env, item.order_book_id, delta_quantity)
        
        if delta_quantity == 0:
            continue
        elif delta_quantity > 0:
            var order = create_order_with_id(
                env.next_order_id(),
                item.order_book_id,
                SIDE.BUY,
                delta_quantity,
                item.open_style,
                POSITION_EFFECT.OPEN
            )
            var result = env.submit_order(order)
            if result != None:
                orders.append(result.value())
        else:
            var order = create_order_with_id(
                env.next_order_id(),
                item.order_book_id,
                SIDE.SELL,
                -delta_quantity,
                item.close_style,
                POSITION_EFFECT.CLOSE
            )
            var result = env.submit_order(order)
            if result != None:
                orders.append(result.value())
    
    return orders^


def get_future_contracts(
    env: Environment,
    underlying_symbol: String
) -> List[String]:
    var instruments = env.get_all_instruments_from_proxy("Future")
    var result = List[String]()
    for ins in instruments:
        result.append(ins.order_book_id())
    return result^


def get_dominant_contract(
    env: Environment,
    underlying_symbol: String
) -> Optional[String]:
    var contracts = get_future_contracts(env, underlying_symbol)
    if len(contracts) > 0:
        return contracts[0]
    return None
