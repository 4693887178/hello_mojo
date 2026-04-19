"""
RQAlpha Mojo - Bundle Data Management
Ported from rqalpha/data/bundle.py

Design Notes:
  - Uses composition instead of inheritance (Mojo limitation)
  - Data generation functions use Python interop for rqdatac/h5py
  - AutomaticUpdateBundle maintains same interface as original
  - Task system uses Python objects to avoid type conversion issues
"""

from std.collections import Dict, List
from std.python import Python, PythonObject
from std.os import path as os_path
from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime, DateTimeDate


comptime START_DATE: Int = 20050104
comptime END_DATE: Int = 29991231

comptime CORPORATE_ACTION_EXCLUSIONS_0 = "Future"
comptime CORPORATE_ACTION_EXCLUSIONS_1 = "Option"
comptime CORPORATE_ACTION_EXCLUSIONS_2 = "Spot"

comptime STOCK_FIELDS_0 = "open"
comptime STOCK_FIELDS_1 = "close"
comptime STOCK_FIELDS_2 = "high"
comptime STOCK_FIELDS_3 = "low"
comptime STOCK_FIELDS_4 = "prev_close"
comptime STOCK_FIELDS_5 = "limit_up"
comptime STOCK_FIELDS_6 = "limit_down"
comptime STOCK_FIELDS_7 = "volume"
comptime STOCK_FIELDS_8 = "total_turnover"

comptime INDEX_FIELDS_0 = "open"
comptime INDEX_FIELDS_1 = "close"
comptime INDEX_FIELDS_2 = "high"
comptime INDEX_FIELDS_3 = "low"
comptime INDEX_FIELDS_4 = "prev_close"
comptime INDEX_FIELDS_5 = "volume"
comptime INDEX_FIELDS_6 = "total_turnover"

comptime FUTURES_EXTRA_0 = "settlement"
comptime FUTURES_EXTRA_1 = "prev_settlement"
comptime FUTURES_EXTRA_2 = "open_interest"


def _get_stock_fields() raises -> PythonObject:
    return Python.list(STOCK_FIELDS_0, STOCK_FIELDS_1, STOCK_FIELDS_2, STOCK_FIELDS_3,
                       STOCK_FIELDS_4, STOCK_FIELDS_5, STOCK_FIELDS_6, STOCK_FIELDS_7, STOCK_FIELDS_8)

def _get_index_fields() raises -> PythonObject:
    return Python.list(INDEX_FIELDS_0, INDEX_FIELDS_1, INDEX_FIELDS_2, INDEX_FIELDS_3,
                       INDEX_FIELDS_4, INDEX_FIELDS_5, INDEX_FIELDS_6)

def _get_futures_fields() raises -> PythonObject:
    return Python.list(STOCK_FIELDS_0, STOCK_FIELDS_1, STOCK_FIELDS_2, STOCK_FIELDS_3,
                       STOCK_FIELDS_4, STOCK_FIELDS_5, STOCK_FIELDS_6, STOCK_FIELDS_7, STOCK_FIELDS_8,
                       FUTURES_EXTRA_0, FUTURES_EXTRA_1, FUTURES_EXTRA_2)


def _get_oids_with_corporate_action_exclusions() raises -> PythonObject:
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var ints = rqdatac.all_instruments()
    var exclusions_list = Python.list(CORPORATE_ACTION_EXCLUSIONS_0, CORPORATE_ACTION_EXCLUSIONS_1, CORPORATE_ACTION_EXCLUSIONS_2)
    ints = ints[~ints.type.isin(exclusions_list)]
    return ints.order_book_id.tolist()


def gen_instruments(d: String) raises:
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var stocks_py = rqdatac.all_instruments().order_book_id
    var instruments_py = rqdatac.instruments(stocks_py)
    var pickle_mod = Python.import_module("pickle")
    var builtins = Python.import_module("builtins")
    var file_path = os_path.join(d, "instruments.pk")
    var f_py = builtins.open(file_path, "wb")
    var instruments_list: PythonObject = []
    for i in instruments_py:
        instruments_list.append(i.__dict__)
    pickle_mod.dump(instruments_list, f_py, protocol=2)
    f_py.close()


def gen_yield_curve(d: String) raises:
    var datetime_mod = Python.import_module("datetime")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var yield_curve = rqdatac.get_yield_curve(start_date=START_DATE, end_date=datetime_mod.date.today())
    var index_py = yield_curve.index
    var converted_index_py: PythonObject
    converted_index_py = []
    for dt in index_py:
        var year = Int(py=dt.year)
        var month = Int(py=dt.month)
        var day = Int(py=dt.day)
        converted_index_py.append(year * 10000 + month * 100 + day)
    yield_curve.index = converted_index_py
    yield_curve.index.name = "date"
    var file_path = os_path.join(d, "yield_curve.h5")
    var h5 = h5py.File(file_path, "w")
    h5.create_dataset("data", data=yield_curve.to_records())
    h5.close()


def gen_trading_dates(d: String) raises:
    var numpy = Python.import_module("numpy")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var dates = rqdatac.get_trading_dates(start_date=START_DATE, end_date="2999-01-01")
    var converted_dates_py: PythonObject
    converted_dates_py = []
    for dt in dates:
        var year = Int(py=dt.year)
        var month = Int(py=dt.month)
        var day = Int(py=dt.day)
        converted_dates_py.append(year * 10000 + month * 100 + day)
    var arr = numpy.array(converted_dates_py)
    var file_path = os_path.join(d, "trading_dates.npy")
    numpy.save(file_path, arr, allow_pickle=False)


