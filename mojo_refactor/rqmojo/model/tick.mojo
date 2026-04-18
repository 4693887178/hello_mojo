"""
RQAlpha Mojo - Tick Object Model
Ported from rqalpha/model/tick.py

Architecture:
  Python: __init__(self, instrument, tick_dict) — lazy dict-driven
  Mojo:  __init__(instrument, tick_dict: Dict[String, TickValue]) — eager struct-driven
          Uses native Mojo Variant (not PythonObject) for heterogeneous dict values.
          All fields resolved at construction time; zero dict lookup at access time.
"""

from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from std.collections import List, Dict
from std.utils import Variant


comptime __all__: List[String] = [
    "TickObject",
]

comptime ORDER_BOOK_LEVELS = 5

comptime TickValue = Variant[Float64, String, DateTime, List[Float64]]


@fieldwise_init
struct TickObject(Writable, Movable, Copyable):
    var _order_book_id: String
    var _instrument: Instrument
    var datetime: DateTime
    var last: Float64
    var volume: Float64
    var total_turnover: Float64
    var open: Float64
    var high: Float64
    var low: Float64
    var prev_close: Float64
    var limit_up: Float64
    var limit_down: Float64
    var open_interest: Float64
    var prev_settlement: Float64
    var asks: List[Float64]
    var ask_vols: List[Float64]
    var bids: List[Float64]
    var bid_vols: List[Float64]

    def __init__(
        out self,
        var instrument: Instrument,
        var tick_dict: Dict[String, TickValue],
    ) raises:
        self._order_book_id = instrument.order_book_id()
        self._instrument = instrument^
        self.datetime = _get_or(tick_dict, "datetime", DateTime(1970, 1, 1, 0, 0, 0, 0))
        self.last = _get_or(tick_dict, "last", 0.0)
        self.volume = _get_or(tick_dict, "volume", 0.0)
        self.total_turnover = _get_or(tick_dict, "total_turnover", 0.0)
        self.open = _get_or(tick_dict, "open", 1.0)
        self.high = _get_or(tick_dict, "high", 1.0)
        self.low = _get_or(tick_dict, "low", 1.0)
        self.prev_close = _get_or(tick_dict, "prev_close", 0.0)
        self.limit_up = _get_or(tick_dict, "limit_up", 0.0)
        self.limit_down = _get_or(tick_dict, "limit_down", 0.0)
        self.open_interest = _get_or(tick_dict, "open_interest", 0.0)
        self.prev_settlement = _get_or(tick_dict, "prev_settlement", 0.0)
        self.asks = _get_or_list(tick_dict, "asks")
        self.ask_vols = _get_or_list(tick_dict, "ask_vols")
        self.bids = _get_or_list(tick_dict, "bids")
        self.bid_vols = _get_or_list(tick_dict, "bid_vols")

    def order_book_id(self) -> String:
        return self._order_book_id

    def instrument(self) -> Instrument:
        return self._instrument

    def close(self) -> Float64:
        return self.last

    def isnan(self) -> Bool:
        return self.last != self.last or self.volume != self.volume

    def __getitem__(self, key: String) -> Float64:
        if key == "last":
            return self.last
        elif key == "open":
            return self.open
        elif key == "high":
            return self.high
        elif key == "low":
            return self.low
        elif key == "prev_close":
            return self.prev_close
        elif key == "volume":
            return self.volume
        elif key == "total_turnover":
            return self.total_turnover
        elif key == "open_interest":
            return self.open_interest
        elif key == "prev_settlement":
            return self.prev_settlement
        elif key == "limit_up":
            return self.limit_up
        elif key == "limit_down":
            return self.limit_down
        else:
            return 0.0

    def get_ask(self, level: Int) -> Float64:
        if level >= 0 and level < len(self.asks):
            return self.asks[level]
        return 0.0

    def get_bid(self, level: Int) -> Float64:
        if level >= 0 and level < len(self.bids):
            return self.bids[level]
        return 0.0

    def get_ask_vol(self, level: Int) -> Float64:
        if level >= 0 and level < len(self.ask_vols):
            return self.ask_vols[level]
        return 0.0

    def get_bid_vol(self, level: Int) -> Float64:
        if level >= 0 and level < len(self.bid_vols):
            return self.bid_vols[level]
        return 0.0


def _default_order_book() -> List[Float64]:
    var result = List[Float64]()
    for _ in range(ORDER_BOOK_LEVELS):
        result.append(0.0)
    return result^


def _get_or(d: Dict[String, TickValue], key: String, default: Float64) raises -> Float64:
    if key in d:
        var v = d[key]
        if v.isa[Float64]():
            return v[Float64]
    return default


def _get_or(d: Dict[String, TickValue], key: String, default: DateTime) raises -> DateTime:
    if key in d:
        var v = d[key]
        if v.isa[DateTime]():
            return v[DateTime]
    return default


def _get_or_list(d: Dict[String, TickValue], key: String) raises -> List[Float64]:
    if key in d:
        var v = d[key]
        if v.isa[List[Float64]]():
            return v[List[Float64]].copy()
    return _default_order_book()


def create_tick_object(
    var instrument: Instrument,
    var dt: DateTime,
    last: Float64 = 10.5,
    volume: Float64 = 10000.0,
    total_turnover: Float64 = 105000.0,
    open: Float64 = 10.0,
    high: Float64 = 11.0,
    low: Float64 = 9.0,
    prev_close: Float64 = 10.0,
    limit_up: Float64 = 11.55,
    limit_down: Float64 = 9.45,
) raises -> TickObject:
    var tick_dict = Dict[String, TickValue]()
    tick_dict["datetime"] = TickValue(dt^)
    tick_dict["last"] = TickValue(last)
    tick_dict["volume"] = TickValue(volume)
    tick_dict["total_turnover"] = TickValue(total_turnover)
    tick_dict["open"] = TickValue(open)
    tick_dict["high"] = TickValue(high)
    tick_dict["low"] = TickValue(low)
    tick_dict["prev_close"] = TickValue(prev_close)
    tick_dict["limit_up"] = TickValue(limit_up)
    tick_dict["limit_down"] = TickValue(limit_down)
    return TickObject(instrument^, tick_dict^)
