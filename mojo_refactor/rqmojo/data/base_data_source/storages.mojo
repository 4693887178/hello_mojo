"""
RQAlpha Mojo - Storages
Ported from rqalpha/data/base_data_source/storages.py
Uses Python h5py/numpy/pandas for HDF5 operations via Python interop
"""

from std.collections import List, Dict, Optional, Set
from std.python import Python, PythonObject
from rqmojo.utils.datetime_func import convert_date_to_date_int
from rqmojo.utils.typing import DateTimeDate, DateTime
from rqmojo.const import COMMISSION_TYPE, MARKET, INSTRUMENT_TYPE


struct FuturesTradingParameters(Movable, Copyable, ImplicitlyCopyable):
    var close_commission_ratio: Float64
    var close_commission_today_ratio: Float64
    var commission_type: COMMISSION_TYPE
    var open_commission_ratio: Float64
    var long_margin_ratio: Float64
    var short_margin_ratio: Float64

    def __init__(out self):
        self.close_commission_ratio = 0.0
        self.close_commission_today_ratio = 0.0
        self.commission_type = COMMISSION_TYPE.BY_MONEY
        self.open_commission_ratio = 0.0
        self.long_margin_ratio = 0.0
        self.short_margin_ratio = 0.0

    def __init__(
        out self,
        close_commission_ratio: Float64,
        close_commission_today_ratio: Float64,
        commission_type: COMMISSION_TYPE,
        open_commission_ratio: Float64,
        long_margin_ratio: Float64,
        short_margin_ratio: Float64
    ):
        self.close_commission_ratio = close_commission_ratio
        self.close_commission_today_ratio = close_commission_today_ratio
        self.commission_type = commission_type
        self.open_commission_ratio = open_commission_ratio
        self.long_margin_ratio = long_margin_ratio
        self.short_margin_ratio = short_margin_ratio


struct ExchangeTradingCalendarStore(Movable):
    var _f: PythonObject
    var _py: Python

    def __init__(out self, f: PythonObject):
        self._f = f
        self._py = Python()

    def get_trading_calendar(ref self) raises -> PythonObject:
        var np = self._py.import_module("numpy")
        var pandas = self._py.import_module("pandas")
        var data = np.load(self._f, allow_pickle=False)
        var str_list = self._py.list()
        for d in data:
            str_list.append(self._py.str(d))
        return pandas.to_datetime(str_list)