def gen_st_days(d: String) raises:
    var datetime_mod = Python.import_module("datetime")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var rqdatac_client = Python.import_module("rqdatac.client")
    var get_client_fn = rqdatac_client.get_client
    var stocks = rqdatac.all_instruments("CS").order_book_id.tolist()
    var today = datetime_mod.date.today()
    var today_int = Int(py=today.year) * 10000 + Int(py=today.month) * 100 + Int(py=today.day)
    var st_days = get_client_fn().execute("get_st_days", stocks, START_DATE, today_int)
    var file_path = os_path.join(d, "st_stock_days.h5")
    var h5 = h5py.File(file_path, "w")
    for order_book_id in st_days.keys():
        h5[order_book_id] = st_days[order_book_id]
    h5.close()


def gen_suspended_days(d: String) raises:
    var datetime_mod = Python.import_module("datetime")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var rqdatac_client = Python.import_module("rqdatac.client")
    var get_client_fn = rqdatac_client.get_client
    var stocks = rqdatac.all_instruments("CS").order_book_id.tolist()
    var today = datetime_mod.date.today()
    var today_int = Int(py=today.year) * 10000 + Int(py=today.month) * 100 + Int(py=today.day)
    var suspended_days = get_client_fn().execute("get_suspended_days", stocks, START_DATE, today_int)
    var file_path = os_path.join(d, "suspended_days.h5")
    var h5 = h5py.File(file_path, "w")
    for order_book_id in suspended_days.keys():
        h5[order_book_id] = suspended_days[order_book_id]
    h5.close()


def gen_dividend(d: String) raises:
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var order_book_ids = _get_oids_with_corporate_action_exclusions()
    var dividend = rqdatac.get_dividend(order_book_ids)
    if dividend is None:
        raise Error("Got no dividend data")
    var need_cols = Python.list(
        "dividend_cash_before_tax", "book_closure_date",
        "ex_dividend_date", "payable_date", "round_lot"
    )
    dividend = dividend[need_cols]
    dividend.reset_index(inplace=True)
    dividend.rename(columns={"declaration_announcement_date": "announcement_date"}, inplace=True)

    dividend["book_closure_date"] = _convert_dates_to_python(dividend["book_closure_date"], False)
    dividend["ex_dividend_date"] = _convert_dates_to_python(dividend["ex_dividend_date"], False)
    dividend["payable_date"] = _convert_dates_to_python(dividend["payable_date"], False)
    dividend["announcement_date"] = _convert_dates_to_python(dividend["announcement_date"], False)

    dividend.set_index(Python.list("order_book_id", "book_closure_date"), inplace=True)
    var items: PythonObject = []
    for order_book_id in dividend.index.levels[0]:
        items.append(Python.tuple(order_book_id, dividend.loc[order_book_id].to_records()))
    var file_path = os_path.join(d, "dividends.h5")
    var h5 = h5py.File(file_path, "w")
    for item in items:
        var order_book_id = item[0]
        var data = item[1]
        h5.create_dataset(order_book_id, data=data)
    h5.close()


def gen_split(d: String) raises:
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var order_book_ids = _get_oids_with_corporate_action_exclusions()
    var split = rqdatac.get_split(order_book_ids)
    if split is None:
        raise Error("Got no split data")
    split["split_factor"] = split["split_coefficient_to"] / split["split_coefficient_from"]
    var cols = Python.list("split_factor", "split_coefficient_to", "split_coefficient_from")
    split = split[cols]
    split.reset_index(inplace=True)
    split.rename(columns={"ex_dividend_date": "ex_date"}, inplace=True)
    split["ex_date"] = _convert_dates_to_python(split["ex_date"], True)
    split.set_index(Python.list("order_book_id", "ex_date"), inplace=True)
    var items: PythonObject = []
    for order_book_id in split.index.levels[0]:
        items.append(Python.tuple(order_book_id, split.loc[order_book_id].to_records()))
    var file_path = os_path.join(d, "split_factor.h5")
    var h5 = h5py.File(file_path, "w")
    for item in items:
        var order_book_id = item[0]
        var data = item[1]
        h5.create_dataset(order_book_id, data=data)
    h5.close()


def gen_ex_factor(d: String) raises:
    var numpy = Python.import_module("numpy")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var order_book_ids = _get_oids_with_corporate_action_exclusions()
    var ex_factor = rqdatac.get_ex_factor(order_book_ids)
    if ex_factor is None:
        raise Error("Got no ex factor data")
    ex_factor.reset_index(inplace=True)
    ex_factor["ex_date"] = _convert_dates_to_python(ex_factor["ex_date"], True)
    ex_factor.rename(columns={"ex_date": "start_date"}, inplace=True)
    ex_factor.set_index(Python.list("order_book_id", "start_date"), inplace=True)
    ex_factor = ex_factor[Python.list("ex_cum_factor")]

    var first_key = ex_factor.index.levels[0][0]
    var dtype = ex_factor.loc[first_key].to_records().dtype
    var initial = numpy.empty(Python.tuple(1), dtype=dtype)
    initial["start_date"] = 0
    initial["ex_cum_factor"] = 1.0

    var items: PythonObject = []
    for order_book_id in ex_factor.index.levels[0]:
        var loc_data = ex_factor.loc[order_book_id].to_records()
        var concatenated = numpy.concatenate(Python.tuple(initial, loc_data))
        items.append(Python.tuple(order_book_id, concatenated))
    var file_path = os_path.join(d, "ex_cum_factor.h5")
    var h5 = h5py.File(file_path, "w")
    for item in items:
        var order_book_id = item[0]
        var data = item[1]
        h5.create_dataset(order_book_id, data=data)
    h5.close()


