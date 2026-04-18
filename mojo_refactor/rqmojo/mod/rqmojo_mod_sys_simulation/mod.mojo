"""
RQAlpha Mojo - Simulation Mod
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/mod.py
"""

from std.collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, MATCHING_TYPE, RUN_TYPE, EXECUTION_PHASE
from rqmojo.model.order import Order
from rqmojo.core.events import EVENT, Event

from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_broker import SimulationBroker, create_simulation_broker
from rqmojo.mod.rqmojo_mod_sys_simulation.signal_broker import SignalBroker, create_signal_broker
from rqmojo.mod.rqmojo_mod_sys_simulation.simulation_event_source import SimulationEventSource, create_simulation_event_source
from rqmojo.mod.rqmojo_mod_sys_simulation.validator import OrderStyleValidator, create_order_style_validator


struct SimulationMod(Movable):
    var _env_name: String
    var _matching_type: MATCHING_TYPE
    var _slippage: Float64
    var _signal: Bool
    var _price_limit: Bool
    var _liquidity_limit: Bool
    var _volume_limit: Bool
    var _volume_percent: Float64
    var _slippage_model: String
    var _inactive_limit: Bool
    var _management_fee: List[String]
    var _frequency: String
    var _run_type: RUN_TYPE
    var _margin_multiplier: Float64

    def __init__(out self):
        self._env_name = ""
        self._matching_type = MATCHING_TYPE.CURRENT_BAR_CLOSE
        self._slippage = 0.0
        self._signal = False
        self._price_limit = True
        self._liquidity_limit = False
        self._volume_limit = True
        self._volume_percent = 0.25
        self._slippage_model = "PriceRatioSlippage"
        self._inactive_limit = True
        self._management_fee = List[String]()
        self._frequency = "1d"
        self._run_type = RUN_TYPE.BACKTEST
        self._margin_multiplier = 1.0

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationMod(matching=", self._matching_type.value, ")")

    def start_up(
        mut self,
        matching_type_str: String = "",
        slippage_model: String = "PriceRatioSlippage",
        slippage: Float64 = 0.0,
        signal: Bool = False,
        price_limit: Bool = True,
        liquidity_limit: Bool = False,
        volume_limit: Bool = True,
        volume_percent: Float64 = 0.25,
        inactive_limit: Bool = True,
        management_fee: List[String] = List[String](),
        frequency: String = "1d",
        run_type: RUN_TYPE = RUN_TYPE.BACKTEST,
        margin_multiplier: Float64 = 1.0
    ) raises -> None:
        self._frequency = frequency
        self._run_type = run_type
        self._margin_multiplier = margin_multiplier

        if run_type == RUN_TYPE.LIVE_TRADING:
            return

        var mt = self.parse_matching_type(matching_type_str, frequency)
        self._matching_type = mt

        if margin_multiplier <= 0.0:
            raise Error("invalid margin multiplier value: value range is (0, +inf]")

        if frequency == "tick":
            var tick_valid = (
                mt == MATCHING_TYPE.NEXT_TICK_LAST
                or mt == MATCHING_TYPE.NEXT_TICK_BEST_OWN
                or mt == MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY
                or mt == MATCHING_TYPE.COUNTERPARTY_OFFER
            )
            if not tick_valid:
                raise Error("Not supported matching type " + mt.value + " for tick frequency")
        else:
            var bar_valid = (
                mt == MATCHING_TYPE.NEXT_BAR_OPEN
                or mt == MATCHING_TYPE.VWAP
                or mt == MATCHING_TYPE.CURRENT_BAR_CLOSE
            )
            if not bar_valid:
                raise Error("Not supported matching type " + mt.value + " for bar frequency")

        if frequency == "1d" and mt == MATCHING_TYPE.NEXT_BAR_OPEN:
            self._matching_type = MATCHING_TYPE.CURRENT_BAR_CLOSE

        if signal:
            var sb = create_signal_broker(
                slippage_model=slippage_model,
                slippage=slippage,
                price_limit=price_limit
            )

        else:
            var sim_broker = create_simulation_broker(
                matching_type=self._matching_type,
                slippage_model=slippage_model,
                slippage=slippage,
                volume_percent=volume_percent,
                price_limit=price_limit,
                inactive_limit=inactive_limit,
                volume_limit=volume_limit,
                liquidity_limit=liquidity_limit,
                frequency=frequency
            )

        var event_source = create_simulation_event_source(frequency)

        var validator = create_order_style_validator(frequency)

    def tear_down(self, code: Int) -> None:
        pass

    @staticmethod
    def parse_matching_type(me_str: String, frequency: String) raises -> MATCHING_TYPE:
        var result = me_str
        if result == "":
            if frequency == "1d" or frequency == "1m":
                result = "current_bar"
            elif frequency == "tick":
                result = "last"
            else:
                raise Error("frequency only support ['1d', '1m', 'tick']")

        if result == "current_bar" or result == "CURRENT_BAR_CLOSE":
            return MATCHING_TYPE.CURRENT_BAR_CLOSE
        elif result == "vwap" or result == "VWAP":
            return MATCHING_TYPE.VWAP
        elif result == "next_bar" or result == "NEXT_BAR_OPEN":
            return MATCHING_TYPE.NEXT_BAR_OPEN
        elif result == "last" or result == "NEXT_TICK_LAST":
            return MATCHING_TYPE.NEXT_TICK_LAST
        elif result == "best_own" or result == "NEXT_TICK_BEST_OWN":
            return MATCHING_TYPE.NEXT_TICK_BEST_OWN
        elif result == "best_counterparty" or result == "NEXT_TICK_BEST_COUNTERPARTY":
            return MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY
        elif result == "counterparty_offer" or result == "COUNTERPARTY_OFFER":
            return MATCHING_TYPE.COUNTERPARTY_OFFER
        else:
            raise Error("NotImplementedError: unknown matching type " + result)

    def get_matching_type(self) -> MATCHING_TYPE:
        return self._matching_type

    def get_slippage(self) -> Float64:
        return self._slippage

    def register_management_fee_calculator(self, event: Event) -> None:
        for i in range(len(self._management_fee)):
            var item = self._management_fee[i]


def load_mod() -> SimulationMod:
    return SimulationMod()


def create_simulation_mod(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE,
    slippage: Float64 = 0.0
) -> SimulationMod:
    var mod = SimulationMod()
    mod._matching_type = matching_type
    mod._slippage = slippage
    return mod^


def load_mod_events(event_bus_ref: AnyType) -> None:
    pass
