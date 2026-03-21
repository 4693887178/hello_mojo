"""
RQAlpha Mojo - Adjust Module
Ported from rqalpha/data/base_data_source/adjust.py
"""

from std.collections import Set, List
from rqmojo.utils.datetime_func import convert_date_to_int


comptime PRICE_FIELDS: Set[String] = Set[String]()
comptime FIELDS_REQUIRE_ADJUSTMENT: Set[String] = Set[String]()


def _init_price_fields() -> Set[String]:
    var s = Set[String]()
    s.add("open")
    s.add("close")
    s.add("high")
    s.add("low")
    s.add("limit_up")
    s.add("limit_down")
    s.add("acc_net_value")
    s.add("unit_net_value")
    return s


def _init_fields_require_adjustment() -> Set[String]:
    var s = _init_price_fields()
    s.add("volume")
    return s


def _factor_for_date(dates: List[UInt64], factors: List[Float64], d: UInt64) -> Float64:
    var pos = 0
    for i in range(len(dates)):
        if dates[i] > d:
            pos = i
            break
        pos = i + 1
    if pos == 0:
        pos = 1
    return factors[pos - 1]


def adjust_bars(
    bars: List[Dict[String, object]],
    ex_factors: Dict[String, object],
    fields: String,
    adjust_type: String,
    adjust_orig: object
) -> List[Dict[String, object]]:
    if ex_factors == None or len(bars) == 0:
        return bars
    
    var price_fields = _init_price_fields()
    
    var dates = ex_factors.get("start_date", List[UInt64]())
    var ex_cum_factors = ex_factors.get("ex_cum_factor", List[Float64]())
    
    var base_adjust_rate: Float64 = 1.0
    if adjust_type == "pre":
        var adjust_orig_dt = convert_date_to_int(adjust_orig)
        base_adjust_rate = _factor_for_date(dates, ex_cum_factors, adjust_orig_dt)
    
    var start_date = bars[0].get("datetime", 0)
    var end_date = bars[-1].get("datetime", 0)
    
    if (_factor_for_date(dates, ex_cum_factors, start_date) == base_adjust_rate and
        _factor_for_date(dates, ex_cum_factors, end_date) == base_adjust_rate):
        return bars
    
    return bars


def get_price_fields() -> Set[String]:
    return _init_price_fields()


def get_fields_require_adjustment() -> Set[String]:
    return _init_fields_require_adjustment()


def main():
    print("adjust.mojo - Data adjustment module loaded successfully")