def _convert_dates_to_python(date_col: PythonObject, is_datetime: Bool) raises -> PythonObject:
    var result: PythonObject = []
    for dv in date_col:
        var year = Int(py=dv.year)
        var month = Int(py=dv.month)
        var day = Int(py=dv.day)
        if is_datetime:
            result.append(year * 10000000000 + month * 100000000 + day * 1000000)
        else:
            result.append(year * 10000 + month * 100 + day)
    return result


def gen_share_transformation(d: String) raises:
    var json_mod = Python.import_module("json")
    var os_mod = Python.import_module("os")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var df = rqdatac.get_share_transformation()
    if df is None:
        raise Error("Got no share transformation data")
    df.drop_duplicates("predecessor", inplace=True)
    df.set_index("predecessor", inplace=True)
    df.effective_date = df.effective_date.astype("str")
    df.predecessor_delisted_date = df.predecessor_delisted_date.astype("str")

    var json_file = os_path.join(d, "share_transformation.json")
    var json_str = df.to_json(orient="index")
    var f = open(json_file, "w")
    f.write(json_str)
    f.close()


def gen_future_info(d: String) raises:
    var json_mod = Python.import_module("json")
    var os_mod = Python.import_module("os")
    var re_mod = Python.import_module("re")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var future_info_file = os_path.join(d, "future_info.json")

    var need_recreate: Bool = False
    if os_mod.path.exists(future_info_file):
        var builtins_check = Python.import_module("builtins")
        var f_check = builtins_check.open(future_info_file, "r")
        var content = f_check.read()
        f_check.close()
        var all_futures_info_check = json_mod.loads(content)
        if "margin_rate" not in all_futures_info_check[0]:
            need_recreate = True

    if need_recreate:
        var all_instruments_data = rqdatac.all_instruments("Future")
        var builtins_update = Python.import_module("builtins")
        var f_update = builtins_update.open(future_info_file, "r")
        var update_content = f_update.read()
        f_update.close()
        var all_futures_info_update = json_mod.loads(update_content)
        for future_info in all_futures_info_update:
            if "order_book_id" in future_info:
                future_info["margin_rate"] = all_instruments_data[
                    all_instruments_data["order_book_id"] == future_info["order_book_id"]
                ].iloc[0].margin_rate
            elif "underlying_symbol" in future_info:
                var dominant = rqdatac.futures.get_dominant(future_info["underlying_symbol"])[-1]
                future_info["margin_rate"] = all_instruments_data[
                    all_instruments_data["order_book_id"] == dominant
                ].iloc[0].margin_rate
        os_mod.remove(future_info_file)
        var builtins_write = Python.import_module("builtins")
        var f_write_py = builtins_write.open(future_info_file, "w")
        json_mod.dump(all_futures_info_update, f_write_py)
        f_write_py.close()

    var hard_code: PythonObject = []
    var dict1 = Python.dict()
    dict1["underlying_symbol"] = "TC"
    dict1["close_commission_ratio"] = 4.0
    dict1["close_commission_today_ratio"] = 0.0
    dict1["commission_type"] = "by_volume"
    dict1["open_commission_ratio"] = 4.0
    dict1["margin_rate"] = 0.05
    dict1["tick_size"] = 0.2
    hard_code.append(dict1)

    var dict2 = Python.dict()
    dict2["underlying_symbol"] = "ER"
    dict2["close_commission_ratio"] = 2.5
    dict2["close_commission_today_ratio"] = 2.5
    dict2["commission_type"] = "by_volume"
    dict2["open_commission_ratio"] = 2.5
    dict2["margin_rate"] = 0.05
    dict2["tick_size"] = 1.0
    hard_code.append(dict2)

    var dict3 = Python.dict()
    dict3["underlying_symbol"] = "WS"
    dict3["close_commission_ratio"] = 2.5
    dict3["close_commission_today_ratio"] = 0.0
    dict3["commission_type"] = "by_volume"
    dict3["open_commission_ratio"] = 2.5
    dict3["margin_rate"] = 0.05
    dict3["tick_size"] = 1.0
    hard_code.append(dict3)

    var dict4 = Python.dict()
    dict4["underlying_symbol"] = "RO"
    dict4["close_commission_ratio"] = 2.5
    dict4["close_commission_today_ratio"] = 0.0
    dict4["commission_type"] = "by_volume"
    dict4["open_commission_ratio"] = 2.5
    dict4["margin_rate"] = 0.05
    dict4["tick_size"] = 2.0
    hard_code.append(dict4)

    var dict5 = Python.dict()
    dict5["underlying_symbol"] = "ME"
    dict5["close_commission_ratio"] = 1.4
    dict5["close_commission_today_ratio"] = 0.0
    dict5["commission_type"] = "by_volume"
    dict5["open_commission_ratio"] = 1.4
    dict5["margin_rate"] = 0.06
    dict5["tick_size"] = 1.0
    hard_code.append(dict5)

    var dict6 = Python.dict()
    dict6["underlying_symbol"] = "WT"
    dict6["close_commission_ratio"] = 5.0
    dict6["close_commission_today_ratio"] = 5.0
    dict6["commission_type"] = "by_volume"
    dict6["open_commission_ratio"] = 5.0
    dict6["margin_rate"] = 0.05
    dict6["tick_size"] = 1.0
    hard_code.append(dict6)

    var all_futures_info: PythonObject
    if not os_mod.path.exists(future_info_file):
        all_futures_info = hard_code
    else:
        var builtins_read = Python.import_module("builtins")
        var f_read = builtins_read.open(future_info_file, "r")
        var read_content = f_read.read()
        f_read.close()
        all_futures_info = json_mod.loads(read_content)

    var future_list: PythonObject = []
    var symbol_list: PythonObject = []
    var param = Python.list(
        "close_commission_ratio", "close_commission_today_ratio",
        "commission_type", "open_commission_ratio"
    )

    for i in all_futures_info:
        if i.get("order_book_id"):
            future_list.append(i.get("order_book_id"))
        else:
            symbol_list.append(i.get("underlying_symbol"))

    for info in hard_code:
        var usym = info["underlying_symbol"]
        var found_sym: Bool = False
        for s in symbol_list:
            if s == usym:
                found_sym = True
                break
        if not found_sym:
            all_futures_info.append(info)
            symbol_list.append(usym)

    var futures_order_book_id = rqdatac.all_instruments(type="Future")["order_book_id"].unique()
    var commission_df = rqdatac.futures.get_commission_margin()

    for future in futures_order_book_id:
        var match_result = re_mod.match(r"^[a-zA-Z]*", future)
        var underlying_symbol = match_result.group()

        var found_obid: Bool = False
        for fl in future_list:
            if fl == future:
                found_obid = True
                break
        if found_obid:
            continue

        var future_dict = Python.dict()
        var commission = commission_df[commission_df["order_book_id"] == future]
        var is_empty_val = commission.empty
        if not is_empty_val:
            future_dict["order_book_id"] = future
            commission = commission.iloc[0]
            for p in param:
                future_dict[p] = commission[p]
            var instruments_data = rqdatac.instruments(future)
            future_dict["margin_rate"] = instruments_data.margin_rate
            future_dict["tick_size"] = instruments_data.tick_size()
        else:
            var found_usym: Bool = False
            for sl in symbol_list:
                if sl == underlying_symbol:
                    found_usym = True
                    break
            if found_usym:
                continue

            symbol_list.append(underlying_symbol)
            future_dict["underlying_symbol"] = underlying_symbol
            var dominant: PythonObject
            try:
                dominant = rqdatac.futures.get_dominant(underlying_symbol).iloc[-1]
            except AttributeError:
                continue

            var dominant_indexer = commission_df["order_book_id"] == dominant
            var has_any = dominant_indexer.any()
            if not has_any:
                continue
            commission = commission_df[dominant_indexer].iloc[0]

            for p in param:
                future_dict[p] = commission[p]
            var instruments_data_dominant = rqdatac.instruments(dominant)
            future_dict["margin_rate"] = instruments_data_dominant.margin_rate
            future_dict["tick_size"] = instruments_data_dominant.tick_size()
        all_futures_info.append(future_dict)

    var output_file = os_path.join(d, "future_info.json")
    var builtins_out = Python.import_module("builtins")
    var f_out = builtins_out.open(output_file, "w")
    json_mod.dump(all_futures_info, f_out)
    f_out.close()