struct FutureInfoStore(Movable):
    var _default_data: PythonObject
    var _custom_data: PythonObject
    var _py: Python

    def __init__(out self, f_path: String, custom_future_info: PythonObject) raises:
        self._py = Python()
        self._custom_data = custom_future_info
        var codecs = self._py.import_module("codecs")
        var json = self._py.import_module("json")
        
        var f = codecs.open(f_path, "r", encoding="utf-8")
        var json_data = json.load(f)
        f.close()
        
        self._default_data = self._py.dict()
        for item in json_data:
            var order_book_id = item.get("order_book_id")
            var underlying_symbol = item.get("underlying_symbol")
            var key = order_book_id if order_book_id else underlying_symbol
            var processed = self._process_future_info_item(item)
            self._default_data[key] = processed

    def _process_future_info_item(mut self, item: PythonObject) raises -> PythonObject:
        var result = self._py.dict()
        for k in item.keys():
            result[k] = item[k]
        var commission_type_str = result.get("commission_type")
        if commission_type_str == "by_volume":
            result["commission_type"] = COMMISSION_TYPE.BY_VOLUME.value
        else:
            result["commission_type"] = COMMISSION_TYPE.BY_MONEY.value
        return result

    def get_future_info(mut self, order_book_id: String, underlying_symbol: String) raises -> FuturesTradingParameters:
        var custom_info = self._custom_data.get(order_book_id)
        if custom_info is None:
            custom_info = self._custom_data.get(underlying_symbol)
        
        var info = self._default_data.get(order_book_id)
        if info is None:
            info = self._default_data.get(underlying_symbol)
        
        if custom_info:
            var copy_mod = self._py.import_module("copy")
            if info:
                info = copy_mod.deepcopy(info)
            else:
                info = self._py.dict()
            info.update(custom_info)
        elif info is None:
            raise "unsupported future instrument"
        
        return self._to_namedtuple(info)

    def _to_namedtuple(mut self, info: PythonObject) raises -> FuturesTradingParameters:
        var futures_info = self._py.dict()
        for k in info.keys():
            futures_info[k] = info[k]
        
        var margin_rate = futures_info.get("margin_rate")
        futures_info["long_margin_ratio"] = margin_rate
        futures_info["short_margin_ratio"] = margin_rate
        
        try:
            futures_info.pop("margin_rate")
        except:
            pass
        
        try:
            futures_info.pop("tick_size")
        except:
            pass
        
        try:
            futures_info.pop("order_book_id")
        except:
            try:
                futures_info.pop("underlying_symbol")
            except:
                pass
        
        var comm_type_str = futures_info.get("commission_type")
        var comm_type = COMMISSION_TYPE.BY_MONEY
        if comm_type_str == "by_volume" or comm_type_str == COMMISSION_TYPE.BY_VOLUME.value:
            comm_type = COMMISSION_TYPE.BY_VOLUME
        
        var close_comm = futures_info.get("close_commission_ratio", 0.0)
        var close_today_comm = futures_info.get("close_commission_today_ratio", 0.0)
        var open_comm = futures_info.get("open_commission_ratio", 0.0)
        var long_margin = futures_info.get("long_margin_ratio", 0.0)
        var short_margin = futures_info.get("short_margin_ratio", 0.0)
        
        return FuturesTradingParameters(
            close_commission_ratio=Float64(py=close_comm),
            close_commission_today_ratio=Float64(py=close_today_comm),
            commission_type=comm_type,
            open_commission_ratio=Float64(py=open_comm),
            long_margin_ratio=Float64(py=long_margin),
            short_margin_ratio=Float64(py=short_margin)
        )

    def get_tick_size(mut self, order_book_id: String, underlying_symbol: String) raises -> Float64:
        var custom_info = self._custom_data.get(order_book_id)
        if custom_info is None:
            custom_info = self._custom_data.get(underlying_symbol)
        
        var info = self._default_data.get(order_book_id)
        if info is None:
            info = self._default_data.get(underlying_symbol)
        
        if custom_info:
            var copy_mod = self._py.import_module("copy")
            if info:
                info = copy_mod.deepcopy(info)
            else:
                info = self._py.dict()
            info.update(custom_info)
        elif info is None:
            raise "unsupported future instrument"
        
        var tick_size = info.get("tick_size", 1.0)
        return Float64(py=tick_size)


