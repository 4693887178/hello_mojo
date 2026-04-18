"""
RQAlpha Mojo - Order Matcher
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/matcher.py
"""

from std.collections import Dict
from rqmojo.const import MATCHING_TYPE, SIDE, ORDER_TYPE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.model.bar import BarObject
from rqmojo.core.events import EVENT, Event
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import SlippageDecider


comptime LIMIT_PRICE_VALID_THRESHOLD = 1e-7


def _price_reaches_limit(order_book_id: String, side: SIDE, deal_price: Float64, limit_up: Float64, limit_down: Float64) -> Bool:
    if side == SIDE.BUY:
        return deal_price >= limit_up or abs(deal_price - limit_up) < LIMIT_PRICE_VALID_THRESHOLD
    elif side == SIDE.SELL:
        return deal_price <= limit_down or abs(deal_price - limit_down) < LIMIT_PRICE_VALID_THRESHOLD
    else:
        return False


@fieldwise_init
struct DefaultBarMatcher(Movable):
    var _slippage_decider: SlippageDecider
    var _turnover: Dict[String, Int]
    var _volume_percent: Float64
    var _price_limit: Bool
    var _inactive_limit: Bool
    var _volume_limit: Bool
    var _matching_type: MATCHING_TYPE

    def match(mut self, account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        if order.position_effect not in [POSITION_EFFECT.OPEN, POSITION_EFFECT.CLOSE, POSITION_EFFECT.CLOSE_TODAY]:
            raise Error("Unsupported position_effect")
        if order.side not in [SIDE.BUY, SIDE.SELL]:
            raise Error("Unsupported side")

        var order_book_id = order.order_book_id
        var deal_price = self._get_deal_price(order_book_id)

        if deal_price <= 0.0:
            order.mark_rejected("Order Cancelled: invalid deal price for " + order_book_id)
            return

        if order.order_type() == ORDER_TYPE.LIMIT:
            if order.side == SIDE.BUY and order.price < deal_price:
                return
            if order.side == SIDE.SELL and order.price > deal_price:
                return
            if self._price_limit:
                if _price_reaches_limit(order_book_id, order.side, deal_price, 11.0, 9.0):
                    return
        else:
            if self._price_limit:
                if _price_reaches_limit(order_book_id, order.side, deal_price, 11.0, 9.0):
                    order.mark_rejected(
                        "Order Cancelled: current bar [" + order_book_id + "] reach the "
                        + ("limit_up" if order.side == SIDE.BUY else "limit_down") + " price."
                    )
                    return

        var fill_qty = order.unfilled_quantity
        if self._volume_limit and fill_qty > 0:
            var volume_limit = Int(Float64(fill_qty) * self._volume_percent)
            var existing_turnover = 0
            try:
                existing_turnover = self._turnover[order_book_id]
            except:
                pass
            volume_limit -= existing_turnover
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
            price = self._slippage_decider.get_trade_price(order, deal_price)

        order.fill(fill_qty, price)

        try:
            self._turnover[order_book_id] += fill_qty
        except:
            self._turnover[order_book_id] = fill_qty

        if order.order_type() == ORDER_TYPE.MARKET and order.unfilled_quantity != 0:
            order.mark_cancelled(
                "Order Cancelled: market order " + order_book_id + " volume "
                + String(order.quantity) + " is larger than "
                + String(self._volume_percent * 100.0) + " percent of bar volume"
            )

    def _get_deal_price(self, order_book_id: String) -> Float64:
        if self._matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE:
            return 10.0
        elif self._matching_type == MATCHING_TYPE.VWAP:
            return 10.0
        elif self._matching_type == MATCHING_TYPE.NEXT_BAR_OPEN:
            return 10.0
        return 10.0

    def update(mut self, event: Event) -> None:
        self._turnover.clear()


@fieldwise_init
struct DefaultTickMatcher(Movable):
    var _slippage_decider: SlippageDecider
    var _turnover: Dict[String, Int]
    var _volume_percent: Float64
    var _price_limit: Bool
    var _liquidity_limit: Bool
    var _volume_limit: Bool
    var _matching_type: MATCHING_TYPE
    var _last_volume: Dict[String, Int]
    var _cur_volume: Dict[String, Int]

    def match(mut self, account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        if order.position_effect not in [POSITION_EFFECT.OPEN, POSITION_EFFECT.CLOSE, POSITION_EFFECT.CLOSE_TODAY]:
            raise Error("Unsupported position_effect")
        if order.side not in [SIDE.BUY, SIDE.SELL]:
            raise Error("Unsupported side")

        var order_book_id = order.order_book_id
        var cur_vol = 1000

        var deal_price = self._get_deal_price(order_book_id, order.side)

        if deal_price <= 0.0:
            order.mark_rejected("Order Cancelled: " + order_book_id + " miss market data.")
            return

        var price = self._slippage_decider.get_trade_price(order, deal_price)

        if order.order_type() == ORDER_TYPE.LIMIT:
            if order.side == SIDE.BUY and order.price < deal_price:
                return
            if order.side == SIDE.SELL and order.price > deal_price:
                return
            if self._price_limit:
                if _price_reaches_limit(order_book_id, order.side, deal_price, 11.0, 9.0):
                    return
        else:
            if self._price_limit:
                if _price_reaches_limit(order_book_id, order.side, deal_price, 11.0, 9.0):
                    order.mark_rejected(
                        "Order Cancelled: current tick [" + order_book_id + "] reach the "
                        + ("limit_up" if order.side == SIDE.BUY else "limit_down") + " price."
                    )
                    return

        var fill_qty = order.unfilled_quantity
        if self._volume_limit and fill_qty > 0:
            var last_vol = 0
            try:
                last_vol = self._last_volume[order_book_id]
            except:
                pass

            var volume: Int
            if last_vol > 0:
                volume = max(0, cur_vol - last_vol)
            else:
                volume = cur_vol

            var volume_limit = Int(Float64(volume) * self._volume_percent)
            var existing_turnover = 0
            try:
                existing_turnover = self._turnover[order_book_id]
            except:
                pass
            volume_limit -= existing_turnover

            if volume_limit <= 0:
                if order.order_type() == ORDER_TYPE.MARKET:
                    order.mark_cancelled(
                        "Order Cancelled: market order " + order_book_id
                        + " volume " + String(order.quantity) + " due to volume limit"
                    )
                return
            fill_qty = min(fill_qty, volume_limit)

        order.fill(fill_qty, price)

        try:
            self._turnover[order_book_id] += fill_qty
        except:
            self._turnover[order_book_id] = fill_qty

        if order.order_type() == ORDER_TYPE.MARKET and order.unfilled_quantity != 0:
            order.mark_cancelled(
                "Order Cancelled: market order " + order_book_id + " volume "
                + String(order.quantity) + " is larger than "
                + String(self._volume_percent * 100.0) + " percent of tick volume"
            )

    def _get_deal_price(self, order_book_id: String, side: SIDE) -> Float64:
        if self._matching_type == MATCHING_TYPE.NEXT_TICK_LAST:
            return 10.0
        elif self._matching_type == MATCHING_TYPE.NEXT_TICK_BEST_OWN:
            var best_own = 9.99 if side == SIDE.BUY else 10.01
            if best_own == 0.0:
                best_own = 10.0
            return best_own
        elif self._matching_type == MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY:
            if side == SIDE.BUY:
                return 10.01
            else:
                return 9.99
        elif self._matching_type == MATCHING_TYPE.COUNTERPARTY_OFFER:
            return 10.0
        return 10.0

    def update(mut self, event: Event) -> None:
        self._turnover.clear()


def create_default_bar_matcher(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    volume_percent: Float64 = 0.25,
    price_limit: Bool = True,
    inactive_limit: Bool = True,
    volume_limit: Bool = True
) -> DefaultBarMatcher:
    return DefaultBarMatcher(
        _slippage_decider=SlippageDecider(module_name=slippage_model, rate=slippage),
        _turnover=Dict[String, Int](),
        _volume_percent=volume_percent,
        _price_limit=price_limit,
        _inactive_limit=inactive_limit,
        _volume_limit=volume_limit,
        _matching_type=matching_type
    )


def create_default_tick_matcher(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.NEXT_TICK_LAST,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    volume_percent: Float64 = 0.25,
    price_limit: Bool = True,
    liquidity_limit: Bool = False,
    volume_limit: Bool = True
) -> DefaultTickMatcher:
    return DefaultTickMatcher(
        _slippage_decider=SlippageDecider(module_name=slippage_model, rate=slippage),
        _turnover=Dict[String, Int](),
        _volume_percent=volume_percent,
        _price_limit=price_limit,
        _liquidity_limit=liquidity_limit,
        _volume_limit=volume_limit,
        _matching_type=matching_type,
        _last_volume=Dict[String, Int](),
        _cur_volume=Dict[String, Int]()
    )
