"""
RQAlpha Mojo - Adjust Module
Ported from rqalpha/data/base_data_source/adjust.py
Uses Python interop for numpy operations
"""

from std.collections import Set, List, Dict
from std.python import Python, PythonObject
from rqmojo.utils.datetime_func import convert_date_to_int


def get_price_fields() -> Set[String]:
    var s = Set[String]()
    s.add("open")
    s.add("close")
    s.add("high")
    s.add("low")
    s.add("limit_up")
    s.add("limit_down")
    s.add("acc_net_value")
    s.add("unit_net_value")
    return s^


def get_fields_require_adjustment() -> Set[String]:
    var s = get_price_fields()
    s.add("volume")
    return s^


def _is_price_field(field: String) -> Bool:
    var price_fields = ["open", "close", "high", "low", "limit_up", "limit_down", "acc_net_value", "unit_net_value"]
    for f in price_fields:
        if f == field:
            return True
    return False


def _factor_for_date(dates: PythonObject, factors: PythonObject, d: PythonObject) raises -> PythonObject:
    var bisect = Python.import_module("bisect")
    var pos = bisect.bisect_right(dates, d)
    return factors[pos - 1]


def adjust_bars(
    bars: PythonObject,
    ex_factors: PythonObject,
    fields: PythonObject,
    adjust_type: PythonObject,
    adjust_orig: PythonObject
) raises -> PythonObject:
    var np = Python.import_module("numpy")
    
    if ex_factors == Python.none() or len(bars) == 0:
        return bars
    
    var dates = ex_factors["start_date"]
    var ex_cum_factors = ex_factors["ex_cum_factor"]
    
    var base_adjust_rate: PythonObject
    if adjust_type == "pre":
        var convert_date_to_int_py = Python.import_module("rqalpha.utils.datetime_func").convert_date_to_int
        var adjust_orig_dt = np.uint64(convert_date_to_int_py(adjust_orig))
        base_adjust_rate = _factor_for_date(dates, ex_cum_factors, adjust_orig_dt)
    else:
        base_adjust_rate = PythonObject(1.0)
    
    var start_date = bars["datetime"][0]
    var end_date = bars["datetime"][-1]
    
    var start_factor = _factor_for_date(dates, ex_cum_factors, start_date)
    var end_factor = _factor_for_date(dates, ex_cum_factors, end_date)
    
    if start_factor == base_adjust_rate and end_factor == base_adjust_rate:
        return bars
    
    var searchsorted_result = dates.searchsorted(bars["datetime"], side="right") - 1
    var factors = ex_cum_factors.take(searchsorted_result)
    
    var bars_copy = bars.copy()
    factors = factors / base_adjust_rate
    
    var fields_str = String(py=fields)
    if fields_str != "":
        if _is_price_field(fields_str):
            bars_copy[fields] = bars_copy[fields] * factors
            return bars_copy
        elif fields_str == "volume":
            bars_copy[fields] = bars_copy[fields] * (1 / factors)
            return bars_copy
        return bars_copy
    
    var dtype_names = bars_copy.dtype.names
    for f in dtype_names:
        var field_name = String(py=f)
        if _is_price_field(field_name):
            bars_copy[f] = bars_copy[f] * factors
        elif field_name == "volume":
            bars_copy[f] = bars_copy[f] * (1 / factors)
    
    return bars_copy


def main():
    print("adjust.mojo - Data adjustment module loaded successfully (Python interop)")
