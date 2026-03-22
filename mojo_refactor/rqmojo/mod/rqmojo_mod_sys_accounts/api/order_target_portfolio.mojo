"""
RQAlpha Mojo - Order Target Portfolio API
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/order_target_portfolio.py
"""

from collections import Dict, List, Optional
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_TYPE_LIMIT
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.datetime_func import DateTime
from rqmojo.utils.exception import RQInvalidArgument
from rqmojo.utils.i18n import gettext


@fieldwise_init
struct TargetPortfolioItem(Movable, Copyable, ImplicitlyCopyable):
    var order_book_id: String
    var target_percent: Float64
    var open_style: OrderStyle
    var close_style: OrderStyle
    var last_price: Float64


fn _round_order_quantity_for_portfolio(env: Environment, order_book_id: String, quantity: Int) -> Int:
    var ins = env.get_instrument(order_book_id)
    var round_lot = 1
    if quantity % round_lot != 0:
        return quantity / round_lot * round_lot
    return quantity


def order_target_portfolio(
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
        
        if item.close_style.style_type == ORDER_TYPE_LIMIT:
            close_price = item.close_style.limit_price
        if item.open_style.style_type == ORDER_TYPE_LIMIT:
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
                delta_quantity,
                SIDE_BUY,
                item.open_style,
                POSITION_EFFECT_OPEN
            )
            var result = env.submit_order(order)
            if result != None:
                orders.append(result.value())
        else:
            var order = create_order_with_id(
                env.next_order_id(),
                item.order_book_id,
                -delta_quantity,
                SIDE_SELL,
                item.close_style,
                POSITION_EFFECT_CLOSE
            )
            var result = env.submit_order(order)
            if result != None:
                orders.append(result.value())
    
    return orders^


def order_target_portfolio_with_config(
    mut env: Environment,
    target_portfolio: Dict[String, Float64],
    config: Dict[String, String]
) -> List[Order]:
    var open_styles = Dict[String, OrderStyle]()
    var close_styles = Dict[String, OrderStyle]()
    
    return order_target_portfolio(env, target_portfolio, open_styles, close_styles)
