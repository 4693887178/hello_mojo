"""
RQAlpha Mojo - Stock API for Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/api_stock.py
"""

from collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION, INSTRUMENT_TYPE_CS, ORDER_TYPE_LIMIT, SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct AccountPositionResult(Copyable, Movable, ImplicitlyCopyable):
    var total_cash: Float64
    var total_value: Float64
    var position_quantity: Int
    var position_market_value: Float64
    var position_closable: Int


fn KSH_MIN_AMOUNT() -> Int:
    return 200


fn BJSE_MIN_AMOUNT() -> Int:
    return 100


fn _get_account_position(env: Environment, order_book_id: String) -> AccountPositionResult raises:
    var position = env.portfolio.get_stock_position(order_book_id)
    return AccountPositionResult(
        total_cash=env._portfolio_cash,
        total_value=env._portfolio_total_value,
        position_quantity=position.quantity,
        position_market_value=position.market_value,
        position_closable=position.closable()
    )


fn _round_order_quantity(ins: Instrument, quantity: Int, round_method: String = "floor") -> Int:
    var ins_type = ins.type()
    var board_type = ins.board_type()
    if ins_type == INSTRUMENT_TYPE_CS and board_type == "KSH":
        if abs(quantity) < KSH_MIN_AMOUNT():
            return 0
        return quantity
    elif ins_type == INSTRUMENT_TYPE_CS and board_type == "BJS":
        if abs(quantity) < BJSE_MIN_AMOUNT():
            return 0
        return quantity
    else:
        var round_lot = ins.round_lot()
        if round_lot <= 0:
            round_lot = 100
        var abs_qty = abs(quantity)
        var lots = abs_qty / round_lot
        if round_method == "ceil":
            lots = (abs_qty + round_lot - 1) / round_lot
        elif round_method == "round":
            lots = (abs_qty + round_lot / 2) / round_lot
        return lots * round_lot * (1 if quantity >= 0 else -1)


fn _get_order_style_price(env: Environment, order_book_id: String, style: OrderStyle) -> Float64:
    if style.style_type == ORDER_TYPE_LIMIT:
        return style.limit_price
    return env.get_last_price_from_proxy(order_book_id)


fn _estimate_transaction_cost(env: Environment, ins: Instrument, delta_quantity: Int, price: Float64) -> Float64:
    return 0.0


fn _submit_order(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    style: OrderStyle,
    current_quantity: Int,
    auto_switch_order_value: Bool = True,
    zero_amount_as_exception: Bool = True
) -> Optional[Order] raises:
    if style.style_type == ORDER_TYPE_LIMIT:
        if style.limit_price != style.limit_price:
            return None
    
    var price = env.get_last_price_from_proxy(order_book_id)
    if price <= 0:
        return None
    
    var ins = env.get_instrument(order_book_id)
    
    if (side == SIDE_BUY and current_quantity != -amount) or (side == SIDE_SELL and current_quantity != abs(amount)):
        amount = _round_order_quantity(ins, amount)
    
    if amount == 0:
        return None
    
    var order = create_order_with_id(
        0,
        ins.order_book_id(),
        abs(amount),
        side,
        style,
        position_effect
    )
    
    return env.submit_order(order)


fn _order_shares(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    style: OrderStyle,
    quantity: Int,
    auto_switch_order_value: Bool = True,
    zero_amount_as_exception: Bool = True
) -> Optional[Order] raises:
    var side: SIDE
    var position_effect: POSITION_EFFECT
    
    if amount > 0:
        side = SIDE_BUY
        position_effect = POSITION_EFFECT_OPEN
    else:
        side = SIDE_SELL
        position_effect = POSITION_EFFECT_CLOSE
    
    return _submit_order(
        env, order_book_id, amount, side, position_effect, style, quantity, 
        auto_switch_order_value, zero_amount_as_exception
    )


