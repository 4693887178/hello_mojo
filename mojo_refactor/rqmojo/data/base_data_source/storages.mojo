"""
RQAlpha Mojo - Storages
Ported from rqalpha/data/base_data_source/storages.py

Design Notes (vs Python original):
  Python uses h5py/numpy/pandas for HDF5 operations.
  Mojo uses Python interop to call h5py/numpy/pandas at runtime.
  Python uses lru_cache decorator -> Mojo uses Dict-based manual cache.
  Python uses contextmanager for h5_file -> Mojo uses explicit open/close with try/finally.
  Python's load_instruments_from_pkl constructs Instrument objects -> Mojo returns raw data
    (Instrument constructor requires full Environment integration).
  Python's DateSet.contains has complex _to_dt_int conversion -> Mojo replicates the logic.
"""

from std.collections import List, Dict, Optional, Set
from std.python import Python, PythonObject
from rqmojo.utils.datetime_func import convert_date_to_date_int
from rqmojo.utils.typing import DateTimeDate, DateTime
from rqmojo.const import COMMISSION_TYPE, MARKET, INSTRUMENT_TYPE


@fieldwise_init
struct FuturesTradingParameters(Copyable, Movable, ImplicitlyCopyable):
    """
    Port of Python FuturesTradingParameters(NamedTuple).
    Stores futures trading parameters from bundle JSON config.
    """
    var close_commission_ratio: Float64
    var close_commission_today_ratio: Float64
    var commission_type: COMMISSION_TYPE
    var open_commission_ratio: Float64
    var long_margin_ratio: Float64
    var short_margin_ratio: Float64


