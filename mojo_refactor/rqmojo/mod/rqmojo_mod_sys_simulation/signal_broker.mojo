"""
RQAlpha Mojo - Signal Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/signal_broker.py
"""

from std.collections import Dict, List
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.core.events import EVENT, Event, EventValue
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import SlippageDecider, is_valid_price
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct SignalBroker(Movable):
    var _env: Environment
    var _slippage_decider: SlippageDecider
    var _price_limit: Bool

    def submit_order(mut self, mut order: Order) raises -> None:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("SignalBroker does not support exercise order temporarily")

        var account = self._env.get_account(order.order_book_id)

        var pending_event = Event(EVENT.ORDER_PENDING_NEW.value)
        pending_event.attributes["account_type"] = EventValue(account.account_type.value)
        pending_event.attributes["order_id"] = EventValue(order.order_id)
        self._env.publish_event(pending_event)

        if order.is_final():
            return

        order.active()

        var creation_event = Event(EVENT.ORDER_CREATION_PASS.value)
        creation_event.attributes["account_type"] = EventValue(account.account_type.value)
        creation_event.attributes["order_id"] = EventValue(order.order_id)
        self._env.publish_event(creation_event)

        self._match(account, order)

    def cancel_order(mut self, order: Order) -> None:
        print("WARNING: cancel_order function is not supported in signal mode")

    def get_open_orders(self) -> List[Order]:
        return List[Order]()

    def _match(mut self, account: Account, mut order: Order) raises -> None:
        var order_book_id = order.order_book_id

        var last_price = self._env.price_board().get_last_price(order_book_id)

        if not is_valid_price(last_price):
            var instrument = self._env.get_instrument(order_book_id)
            var listed_date = instrument.listed_date()
            var trading_date = self._env.trading_dt()
            if listed_date.year == trading_date.year and listed_date.month == trading_date.month and listed_date.day == trading_date.day:
                var reason = (
                    "Order Cancelled: current security [" + order_book_id
                    + "] can not be traded in listed date ["
                    + String(listed_date.year) + "-"
                    + String(listed_date.month) + "-"
                    + String(listed_date.day) + "]"
                )
                order.mark_rejected(reason)
            else:
                order.mark_rejected(
                    "Order Cancelled: current bar [" + order_book_id + "] miss market data."
                )
            var unsolicited_event = Event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
            unsolicited_event.attributes["order_id"] = EventValue(order.order_id)
            unsolicited_event.attributes["reason"] = EventValue(order.message)
            self._env.publish_event(unsolicited_event)
            return

        var deal_price: Float64
        if order.order_type() == ORDER_TYPE.LIMIT:
            deal_price = order.frozen_price
        elif order.order_type() == ORDER_TYPE.ALGO:
            deal_price = last_price
        else:
            deal_price = last_price

        if self._price_limit and order.position_effect != POSITION_EFFECT.EXERCISE:
            var limit_up = self._env.price_board().get_limit_up(order_book_id)
            var limit_down = self._env.price_board().get_limit_down(order_book_id)
            if order.side == SIDE.BUY and is_valid_price(limit_up) and deal_price >= limit_up:
                order.mark_rejected(
                    "Order Cancelled: current bar [" + order_book_id + "] reach the limit_up price."
                )
                var reject_event = Event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
                reject_event.attributes["order_id"] = EventValue(order.order_id)
                reject_event.attributes["reason"] = EventValue(order.message)
                self._env.publish_event(reject_event)
                return
            if order.side == SIDE.SELL and is_valid_price(limit_down) and deal_price <= limit_down:
                order.mark_rejected(
                    "Order Cancelled: current bar [" + order_book_id + "] reach the limit_down price."
                )
                var reject_event2 = Event(EVENT.ORDER_UNSOLICITED_UPDATE.value)
                reject_event2.attributes["order_id"] = EventValue(order.order_id)
                reject_event2.attributes["reason"] = EventValue(order.message)
                self._env.publish_event(reject_event2)
                return

        var ct_amount = account.calc_close_today_amount(
            order_book_id, order.quantity, order.position_direction(), order.position_effect
        )
        var trade_price = self._slippage_decider.get_trade_price(order, deal_price)

        var trade = create_trade_with_id(
            trade_id=order.order_id,
            order=order,
            quantity=order.quantity,
            price=trade_price
        )
        trade.close_today_amount = ct_amount

        order.fill(order.quantity, trade_price)

        var trade_event = Event(EVENT.TRADE.value)
        trade_event.attributes["order_id"] = EventValue(order.order_id)
        trade_event.attributes["trade_id"] = EventValue(trade.trade_id)
        trade_event.attributes["price"] = EventValue(trade.price)
        trade_event.attributes["quantity"] = EventValue(trade.quantity)
        self._env.publish_event(trade_event)


def create_signal_broker(
    var env: Environment,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    price_limit: Bool = True
) raises -> SignalBroker:
    return SignalBroker(
        _env=env^,
        _slippage_decider=SlippageDecider(module_name=slippage_model, rate=slippage),
        _price_limit=price_limit
    )
