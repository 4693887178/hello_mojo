"""
RQAlpha Mojo - Data Source Adjust
Ported from rqalpha/data/base_data_source/adjust.py
"""

from rqmojo.model.bar import BarObject
from rqmojo.utils.datetime_func import DateTime


fn adjust_price_pre(price: Float64, factor: Float64) -> Float64:
    return price * factor


fn adjust_price_post(price: Float64, factor: Float64) -> Float64:
    return price / factor


fn calculate_adjust_factor(pre_close: Float64, ex_close: Float64, dividend: Float64 = 0.0, split_ratio: Float64 = 1.0) -> Float64:
    if pre_close <= 0:
        return 1.0
    return (ex_close + dividend) / pre_close / split_ratio


fn adjust_bars(bars: List[BarObject], factors: List[Float64], adjust_type: String = "pre") -> List[BarObject]:
    var result = List[BarObject]()
    
    if len(bars) != len(factors):
        return bars
    
    for i in range(len(bars)):
        var bar = bars[i]
        var factor = factors[i]
        
        if adjust_type == "pre":
            result.append(BarObject(
                datetime=bar.datetime,
                open=adjust_price_pre(bar.open, factor),
                high=adjust_price_pre(bar.high, factor),
                low=adjust_price_pre(bar.low, factor),
                close=adjust_price_pre(bar.close, factor),
                volume=bar.volume,
                total_turnover=bar.total_turnover
            ))
        elif adjust_type == "post":
            result.append(BarObject(
                datetime=bar.datetime,
                open=adjust_price_post(bar.open, factor),
                high=adjust_price_post(bar.high, factor),
                low=adjust_price_post(bar.low, factor),
                close=adjust_price_post(bar.close, factor),
                volume=bar.volume,
                total_turnover=bar.total_turnover
            ))
        else:
            result.append(bar)
    
    return result