struct ShareTransformationStore(Movable):
    var _share_transformation: PythonObject
    var _py: Python

    def __init__(out self, f_path: String) raises:
        self._py = Python()
        var codecs = self._py.import_module("codecs")
        var json = self._py.import_module("json")
        
        var f = codecs.open(f_path, "r", encoding="utf-8")
        self._share_transformation = json.load(f)
        f.close()

    def get_share_transformation(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        try:
            var transformation_data = self._share_transformation[order_book_id]
            return transformation_data
        except:
            return None


struct DayBarStore(Movable):
    var _path: String
    var _py: Python

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()

    def get_bars(mut self, order_book_id: String) raises -> PythonObject:
        var h5py = self._py.import_module("h5py")
        var np = self._py.import_module("numpy")
        
        var h5 = h5py.File(self._path, "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            return data
        except:
            h5.close()
            return np.empty(0)

    def get_date_range(mut self, order_book_id: String) raises -> PythonObject:
        var h5py = self._py.import_module("h5py")
        
        var h5 = h5py.File(self._path, "r")
        try:
            var data = h5[order_book_id]
            var dt1 = data[0]["datetime"]
            var dt2 = data[-1]["datetime"]
            h5.close()
            var result = self._py.list()
            result.append(dt1)
            result.append(dt2)
            return result
        except:
            h5.close()
            var result = self._py.list()
            result.append(20050104)
            result.append(20050104)
            return result


struct FutureDayBarStore(Movable):
    var _path: String
    var _py: Python

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()

    def get_bars(mut self, order_book_id: String) raises -> PythonObject:
        var h5py = self._py.import_module("h5py")
        var np = self._py.import_module("numpy")
        
        var h5 = h5py.File(self._path, "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            return data
        except:
            h5.close()
            return np.empty(0)


struct DividendStore(Movable):
    var _path: String
    var _py: Python

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()

    def get_dividend(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        var h5py = self._py.import_module("h5py")
        
        var h5 = h5py.File(self._path, "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            return data
        except:
            h5.close()
            return None


struct YieldCurveStore(Movable):
    var _data: PythonObject
    var _py: Python

    def __init__(out self, path: String) raises:
        self._py = Python()
        var h5py = self._py.import_module("h5py")
        
        var h5 = h5py.File(path, "r")
        self._data = h5["data"][:]
        h5.close()

    def get_yield_curve(mut self, start_date: DateTime, end_date: DateTime, tenor: Optional[String]) raises -> Optional[PythonObject]:
        var d1 = convert_date_to_date_int(start_date)
        var d2 = convert_date_to_date_int(end_date)
        
        var dates = self._data["date"]
        var s = dates.searchsorted(d1)
        var e = dates.searchsorted(d2, side="right")
        
        if e == len(self._data):
            e -= 1
        if self._data[e]["date"] == d2:
            e += 1
        
        if e < s:
            return None
        
        var pandas = self._py.import_module("pandas")
        var np = self._py.import_module("numpy")
        var builtins = self._py.import_module("builtins")
        var py_slice = builtins.slice(s, e)
        var sliced_data = self._data[py_slice]
        var df = pandas.DataFrame(sliced_data)
        return df


struct SimpleFactorStore(Movable):
    var _path: String
    var _py: Python
    var _cache: Dict[String, PythonObject]

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()
        self._cache = Dict[String, PythonObject]()

    def get_factors(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        if order_book_id in self._cache:
            return self._cache[order_book_id]
        
        var h5py = self._py.import_module("h5py")
        
        var h5 = h5py.File(self._path, "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            self._cache[order_book_id] = data
            return data
        except:
            h5.close()
            return None


struct DateSet(Movable):
    var _f: PythonObject
    var _py: Python
    var _days_cache: Dict[String, PythonObject]

    def __init__(out self, f: PythonObject):
        self._f = f
        self._py = Python()
        self._days_cache = Dict[String, PythonObject]()

    def get_days(mut self, order_book_id: String) raises -> PythonObject:
        if order_book_id in self._days_cache:
            return self._days_cache[order_book_id]
        
        var h5py = self._py.import_module("h5py")
        var np = self._py.import_module("numpy")
        
        var h5 = h5py.File(self._f, "r")
        try:
            var days = h5[order_book_id][:]
            h5.close()
            self._days_cache[order_book_id] = days
            return days
        except:
            h5.close()
            var empty_list = self._py.list()
            return empty_list

    def contains(mut self, order_book_id: String, dates: List[Int]) raises -> List[Bool]:
        var date_array = self.get_days(order_book_id)
        var np = self._py.import_module("numpy")
        var builtins = self._py.import_module("builtins")
        
        if len(date_array) == 0:
            return List[Bool]()
        
        var date_set = builtins.set(date_array.tolist())
        var result = List[Bool]()
        for i in range(len(dates)):
            var d = dates[i]
            result.append(d in date_set)
        return result^


def open_h5(path: String) raises -> PythonObject:
    var _ = Python()
    var h5py = Python().import_module("h5py")
    return h5py.File(path, "r")


def h5_file(path: String) raises -> PythonObject:
    return open_h5(path)


def load_instruments_from_pkl(pkl_path: String, future_info_store: FutureInfoStore) raises -> PythonObject:
    var _ = Python()
    var py = Python()
    var pickle = py.import_module("pickle")
    var builtins = py.import_module("builtins")
    var datetime = py.import_module("datetime")
    
    var f = builtins.open(pkl_path, "rb")
    var data = pickle.load(f)
    f.close()
    
    var instruments = py.list()
    for i in data:
        var i_type = i.get("type")
        if i_type == "Future":
            var order_book_id = i.get("order_book_id")
            if order_book_id and "Future" in py.str(order_book_id):
                i["listed_date"] = datetime.datetime(1990, 1, 1)
        
        instruments.append(i)
    
    return instruments


def create_exchange_trading_calendar_store(f: PythonObject) -> ExchangeTradingCalendarStore:
    return ExchangeTradingCalendarStore(f)


def create_future_info_store(f_path: String, custom_future_info: PythonObject) raises -> FutureInfoStore:
    return FutureInfoStore(f_path, custom_future_info)


def create_share_transformation_store(f_path: String) raises -> ShareTransformationStore:
    return ShareTransformationStore(f_path)


def create_day_bar_store(path: String) -> DayBarStore:
    return DayBarStore(path)


def create_future_day_bar_store(path: String) -> FutureDayBarStore:
    return FutureDayBarStore(path)


def create_dividend_store(path: String) -> DividendStore:
    return DividendStore(path)


def create_yield_curve_store(path: String) raises -> YieldCurveStore:
    return YieldCurveStore(path)


def create_simple_factor_store(path: String) -> SimpleFactorStore:
    return SimpleFactorStore(path)


def create_date_set(f: PythonObject) -> DateSet:
    return DateSet(f)
