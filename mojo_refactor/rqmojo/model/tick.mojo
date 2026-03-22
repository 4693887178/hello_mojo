"""
RQAlpha Mojo - Tick Object Model
Ported from rqalpha/model/tick.py
"""

from rqmojo.const import INSTRUMENT_TYPE, MARKET
from rqmojo.model.instrument import Instrument, create_instrument_from_dict
from rqmojo.utils.datetime_func import DateTime
from rqmojo.utils.i18n import gettext
from rqmojo.utils.repr import dict_repr_from_dict
from std.collections import Dict, List


comptime __all__: List[String] = [
    "TickObject",
    "create_tick_object",
]


@fieldwise_init
struct TickObject(Writable, Movable, Copyable, ImplicitlyCopyable):
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

    def __str__(self) -> String:
        var props = Dict[String, String]()
        props["order_book_id"] = self._order_book_id
        props["datetime"] = self.datetime.__str__()
        props["last"] = String(self.last)
        return dict_repr_from_dict("TickObject", props)

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.__str__())

    def order_book_id(self) -> String:
        return self._order_book_id

    def instrument(self) -> Instrument:
        return self._instrument

    def close(self) -> Float64:
        return self.last


def create_tick_object(
    var instrument: Instrument,
    dt: DateTime,
    last: Float64,
    volume: Float64,
    total_turnover: Float64,
    open: Float64 = 1.0,
    high: Float64 = 1.0,
    low: Float64 = 1.0,
    prev_close: Float64 = 0.0,
    limit_up: Float64 = 0.0,
    limit_down: Float64 = 0.0
) -> TickObject:
    return TickObject(
        _order_book_id=instrument.order_book_id(),
        _instrument=instrument^,
        datetime=dt,
        last=last,
        volume=volume,
        total_turnover=total_turnover,
        open=open,
        high=high,
        low=low,
        prev_close=prev_close,
        limit_up=limit_up,
        limit_down=limit_down
    )
