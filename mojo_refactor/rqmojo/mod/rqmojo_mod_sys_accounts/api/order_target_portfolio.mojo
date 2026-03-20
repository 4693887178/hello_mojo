"""
RQAlpha Mojo - Order Target Portfolio API
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/order_target_portfolio.py
"""

from collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION, SIDE_SELL, SIDE_BUY, POSITION_EFFECT_CLOSE, POSITION_EFFECT_OPEN, ORDER_TYPE_LIMIT, SIDE_SELL, SIDE_BUY, POSITION_EFFECT_CLOSE, POSITION_EFFECT_OPEN, ORDER_TYPE_LIMIT
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.datetime_func import DateTime


struct TargetPortfolioItem(Copyable, Movable):
    var order_book_id: String
    var target_percent: Float64
    var open_style: OrderStyle
    var close_style: OrderStyle
    var last_price: Float64


fn order_target_portfolio(
    mut env: Environment,
    target_portfolio: Dict[String, Float64],
    open_styles: Dict[String, OrderStyle] = Dict[String, OrderStyle](),
    close_styles: Dict[String, OrderStyle] = Dict[String, OrderStyle]()
) -> List[Order]:
    var target = List[TargetPortfolioItem]()
    
    for order_book_id, percent in target_portfolio.items():
        if percent < 0:
            continue
        
        var last_price = env.get_last_price_from_proxy(order_book_id)
        if last_price <= 0:
            continue
        
        var open_style = MarketOrder()
        var close_style = MarketOrder()
        
        if open_styles.contains(order_book_id):
            open_style = open_styles[order_book_id]
        if close_styles.contains(order_book_id):
            close_style = close_styles[order_book_id]
        
        target.append(TargetPortfolioItem(
            order_book_id=order_book_id,
            target_percent=percent,
            open_style=open_style,
            close_style=close_style,
            last_price=last_price
        ))
    
    var total_percent: Float64 = 0.0
    for item in target:
        total_percent += item.target_percent
    
    if total_percent > 1.0:
        var orders = List[Order]()
        return orders^
    
    var account_value = env._portfolio_total_value
    
    var current_quantities = Dict[String, Int]()
    
    for order_book_id, quantity in current_quantities.items():
        if not target_portfolio.contains(order_book_id):
            var close_order = create_order_with_id(
                0,
                order_book_id,
                quantity,
                SIDE_SELL,
                MarketOrder(),
                POSITION_EFFECT_CLOSE
            )
            env.submit_order(close_order)
    
    var orders = List[Order]()
    
    for item in target:
        var current_qty = current_quantities.get(item.order_book_id, 0)
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
                0,
                item.order_book_id,
                delta_quantity,
                SIDE_BUY,
                item.open_style,
                POSITION_EFFECT_OPEN
            )
            var result = env.submit_order(order)
            if result is not None:
                orders.append(result[])
        else:
            var quantity = abs(delta_quantity)
            var order = create_order_with_id(
                0,
                item.order_book_id,
                quantity,
                SIDE_SELL,
                item.close_style,
                POSITION_EFFECT_CLOSE
            )
            var result = env.submit_order(order)
            if result is not None:
                orders.append(result[])
    
    return orders^


fn _round_order_quantity_for_portfolio(env: Environment, order_book_id: String, quantity: Int) -> Int:
    var ins = env.get_instrument(order_book_id)
    var round_lot = ins.round_lot
    if round_lot <= 0:
        round_lot = 100
    var abs_qty = abs(quantity)
    var lots = (abs_qty + round_lot / 2) / round_lot
    return lots * round_lot * (1 if quantity >= 0 else -1)