def process_init(args: PythonObject = Python.none(), kwargs: PythonObject = Python.dict()) raises:
    var warnings = Python.import_module("warnings")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    warnings.catch_warnings(record=True)
    rqdatac.init(kwargs)
    from rqmojo.utils.logger import init_logger
    init_logger()


def gather_tasks(
    path: String,
    create: Bool,
    enable_compression: Bool,
    h5_kwargs: PythonObject = Python.dict()
) raises -> PythonObject:
    var tasks: PythonObject = []

    from rqmojo.utils.logger import init_logger
    init_logger()

    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var cs_stocks = rqdatac.all_instruments("CS").order_book_id.tolist()
    var indx_stocks = rqdatac.all_instruments("INDX").order_book_id.tolist()
    var future_stocks = rqdatac.all_instruments("Future").order_book_id.tolist()
    var fund_stocks = rqdatac.all_instruments("FUND").order_book_id.tolist()

    var final_h5_kwargs = h5_kwargs
    if enable_compression:
        final_h5_kwargs = Python.dict()
        final_h5_kwargs["compression"] = 9

    var stocks_fields_py = _get_stock_fields()
    var indexes_fields_py = _get_index_fields()
    var futures_fields_py = _get_futures_fields()
    var fund_fields_py = _get_stock_fields()

    if create:
        var task1 = Python.dict()
        task1["type"] = "day_bar_generate"
        task1["order_book_ids"] = cs_stocks
        task1["file_path"] = os_path.join(path, "stocks.h5")
        task1["fields"] = stocks_fields_py
        task1["market"] = "cn"
        task1["h5_kwargs"] = final_h5_kwargs
        tasks.append(task1)

        var task2 = Python.dict()
        task2["type"] = "day_bar_generate"
        task2["order_book_ids"] = indx_stocks
        task2["file_path"] = os_path.join(path, "indexes.h5")
        task2["fields"] = indexes_fields_py
        task2["market"] = "cn"
        task2["h5_kwargs"] = final_h5_kwargs
        tasks.append(task2)

        var task3 = Python.dict()
        task3["type"] = "day_bar_generate"
        task3["order_book_ids"] = future_stocks
        task3["file_path"] = os_path.join(path, "futures.h5")
        task3["fields"] = futures_fields_py
        task3["market"] = "cn"
        task3["h5_kwargs"] = final_h5_kwargs
        tasks.append(task3)

        var task4 = Python.dict()
        task4["type"] = "day_bar_generate"
        task4["order_book_ids"] = fund_stocks
        task4["file_path"] = os_path.join(path, "funds.h5")
        task4["fields"] = fund_fields_py
        task4["market"] = "cn"
        task4["h5_kwargs"] = final_h5_kwargs
        tasks.append(task4)
    else:
        var task5 = Python.dict()
        task5["type"] = "day_bar_update"
        task5["order_book_ids"] = cs_stocks
        task5["file_path"] = os_path.join(path, "stocks.h5")
        task5["fields"] = stocks_fields_py
        task5["market"] = "cn"
        task5["h5_kwargs"] = final_h5_kwargs
        tasks.append(task5)

        var task6 = Python.dict()
        task6["type"] = "day_bar_update"
        task6["order_book_ids"] = indx_stocks
        task6["file_path"] = os_path.join(path, "indexes.h5")
        task6["fields"] = indexes_fields_py
        task6["market"] = "cn"
        task6["h5_kwargs"] = final_h5_kwargs
        tasks.append(task6)

        var task7 = Python.dict()
        task7["type"] = "day_bar_update"
        task7["order_book_ids"] = future_stocks
        task7["file_path"] = os_path.join(path, "futures.h5")
        task7["fields"] = futures_fields_py
        task7["market"] = "cn"
        task7["h5_kwargs"] = final_h5_kwargs
        tasks.append(task7)

        var task8 = Python.dict()
        task8["type"] = "day_bar_update"
        task8["order_book_ids"] = fund_stocks
        task8["file_path"] = os_path.join(path, "funds.h5")
        task8["fields"] = fund_fields_py
        task8["market"] = "cn"
        task8["h5_kwargs"] = final_h5_kwargs
        tasks.append(task8)

    var gen_task1 = Python.dict()
    gen_task1["type"] = "gen_func"
    gen_task1["func_name"] = "gen_instruments"
    gen_task1["path"] = path
    tasks.append(gen_task1)

    var gen_task2 = Python.dict()
    gen_task2["type"] = "gen_func"
    gen_task2["func_name"] = "gen_trading_dates"
    gen_task2["path"] = path
    tasks.append(gen_task2)

    var gen_task3 = Python.dict()
    gen_task3["type"] = "gen_func"
    gen_task3["func_name"] = "gen_st_days"
    gen_task3["path"] = path
    tasks.append(gen_task3)

    var gen_task4 = Python.dict()
    gen_task4["type"] = "gen_func"
    gen_task4["func_name"] = "gen_suspended_days"
    gen_task4["path"] = path
    tasks.append(gen_task4)

    var gen_task5 = Python.dict()
    gen_task5["type"] = "gen_func"
    gen_task5["func_name"] = "gen_yield_curve"
    gen_task5["path"] = path
    tasks.append(gen_task5)

    var gen_task6 = Python.dict()
    gen_task6["type"] = "gen_func"
    gen_task6["func_name"] = "gen_share_transformation"
    gen_task6["path"] = path
    tasks.append(gen_task6)

    var gen_task7 = Python.dict()
    gen_task7["type"] = "gen_func"
    gen_task7["func_name"] = "gen_future_info"
    gen_task7["path"] = path
    tasks.append(gen_task7)

    var gen_task8 = Python.dict()
    gen_task8["type"] = "gen_func"
    gen_task8["func_name"] = "gen_dividend"
    gen_task8["path"] = path
    tasks.append(gen_task8)

    var gen_task9 = Python.dict()
    gen_task9["type"] = "gen_func"
    gen_task9["func_name"] = "gen_split"
    gen_task9["path"] = path
    tasks.append(gen_task9)

    var gen_task10 = Python.dict()
    gen_task10["type"] = "gen_func"
    gen_task10["func_name"] = "gen_ex_factor"
    gen_task10["path"] = path
    tasks.append(gen_task10)

    return tasks


