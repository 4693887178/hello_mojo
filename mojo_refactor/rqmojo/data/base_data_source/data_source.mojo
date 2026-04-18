"""
RQAlpha Mojo - Base Data Source
Ported from rqalpha/data/base_data_source/data_source.py
"""


from std.collections import Dict, List, Set
from std.python import Python, PythonObject
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET, TRADING_CALENDAR_TYPE, COMMISSION_TYPE
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.model.bar import BarObject, create_bar_object, create_nan_bar_object
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.datetime_func import (
    convert_date_to_int, convert_int_to_date, convert_int_to_datetime,
    convert_dt_to_int, to_date
)
from rqmojo.data.base_data_source.adjust import get_fields_require_adjustment, adjust_bars
from rqmojo.data.base_data_source.storages import (
    FuturesTradingParameters as StoragesFuturesTradingParameters,
    DayBarStore, FutureDayBarStore, DividendStore,
    ExchangeTradingCalendarStore, FutureInfoStore,
    ShareTransformationStore, SimpleFactorStore, YieldCurveStore,
    DateSet, load_instruments_from_pkl
)


def get_BAR_RESAMPLE_FIELD_METHODS() -> Dict[String, String]:
    var d = Dict[String, String]()
    d["open"] = "first"
    d["close"] = "last"
    d["iopv"] = "last"
    d["high"] = "max"
    d["low"] = "min"
    d["total_turnover"] = "sum"
    d["volume"] = "sum"
    d["num_trades"] = "sum"
    d["acc_net_value"] = "last"
    d["unit_net_value"] = "last"
    d["discount_rate"] = "last"
    d["settlement"] = "last"
    d["prev_settlement"] = "last"
    d["open_interest"] = "last"
    d["basis_spread"] = "last"
    d["contract_multiplier"] = "last"
    d["strike_price"] = "last"
    return d^


def get_OPEN_AUCTION_BAR_FIELDS() -> List[String]:
    return ["datetime", "open", "limit_up", "limit_down", "volume", "total_turnover"]


trait BaseDataSourceProtocol:
    def register_day_bar_store(mut self, instrument_type: INSTRUMENT_TYPE, store: PythonObject, market: MARKET) raises:
        ...
    def register_instruments(mut self, instruments: List[Instrument]) raises:
        ...
    def register_dividend_store(mut self, instrument_type: INSTRUMENT_TYPE, dividend_store: PythonObject, market: MARKET) raises:
        ...
    def register_split_store(mut self, instrument_type: INSTRUMENT_TYPE, split_store: PythonObject, market: MARKET) raises:
        ...
    def register_calendar_store(mut self, calendar_type: TRADING_CALENDAR_TYPE, calendar_store: PythonObject) raises:
        ...
    def register_ex_factor_store(mut self, instrument_type: INSTRUMENT_TYPE, ex_factor_store: PythonObject, market: MARKET) raises:
        ...


@fieldwise_init
struct FuturesTradingParameters(Writable, Copyable, Movable, ImplicitlyCopyable):
    var long_margin_ratio: Float64
    var short_margin_ratio: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "FuturesTradingParameters(long=", self.long_margin_ratio,
            ", short=", self.short_margin_ratio, ")"
        )


@fieldwise_init
struct ExchangeRate(Writable, Copyable, Movable, ImplicitlyCopyable):
    var bid_reference: Float64
    var ask_reference: Float64
    var bid_settlement_sh: Float64
    var ask_settlement_sh: Float64
    var bid_settlement_sz: Float64
    var ask_settlement_sz: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "ExchangeRate(bid=", self.bid_reference,
            ", ask=", self.ask_reference, ")"
        )


