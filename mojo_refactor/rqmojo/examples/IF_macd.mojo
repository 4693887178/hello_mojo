"""
RQAlpha Mojo - IF MACD Strategy Example
Ported from rqalpha/examples/IF_macd.py
"""

from rqmojo.apis import *
from python import talib


fn init(context: object) -> None:
    context.s1 = "IF1606"
    context.SHORTPERIOD = 12
    context.LONGPERIOD = 26
    context.SMOOTHPERIOD = 9
    context.OBSERVATION = 50
    subscribe(context.s1)


fn handle_bar(context: object, bar_dict: object) -> None:
    var prices = history_bars(context.s1, context.OBSERVATION, "1d", "close")
    
    var macd_result = talib.MACD(prices, context.SHORTPERIOD, context.LONGPERIOD, context.SMOOTHPERIOD)
    var macd = macd_result[0]
    var signal = macd_result[1]
    var hist = macd_result[2]
    
    if macd[-1] - signal[-1] > 0 and macd[-2] - signal[-2] < 0:
        var sell_qty = get_position(context.s1, POSITION_DIRECTION_SHORT).quantity
        if sell_qty > 0:
            buy_close(context.s1, 1)
        buy_open(context.s1, 1)
    
    if macd[-1] - signal[-1] < 0 and macd[-2] - signal[-2] > 0:
        var buy_qty = get_position(context.s1, POSITION_DIRECTION_LONG).quantity
        if buy_qty > 0:
            sell_close(context.s1, 1)
        sell_open(context.s1, 1)
