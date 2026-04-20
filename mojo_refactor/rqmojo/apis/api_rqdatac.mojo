"""
RQAlpha Mojo - RQData API.
Ported from rqalpha/apis/api_rqdatac.py.
"""

from std.collections import Dict, List, Set, Optional
from std.python import Python, PythonObject
from rqmojo.const import EXECUTION_PHASE, EXCHANGE
from rqmojo.environment import Environment
from rqmojo.utils.typing import DateTime



def _bi() raises -> PythonObject:
    return Python.import_module("builtins")


def _py_getattr(obj: PythonObject, attr: String) raises -> PythonObject:
    return _bi().getattr(obj, attr)


def _py_hasattr(obj: PythonObject, attr: String) raises -> Bool:
    var has = True
    try:
        var _ = _bi().getattr(obj, attr)
    except:
        has = False
    return has


def _py_isinstance(obj: PythonObject, type_name: String) raises -> Bool:
    var cls_name = obj.__class__.__name__
    return Bool(py=cls_name == type_name)


def _py_str(val: PythonObject) raises -> PythonObject:
    return _bi().str(val)


def _py_set(val: PythonObject) raises -> PythonObject:
    return _bi().set(val)


def _py_setitem(obj: PythonObject, key: String, value: PythonObject) raises -> None:
    var op = Python.import_module("operator")
    op.setitem(obj, key, value)


def _str_slice(s: String, start: Int, end: Int) raises -> String:
    var py_s = _bi().str(s)
    var py_result = py_s[start:end]
    return String(py=py_result)


def _to_py_date(dt: DateTime) raises -> PythonObject:
    var dm = Python.import_module("datetime")
    return dm.date(dt.year, dt.month, dt.day)


def _to_py_datetime(dt: DateTime) raises -> PythonObject:
    var dm = Python.import_module("datetime")
    return dm.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)


def _to_date(date_val: PythonObject) raises -> PythonObject:
    var dm = Python.import_module("datetime")
    var dp = Python.import_module("dateutil.parser").parse
    var cls_name = date_val.__class__.__name__
    if cls_name == "datetime":
        return date_val.date()
    if cls_name == "date":
        return date_val
    try:
        var parsed = dp(_py_str(date_val))
        return parsed.date()
    except e:
        pass
    raise Error("unknown date value: " + String(py=cls_name))


def _assure_order_book_id(order_book_id: String) raises -> String:
    if order_book_id.find(".") == -1:
        raise Error("invalid order_book_id: " + order_book_id)
    return order_book_id


def _get_rqdatac() raises -> PythonObject:
    try:
        return Python.import_module("rqdatac")
    except e:
        var dummy = Python.evaluate(
            "type('Dummy', (), {"
            "'__getattr__': lambda s, a: s, "
            "'__call__': lambda *a, **k: (_ for _ in ()).throw(RuntimeError('rqdatac unavailable'))"
            "})()"
        )
        return dummy


def _trading_dt_yesterday(mut env: Environment) raises -> PythonObject:
    var dt = env.trading_dt()
    var dm = Python.import_module("datetime")
    var py_date = dm.date(dt.year, dt.month, dt.day)
    var timedelta = dm.timedelta(days=1)
    return py_date - timedelta


def _calendar_dt_date(env: Environment) raises -> PythonObject:
    var dt = env.calendar_dt()
    var dm = Python.import_module("datetime")
    return dm.date(dt.year, dt.month, dt.day)


def _calendar_dt_datetime(env: Environment) raises -> PythonObject:
    var dt = env.calendar_dt()
    var dm = Python.import_module("datetime")
    return dm.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)


def _trading_dt_datetime(mut env: Environment) raises -> PythonObject:
    var dt = env.trading_dt()
    var dm = Python.import_module("datetime")
    return dm.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)


def _is_string(val: PythonObject) raises -> Bool:
    return Bool(py=val.__class__.__name__ == "str")


def _is_list(val: PythonObject) raises -> Bool:
    return Bool(py=val.__class__.__name__ == "list")


def _get_nth_previous_trading_date(mut env: Environment, dt: DateTime, n: Int) raises -> PythonObject:
    var cur = dt
    for _ in range(n):
        cur = env.data_proxy().get_previous_trading_date(cur)
    return _to_py_date(cur)


def get_split(mut env: Environment, order_book_ids_in: PythonObject, start_date: PythonObject) raises -> PythonObject:
    """
    Get stock split information up to strategy previous trading day.
    """
    var rqdatac = _get_rqdatac()
    var yesterday = _trading_dt_yesterday(env)
    var sd = _to_date(start_date)
    if sd > yesterday:
        raise Error("in get_split, start_date is no earlier than previous test day")
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = Python.list(order_book_ids_in)
    else:
        order_book_ids = order_book_ids_in
    var validated = Python.list()
    for i in range(len(order_book_ids)):
        var obid = String(py=order_book_ids[i])
        validated.append(_assure_order_book_id(obid))
    return rqdatac.get_split(validated, sd, yesterday)


