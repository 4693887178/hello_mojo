"""
RQAlpha Mojo - RQData API
Ported from rqalpha/apis/api_rqdatac.py
"""

from std.collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE
from rqmojo.model.order import Order
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.utils.datetime_func import DateTime


def get_price(ctx: StrategyContext, order_book_id: String, start_date: DateTime, end_date: DateTime, frequency: String = "1d") -> List[Float64]:
    var prices = List[Float64]()
    var bar = ctx.get_bar(order_book_id)
    var close_price = bar.close()
    prices.append(close_price)
    return prices^


def get_yield_curve(ctx: StrategyContext, start_date: DateTime, end_date: DateTime, tenor: String = "10y") -> Dict[String, Float64]:
    var result = Dict[String, Float64]()
    result["10y"] = 0.03
    return result^


def is_trading_date(ctx: StrategyContext, date: DateTime) -> Bool:
    return ctx.is_suspended("000001.XSHE")


def get_previous_trading_date(ctx: StrategyContext, date: DateTime) -> DateTime:
    return DateTime(date.year, date.month, date.day - 1, 0, 0, 0, 0)


def get_next_trading_date(ctx: StrategyContext, date: DateTime) -> DateTime:
    return DateTime(date.year, date.month, date.day + 1, 0, 0, 0, 0)


def get_dividend_info(ctx: StrategyContext, order_book_id: String) -> Dict[String, Float64]:
    var result = Dict[String, Float64]()
    return result^


def get_split_info(ctx: StrategyContext, order_book_id: String) -> Dict[String, Float64]:
    var result = Dict[String, Float64]()
    return result^
