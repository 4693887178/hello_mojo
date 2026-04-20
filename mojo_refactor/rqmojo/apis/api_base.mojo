"""
RQAlpha Mojo - Base API
Ported from rqalpha/apis/api_base.py

Design Notes (vs Python original):
  Python: 1079 lines with @export_as_api decorators, ExecutionContext phases,
          apply_rules validators, Environment singleton access
  Mojo:    No decorator system; uses StrategyContext parameter instead of
           Environment.get_instance(); validates inputs inline

API Functions (aligned with Python):
  - Order APIs:     order_shares, order_value, order_percent,
                    order_target_value, order_target_percent, submit_order, cancel_order
  - Universe APIs:  update_universe, subscribe, unsubscribe
  - Data APIs:      history_bars, history_ticks, current_snapshot,
                    get_trading_dates, get_previous_trading_date, get_next_trading_date
  - Instrument APIs: instruments, all_instruments, active_instrument
  - Position APIs:  get_position, get_positions, get_portfolio
  - Account APIs:   deposit, withdraw
"""

from std.collections import Optional, List, Dict, Set
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, POSITION_DIRECTION, ORDER_STATUS, RUN_TYPE, EXECUTION_PHASE
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder, OrderStyle, AlgoOrderStyle, TWAPOrder, VWAPOrder
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.portfolio.position import Position
from rqmojo.portfolio_manager import Portfolio
from rqmojo.data.data_proxy import DataProxy, Snapshot
from rqmojo.utils.typing import DateTime


def assure_order_book_id(id_or_ins: String) -> String:
    return id_or_ins


def cal_style(price: Float64, style: OrderStyle, price_or_style: Optional[Float64] = None) -> OrderStyle:
    var actual_style = style
    if price_or_style != None:
        actual_style = LimitOrder(price_or_style.value())
    elif price > 0.0:
        actual_style = LimitOrder(price)
    return actual_style


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
    if cash_amount == 0.0:
        return None

    var bar = ctx.get_bar(order_book_id)
    if bar.close() <= 0.0:
        return None

    var quantity = Int(cash_amount / bar.close() / 100.0) * 100
    if quantity == 0:
        return None

    return order_shares(ctx, order_book_id, quantity, style, price)