fn _order_value(
    mut env: Environment,
    account_result: AccountPositionResult,
    order_book_id: String,
    cash_amount: Float64,
    style: OrderStyle,
    zero_amount_as_exception: Bool = True
) -> Optional[Order] raises:
    var actual_cash = cash_amount
    if cash_amount > 0:
        actual_cash = min(cash_amount, account_result.total_cash)
    
    var price: Float64
    if style.style_type == ORDER_TYPE_LIMIT:
        price = style.limit_price
    else:
        price = env.get_last_price_from_proxy(order_book_id)
    
    if price <= 0:
        return None
    
    var ins = env.get_instrument(order_book_id)
    var round_lot = ins.round_lot()
    if round_lot <= 0:
        round_lot = 100
    
    var amount = Int(actual_cash / price)
    amount = _round_order_quantity(ins, amount)
    
    if actual_cash > 0:
        if amount <= 0:
            return None
    
    if amount < 0:
        var closable = account_result.position_closable
        if abs(amount) > closable:
            amount = -closable
    
    return _order_shares(
        env, order_book_id, amount, style, account_result.position_quantity, 
        auto_switch_order_value=False, zero_amount_as_exception=zero_amount_as_exception
    )


fn stock_order_shares(
    mut env: Environment,
    id_or_ins: String,
    amount: Int,
    style: OrderStyle = MarketOrder()
) -> Optional[Order] raises:
    var result = _get_account_position(env, id_or_ins)
    return _order_shares(
        env, id_or_ins, amount, style, result.position_quantity, True
    )


fn stock_order_lots(
    mut env: Environment,
    id_or_ins: String,
    lots: Int,
    style: OrderStyle = MarketOrder()
) -> Optional[Order] raises:
    var ins = env.get_instrument(id_or_ins)
    var round_lot = ins.round_lot()
    if round_lot <= 0:
        round_lot = 100
    return stock_order_shares(env, id_or_ins, lots * round_lot, style)


fn stock_order_value(
    mut env: Environment,
    id_or_ins: String,
    cash_amount: Float64,
    style: OrderStyle = MarketOrder()
) -> Optional[Order] raises:
    var result = _get_account_position(env, id_or_ins)
    return _order_value(env, result, id_or_ins, cash_amount, style)


fn stock_order_percent(
    mut env: Environment,
    id_or_ins: String,
    percent: Float64,
    style: OrderStyle = MarketOrder()
) -> Optional[Order] raises:
    var result = _get_account_position(env, id_or_ins)
    var cash_amount = result.total_value * percent
    return _order_value(env, result, id_or_ins, cash_amount, style)


fn stock_order_target_value(
    mut env: Environment,
    id_or_ins: String,
    cash_amount: Float64,
    open_style: OrderStyle = MarketOrder(),
    close_style: OrderStyle = MarketOrder()
) -> Optional[Order] raises:
    var result = _get_account_position(env, id_or_ins)
    
    if cash_amount == 0:
        return _submit_order(
            env, id_or_ins, result.position_closable, SIDE_SELL, 
            POSITION_EFFECT_CLOSE, close_style, result.position_quantity, False
        )
    
    var delta = cash_amount - result.position_market_value
    var style = open_style if delta > 0 else close_style
    return _order_value(env, result, id_or_ins, delta, style, zero_amount_as_exception=False)


fn stock_order_target_percent(
    mut env: Environment,
    id_or_ins: String,
    percent: Float64,
    open_style: OrderStyle = MarketOrder(),
    close_style: OrderStyle = MarketOrder()
) -> Optional[Order] raises:
    var result = _get_account_position(env, id_or_ins)
    
    if percent == 0:
        return _submit_order(
            env, id_or_ins, result.position_closable, SIDE_SELL,
            POSITION_EFFECT_CLOSE, close_style, result.position_quantity, False
        )
    
    var delta = result.total_value * percent - result.position_market_value
    var style = open_style if delta > 0 else close_style
    return _order_value(env, result, id_or_ins, delta, style, zero_amount_as_exception=False)


fn stock_order(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) -> List[Order] raises:
    var result = stock_order_shares(env, id_or_ins, quantity, style)
    var orders = List[Order]()
    if result is not None:
        orders.append(result[])
    return orders^


fn stock_order_to(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    open_style: OrderStyle = MarketOrder(),
    close_style: OrderStyle = MarketOrder()
) -> List[Order] raises:
    var result = _get_account_position(env, id_or_ins)
    var delta = quantity - result.position_quantity
    var style = open_style if delta > 0 else close_style
    
    var order = stock_order_shares(env, id_or_ins, delta, style)
    var orders = List[Order]()
    if order is not None:
        orders.append(order[])
    return orders^
