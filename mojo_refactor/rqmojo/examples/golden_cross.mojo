"""
RQAlpha Mojo - Golden Cross Strategy Example
Ported from rqalpha/examples/golden_cross.py
"""

from rqmojo.apis import *


fn init(context: object) -> None:
    context.s1 = "000001.XSHE"
    context.SHORTPERIOD = 20
    context.LONGPERIOD = 120


fn handle_bar(context: object, bar_dict: object) -> None:
    var prices = history_bars(context.s1, context.LONGPERIOD + 1, "1d", "close")
    
    var short_avg = simple_moving_average(prices, context.SHORTPERIOD)
    var long_avg = simple_moving_average(prices, context.LONGPERIOD)
    
    plot("short avg", short_avg[-1])
    plot("long avg", long_avg[-1])
    
    var cur_position = get_position(context.s1).quantity
    var shares = context.portfolio.cash / bar_dict[context.s1].close
    
    if short_avg[-1] - long_avg[-1] < 0 and short_avg[-2] - long_avg[-2] > 0 and cur_position > 0:
        order_target_value(context.s1, 0)
    
    if short_avg[-1] - long_avg[-1] > 0 and short_avg[-2] - long_avg[-2] < 0:
        order_shares(context.s1, shares)


fn simple_moving_average(data: List[Float64], period: Int) -> List[Float64]:
    var result = List[Float64]()
    for i in range(period - 1, len(data)):
        var sum = 0.0
        for j in range(i - period + 1, i + 1):
            sum += data[j]
        result.append(sum / period)
    return result
