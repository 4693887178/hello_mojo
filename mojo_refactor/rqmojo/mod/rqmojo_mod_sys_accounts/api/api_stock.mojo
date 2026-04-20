"""
RQAlpha Mojo - Stock API for Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/api_stock.py

Key differences from Python original:
  - Environment passed explicitly (no singleton get_instance)
  - Uses Float64 arithmetic instead of Decimal (Mojo has no Decimal type)
  - Optional types used instead of None returns
"""

from std.collections import Dict, List, Set
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION, EXECUTION_PHASE
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, AlgoOrderStyle, create_order_with_id, create_algo_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment, TransactionCostArgs
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy, DividendInfo
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct AccountPositionResult(Copyable, Movable, ImplicitlyCopyable):
    var total_cash: Float64
    var total_value: Float64
    var position_quantity: Int
    var position_market_value: Float64
    var position_closable: Int


@fieldwise_init
struct ExchangeRateResult(Copyable, Movable, ImplicitlyCopyable):
    var bid_reference: Float64
    var ask_reference: Float64


@fieldwise_init
struct TargetPortfolioData(Copyable, Movable, ImplicitlyCopyable):
    var order_book_id: String
    var open_style: OrderStyle
    var close_style: OrderStyle
    var last_price: Float64
    var instrument: Instrument


@fieldwise_init
struct WaitingToBuyData(Copyable, Movable, ImplicitlyCopyable):
    var delta_quantity: Int
    var position_effect: POSITION_EFFECT
    var style: OrderStyle
    var last_price: Float64


comptime KSH_MIN_AMOUNT: Int = 200
comptime BJSE_MIN_AMOUNT: Int = 100


def _get_account_position(env: Environment, order_book_id: String) raises -> AccountPositionResult:
    var position = env.portfolio.get_stock_position(order_book_id)
    var account = env.get_stock_account()
    return AccountPositionResult(
        total_cash=account.total_cash,
        total_value=env.get_portfolio_total_value(),
        position_quantity=position.quantity,
        position_market_value=position.market_value,
        position_closable=position.closable()
    )


def _is_nan(value: Float64) -> Bool:
    return value != value


def _round_order_quantity(ins: Instrument, quantity: Int, round_method: String = "floor") -> Int:
    var ins_type = ins.type()
    var board_type = ins.board_type()
    if ins_type == INSTRUMENT_TYPE.CS and board_type == "KSH":
        if abs(quantity) < KSH_MIN_AMOUNT:
            return 0
        return quantity
    elif ins_type == INSTRUMENT_TYPE.CS and board_type == "BJS":
        if abs(quantity) < BJSE_MIN_AMOUNT:
            return 0
        return quantity
    else:
        var round_lot = ins.round_lot()
        if round_lot <= 0:
            round_lot = 100
        var abs_qty = abs(quantity)
        var lots: Int
        if round_method == "ceil":
            lots = (abs_qty + round_lot - 1) / round_lot
        elif round_method == "round":
            lots = (abs_qty + round_lot / 2) / round_lot
        else:
            lots = abs_qty / round_lot
        return lots * round_lot * (1 if quantity >= 0 else -1)


def _get_order_style_price(env: Environment, order_book_id: String, style: OrderStyle) -> Float64:
    if style.style_type == ORDER_TYPE.LIMIT:
        return style.limit_price
    if style.style_type == ORDER_TYPE.ALGO:
        return env.get_last_price_from_proxy(order_book_id)
    return env.get_last_price_from_proxy(order_book_id)


def _is_valid_price(price: Float64) -> Bool:
    if _is_nan(price):
        return False
    if price <= 0:
        return False
    return True


def _estimate_transaction_cost(env: Environment, ins: Instrument, delta_quantity: Int, price: Float64) -> Float64:
    var side: SIDE
    var pe: POSITION_EFFECT
    if delta_quantity > 0:
        side = SIDE.BUY
        pe = POSITION_EFFECT.OPEN
    else:
        side = SIDE.SELL
        pe = POSITION_EFFECT.CLOSE
    var order = create_order_with_id(
        0,
        ins.order_book_id(),
        side,
        abs(delta_quantity),
        MarketOrder(),
        pe
    )
    var args = TransactionCostArgs(order=order.copy(), instrument=ins, quantity=abs(delta_quantity), price=price)
    return env.calc_transaction_cost(args)


def _get_exchange_rate(env: Environment, dt: DateTime, market_str: String) -> ExchangeRateResult:
    return ExchangeRateResult(bid_reference=1.0, ask_reference=1.0)