def index_components(mut env: Environment, order_book_id: String, date: Optional[PythonObject] = None) raises -> List[String]:
    """
    Get index component stocks list.
    """
    var rqdatac = _get_rqdatac()
    var dt = _calendar_dt_date(env)
    var query_date: PythonObject
    if date is None:
        query_date = dt
    else:
        query_date = _to_date(date.value())
        if query_date > dt:
            raise Error("in index_components, date is no earlier than test date")
    var obid = _assure_order_book_id(order_book_id)
    var result = rqdatac.index_components(obid, date=query_date)
    var mojo_list = List[String]()
    for i in range(len(result)):
        mojo_list.append(String(py=result[i]))
    return mojo_list^


def index_weights(mut env: Environment, order_book_id: String, date: Optional[PythonObject] = None) raises -> PythonObject:
    """
    Get T-1 index weights.
    """
    var rqdatac = _get_rqdatac()
    var prev_trading = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var dt_obj = _to_py_date(prev_trading)
    var query_date: PythonObject
    if date is None:
        query_date = dt_obj
    else:
        query_date = _to_date(date.value())
        if query_date > dt_obj:
            raise Error("in index_weights, date is no earlier than previous test day")
    var obid = _assure_order_book_id(order_book_id)
    return rqdatac.index_weights(obid, query_date)


def concept(mut env: Environment, concept_names: List[String]) raises -> List[String]:
    """
    Get concept stock list for given concept name(s).
    """
    var rqdatac = _get_rqdatac()
    var dt = _calendar_dt_date(env)
    if len(concept_names) == 0:
        return List[String]()
    var result: PythonObject
    if len(concept_names) == 1:
        result = rqdatac.concept(concept_names[0], date=dt)
    elif len(concept_names) == 2:
        result = rqdatac.concept(concept_names[0], concept_names[1], date=dt)
    elif len(concept_names) == 3:
        result = rqdatac.concept(concept_names[0], concept_names[1], concept_names[2], date=dt)
    elif len(concept_names) == 4:
        result = rqdatac.concept(concept_names[0], concept_names[1], concept_names[2], concept_names[3], date=dt)
    else:
        var py_names = Python.list()
        for i in range(len(concept_names)):
            py_names.append(concept_names[i])
        result = Python.evaluate("_f(*_a, **_k)").__call__(
            _bi().dict(_f=rqdatac.concept, _a=py_names, _k=_bi().dict(date=dt))
        )
    var mojo_list = List[String]()
    for i in range(len(result)):
        mojo_list.append(String(py=result[i]))
    return mojo_list^


def get_margin_stocks(
    mut env: Environment,
    exchange: Optional[String] = None,
    margin_type: String = "all"
) raises -> List[String]:
    """
    Get margin trading stocks list for a specific exchange.
    """
    var rqdatac = _get_rqdatac()
    var trade_dt = _trading_dt_yesterday(env)
    var symbols_py = Python.list()
    var exchange_str: String
    if exchange is not None:
        exchange_str = exchange.value()
    else:
        exchange_str = ""
    if margin_type == "all":
        symbols_py.extend(rqdatac.get_margin_stocks(trade_dt, exchange_str, margin_type="stock", market="cn"))
        symbols_py.extend(rqdatac.get_margin_stocks(trade_dt, exchange_str, margin_type="cash", market="cn"))
    elif margin_type == "cash" or margin_type == "stock":
        symbols_py.extend(rqdatac.get_margin_stocks(trade_dt, exchange_str, margin_type=margin_type, market="cn"))
    else:
        raise Error("MarginComponentValidator margin_type value error, got " + margin_type)
    var unique_set = _py_set(symbols_py)
    var result = List[String]()
    for item in unique_set:
        result.append(String(py=item))
    return result^


