"""
RQAlpha Mojo - Storages
Ported from rqalpha/data/base_data_source/storages.py
Uses Python h5py/numpy/pandas for HDF5 operations
"""

from std.collections import List, Dict
from python import Python, PythonObject
from rqmojo.utils.datetime_func import convert_date_to_date_int, Date, DateTime
from rqmojo.utils.typing import DateLike


struct FuturesTradingParameters(Movable, Copyable, ImplicitlyCopyable):
    var close_commission_ratio: Float64
    var close_commission_today_ratio: Float64
    var commission_type: String
    var open_commission_ratio: Float64
    var long_margin_ratio: Float64
    var short_margin_ratio: Float64

    def __init__(out self):
        self.close_commission_ratio = 0.0
        self.close_commission_today_ratio = 0.0
        self.commission_type = ""
        self.open_commission_ratio = 0.0
        self.long_margin_ratio = 0.0
        self.short_margin_ratio = 0.0

    def __init__(
        out self,
        close_commission_ratio: Float64,
        close_commission_today_ratio: Float64,
        commission_type: String,
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


def _py_to_float(obj: PythonObject) raises -> Float64:
    var py = Python()
    var builtins = py.import_module("builtins")
    var f = builtins.float(obj)
    return f


def _py_to_int(obj: PythonObject) raises -> Int:
    var py = Python()
    var builtins = py.import_module("builtins")
    var i = builtins.int(obj)
    return i


def _py_to_string(obj: PythonObject) raises -> String:
    var py = Python()
    var builtins = py.import_module("builtins")
    var s = builtins.str(obj)
    return s


def _is_none(obj: PythonObject) raises -> Bool:
    var py = Python()
    var builtins = py.import_module("builtins")
    return obj == builtins.None


struct ExchangeTradingCalendarStore(Movable):
    var _f: PythonObject

    def __init__(out self, f: PythonObject):
        self._f = f

    def get_trading_calendar(ref self) raises -> PythonObject:
        var py = Python()
        var np = py.import_module("numpy")
        var pandas = py.import_module("pandas")
        var builtins = py.import_module("builtins")
        
        var data = np.load(self._f, allow_pickle=False)
        var str_list = builtins.list()
        for i in range(len(data)):
            str_list.append(builtins.str(data[i]))
        return pandas.to_datetime(str_list)


struct FutureInfoStore(Movable):
    var _default_data: PythonObject
    var _custom_data: PythonObject
    var _cache: Dict[String, FuturesTradingParameters]
    var _tick_size_cache: Dict[String, Float64]

    def __init__(out self, f: String, custom_future_info: PythonObject) raises:
        var py = Python()
        var json = py.import_module("json")
        var builtins = py.import_module("builtins")
        
        var json_file = builtins.open(f, "r")
        var json_data = json.load(json_file)
        json_file.close()
        
        self._default_data = builtins.dict()
        for item in json_data:
            var key = item.get("order_book_id")
            if _is_none(key):
                key = item.get("underlying_symbol")
            if not _is_none(key):
                var processed = self._process_future_info_item(item)
                self._default_data[key] = processed
        
        self._custom_data = custom_future_info
        self._cache = Dict[String, FuturesTradingParameters]()
        self._tick_size_cache = Dict[String, Float64]()
        
        var first_key = builtins.next(builtins.iter(self._default_data))
        var first_item = self._default_data[first_key]
        if not ("margin_rate" in first_item):
            raise Error("The bundle data you are using is too old, please update it to lastest before using")

    def _process_future_info_item(ref self, item: PythonObject) raises -> PythonObject:
        var py = Python()
        var builtins = py.import_module("builtins")
        var result = builtins.dict(item)
        var ct = item["commission_type"]
        if ct == "by_volume":
            result["commission_type"] = "by_volume"
        elif ct == "by_money":
            result["commission_type"] = "by_money"
        return result

    def get_future_info(mut self, order_book_id: String, underlying_symbol: String) raises -> FuturesTradingParameters:
        var cache_key = order_book_id + "|" + underlying_symbol
        try:
            return self._cache[cache_key]
        except:
            pass
        
        var py = Python()
        var builtins = py.import_module("builtins")
        var info: PythonObject
        var found = False
        
        var custom_info = self._custom_data.get(order_book_id)
        if _is_none(custom_info):
            custom_info = self._custom_data.get(underlying_symbol)
        
        var default_info = self._default_data.get(order_book_id)
        if _is_none(default_info):
            default_info = self._default_data.get(underlying_symbol)
        
        if not _is_none(custom_info):
            if not _is_none(default_info):
                info = builtins.dict(default_info)
                info.update(custom_info)
            else:
                info = builtins.dict(custom_info)
            found = True
        elif not _is_none(default_info):
            info = default_info
            found = True
        
        if not found:
            raise Error("unsupported future instrument " + order_book_id)
        
        var result = self._to_namedtuple(info)
        self._cache[cache_key] = result
        return result

    def _to_namedtuple(ref self, info: PythonObject) raises -> FuturesTradingParameters:
        var result = FuturesTradingParameters()
        result.close_commission_ratio = _py_to_float(info["close_commission_ratio"])
        result.close_commission_today_ratio = _py_to_float(info["close_commission_today_ratio"])
        result.open_commission_ratio = _py_to_float(info["open_commission_ratio"])
        var margin_rate = _py_to_float(info["margin_rate"])
        result.long_margin_ratio = margin_rate
        result.short_margin_ratio = margin_rate
        result.commission_type = _py_to_string(info["commission_type"])
        return result

    def get_tick_size(mut self, order_book_id: String, underlying_symbol: String) raises -> Float64:
        var cache_key = order_book_id + "|" + underlying_symbol
        try:
            return self._tick_size_cache[cache_key]
        except:
            pass
        
        var py = Python()
        var builtins = py.import_module("builtins")
        var info: PythonObject
        var found = False
        
        var custom_info = self._custom_data.get(order_book_id)
        if _is_none(custom_info):
            custom_info = self._custom_data.get(underlying_symbol)
        
        var default_info = self._default_data.get(order_book_id)
        if _is_none(default_info):
            default_info = self._default_data.get(underlying_symbol)
        
        if not _is_none(custom_info):
            if not _is_none(default_info):
                info = builtins.dict(default_info)
                info.update(custom_info)
            else:
                info = builtins.dict(custom_info)
            found = True
        elif not _is_none(default_info):
            info = default_info
            found = True
        
        if not found:
            raise Error("unsupported future instrument " + order_book_id)
        
        var tick_size = _py_to_float(info["tick_size"])
        self._tick_size_cache[cache_key] = tick_size
        return tick_size


def load_instruments_from_pkl(pkl_path: String, ref future_info_store: FutureInfoStore) raises -> List[PythonObject]:
    var py = Python()
    var pickle = py.import_module("pickle")
    var datetime = py.import_module("datetime")
    var builtins = py.import_module("builtins")
    
    var instruments = List[PythonObject]()
    var unsupported_types = List[String]()
    
    var f = builtins.open(pkl_path, "rb")
    var pkl_data = pickle.load(f)
    f.close()
    
    for i in pkl_data:
        var item = i
        var item_type = _py_to_string(item["type"])
        var order_book_id = _py_to_string(item["order_book_id"])
        
        if item_type == "Future":
            if order_book_id.startswith("88") or order_book_id.startswith("99"):
                item["listed_date"] = datetime.datetime(1990, 1, 1)
        
        instruments.append(item)
    
    return instruments^


struct ShareTransformationStore(Movable):
    var _share_transformation: PythonObject

    def __init__(out self, f: String) raises:
        var py = Python()
        var codecs = py.import_module("codecs")
        var json = py.import_module("json")
        
        var store = codecs.open(f, "r", encoding="utf-8")
        self._share_transformation = json.load(store)
        store.close()

    def get_share_transformation(ref self, order_book_id: String) raises -> Optional[Tuple[String, Float64]]:
        try:
            var transformation_data = self._share_transformation[order_book_id]
            var successor = _py_to_string(transformation_data["successor"])
            var ratio = _py_to_float(transformation_data["share_conversion_ratio"])
            return (successor, ratio)
        except:
            return None


def _file_path(path: String) raises -> PythonObject:
    var py = Python()
    var sys = py.import_module("sys")
    var locale = py.import_module("locale")
    var builtins = py.import_module("builtins")
    
    if sys.platform == "win32":
        try:
            var l_obj = locale.getlocale(locale.LC_ALL)
            var l = l_obj[1]
            if not _is_none(l):
                var l_str = builtins.str(l)
                if l_str.lower() == "utf-8":
                    return builtins.str(path).encode("utf-8")
        except:
            pass
    return builtins.str(path)


def _create_dtype(ref np: PythonObject) raises -> PythonObject:
    var py = Python()
    var builtins = py.import_module("builtins")
    var dtype_list = builtins.list()
    var t1 = builtins.tuple(builtins.list([builtins.str("datetime"), np.uint64]))
    var t2 = builtins.tuple(builtins.list([builtins.str("open"), np.float64]))
    var t3 = builtins.tuple(builtins.list([builtins.str("close"), np.float64]))
    var t4 = builtins.tuple(builtins.list([builtins.str("high"), np.float64]))
    var t5 = builtins.tuple(builtins.list([builtins.str("low"), np.float64]))
    var t6 = builtins.tuple(builtins.list([builtins.str("volume"), np.float64]))
    dtype_list.append(t1)
    dtype_list.append(t2)
    dtype_list.append(t3)
    dtype_list.append(t4)
    dtype_list.append(t5)
    dtype_list.append(t6)
    return np.dtype(dtype_list)


def _create_future_dtype(ref np: PythonObject) raises -> PythonObject:
    var py = Python()
    var builtins = py.import_module("builtins")
    var base_dtype = _create_dtype(np)
    var extra = builtins.list()
    var t = builtins.tuple(builtins.list([builtins.str("open_interest"), builtins.str("<f8")]))
    extra.append(t)
    return np.dtype(base_dtype.descr + extra)


struct DayBarStore(Movable):
    var _path: String
    var _default_dtype: PythonObject

    def __init__(out self, path: String) raises:
        var py = Python()
        var os = py.import_module("os")
        var np = py.import_module("numpy")
        
        if not os.path.exists(path):
            raise Error("File " + path + " not exist, please update bundle.")
        
        self._path = path
        self._default_dtype = _create_dtype(np)

    def get_bars(ref self, order_book_id: String) raises -> PythonObject:
        var py = Python()
        var h5py = py.import_module("h5py")
        var np = py.import_module("numpy")
        
        var path_obj = _file_path(self._path)
        var h5 = h5py.File(path_obj, "r")
        try:
            var data = h5[order_book_id]
            return data[:]
        except:
            return np.empty(0, self._default_dtype)
        finally:
            h5.close()

    def get_date_range(ref self, order_book_id: String) raises -> Tuple[Int, Int]:
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var path_obj = _file_path(self._path)
        var h5 = h5py.File(path_obj, "r")
        try:
            var data = h5[order_book_id]
            var first = data[0]
            var last = data[-1]
            var start_dt = _py_to_int(first["datetime"])
            var end_dt = _py_to_int(last["datetime"])
            return (start_dt, end_dt)
        except:
            return (20050104, 20050104)
        finally:
            h5.close()


struct FutureDayBarStore(Movable):
    var _path: String
    var _default_dtype: PythonObject

    def __init__(out self, path: String) raises:
        var py = Python()
        var os = py.import_module("os")
        var np = py.import_module("numpy")
        
        if not os.path.exists(path):
            raise Error("File " + path + " not exist, please update bundle.")
        
        self._default_dtype = _create_future_dtype(np)
        self._path = path

    def get_bars(ref self, order_book_id: String) raises -> PythonObject:
        var py = Python()
        var h5py = py.import_module("h5py")
        var np = py.import_module("numpy")
        
        var path_obj = _file_path(self._path)
        var h5 = h5py.File(path_obj, "r")
        try:
            var data = h5[order_book_id]
            return data[:]
        except:
            return np.empty(0, self._default_dtype)
        finally:
            h5.close()

    def get_date_range(ref self, order_book_id: String) raises -> Tuple[Int, Int]:
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var path_obj = _file_path(self._path)
        var h5 = h5py.File(path_obj, "r")
        try:
            var data = h5[order_book_id]
            var first = data[0]
            var last = data[-1]
            var start_dt = _py_to_int(first["datetime"])
            var end_dt = _py_to_int(last["datetime"])
            return (start_dt, end_dt)
        except:
            return (20050104, 20050104)
        finally:
            h5.close()


struct DividendStore(Movable):
    var _path: String

    def __init__(out self, path: String):
        self._path = path

    def get_dividend(ref self, order_book_id: String) raises -> Optional[PythonObject]:
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var path_obj = _file_path(self._path)
        var h5 = h5py.File(path_obj, "r")
        try:
            var data = h5[order_book_id]
            return data[:]
        except:
            return None
        finally:
            h5.close()


struct YieldCurveStore(Movable):
    var _data: PythonObject

    def __init__(out self, path: String) raises:
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var path_obj = _file_path(path)
        var h5 = h5py.File(path_obj, "r")
        try:
            self._data = h5["data"][:]
        finally:
            h5.close()

    def get_yield_curve(ref self, start_date: DateLike, end_date: DateLike, tenor: Optional[String] = None) raises -> Optional[PythonObject]:
        var py = Python()
        var pandas = py.import_module("pandas")
        var builtins = py.import_module("builtins")
        
        var d1 = _date_like_to_int(start_date)
        var d2 = _date_like_to_int(end_date)
        
        var dates = self._data["date"]
        var s = dates.searchsorted(d1)
        var e = dates.searchsorted(d2, side="right")
        
        var data_len = len(self._data)
        if e == data_len:
            e -= 1
        if _py_to_int(self._data[e]["date"]) == d2:
            e += 1
        
        if e < s:
            return None
        
        var sliced = self._data.__getitem__(builtins.slice(s, e))
        var df = pandas.DataFrame(sliced)
        var date_col = df["date"]
        var str_dates = builtins.list()
        for i in range(len(date_col)):
            str_dates.append(builtins.str(date_col[i]))
        df.index = pandas.to_datetime(str_dates)
        df.drop("date", axis=1, inplace=True)
        
        if tenor != None:
            return df[tenor.value()]
        return df


struct SimpleFactorStore(Movable):
    var _path: String
    var _cache: Dict[String, PythonObject]

    def __init__(out self, path: String):
        self._path = path
        self._cache = Dict[String, PythonObject]()

    def get_factors(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        try:
            return self._cache[order_book_id]
        except:
            pass
        
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var path_obj = _file_path(self._path)
        var h5 = h5py.File(path_obj, "r")
        try:
            var data = h5[order_book_id]
            var result = data[:]
            self._cache[order_book_id] = result
            return result
        except:
            return None
        finally:
            h5.close()


def _date_like_to_int(dt: DateLike) -> Int:
    if dt.isa[Date]():
        return convert_date_to_date_int(dt[Date])
    elif dt.isa[DateTime]():
        var d = dt[DateTime]
        return d.year * 10000 + d.month * 100 + d.day
    elif dt.isa[Int]():
        var val = dt[Int]
        if val > 100000000:
            return val // 1000000
        return val
    return 0


struct DateSet(Movable):
    var _f: String
    var _days_cache: Dict[String, PythonObject]

    def __init__(out self, f: String):
        self._f = f
        self._days_cache = Dict[String, PythonObject]()

    def _get_days(mut self, order_book_id: String) raises -> PythonObject:
        try:
            return self._days_cache[order_book_id]
        except:
            pass
        
        var py = Python()
        var h5py = py.import_module("h5py")
        var builtins = py.import_module("builtins")
        
        var path_obj = _file_path(self._f)
        var h5 = h5py.File(path_obj, "r")
        try:
            var days = h5[order_book_id][:]
            var days_list = days.tolist()
            var days_set = builtins.set(days_list)
            self._days_cache[order_book_id] = days_set
            return days_set
        except:
            var empty_set = builtins.set()
            self._days_cache[order_book_id] = empty_set
            return empty_set
        finally:
            h5.close()

    def contains(mut self, order_book_id: String, dates: List[DateLike]) raises -> Optional[List[Bool]]:
        var date_set = self._get_days(order_book_id)
        
        if len(date_set) == 0:
            return None
        
        var result = List[Bool]()
        for i in range(len(dates)):
            var date_int = _date_like_to_int(dates[i])
            result.append(date_int in date_set)
        
        return result^


def create_exchange_trading_calendar_store(f: PythonObject) -> ExchangeTradingCalendarStore:
    return ExchangeTradingCalendarStore(f)

def create_future_info_store(f: String, custom_future_info: PythonObject) raises -> FutureInfoStore:
    return FutureInfoStore(f, custom_future_info)

def create_share_transformation_store(f: String) raises -> ShareTransformationStore:
    return ShareTransformationStore(f)

def create_day_bar_store(path: String) raises -> DayBarStore:
    return DayBarStore(path)

def create_future_day_bar_store(path: String) raises -> FutureDayBarStore:
    return FutureDayBarStore(path)

def create_dividend_store(path: String) -> DividendStore:
    return DividendStore(path)

def create_yield_curve_store(path: String) raises -> YieldCurveStore:
    return YieldCurveStore(path)

def create_simple_factor_store(path: String) -> SimpleFactorStore:
    return SimpleFactorStore(path)

def create_date_set(f: String) -> DateSet:
    return DateSet(f)
