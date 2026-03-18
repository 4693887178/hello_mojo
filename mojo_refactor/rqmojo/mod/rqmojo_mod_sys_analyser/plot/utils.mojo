"""
RQAlpha Mojo - Plot Utils
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/utils.py
"""

from rqmojo.utils.datetime_func import DateTime


fn format_date(dt: DateTime) -> String:
    return String(dt.year) + "-" + String(dt.month).zfill(2) + "-" + String(dt.day).zfill(2)


fn format_datetime(dt: DateTime) -> String:
    return format_date(dt) + " " + String(dt.hour).zfill(2) + ":" + String(dt.minute).zfill(2) + ":" + String(dt.second).zfill(2)


fn calculate_returns(nav_list: List[Float64]) -> List[Float64]:
    var returns = List[Float64]()
    if len(nav_list) < 2:
        return returns
    
    for i in range(1, len(nav_list)):
        if nav_list[i-1] > 0:
            var ret = (nav_list[i] - nav_list[i-1]) / nav_list[i-1]
            returns.append(ret)
        else:
            returns.append(0.0)
    
    return returns


fn calculate_max_drawdown(nav_list: List[Float64]) -> Float64:
    if len(nav_list) == 0:
        return 0.0
    
    var max_nav = nav_list[0]
    var max_drawdown = 0.0
    
    for nav in nav_list:
        if nav > max_nav:
            max_nav = nav
        
        if max_nav > 0:
            var drawdown = (max_nav - nav) / max_nav
            if drawdown > max_drawdown:
                max_drawdown = drawdown
    
    return max_drawdown


fn calculate_sharpe_ratio(returns: List[Float64], risk_free_rate: Float64 = 0.03) -> Float64:
    if len(returns) == 0:
        return 0.0
    
    var sum_returns = 0.0
    for ret in returns:
        sum_returns += ret
    
    var avg_return = sum_returns / Float64(len(returns))
    
    var sum_sq_diff = 0.0
    for ret in returns:
        var diff = ret - avg_return
        sum_sq_diff += diff * diff
    
    var std_dev = (sum_sq_diff / Float64(len(returns))).sqrt()
    
    if std_dev == 0:
        return 0.0
    
    return (avg_return - risk_free_rate / 252.0) / std_dev * 252.0.sqrt()