def run_tasks(tasks: PythonObject, concurrency: Int = 1, rqdatac_kwargs: PythonObject = Python.dict()) raises -> Bool:
    var multiprocessing = Python.import_module("multiprocessing")
    var ctypes_mod = Python.import_module("ctypes")

    var succeed = multiprocessing.Value(ctypes_mod.c_bool, True)

    for task in tasks:
        var task_type = task["type"]
        if task_type == "day_bar_generate":
            _execute_day_bar_generate(task)
        elif task_type == "day_bar_update":
            _execute_day_bar_update(task)
        elif task_type == "gen_func":
            var func_name = task["func_name"]
            var path = task["path"]
            if func_name == "gen_instruments":
                gen_instruments(path)
            elif func_name == "gen_trading_dates":
                gen_trading_dates(path)
            elif func_name == "gen_st_days":
                gen_st_days(path)
            elif func_name == "gen_suspended_days":
                gen_suspended_days(path)
            elif func_name == "gen_yield_curve":
                gen_yield_curve(path)
            elif func_name == "gen_share_transformation":
                gen_share_transformation(path)
            elif func_name == "gen_future_info":
                gen_future_info(path)
            elif func_name == "gen_dividend":
                gen_dividend(path)
            elif func_name == "gen_split":
                gen_split(path)
            elif func_name == "gen_ex_factor":
                gen_ex_factor(path)

    return succeed.value != 0