def get_price(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    start_date: PythonObject,
    end_date: Optional[PythonObject] = None,
    frequency: String = "1d",
    fields: Optional[PythonObject] = None,
    adjust_type: String = "pre",
    skip_suspended: Bool = False,
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Get historical price data for contract(s).
    """
    var rqdatac = _get_rqdatac()
    var yesterday = _trading_dt_yesterday(env)
    var ed: PythonObject
    if end_date is not None:
        ed = _to_date(end_date.value())
        if ed > yesterday:
            raise Error("in get_price, end_date is no earlier than previous test day")
    else:
        ed = yesterday
    var sd = _to_date(start_date)
    if sd > yesterday:
        raise Error("in get_price, start_date is no earlier than previous test day")
    if sd > ed:
        raise Error("in get_price, start_date > end_date")
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = _assure_order_book_id(String(py=order_book_ids_in))
    else:
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            validated.append(_assure_order_book_id(String(py=order_book_ids_in[i])))
        order_book_ids = validated
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
    else:
        fields_arg = Python.none()
    return rqdatac.get_price(
        order_book_ids, sd, ed,
        frequency=frequency, fields=fields_arg,
        adjust_type=adjust_type,
        skip_suspended=skip_suspended,
        expect_df=expect_df
    )


def get_securities_margin(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    count: Int = 1,
    fields: Optional[PythonObject] = None,
    expect_df: Bool = True
) raises -> PythonObject:
    """
    Get securities margin trading information.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var start_dt: PythonObject
    if count == 1:
        start_dt = _to_py_date(prev_dt)
    else:
        start_dt = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    var _overall_codes = ["XSHG", "XSHE", "sh", "sz"]
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        var obid_str = String(py=order_book_ids_in)
        if obid_str != "XSHG" and obid_str != "XSHE" and obid_str != "sh" and obid_str != "sz":
            order_book_ids = _assure_order_book_id(obid_str)
        else:
            order_book_ids = order_book_ids_in
    else:
        var overall_keep = Python.list()
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            var s = String(py=order_book_ids_in[i])
            if s == "XSHG" or s == "XSHE" or s == "sh" or s == "sz":
                overall_keep.append(s)
            else:
                validated.append(_assure_order_book_id(s))
        order_book_ids = validated
        for j in range(len(overall_keep)):
            order_book_ids.append(overall_keep[j])
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
    else:
        fields_arg = Python.none()
    return rqdatac.get_securities_margin(order_book_ids, start_dt, _to_py_date(prev_dt), fields=fields_arg, expect_df=expect_df)


def get_shares(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    count: Int = 1,
    fields: Optional[PythonObject] = None,
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Get share structure data (total shares, circulation_a, etc.).
    """
    var rqdatac = _get_rqdatac()
    var dt = env.trading_dt()
    var dt_py = _to_py_datetime(dt)
    var start_dt: PythonObject
    if count == 1:
        start_dt = dt_py
    else:
        var prev = env.data_proxy().get_previous_trading_date(dt)
        start_dt = _get_nth_previous_trading_date(env, prev, count - 1)
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = _assure_order_book_id(String(py=order_book_ids_in))
    else:
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            validated.append(_assure_order_book_id(String(py=order_book_ids_in[i])))
        order_book_ids = validated
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
    else:
        fields_arg = Python.none()
    return rqdatac.get_shares(order_book_ids, start_dt, dt_py, fields=fields_arg, expect_df=expect_df)


def get_turnover_rate(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    count: Int = 1,
    fields: Optional[PythonObject] = None,
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Get turnover rate data up to T-1.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var start_dt: PythonObject
    if count == 1:
        start_dt = _to_py_date(prev_dt)
    else:
        start_dt = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = _assure_order_book_id(String(py=order_book_ids_in))
    else:
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            validated.append(_assure_order_book_id(String(py=order_book_ids_in[i])))
        order_book_ids = validated
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
    else:
        fields_arg = Python.none()
    return rqdatac.get_turnover_rate(order_book_ids, start_dt, _to_py_date(prev_dt), fields=fields_arg, expect_df=expect_df)


def get_price_change_rate(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    count: Int = 1,
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Get daily price change rate up to T-1.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = _assure_order_book_id(String(py=order_book_ids_in))
    else:
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            validated.append(_assure_order_book_id(String(py=order_book_ids_in[i])))
        order_book_ids = validated
    var end_date = _to_py_date(prev_dt)
    var start_date: PythonObject
    if count == 1:
        start_date = end_date
    else:
        start_date = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    return rqdatac.get_price_change_rate(order_book_ids, start_date, end_date, expect_df=expect_df)


def get_factor(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    factors: PythonObject,
    count: Int = 1,
    universe: Optional[PythonObject] = None,
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Get factor data up to T-1.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var start_date: PythonObject
    if count == 1:
        start_date = _to_py_date(prev_dt)
    else:
        start_date = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = _assure_order_book_id(String(py=order_book_ids_in))
    else:
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            validated.append(_assure_order_book_id(String(py=order_book_ids_in[i])))
        order_book_ids = validated
    var universe_arg: PythonObject
    if universe is not None:
        universe_arg = universe.value()
    else:
        universe_arg = Python.none()
    return rqdatac.get_factor(
        order_book_ids, factors,
        start_date=start_date, end_date=_to_py_date(prev_dt),
        universe=universe_arg, expect_df=expect_df
    )


def get_industry(mut env: Environment, industry_name: String, source: String = "citics") raises -> List[String]:
    """
    Get industry stock list by industry name/code.
    """
    var rqdatac = _get_rqdatac()
    var cal_py = _calendar_dt_datetime(env)
    var result = rqdatac.get_industry(industry_name, source, cal_py)
    var mojo_list = List[String]()
    for i in range(len(result)):
        mojo_list.append(String(py=result[i]))
    return mojo_list^


def get_instrument_industry(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    source: String = "citics",
    level: Int = 1
) raises -> PythonObject:
    """
    Get instrument industry classification at T day.
    """
    var rqdatac = _get_rqdatac()
    var cal_py = _calendar_dt_datetime(env)
    var order_book_ids: PythonObject
    if _is_string(order_book_ids_in):
        order_book_ids = _assure_order_book_id(String(py=order_book_ids_in))
    else:
        var validated = Python.list()
        for i in range(len(order_book_ids_in)):
            validated.append(_assure_order_book_id(String(py=order_book_ids_in[i])))
        order_book_ids = validated
    return rqdatac.get_instrument_industry(order_book_ids, source, level, cal_py)


def get_stock_connect(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    count: Int = 1,
    fields: Optional[PythonObject] = None,
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Get A-share stock connect holdings up to T-1.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var start_date: PythonObject
    if count == 1:
        start_date = _to_py_date(prev_dt)
    else:
        start_date = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
    else:
        fields_arg = Python.none()
    return rqdatac.get_stock_connect(order_book_ids_in, start_date, _to_py_date(prev_dt), fields=fields_arg, expect_df=expect_df)


def current_performance(
    mut env: Environment,
    order_book_id: String,
    info_date: Optional[PythonObject] = None,
    quarter: Optional[String] = None,
    interval: String = "1q",
    fields: Optional[PythonObject] = None
) raises -> PythonObject:
    """
    Get latest performance snapshot for an instrument.
    """
    var rqdatac = _get_rqdatac()
    var dt_py = _trading_dt_datetime(env)
    var actual_info_date: PythonObject
    if info_date is None and quarter is None:
        actual_info_date = dt_py
    elif info_date is not None:
        actual_info_date = info_date.value()
    else:
        actual_info_date = Python.none()
    var actual_quarter: PythonObject
    if quarter is not None:
        actual_quarter = PythonObject(quarter.value())
    else:
        actual_quarter = Python.none()
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
    else:
        fields_arg = Python.none()
    return rqdatac.current_performance(order_book_id, actual_info_date, actual_quarter, interval, fields_arg)


def get_dominant_future(mut env: Environment, underlying_symbol: String, rule: Int = 0) raises -> Optional[String]:
    """
    Get dominant future contract code for a futures product.
    """
    var rqdatac = _get_rqdatac()
    var pd_mod = Python.import_module("pandas")
    var trade_dt = env.trading_dt()
    var dt_py = _to_py_date(trade_dt)
    var ret = rqdatac.get_dominant_future(underlying_symbol, dt_py, dt_py, rule)
    if _py_isinstance(ret, "Series") and Int(py=ret.size()) == 1:
        return Optional[String](String(py=ret.item()))
    else:
        return Optional[String](None)


def econ_get_reserve_ratio(reserve_type: String = "all", n: Int = 1) raises -> Optional[PythonObject]:
    """
    Get deposit reserve ratio up to T day.
    """
    var rqdatac = _get_rqdatac()
    var df = rqdatac.econ.get_reserve_ratio(reserve_type)
    if df is Python.none() or (_py_hasattr(df, "empty") and Bool(py=df.empty)):
        return Optional[PythonObject](None)
    df.sort_values(by=["effective_date", "reserve_type"], ascending=[False, True], inplace=True)
    var effective_dates = df["effective_date"].unique()
    if Int(py=len(effective_dates)) <= n:
        return Optional[PythonObject](df)
    var filtered = df[df["effective_date"] >= effective_dates[n - 1]]
    return Optional[PythonObject](filtered)


def econ_get_money_supply(n: Int = 1) raises -> Optional[PythonObject]:
    """
    Get money supply indicators up to T day.
    """
    var rqdatac = _get_rqdatac()
    var start_int = 19780101
    var end_int = 10000 * 2025 + 100 * 4 + 20
    var df = rqdatac.econ.get_money_supply(start_int, end_int)
    if df is Python.none() or (_py_hasattr(df, "empty") and Bool(py=df.empty)):
        return Optional[PythonObject](None)
    df.sort_index(ascending=False, inplace=True)
    var head_df = df.head(n)
    return Optional[PythonObject](head_df)


def futures_get_dominant(mut env: Environment, underlying_symbol: String, rule: Int = 0) raises -> Optional[String]:
    """
    Get dominant future contract via futures submodule.
    """
    var rqdatac = _get_rqdatac()
    var trade_dt = env.trading_dt()
    var dt_py = _to_py_date(trade_dt)
    var ret = rqdatac.futures.get_dominant(underlying_symbol, dt_py, dt_py, rule)
    if ret is Python.none() or (_py_hasattr(ret, "empty") and Bool(py=ret.empty)):
        return Optional[String](None)
    return Optional[String](String(py=ret.item()))


def futures_get_member_rank(
    mut env: Environment,
    which: String,
    count: Int = 1,
    rank_by: String = "short"
) raises -> PythonObject:
    """
    Get futures member ranking up to T-1.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var start_date: PythonObject
    if count == 1:
        start_date = _to_py_date(prev_dt)
    else:
        start_date = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    return rqdatac.futures.get_member_rank(which, start_date=start_date, end_date=_to_py_date(prev_dt), rank_by=rank_by)


def futures_get_warehouse_stocks(
    mut env: Environment,
    underlying_symbols: PythonObject,
    count: Int = 1
) raises -> PythonObject:
    """
    Get futures warehouse receipt data up to T-1.
    """
    var rqdatac = _get_rqdatac()
    var prev_dt = env.data_proxy().get_previous_trading_date(env.trading_dt())
    var start_date: PythonObject
    if count == 1:
        start_date = _to_py_date(prev_dt)
    else:
        start_date = _get_nth_previous_trading_date(env, prev_dt, count - 1)
    return rqdatac.futures.get_warehouse_stocks(underlying_symbols, start_date=start_date, end_date=_to_py_date(prev_dt))


def futures_get_dominant_price(
    mut env: Environment,
    underlying_symbols_in: PythonObject,
    start_date: Optional[PythonObject] = None,
    end_date: Optional[PythonObject] = None,
    frequency: String = "1d",
    fields: Optional[PythonObject] = None,
    adjust_type: String = "pre",
    adjust_method: String = "prev_close_spread"
) raises -> Optional[PythonObject]:
    """
    Get dominant future contract price data with adjustment.
    """
    var rqdatac = _get_rqdatac()
    var pd_mod = Python.import_module("pandas")
    var dm = Python.import_module("datetime")
    var trade_dt = env.trading_dt()
    var trade_dt_py = _to_py_datetime(trade_dt)
    var underlying_symbols: PythonObject
    var has_len_attr = _py_getattr(underlying_symbols_in, "__len__")
    if has_len_attr is Python.none():
        underlying_symbols = Python.list(underlying_symbols_in)
    else:
        underlying_symbols = underlying_symbols_in
    var fields_arg: PythonObject
    if fields is not None:
        fields_arg = fields.value()
        var flen_attr = _py_getattr(fields_arg, "__len__")
        if flen_attr is Python.none():
            fields_arg = Python.list(fields_arg)
    else:
        fields_arg = Python.none()
    var ed: PythonObject
    if end_date is not None:
        ed = pd_mod.to_datetime(end_date.value())
    else:
        ed = trade_dt_py
    var sd: PythonObject
    if start_date is not None:
        sd = pd_mod.to_datetime(start_date.value())
    else:
        var td = dm.timedelta(days=3)
        sd = ed - td
    if sd > ed:
        raise Error("in futures.get_dominant_price, start_date > end_date")
    if ed > trade_dt_py:
        raise Error("in futures.get_dominant_price, end_date > trading day")
    if adjust_type != "none" and adjust_type != "pre" and adjust_type != "post":
        raise Error("invalid adjust_type: " + adjust_type)
    if adjust_method != "prev_close_spread" and adjust_method != "open_spread" and adjust_method != "prev_close_ratio" and adjust_method != "open_ratio":
        raise Error("invalid adjust_method: " + adjust_method)
    var obs = Python.list()
    for i in range(len(underlying_symbols)):
        var u = String(py=underlying_symbols[i]) + "88"
        obs.append(u)
    var date_key: String
    if frequency == "1d":
        date_key = "date"
    else:
        date_key = "trading_date"
    var _fields = fields_arg
    var fields_not_none = not Bool(py=_bi().is_(fields_arg, Python.none()))
    if fields_not_none and frequency != "1d":
        var has_td = False
        var flen = Int(py=len(_fields))
        for f_idx in range(flen):
            if String(py=_fields[f_idx]) == "trading_date":
                has_td = True
        if not has_td:
            new_fields = Python.list()
            new_fields.append("trading_date")
            for f_idx2 in range(flen):
                new_fields.append(_fields[f_idx2])
            _fields = new_fields
    var df = rqdatac.get_price(
        order_book_ids=obs, start_date=sd, end_date=ed,
        frequency=frequency, adjust_type="none",
        fields=_fields, expect_df=True
    )
    if df is Python.none():
        return Optional[PythonObject](None)
    df.reset_index(inplace=True)
    var order_book_id_col = df["order_book_id"]
    var sliced = order_book_id_col.str[:-2]
    _py_setitem(df, "underlying_symbol", sliced)
    var idx_cols = Python.list()
    idx_cols.append("underlying_symbol")
    idx_cols.append(date_key)
    df = df.set_index(idx_cols)
    if adjust_type != "none":
        var env_dt_py = _to_py_date(trade_dt)
        var factor = _get_ex_factor(underlying_symbols, adjust_type, adjust_method, env_dt_py)
        factor = factor.reindex(factor.index.union(df.index.unique())).groupby(level=0).ffill()
        var values = factor.loc[df.index].values
        var _fields_for_adj: PythonObject
        if fields_not_none:
            _fields_for_adj = fields_arg
        else:
            _fields_for_adj = df.columns.tolist()
        var adjust_field_names = ["open", "high", "low", "close", "last", "limit_up", "limit_down",
                                  "settlement", "prev_settlement", "prev_close",
                                  "a1", "a2", "a3", "a4", "a5", "b1", "b2", "b3", "b4", "b5"]
        var adj_fields = Python.list()
        var fflen = Int(py=len(_fields_for_adj))
        for af_i in range(fflen):
            var af_name = String(py=_fields_for_adj[af_i])
            var found = False
            for n_idx in range(len(adjust_field_names)):
                if af_name == adjust_field_names[n_idx]:
                    found = True
                    break
            if found:
                adj_fields.append(af_name)
        if adjust_method.endswith("spread"):
            for af_j in range(len(adj_fields)):
                var field_name = String(py=adj_fields[af_j])
                var col = df[field_name]
                _py_setitem(df, field_name, col + values)
        elif adjust_method.endswith("ratio"):
            for af_k in range(len(adj_fields)):
                var field_name2 = String(py=adj_fields[af_k])
                var col2 = df[field_name2]
                _py_setitem(df, field_name2, col2 * values)
        var col_names = df.columns.tolist()
        var has_turnover = False
        for cn_i in range(len(col_names)):
            if String(py=col_names[cn_i]) == "total_turnover":
                has_turnover = True
                break
        if has_turnover:
            _py_setitem(df, "total_turnover", 0)
    if frequency != "1d":
        var ri = df.reset_index()
        var dt_idx_cols = Python.list()
        dt_idx_cols.append("underlying_symbol")
        dt_idx_cols.append("datetime")
        df = ri.set_index(dt_idx_cols)
    df.sort_index(inplace=True)
    df = df.drop(labels=["order_book_id"], axis=0, errors="ignore")
    if fields_not_none:
        return Optional[PythonObject](df[fields_arg])
    else:
        return Optional[PythonObject](df)


def _get_ex_factor(
    underlying_symbols: PythonObject,
    adjust_type: String,
    adjust_method: String,
    adjust_date: PythonObject
) raises -> PythonObject:
    """Compute ex-factor for futures dominant price adjustment."""
    var rqdatac = _get_rqdatac()
    var future_factors_mod = Python.import_module("rqdatac.services.future")
    var get_future_factors_df = _py_getattr(future_factors_mod, "_get_future_factors_df")
    var df = get_future_factors_df().loc[underlying_symbols].reset_index()
    var need_cols = Python.list()
    need_cols.append("underlying_symbol")
    need_cols.append("ex_date")
    need_cols.append("ex_factor")
    var factor_df = df[df["ex_date"] <= adjust_date][need_cols]
    var pre = adjust_type == "pre"
    var ratio = adjust_method.endswith("ratio")
    var factor: PythonObject

    if ratio:
        if pre:
            var lambda_fn = Python.evaluate(
                "lambda x: (x.__setitem__('ex_cum_factor', x['ex_factor'].cumprod() / x['ex_factor'].cumprod().iloc[-1]), x.set_index('ex_date'))[1]"
            )
            factor = factor_df.groupby("underlying_symbol", as_index=True).apply(lambda_fn)
        else:
            var lambda_fn2 = Python.evaluate(
                "lambda x: (x.__setitem__('ex_cum_factor', x['ex_factor'].cumprod()), x.set_index('ex_date'))[1]"
            )
            factor = factor_df.groupby("underlying_symbol", as_index=True).apply(lambda_fn2)
    else:
        if pre:
            var lambda_fn3 = Python.evaluate(
                "lambda x: (x.__setitem__('ex_cum_factor', x['ex_factor'].cumsum() - x['ex_factor'].cumsum().iloc[-1]), x.set_index('ex_date'))[1]"
            )
            factor = factor_df.groupby("underlying_symbol", as_index=True).apply(lambda_fn3)
        else:
            var lambda_fn4 = Python.evaluate(
                "lambda x: (x.__setitem__('ex_cum_factor', x['ex_factor'].cumsum()), x.set_index('ex_date'))[1]"
            )
            factor = factor_df.groupby("underlying_symbol", as_index=True).apply(lambda_fn4)
    return factor["ex_cum_factor"]


def get_fundamentals(
    mut env: Environment,
    query: PythonObject,
    entry_date: Optional[PythonObject] = None,
    interval: String = "1d",
    report_quarter: Bool = False,
    expect_df: Bool = False,
    kwargs_dict: Dict[String, PythonObject] = Dict[String, PythonObject]()
) raises -> PythonObject:
    """
    Deprecated: get fundamentals data. Use get_pit_financials_ex instead.
    """
    var rqdatac = _get_rqdatac()
    var pd_mod = Python.import_module("pandas")
    var dm = Python.import_module("datetime")
    var dt = env.calendar_dt()
    var dt_py = dm.date(dt.year, dt.month, dt.day)
    var latest_query_day = dt_py - dm.timedelta(days=1)
    var query_date: PythonObject
    if entry_date is not None:
        var ed_parsed = _to_date(entry_date.value())
        if ed_parsed <= latest_query_day:
            query_date = ed_parsed
        else:
            raise Error("in get_fundamentals entry_date is no earlier than test date")
    else:
        query_date = latest_query_day
    var result = rqdatac.get_fundamentals(query, query_date, interval, report_quarter=report_quarter, expect_df=expect_df)
    if result is Python.none():
        var empty_df = Python.evaluate("import pandas as pd; pd.DataFrame()")
        return empty_df
    if expect_df:
        return result
    var major_axis_len = Int(py=len(result.major_axis))
    if major_axis_len == 1:
        var frame = result.major_xs(result.major_axis[0])
        return frame.T
    return result


def get_financials(
    mut env: Environment,
    query_obj: PythonObject,
    quarter: Optional[String] = None,
    interval: String = "4q",
    expect_df: Bool = False
) raises -> PythonObject:
    """
    Deprecated: get financials data. Use get_pit_financials_ex instead.
    """
    var rqdatac = _get_rqdatac()
    var pd_mod = Python.import_module("pandas")
    var dm = Python.import_module("datetime")
    var dt = env.calendar_dt()
    var dt_date = dm.date(dt.year, dt.month, dt.day) - dm.timedelta(days=1)
    var year = Int(py=dt_date.year)
    var mon = Int(py=dt_date.month)
    var q = (mon - 4) // 3 + 1
    var y = year
    if q <= 0:
        y -= 1
        q = 4
    var default_quarter = String(py=_py_str(y)) + "q" + String(py=_py_str(q))

    var valid_quarter = True
    var actual_quarter: String
    if quarter is not None:
        var qstr = quarter.value()
        valid_quarter = _py_isinstance(qstr, "str") and len(qstr) >= 2 and _str_slice(qstr, len(qstr) - 2, len(qstr)) == "q"
        if valid_quarter:
            try:
                var prefix = _str_slice(qstr, 0, len(qstr) - 2)
                var suffix_char = _str_slice(qstr, len(qstr) - 2, len(qstr))
                var suffix_q = _str_slice(suffix_char, 1, 2)
                var q_year = Int(py=_py_str(prefix))
                var q_num = Int(py=_py_str(suffix_q))
                valid_quarter = 1990 <= q_year <= 2050 and 1 <= q_num <= 4
            except e:
                valid_quarter = False
        actual_quarter = qstr
    else:
        actual_quarter = default_quarter
    if not valid_quarter:
        raise Error("function get_financials: invalid quarter argument, should be in form of '2012q3'")
    if quarter is None or actual_quarter > default_quarter:
        actual_quarter = default_quarter
    var include_date = False
    var col_descs = query_obj.column_descriptions
    for d_i in range(len(col_descs)):
        var cd = col_descs[d_i]
        if String(py=cd["name"]) == "announce_date":
            include_date = True
    var int_date = year * 10000 + mon * 100 + Int(py=dt_date.day)
    var result: PythonObject
    if not include_date:
        var q2 = query_obj.add_column(rqdatac.fundamentals.announce_date)
        result = rqdatac.get_financials(q2, actual_quarter, interval, expect_df=expect_df)
    else:
        result = rqdatac.get_financials(query_obj, actual_quarter, interval, expect_df=expect_df)
    if result is Python.none():
        return pd_mod.DataFrame()
    if _py_isinstance(result, "Series"):
        return result
    elif _py_isinstance(result, "DataFrame"):
        var mask = (result["announce_date"] <= int_date) | pd_mod.isnull(result["announce_date"])
        result = result[mask]
        if not include_date:
            result = result.drop(labels=["announce_date"], axis=1)
    else:
        var panel_dict = Python.dict()
        var minor_axis = result.minor_axis
        for m_i in range(len(minor_axis)):
            var obid = minor_axis[m_i]
            var sub_df = result.minor_xs(obid)
            var sub_mask = (sub_df.announce_date < int_date) | (pd_mod.isnull(sub_df.announce_date))
            sub_df = sub_df[sub_mask]
            Python.evaluate("_d[_k] = _v").__call__(_bi().dict(_d=panel_dict, _k=obid, _v=sub_df))
        var pl = pd_mod.Panel.from_dict(panel_dict, orient="minor")
        if not include_date:
            pl = pl.drop(labels=["announce_date"], axis=0, inplace=False)
            if Int(py=len(pl.items)) == 1:
                pl = pl[pl.items[0]]
        return pl
    return result


def get_pit_financials(
    mut env: Environment,
    fields: PythonObject,
    quarter: Optional[String] = None,
    interval: Optional[String] = None,
    order_book_ids: Optional[PythonObject] = None,
    if_adjusted: String = "all"
) raises -> PythonObject:
    """
    Get point-in-time financial data.
    """
    var rqdatac = _get_rqdatac()
    var pd_mod = Python.import_module("pandas")
    var dm = Python.import_module("datetime")
    var dt = env.calendar_dt()
    var dt_date = dm.date(dt.year, dt.month, dt.day)
    var year = Int(py=dt_date.year)
    var mon = Int(py=dt_date.month)
    var day = Int(py=dt_date.day)
    var int_date = year * 10000 + mon * 100 + day
    var q = (mon - 4) // 3 + 1
    var y = year
    if q <= 0:
        y -= 1
        q = 4
    var default_quarter = String(py=_py_str(y)) + "q" + String(py=_py_str(q))
    var valid_quarter = True
    var actual_quarter: String
    if quarter is not None:
        var qstr = quarter.value()
        valid_quarter = _py_isinstance(qstr, "str") and len(qstr) >= 2 and _str_slice(qstr, len(qstr) - 2, len(qstr)) == "q"
        if valid_quarter:
            try:
                var prefix2 = _str_slice(qstr, 0, len(qstr) - 2)
                var suffix_char2 = _str_slice(qstr, len(qstr) - 2, len(qstr))
                var suffix_q2 = _str_slice(suffix_char2, 1, 2)
                var q_year2 = Int(py=_py_str(prefix2))
                var q_num2 = Int(py=_py_str(suffix_q2))
                valid_quarter = 1990 <= q_year2 <= 2050 and 1 <= q_num2 <= 4
            except e:
                valid_quarter = False
        actual_quarter = qstr
    else:
        actual_quarter = default_quarter
    if not valid_quarter:
        raise Error("function get_pit_financials: invalid quarter argument, should be in form of '2012q3'")
    if quarter is None or actual_quarter > default_quarter:
        actual_quarter = default_quarter
    var obids_arg: PythonObject
    if order_book_ids is not None:
        obids_arg = order_book_ids.value()
    else:
        obids_arg = Python.none()
    var interval_arg: PythonObject
    if interval is not None:
        interval_arg = interval.value()
    else:
        interval_arg = Python.none()
    var result = rqdatac.get_pit_financials(
        fields, actual_quarter, interval_arg, obids_arg, if_adjusted,
        max_info_date=int_date, market="cn"
    )
    if result is Python.none():
        return pd_mod.DataFrame()
    if if_adjusted == "ignore":
        result = result.reset_index().sort_values("info_date")
        var gb_fn = Python.evaluate("lambda df: df.groupby(['order_book_id', 'end_date'], as_index=False).apply(lambda g: g.fillna(method='ffill')).reset_index(drop=True)")
        result = gb_fn(result)
        var drop_cols = Python.list()
        drop_cols.append("info_date")
        drop_cols.append("if_adjusted")
        result = result.drop(columns=drop_cols)
        var dd_subset = Python.list()
        dd_subset.append("order_book_id")
        dd_subset.append("end_date")
        result = result.drop_duplicates(subset=dd_subset, keep="last")
        var si_cols = Python.list()
        si_cols.append("order_book_id")
        si_cols.append("end_date")
        result = result.set_index(si_cols).sort_index()
    return result


def get_pit_financials_ex(
    mut env: Environment,
    order_book_ids_in: PythonObject,
    fields: PythonObject,
    count: Int,
    statements: String = "latest"
) raises -> Optional[PythonObject]:
    """
    Get quarterly fundamental data (income statement, balance sheet, cash flow).
    """
    var rqdatac = _get_rqdatac()
    var pd_mod = Python.import_module("pandas")
    var dm = Python.import_module("datetime")
    var order_book_ids: PythonObject
    if _py_isinstance(order_book_ids_in, "str"):
        order_book_ids = Python.list(order_book_ids_in)
    else:
        order_book_ids = order_book_ids_in
    if count < 0:
        return Optional[PythonObject](None)
    var cal_dt = env.calendar_dt()
    var cal_dt_py = dm.date(cal_dt.year, cal_dt.month, cal_dt.day)
    var active_list = Python.list()
    var de_listed_obids = Python.list()
    var de_listed_dates = Python.list()
    for i in range(len(order_book_ids)):
        var obid = String(py=order_book_ids[i])
        var ins = env.get_instrument(obid)
        if cal_dt.toordinal() > ins.de_listed_date().toordinal():
            de_listed_obids.append(obid)
            var ins_dld = ins.de_listed_date()
            de_listed_dates.append(_to_py_date(ins_dld))
        else:
            active_list.append(obid)
    var adjusted_count = count + 1

    def _get_data(
        symbol_list: PythonObject,
        start_dt_py: PythonObject,
        end_dt_py: PythonObject
    ) raises -> PythonObject:
        var sdt_year = Int(py=start_dt_py.year)
        var sdt_mon = Int(py=start_dt_py.month)
        var sq = (sdt_mon - 4) // 3 + 1
        var sy = sdt_year
        if sq <= 0:
            sy -= 1
            sq = 4
        var end_quarter = String(py=_py_str(sy)) + "q" + String(py=_py_str(sq))
        var ey_int = sy * 4 + sq
        var start_q_int = ey_int - adjusted_count - 4
        var start_sy2 = start_q_int // 4
        var start_sq2 = start_q_int % 4 + 1
        var start_quarter = String(py=_py_str(start_sy2)) + "q" + String(py=_py_str(start_sq2))
        if start_quarter > end_quarter:
            start_quarter = end_quarter
        return rqdatac.get_pit_financials_ex(
            fields=fields, start_quarter=start_quarter, end_quarter=end_quarter,
            order_book_ids=symbol_list, statements=statements, market="cn",
            date=end_dt_py
        )

    var result_list = Python.list()
    if len(active_list) > 0:
        var result = _get_data(active_list, cal_dt_py, cal_dt_py)
        if _py_isinstance(result, "DataFrame"):
            var grouped = result.groupby("order_book_id")
            var group_keys = grouped.groups
            for group_key in group_keys:
                var group_df = grouped.get_group(group_key)
                var glen = Int(py=len(group_df))
                var iloc_count = min(glen, adjusted_count)
                var sliced_df = group_df.iloc[-iloc_count:]
                result_list.append(sliced_df)
    for di in range(len(de_listed_obids)):
        var ins_obid = de_listed_obids[di]
        var ins_dld_py = de_listed_dates[di]
        var de_result = _get_data(Python.list(ins_obid), ins_dld_py, ins_dld_py)
        if _py_isinstance(de_result, "DataFrame"):
            var de_glen = Int(py=len(de_result))
            var de_iloc_count = min(de_glen, adjusted_count)
            result_list.append(de_result.iloc[-de_iloc_count:])
    if Int(py=len(result_list)) > 0:
        return Optional[PythonObject](pd_mod.concat(result_list))
    else:
        return Optional[PythonObject](None)


def query(entities: PythonObject) raises -> PythonObject:
    """
    Query entities from rqdatac.
    """
    var rqdatac = _get_rqdatac()
    var bi = _bi()
    return Python.evaluate("_f(*_a)").__call__(bi.dict(_f=rqdatac.query, _a=entities))
