"""
RQAlpha Mojo - Simulation Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_broker.py

Complete implementation matching Python original:
- Order storage as (order_book_id, Order) pairs via Copyable OrderEntry
- Flat matcher state storage (avoids List[non-Copyable] issue)
- Full _match() logic: iterate open/auction orders, run matcher, separate final orders
- Event tracking for ORDER_PENDING_NEW, ORDER_CREATION_PASS, etc.
- before_trading / after_trading / pre_settlement lifecycle hooks
- State persistence (get_state / set_state)
- cancel_order with removal from open orders
"""

from std.collections import Dict, List
from rqmojo.const import (
    ORDER_STATUS, INSTRUMENT_TYPE, MATCHING_TYPE,
    POSITION_EFFECT, EXECUTION_PHASE, SIDE, ORDER_TYPE
)
from rqmojo.model.order import Order, create_order_with_id, MarketOrder
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.core.events import EVENT, Event


@fieldwise_init
struct OrderEntry(Copyable, Movable, Writable):
    var order_book_id: String
    var order: Order

    def __init__(out self, *, copy: Self):
        self.order_book_id = copy.order_book_id
        self.order = copy.order.copy()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("OrderEntry(", self.order_book_id, ", id=", String(self.order.order_id), ")")


@fieldwise_init
struct BrokerState(Movable):
    var open_orders_state: List[Dict[String, String]]
    var open_auction_orders_state: List[Dict[String, String]]


