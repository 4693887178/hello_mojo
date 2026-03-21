"""
RQAlpha Mojo - Simulation Mod
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/
"""

from std.collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, MATCHING_TYPE, MATCHING_TYPE_CURRENT_BAR_CLOSE
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.utils.datetime_func import DateTime
from rqmojo.core.events import EVENT, EventBus, Event


@fieldwise_init
struct SimulationMod(Copyable, Movable, ImplicitlyCopyable, Writable):
    var name: String
    var enabled: Bool
    var matching_type: MATCHING_TYPE
    var slippage: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationMod(", self.name, ")")
    
    def start(self) -> None:
        pass
    
    def stop(self) -> None:
        pass
    
    def get_matching_type(self) -> MATCHING_TYPE:
        return self.matching_type
    
    def get_slippage(self) -> Float64:
        return self.slippage


@fieldwise_init
struct SimulationModState(Movable):
    var last_trade_id: Int
    var order_id_count: Int


def create_simulation_mod(
    matching_type: MATCHING_TYPE = MATCHING_TYPE_CURRENT_BAR_CLOSE,
    slippage: Float64 = 0.0
) -> SimulationMod:
    return SimulationMod(
        name="simulation",
        enabled=True,
        matching_type=matching_type,
        slippage=slippage
    )


def load_mod_events(event_bus: EventBus) -> None:
    pass
