"""
RQAlpha Mojo - Pair Trading Strategy Example
Ported from rqalpha/examples/pair_trading.py
"""

from rqmojo.apis import *
from python import numpy as np


def init(context: object) -> None:
    context.s1 = "AG1612"
    context.s2 = "AU1612"
    context.counter = 0
    context.window = 60
    context.ratio = 15
    context.up_cross_up_limit = False
    context.down_cross_down_limit = False
    context.entry_score = 2
    subscribe([context.s1, context.s2])


def before_trading(context: object) -> None:
    context.counter = 0


def handle_bar(context: object, bar_dict: object) -> None:
    var long_pos_a = get_position(context.s1, POSITION_DIRECTION.LONG)
    var short_pos_a = get_position(context.s1, POSITION_DIRECTION.SHORT)
    var long_pos_b = get_position(context.s2, POSITION_DIRECTION.LONG)
    var short_pos_b = get_position(context.s2, POSITION_DIRECTION.SHORT)
    
    context.counter += 1
    
    if context.counter > context.window:
        var price_array_a = history_bars(context.s1, context.window, "1m", "close")
        var price_array_b = history_bars(context.s2, context.window, "1m", "close")
        
        var spread_array = np.subtract(price_array_a, np.multiply(context.ratio, price_array_b))
        var std = np.std(spread_array)
        var mean = np.mean(spread_array)
        var up_limit = mean + context.entry_score * std
        var down_limit = mean - context.entry_score * std
        
        var price_a = bar_dict[context.s1].close
        var price_b = bar_dict[context.s2].close
        var spread = price_a - context.ratio * price_b
        
        if spread <= down_limit and not context.down_cross_down_limit:
            log.info("spread: {}, mean: {}, down_limit: {}", spread, mean, down_limit)
            log.info("Creating buy spread position...")
            
            var qty_a = 1 - long_pos_a.quantity
            var qty_b = context.ratio - short_pos_b.sell_quantity
            
            if qty_a > 0:
                buy_open(context.s1, qty_a)
            if qty_b > 0:
                sell_open(context.s2, qty_b)
            if qty_a == 0 and qty_b == 0:
                context.down_cross_down_limit = True
                log.info("Buy spread position created successfully!")
        
        if spread >= mean and context.down_cross_down_limit:
            log.info("spread: {}, mean: {}, down_limit: {}", spread, mean, down_limit)
            log.info("Closing buy spread position...")
            
            var qty_a = long_pos_a.quantity
            var qty_b = short_pos_b.quantity
            if qty_a > 0:
                sell_close(context.s1, qty_a)
            if qty_b > 0:
                buy_close(context.s2, qty_b)
            if qty_a == 0 and qty_b == 0:
                context.down_cross_down_limit = False
                log.info("Buy spread position closed successfully!")
        
        if spread >= up_limit and not context.up_cross_up_limit:
            log.info("spread: {}, mean: {}, up_limit: {}", spread, mean, up_limit)
            log.info("Creating sell spread position...")
            
            var qty_a = 1 - short_pos_a.quantity
            var qty_b = context.ratio - long_pos_b.quantity
            if qty_a > 0:
                sell_open(context.s1, qty_a)
            if qty_b > 0:
                buy_open(context.s2, qty_b)
            if qty_a == 0 and qty_b == 0:
                context.up_cross_up_limit = True
                log.info("Sell spread position created successfully!")
        
        if spread < mean and context.up_cross_up_limit:
            log.info("spread: {}, mean: {}, up_limit: {}", spread, mean, up_limit)
            log.info("Closing sell spread position...")
            
            var qty_a = short_pos_a.quantity
            var qty_b = long_pos_b.quantity
            if qty_a > 0:
                buy_close(context.s1, qty_a)
            if qty_b > 0:
                sell_close(context.s2, qty_b)
            if qty_a == 0 and qty_b == 0:
                context.up_cross_up_limit = False
                log.info("Sell spread position closed successfully!")
