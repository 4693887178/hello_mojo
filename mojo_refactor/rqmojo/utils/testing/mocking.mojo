"""
RQAlpha Mojo - Mocking Utilities
Ported from rqalpha/utils/testing/mocking.py

Python original provides 3 simple factory functions:
  - mock_instrument(order_book_id, _type, exchange, **kwargs)
  - mock_bar(instrument, **kwargs)
  - mock_tick(instrument, **kwargs)

Mojo version adds explicit parameters (no **kwargs in Mojo) plus:
  - MockDataProxy: mock data proxy for testing
  - create_mock_order: convenience factory for Order objects
"""

from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, SIDE, POSITION_EFFECT
from rqmojo.model.order import Order, OrderStyle, MarketOrder, create_order_with_id
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.tick import TickObject, create_tick_object
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime


def mock_instrument(
    order_book_id: String = "000001",
    ins_type: INSTRUMENT_TYPE = INSTRUMENT_TYPE.CS,
    exchange: EXCHANGE = EXCHANGE.XSHE,
) -> Instrument:
    var symbol = String(order_book_id.split(".")[0])
    return create_stock_instrument(
        order_book_id=order_book_id,
        symbol=symbol,
        listed_date=DateTime(1990, 1, 1, 0, 0, 0, 0),
        exchange=exchange,
    )


def mock_bar(
    instrument: Instrument,
    dt: DateTime,
    open: Float64 = 10.0,
    high: Float64 = 11.0,
    low: Float64 = 9.0,
    close: Float64 = 10.5,
    volume: Float64 = 1000000.0,
    total_turnover: Float64 = 10500000.0,
) -> BarObject:
    return create_bar_object(
        order_book_id=instrument.order_book_id(),
        dt=dt,
        open=open,
        high=high,
        low=low,
        close=close,
        volume=volume,
        total_turnover=total_turnover,
    )


def mock_tick(
    var instrument: Instrument,
    var dt: DateTime,
    last: Float64 = 10.5,
    volume: Float64 = 10000.0,
    total_turnover: Float64 = 105000.0,
) raises -> TickObject:
    return create_tick_object(
        instrument=instrument^,
        dt=dt^,
        last=last,
        volume=volume,
        total_turnover=total_turnover,
    )


struct MockDataProxy(Movable, Copyable):
    var _bars: Dict[String, BarObject]
    var _instruments: Dict[String, Instrument]

    def __init__(out self):
        self._bars = Dict[String, BarObject]()
        self._instruments = Dict[String, Instrument]()

    def get_bar(self, order_book_id: String, dt: DateTime) raises -> BarObject:
        if order_book_id in self._bars:
            return self._bars[order_book_id]
        return create_bar_object(
            order_book_id=order_book_id,
            dt=dt,
            open=10.0,
            high=11.0,
            low=9.0,
            close=10.5,
            volume=1000000.0,
            total_turnover=10500000.0,
            limit_up=11.5,
            limit_down=9.5,
            suspended=False,
            trading=True,
        )

    def get_instrument(self, order_book_id: String) raises -> Instrument:
        if order_book_id in self._instruments:
            return self._instruments[order_book_id]
        var symbol = String(order_book_id.split(".")[0])
        return create_stock_instrument(
            order_book_id, symbol,
            DateTime(1990, 1, 1, 0, 0, 0, 0), EXCHANGE.XSHE,
        )


def create_mock_data_proxy() -> MockDataProxy:
    return MockDataProxy()


def create_mock_order(
    order_book_id: String = "000001.XSHE",
    quantity: Int = 100,
    price: Float64 = 10.0,
) -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=SIDE.BUY,
        quantity=quantity,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN,
    )
