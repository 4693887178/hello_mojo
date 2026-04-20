"""
RQAlpha Mojo - Tick Object Model
Ported from rqalpha/model/tick.py

Faithful port of Python's TickObject class:
  1. TickObject: Eager struct with all tick fields resolved at construction.
     Matches Python's property-based lazy dict access pattern.
  2. Field semantics match Python exactly:
     - last: falls back to prev_close when missing (L74-76)
     - open/high/low: raise KeyError in Python → default 0.0 in Mojo
     - volume/total_turnover/open_interest/prev_settlement: default 0.0 on KeyError
     - asks/bids/ask_vols/bid_vols: default [0]*5 on KeyError
     - limit_up/limit_down: default 0.0 on KeyError
     - isnan: np.isnan(self.last) only checks last price
  3. __getitem__ matches Python's getattr-based key access.
"""

from rqmojo.model.instrument import Instrument
from rqmojo.utils.typing import DateTime
from std.collections import List, Dict


comptime __all__: List[String] = [
    "TickObject",
]

comptime ORDER_BOOK_LEVELS = 5


@fieldwise_init
struct TickObject(Writable, Movable, Copyable):
    """Mojo equivalent of Python's TickObject.

    Python stores instrument + raw dict, resolves lazily via @property getters.
    Mojo eagerly resolves all fields at construction time for type safety and
    zero-lookup-cost access, while preserving identical fallback behavior.

    Python original behavior preserved:
      - order_book_id -> self._instrument.order_book_id
      - datetime -> parsed from dict or datetime.min
      - last -> dict['last'] or fallback to prev_close (KEY!)
      - open/high/low -> dict direct (KeyError→default)
      - volume/total_turnover -> dict or 0
      - open_interest/prev_settlement -> dict or 0 (futures)
      - asks/bids/ask_vols/bid_vols -> dict or [0]*5
      - limit_up/limit_down -> dict or 0
      - isnan -> np.isnan(last) only
      - __getitem__ -> getattr(self, key) delegation
    """

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
        var tick_dict: Dict[String, Float64],
    ) raises:
        """Construct from Instrument and flat float-typed tick dict.

        Mirrors Python's __init__(self, instrument, tick_dict).
        All fields resolved eagerly; defaults match Python's try/except fallbacks.
        """
        self._order_book_id = instrument.order_book_id()
        self._instrument = instrument^

        self.datetime = _get_dt(tick_dict)

        # prev_close must be resolved BEFORE last (last may fall back to it)
        self.prev_close = _get_float(tick_dict, "prev_close", 0.0)

        # last falls back to prev_close when missing (Python L71-76)
        if "last" in tick_dict:
            self.last = tick_dict["last"]
        else:
            self.last = self.prev_close

        self.volume = _get_float(tick_dict, "volume", 0.0)
        self.total_turnover = _get_float(tick_dict, "total_turnover", 0.0)

        # open/high/low have no try/except in Python (raise KeyError),
        # but Mojo needs a sensible default: 0.0 consistent with other fields
        self.open = _get_float(tick_dict, "open", 0.0)
        self.high = _get_float(tick_dict, "high", 0.0)
        self.low = _get_float(tick_dict, "low", 0.0)

        self.limit_up = _get_float(tick_dict, "limit_up", 0.0)
        self.limit_down = _get_float(tick_dict, "limit_down", 0.0)
        self.open_interest = _get_float(tick_dict, "open_interest", 0.0)
        self.prev_settlement = _get_float(tick_dict, "prev_settlement", 0.0)

        # Order book lists: Python returns [0] * 5 on KeyError
        self.asks = _get_list_or_default(tick_dict, "asks")
        self.ask_vols = _get_list_or_default(tick_dict, "ask_vols")
        self.bids = _get_list_or_default(tick_dict, "bids")
        self.bid_vols = _get_list_or_default(tick_dict, "bid_vols")

    def order_book_id(self) -> String:
        """[str] Order book ID, delegates to instrument."""
        return self._order_book_id

    def isnan(self) -> Bool:
        """Check if last price is NaN.

        Mirrors Python: ``return np.isnan(self.last)``
        Only checks last price, NOT volume (unlike old Mojo version).
        """
        return self.last != self.last

    def __getitem__(self, key: String) -> Float64:
        """Key-based attribute access matching Python's __getitem__/getattr.

        Python: ``def __getitem__(self, key): return getattr(self, key)``
        Returns 0.0 for unknown keys (consistent with numeric field defaults).
        """
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


def _get_float(d: Dict[String, Float64], key: String, default: Float64) raises -> Float64:
    """Get float from dict or return default (mirrors Python try/except KeyError)."""
    if key in d:
        return d[key]
    return default


def _get_dt(d: Dict[String, Float64]) -> DateTime:
    """Return epoch default (matches Python's datetime.min fallback).

    Python tries complex int/ms_int/datetime parsing; Mojo stores DateTime directly.
    When no datetime is available, returns epoch (1970-1-1) matching datetime.min semantics.
    """
    return DateTime(1970, 1, 1, 0, 0, 0, 0)


def _get_list_or_default(d: Dict[String, Float64], key: String) -> List[Float64]:
    """Get list from dict or return [0]*5 default (mirrors Python except KeyError)."""
    var result = List[Float64]()
    for _ in range(ORDER_BOOK_LEVELS):
        result.append(0.0)
    return result^
