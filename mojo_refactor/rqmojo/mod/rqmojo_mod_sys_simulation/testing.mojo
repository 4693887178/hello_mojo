"""
RQAlpha Mojo - Simulation Testing Utilities
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/testing.py
"""

from std.collections import Dict, List as StdList
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, EXCHANGE
from rqmojo.model.order import Order, create_order_with_id, OrderStyle, MarketOrder
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.typing import DateTime
from rqmojo.utils.testing.fixtures import EnvironmentFixture
from rqmojo.utils import RqAttrDict
from rqmojo.environment import Environment
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import SimulationEventSource, create_simulation_event_source


struct SimulationEventSourceFixture:
    var env_config: RqAttrDict
    var env: Optional[Environment]
    var simulation_event_source: Optional[SimulationEventSource]

    def __init__(out self):
        self.env_config = RqAttrDict()
        self.env = None
        self.simulation_event_source = None

    def init_fixture(mut self) -> None:
        var parent = EnvironmentFixture()
        parent.init_fixture()
        if self.env != None:
            self.simulation_event_source = create_simulation_event_source()


def create_test_order(order_book_id: String = "000001.XSHE", quantity: Int = 100, price: Float64 = 10.0, side: SIDE = SIDE.BUY) -> Order:
    var style = MarketOrder()
    return create_order_with_id(
        order_id=1,
        order_book_id=order_book_id,
        side=side,
        quantity=quantity,
        style=style,
        position_effect=POSITION_EFFECT.OPEN
    )


def create_test_bar(open_price: Float64 = 10.0, high: Float64 = 11.0, low: Float64 = 9.0, close: Float64 = 10.5, volume: Int = 1000000) -> BarObject:
    return create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2020, 1, 1, 9, 30, 0, 0),
        open=open_price,
        high=high,
        low=low,
        close=close,
        volume=Float64(volume),
        total_turnover=close * Float64(volume)
    )


def create_test_instrument(order_book_id: String = "000001.XSHE") -> Instrument:
    var parts = order_book_id.split(".")
    var symbol = String(parts[0])
    return create_stock_instrument(
        order_book_id=order_book_id,
        symbol=symbol,
        listed_date=DateTime(1990, 1, 1, 0, 0, 0, 0),
        exchange=EXCHANGE.XSHE
    )
