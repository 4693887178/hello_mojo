"""
RQAlpha Mojo - Bar Object Model
Ported from rqalpha/model/bar.py
"""

from std.collections import Dict, List, Set
from rqmojo.const import INSTRUMENT_TYPE, RUN_TYPE, EXECUTION_PHASE, EXCHANGE
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.datetime_func import DateTime, convert_int_to_datetime
from python import Python, PythonObject


comptime BAR_NAMES: Int = 16
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
struct PartialBarObject(Writable, Movable, Copyable, ImplicitlyCopyable):
    var _order_book_id: String
    var _instrument: Instrument
    var _dt: DateTime
    var _data: BarData
    var _limit_up: Float64
    var _limit_down: Float64

    def write_to(self, mut writer: Some[Writer]):
        writer.write("PartialBarObject(", self._order_book_id, ", dt=", self._dt.__str__(), ")")

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
        return self._data.last

    def volume(self) -> Float64:
        return self._data.volume

    def total_turnover(self) -> Float64:
        return self._data.total_turnover

    def limit_up(self) -> Float64:
        if self._limit_up != 0.0:
            return self._limit_up
        var v = self._data.limit_up
        if v != 0.0:
            return v
        return NAN_VALUE

    def limit_down(self) -> Float64:
        if self._limit_down != 0.0:
            return self._limit_down
        var v = self._data.limit_down
        if v != 0.0:
            return v
        return NAN_VALUE

    def prev_close(self) -> Float64:
        return self._data.prev_close

    def prev_settlement(self) -> Float64:
        return self._data.prev_settlement

    def isnan(self) -> Bool:
        return self._data.close != self._data.close


@fieldwise_init
struct BarObject(Writable, Movable, Copyable, ImplicitlyCopyable):
    var _order_book_id: String
    var _instrument: Instrument
    var _dt: DateTime
    var _data: BarData
    var _limit_up: Float64
    var _limit_down: Float64
    var _suspended: Bool
    var _trading: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BarObject(", self._order_book_id, ", ", self._dt.__str__(), ", close=", String(self.close()), ")")

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
        return self._data.close

    def volume(self) -> Float64:
        return self._data.volume

    def total_turnover(self) -> Float64:
        return self._data.total_turnover

    def limit_up(self) -> Float64:
        if self._limit_up != 0.0:
            return self._limit_up
        var v = self._data.limit_up
        if v != 0.0:
            return v
        return NAN_VALUE

    def limit_down(self) -> Float64:
        if self._limit_down != 0.0:
            return self._limit_down
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
        return self._data.basis_spread

    def is_trading(self) -> Bool:
        return self._data.volume > 0

    def suspended(self) -> Bool:
        return self._suspended

    def isnan(self) -> Bool:
        return self._data.close != self._data.close

    def vwap(self) -> Float64:
        if self._data.volume > 0:
            return self._data.total_turnover / self._data.volume
        else:
            return 0.0

    def mavg(self, n: Int, frequency: String = "1d") -> Float64:
        return self._data.close

    def vwap_avg(self, n: Int, frequency: String = "1d") -> Float64:
        if self._data.volume > 0:
            return self._data.total_turnover / self._data.volume
        return 0.0


struct BarMap(Movable):
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

    def __contains__(self, key: String) -> Bool:
        return key in self._universe

    def len(self) -> Int:
        return len(self._universe)

    def get(mut self, key: String) raises -> BarObject:
        try:
            return self._cache[key]
        except:
            var nan_bar = create_nan_bar_object(key)
            self._cache[key] = nan_bar
            return nan_bar

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
        _limit_up=limit_up,
        _limit_down=limit_down,
        _suspended=suspended,
        _trading=trading
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
        _limit_up=data.limit_up,
        _limit_down=data.limit_down,
        _suspended=suspended,
        _trading=data.volume > 0
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


def create_nan_bar_object(order_book_id: String) -> BarObject:
    var nan_data = create_nan_bar_data()
    var ins = create_stock_instrument(order_book_id, order_book_id, DateTime(1970, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHG)
    return BarObject(
        _order_book_id=order_book_id,
        _instrument=ins,
        _dt=DateTime(1970, 1, 1, 0, 0, 0, 0),
        _data=nan_data,
        _limit_up=NAN_VALUE,
        _limit_down=NAN_VALUE,
        _suspended=True,
        _trading=False
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