def _submit_order(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    style: OrderStyle,
    current_quantity: Int,
    auto_switch_order_value: Bool = True,
    zero_amount_as_exception: Bool = True
) raises -> Optional[Order]:
    if style.style_type == ORDER_TYPE.LIMIT:
        if _is_nan(style.limit_price):
            return None
    
    var price = env.get_last_price_from_proxy(order_book_id)
    if not _is_valid_price(price):
        env.order_creation_failed(order_book_id, "No market data")
        return None
    
    var ins = env.get_instrument(order_book_id)
    
    var final_amount = amount
    if (side == SIDE.BUY and current_quantity != -amount) or (side == SIDE.SELL and current_quantity != abs(amount)):
        final_amount = _round_order_quantity(ins, amount)
    
    if final_amount == 0:
        if zero_amount_as_exception:
            env.order_creation_failed(order_book_id, "0 order quantity")
        return None
    
    var order = create_order_with_id(
        env.next_order_id(),
        ins.order_book_id(),
        side,
        abs(final_amount),
        style,
        position_effect
    )
    
    if side == SIDE.BUY and auto_switch_order_value:
        var account_result = _get_account_position(env, order_book_id)
        var order_cost = Float64(abs(final_amount)) * price
        if order_cost > account_result.total_cash:
            return _order_value(env, account_result, order_book_id, account_result.total_cash, style, zero_amount_as_exception)
    
    return env.submit_order(order)


def _order_shares(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    style: OrderStyle,
    quantity: Int,
    auto_switch_order_value: Bool = True,
    zero_amount_as_exception: Bool = True
) raises -> Optional[Order]:
    var side: SIDE
    var position_effect: POSITION_EFFECT
    
    if amount > 0:
        side = SIDE.BUY
        position_effect = POSITION_EFFECT.OPEN
    else:
        side = SIDE.SELL
        position_effect = POSITION_EFFECT.CLOSE
    
    return _submit_order(
        env, order_book_id, amount, side, position_effect, style, quantity, 
        auto_switch_order_value, zero_amount_as_exception
    )


def _order_value(
    mut env: Environment,
    account_result: AccountPositionResult,
    order_book_id: String,
    cash_amount: Float64,
    style: OrderStyle,
    zero_amount_as_exception: Bool = True
) raises -> Optional[Order]:
    var actual_cash = cash_amount
    if cash_amount > 0:
        actual_cash = min(cash_amount, account_result.total_cash)
    
    var price: Float64
    if style.style_type == ORDER_TYPE.LIMIT:
        price = style.limit_price
    else:
        price = env.get_last_price_from_proxy(order_book_id)
    
    if not _is_valid_price(price):
        env.order_creation_failed(order_book_id, "No market data")
        return None
    
    var ins = env.get_instrument(order_book_id)
    var exchange_rates = _get_exchange_rate(env, env.trading_dt(), ins.market().value)
    var exchange_rate_middle = (exchange_rates.bid_reference + exchange_rates.ask_reference) / 2.0
    
    var amount = Int(actual_cash / (price * exchange_rate_middle))
    
    if cash_amount > 0:
        var max_amount = Int(account_result.total_cash / (price * exchange_rates.ask_reference))
        if amount > max_amount:
            amount = max_amount
    
    var round_lot = ins.round_lot()
    if round_lot <= 0:
        round_lot = 100
    
    amount = _round_order_quantity(ins, amount)
    
    if cash_amount > 0:
        if amount <= 0:
            if zero_amount_as_exception:
                env.order_creation_failed(order_book_id, "0 order quantity")
            return None
        
        while amount > 0:
            var expected_cost = _estimate_transaction_cost(env, ins, amount, price)
            var total_cost = Float64(amount) * price * exchange_rates.ask_reference + expected_cost
            if total_cost <= cash_amount:
                break
            amount -= round_lot
        if amount <= 0:
            if zero_amount_as_exception:
                env.order_creation_failed(order_book_id, "0 order quantity after cost adjustment")
            return None
    
    if amount < 0:
        var closable = account_result.position_closable
        if abs(amount) > closable:
            amount = -closable
    
    return _order_shares(
        env, order_book_id, amount, style, account_result.position_quantity, 
        auto_switch_order_value=False, zero_amount_as_exception=zero_amount_as_exception
    )


