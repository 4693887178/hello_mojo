"""
RQAlpha Mojo - Simulation Module Init
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/__init__.py
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.mod import SimulationMod, load_mod
from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import (
    DefaultBarMatcher,
    DefaultTickMatcher,
    create_default_bar_matcher,
    create_default_tick_matcher,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import (
    SimulationBroker,
    BrokerState,
    create_simulation_broker,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import (
    SimulationEventSource,
    create_simulation_event_source,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import (
    SignalBroker,
    create_signal_broker,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import (
    SlippageDecider,
    PriceRatioSlippage,
    TickSizeSlippage,
    LimitPriceSlippage,
    create_slippage_decider,
    create_price_ratio_slippage,
    create_tick_size_slippage,
    create_limit_price_slippage,
)
from rqmojo.mod.rqmojo_mod_sys_simulation.validator import (
    OrderStyleValidator,
    create_order_style_validator,
)


def get_mod_config_signal() -> Bool:
    return False

def get_mod_config_matching_type() -> String:
    return ""

def get_mod_config_price_limit() -> Bool:
    return True

def get_mod_config_liquidity_limit() -> Bool:
    return False

def get_mod_config_volume_limit() -> Bool:
    return True

def get_mod_config_volume_percent() -> Float64:
    return 0.25

def get_mod_config_slippage_model() -> String:
    return "PriceRatioSlippage"

def get_mod_config_slippage() -> Float64:
    return 0.0

def get_mod_config_inactive_limit() -> Bool:
    return True
