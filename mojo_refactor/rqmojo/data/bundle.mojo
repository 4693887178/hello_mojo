"""
RQAlpha Mojo - Bundle Data Management
Ported from rqalpha/data/bundle.py

Design Notes:
  - Uses composition instead of inheritance (Mojo limitation)
  - Data generation functions use Python interop for rqdatac/h5py
  - AutomaticUpdateBundle maintains same interface as original
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


struct GenerateDividendBundle(Writable, Movable):
    var _d: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("GenerateDividendBundle(path=", self._d, ")")

    def __init__(out self, d: String):
        self._d = d

    def _get_dividend(self) raises -> PythonObject:
        var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
        var order_book_ids = _get_oids_with_corporate_action_exclusions()
        return rqdatac.get_dividend(order_book_ids)

    def _write(self, data_iter: PythonObject) raises:
        var h5py = Python.import_module("h5py")
        var file_path = os_path.join(self._d, "dividends.h5")
        var h5 = h5py.File(file_path, "w")
        for item in data_iter:
            var order_book_id = item[0]
            var data = item[1]
            h5.create_dataset(order_book_id, data=data)
        h5.close()

    def __call__(self) raises:
        var dividend = self._get_dividend()
        if dividend is None:
            raise Error("Got no dividend data")
        var need_cols = Python.list(
            "dividend_cash_before_tax", "book_closure_date",
            "ex_dividend_date", "payable_date", "round_lot"
        )
        dividend = dividend[need_cols]
        dividend.reset_index(inplace=True)
        dividend.rename(columns={"declaration_announcement_date": "announcement_date"}, inplace=True)

        dividend["book_closure_date"] = self._convert_dates(dividend["book_closure_date"], False)
        dividend["ex_dividend_date"] = self._convert_dates(dividend["ex_dividend_date"], False)
        dividend["payable_date"] = self._convert_dates(dividend["payable_date"], False)
        dividend["announcement_date"] = self._convert_dates(dividend["announcement_date"], False)

        dividend.set_index(Python.list("order_book_id", "book_closure_date"), inplace=True)
        var items: List[PythonObject] = []
        for order_book_id in dividend.index.levels[0]:
            items.append(Python.tuple(order_book_id, dividend.loc[order_book_id].to_records()))
        self._write(items)

    def _convert_dates(self, date_col: PythonObject, is_datetime: Bool) -> List[Int]:
        var result: List[Int] = []
        for dv in date_col:
            var year = Int(py=dv.year)
            var month = Int(py=dv.month)
            var day = Int(py=dv.day)
            if is_datetime:
                result.append(year * 10000000000 + month * 100000000 + day * 1000000)
            else:
                result.append(year * 10000 + month * 100 + day)
        return result^


struct GenerateSplitBundle(Writable, Movable):
    var _d: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("GenerateSplitBundle(path=", self._d, ")")

    def __init__(out self, d: String):
        self._d = d

    def _get_split(self) raises -> PythonObject:
        var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
        var order_book_ids = _get_oids_with_corporate_action_exclusions()
        return rqdatac.get_split(order_book_ids)

    def _write(self, data_iter: PythonObject) raises:
        var h5py = Python.import_module("h5py")
        var file_path = os_path.join(self._d, "split_factor.h5")
        var h5 = h5py.File(file_path, "w")
        for item in data_iter:
            var order_book_id = item[0]
            var data = item[1]
            h5.create_dataset(order_book_id, data=data)
        h5.close()

    def __call__(self) raises:
        var split = self._get_split()
        if split is None:
            raise Error("Got no split data")
        split["split_factor"] = split["split_coefficient_to"] / split["split_coefficient_from"]
        var cols = Python.list("split_factor", "split_coefficient_to", "split_coefficient_from")
        split = split[cols]
        split.reset_index(inplace=True)
        split.rename(columns={"ex_dividend_date": "ex_date"}, inplace=True)
        split["ex_date"] = self._convert_dates(split["ex_date"], True)
        split.set_index(Python.list("order_book_id", "ex_date"), inplace=True)
        var items: List[PythonObject] = []
        for order_book_id in split.index.levels[0]:
            items.append(Python.tuple(order_book_id, split.loc[order_book_id].to_records()))
        self._write(items)

    def _convert_dates(self, date_col: PythonObject, is_datetime: Bool) -> List[Int]:
        var result: List[Int] = []
        for dv in date_col:
            var year = Int(py=dv.year)
            var month = Int(py=dv.month)
            var day = Int(py=dv.day)
            if is_datetime:
                result.append(year * 10000000000 + month * 100000000 + day * 1000000)
            else:
                result.append(year * 10000 + month * 100 + day)
        return result^


struct GenerateExFactorBundle(Writable, Movable):
    var _d: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("GenerateExFactorBundle(path=", self._d, ")")

    def __init__(out self, d: String):
        self._d = d

    def _get_ex_factor(self) raises -> PythonObject:
        var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
        var order_book_ids = _get_oids_with_corporate_action_exclusions()
        return rqdatac.get_ex_factor(order_book_ids)

    def _write(self, data_iter: PythonObject) raises:
        var h5py = Python.import_module("h5py")
        var file_path = os_path.join(self._d, "ex_cum_factor.h5")
        var h5 = h5py.File(file_path, "w")
        for item in data_iter:
            var order_book_id = item[0]
            var data = item[1]
            h5.create_dataset(order_book_id, data=data)
        h5.close()

    def __call__(self) raises:
        var numpy = Python.import_module("numpy")
        var ex_factor = self._get_ex_factor()
        if ex_factor is None:
            raise Error("Got no ex factor data")
        ex_factor.reset_index(inplace=True)
        ex_factor["ex_date"] = self._convert_dates(ex_factor["ex_date"], True)
        ex_factor.rename(columns={"ex_date": "start_date"}, inplace=True)
        ex_factor.set_index(Python.list("order_book_id", "start_date"), inplace=True)
        ex_factor = ex_factor[Python.list("ex_cum_factor")]

        var first_key = ex_factor.index.levels[0][0]
        var dtype = ex_factor.loc[first_key].to_records().dtype
        var initial = numpy.empty(Python.tuple(1), dtype=dtype)
        initial["start_date"] = 0
        initial["ex_cum_factor"] = 1.0

        var items: List[PythonObject] = []
        for order_book_id in ex_factor.index.levels[0]:
            var loc_data = ex_factor.loc[order_book_id].to_records()
            var concatenated = numpy.concatenate(Python.tuple(initial, loc_data))
            items.append(Python.tuple(order_book_id, concatenated))
        self._write(items)

    def _convert_dates(self, date_col: PythonObject, is_datetime: Bool) -> List[Int]:
        var result: List[Int] = []
        for dv in date_col:
            var year = Int(py=dv.year)
            var month = Int(py=dv.month)
            var day = Int(py=dv.day)
            if is_datetime:
                result.append(year * 10000000000 + month * 100000000 + day * 1000000)
            else:
                result.append(year * 10000 + month * 100 + day)
        return result^


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
            future_list.append(String(py=i.get("order_book_id")))
        else:
            symbol_list.append(String(py=i.get("underlying_symbol")))

    for info in hard_code:
        var usym = String(py=info["underlying_symbol"])
        if usym not in symbol_list:
            all_futures_info.append(info)
            symbol_list.append(usym)

    var futures_order_book_id = rqdatac.all_instruments(type="Future")["order_book_id"].unique()
    var commission_df = rqdatac.futures.get_commission_margin()

    for future in futures_order_book_id:
        var future_str = String(py=future)
        var match_result = re_mod.match(r"^[a-zA-Z]*", future_str)
        var underlying_symbol = match_result.group()
        if future_str in future_list:
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
        var is_in_symbol_list: Bool = False
        for s in symbol_list:
            if s == underlying_symbol:
                is_in_symbol_list = True
                break
        if is_in_symbol_list:
            continue
        else:
            symbol_list.append(underlying_symbol)
            future_dict["underlying_symbol"] = underlying_symbol
            try:
                var dominant = rqdatac.futures.get_dominant(underlying_symbol).iloc[-1]
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
    json_mod.dump(all_futures_info, f_out, separators=(",", ":"), indent=2)
    f_out.close()


struct GenerateFileTask(Writable, Movable):
    var _func: PythonObject
    var _args: PythonObject
    var _kwargs: PythonObject
    var _step: Int

    def write_to(self, mut writer: Some[Writer]):
        writer.write("GenerateFileTask(step=", String(self._step), ")")

    def __init__(out self, func: PythonObject, args: PythonObject, kwargs: PythonObject):
        self._func = func
        self._args = args
        self._kwargs = kwargs
        self._step = 100

    def total_steps(self) -> Int:
        return self._step

    def __call__(mut self) raises -> Int:
        self._func(self._args, self._kwargs)
        return self._step


struct DayBarTask(Writable, Movable):
    var _order_book_ids: PythonObject
    var _file_path: String
    var _fields: PythonObject
    var _h5_kwargs: PythonObject
    var _market: String
    var _task_type: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("DayBarTask(file=", self._file_path, ", type=", self._task_type, ")")

    def __init__(
        out self,
        order_book_ids: PythonObject,
        file_path: String,
        fields: PythonObject,
        market: String = "cn",
        h5_kwargs: Optional[PythonObject] = None,
        task_type: String = "base"
    ):
        self._order_book_ids = order_book_ids
        self._file_path = file_path
        self._fields = fields
        if h5_kwargs is None:
            self._h5_kwargs = Python.dict()
        else:
            self._h5_kwargs = h5_kwargs
        self._market = market
        self._task_type = task_type

    def total_steps(self) -> Int:
        return len(self._order_book_ids)

    def execute_generate(mut self) raises -> List[Int]:
        var results: List[Int] = []
        var datetime_mod = Python.import_module("datetime")
        var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
        var h5py = Python.import_module("h5py")

        try:
            var h5 = h5py.File(self._file_path, "w")
        except OSError:
            print("Error: File update failed - " + self._file_path)
            results.append(1)
            return results^

        var i = 0
        var step = 300
        while True:
            var end_idx = min(i + step, len(self._order_book_ids))
            var batch_ids = self._order_book_ids[i:end_idx]
            var py_batch_ids = Python.list(batch_ids[0])
            for j in range(1, len(batch_ids)):
                py_batch_ids.append(batch_ids[j])

            var df = rqdatac.get_price(
                py_batch_ids, START_DATE, datetime_mod.date.today(), "1d",
                adjust_type="none", fields=self._fields,
                expect_df=True, market=self._market
            )
            var df_is_none = df is None
            var df_empty = False
            if not df_is_none:
                df_empty = bool(df.empty)
            if not (df_is_none or df_empty):
                df.reset_index(inplace=True)
                var datetime_values: List[Int] = []
                for dv in df["date"]:
                    var year = Int(py=dv.year)
                    var month = Int(py=dv.month)
                    var day = Int(py=dv.day)
                    datetime_values.append(year * 10000000000 + month * 100000000 + day * 1000000)
                df["datetime"] = datetime_values
                del df["date"]
                df.set_index(Python.list("order_book_id", "datetime"), inplace=True)
                df.sort_index(inplace=True)
                for order_book_id in df.index.levels[0]:
                    h5.create_dataset(
                        order_book_id,
                        data=df.loc[order_book_id].to_records(),
                        **self._h5_kwargs
                    )
            results.append(len(batch_ids))
            i += step
            if i >= len(self._order_book_ids):
                break
        h5.close()
        return results^

    def execute_update(mut self) raises -> List[Int]:
        var results: List[Int] = []
        var datetime_mod = Python.import_module("datetime")
        var os_mod = Python.import_module("os")
        var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
        var h5py = Python.import_module("h5py")
        var numpy = Python.import_module("numpy")

        var need_recreate_h5: Bool = False
        try:
            var h5_check = h5py.File(self._file_path, "r")
            need_recreate_h5 = not self._h5_has_valid_fields(h5_check, self._fields)
            h5_check.close()
        except OSError:
            need_recreate_h5 = True
        except RuntimeError:
            need_recreate_h5 = True

        if need_recreate_h5:
            return self.execute_generate()

        var h5: Optional[PythonObject] = None
        try:
            h5 = h5py.File(self._file_path, "a")
        except OSError:
            print("Error: File update failed - " + self._file_path)
            results.append(1)
            return results^

        var basename = os_mod.path.basename(self._file_path)
        var parts = basename.split(".")
        var is_futures = parts[0] == "futures"

        for order_book_id in self._order_book_ids:
            var is_pre = is_futures and "888" in order_book_id
            var start_date: Int = START_DATE

            if order_book_id in h5 and not is_pre:
                try:
                    var last_date_val = h5[order_book_id]["datetime"][-1]
                    var last_date = Int(py=last_date_val) // 1000000
                except OSError:
                    print("Error: File update failed - " + self._file_path)
                    results.append(1)
                    break
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
                adjust_type="none", fields=self._fields,
                expect_df=True, market=self._market
            )
            var df_is_none = df is None
            var df_empty = False
            if not df_is_none:
                df_empty = bool(df.empty)
            if not (df_is_none or df_empty):
                var fields_py = Python.list(self._fields[0])
                for fi in range(1, len(self._fields)):
                    fields_py.append(self._fields[fi])
                df = df[fields_py]
                df = df.loc[order_book_id]
                df.reset_index(inplace=True)
                var dt_vals: List[Int] = []
                for dv in df["date"]:
                    var year = Int(py=dv.year)
                    var month = Int(py=dv.month)
                    var day = Int(py=dv.day)
                    dt_vals.append(year * 10000000000 + month * 100000000 + day * 1000000)
                df["datetime"] = dt_vals
                del df["date"]
                df.set_index("datetime", inplace=True)

                if order_book_id in h5:
                    var existing_data = h5[order_book_id][:]
                    var new_records = df.to_records()
                    var combined: List[PythonObject] = []
                    for ed in existing_data:
                        combined.append(ed)
                    for nr in new_records:
                        combined.append(nr)
                    var data = numpy.array(combined, dtype=h5[order_book_id].dtype)
                    h5.pop(order_book_id)
                    h5.create_dataset(order_book_id, data=data, **self._h5_kwargs)
                else:
                    h5.create_dataset(order_book_id, data=df.to_records(), **self._h5_kwargs)
            results.append(1)
        finally:
            if h5 is not None:
                h5.close()
        return results^

    def _h5_has_valid_fields(self, h5: PythonObject, wanted_fields: List[String]) -> Bool:
        var keys_iter = h5.keys()
        var wanted_fields_set: Dict[String, Bool] = {}
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
                    if String(py=key) == String(py=hf):
                        found = True
                        break
                if not found:
                    result = False
                    break
            return result
        except StopIteration:
            pass
        return False

    def __call__(mut self) raises -> List[Int]:
        if self._task_type == "generate":
            return self.execute_generate()
        else:
            return self.execute_update()


fn create_day_bar_task_generate(
    order_book_ids: List[String],
    file_path: String,
    fields: List[String],
    market: String = "cn",
    h5_kwargs: Optional[PythonObject] = None
) raises -> DayBarTask:
    var final_h5_kwargs = h5_kwargs
    if final_h5_kwargs is None:
        final_h5_kwargs = Python.dict()
    return DayBarTask(order_book_ids, file_path, fields, market, final_h5_kwargs, "generate")


fn create_day_bar_task_update(
    order_book_ids: List[String],
    file_path: String,
    fields: List[String],
    market: String = "cn",
    h5_kwargs: Optional[PythonObject] = None
) raises -> DayBarTask:
    var final_h5_kwargs = h5_kwargs
    if final_h5_kwargs is None:
        final_h5_kwargs = Python.dict()
    return DayBarTask(order_book_ids, file_path, fields, market, final_h5_kwargs, "update")


def process_init(args: Optional[PythonObject] = None, kwargs: Optional[PythonObject] = None) raises:
    var kwargs_final: PythonObject = Python.dict()
    if kwargs is not None:
        kwargs_final = kwargs
    var warnings = Python.import_module("warnings")
    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    warnings.catch_warnings(record=True)
    rqdatac.init(kwargs_final)
    from rqmojo.utils.logger import init_logger
    init_logger()


def gather_tasks(
    path: String,
    create: Bool,
    enable_compression: Bool,
    h5_kwargs: Optional[PythonObject] = None
) raises -> List[PythonObject]:
    var tasks: List[PythonObject] = []

    from rqmojo.utils.logger import init_logger
    init_logger()

    var rqdatac = Python.import_module("rqalpha.apis.api_rqdatac").rqdatac
    var cs_stocks = rqdatac.all_instruments("CS").order_book_id.tolist()
    var indx_stocks = rqdatac.all_instruments("INDX").order_book_id.tolist()
    var future_stocks = rqdatac.all_instruments("Future").order_book_id.tolist()
    var fund_stocks = rqdatac.all_instruments("FUND").order_book_id.tolist()

    var final_h5_kwargs = h5_kwargs
    if final_h5_kwargs is None:
        final_h5_kwargs = Python.dict()
    if enable_compression:
        final_h5_kwargs = Python.dict(compression=9)

    var stocks_fields_py = _get_stock_fields()
    var indexes_fields_py = _get_index_fields()
    var futures_fields_py = _get_futures_fields()
    var fund_fields_py = _get_stock_fields()

    if create:
        tasks.append(create_day_bar_task_generate(cs_stocks, os_path.join(path, "stocks.h5"), stocks_fields_py, "cn", final_h5_kwargs))
        tasks.append(create_day_bar_task_generate(indx_stocks, os_path.join(path, "indexes.h5"), indexes_fields_py, "cn", final_h5_kwargs))
        tasks.append(create_day_bar_task_generate(future_stocks, os_path.join(path, "futures.h5"), futures_fields_py, "cn", final_h5_kwargs))
        tasks.append(create_day_bar_task_generate(fund_stocks, os_path.join(path, "funds.h5"), fund_fields_py, "cn", final_h5_kwargs))
    else:
        tasks.append(create_day_bar_task_update(cs_stocks, os_path.join(path, "stocks.h5"), stocks_fields_py, "cn", final_h5_kwargs))
        tasks.append(create_day_bar_task_update(indx_stocks, os_path.join(path, "indexes.h5"), indexes_fields_py, "cn", final_h5_kwargs))
        tasks.append(create_day_bar_task_update(future_stocks, os_path.join(path, "futures.h5"), futures_fields_py, "cn", final_h5_kwargs))
        tasks.append(create_day_bar_task_update(fund_stocks, os_path.join(path, "funds.h5"), fund_fields_py, "cn", final_h5_kwargs))

    var path_arg = Python.tuple(path)
    var empty_kwargs = Python.dict()

    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_instruments, path_arg, empty_kwargs))
    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_trading_dates, path_arg, empty_kwargs))
    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_st_days, path_arg, empty_kwargs))
    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_suspended_days, path_arg, empty_kwargs))
    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_yield_curve, path_arg, empty_kwargs))
    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_share_transformation, path_arg, empty_kwargs))
    tasks.append(GenerateFileTask(Python.import_module("rqmojo.data.bundle").gen_future_info, path_arg, empty_kwargs))

    return tasks^


def run_tasks(tasks: List[PythonObject], concurrency: Int = 1, rqdatac_kwargs: Optional[PythonObject] = None) raises -> Bool:
    var multiprocessing = Python.import_module("multiprocessing")
    var ctypes = Python.import_module("ctypes")
    from rqmojo.utils.concurrent import ProgressedProcessPoolExecutor

    var final_rqdatac_kwargs = rqdatac_kwargs
    if final_rqdatac_kwargs is None:
        final_rqdatac_kwargs = Python.dict()

    var succeed = multiprocessing.Value(ctypes.c_bool, True)
    var executor = ProgressedProcessPoolExecutor(
        max_workers=concurrency,
        initializer=process_init,
        initargs=Python.tuple(succeed, final_rqdatac_kwargs)
    )
    for task in tasks:
        executor.submit(task)
    return bool(succeed.value)


def update_bundle(
    path: String,
    create: Bool,
    enable_compression: Bool = False,
    concurrency: Int = 1,
    rqdata_kwargs: Optional[PythonObject] = None,
    h5_kwargs: Optional[PythonObject] = None
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
                    var combined: List[PythonObject] = []
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
            var trading_dt_converted: List[Int] = []
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
