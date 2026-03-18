"""
RQAlpha Mojo - Bar Object Model
Ported from rqalpha/model/bar.py
"""

from rqmojo.const import INSTRUMENT_TYPE
from rqmojo.model.instrument import Instrument
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct BarObject(Stringable, Copyable, Movable, ImplicitlyCopyable):
    var instrument: Instrument
    var datetime: DateTime
    var open: Float64
    var high: Float64
    var low: Float64
    var close: Float64
    var volume: Float64
    var total_turnover: Float64
    var limit_up: Float64
    var limit_down: Float64
    var _suspended: Bool
    var _trading: Bool
    var prev_settlement: Float64
    var settlement: Float64
    var open_interest: Float64
    var prev_close: Float64
    
    fn __str__(self) -> String:
        return "BarObject(" + self.instrument.order_book_id + ", " + self.datetime.__str__() + ", close=" + String(self.close) + ")"
    
    fn is_trading(self) -> Bool:
        return self._trading
    
    fn suspended(self) -> Bool:
        return self._suspended
    
    fn last(self) -> Float64:
        return self.close
    
    fn vwap(self) -> Float64:
        if self.volume > 0:
            return self.total_turnover / self.volume
        else:
            return 0.0
    
    fn mavg(self, n: Int, frequency: String = "1d") -> Float64:
        return self.close
    
    fn isnan(self) -> Bool:
        return self.close <= 0


fn create_bar_object(
    instrument: Instrument,
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
    return BarObject(
        instrument=instrument,
        datetime=dt,
        open=open,
        high=high,
        low=low,
        close=close,
        volume=volume,
        total_turnover=total_turnover,
        limit_up=limit_up,
        limit_down=limit_down,
        _suspended=suspended,
        _trading=trading,
        prev_settlement=prev_settlement,
        settlement=settlement,
        open_interest=open_interest,
        prev_close=prev_close
    )


fn create_simple_bar(
    instrument: Instrument,
    dt: DateTime,
    open: Float64,
    high: Float64,
    low: Float64,
    close: Float64,
    volume: Float64
) -> BarObject:
    return create_bar_object(
        instrument=instrument,
        dt=dt,
        open=open,
        high=high,
        low=low,
        close=close,
        volume=volume,
        total_turnover=volume * close
    )
