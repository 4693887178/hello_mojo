"""
RQAlpha Mojo - Signal Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/signal_broker.py
"""

from std.collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.core.events import EVENT, Event
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import SlippageDecider


@fieldwise_init
struct SignalBroker(Movable):
    var _slippage_decider: SlippageDecider
    var _price_limit: Bool

    def submit_order(mut self, mut order: Order) raises -> None:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("SignalBroker does not support exercise order temporarily")

        var pending_event = Event(EVENT.ORDER_PENDING_NEW.value)

        if order.is_final():
            return

        order.active()
        var creation_event = Event(EVENT.ORDER_CREATION_PASS.value)

        self._match(order)

    def cancel_order(mut self, order: Order) -> None:
        pass

    def get_open_orders(self) -> List[Order]:
        return List[Order]()

    def _match(mut self, mut order: Order) raises -> None:
        var order_book_id = order.order_book_id
        var last_price = 10.0

        if last_price <= 0.0:
            order.mark_rejected(
                "Order Cancelled: current bar [" + order_book_id + "] miss market data."
            )
            var unsolicited_event2 = Event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
            return

        var deal_price: Float64
        if order.order_type() == ORDER_TYPE.LIMIT:
            deal_price = order.frozen_price
        else:
            deal_price = last_price

        if self._price_limit and order.position_effect != POSITION_EFFECT.EXERCISE:
            if order.side == SIDE.BUY and deal_price >= 11.0:
                order.mark_rejected("Order Cancelled: current bar [" + order_book_id + "] reach the limit_up price.")
                var reject_event = Event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
                return
            if order.side == SIDE.SELL and deal_price <= 9.0:
                order.mark_rejected("Order Cancelled: current bar [" + order_book_id + "] reach the limit_down price.")
                var reject_event2 = Event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
                return

        var trade_price = self._slippage_decider.get_trade_price(order, deal_price)

        order.fill(order.quantity, trade_price)

        var trade_event = Event(EVENT.TRADE.value)


def create_signal_broker(
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    price_limit: Bool = True
) -> SignalBroker:
    return SignalBroker(
        _slippage_decider=SlippageDecider(module_name=slippage_model, rate=slippage),
        _price_limit=price_limit
    )