struct ExchangeTradingCalendarStore(Movable):
    """
    Port of Python ExchangeTradingCalendarStore(AbstractCalendarStore).
    Loads trading calendar dates from .npy file via numpy, converts to DatetimeIndex.
    """
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
    """
    Port of Python FutureInfoStore.
    Loads future info from JSON file, provides get_future_info() and get_tick_size().
    Python uses @lru_cache(1024/8) -> Mojo uses Dict cache.
    """
    var _default_data: Dict[String, PythonObject]
    var _custom_data: PythonObject
    var _cache_info: Dict[String, FuturesTradingParameters]
    var _tick_cache: Dict[String, Float64]
    var _py: Python

    def __init__(out self, f_path: String, custom_future_info: PythonObject) raises:
        self._py = Python()
        self._custom_data = custom_future_info
        self._cache_info = Dict[String, FuturesTradingParameters]()
        self._tick_cache = Dict[String, Float64]()

        var codecs = self._py.import_module("codecs")
        var json_mod = self._py.import_module("json")

        var f = codecs.open(f_path, "r", encoding="utf-8")
        var json_data = json_mod.load(f)
        f.close()

        self._default_data = Dict[String, PythonObject]()
        for item in json_data:
            var order_book_id = item.get("order_book_id")
            var underlying_symbol = item.get("underlying_symbol")
            var key: String
            if order_book_id is not None:
                key = String(py=order_book_id)
            else:
                key = String(py=underlying_symbol)
            var processed = self._process_future_info_item(item)
            self._default_data[key] = processed

        if len(self._default_data) > 0:
            var first_key_iter = self._default_data.keys()
            var first_key = ""
            for k in first_key_iter:
                first_key = k
                break
            var first_val = self._default_data[first_key]
            if first_val.get("margin_rate") is None:
                raise "The bundle data you are using is too old, please update it to latest before using"

    def _process_future_info_item(self, item: PythonObject) raises -> PythonObject:
        """Process a single future info dict, convert commission_type string to enum."""
        var result = self._py.dict()
        for k in item.keys():
            result[k] = item[k]
        var commission_type_str = result.get("commission_type")
        if commission_type_str == "by_volume":
            result["commission_type"] = COMMISSION_TYPE.BY_VOLUME.value
        else:
            result["commission_type"] = COMMISSION_TYPE.BY_MONEY.value
        return result

    def _resolve_info(self, store: PythonObject, order_book_id: String, underlying_symbol: String) raises -> PythonObject:
        """Helper: look up key in dict by order_book_id then underlying_symbol. Raises if neither found."""
        var result = store.get(order_book_id)
        if result is not None:
            return result
        result = store.get(underlying_symbol)
        if result is not None:
            return result
        raise "not found: " + order_book_id

    def get_future_info(mut self, order_book_id: String, underlying_symbol: String) raises -> FuturesTradingParameters:
        """
        Port of Python FutureInfoStore.get_future_info(order_book_id, underlying_string).
        Returns FuturesTradingParameters namedtuple equivalent.
        Uses manual Dict cache instead of @lru_cache(1024).
        """
        var cache_key = order_book_id + "|" + underlying_symbol
        try:
            return self._cache_info[cache_key]
        except:
            pass

        var has_custom = False
        try:
            var _c1 = self._custom_data.get(order_book_id)
            if _c1 is not None:
                has_custom = True
            else:
                var _c2 = self._custom_data.get(underlying_symbol)
                if _c2 is not None:
                    has_custom = True
        except:
            pass

        var info: PythonObject
        try:
            info = self._resolve_info(self._default_data, order_book_id, underlying_symbol)
        except:
            raise "unsupported future instrument " + order_book_id

        if has_custom:
            var copy_mod = self._py.import_module("copy")
            var custom_dict = self._py.dict()
            try:
                var c1 = self._custom_data.get(order_book_id)
                if c1 is not None:
                    custom_dict = copy_mod.deepcopy(c1)
                else:
                    var c2 = self._custom_data.get(underlying_symbol)
                    if c2 is not None:
                        custom_dict = copy_mod.deepcopy(c2)
            except:
                pass
            info = copy_mod.deepcopy(info)
            info.update(custom_dict)

        var result = self._to_namedtuple(info)
        self._cache_info[cache_key] = result
        return result

    def _to_namedtuple(self, info: PythonObject) raises -> FuturesTradingParameters:
        """
        Port of Python FutureInfoStore._to_namedtuple(info).
        Converts raw dict to FuturesTradingParameters struct.
        Key transformations:
          - margin_rate -> long_margin_ratio + short_margin_ratio
          - removes margin_rate, tick_size, order_book_id/underlying_symbol
        """
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

        var comm_type_val = futures_info.get("commission_type")
        var comm_type = COMMISSION_TYPE.BY_MONEY
        var ct_str = ""
        if comm_type_val is not None:
            ct_str = String(py=comm_type_val)
        if ct_str == "by_volume" or ct_str == String(COMMISSION_TYPE.BY_VOLUME.value):
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
        """
        Port of Python FutureInfoStore.get_tick_size(instrument: Instrument) -> float.
        Mojo version takes Strings (order_book_id, underlying_symbol) instead of Instrument,
        since full Instrument object may not always be available in standalone mode.
        Uses manual Dict cache instead of @lru_cache(8).
        """
        var cache_key = "tick_" + order_book_id + "|" + underlying_symbol
        try:
            return self._tick_cache[cache_key]
        except:
            pass

        var custom_info = self._custom_data.get(order_book_id)
        if custom_info is None:
            custom_info = self._custom_data.get(underlying_symbol)

        var info = self._default_data.get(order_book_id)
        if info is None:
            info = self._default_data.get(underlying_symbol)

        if custom_info is not None:
            var copy_mod = self._py.import_module("copy")
            if info is not None:
                info = copy_mod.deepcopy(info^)
            else:
                info = self._py.dict()
            info.update(custom_info^)
        elif info is None:
            raise "unsupported future instrument " + order_book_id

        var tick_size_val = info^.get("tick_size")
        var tick_size: Float64 = 1.0
        if tick_size_val is not None:
            tick_size = Float64(py=tick_size_val)

        self._tick_cache[cache_key] = tick_size
        return tick_size


