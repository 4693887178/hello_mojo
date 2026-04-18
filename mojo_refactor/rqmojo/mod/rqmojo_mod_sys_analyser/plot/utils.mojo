"""
RQAlpha Mojo - Plot Utils
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/plot/utils.py
"""

from std.math import sqrt
from rqmojo.utils.typing import DateTime
from rqmojo.mod.rqmojo_mod_sys_analyser.plot.consts import IndexRange


def _pad_zero(value: Int, width: Int) -> String:
    var s = String(value)
    while len(s) < width:
        s = "0" + s
    return s


def format_date(dt: DateTime) -> String:
    return String(dt.year) + "-" + _pad_zero(dt.month, 2) + "-" + _pad_zero(dt.day, 2)


def format_datetime(dt: DateTime) -> String:
    return format_date(dt) + " " + _pad_zero(dt.hour, 2) + ":" + _pad_zero(dt.minute, 2) + ":" + _pad_zero(dt.second, 2)


def calculate_returns(nav_list: List[Float64]) -> List[Float64]:
    var returns = List[Float64]()
    if len(nav_list) < 2:
        return returns^

    for i in range(1, len(nav_list)):
        if nav_list[i-1] > 0:
            var ret = (nav_list[i] - nav_list[i-1]) / nav_list[i-1]
            returns.append(ret)
        else:
            returns.append(0.0)

    return returns^


def calculate_max_drawdown(nav_list: List[Float64]) -> Float64:
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


def calculate_sharpe_ratio(returns: List[Float64], risk_free_rate: Float64 = 0.03) -> Float64:
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

    var std_dev = sqrt(sum_sq_diff / Float64(len(returns)))

    if std_dev == 0:
        return 0.0

    return (avg_return - risk_free_rate / 252.0) / std_dev * sqrt(252.0)


def max_dd(arr: List[Float64], index: List[String]) -> IndexRange:
    var n = len(arr)
    if n == 0:
        return IndexRange(start=0, end=0, start_date="", end_date="")

    var end_idx = 0
    var max_peak = arr[0]
    var max_ratio = 1.0

    for i in range(n):
        if arr[i] > max_peak:
            max_peak = arr[i]

        if max_peak > 0:
            var ratio = max_peak / arr[i]
            if ratio >= max_ratio:
                max_ratio = ratio
                end_idx = i

    if end_idx == 0:
        end_idx = n - 1

    var start_idx = 0
    for i in range(end_idx):
        if arr[i] >= arr[start_idx]:
            start_idx = i

    var start_date_str = ""
    var end_date_str = ""
    if start_idx < len(index):
        start_date_str = index[start_idx]
    if end_idx < len(index):
        end_date_str = index[end_idx]

    return IndexRange(
        start=start_idx,
        end=end_idx,
        start_date=start_date_str,
        end_date=end_date_str
    )


def max_ddd(arr: List[Float64], index: List[String]) -> IndexRange:
    var n = len(arr)
    if n == 0:
        return IndexRange(start=0, end=0, start_date="", end_date="")

    var max_seen = arr[0]
    var ddd_start = 0
    var ddd_end = 0
    var ddd = 0
    var start = 0
    var in_draw_down = False
    var last_i = 0

    for i in range(n):
        last_i = i
        if arr[i] > max_seen:
            if in_draw_down:
                in_draw_down = False
                if i - start > ddd:
                    ddd = i - start
                    ddd_start = start
                    ddd_end = i - 1
            max_seen = arr[i]
        elif arr[i] < max_seen:
            if not in_draw_down:
                in_draw_down = True
                start = i - 1

    if last_i > 0 and arr[last_i] < max_seen:
        if last_i - start > ddd:
            var sd = ""
            var ed = ""
            if start < len(index):
                sd = index[start]
            if last_i < len(index):
                ed = index[last_i]
            return IndexRange(start=start, end=last_i, start_date=sd, end_date=ed)

    var sd = ""
    var ed = ""
    if ddd_start < len(index):
        sd = index[ddd_start]
    if ddd_end < len(index):
        ed = index[ddd_end]
    return IndexRange(start=ddd_start, end=ddd_end, start_date=sd, end_date=ed)


def weekly_returns(nav_list: List[Float64], dates: List[String]) -> List[Float64]:
    var result = List[Float64]()
    if len(nav_list) == 0 or len(dates) == 0:
        return result^

    var week_start_idx = 0
    var last_week_key = ""

    for i in range(len(dates)):
        var date_str = dates[i]
        var week_key: String
        if len(date_str) >= 10:
           week_key = String(date_str[byte=0:7])
        else:
            week_key = date_str

        if week_key != last_week_key and len(last_week_key) > 0:
            if week_start_idx > 0 and week_start_idx < len(nav_list):
                var prev_val = nav_list[week_start_idx - 1]
                if prev_val != 0:
                    result.append(nav_list[i - 1] / prev_val - 1.0)
                else:
                    result.append(0.0)

        last_week_key = week_key
        if i == 0 or week_key != last_week_key:
            week_start_idx = i

    if week_start_idx > 0 and week_start_idx < len(nav_list):
        var prev_val = nav_list[week_start_idx - 1]
        var n = len(nav_list)
        if prev_val != 0 and n > 0:
            result.append(nav_list[n - 1] / prev_val - 1.0)
        else:
            result.append(0.0)

    return result^


def trading_dates_index(trade_dates: List[String], position_effect: String, index: List[String]) -> List[Int]:
    var result = List[Int]()
    if len(index) == 0:
        return result^

    for td in trade_dates:
        var idx = _binary_search_right(index, td)
        if idx > 0:
            result.append(idx - 1)

    return result^


def _binary_search_right(arr: List[String], target: String) -> Int:
    var lo = 0
    var hi = len(arr)
    while lo < hi:
        var mid = (lo + hi) // 2
        if arr[mid] <= target:
            lo = mid + 1
        else:
            hi = mid
    return lo