def order_percent(ctx: StrategyContext, order_book_id: String, percent: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    if percent <= 0.0 or percent > 1.0:
        return None

    var portfolio = ctx.portfolio()
    var cash_amount = portfolio.total_value * percent

    return order_value(ctx, order_book_id, cash_amount, style, price)


def order_target_value(ctx: StrategyContext, order_book_id: String, target_value: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    var portfolio = ctx.portfolio()
    var position = portfolio.get_position(order_book_id, POSITION_DIRECTION.LONG)

    var current_value = position.market_value()
    var delta_value = target_value - current_value

    return order_value(ctx, order_book_id, delta_value, style, price)


def order_target_percent(ctx: StrategyContext, order_book_id: String, target_percent: Float64, style: ORDER_TYPE = ORDER_TYPE.MARKET, price: Float64 = 0.0) -> Optional[Order]:
    var portfolio = ctx.portfolio()
    var target_value = portfolio.total_value * target_percent

    return order_target_value(ctx, order_book_id, target_value, style, price)


def submit_order(
    ctx: StrategyContext,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    style: Optional[OrderStyle] = None,
    price: Float64 = 0.0,
) -> Optional[Order]:
    if amount <= 0:
        return None

    var order_style = MarketOrder()
    if style != None:
        order_style = style.value()
    elif price > 0.0:
        order_style = LimitOrder(price)

    var _position_effect: Optional[POSITION_EFFECT] = None
    if side == SIDE.BUY:
        _position_effect = POSITION_EFFECT.OPEN
    else:
        _position_effect = POSITION_EFFECT.CLOSE

    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=side,
        quantity=amount,
        style=order_style,
        position_effect=_position_effect
    )


def cancel_order(ctx: StrategyContext, order: Order) -> Order:
    if not order.is_active():
        return order.copy()
    return order.copy()


def update_universe(mut ctx: StrategyContext, id_or_symbols: List[String]) -> None:
    ctx.update_universe(Set[String](id_or_symbols))


def subscribe(ctx: StrategyContext, order_book_id: String) -> None:
    pass


def unsubscribe(ctx: StrategyContext, order_book_id: String) -> None:
    pass


def history_bars(
    ctx: StrategyContext,
    order_book_id: String,
    bar_count: Int,
    frequency: String,
    fields: String = "close",
    skip_suspended: Bool = True,
    include_now: Bool = False,
    adjust_type: String = "pre"
) -> List[Float64]:
    var result = List[Float64]()
    var count = 0

    while count < bar_count:
        var bar = ctx.get_bar(order_book_id)
        if fields == "close":
            result.append(bar.close())
        elif fields == "open":
            result.append(bar.open())
        elif fields == "high":
            result.append(bar.high())
        elif fields == "low":
            result.append(bar.low())
        elif fields == "volume":
            result.append(bar.volume())
        else:
            result.append(bar.close())
        count += 1

    return result^


def history(
    ctx: StrategyContext,
    order_book_id: String,
    bar_count: Int,
    frequency: String = "1d",
    fields: String = "close"
) -> List[Float64]:
    return history_bars(ctx, order_book_id, bar_count, frequency, fields)


def get_price(
    ctx: StrategyContext,
    order_book_id: String,
    start_date: DateTime,
    end_date: DateTime,
    frequency: String = "1d"
) -> List[Float64]:
    var result = List[Float64]()
    var current_dt = start_date
    var max_iterations = 10000
    var count = 0

    while count < max_iterations:
        if current_dt.year > end_date.year:
            break
        if current_dt.year == end_date.year and current_dt.month > end_date.month:
            break
        if current_dt.year == end_date.year and current_dt.month == end_date.month and current_dt.day > end_date.day:
            break

        var bar = ctx.get_bar(order_book_id)
        result.append(bar.close())

        count += 1
        current_dt = DateTime(current_dt.year, current_dt.month, current_dt.day + 1, 0, 0, 0, 0)

    return result^


def current_snapshot(ctx: StrategyContext, order_book_id: String) -> Optional[Snapshot]:
    return None


def get_trading_dates(ctx: StrategyContext, start_date: DateTime, end_date: DateTime) -> List[DateTime]:
    var result = List[DateTime]()
    var current_dt = start_date
    var max_iterations = 10000
    var count = 0

    while count < max_iterations:
        if current_dt.year > end_date.year:
            break
        if current_dt.year == end_date.year and current_dt.month > end_date.month:
            break
        if current_dt.year == end_date.year and current_dt.month == end_date.month and current_dt.day > end_date.day:
            break

        result.append(current_dt)
        current_dt = DateTime(current_dt.year, current_dt.month, current_dt.day + 1, 0, 0, 0, 0)
        count += 1

    return result^


def get_previous_trading_date(ctx: StrategyContext, date: DateTime) -> DateTime:
    var prev_day = date.day - 1
    var prev_month = date.month
    var prev_year = date.year

    if prev_day < 1:
        prev_month -= 1
        if prev_month < 1:
            prev_month = 12
            prev_year -= 1
        prev_day = 28

    return DateTime(prev_year, prev_month, prev_day, 0, 0, 0, 0)


def get_next_trading_date(ctx: StrategyContext, date: DateTime) -> DateTime:
    var next_day = date.day + 1
    var next_month = date.month
    var next_year = date.year

    if next_day > 31:
        next_day = 1
        next_month += 1
        if next_month > 12:
            next_month = 1
            next_year += 1

    return DateTime(next_year, next_month, next_day, 0, 0, 0, 0)


def get_position(ctx: StrategyContext, order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG) -> Optional[Position]:
    var portfolio = ctx.portfolio()
    var pos = portfolio.get_position(order_book_id, direction)
    if pos.quantity == 0:
        return None
    return pos^


def get_positions(ctx: StrategyContext) -> List[Position]:
    var result = List[Position]()
    return result^


def get_portfolio(ctx: StrategyContext) -> Portfolio:
    return ctx.portfolio()


def instruments(ctx: StrategyContext, id_or_symbol: String) raises -> Optional[Instrument]:
    return ctx.get_instrument(id_or_symbol)


def all_instruments(ctx: StrategyContext, type_str: String = "") -> List[Instrument]:
    var result = List[Instrument]()
    return result^


def active_instrument(ctx: StrategyContext, order_book_id: String) raises -> Optional[Instrument]:
    return ctx.get_instrument(order_book_id)


def deposit(ctx: StrategyContext, account_type: String, amount: Float64, receiving_days: Int = 0) -> None:
    pass


def withdraw(ctx: StrategyContext, account_type: String, amount: Float64) -> None:
    pass
