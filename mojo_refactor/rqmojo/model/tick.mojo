"""
RQAlpha Mojo - Tick Object Model
Ported from rqalpha/model/tick.py
"""

from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TickObject(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var instrument: Instrument
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
    
    fn __str__(self) -> String:
        return "TickObject(" + self.instrument.order_book_id + ", " + self.datetime.__str__() + ", last=" + String(self.last) + ")"
    
    fn close(self) -> Float64:
        return self.last
    
    fn order_book_id(self) -> String:
        return self.instrument.order_book_id


fn create_tick_object(
    instrument: Instrument,
    dt: DateTime,
    last: Float64,
    volume: Float64,
    total_turnover: Float64,
    open: Float64 = 0.0,
    high: Float64 = 0.0,
    low: Float64 = 0.0,
    prev_close: Float64 = 0.0,
    limit_up: Float64 = 0.0,
    limit_down: Float64 = 0.0
) -> TickObject:
    return TickObject(
        instrument=instrument,
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
