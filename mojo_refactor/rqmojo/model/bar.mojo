"""
RQAlpha Mojo - Bar Object Model
Ported from rqalpha/model/bar.py

Design Notes (vs Python original):
  Python uses class inheritance: BarObject(PartialBarObject)
  Mojo has no class inheritance -> BarObject contains all fields from both
  Python uses cached_property decorator -> Mojo methods compute on each call
  Python NANDict is {name: np.nan} -> Mojo BarData struct with NAN_VALUE
"""

from std.collections import Dict, List, Set
from std.python import Python, PythonObject
from rqmojo.const import INSTRUMENT_TYPE, RUN_TYPE, EXECUTION_PHASE, EXCHANGE
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.datetime_func import convert_int_to_datetime


comptime BAR_NAMES_COUNT: Int = 16
comptime NAN_VALUE: Float64 = 0.0 / 0.0


@fieldwise_init
struct BarData(Copyable, Movable, ImplicitlyCopyable):
    var open: Float64
    var close: Float64
    var high: Float64
    var low: Float64
    var volume: Float64
    var total_turnover: Float64
    var limit_up: Float64
    var limit_down: Float64
    var settlement: Float64
    var prev_settlement: Float64
    var open_interest: Float64
    var discount_rate: Float64
    var acc_net_value: Float64
    var unit_net_value: Float64
    var basis_spread: Float64
    var datetime_int: Int
    var prev_close: Float64
    var last: Float64


def create_nan_bar_data() -> BarData:
    return BarData(
        open=NAN_VALUE,
        close=NAN_VALUE,
        high=NAN_VALUE,
        low=NAN_VALUE,
        volume=0.0,
        total_turnover=0.0,
        limit_up=NAN_VALUE,
        limit_down=NAN_VALUE,
        settlement=NAN_VALUE,
        prev_settlement=NAN_VALUE,
        open_interest=0.0,
        discount_rate=NAN_VALUE,
        acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE,
        basis_spread=NAN_VALUE,
        datetime_int=0,
        prev_close=NAN_VALUE,
        last=NAN_VALUE
    )