struct BaseDataSource(BaseDataSourceProtocol, Movable):
    var _bundle_path: String
    var _future_info_store: FutureInfoStore
    var _yield_curve: YieldCurveStore
    var _share_transformation: ShareTransformationStore
    var _st_stock_days: DateSet
    var _ins_id_or_sym_type_map: Dict[String, INSTRUMENT_TYPE]
    var _cs_day_bar_store: DayBarStore
    var _indx_day_bar_store: DayBarStore
    var _future_day_bar_store: FutureDayBarStore
    var _funds_day_bar_store: DayBarStore
    var _dividend_store: DividendStore
    var _split_store: SimpleFactorStore
    var _ex_factor_store: SimpleFactorStore
    var _calendar_store: ExchangeTradingCalendarStore
    var _suspend_days_paths: List[String]
    var _id_instrument_map: Dict[String, Dict[Int, Instrument]]
    var _sym_instrument_map: Dict[String, Dict[Int, Instrument]]
    var _grouped_instruments: Dict[INSTRUMENT_TYPE, List[Instrument]]
    var _dividend_cache: Dict[String, PythonObject]
    var _split_cache: Dict[String, PythonObject]
    var _ex_cum_factor_cache: Dict[String, Optional[PythonObject]]
    var _all_day_bars_cache: Dict[String, PythonObject]
    var _filtered_day_bars_cache: Dict[String, PythonObject]
    var _exchange_rate_1: ExchangeRate

    def __init__(
        out self,
        bundle_path: String,
        custom_future_info: PythonObject,
    ) raises:
        var os_mod = Python().import_module("os")

        if not Bool(py=os_mod.path.exists(bundle_path)):
            raise Error("bundle path " + String(py=os_mod.path.abspath(bundle_path)) + " not exist")

        self._bundle_path = bundle_path

        def _p(name: String) raises -> String:
            return String(py=os_mod.path.join(bundle_path, name))

        self._future_info_store = FutureInfoStore(_p("future_info.json"), custom_future_info)
        self._yield_curve = YieldCurveStore(_p("yield_curve.h5"))
        self._share_transformation = ShareTransformationStore(_p("share_transformation.json"))
        self._st_stock_days = DateSet(PythonObject(_p("st_stock_days.h5")))

        self._ins_id_or_sym_type_map = Dict[String, INSTRUMENT_TYPE]()
        self._suspend_days_paths = List[String]()
        self._suspend_days_paths.append(_p("suspended_days.h5"))

        self._cs_day_bar_store = DayBarStore(_p("stocks.h5"))
        self._indx_day_bar_store = DayBarStore(_p("indexes.h5"))
        self._future_day_bar_store = FutureDayBarStore(_p("futures.h5"))
        self._funds_day_bar_store = DayBarStore(_p("funds.h5"))

        self._dividend_store = DividendStore(_p("dividends.h5"))
        self._split_store = SimpleFactorStore(_p("split_factor.h5"))
        self._ex_factor_store = SimpleFactorStore(_p("ex_cum_factor.h5"))

        self._calendar_store = ExchangeTradingCalendarStore(PythonObject(_p("trading_dates.npy")))

        self._id_instrument_map = Dict[String, Dict[Int, Instrument]]()
        self._sym_instrument_map = Dict[String, Dict[Int, Instrument]]()
        self._grouped_instruments = Dict[INSTRUMENT_TYPE, List[Instrument]]()

        self._dividend_cache = Dict[String, PythonObject]()
        self._split_cache = Dict[String, PythonObject]()
        self._ex_cum_factor_cache = Dict[String, Optional[PythonObject]]()
        self._all_day_bars_cache = Dict[String, PythonObject]()
        self._filtered_day_bars_cache = Dict[String, PythonObject]()

        self._exchange_rate_1 = ExchangeRate(
            bid_reference=1.0,
            ask_reference=1.0,
            bid_settlement_sh=1.0,
            ask_settlement_sh=1.0,
            bid_settlement_sz=1.0,
            ask_settlement_sz=1.0
        )

        var raw_instruments = load_instruments_from_pkl(_p("instruments.pk"), self._future_info_store)
        var instruments = self._py_instruments_to_mojo(raw_instruments)
        self.register_instruments(instruments)

    def _py_instruments_to_mojo(self, py_instruments: PythonObject) raises -> List[Instrument]:
        var result = List[Instrument]()
        for i in py_instruments:
            var order_book_id = String(py=i.get("order_book_id"))
            var symbol = String(py=i.get("symbol"))
            var i_type_str = String(py=i.get("type"))
            var listed_date_str = String(py=i.get("listed_date", "1990-01-01"))
            var de_listed_date_str = String(py=i.get("de_listed_date", "2999-12-31"))
            var exchange_str = String(py=i.get("exchange", "XSHE"))

            var listed_date = self._parse_date(listed_date_str)
            var de_listed_date = self._parse_date(de_listed_date_str)
            var ex = self._str_to_exchange(exchange_str)

            if i_type_str == "CS" or i_type_str == "ETF" or i_type_str == "LOF":
                result.append(create_stock_instrument(order_book_id, symbol, listed_date, ex))
            elif i_type_str == "Future" or i_type_str == "FUTURE":
                var underlying_symbol = String(py=i.get("underlying_symbol", ""))
                var contract_multiplier = Float64(py=i.get("contract_multiplier", 1.0))
                result.append(create_future_instrument(
                    order_book_id, symbol, listed_date,
                    listed_date, de_listed_date, contract_multiplier,
                    ex, underlying_symbol
                ))
            else:
                result.append(create_stock_instrument(order_book_id, symbol, listed_date, ex))
        return result^

    def _parse_date(self, date_str: String) -> DateTime:
        if len(date_str) == 0 or date_str == "0000-00-00":
            return DateTime(1990, 1, 1, 0, 0, 0, 0)
        try:
            var year = Int(date_str[byte=0:4])
            var month = Int(date_str[byte=5:7])
            var day = Int(date_str[byte=8:10])
            return DateTime(year, month, day, 0, 0, 0, 0)
        except:
            return DateTime(1990, 1, 1, 0, 0, 0, 0)

    def _str_to_exchange(self, ex_str: String) -> EXCHANGE:
        if ex_str == "XSHE":
            return EXCHANGE.XSHE
        elif ex_str == "XSHG":
            return EXCHANGE.XSHG
        elif ex_str == "SHFE":
            return EXCHANGE.SHFE
        elif ex_str == "CFFEX":
            return EXCHANGE.CFFEX
        elif ex_str == "DCE":
            return EXCHANGE.DCE
        elif ex_str == "CZCE":
            return EXCHANGE.CZCE
        elif ex_str == "INE":
            return EXCHANGE.INE
        else:
            return EXCHANGE.XSHE

    def register_day_bar_store(mut self, instrument_type: INSTRUMENT_TYPE, store: PythonObject, market: MARKET):
        pass

    def register_instruments(mut self, instruments: List[Instrument]) raises:
        for ins in instruments:
            var obid = ins.order_book_id()
            var sym = ins.symbol()
            var listed_dt = convert_date_to_int(ins.listed_date())

            if obid not in self._id_instrument_map:
                self._id_instrument_map[obid] = Dict[Int, Instrument]()
            self._id_instrument_map[obid][listed_dt] = ins

            if sym not in self._sym_instrument_map:
                self._sym_instrument_map[sym] = Dict[Int, Instrument]()
            self._sym_instrument_map[sym][listed_dt] = ins

            var ins_type = ins.type()
            if ins_type not in self._grouped_instruments:
                self._grouped_instruments[ins_type] = List[Instrument]()
            self._grouped_instruments[ins_type].append(ins)

            self._ins_id_or_sym_type_map[obid] = ins_type
            self._ins_id_or_sym_type_map[sym] = ins_type

    def register_dividend_store(mut self, instrument_type: INSTRUMENT_TYPE, dividend_store: PythonObject, market: MARKET):
        pass

    def register_split_store(mut self, instrument_type: INSTRUMENT_TYPE, split_store: PythonObject, market: MARKET):
        pass

    def register_calendar_store(mut self, calendar_type: TRADING_CALENDAR_TYPE, calendar_store: PythonObject):
        pass

    def register_ex_factor_store(mut self, instrument_type: INSTRUMENT_TYPE, ex_factor_store: PythonObject, market: MARKET):
        pass

    def append_suspend_date_set(mut self, suspend_path: String) raises:
        self._suspend_days_paths.append(suspend_path)

    def get_dividend(mut self, instrument: Instrument) raises -> PythonObject:
        var cache_key = instrument.order_book_id()
        if cache_key in self._dividend_cache:
            return self._dividend_cache[cache_key]

        var result_opt = self._dividend_store.get_dividend(instrument.order_book_id())
        if result_opt != None:
            self._dividend_cache[cache_key] = result_opt.value()
            return result_opt.value()
        else:
            var np = Python().import_module("numpy")
            self._dividend_cache[cache_key] = PythonObject(None)
            return PythonObject(None)

    def get_trading_minutes_for(self, instrument: Instrument, trading_dt: DateTime) raises -> PythonObject:
        raise Error("get_trading_minutes_for is not implemented")

    def get_trading_calendars(self) raises -> Dict[String, PythonObject]:
        var result = Dict[String, PythonObject]()
        result["CN_STOCK"] = self._calendar_store.get_trading_calendar()
        return result^

    def get_instruments(
        mut self,
        id_or_syms: Optional[List[String]] = None,
        types: Optional[List[INSTRUMENT_TYPE]] = None,
    ) raises -> List[Instrument]:
        var result = List[Instrument]()
        var seen: Set[String] = Set[String]()

        if id_or_syms != None:
            var ids = id_or_syms.value().copy()
            for i in ids:
                var v_id = self._id_instrument_map.get(i)
                var v_sym = self._sym_instrument_map.get(i)
                if v_id != None:
                    for dt_val in v_id.value().values():
                        var ins = dt_val
                        if ins.order_book_id() not in seen:
                            seen.add(ins.order_book_id())
                            result.append(ins)
                if v_sym != None:
                    for dt_val in v_sym.value().values():
                        var ins = dt_val
                        if ins.order_book_id() not in seen:
                            seen.add(ins.order_book_id())
                            result.append(ins)
        else:
            var target_types: Optional[List[INSTRUMENT_TYPE]]
            if types == None:
                var all_keys = List[INSTRUMENT_TYPE]()
                for k in self._grouped_instruments.keys():
                    all_keys.append(k)
                target_types = Optional[List[INSTRUMENT_TYPE]](all_keys^)
            else:
                target_types = types.copy()

            for t in target_types.value().copy():
                if t in self._grouped_instruments:
                    for ins in self._grouped_instruments[t]:
                        if ins.order_book_id() not in seen:
                            seen.add(ins.order_book_id())
                            result.append(ins)
        return result^

    def get_share_transformation(mut self, order_book_id: String) raises -> PythonObject:
        var result_opt = self._share_transformation.get_share_transformation(order_book_id)
        if result_opt != None:
            return result_opt.value()
        return PythonObject(None)

    def is_suspended(mut self, order_book_id: String, dates: List[Int]) raises -> List[Bool]:
        for spath in self._suspend_days_paths:
            var ds = DateSet(PythonObject(spath))
            var result = ds.contains(order_book_id, dates)
            if len(result) > 0:
                return result^
        var false_result = List[Bool]()
        for _ in range(len(dates)):
            false_result.append(False)
        return false_result^

    def is_st_stock(mut self, order_book_id: String, dates: List[Int]) raises -> List[Bool]:
        var result = self._st_stock_days.contains(order_book_id, dates)
        if len(result) > 0:
            return result^
        var false_result = List[Bool]()
        for _ in range(len(dates)):
            false_result.append(False)
        return false_result^

    def _get_day_bars_from_store(mut self, instrument_type: INSTRUMENT_TYPE, order_book_id: String) raises -> PythonObject:
        if instrument_type == INSTRUMENT_TYPE.CS:
            return self._cs_day_bar_store.get_bars(order_book_id)
        elif instrument_type == INSTRUMENT_TYPE.INDX:
            return self._indx_day_bar_store.get_bars(order_book_id)
        elif instrument_type == INSTRUMENT_TYPE.FUTURE:
            return self._future_day_bar_store.get_bars(order_book_id)
        else:
            return self._funds_day_bar_store.get_bars(order_book_id)

    def _all_day_bars_of(mut self, instrument: Instrument) raises -> PythonObject:
        var cache_key = instrument.order_book_id()
        if cache_key in self._all_day_bars_cache:
            return self._all_day_bars_cache[cache_key]

        var bars = self._get_day_bars_from_store(instrument.type(), instrument.order_book_id())
        self._all_day_bars_cache[cache_key] = bars
        return bars

    def _filtered_day_bars(mut self, instrument: Instrument) raises -> PythonObject:
        var cache_key = "_filt_" + instrument.order_book_id()
        if cache_key in self._filtered_day_bars_cache:
            return self._filtered_day_bars_cache[cache_key]

        var bars_cache_key = instrument.order_book_id()
        var bars: PythonObject
        if bars_cache_key in self._all_day_bars_cache:
            bars = self._all_day_bars_cache[bars_cache_key]
        else:
            bars = self._get_day_bars_from_store(instrument.type(), instrument.order_book_id())
            self._all_day_bars_cache[bars_cache_key] = bars

        if len(bars) <= 0:
            self._filtered_day_bars_cache[cache_key] = bars
            return bars

        var filtered = bars[bars["volume"] > 0]
        self._filtered_day_bars_cache[cache_key] = filtered
        return filtered

    def get_bar(mut self, instrument: Instrument, dt: DateTime, frequency: String) raises -> Optional[PythonObject]:
        if frequency != "1d":
            raise Error("only 1d frequency supported")

        var cache_key = instrument.order_book_id()
        var bars: PythonObject
        if cache_key in self._all_day_bars_cache:
            bars = self._all_day_bars_cache[cache_key]
        else:
            bars = self._get_day_bars_from_store(instrument.type(), instrument.order_book_id())
            self._all_day_bars_cache[cache_key] = bars
        var np = Python().import_module("numpy")
        if len(bars) <= 0:
            return None

        var dt_int = np.uint64(convert_date_to_int(dt))
        var pos = Int(py=bars["datetime"].searchsorted(dt_int))
        if pos >= len(bars) or bars["datetime"][pos] != dt_int:
            return None

        return Optional[PythonObject](bars[pos])

    def get_open_auction_bar(mut self, instrument: Instrument, dt: DateTime) raises -> Dict[String, PythonObject]:
        var day_bar = self.get_bar(instrument, dt, "1d")
        var bar = Dict[String, PythonObject]()
        var np = Python().import_module("numpy")
        var nan_val = np.nan
        var open_auction_fields = get_OPEN_AUCTION_BAR_FIELDS()

        for field_name in open_auction_fields:
            if day_bar == None:
                bar[field_name] = nan_val
            else:
                var db = day_bar.value()
                var db_attr = getattr_python(db, field_name)
                if db_attr != None:
                    bar[field_name] = db_attr.value()
                else:
                    bar[field_name] = nan_val

        var open_val = bar.get("open")
        if open_val != None:
            bar["last"] = open_val.value()
        else:
            bar["last"] = nan_val
        return bar^

    def get_settle_price(mut self, instrument: Instrument, date: DateTime) raises -> Float64:
        var bar = self.get_bar(instrument, date, "1d")
        if bar == None:
            var np = Python().import_module("numpy")
            return Float64(py=np.nan)
        var db = bar.value()
        var settlement = getattr_python(db, "settlement")
        if settlement != None:
            return Float64(py=settlement.value())
        var np = Python().import_module("numpy")
        return Float64(py=np.nan)

    @staticmethod
    def _are_fields_valid(fields: Optional[String], valid_fields: List[String]) -> Bool:
        if fields == None:
            return True
        var f = fields.value()
        for vf in valid_fields:
            if f == vf:
                return True
        return False

    def get_ex_cum_factor(mut self, instrument: Instrument) raises -> Optional[PythonObject]:
        var cache_key = instrument.order_book_id()
        if cache_key in self._ex_cum_factor_cache:
            var cached = self._ex_cum_factor_cache[cache_key]
            if cached == None:
                return None
            return cached

        var factors_opt = self._ex_factor_store.get_factors(instrument.order_book_id())
        if factors_opt == None:
            self._ex_cum_factor_cache[cache_key] = PythonObject(None)
            return None
        var factors = factors_opt.value()
        if len(factors) == 0:
            self._ex_cum_factor_cache[cache_key] = PythonObject(None)
            return None

        var listed_int = convert_dt_to_int(instrument.listed_date())
        var de_listed_int = convert_dt_to_int(instrument.de_listed_date())

        var mask = (factors["start_date"] >= listed_int) & (factors["start_date"] <= de_listed_int)
        factors = factors[mask]
        if len(factors) == 0:
            self._ex_cum_factor_cache[cache_key] = PythonObject(None)
            return None

        var np = Python().import_module("numpy")
        if Int(py=factors["start_date"][0]) != 0:
            var concat_fn = Python().evaluate("""
def concat_row(factors):
    import numpy as np
    row = np.zeros(1, dtype=factors.dtype)
    row['start_date'][0] = np.int64(0)
    row['ex_cum_factor'][0] = np.float64(1.0)
    return np.concatenate([row, factors])
""", file=True)
            factors = concat_fn(factors)

        self._ex_cum_factor_cache[cache_key] = factors
        return Optional[PythonObject](factors)

    def resample_week_bars(
        mut self,
        bars: PythonObject,
        bar_count: Optional[Int],
        fields: Optional[String],
    ) raises -> PythonObject:
        var pd = Python().import_module("pandas")
        var np = Python().import_module("numpy")
        var df_bars = pd.DataFrame(bars)

        var convert_dt_fn = Python().evaluate("""
def fn(x):
    from rqalpha.utils.datetime_func import convert_int_to_datetime
    return convert_int_to_datetime(int(x['datetime']))
""", file=True)
        df_bars["datetime"] = df_bars.apply(convert_dt_fn, axis=1)
        df_bars = df_bars.set_index("datetime")

        var hows_py = Python.dict()
        var resample_methods = get_BAR_RESAMPLE_FIELD_METHODS()
        if fields != None:
            var f = fields.value()
            if f in resample_methods:
                var method_val = resample_methods[f]
                hows_py[f] = method_val
        else:
            var resample_keys = List[String]()
            for k in resample_methods.keys():
                resample_keys.append(k)
            for fn_key in resample_keys:
                var val = resample_methods[fn_key]
                hows_py[fn_key] = val

        df_bars = df_bars.resample("W-Fri").agg(hows_py)
        var identity_fn = Python().evaluate("lambda x: x")
        df_bars.index = df_bars.index.map(identity_fn)
        df_bars = df_bars[~df_bars.index.duplicated(keep="first")]
        df_bars.sort_index(inplace=True)

        if bar_count != None:
            var bc = bar_count.value()
            df_bars = df_bars[-bc:]

        df_bars = df_bars.reset_index()
        var convert_back_fn = Python().evaluate("""
def fn2(x):
    import numpy as np
    from rqalpha.utils.datetime_func import convert_date_to_int
    return np.uint64(convert_date_to_int(__import__('datetime').date(
        int(x['datetime'].year), int(x['datetime'].month),
        int(x['datetime'].day))))
""", file=True)
        df_bars["datetime"] = df_bars.apply(convert_back_fn, axis=1)
        df_bars = df_bars.set_index("datetime")
        return df_bars.to_records()

    def history_bars(
        mut self,
        instrument: Instrument,
        bar_count: Optional[Int],
        frequency: String,
        fields: Optional[String],
        dt: DateTime,
        skip_suspended: Bool = True,
        include_now: Bool = False,
        adjust_type: String = "pre",
        adjust_orig: Optional[DateTime] = None,
    ) raises -> PythonObject:

        if frequency != "1d" and frequency != "1w":
            raise Error("unsupported frequency: " + frequency)

        var bars: PythonObject
        if skip_suspended and instrument.type() == INSTRUMENT_TYPE.CS:
            bars = self._filtered_day_bars(instrument)
        else:
            bars = self._all_day_bars_of(instrument)

        var np = Python().import_module("numpy")
        if len(bars) <= 0:
            return bars

        if frequency == "1w":
            var dt_int_np = np.uint64(convert_date_to_int(dt))

            var i: Int
            if include_now:
                i = Int(py=bars["datetime"].searchsorted(dt_int_np, side="right"))
            else:
                var monday_int = np.uint64(convert_date_to_int(DateTime(dt.year, dt.month, max(dt.day - 6, 1), 0, 0, 0, 0)))
                i = Int(py=bars["datetime"].searchsorted(monday_int, side="left"))

            var left: Int
            if bar_count == None:
                left = 0
            else:
                var bc = bar_count.value()
                left = i - bc * 5 if i >= bc * 5 else 0

            var builtins = Python().import_module("builtins")
            var py_slice = builtins.slice(left, i)
            bars = bars[py_slice]

            if adjust_type == "none" or instrument.type() == INSTRUMENT_TYPE.FUTURE or instrument.type() == INSTRUMENT_TYPE.INDX:
                return self.resample_week_bars(bars, bar_count, fields)

            if fields != None:
                var f = fields.value()
                var price_fields = get_fields_require_adjustment()
                var needs_adjust = False
                for pf in price_fields:
                    if pf == f:
                        needs_adjust = True
                        break
                if not needs_adjust:
                    return self.resample_week_bars(bars, bar_count, fields)

            var ex_cum = self.get_ex_cum_factor(instrument)
            var adjust_orig_py: PythonObject
            if adjust_orig != None:
                var dt_val = adjust_orig.value()
                var py_datetime = Python().import_module("datetime")
                adjust_orig_py = py_datetime.datetime(dt_val.year, dt_val.month, dt_val.day, dt_val.hour, dt_val.minute, dt_val.second)
            else:
                adjust_orig_py = Python.none()
            return self.resample_week_bars(
                adjust_bars(
                    bars,
                    ex_cum.value() if ex_cum != None else Python.none(),
                    Python.str(fields.value() if fields != None else ""),
                    Python.str(adjust_type),
                    adjust_orig_py,
                ),
                bar_count, fields,
            )

        var dt_int_np = np.uint64(convert_date_to_int(dt))
        var i = Int(py=bars["datetime"].searchsorted(dt_int_np, side="right"))

        var left: Int
        if bar_count == None:
            left = 0
        else:
            var bc = bar_count.value()
            left = i - bc if i >= bc else 0

        var builtins = Python().import_module("builtins")
        var py_slice = builtins.slice(left, i)
        bars = bars[py_slice]

        if adjust_type == "none" or instrument.type() == INSTRUMENT_TYPE.FUTURE or instrument.type() == INSTRUMENT_TYPE.INDX:
            return bars

        if fields != None:
            var f = fields.value()
            var price_fields = get_fields_require_adjustment()
            var needs_adjust = False
            for pf in price_fields:
                if pf == f:
                    needs_adjust = True
                    break
            if not needs_adjust:
                return bars

        var ex_cum = self.get_ex_cum_factor(instrument)
        var adjust_orig_py: PythonObject
        if adjust_orig != None:
            var dt_val = adjust_orig.value()
            var py_datetime = Python().import_module("datetime")
            adjust_orig_py = py_datetime.datetime(dt_val.year, dt_val.month, dt_val.day, dt_val.hour, dt_val.minute, dt_val.second)
        else:
            adjust_orig_py = Python.none()
        return adjust_bars(
            bars,
            ex_cum.value() if ex_cum != None else Python.none(),
            Python.str(fields.value() if fields != None else ""),
            Python.str(adjust_type),
            adjust_orig_py,
        )

    def current_snapshot(self, instrument: Instrument, frequency: String, dt: DateTime) raises -> PythonObject:
        raise Error("current_snapshot is not implemented")

    def get_split(mut self, instrument: Instrument) raises -> PythonObject:
        var cache_key = instrument.order_book_id()
        if cache_key in self._split_cache:
            return self._split_cache[cache_key]

        var result_opt = self._split_store.get_factors(instrument.order_book_id())
        if result_opt != None:
            var result = result_opt.value()
            self._split_cache[cache_key] = result
            return result
        else:
            self._split_cache[cache_key] = PythonObject(None)
            return PythonObject(None)

    def available_data_range(mut self, frequency: String) raises -> Tuple[DateTimeDate, DateTimeDate]:
        var min_d = DateTimeDate(1, 1, 1)
        var max_d = DateTimeDate(9999, 12, 31)
        if frequency == "tick" or frequency == "1d":
            var date_range = self._indx_day_bar_store.get_date_range("000001.XSHG")
            var s = convert_int_to_date(Int(py=date_range[0]))
            var e = convert_int_to_date(Int(py=date_range[1]))
            return (DateTimeDate(s.year, s.month, s.day), DateTimeDate(e.year, e.month, e.day))
        return (min_d, max_d)

    def get_yield_curve(mut self, start_date: DateTimeDate, end_date: DateTimeDate, tenor: Optional[String] = None) raises -> Optional[PythonObject]:
        var result_opt = self._yield_curve.get_yield_curve(start_date, end_date, tenor)
        if result_opt != None:
            return result_opt
        return PythonObject(None)

    def get_futures_trading_parameters(mut self, instrument: Instrument, dt: DateTime) raises -> StoragesFuturesTradingParameters:
        return self._future_info_store.get_future_info(instrument.order_book_id(), instrument.underlying_symbol())

    def get_merge_ticks(self, order_book_id_list: List[String], trading_date: DateTime, last_dt: Optional[DateTime] = None) raises -> PythonObject:
        raise Error("get_merge_ticks is not implemented")

    def history_ticks(self, instrument: Instrument, count: Int, dt: DateTime) raises -> PythonObject:
        raise Error("history_ticks is not implemented")

    def get_algo_bar(self, id_or_ins: String, start_min: Int, end_min: Int, dt: DateTime) raises -> PythonObject:
        raise Error("open source rqalpha does not support algo order")

    def get_open_auction_volume(mut self, instrument: Instrument, dt: DateTime) raises -> Float64:
        var bar_dict = self.get_open_auction_bar(instrument, dt)
        var vol = bar_dict.get("volume")
        if vol != None:
            return Float64(py=vol.value())
        return 0.0

    def register_instruments_store(mut self, instruments_store: PythonObject, market: MARKET) raises:
        print("[WARN] register_instruments_store is deprecated, please use register_instruments instead")

    def get_exchange_rate(self, trading_date: DateTimeDate, local: MARKET, settlement: MARKET = MARKET.CN) raises -> ExchangeRate:
        if local == settlement:
            return self._exchange_rate_1
        else:
            raise Error("exchange rate for different markets is not implemented")


def _store_key(instrument_type: INSTRUMENT_TYPE, market: MARKET) -> String:
    return instrument_type.value + "|" + market.value


def getattr_python(obj: PythonObject, attr_name: String) raises -> Optional[PythonObject]:
    var builtins = Python().import_module("builtins")
    if builtins.hasattr(obj, attr_name):
        return Optional[PythonObject](builtins.getattr(obj, attr_name))
    return None


def create_base_data_source(bundle_path: String) raises -> BaseDataSource:
    return BaseDataSource(bundle_path=bundle_path, custom_future_info=PythonObject(None))


def create_base_data_source_with_path(bundle_path: String) raises -> BaseDataSource:
    return BaseDataSource(bundle_path=bundle_path, custom_future_info=PythonObject(None))
