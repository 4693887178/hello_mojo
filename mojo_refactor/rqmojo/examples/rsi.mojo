"""
RQAlpha Mojo - RSI Strategy Example
Ported from rqalpha/examples/rsi.py
"""

from rqmojo.apis import *
from python import talib


fn init(context: object) -> None:
    context.s1 = "000001.XSHE"
    context.s2 = "601988.XSHG"
    context.s3 = "000068.XSHE"
    context.stocks = [context.s1, context.s2, context.s3]
    context.TIME_PERIOD = 14
    context.HIGH_RSI = 85
    context.LOW_RSI = 30
    context.ORDER_PERCENT = 0.3


fn handle_bar(context: object, bar_dict: object) -> None:
    for stock in context.stocks:
        var prices = history_bars(stock, context.TIME_PERIOD + 1, "1d", "close")
        
        var rsi_data = talib.RSI(prices, timeperiod=context.TIME_PERIOD)[-1]
        
        var cur_position = get_position(stock).quantity
        var target_available_cash = context.portfolio.cash * context.ORDER_PERCENT
        
        if rsi_data > context.HIGH_RSI and cur_position > 0:
            order_target_value(stock, 0)
        
        if rsi_data < context.LOW_RSI:
            log.info("target available cash calculated: {}", target_available_cash)
            order_value(stock, target_available_cash)