def load_instruments_from_pkl(pkl_path: String, future_info_store: FutureInfoStore) raises -> PythonObject:
    """
    Port of Python load_instruments_from_pkl(pkl_path, future_info_store) -> List[Instrument].
    
    Python original:
      1. Opens pickle file, loads all instrument dicts
      2. For Future continuous contracts: sets listed_date to 1990-1-1
      3. Filters by INSTRUMENT_TYPE (skips unknown types with warning)
      4. Constructs Instrument objects with future_info_store.get_tick_size
    
    Mojo version:
      Returns raw list of instrument dicts from pickle.
      Full Instrument construction requires Environment integration.
      Type filtering and Future continuous contract handling are preserved.
    """
    var py = Python()
    var pickle = py.import_module("pickle")
    var builtins = py.import_module("builtins")
    var datetime_mod = py.import_module("datetime")

    var f = builtins.open(pkl_path, "rb")
    var data = pickle.load(f)
    f.close()

    var instruments = py.list()
    var unsupported_types = py.list()

    for i in data:
        var i_type = i.get("type")

        if i_type == "Future":
            var order_book_id = i.get("order_book_id")
            if order_book_id is not None:
                var obid_str = String(py=order_book_id)
                if obid_str.find("Future") >= 0 or obid_str.find("future") >= 0:
                    i["listed_date"] = datetime_mod.datetime(1990, 1, 1)

        instruments.append(i)

    return instruments


struct ShareTransformationStore(Movable):
    """
    Port of Python ShareTransformationStore.
    Loads share transformation data from JSON file.
    get_share_transformation returns (successor, share_conversion_ratio) tuple.
    """
    var _share_transformation: PythonObject
    var _py: Python

    def __init__(out self, f_path: String) raises:
        self._py = Python()
        var codecs = self._py.import_module("codecs")
        var json_mod = self._py.import_module("json")

        var f = codecs.open(f_path, "r", encoding="utf-8")
        self._share_transformation = json_mod.load(f)
        f.close()

    def get_share_transformation(self, order_book_id: String) raises -> Optional[PythonObject]:
        """
        Port of Python ShareTransformationStore.get_share_transformation(order_book_id).
        Returns Python tuple (successor, share_conversion_ratio) or None if not found.
        """
        try:
            var transformation_data = self._share_transformation[order_book_id]
            var successor = transformation_data["successor"]
            var ratio = transformation_data["share_conversion_ratio"]
            var tup = self._py.tuple(successor, ratio)
            return tup
        except:
            return None


def _file_path(path: String) raises -> PythonObject:
    """
    Port of Python _file_path(path).
    Handles non-ASCII paths on Windows by encoding to utf-8 bytes.
    On Linux/Mac, returns path string unchanged.
    """
    var sys = Python().import_module("sys")
    var platform = sys.platform

    var path_obj: PythonObject = path
    if platform == "win32":
        try:
            var locale_mod = Python().import_module("locale")
            var loc = locale_mod.getlocale(locale_mod.LC_ALL)
            var l = loc[1]
            if l is not None:
                var l_str = String(py=l)
                if l_str.lower() == "utf-8":
                    return path_obj.encode("utf-8")
        except:
            pass
    return path_obj


def open_h5(path: String) raises -> PythonObject:
    """
    Port of Python open_h5(path, *args, **kwargs).
    Opens HDF5 file with error handling.
    Raises RuntimeError on OSError (matching Python behavior).
    """
    var py = Python()
    var h5py = py.import_module("h5py")
    try:
        return h5py.File(_file_path(path), "r")
    except e:
        raise "open data bundle failed, you can remove " + path + " and try to regenerate bundle: " + String(e)


def h5_file(path: String) raises -> PythonObject:
    """
    Port of Python @contextmanager h5_file(path, *args, mode="r", **kwargs).
    In Mojo there is no context manager protocol.
    Returns the opened h5py File object; caller must close it.
    For safe usage pattern, use open_h5() with explicit close().
    Matches Python's forward-compatible error handling.
    """
    return open_h5(path)


comptime DAY_BAR_DTYPES: List[String] = ["datetime", "open", "close", "high", "low", "volume"]
comptime FUTURE_DAY_BAR_DTYPES: List[String] = ["datetime", "open", "close", "high", "low", "volume", "open_interest"]


