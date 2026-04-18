"""
RQAlpha Mojo - Simulation Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_broker.py
"""

from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, INSTRUMENT_TYPE, MATCHING_TYPE, POSITION_EFFECT, EXECUTION_PHASE, RUN_TYPE
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.core.events import EVENT, Event

from rqmojo.mod.rqmojo_mod_sys_simulation.matcher import (
    DefaultBarMatcher, DefaultTickMatcher,
    create_default_bar_matcher, create_default_tick_matcher
)
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import SlippageDecider


@fieldwise_init
struct BrokerState(Movable):
    var open_orders_state: List[String]
    var open_auction_orders_state: List[String]


@fieldwise_init
struct SimulationBroker(Movable):
    var _mod_config_name: String
    var _match_immediately: Bool
    var _open_order_ids: List[Int]
    var _open_auction_order_ids: List[Int]
    var _open_exercise_order_ids: List[Int]
    var _trade_id: Int
    var _order_count: Int
    var _matching_type: MATCHING_TYPE
    var _slippage_model: String
    var _slippage: Float64
    var _volume_percent: Float64
    var _price_limit: Bool
    var _inactive_limit: Bool
    var _volume_limit: Bool
    var _liquidity_limit: Bool
    var _frequency: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationBroker(orders=", String(len(self._open_order_ids)), ")")

    def submit_order(mut self, mut order: Order) raises -> None:
        if order.position_effect == POSITION_EFFECT.MATCH:
            raise Error("unsupported position_effect MATCH")
        if order.is_final():
            return
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            self._open_exercise_order_ids.append(order.order_id)
            return

        var pending_event = Event(EVENT.ORDER_PENDING_NEW.value)

        self._open_order_ids.append(order.order_id)

        order.active()
        var creation_event = Event(EVENT.ORDER_CREATION_PASS.value)

        if self._match_immediately:
            self._match()

    def cancel_order(mut self, mut order: Order) -> None:

        var pending_cancel_event = Event(EVENT.ORDER_PENDING_CANCEL.value)

        order.mark_cancelled(String(order.order_id) + " order has been cancelled by user.")

        var pass_cancel_event = Event(EVENT.ORDER_CANCELLATION_PASS.value)

        var new_ids = List[Int]()
        for i in range(len(self._open_order_ids)):
            if self._open_order_ids[i] != order.order_id:
                new_ids.append(self._open_order_ids[i])
        self._open_order_ids = new_ids^

    def get_open_orders(self, order_book_id: String = "") -> List[Int]:
        var result = List[Int]()
        for i in range(len(self._open_order_ids)):
            result.append(self._open_order_ids[i])
        for i in range(len(self._open_auction_order_ids)):
            result.append(self._open_auction_order_ids[i])
        return result^

    def register_matcher(mut self, instrument_type_str: String, matcher: DefaultBarMatcher) -> None:
        pass

    def _get_bar_matcher(self, order_book_id: String) -> DefaultBarMatcher:
        return create_default_bar_matcher(
            matching_type=self._matching_type,
            slippage_model=self._slippage_model,
            slippage=self._slippage,
            volume_percent=self._volume_percent,
            price_limit=self._price_limit,
            inactive_limit=self._inactive_limit,
            volume_limit=self._volume_limit
        )

    def _get_tick_matcher(self, order_book_id: String) -> DefaultTickMatcher:
        return create_default_tick_matcher(
            matching_type=self._matching_type,
            slippage_model=self._slippage_model,
            slippage=self._slippage,
            volume_percent=self._volume_percent,
            price_limit=self._price_limit,
            liquidity_limit=self._liquidity_limit,
            volume_limit=self._volume_limit
        )

    def before_trading(mut self) -> None:
        pass

    def after_trading(mut self) -> None:
        self._open_order_ids = List[Int]()

    def pre_settlement(mut self) -> None:
        self._open_exercise_order_ids = List[Int]()

    def on_bar(mut self, event: Event) -> None:
        self._match()

    def on_tick(mut self, event: Event, tick_ob_id: String) -> None:
        self._match(tick_ob_id)

    def _match(mut self, order_book_id: String = "") -> None:
        pass

    def get_state(self) -> BrokerState:
        var open_orders_state = List[String]()
        for i in range(len(self._open_order_ids)):
            open_orders_state.append(String(self._open_order_ids[i]))
        var open_auction_orders_state = List[String]()
        for i in range(len(self._open_auction_order_ids)):
            open_auction_orders_state.append(String(self._open_auction_order_ids[i]))
        return BrokerState(
            open_orders_state=open_orders_state^,
            open_auction_orders_state=open_auction_orders_state^
        )

    def set_state(mut self, state: BrokerState) -> None:
        pass


def create_simulation_broker(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    volume_percent: Float64 = 0.25,
    price_limit: Bool = True,
    inactive_limit: Bool = True,
    volume_limit: Bool = True,
    liquidity_limit: Bool = False,
    frequency: String = "1d"
) -> SimulationBroker:
    var match_immediately = (
        matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE
        or matching_type == MATCHING_TYPE.VWAP
    )
    return SimulationBroker(
        _mod_config_name="sys_simulation",
        _match_immediately=match_immediately,
        _open_order_ids=List[Int](),
        _open_auction_order_ids=List[Int](),
        _open_exercise_order_ids=List[Int](),
        _trade_id=0,
        _order_count=0,
        _matching_type=matching_type,
        _slippage_model=slippage_model,
        _slippage=slippage,
        _volume_percent=volume_percent,
        _price_limit=price_limit,
        _inactive_limit=inactive_limit,
        _volume_limit=volume_limit,
        _liquidity_limit=liquidity_limit,
        _frequency=frequency
    )