@fieldwise_init
struct PartialBarObject(Writable, Movable):
    """
    Port of Python PartialBarObject.
    Used for open_auction bars - has a subset of BarObject properties.
    Python original does NOT have close, high, low (those are BarObject-only).
    """
    var _order_book_id: String
    var _instrument: Instrument
    var _dt: DateTime
    var _data: BarData

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PartialBarObject(", self._order_book_id, ", dt=")
        self._dt.write_to(writer)
        writer.write(")")

    def order_book_id(self) -> String:
        return self._order_book_id

    def symbol(self) -> String:
        return self._instrument.symbol()

    def instrument(self) -> Instrument:
        return self._instrument

    def datetime(self) -> DateTime:
        if self._dt.year > 1970:
            return self._dt
        if self._data.datetime_int > 0:
            return convert_int_to_datetime(self._data.datetime_int)
        return self._dt

    def open(self) -> Float64:
        return self._data.open

    def last(self) -> Float64:
        return self._data.last

    def volume(self) -> Float64:
        return self._data.volume

    def total_turnover(self) -> Float64:
        return self._data.total_turnover

    def limit_up(self) -> Float64:
        """
        Returns limit_up price, or NaN if value is 0 or missing.
        Matches Python: try/except with v != 0 check.
        """
        var v = self._data.limit_up
        if v != 0.0:
            return v
        return NAN_VALUE

    def limit_down(self) -> Float64:
        """
        Returns limit_down price, or NaN if value is 0 or missing.
        Matches Python: try/except with v != 0 check.
        """
        var v = self._data.limit_down
        if v != 0.0:
            return v
        return NAN_VALUE

    def prev_close(self) -> Float64:
        """
        Returns prev_close from data.
        Note: Python version falls back to Environment.data_proxy.get_prev_close()
        when KeyError, but Mojo standalone version returns data value directly.
        """
        return self._data.prev_close

    def prev_settlement(self) -> Float64:
        """
        Returns prev_settlement from data.
        Note: Python version falls back to Environment.data_proxy.get_prev_settlement()
        when KeyError, but Mojo standalone version returns data value directly.
        """
        return self._data.prev_settlement

    def isnan(self) -> Bool:
        return self._data.close != self._data.close


@fieldwise_init
struct BarObject(Writable, Copyable, Movable, ImplicitlyCopyable):
    """
    Port of Python BarObject.
    Contains all PartialBarObject fields plus: close, high, low, settlement,
    open_interest, discount_rate, acc_net_value, unit_net_value, basis_spread,
    is_trading, suspended.
    """
    var _order_book_id: String
    var _instrument: Instrument
    var _dt: DateTime
    var _data: BarData
    var _suspended: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BarObject(", self._order_book_id, ", ")
        self._dt.write_to(writer)
        writer.write(", close=", String(self.close()), ")")

    def order_book_id(self) -> String:
        return self._order_book_id

    def symbol(self) -> String:
        return self._instrument.symbol()

    def instrument(self) -> Instrument:
        return self._instrument

    def datetime(self) -> DateTime:
        if self._dt.year > 1970:
            return self._dt
        if self._data.datetime_int > 0:
            return convert_int_to_datetime(self._data.datetime_int)
        return self._dt

    def open(self) -> Float64:
        return self._data.open

    def close(self) -> Float64:
        return self._data.close

    def high(self) -> Float64:
        return self._data.high

    def low(self) -> Float64:
        return self._data.low

    def last(self) -> Float64:
        """In BarObject, last always equals close (matches Python)."""
        return self._data.close

    def volume(self) -> Float64:
        return self._data.volume

    def total_turnover(self) -> Float64:
        return self._data.total_turnover

    def limit_up(self) -> Float64:
        var v = self._data.limit_up
        if v != 0.0:
            return v
        return NAN_VALUE

    def limit_down(self) -> Float64:
        var v = self._data.limit_down
        if v != 0.0:
            return v
        return NAN_VALUE

    def settlement(self) -> Float64:
        return self._data.settlement

    def prev_settlement(self) -> Float64:
        return self._data.prev_settlement

    def prev_close(self) -> Float64:
        return self._data.prev_close

    def open_interest(self) -> Float64:
        return self._data.open_interest

    def discount_rate(self) -> Float64:
        return self._data.discount_rate

    def acc_net_value(self) -> Float64:
        return self._data.acc_net_value

    def unit_net_value(self) -> Float64:
        return self._data.unit_net_value

    def basis_spread(self) -> Float64:
        """
        Basis spread calculation.
        Python original has complex INDEX_MAP logic for futures in PAPER_TRADING mode.
        Mojo version returns stored data value (standalone mode without Environment).
        For full parity with Python's paper trading mode, this would need Environment access.
        """
        return self._data.basis_spread

    def is_trading(self) -> Bool:
        """True if volume > 0."""
        return self._data.volume > 0

    def suspended(self) -> Bool:
        """
        Checks if bar is suspended.
        Python: checks isnan first, then calls data_proxy.is_suspended().
        Mojo: uses stored _suspended flag (set during construction).
        """
        if self.isnan():
            return True
        return self._suspended

    def isnan(self) -> Bool:
        return self._data.close != self._data.close

    def vwap(self, intervals: Int, frequency: String = "1d") -> Float64:
        """
        Volume Weighted Average Price.
        Python original uses data_proxy.fast_history() for multi-bar VWAP.
        Mojo standalone: returns single-bar VWAP (total_turnover / volume).
        Signature matches Python: vwap(intervals, frequency='1d').
        """
        if self._data.volume > 0:
            return self._data.total_turnover / self._data.volume
        return 0.0

    def mavg(self, intervals: Int, frequency: String = "1d") -> Float64:
        """
        Moving average of close prices over given intervals.
        Python original uses data_proxy.fast_history() for historical data.
        Mojo standalone: returns current close (stub for single-bar context).
        Signature matches Python: mavg(intervals, frequency='1d').
        """
        return self._data.close


struct BarMap(Movable):
    """
    Port of Python BarMap.
    Dictionary-like container mapping order_book_id -> BarObject.
    """
    var _dt: DateTime
    var _frequency: String
    var _cache: Dict[String, BarObject]
    var _universe: Set[String]

    def __init__(out self):
        self._dt = DateTime(1970, 1, 1, 0, 0, 0, 0)
        self._frequency = "1d"
        self._cache = Dict[String, BarObject]()
        self._universe = Set[String]()

    def __init__(out self, frequency: String):
        self._dt = DateTime(1970, 1, 1, 0, 0, 0, 0)
        self._frequency = frequency
        self._cache = Dict[String, BarObject]()
        self._universe = Set[String]()

    def update_dt(mut self, dt: DateTime) -> None:
        self._dt = dt
        self._cache = Dict[String, BarObject]()

    def update_universe(mut self, var universe: Set[String]) -> None:
        self._universe = universe^

    def dt(self) -> DateTime:
        return self._dt

    def frequency(self) -> String:
        return self._frequency

    def items(self) -> List[Tuple[String, BarObject]]:
        var result = List[Tuple[String, BarObject]]()
        for obid in self._universe:
            try:
                var bar = self._cache[obid]
                result.append((obid, bar))
            except:
                pass
        return result^

    def keys(self) -> Set[String]:
        var result = Set[String]()
        for item in self._universe:
            result.add(item)
        return result^

    def values(self) -> List[BarObject]:
        var result = List[BarObject]()
        for obid in self._universe:
            try:
                result.append(self._cache[obid])
            except:
                pass
        return result^

    def contains(self, key: String) -> Bool:
        return key in self._universe

    def len(self) -> Int:
        return len(self._universe)

    def get(mut self, key: String) -> BarObject:
        try:
            return self._cache[key]
        except:
            var nan_bar = create_nan_bar_object(key)
            self._cache[key] = nan_bar
            return nan_bar

    def set(mut self, key: String, bar: BarObject) -> None:
        self._cache[key] = bar

    def __str__(self) -> String:
        var keys_list = List[String]()
        var count = 0
        for k in self._universe:
            if count < 10:
                keys_list.append(k)
            count += 1
        var s = ", ".join(keys_list)
        if count > 10:
            s = s + " ..."
        return "BarMap(" + s + ")"


def create_bar_object(
    order_book_id: String,
    dt: DateTime,
    open: Float64,
    high: Float64,
    low: Float64,
    close: Float64,
    volume: Float64,
    total_turnover: Float64,
    limit_up: Float64 = 0.0,
    limit_down: Float64 = 0.0,
    suspended: Bool = False,
    trading: Bool = True,
    prev_settlement: Float64 = 0.0,
    settlement: Float64 = 0.0,
    open_interest: Float64 = 0.0,
    prev_close: Float64 = 0.0
) -> BarObject:
    var data = BarData(
        open=open,
        close=close,
        high=high,
        low=low,
        volume=volume,
        total_turnover=total_turnover,
        limit_up=limit_up,
        limit_down=limit_down,
        settlement=settlement,
        prev_settlement=prev_settlement,
        open_interest=open_interest,
        discount_rate=NAN_VALUE,
        acc_net_value=NAN_VALUE,
        unit_net_value=NAN_VALUE,
        basis_spread=NAN_VALUE,
        datetime_int=0,
        prev_close=prev_close,
        last=close
    )
    var ins = create_stock_instrument(order_book_id, order_book_id, dt, EXCHANGE.XSHG)
    return BarObject(
        _order_book_id=order_book_id,
        _instrument=ins,
        _dt=dt,
        _data=data,
        _suspended=suspended
    )


def create_bar_object_with_instrument(
    instrument: Instrument,
    dt: DateTime,
    data: BarData,
    suspended: Bool = False
) -> BarObject:
    return BarObject(
        _order_book_id=instrument.order_book_id(),
        _instrument=instrument,
        _dt=dt,
        _data=data,
        _suspended=suspended
    )


def create_simple_bar(
    order_book_id: String,
    dt: DateTime,
    open: Float64,
    high: Float64,
    low: Float64,
    close: Float64,
    volume: Float64
) -> BarObject:
    return create_bar_object(
        order_book_id=order_book_id,
        dt=dt,
        open=open,
        high=high,
        low=low,
        close=close,
        volume=volume,
        total_turnover=volume * close
    )


def create_partial_bar_object(
    order_book_id: String,
    instrument: Instrument,
    dt: DateTime,
    data: BarData
) -> PartialBarObject:
    return PartialBarObject(
        _order_book_id=order_book_id,
        _instrument=instrument,
        _dt=dt,
        _data=data
    )


def create_nan_bar_object(order_book_id: String) -> BarObject:
    var nan_data = create_nan_bar_data()
    var ins = create_stock_instrument(order_book_id, order_book_id, DateTime(1970, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHG)
    return BarObject(
        _order_book_id=order_book_id,
        _instrument=ins,
        _dt=DateTime(1970, 1, 1, 0, 0, 0, 0),
        _data=nan_data,
        _suspended=True
    )


def create_bar_map(frequency: String = "1d") -> BarMap:
    return BarMap(frequency=frequency)


def bar_object_from_dict(order_book_id: String, dt: DateTime, data: Dict[String, Float64]) -> BarObject:
    var open_val: Float64 = NAN_VALUE
    var close_val: Float64 = NAN_VALUE
    var high_val: Float64 = NAN_VALUE
    var low_val: Float64 = NAN_VALUE
    var volume_val: Float64 = 0.0
    var turnover_val: Float64 = 0.0
    var limit_up_val: Float64 = NAN_VALUE
    var limit_down_val: Float64 = NAN_VALUE
    var settlement_val: Float64 = NAN_VALUE
    var prev_settlement_val: Float64 = NAN_VALUE
    var open_interest_val: Float64 = 0.0
    var prev_close_val: Float64 = NAN_VALUE

    try:
        open_val = data["open"]
    except:
        pass
    try:
        close_val = data["close"]
    except:
        pass
    try:
        high_val = data["high"]
    except:
        pass
    try:
        low_val = data["low"]
    except:
        pass
    try:
        volume_val = data["volume"]
    except:
        pass
    try:
        turnover_val = data["total_turnover"]
    except:
        pass
    try:
        limit_up_val = data["limit_up"]
    except:
        pass
    try:
        limit_down_val = data["limit_down"]
    except:
        pass
    try:
        settlement_val = data["settlement"]
    except:
        pass
    try:
        prev_settlement_val = data["prev_settlement"]
    except:
        pass
    try:
        open_interest_val = data["open_interest"]
    except:
        pass
    try:
        prev_close_val = data["prev_close"]
    except:
        pass

    return create_bar_object(
        order_book_id=order_book_id,
        dt=dt,
        open=open_val,
        high=high_val,
        low=low_val,
        close=close_val,
        volume=volume_val,
        total_turnover=turnover_val,
        limit_up=limit_up_val,
        limit_down=limit_down_val,
        settlement=settlement_val,
        prev_settlement=prev_settlement_val,
        open_interest=open_interest_val,
        prev_close=prev_close_val
    )