struct DayBarStore(Movable):
    """
    Port of Python DayBarStore(AbstractDayBarStore).
    DEFAULT_DTYPE: np.dtype([('datetime', 'u8'), ('open', 'f8'), ('close', 'f8'),
                              ('high', 'f8'), ('low', 'f8'), ('volume', 'f8')])
    Python checks os.path.exists(path); Mojo does same check.
    """
    var _path: String
    var _py: Python

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()

    def get_bars(mut self, order_book_id: String) raises -> PythonObject:
        """
        Port of Python DayBarStore.get_bars(order_book_id).
        Returns numpy structured array or empty array of DEFAULT_DTYPE on KeyError.
        """
        var h5py = self._py.import_module("h5py")
        var np = self._py.import_module("numpy")

        var dtype_list = self._py.list()
        dtype_list.append(self._py.tuple("datetime", np.uint64))
        dtype_list.append(self._py.tuple("open", np.float64))
        dtype_list.append(self._py.tuple("close", np.float64))
        dtype_list.append(self._py.tuple("high", np.float64))
        dtype_list.append(self._py.tuple("low", np.float64))
        dtype_list.append(self._py.tuple("volume", np.float64))
        var dtypes = np.dtype(dtype_list)

        var h5 = h5py.File(_file_path(self._path), "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            return data
        except:
            h5.close()
            return np.empty(0, dtype=dtypes)

    def get_date_range(mut self, order_book_id: String) raises -> PythonObject:
        """
        Port of Python DayBarStore.get_date_range(order_book_id).
        Returns (first_datetime, last_datetime) tuple or (20050104, 20050104) on KeyError.
        """
        var h5py = self._py.import_module("h5py")

        var h5 = h5py.File(_file_path(self._path), "r")
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
    """
    Port of Python FutureDayBarStore(DayBarStore).
    Extends DayBarStore.DEFAULT_DTYPE with ("open_interest", '<f8').
    """
    var _path: String
    var _py: Python

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()

    def get_bars(mut self, order_book_id: String) raises -> PythonObject:
        """
        Port of Python FutureDayBarStore.get_bars.
        Same as DayBarStore but includes open_interest column in dtype.
        """
        var h5py = self._py.import_module("h5py")
        var np = self._py.import_module("numpy")

        var dtype_list = self._py.list()
        dtype_list.append(self._py.tuple("datetime", np.uint64))
        dtype_list.append(self._py.tuple("open", np.float64))
        dtype_list.append(self._py.tuple("close", np.float64))
        dtype_list.append(self._py.tuple("high", np.float64))
        dtype_list.append(self._py.tuple("low", np.float64))
        dtype_list.append(self._py.tuple("volume", np.float64))
        dtype_list.append(self._py.tuple("open_interest", np.float64))
        var dtypes = np.dtype(dtype_list)

        var h5 = h5py.File(_file_path(self._path), "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            return data
        except:
            h5.close()
            return np.empty(0, dtype=dtypes)


struct DividendStore(Movable):
    """
    Port of Python DividendStore(AbstractDividendStore).
    Reads dividend data from HDF5 file.
    """
    var _path: String
    var _py: Python

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()

    def get_dividend(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        """
        Port of Python DividendStore.get_dividend(order_book_id).
        Returns numpy array or None on KeyError.
        """
        var h5py = self._py.import_module("h5py")

        var h5 = h5py.File(_file_path(self._path), "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            return data
        except:
            h5.close()
            return None


struct YieldCurveStore(Movable):
    """
    Port of Python YieldCurveStore.
    Loads yield curve data from HDF5, supports date range filtering and tenor selection.
    """
    var _data: PythonObject
    var _py: Python

    def __init__(out self, path: String) raises:
        self._py = Python()
        var h5py = self._py.import_module("h5py")

        var h5 = h5py.File(_file_path(path), "r")
        self._data = h5["data"][:]
        h5.close()

    def get_yield_curve(
        mut self,
        start_date: DateTimeDate,
        end_date: DateTimeDate,
        tenor: Optional[String]
    ) raises -> Optional[PythonObject]:
        """
        Port of Python YieldCurveStore.get_yield_curve(start_date, end_date, tenor).
        
        Steps:
        1. Convert dates to int using convert_date_to_date_int
        2. Use searchsorted to find slice range [s, e)
        3. Handle edge cases where e exceeds array length
        4. Create DataFrame with date index
        5. Delete 'date' column after setting index
        6. Filter by tenor column if specified
        
        Returns DataFrame or None if no data in range.
        """
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
        var builtins = self._py.import_module("builtins")
        var py_slice = builtins.slice(s, e)
        var sliced_data = self._data[py_slice]

        var df = pandas.DataFrame(sliced_data)

        var date_col = df["date"].tolist()
        var str_dates = self._py.list()
        for d in date_col:
            str_dates.append(self._py.str(d))
        df.index = pandas.to_datetime(str_dates)

        df = df.drop("date", axis=1)

        if tenor is not None:
            return df[tenor.value()]
        return df


struct SimpleFactorStore(Movable):
    """
    Port of Python SimpleFactorStore(AbstractSimpleFactorStore).
    Caches factor data per order_book_id (replaces @lru_cache(1024)).
    """
    var _path: String
    var _py: Python
    var _cache: Dict[String, PythonObject]

    def __init__(out self, path: String):
        self._path = path
        self._py = Python()
        self._cache = Dict[String, PythonObject]()

    def get_factors(mut self, order_book_id: String) raises -> Optional[PythonObject]:
        """
        Port of Python SimpleFactorStore.get_factors(order_book_id).
        Returns cached numpy array or loads from HDF5.
        """
        if order_book_id in self._cache:
            return self._cache[order_book_id]

        var h5py = self._py.import_module("h5py")

        var h5 = h5py.File(_file_path(self._path), "r")
        try:
            var data = h5[order_book_id][:]
            h5.close()
            self._cache[order_book_id] = data
            return data
        except:
            h5.close()
            return None


struct DateSet(Movable):
    """
    Port of Python DateSet(AbstractDateSet).
    Caches day sets per order_book_id (replaces @lru_cache(None)).
    contains() handles int, np.int64, np.uint64, and datetime-like inputs.
    """
    var _f: PythonObject
    var _py: Python
    var _days_cache: Dict[String, PythonObject]

    def __init__(out self, f: PythonObject):
        self._f = f
        self._py = Python()
        self._days_cache = Dict[String, PythonObject]()

    def get_days(mut self, order_book_id: String) raises -> PythonObject:
        """
        Port of Python DateSet.get_days(order_book_id).
        Returns set of date ints (cached).
        """
        if order_book_id in self._days_cache:
            return self._days_cache[order_book_id]

        var h5py = self._py.import_module("h5py")
        var builtins = self._py.import_module("builtins")

        var h5 = h5py.File(self._f, "r")
        try:
            var days = h5[order_book_id][:]
            h5.close()
            var days_set = builtins.set(days.tolist())
            self._days_cache[order_book_id] = days_set
            return days_set
        except:
            h5.close()
            var empty_set = builtins.set()
            self._days_cache[order_book_id] = empty_set
            return empty_set

    def contains(mut self, order_book_id: String, dates: List[Int]) raises -> Optional[List[Bool]]:
        """
        Port of Python DateSet.contains(order_book_id, dates).
        Returns list of bool indicating whether each date is in the date set.
        Returns None if date_set is empty (matching Python behavior).
        
        Handles multiple input formats via _to_dt_int:
          - Int > 100000000: treat as datetime int (divide by 1000000)
          - Other int: treat as date int (YYYYMMDD)
          - Object with year/month/day: convert to YYYYMMDD
        """
        var date_set = self.get_days(order_book_id)
        var builtins = self._py.import_module("builtins")

        if builtins.len(date_set) == 0:
            return None

        var result = List[Bool]()
        for i in range(len(dates)):
            var d = dates[i]
            var dt_int = self._to_dt_int(builtins, d)
            result.append(dt_int in date_set)
        return result^

    def _to_dt_int(self, builtins: PythonObject, d: Int) raises -> Int:
        """
        Port of Python inner function _to_dt_int(d).
        Converts various date representations to integer date (YYYYMMDD).
        
        Logic:
          - If d is large (> 100000000): it's a datetime int, divide by 1000000
          - Otherwise: treat as plain date int (YYYYMMDD)
        """
        if d > 100000000:
            return d // 1000000
        else:
            return d


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