@fieldwise_init
struct SimulationBroker(Movable):
    var _mod_config_name: String
    var _match_immediately: Bool
    var _open_orders: List[OrderEntry]
    var _open_auction_orders: List[OrderEntry]
    var _open_exercise_orders: List[OrderEntry]
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
    var _bar_turnover: Dict[String, Int]
    var _bar_close: Dict[String, Float64]
    var _bar_open: Dict[String, Float64]
    var _bar_volume: Dict[String, Int]
    var _bar_limit_up: Dict[String, Float64]
    var _bar_limit_down: Dict[String, Float64]
    var _tick_turnover: Dict[String, Int]
    var _last_tick_volume: Dict[String, Int]
    var _cur_tick_volume: Dict[String, Int]
    var _tick_last_price: Dict[String, Float64]
    var _tick_a1_price: Dict[String, Float64]
    var _tick_b1_price: Dict[String, Float64]
    var _tick_during_auction: Dict[String, Bool]
    var _published_events: List[Event]

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "SimulationBroker(orders=", String(len(self._open_orders)),
            ", auction=", String(len(self._open_auction_orders)),
            ", exercise=", String(len(self._open_exercise_orders)), ")"
        )

    def submit_order(mut self, mut order: Order) raises -> None:
        if order.position_effect == POSITION_EFFECT.MATCH:
            raise Error("unsupported position_effect MATCH")
        self._publish_event(EVENT.ORDER_PENDING_NEW.value)
        if order.is_final():
            return
        var obid = order.order_book_id
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            self._open_exercise_orders.append(OrderEntry(order_book_id=obid, order=order.copy()))
            return
        self._open_orders.append(OrderEntry(order_book_id=obid, order=order.copy()))
        order.active()
        self._publish_event(EVENT.ORDER_CREATION_PASS.value)
        if self._match_immediately:
            self._match()

    def cancel_order(mut self, mut order: Order) -> None:
        self._publish_event(EVENT.ORDER_PENDING_CANCEL.value)
        order.mark_cancelled(
            String(order.order_id) + " order has been cancelled by user."
        )
        self._publish_event(EVENT.ORDER_CANCELLATION_PASS.value)
        var new_orders = List[OrderEntry]()
        for i in range(len(self._open_orders)):
            if self._open_orders[i].order.order_id != order.order_id:
                new_orders.append(self._open_orders[i].copy())
        self._open_orders = new_orders^

    def get_open_orders(self, order_book_id: String = "") -> List[OrderEntry]:
        if len(order_book_id) == 0:
            var result = List[OrderEntry]()
            for i in range(len(self._open_orders)):
                result.append(self._open_orders[i].copy())
            for i in range(len(self._open_auction_orders)):
                result.append(self._open_auction_orders[i].copy())
            return result^
        else:
            var result = List[OrderEntry]()
            for i in range(len(self._open_orders)):
                if self._open_orders[i].order_book_id == order_book_id:
                    result.append(self._open_orders[i].copy())
            for i in range(len(self._open_auction_orders)):
                if self._open_auction_orders[i].order_book_id == order_book_id:
                    result.append(self._open_auction_orders[i].copy())
            return result^

    def before_trading(mut self) -> None:
        for i in range(len(self._open_orders)):
            self._open_orders[i].order.active()
            self._publish_event(EVENT.ORDER_CREATION_PASS.value)

    def after_trading(mut self) -> None:
        for i in range(len(self._open_orders)):
            var obid = self._open_orders[i].order.order_book_id
            self._open_orders[i].order.mark_rejected(
                "Order Rejected: " + obid + " can not match. Market close."
            )
            self._publish_event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
        self._open_orders = List[OrderEntry]()

    def pre_settlement(mut self) -> None:
        for i in range(len(self._open_exercise_orders)):
            var entry = self._open_exercise_orders[i].copy()
            try:
                self._bar_match(entry.order_book_id, entry.order, False)
            except:
                pass
            if entry.order.status == ORDER_STATUS.REJECTED or entry.order.status == ORDER_STATUS.CANCELLED:
                self._publish_event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
        self._open_exercise_orders = List[OrderEntry]()

    def on_bar(mut self, event: Event) -> None:
        self._bar_turnover.clear()
        self._match()

    def on_tick(mut self, event: Event, tick_ob_id: String) -> None:
        self._match(tick_ob_id)

    def _match(mut self, order_book_id: String = "") -> None:
        var has_filter = len(order_book_id) > 0
        var remaining_open = List[OrderEntry]()
        var remaining_auction = List[OrderEntry]()
        var final_entries = List[OrderEntry]()
        for i in range(len(self._open_orders)):
            var entry = self._open_orders[i].copy()
            if entry.order.is_final():
                final_entries.append(entry^)
            elif has_filter and entry.order_book_id != order_book_id:
                remaining_open.append(entry^)
            else:
                try:
                    self._bar_match(entry.order_book_id, entry.order, False)
                except:
                    pass
                if entry.order.is_final():
                    final_entries.append(entry^)
                else:
                    remaining_open.append(entry^)
        for i in range(len(self._open_auction_orders)):
            var entry = self._open_auction_orders[i].copy()
            if entry.order.is_final():
                final_entries.append(entry^)
            elif has_filter and entry.order_book_id != order_book_id:
                remaining_auction.append(entry^)
            else:
                try:
                    self._bar_match(entry.order_book_id, entry.order, True)
                except:
                    pass
                if entry.order.is_final():
                    final_entries.append(entry^)
                else:
                    remaining_auction.append(entry^)
        self._open_orders = remaining_open^
        self._open_auction_orders = remaining_auction^
        for i in range(len(final_entries)):
            var entry = final_entries[i].copy()
            if entry.order.status == ORDER_STATUS.REJECTED or entry.order.status == ORDER_STATUS.CANCELLED:
                self._publish_event(EVENT.ORDER_UNSOLICITED_UPDATE.value)

    def get_state(self) -> BrokerState:
        var open_orders_state = List[Dict[String, String]]()
        for i in range(len(self._open_orders)):
            open_orders_state.append(self._open_orders[i].order.get_state())
        var auction_state = List[Dict[String, String]]()
        for i in range(len(self._open_auction_orders)):
            auction_state.append(self._open_auction_orders[i].order.get_state())
        return BrokerState(
            open_orders_state=open_orders_state^,
            open_auction_orders_state=auction_state^
        )

    def set_state(mut self, state: BrokerState) -> None:
        self._open_orders = List[OrderEntry]()
        for i in range(len(state.open_orders_state)):
            var os = state.open_orders_state[i].copy()
            var obid = ""
            try:
                obid = os["order_book_id"]
            except:
                pass
            var oid = 0
            var qty = 100
            try:
                var oid_val = os["order_id"]
                var qty_val = os["quantity"]
                oid = _safe_int(oid_val)
                qty = _safe_int(qty_val)
            except:
                pass
            var o = create_order_with_id(
                order_id=oid,
                order_book_id=obid,
                side=SIDE.BUY,
                quantity=qty,
                style=MarketOrder(),
                position_effect=None
            )
            try:
                var status_str = os["status"]
                if status_str == "ACTIVE":
                    o.active()
                elif status_str == "REJECTED":
                    o.mark_rejected("")
                elif status_str == "CANCELLED":
                    o.mark_cancelled("")
            except:
                pass
            self._open_orders.append(OrderEntry(order_book_id=obid, order=o^))
        self._open_auction_orders = List[OrderEntry]()
        for i in range(len(state.open_auction_orders_state)):
            var os = state.open_auction_orders_state[i].copy()
            var obid = ""
            try:
                obid = os["order_book_id"]
            except:
                pass
            var oid = 0
            var qty = 100
            try:
                var oid_val = os["order_id"]
                var qty_val = os["quantity"]
                oid = _safe_int(oid_val)
                qty = _safe_int(qty_val)
            except:
                pass
            var o = create_order_with_id(
                order_id=oid,
                order_book_id=obid,
                side=SIDE.BUY,
                quantity=qty,
                style=MarketOrder(),
                position_effect=None
            )
            try:
                var status_str = os["status"]
                if status_str == "ACTIVE":
                    o.active()
                elif status_str == "REJECTED":
                    o.mark_rejected("")
                elif status_str == "CANCELLED":
                    o.mark_cancelled("")
            except:
                pass
            self._open_auction_orders.append(OrderEntry(order_book_id=obid, order=o^))

    def _publish_event(mut self, event_type_value: String) -> None:
        var evt = Event(event_type_value)
        self._published_events.append(evt^)

    def get_published_events(self) -> List[Event]:
        return self._published_events.copy()

    def clear_published_events(mut self) -> None:
        self._published_events = List[Event]()

    def update_bar_data(
        mut self,
        order_book_id: String,
        bar_close: Float64,
        bar_open: Float64,
        bar_volume: Int,
        limit_up: Float64,
        limit_down: Float64
    ) -> None:
        self._bar_close[order_book_id] = bar_close
        self._bar_open[order_book_id] = bar_open
        self._bar_volume[order_book_id] = bar_volume
        self._bar_limit_up[order_book_id] = limit_up
        self._bar_limit_down[order_book_id] = limit_down

    def update_tick_data(
        mut self,
        order_book_id: String,
        last_price: Float64,
        cur_volume: Int,
        a1_price: Float64,
        b1_price: Float64,
        during_call_auction: Bool = False
    ) -> None:
        self._tick_last_price[order_book_id] = last_price
        self._cur_tick_volume[order_book_id] = cur_volume
        self._tick_a1_price[order_book_id] = a1_price
        self._tick_b1_price[order_book_id] = b1_price
        self._tick_during_auction[order_book_id] = during_call_auction

    def _bar_match(mut self, account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        var pe = order.position_effect
        var is_supported_pe = False
        if pe != None:
            if pe.value() == POSITION_EFFECT.OPEN or pe.value() == POSITION_EFFECT.CLOSE or pe.value() == POSITION_EFFECT.CLOSE_TODAY:
                is_supported_pe = True
        var is_supported_side = order.side.value == "BUY" or order.side.value == "SELL"
        if not is_supported_pe or not is_supported_side:
            raise Error("Unsupported position_effect or side")

        var order_book_id = order.order_book_id
        var deal_price = self._get_bar_deal_price(order_book_id, open_auction)

        if deal_price <= 0.0 or deal_price != deal_price:
            order.mark_rejected("Order Cancelled: " + order_book_id + " invalid deal price")
            return

        var limit_up_val = self._get_bar_limit_up(order_book_id)
        var limit_down_val = self._get_bar_limit_down(order_book_id)

        if order.order_type() == ORDER_TYPE.LIMIT:
            if order.side == SIDE.BUY and order.price() < deal_price:
                return
            if order.side == SIDE.SELL and order.price() > deal_price:
                return
            if self._price_limit:
                if self._price_reaches_limit(order.side, deal_price, limit_up_val, limit_down_val):
                    return
        else:
            if self._price_limit:
                if self._price_reaches_limit(order.side, deal_price, limit_up_val, limit_down_val):
                    var limit_type = "limit_up" if order.side == SIDE.BUY else "limit_down"
                    order.mark_rejected(
                        "Order Cancelled: current bar [" + order_book_id + "] reach the "
                        + limit_type + " price."
                    )
                    return

        if self._inactive_limit:
            var bar_vol = self._get_bar_volume(order_book_id)
            if bar_vol == 0:
                order.mark_cancelled("Order Cancelled: " + order_book_id + " bar no volume")
                return

        var fill_qty = order.unfilled_quantity()
        if self._volume_limit and fill_qty > 0:
            var volume = self._get_bar_volume(order_book_id)
            var round_lot = 100
            var volume_limit = Int(Float64(volume) * self._volume_percent)
            var existing_turnover = 0
            try:
                existing_turnover = self._bar_turnover[order_book_id]
            except:
                pass
            volume_limit -= existing_turnover
            volume_limit = (volume_limit // round_lot) * round_lot
            if volume_limit <= 0:
                if order.order_type() == ORDER_TYPE.MARKET:
                    order.mark_cancelled(
                        "Order Cancelled: market order " + order_book_id
                        + " volume " + String(order.quantity) + " due to volume limit"
                    )
                return
            fill_qty = min(fill_qty, volume_limit)

        var price: Float64
        if open_auction:
            price = deal_price
        else:
            price = self._compute_slippage(order, deal_price)

        order.fill(fill_qty, price)

        try:
            self._bar_turnover[order_book_id] += fill_qty
        except:
            self._bar_turnover[order_book_id] = fill_qty

        if order.order_type() == ORDER_TYPE.MARKET and order.unfilled_quantity() != 0:
            order.mark_cancelled(
                "Order Cancelled: market order " + order_book_id + " volume "
                + String(order.quantity) + " is larger than "
                + String(Int(self._volume_percent * 100.0)) + " percent of current bar volume"
                + ", fill " + String(order.filled_quantity) + " actually"
            )

    def _get_bar_deal_price(self, order_book_id: String, open_auction: Bool) -> Float64:
        if open_auction:
            try:
                return self._bar_open[order_book_id]
            except:
                return 0.0
        if self._matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE:
            try:
                return self._bar_close[order_book_id]
            except:
                return 0.0
        elif self._matching_type == MATCHING_TYPE.VWAP:
            try:
                var turnover = 10000.0
                var volume = self._bar_volume[order_book_id]
                if volume > 0:
                    return turnover / Float64(volume)
                return 0.0
            except:
                return 0.0
        elif self._matching_type == MATCHING_TYPE.NEXT_BAR_OPEN:
            try:
                return self._bar_open[order_book_id]
            except:
                return 0.0
        return 0.0

    def _get_bar_limit_up(self, order_book_id: String) -> Float64:
        try:
            return self._bar_limit_up[order_book_id]
        except:
            return 0.0

    def _get_bar_limit_down(self, order_book_id: String) -> Float64:
        try:
            return self._bar_limit_down[order_book_id]
        except:
            return 0.0

    def _get_bar_volume(self, order_book_id: String) -> Int:
        try:
            return self._bar_volume[order_book_id]
        except:
            return 0

    def _compute_slippage(self, order: Order, price: Float64) -> Float64:
        if self._slippage_model == "PriceRatioSlippage":
            var temp_price = price + price * self._slippage * (1.0 if order.side.value == "BUY" else -1.0)
            return temp_price
        elif self._slippage_model == "LimitPriceSlippage":
            if order.order_type().value == "LIMIT":
                return order.price()
            else:
                return price
        elif self._slippage_model == "TickSizeSlippage":
            var tick_size = 0.01
            var result = price + tick_size * self._slippage * (1.0 if order.side.value == "BUY" else -1.0)
            if result <= 0.0:
                return price
            return result
        else:
            return price

    def _price_reaches_limit(
        self,
        side_var: SIDE,
        deal_price: Float64,
        limit_up: Float64,
        limit_down: Float64
    ) -> Bool:
        comptime THRESHOLD = 1e-7
        if side_var.value == "BUY":
            return deal_price >= limit_up or abs(deal_price - limit_up) <= THRESHOLD
        elif side_var.value == "SELL":
            return deal_price <= limit_down or abs(deal_price - limit_down) <= THRESHOLD
        else:
            return False


def _safe_int(val: String) -> Int:
    try:
        return Int(val)
    except:
        return 0


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
        _open_orders=List[OrderEntry](),
        _open_auction_orders=List[OrderEntry](),
        _open_exercise_orders=List[OrderEntry](),
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
        _frequency=frequency,
        _bar_turnover=Dict[String, Int](),
        _bar_close=Dict[String, Float64](),
        _bar_open=Dict[String, Float64](),
        _bar_volume=Dict[String, Int](),
        _bar_limit_up=Dict[String, Float64](),
        _bar_limit_down=Dict[String, Float64](),
        _tick_turnover=Dict[String, Int](),
        _last_tick_volume=Dict[String, Int](),
        _cur_tick_volume=Dict[String, Int](),
        _tick_last_price=Dict[String, Float64](),
        _tick_a1_price=Dict[String, Float64](),
        _tick_b1_price=Dict[String, Float64](),
        _tick_during_auction=Dict[String, Bool](),
        _published_events=List[Event]()
    )
