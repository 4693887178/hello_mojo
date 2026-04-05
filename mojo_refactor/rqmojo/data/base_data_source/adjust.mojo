"""
RQAlpha Mojo - Adjust Module
Ported from rqalpha/data/base_data_source/adjust.py
Uses bison library for data processing (Series for date/factor lookups),
Mojo native List[Float64] for numerical computation (fully replacing numpy).
Zero numpy import — all numpy objects obtained via pandas bridge.
"""

from std.collections import Set, List
from std.python import Python, PythonObject
from rqmojo.utils.datetime_func import convert_date_to_int, to_date
from bison import Series


def _build_price_fields_set() raises -> Set[String]:
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


def get_price_fields() raises -> Set[String]:
    return _build_price_fields_set().copy()


def get_fields_require_adjustment() raises -> Set[String]:
    var s = get_price_fields()
    s.add("volume")
    return s^


def _is_price_field(field: String) raises -> Bool:
    return field in _build_price_fields_set()


@always_inline
def _factor_for_date(dates: Series, factors: Series, d: Int64) raises -> Float64:
    var left: Int = 0
    var right: Int = dates.size()
    while left < right:
        var mid: Int = (left + right) // 2
        var mid_val = dates.iloc(mid)[Int64]
        if mid_val <= d:
            left = mid + 1
        else:
            right = mid
    if left > 0:
        return factors.iloc(left - 1)[Float64]
    else:
        return factors.iloc(0)[Float64]


@always_inline
def _mojo_list_to_py_array(mojo_list: List[Float64]) raises -> PythonObject:
    """Convert Mojo List[Float64] to numpy array via pandas bridge."""
    var py_list = Python.list()
    for val in mojo_list:
        py_list.append(PythonObject(val))
    var pd = Python.import_module("pandas")
    return pd.Series(py_list).values


@always_inline
def _build_factor_arrays(
    size: Int,
    bar_dates: PythonObject,
    dates: Series,
    ex_cum_factors: Series,
    base_rate: Float64,
) raises -> Tuple[PythonObject, PythonObject]:
    """Build both normal and reciprocal adjustment factor arrays using pure Mojo.
    
    Returns (factors, inv_factors) as numpy arrays via pandas bridge.
    Replaces: np.zeros + loop fill + np.array() + scalar division + 1.0/arr.
    """
    var factors = List[Float64](capacity=size)
    var inv_factors = List[Float64](capacity=size)
    for i in range(size):
        var d = Int64(Int(py=bar_dates[i]))
        var f = _factor_for_date(dates, ex_cum_factors, d)
        var adjusted = f / base_rate
        factors.append(adjusted)
        inv_factors.append(Float64(1.0) / adjusted)

    return (_mojo_list_to_py_array(factors), _mojo_list_to_py_array(inv_factors))


def adjust_bars(
    bars: PythonObject,
    ex_factors: PythonObject,
    fields: PythonObject,
    adjust_type: PythonObject,
    adjust_orig: PythonObject,
) raises -> PythonObject:
    var is_none = Bool(py=ex_factors is Python.none())
    if is_none or len(bars) == 0:
        return bars

    var pd = Python.import_module("pandas")
    var dates = Series(pd.Series(ex_factors["start_date"]))
    var ex_cum_factors = Series(pd.Series(ex_factors["ex_cum_factor"]))

    var base_adjust_rate: Float64
    if String(py=adjust_type) == "pre":
        var adjust_orig_str = String(py=adjust_orig)
        var adjust_orig_date = to_date(adjust_orig_str)
        var adjust_orig_dt = convert_date_to_int(adjust_orig_date)
        base_adjust_rate = _factor_for_date(dates, ex_cum_factors, Int64(adjust_orig_dt))
    else:
        base_adjust_rate = Float64(1.0)

    var start_date = Int64(Int(py=bars["datetime"][0]))
    var end_date = Int64(Int(py=bars["datetime"][len(bars) - 1]))

    var start_factor = _factor_for_date(dates, ex_cum_factors, start_date)
    var end_factor = _factor_for_date(dates, ex_cum_factors, end_date)

    if start_factor == base_adjust_rate and end_factor == base_adjust_rate:
        return bars

    var bar_dates = bars["datetime"]
    var size = len(bar_dates)

    var (py_factors, py_inv_factors) = _build_factor_arrays(
        size, bar_dates, dates, ex_cum_factors, base_adjust_rate
    )

    var result_bars = bars.copy()

    var fields_str = String(py=fields)
    if fields_str != "":
        if _is_price_field(fields_str):
            result_bars[fields] = result_bars[fields] * py_factors
            return result_bars
        elif fields_str == "volume":
            result_bars[fields] = (result_bars[fields] * py_inv_factors).astype(
                result_bars[fields].dtype
            )
            return result_bars
        return result_bars

    var dtype_names = result_bars.dtype.names
    for f in dtype_names:
        var field_name = String(py=f)
        if _is_price_field(field_name):
            result_bars[f] = result_bars[f] * py_factors
        elif field_name == "volume":
            result_bars[f] = (result_bars[f] * py_inv_factors).astype(
                result_bars[f].dtype
            )

    return result_bars


def adjust_ratio(
    pre_close: PythonObject,
    ex_factor: PythonObject,
) raises -> PythonObject:
    """Calculate adjustment ratio from previous close price and ex-factor."""
    var pre_close_val = Float64(py=pre_close)
    var ex_factor_val = Float64(py=ex_factor)
    if ex_factor_val != Float64(0.0) and pre_close_val != Float64(0.0):
        return PythonObject(pre_close_val / ex_factor_val)
    else:
        return PythonObject(Float64(1.0))