def _execute_day_bar_generate(task: PythonObject) raises:
    var datetime_mod = Python.import_module("datetime")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")

    var order_book_ids = task["order_book_ids"]
    var file_path = task["file_path"]
    var fields = task["fields"]
    var market = task["market"]
    var h5_kwargs = task["h5_kwargs"]

    var h5 = h5py.File(file_path, "w")

    var i = 0
    var step = 300
    while True:
        var end_idx = min(i + step, len(order_book_ids))
        var batch_ids = order_book_ids[i:end_idx]

        var df = rqdatac.get_price(
            batch_ids, START_DATE, datetime_mod.date.today(), "1d",
            adjust_type="none", fields=fields,
            expect_df=True, market=market
        )
        var df_is_none = df is None
        var df_empty = False
        if not df_is_none:
            df_empty = bool(df.empty)
        if not (df_is_none or df_empty):
            df.reset_index(inplace=True)
            df["datetime"] = _convert_dates_to_python(df["date"], True)
            del df["date"]
            df.set_index(Python.list("order_book_id", "datetime"), inplace=True)
            df.sort_index(inplace=True)
            for order_book_id in df.index.levels[0]:
                h5.create_dataset(order_book_id, data=df.loc[order_book_id].to_records(), **h5_kwargs)
        i += step
        if i >= len(order_book_ids):
            break
    h5.close()


def _execute_day_bar_update(task: PythonObject) raises:
    var datetime_mod = Python.import_module("datetime")
    var os_mod = Python.import_module("os")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var h5py = Python.import_module("h5py")
    var numpy = Python.import_module("numpy")

    var order_book_ids = task["order_book_ids"]
    var file_path = task["file_path"]
    var fields = task["fields"]
    var market = task["market"]
    var h5_kwargs = task["h5_kwargs"]

    var need_recreate_h5: Bool = False
    try:
        var h5_check = h5py.File(file_path, "r")
        need_recreate_h5 = not _h5_has_valid_fields(h5_check, fields)
        h5_check.close()
    except OSError:
        need_recreate_h5 = True
    except RuntimeError:
        need_recreate_h5 = True

    if need_recreate_h5:
        _execute_day_bar_generate(task)
        return

    var h5 = h5py.File(file_path, "a")

    var basename = os_mod.path.basename(file_path)
    var parts = basename.split(".")
    var is_futures = parts[0] == "futures"

    for order_book_id in order_book_ids:
        var is_pre = is_futures and "888" in order_book_id
        var start_date: Int = START_DATE

        if order_book_id in h5 and not is_pre:
            try:
                var last_date_val = h5[order_book_id]["datetime"][-1]
                var last_date = Int(py=last_date_val) // 1000000
            except OSError:
                print("Error: File update failed - " + file_path)
                h5.pop(order_book_id)
                start_date = START_DATE
            except ValueError:
                h5.pop(order_book_id)
                start_date = START_DATE
            else:
                var next_dt = rqdatac.get_next_trading_date(last_date)
                start_date = Int(py=next_dt.year) * 10000000000 + Int(py=next_dt.month) * 100000000 + Int(py=next_dt.day) * 1000000
        else:
            start_date = START_DATE

        var df = rqdatac.get_price(
            order_book_id, start_date, END_DATE, "1d",
            adjust_type="none", fields=fields,
            expect_df=True, market=market
        )
        var df_is_none = df is None
        var df_empty = False
        if not df_is_none:
            df_empty = bool(df.empty)
        if not (df_is_none or df_empty):
            df = df[fields]
            df = df.loc[order_book_id]
            df.reset_index(inplace=True)
            df["datetime"] = _convert_dates_to_python(df["date"], True)
            del df["date"]
            df.set_index("datetime", inplace=True)

            if order_book_id in h5:
                var existing_data = h5[order_book_id][:]
                var new_records = df.to_records()
                var combined: PythonObject = []
                for ed in existing_data:
                    combined.append(ed)
                for nr in new_records:
                    combined.append(nr)
                var data = numpy.array(combined, dtype=h5[order_book_id].dtype)
                h5.pop(order_book_id)
                h5.create_dataset(order_book_id, data=data, **h5_kwargs)
            else:
                h5.create_dataset(order_book_id, data=df.to_records(), **h5_kwargs)
    h5.close()


