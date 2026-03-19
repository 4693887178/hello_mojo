"""
RQAlpha Mojo - MACD Strategy Example
Ported from rqalpha/examples/macd.py
"""

from rqmojo.apis import *
from python import talib


fn init(context: object) -> None:
    context.s1 = "000001.XSHE"
    context.SHORTPERIOD = 12
    context.LONGPERIOD = 26
    context.SMOOTHPERIOD = 9
    context.OBSERVATION = 100


fn handle_bar(context: object, bar_dict: object) -> None:
    var prices = history_bars(context.s1, context.OBSERVATION, "1d", "close")
    
    var macd_result = talib.MACD(prices, context.SHORTPERIOD, context.LONGPERIOD, context.SMOOTHPERIOD)
    var macd = macd_result[0]
    var signal = macd_result[1]
    var hist = macd_result[2]
    
    plot("macd", macd[-1])
    plot("macd signal", signal[-1])
    
    if macd[-1] - signal[-1] < 0 and macd[-2] - signal[-2] > 0:
        var cur_position = get_position(context.s1).quantity
        if cur_position > 0:
            order_target_value(context.s1, 0)
    
    if macd[-1] - signal[-1] > 0 and macd[-2] - signal[-2] < 0:
        order_target_percent(context.s1, 1)
