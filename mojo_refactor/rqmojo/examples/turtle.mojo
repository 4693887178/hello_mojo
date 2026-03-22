"""
RQAlpha Mojo - Turtle Trading Strategy Example
Ported from rqalpha/examples/turtle.py
"""

from rqmojo.apis import *
from python import numpy as np
from python import talib
from python import math


def get_extreme(array_high_price_result: object, array_low_price_result: object) -> List[Float64]:
    var np_array_high_price_result = np.array(array_high_price_result[:-1])
    var np_array_low_price_result = np.array(array_low_price_result[:-1])
    var max_result = np_array_high_price_result.max()
    var min_result = np_array_low_price_result.min()
    return [max_result, min_result]


def get_atr_and_unit(atr_array_result: object, atr_length_result: Int, portfolio_value_result: Float64) -> List[Float64]:
    var atr = atr_array_result[atr_length_result - 1]
    var unit = math.floor(portfolio_value_result * 0.01 / atr)
    return [atr, unit]


def get_stop_price(first_open_price_result: Float64, units_hold_result: Int, atr_result: Float64) -> Float64:
    var stop_price = first_open_price_result - 2 * atr_result + (units_hold_result - 1) * 0.5 * atr_result
    return stop_price


def init(context: object) -> None:
    context.trade_day_num = 0
    context.unit = 0
    context.atr = 0
    context.trading_signal = "start"
    context.pre_trading_signal = ""
    context.units_hold_max = 4
    context.units_hold = 0
    context.quantity = 0
    context.max_add = 0
    context.first_open_price = 0
    context.s = "000300.XSHG"
    context.open_observe_time = 55
    context.close_observe_time = 20
    context.atr_time = 20


def handle_bar(context: object, bar_dict: object) -> None:
    var portfolio_value = context.portfolio.portfolio_value
    var high_price = history_bars(context.s, context.open_observe_time + 1, "1d", "high")
    var low_price_for_atr = history_bars(context.s, context.open_observe_time + 1, "1d", "low")
    var low_price_for_extreme = history_bars(context.s, context.close_observe_time + 1, "1d", "low")
    var close_price = history_bars(context.s, context.open_observe_time + 2, "1d", "close")
    var close_price_for_atr = close_price[:-1]
    
    var atr_array = talib.ATR(high_price, low_price_for_atr, close_price_for_atr, timeperiod=context.atr_time)
    
    var extreme = get_extreme(high_price, low_price_for_extreme)
    var maxx = extreme[0]
    var minn = extreme[1]
    var atr = atr_array[-2]
    
    if context.trading_signal != "start":
        if context.units_hold != 0:
            context.max_add += 0.5 * get_atr_and_unit(atr_array, atr_array.size, portfolio_value)[0]
    else:
        context.max_add = bar_dict[context.s].last
    
    var cur_position = get_position(context.s).quantity
    var available_cash = context.portfolio.cash
    var market_value = context.portfolio.market_value
    
    if cur_position > 0 and bar_dict[context.s].last < get_stop_price(context.first_open_price, context.units_hold, atr):
        context.trading_signal = "stop"
    else:
        if cur_position > 0 and bar_dict[context.s].last < minn:
            context.trading_signal = "exit"
        else:
            if bar_dict[context.s].last > context.max_add and context.units_hold != 0 and context.units_hold < context.units_hold_max and available_cash > bar_dict[context.s].last * context.unit:
                context.trading_signal = "entry_add"
            else:
                if bar_dict[context.s].last > maxx and context.units_hold == 0:
                    context.max_add = bar_dict[context.s].last
                    context.trading_signal = "entry"
    
    atr = get_atr_and_unit(atr_array, atr_array.size, portfolio_value)[0]
    if context.trade_day_num % 5 == 0:
        context.unit = get_atr_and_unit(atr_array, atr_array.size, portfolio_value)[1]
    context.trade_day_num += 1
    context.quantity = context.unit
    
    if context.trading_signal != context.pre_trading_signal or (context.units_hold < context.units_hold_max and context.units_hold > 1) or context.trading_signal == "stop":
        if context.trading_signal == "entry":
            context.quantity = context.unit
            if available_cash > bar_dict[context.s].last * context.quantity:
                order_shares(context.s, context.quantity)
                context.first_open_price = bar_dict[context.s].last
                context.units_hold = 1
        
        if context.trading_signal == "entry_add":
            context.quantity = context.unit
            order_shares(context.s, context.quantity)
            context.units_hold += 1
        
        if context.trading_signal == "stop":
            if context.units_hold > 0:
                order_shares(context.s, -context.quantity)
                context.units_hold -= 1
        
        if context.trading_signal == "exit":
            if cur_position > 0:
                order_shares(context.s, -cur_position)
                context.units_hold = 0
    
    context.pre_trading_signal = context.trading_signal