def _h5_has_valid_fields(h5: PythonObject, wanted_fields: PythonObject) -> Bool:
    var keys_iter = h5.keys()
    var wanted_fields_set: PythonObject = Python.dict()
    for wf in wanted_fields:
        wanted_fields_set[wf] = True
    wanted_fields_set["datetime"] = True
    try:
        var first_key = next(keys_iter)
        var h5_fields = h5[first_key].dtype.fields.keys()
        var result: Bool = True
        for key in wanted_fields_set.keys():
            var found: Bool = False
            for hf in h5_fields:
                if key == hf:
                    found = True
                    break
            if not found:
                result = False
                break
        return result
    except StopIteration:
        pass
    return False


def update_bundle(
    path: String,
    create: Bool,
    enable_compression: Bool = False,
    concurrency: Int = 1,
    rqdata_kwargs: PythonObject = Python.dict(),
    h5_kwargs: PythonObject = Python.dict()
) raises -> Bool:
    var tasks = gather_tasks(path, create, enable_compression, h5_kwargs)
    return run_tasks(tasks, concurrency, rqdata_kwargs)


@fieldwise_init
struct BundleVersion(Copyable, Movable, ImplicitlyCopyable, Equatable, Writable):
    var major: Int
    var minor: Int
    var patch: Int

    @staticmethod
    fn default() -> BundleVersion:
        return BundleVersion(major=1, minor=0, patch=0)


@fieldwise_init
struct BundleMetadata(Writable, Movable):
    var version: BundleVersion
    var created_at: DateTime
    var market: String
    var data_types: List[String]


@fieldwise_init
struct Bundle(Writable, Movable):
    var _path: String
    var _version: BundleVersion
    var _metadata: BundleMetadata
    var _instruments_path: String
    var _trading_dates_path: String
    var _stocks_path: String
    var _indexes_path: String
    var _futures_path: String
    var _funds_path: String
    var _dividends_path: String
    var _splits_path: String
    var _ex_cum_factor_path: String
    var _initialized: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Bundle(path=", self._path, ")")

    def __init__(out self, path: String):
        self._path = path
        self._version = BundleVersion.default()
        self._metadata = BundleMetadata(
            version=BundleVersion.default(),
            created_at=_get_current_time(),
            market="cn",
            data_types=List[String]()
        )
        self._instruments_path = os_path.join(path, "instruments.pk")
        self._trading_dates_path = os_path.join(path, "trading_dates.npy")
        self._stocks_path = os_path.join(path, "stocks.h5")
        self._indexes_path = os_path.join(path, "indexes.h5")
        self._futures_path = os_path.join(path, "futures.h5")
        self._funds_path = os_path.join(path, "funds.h5")
        self._dividends_path = os_path.join(path, "dividends.h5")
        self._splits_path = os_path.join(path, "split_factor.h5")
        self._ex_cum_factor_path = os_path.join(path, "ex_cum_factor.h5")
        self._initialized = False

    def update(mut self) -> Bool:
        print("Updating bundle at: " + self._path)
        self._initialized = True
        return True

    def load(mut self) -> Bool:
        print("Loading bundle from: " + self._path)
        self._initialized = True
        return True

    def get_stocks_path(self) -> String:
        return self._stocks_path

    def get_indexes_path(self) -> String:
        return self._indexes_path

    def get_futures_path(self) -> String:
        return self._futures_path

    def get_funds_path(self) -> String:
        return self._funds_path

    def get_dividends_path(self) -> String:
        return self._dividends_path

    def get_splits_path(self) -> String:
        return self._splits_path

    def get_ex_cum_factor_path(self) -> String:
        return self._ex_cum_factor_path

    def get_trading_dates_path(self) -> String:
        return self._trading_dates_path

    def get_instruments_path(self) -> String:
        return self._instruments_path

    def is_initialized(self) -> Bool:
        return self._initialized

    def get_version(self) -> BundleVersion:
        return self._version

    def get_market(self) -> String:
        return self._metadata.market

    def get_path(self) -> String:
        return self._path


fn create_bundle(path: String) -> Bundle:
    return Bundle(path)


def _get_current_time() -> DateTime:
    try:
        return DateTime.now()
    except:
        return DateTime(2024, 1, 1, 0, 0, 0, 0)