def stock_order_shares(
    mut env: Environment,
    id_or_ins: String,
    amount: Int,
    style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    var result = _get_account_position(env, id_or_ins)
    return _order_shares(
        env, id_or_ins, amount, style, result.position_quantity, True
    )


def stock_order_lots(
    mut env: Environment,
    id_or_ins: String,
    lots: Int,
    style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    var ins = env.get_instrument(id_or_ins)
    var round_lot = ins.round_lot()
    if round_lot <= 0:
        round_lot = 100
    return stock_order_shares(env, id_or_ins, lots * round_lot, style)


def stock_order_value(
    mut env: Environment,
    id_or_ins: String,
    cash_amount: Float64,
    style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    var result = _get_account_position(env, id_or_ins)
    return _order_value(env, result, id_or_ins, cash_amount, style)


def stock_order_percent(
    mut env: Environment,
    id_or_ins: String,
    percent: Float64,
    style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    var result = _get_account_position(env, id_or_ins)
    var cash_amount = result.total_value * percent
    return _order_value(env, result, id_or_ins, cash_amount, style)


def stock_order_target_value(
    mut env: Environment,
    id_or_ins: String,
    cash_amount: Float64,
    open_style: OrderStyle = MarketOrder(),
    close_style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    var result = _get_account_position(env, id_or_ins)
    
    if cash_amount == 0:
        return _submit_order(
            env, id_or_ins, result.position_closable, SIDE.SELL, 
            POSITION_EFFECT.CLOSE, close_style, result.position_quantity, False
        )
    
    var delta = cash_amount - result.position_market_value
    var target_style = open_style if delta > 0 else close_style
    return _order_value(env, result, id_or_ins, delta, target_style, zero_amount_as_exception=False)


def stock_order_target_percent(
    mut env: Environment,
    id_or_ins: String,
    percent: Float64,
    open_style: OrderStyle = MarketOrder(),
    close_style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    var result = _get_account_position(env, id_or_ins)
    
    if percent == 0:
        return _submit_order(
            env, id_or_ins, result.position_closable, SIDE.SELL,
            POSITION_EFFECT.CLOSE, close_style, result.position_quantity, False
        )
    
    var delta = result.total_value * percent - result.position_market_value
    var target_style = open_style if delta > 0 else close_style
    return _order_value(env, result, id_or_ins, delta, target_style, zero_amount_as_exception=False)


def stock_order(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) raises -> List[Order]:
    var result = stock_order_shares(env, id_or_ins, quantity, style)
    var orders = List[Order]()
    if result is not None:
        orders.append(result.value().copy())
    return orders^


def stock_order_to(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    open_style: OrderStyle = MarketOrder(),
    close_style: OrderStyle = MarketOrder()
) raises -> List[Order]:
    var result = _get_account_position(env, id_or_ins)
    var delta = quantity - result.position_quantity
    var target_style = open_style if delta > 0 else close_style
    
    var order = stock_order_shares(env, id_or_ins, delta, target_style)
    var orders = List[Order]()
    if order is not None:
        orders.append(order.value().copy())
    return orders^


def order_target_portfolio(
    mut env: Environment,
    target_portfolio: Dict[String, Float64],
    price_or_styles: Dict[String, OrderStyle] = Dict[String, OrderStyle]()
) raises -> List[Order]:
    var orders = List[Order]()
    var target_data: Dict[String, TargetPortfolioData] = Dict[String, TargetPortfolioData]()
    
    for entry in target_portfolio.items():
        var id_or_ins = entry.key
        var percent = entry.value
        
        var ins = env.get_instrument(id_or_ins)
        
        if percent < 0:
            raise Error("Invalid target_portfolio value: " + String(percent) + " for " + id_or_ins)
        
        var order_book_id = ins.order_book_id()
        var last_price = env.get_last_price_from_proxy(order_book_id)
        if not _is_valid_price(last_price):
            env.order_creation_failed(order_book_id, "No market data")
            continue
        
        var open_style = MarketOrder()
        var close_style = MarketOrder()
        if order_book_id in price_or_styles:
            open_style = price_or_styles[order_book_id]
            close_style = price_or_styles[order_book_id]
        
        target_data[order_book_id] = TargetPortfolioData(
            order_book_id=order_book_id,
            open_style=open_style,
            close_style=close_style,
            last_price=last_price,
            instrument=ins
        )
    
    var total_percent: Float64 = 0.0
    for entry in target_data.items():
        var key = entry.key
        var p = target_portfolio.get(key, 0.0)
        total_percent += p
    
    var account = env.get_stock_account()
    var current_quantities = Dict[String, Int]()
    var positions = account.get_positions()
    for pos in positions:
        if pos.quantity > 0 and pos.direction == POSITION_DIRECTION.LONG:
            current_quantities[pos.order_book_id] = pos.quantity
    
    for entry in current_quantities.items():
        var obid = entry.key
        var qty = entry.value
        if obid not in target_data:
            var sell_order = create_order_with_id(
                env.next_order_id(),
                obid,
                SIDE.SELL,
                qty,
                MarketOrder(),
                POSITION_EFFECT.CLOSE
            )
            var submitted = env.submit_order(sell_order)
            if submitted is not None:
                orders.append(submitted.value().copy())
    
    var account_value = env.get_portfolio_total_value()
    
    var close_orders = List[Order]()
    var waiting_to_buy = Dict[String, WaitingToBuyData]()
    
    for entry in target_data.items():
        var order_book_id = entry.key
        var data = entry.value
        var target_percent = target_portfolio.get(order_book_id, 0.0)
        var open_style_val = data.open_style
        var close_style_val = data.close_style
        var last_price = data.last_price
        var ins = data.instrument
        
        var open_p = _get_order_style_price(env, order_book_id, open_style_val)
        var close_p = _get_order_style_price(env, order_book_id, close_style_val)
        
        if not (_is_valid_price(close_p) and _is_valid_price(open_p)):
            env.order_creation_failed(order_book_id, "Invalid close/open price")
            continue
        
        var current_qty = 0
        if order_book_id in current_quantities:
            current_qty = current_quantities[order_book_id]
        
        var raw_delta = (account_value * target_percent / close_p) - Float64(current_qty)
        var delta_quantity = _round_order_quantity(ins, Int(raw_delta), "round")
        
        if delta_quantity == 0:
            continue
        elif delta_quantity > 0:
            waiting_to_buy[order_book_id] = WaitingToBuyData(
                delta_quantity=delta_quantity,
                position_effect=POSITION_EFFECT.OPEN,
                style=open_style_val,
                last_price=last_price
            )
        else:
            var sell_qty = abs(delta_quantity)
            var order = create_order_with_id(
                env.next_order_id(),
                order_book_id,
                SIDE.SELL,
                sell_qty,
                close_style_val,
                POSITION_EFFECT.CLOSE
            )
            if close_style_val.style_type == ORDER_TYPE.MARKET:
                order.set_frozen_price(last_price)
            close_orders.append(order^)
    
    var estimate_cash = account.total_cash
    for i in range(len(close_orders)):
        var o = close_orders[i].copy()
        estimate_cash += Float64(o.quantity) * o.frozen_price - o.estimated_transaction_cost()
    
    for entry in waiting_to_buy.items():
        var order_book_id = entry.key
        var data = entry.value
        var delta_quantity = data.delta_quantity
        var position_effect = data.position_effect
        var open_style_val = data.style
        var last_price = data.last_price
        
        var ins = env.get_instrument(order_book_id)
        var cost = Float64(delta_quantity) * last_price + _estimate_transaction_cost(env, ins, delta_quantity, last_price)
        
        if cost > estimate_cash:
            delta_quantity = Int(estimate_cash / last_price)
            delta_quantity = _round_order_quantity(ins, delta_quantity)
            if delta_quantity == 0:
                continue
            cost = Float64(delta_quantity) * last_price + _estimate_transaction_cost(env, ins, delta_quantity, last_price)
        
        var order = create_order_with_id(
            env.next_order_id(),
            order_book_id,
            SIDE.BUY,
            delta_quantity,
            open_style_val,
            position_effect
        )
        if open_style_val.style_type == ORDER_TYPE.MARKET:
            order.set_frozen_price(last_price)
        
        var submitted = env.submit_order(order)
        if submitted is not None:
            orders.append(submitted.value().copy())
        estimate_cash -= cost
    
    for i in range(len(close_orders)):
        var o = close_orders[i].copy()
        var submitted = env.submit_order(o)
        if submitted is not None:
            orders.append(submitted.value().copy())
    
    return orders^


def is_suspended(env: Environment, order_book_id: String, count: Int = 1) raises -> Bool:
    var dt = env.calendar_dt()
    return env.is_suspended_from_proxy(order_book_id, dt)


def is_st_stock(env: Environment, order_book_id: String, count: Int = 1) raises -> Bool:
    var ins = env.get_instrument(order_book_id)
    var special_type = ins.special_type()
    return special_type == "ST" or special_type == "*ST"


def industry(env: Environment, code: String) raises -> List[String]:
    var instruments = env.get_all_instruments_from_proxy("CS")
    var result = List[String]()
    for ins in instruments:
        if ins.industry_code() == code:
            result.append(ins.order_book_id())
    return result^


def sector(env: Environment, code: String) raises -> List[String]:
    var instruments = env.get_all_instruments_from_proxy("CS")
    var result = List[String]()
    for ins in instruments:
        if ins.sector_code() == code:
            result.append(ins.order_book_id())
    return result^


def get_dividend(env: Environment, order_book_id: String, start_date: DateTime) raises -> Optional[DividendInfo]:
    var ins = env.get_instrument(order_book_id)
    var dividend_opt = env.get_dividend_from_proxy(ins)
    if dividend_opt is None:
        return Optional[DividendInfo](None)
    var dividend = dividend_opt.value()
    return Optional[DividendInfo](dividend)


def to_industry_code(s: String) -> String:
    return s


def to_sector_name(s: String) -> String:
    return s