struct AutomaticUpdateBundle(Writable, Movable):
    var _bundle: Bundle
    var _filename: String
    var _api: PythonObject
    var _fields: List[String]
    var _end_date: DateTimeDate
    var _start_date: Int
    var _updated: List[String]
    var _env: PythonObject
    var _file_lock: PythonObject

    def write_to(self, mut writer: Some[Writer]):
        writer.write("AutomaticUpdateBundle(", self._filename, ")")

    def __init__(
        out self,
        path: String,
        filename: String,
        api: PythonObject,
        fields: List[String],
        end_date: DateTimeDate,
        start_date: Int = START_DATE
    ) raises:
        var os_mod = Python.import_module("os")
        if not os_mod.path.exists(path):
            os_mod.makedirs(path)

        self._bundle = Bundle(path)
        self._filename = os_path.join(path, filename)
        self._api = api
        self._fields = fields
        self._end_date = end_date
        self._start_date = start_date
        self._updated = List[String]()
        from rqmojo.environment import Environment
        self._env = Environment.get_instance()
        var filelock = Python.import_module("filelock")
        self._file_lock = filelock.FileLock(self._filename + ".lock")

    def get_data(mut self, instrument: Instrument, dt: DateTimeDate) raises -> Optional[PythonObject]:
        var dt_int = Int(py=dt.year) * 10000 + Int(py=dt.month) * 100 + Int(py=dt.day)
        var data = self._get_data_all_time(instrument)
        if data is None:
            return None
        else:
            var numpy = Python.import_module("numpy")
            var searchsorted_result = numpy.searchsorted(data, dt_int)
            var idx_int = Int(py=searchsorted_result)
            if idx_int >= len(data):
                return None
            return data[idx_int]

    def _get_data_all_time(mut self, instrument: Instrument) raises -> Optional[PythonObject]:
        var obid = instrument.order_book_id()
        var found: Bool = False
        for u in self._updated:
            if u == obid:
                found = True
                break
        if not found:
            self._auto_update_task(instrument)
            self._updated.append(obid)

        var h5py = Python.import_module("h5py")
        var h5 = h5py.File(self._filename, "r")
        var data = h5[instrument.order_book_id()][:]
        h5.close()
        if len(data) == 0:
            return None
        return data

    def _auto_update_task(mut self, instrument: Instrument) raises -> None:
        """
        Auto-update required day bar data during strategy execution

        :param instrument: Instrument object
        :type instrument: `Instrument`
        """
        var datetime_mod = Python.import_module("datetime")
        var h5py = Python.import_module("h5py")
        var numpy = Python.import_module("numpy")

        var order_book_id = instrument.order_book_id()
        var start_date = self._start_date

        var lock_acquired = self._file_lock.acquire()
        var h5 = h5py.File(self._filename, "a")
        try:
            var key_exists = False
            for k in h5.keys():
                if String(py=k) == order_book_id:
                    key_exists = True
                    break

            if key_exists and h5[order_book_id].dtype.names is not None:
                var names = h5[order_book_id].dtype.names
                var has_trading_dt: Bool = False
                for n in names:
                    if String(py=n) == "trading_dt":
                        has_trading_dt = True
                        break
                if has_trading_dt:
                    var existing_len = len(h5[order_book_id][:])
                    if existing_len > 0:
                        var last_date_val = h5[order_book_id][-1]["trading_dt"]
                        var last_date_str = String(py=last_date_val)
                        var last_date = datetime_mod.datetime.strptime(last_date_str, "%Y%m%d").date()
                        var config_base = self._env.config.base
                        var end_date = config_base.end_date
                        if last_date >= end_date:
                            return
                        var next_trading = self._env.data_proxy._data_source.get_next_trading_date(last_date)
                        start_date = Int(py=next_trading.year) * 10000 + Int(py=next_trading.month) * 100 + Int(py=next_trading.day)
                        if start_date > Int(py=end_date.year) * 10000 + Int(py=end_date.month) * 100 + Int(py=end_date.day):
                            return
                else:
                    h5.pop(order_book_id)

            var arr = self._get_array(instrument, start_date)
            if arr is None:
                var arr_key_exists = False
                for k in h5.keys():
                    if String(py=k) == order_book_id:
                        arr_key_exists = True
                        break
                if not arr_key_exists:
                    arr = numpy.array([])
                    h5.create_dataset(order_book_id, data=arr)
            else:
                var arr_key_exists2 = False
                for k in h5.keys():
                    if String(py=k) == order_book_id:
                        arr_key_exists2 = True
                        break
                if arr_key_exists2:
                    var existing_data = h5[order_book_id][:]
                    var combined: PythonObject = []
                    for ed in existing_data:
                        combined.append(ed)
                    for ar in arr:
                        combined.append(ar)
                    var data = numpy.array(combined, dtype=h5[order_book_id].dtype)
                    h5.pop(order_book_id)
                    h5.create_dataset(order_book_id, data=data)
                else:
                    h5.create_dataset(order_book_id, data=arr)
        except OSError:
            var error_msg = "File " + self._filename + " update failed, if it is using, please update later, or you can delete then update again"
            raise OSError(error_msg)
        finally:
            h5.close()

    def _get_array(self, instrument: Instrument, start_date: Int) raises -> Optional[PythonObject]:
        var numpy = Python.import_module("numpy")
        var config_base = self._env.config.base
        var end_date = config_base.end_date
        var fields_py = Python.list(self._fields[0])
        for fi in range(1, len(self._fields)):
            fields_py.append(self._fields[fi])

        var df = self._api(instrument.order_book_id(), start_date, end_date, fields_py)
        var df_is_none = df is None
        var df_empty = False
        if not df_is_none:
            df_empty = bool(df.empty)
        if not (df_is_none or df_empty):
            df = df[fields_py]
            df = df.loc[instrument.order_book_id()]
            var record = df.iloc[0:1].to_records()
            var dtype_list = Python.list(Python.tuple("trading_dt", "int"))
            for field in self._fields:
                dtype_list.append(Python.tuple(field, record.dtype[field]))
            var trading_dt = self._env.data_proxy._data_source.batch_get_trading_date(df.index)
            var trading_dt_converted: PythonObject = []
            for td in trading_dt:
                var year = Int(py=td.year)
                var month = Int(py=td.month)
                var day = Int(py=td.day)
                trading_dt_converted.append(year * 10000 + month * 100 + day)
            var arr = numpy.ones(Python.tuple(len(trading_dt_converted)), dtype=dtype_list)
            arr["trading_dt"] = trading_dt_converted
            for field in self._fields:
                arr[field] = df[field].values
            return arr
        return None
