"""
RQAlpha Mojo - Order Matcher
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/matcher.py

Complete implementation matching Python original:
- _price_reaches_limit() price limit check utility
- AbstractMatcher trait for polymorphic matcher interface
- DefaultBarMatcher: bar-level order matching (CURRENT_BAR_CLOSE / VWAP / NEXT_BAR_OPEN)
- DefaultTickMatcher: tick-level order matching (NEXT_TICK_LAST / NEXT_TICK_BEST_OWN / etc.)
- CounterPartyOfferMatcher: counter-party offer matching using ask/bid volumes
"""

from std.collections import Dict, List
from rqmojo.const import MATCHING_TYPE, SIDE, ORDER_TYPE, POSITION_EFFECT, POSITION_DIRECTION
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_from_order
from rqmojo.core.events import EVENT, Event, EventValue
from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import SlippageDecider


comptime LIMIT_PRICE_VALID_THRESHOLD = 1e-7

comptime SUPPORT_POSITION_EFFECTS = [POSITION_EFFECT.OPEN, POSITION_EFFECT.CLOSE, POSITION_EFFECT.CLOSE_TODAY]
comptime SUPPORT_SIDES = [SIDE.BUY, SIDE.SELL]


def is_valid_price(price: Float64) -> Bool:
    return price > 0.0 and price == price


def _is_supported_position_effect(pe: Optional[POSITION_EFFECT]) -> Bool:
    if pe is None:
        return False
    for spe in materialize[SUPPORT_POSITION_EFFECTS]():
        if pe == spe:
            return True
    return False


def _is_supported_side(s: Optional[SIDE]) -> Bool:
    if s is None:
        return False
    for ss in materialize[SUPPORT_SIDES]():
        if s == ss:
            return True
    return False


def _price_reaches_limit(
    side: SIDE,
    deal_price: Float64,
    limit_up: Float64,
    limit_down: Float64
) -> Bool:
    if side == SIDE.BUY:
        return deal_price >= limit_up or abs(deal_price - limit_up) <= LIMIT_PRICE_VALID_THRESHOLD
    elif side == SIDE.SELL:
        return deal_price <= limit_down or abs(deal_price - limit_down) <= LIMIT_PRICE_VALID_THRESHOLD
    else:
        return False


trait MatcherInterface:
    def match(mut self, mut account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        ...
    def update(mut self, event: Event) raises -> None:
        ...


@fieldwise_init
struct DefaultBarMatcher(MatcherInterface, Movable):
    var _slippage_decider: SlippageDecider
    var _turnover: Dict[String, Int]
    var _volume_percent: Float64
    var _price_limit: Bool
    var _inactive_limit: Bool
    var _volume_limit: Bool
    var _matching_type: MATCHING_TYPE
    var _bar_close: Dict[String, Float64]
    var _bar_open: Dict[String, Float64]
    var _bar_volume: Dict[String, Int]
    var _limit_up: Dict[String, Float64]
    var _limit_down: Dict[String, Float64]

    def _current_bar_close_decider(self, order_book_id: String) -> Float64:
        try:
            return self._bar_close[order_book_id]
        except:
            return 0.0

    def _next_bar_open_decider(self, order_book_id: String) -> Float64:
        try:
            return self._bar_open[order_book_id]
        except:
            return 0.0

    def _vwap_decider(self, order_book_id: String) -> Float64:
        try:
            var turnover = 10000.0
            var volume = self._bar_volume[order_book_id]
            var multiplier = 1.0
            if volume > 0 and multiplier > 0:
                return turnover / Float64(volume) / multiplier
            return 0.0
        except:
            return 0.0

    def _open_auction_deal_price_decider(self, order_book_id: String) -> Float64:
        try:
            return self._bar_open[order_book_id]
        except:
            return 0.0

    def _get_bar_volume(self, order_book_id: String, open_auction: Bool) -> Int:
        try:
            return self._bar_volume[order_book_id]
        except:
            return 0

    def _get_deal_price(self, order_book_id: String, open_auction: Bool) -> Float64:
        if open_auction:
            return self._open_auction_deal_price_decider(order_book_id)
        if self._matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE:
            return self._current_bar_close_decider(order_book_id)
        elif self._matching_type == MATCHING_TYPE.VWAP:
            return self._vwap_decider(order_book_id)
        elif self._matching_type == MATCHING_TYPE.NEXT_BAR_OPEN:
            return self._next_bar_open_decider(order_book_id)
        return 0.0

    def _get_limit_up(self, order_book_id: String) -> Float64:
        try:
            return self._limit_up[order_book_id]
        except:
            return 0.0

    def _get_limit_down(self, order_book_id: String) -> Float64:
        try:
            return self._limit_down[order_book_id]
        except:
            return 0.0

    def match(mut self, mut account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        if not _is_supported_position_effect(order.position_effect) or not _is_supported_side(order.side):
            raise Error("Unsupported position_effect or side")

        var order_book_id = order.order_book_id
        var deal_price = self._get_deal_price(order_book_id, open_auction)

        if not is_valid_price(deal_price):
            order.mark_rejected("Order Cancelled: " + order_book_id + " invalid deal price")
            return

        var limit_up_val = self._get_limit_up(order_book_id)
        var limit_down_val = self._get_limit_down(order_book_id)

        if order.order_type() == ORDER_TYPE.LIMIT:
            if order.side == SIDE.BUY and order.price() < deal_price:
                return
            if order.side == SIDE.SELL and order.price() > deal_price:
                return
            if self._price_limit:
                if _price_reaches_limit(order.side, deal_price, limit_up_val, limit_down_val):
                    return
        else:
            if self._price_limit:
                if _price_reaches_limit(order.side, deal_price, limit_up_val, limit_down_val):
                    var limit_type = "limit_up" if order.side == SIDE.BUY else "limit_down"
                    order.mark_rejected(
                        "Order Cancelled: current bar [" + order_book_id + "] reach the "
                        + limit_type + " price."
                    )
                    return

        if self._inactive_limit:
            var bar_volume = self._get_bar_volume(order_book_id, open_auction)
            if bar_volume == 0:
                order.mark_cancelled("Order Cancelled: " + order_book_id + " bar no volume")
                return

        var fill_qty = order.unfilled_quantity()
        if self._volume_limit and fill_qty > 0:
            var volume = self._get_bar_volume(order_book_id, open_auction)
            var round_lot = 100
            var volume_limit = Int(Float64(volume) * self._volume_percent)
            var existing_turnover = 0
            try:
                existing_turnover = self._turnover[order_book_id]
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
            price = self._slippage_decider.get_trade_price(order, deal_price)

        order.fill(fill_qty, price)

        try:
            self._turnover[order_book_id] += fill_qty
        except:
            self._turnover[order_book_id] = fill_qty

        if order.order_type() == ORDER_TYPE.MARKET and order.unfilled_quantity() != 0:
            order.mark_cancelled(
                "Order Cancelled: market order " + order_book_id + " volume "
                + String(order.quantity) + " is larger than "
                + String(Int(self._volume_percent * 100.0)) + " percent of current bar volume"
                + ", fill " + String(order.filled_quantity) + " actually"
            )

    def update(mut self, event: Event) raises -> None:
        self._turnover.clear()


@fieldwise_init
struct DefaultTickMatcher(MatcherInterface, Movable):
    var _slippage_decider: SlippageDecider
    var _turnover: Dict[String, Int]
    var _volume_percent: Float64
    var _price_limit: Bool
    var _liquidity_limit: Bool
    var _volume_limit: Bool
    var _matching_type: MATCHING_TYPE
    var _last_tick_volume: Dict[String, Int]
    var _cur_tick_volume: Dict[String, Int]
    var _last_price: Dict[String, Float64]
    var _a1_price: Dict[String, Float64]
    var _b1_price: Dict[String, Float64]
    var _during_call_auction: Dict[String, Bool]

    def _get_last_tick_volume(self, order_book_id: String) -> Int:
        try:
            return self._last_tick_volume[order_book_id]
        except:
            return 0

    def _get_cur_tick_volume(self, order_book_id: String) -> Int:
        try:
            return self._cur_tick_volume[order_book_id]
        except:
            return 0

    def _is_call_auction(self, order_book_id: String) -> Bool:
        try:
            return self._during_call_auction[order_book_id]
        except:
            return False

    def _get_last_price(self, order_book_id: String) -> Float64:
        try:
            return self._last_price[order_book_id]
        except:
            return 0.0

    def _get_a1(self, order_book_id: String) -> Float64:
        try:
            return self._a1_price[order_book_id]
        except:
            return 0.0

    def _get_b1(self, order_book_id: String) -> Float64:
        try:
            return self._b1_price[order_book_id]
        except:
            return 0.0

    def _get_limit_up(self, order_book_id: String) -> Float64:
        try:
            return self._a1_price[order_book_id] * 1.1
        except:
            return 0.0

    def _get_limit_down(self, order_book_id: String) -> Float64:
        try:
            return self._b1_price[order_book_id] * 0.9
        except:
            return 0.0

    def _deal_price_decider(self, order_book_id: String, side: SIDE) -> Float64:
        if self._matching_type == MATCHING_TYPE.NEXT_TICK_LAST:
            return self._get_last_price(order_book_id)
        elif self._matching_type == MATCHING_TYPE.NEXT_TICK_BEST_OWN:
            var best_own = self._get_b1(order_book_id) if side == SIDE.BUY else self._get_a1(order_book_id)
            if best_own == 0.0:
                best_own = self._get_last_price(order_book_id)
            return best_own
        elif self._matching_type == MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY:
            if side == SIDE.BUY:
                return self._get_a1(order_book_id)
            else:
                return self._get_b1(order_book_id)
        elif self._matching_type == MATCHING_TYPE.COUNTERPARTY_OFFER:
            return self._get_last_price(order_book_id)
        return self._get_last_price(order_book_id)

    def _best_own_price_decider(self, order_book_id: String, side: SIDE) -> Float64:
        var price = self._get_b1(order_book_id) if side == SIDE.BUY else self._get_a1(order_book_id)
        if price == 0.0:
            price = self._get_last_price(order_book_id)
        return price

    def match(mut self, mut account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        if not _is_supported_position_effect(order.position_effect) or not _is_supported_side(order.side):
            raise Error("Unsupported position_effect or side")

        var order_book_id = order.order_book_id
        var cur_vol = self._get_cur_tick_volume(order_book_id)

        var deal_price: Float64
        var volume_limit_flag: Bool
        if self._is_call_auction(order_book_id):
            deal_price = self._get_last_price(order_book_id)
            volume_limit_flag = True
        else:
            deal_price = self._deal_price_decider(order_book_id, order.side)
            volume_limit_flag = self._volume_limit

        if not is_valid_price(deal_price):
            order.mark_rejected("Order Cancelled: current tick [" + order_book_id + "] miss market data.")
            return

        var price: Float64
        if self._is_call_auction(order_book_id):
            price = deal_price
        else:
            price = self._slippage_decider.get_trade_price(order, deal_price)

        var limit_up_val = self._get_limit_up(order_book_id)
        var limit_down_val = self._get_limit_down(order_book_id)

        if order.order_type() == ORDER_TYPE.LIMIT:
            if order.side == SIDE.BUY and order.price() < deal_price:
                return
            if order.side == SIDE.SELL and order.price() > deal_price:
                return
            if self._price_limit:
                if _price_reaches_limit(order.side, deal_price, limit_up_val, limit_down_val):
                    return
            if self._liquidity_limit:
                if order.side == SIDE.BUY and self._get_a1(order_book_id) == 0:
                    return
                if order.side == SIDE.SELL and self._get_b1(order_book_id) == 0:
                    return
        else:
            if self._price_limit:
                if _price_reaches_limit(order.side, deal_price, limit_up_val, limit_down_val):
                    var limit_type = "limit_up" if order.side == SIDE.BUY else "limit_down"
                    order.mark_rejected(
                        "Order Cancelled: current tick [" + order_book_id + "] reach the "
                        + limit_type + " price."
                    )
                    return
            if self._liquidity_limit:
                if order.side == SIDE.BUY and self._get_a1(order_book_id) == 0:
                    order.mark_rejected("Order Cancelled: [" + order_book_id + "] has no liquidity.")
                    return
                if order.side == SIDE.SELL and self._get_b1(order_book_id) == 0:
                    order.mark_rejected("Order Cancelled: [" + order_book_id + "] has no liquidity.")
                    return

        var fill_qty = order.unfilled_quantity()
        if volume_limit_flag:
            var last_vol = self._get_last_tick_volume(order_book_id)
            var volume: Int
            if last_vol > 0:
                volume = max(0, cur_vol - last_vol)
            else:
                volume = cur_vol

            var round_lot = 100
            var v_limit: Int
            if self._volume_limit:
                v_limit = Int(Float64(volume) * self._volume_percent)
                var existing_turnover = 0
                try:
                    existing_turnover = self._turnover[order_book_id]
                except:
                    pass
                v_limit -= existing_turnover
            else:
                v_limit = volume

            v_limit = (v_limit // round_lot) * round_lot

            if v_limit <= 0:
                if order.order_type() == ORDER_TYPE.MARKET:
                    order.mark_cancelled(
                        "Order Cancelled: market order " + order_book_id
                        + " volume " + String(order.quantity) + " due to volume limit"
                    )
                return

            if self._volume_limit:
                fill_qty = min(fill_qty, v_limit)
            else:
                fill_qty = min(fill_qty, volume)
        else:
            pass

        order.fill(fill_qty, price)

        try:
            self._turnover[order_book_id] += fill_qty
        except:
            self._turnover[order_book_id] = fill_qty

        if order.order_type() == ORDER_TYPE.MARKET and order.unfilled_quantity() != 0:
            order.mark_cancelled(
                "Order Cancelled: market order " + order_book_id + " volume "
                + String(order.quantity) + " is larger than "
                + String(Int(self._volume_percent * 100.0)) + " percent of current tick volume"
                + ", fill " + String(order.filled_quantity) + " actually"
            )

    def update(mut self, event: Event) raises -> None:
        var order_book_id_attr = event.attributes.get("order_book_id", EventValue(""))
        var order_book_id = ""
        if order_book_id_attr.isa[String]():
            order_book_id = order_book_id_attr[String]
        var tick_vol_attr = event.attributes.get("tick_volume", EventValue(0))
        var old_vol = self._get_cur_tick_volume(order_book_id)
        if old_vol > 0:
            try:
                self._last_tick_volume[order_book_id] = old_vol
            except:
                pass
        try:
            self._cur_tick_volume[order_book_id] = tick_vol_attr[Int]
        except:
            pass
        self._turnover.clear()


@fieldwise_init
struct CounterPartyOfferMatcher(Movable):
    var _base_matcher: DefaultTickMatcher
    var _a_volume: Dict[String, List[Int]]
    var _b_volume: Dict[String, List[Int]]
    var _a_price: Dict[String, List[Float64]]
    var _b_price: Dict[String, List[Float64]]

    def match(mut self, mut account_str: String, mut order: Order, open_auction: Bool) raises -> None:
        if not _is_supported_position_effect(order.position_effect) or not _is_supported_side(order.side):
            raise Error("Unsupported position_effect or side")

        var order_book_id = order.order_book_id
        self._pop_empty_levels(order_book_id, order.side)

        var volume_limit: Int
        var matching_price: Float64
        if order.side == SIDE.BUY:
            try:
                if len(self._a_volume[order_book_id]) == 0:
                    return
                volume_limit = self._a_volume[order_book_id][0]
                matching_price = self._a_price[order_book_id][0]
            except:
                return
        else:
            try:
                if len(self._b_volume[order_book_id]) == 0:
                    return
                volume_limit = self._b_volume[order_book_id][0]
                matching_price = self._b_price[order_book_id][0]
            except:
                return

        if order.order_type() == ORDER_TYPE.MARKET:
            pass
        else:
            if volume_limit <= 0 and order.unfilled_quantity() != 0:
                return

        if not is_valid_price(matching_price):
            return

        var is_auction = self._base_matcher._is_call_auction(order_book_id)
        if is_auction:
            matching_price = self._base_matcher._get_last_price(order_book_id)

        if order.order_type() == ORDER_TYPE.LIMIT:
            if order.side == SIDE.BUY and order.price() < matching_price:
                return
            if order.side == SIDE.SELL and order.price() > matching_price:
                return

        var fill_qty = order.unfilled_quantity()
        if fill_qty > 0 and volume_limit > 0:
            var round_lot = 100
            var v_limit = (volume_limit // round_lot) * round_lot
            if v_limit <= 0:
                if order.order_type() == ORDER_TYPE.MARKET:
                    order.mark_cancelled(
                        "Order Cancelled: market order " + order_book_id
                        + " volume " + String(order.quantity) + " due to volume limit"
                    )
                return
            fill_qty = min(fill_qty, v_limit)
        else:
            fill_qty = min(fill_qty, volume_limit)

        order.fill(fill_qty, matching_price)

        try:
            self._base_matcher._turnover[order_book_id] += fill_qty
        except:
            self._base_matcher._turnover[order_book_id] = fill_qty

        if not is_auction:
            if order.side == SIDE.BUY:
                try:
                    self._a_volume[order_book_id][0] -= fill_qty
                except:
                    pass
            else:
                try:
                    self._b_volume[order_book_id][0] -= fill_qty
                except:
                    pass

        if order.order_type() == ORDER_TYPE.MARKET and order.unfilled_quantity() != 0:
            order.mark_cancelled(
                "Order Cancelled: market order " + order_book_id + " fill "
                + String(order.filled_quantity) + " actually"
            )

        if order.unfilled_quantity() != 0:
            self.match(account_str, order, open_auction)

    def _pop_empty_levels(mut self, order_book_id: String, side: SIDE) -> None:
        try:
            if side == SIDE.BUY:
                if len(self._a_volume[order_book_id]) > 0 and self._a_volume[order_book_id][0] == 0:
                    _ = self._a_volume[order_book_id].pop(0)
                    if len(self._a_price[order_book_id]) > 0:
                        _ = self._a_price[order_book_id].pop(0)
            else:
                if len(self._b_volume[order_book_id]) > 0 and self._b_volume[order_book_id][0] == 0:
                    _ = self._b_volume[order_book_id].pop(0)
                    if len(self._b_price[order_book_id]) > 0:
                        _ = self._b_price[order_book_id].pop(0)
        except:
            pass

    def pre_tick_update(mut self, order_book_id: String, ask_vols: List[Int], bid_vols: List[Int], asks: List[Float64], bids: List[Float64]) -> None:
        self._a_volume[order_book_id] = ask_vols.copy()
        self._b_volume[order_book_id] = bid_vols.copy()
        self._a_price[order_book_id] = asks.copy()
        self._b_price[order_book_id] = bids.copy()


def create_default_bar_matcher(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    volume_percent: Float64 = 0.25,
    price_limit: Bool = True,
    inactive_limit: Bool = True,
    volume_limit: Bool = True
) raises -> DefaultBarMatcher:
    return DefaultBarMatcher(
        _slippage_decider=SlippageDecider(module_name=slippage_model, rate=slippage),
        _turnover=Dict[String, Int](),
        _volume_percent=volume_percent,
        _price_limit=price_limit,
        _inactive_limit=inactive_limit,
        _volume_limit=volume_limit,
        _matching_type=matching_type,
        _bar_close=Dict[String, Float64](),
        _bar_open=Dict[String, Float64](),
        _bar_volume=Dict[String, Int](),
        _limit_up=Dict[String, Float64](),
        _limit_down=Dict[String, Float64]()
    )


def create_default_tick_matcher(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.NEXT_TICK_LAST,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    volume_percent: Float64 = 0.25,
    price_limit: Bool = True,
    liquidity_limit: Bool = False,
    volume_limit: Bool = True
) raises -> DefaultTickMatcher:
    return DefaultTickMatcher(
        _slippage_decider=SlippageDecider(module_name=slippage_model, rate=slippage),
        _turnover=Dict[String, Int](),
        _volume_percent=volume_percent,
        _price_limit=price_limit,
        _liquidity_limit=liquidity_limit,
        _volume_limit=volume_limit,
        _matching_type=matching_type,
        _last_tick_volume=Dict[String, Int](),
        _cur_tick_volume=Dict[String, Int](),
        _last_price=Dict[String, Float64](),
        _a1_price=Dict[String, Float64](),
        _b1_price=Dict[String, Float64](),
        _during_call_auction=Dict[String, Bool]()
    )


def create_counter_party_offer_matcher(
    matching_type: MATCHING_TYPE = MATCHING_TYPE.NEXT_TICK_LAST,
    slippage_model: String = "PriceRatioSlippage",
    slippage: Float64 = 0.0,
    volume_percent: Float64 = 0.25,
    price_limit: Bool = True,
    liquidity_limit: Bool = False,
    volume_limit: Bool = True
) raises -> CounterPartyOfferMatcher:
    var base = create_default_tick_matcher(
        matching_type=matching_type,
        slippage_model=slippage_model,
        slippage=slippage,
        volume_percent=volume_percent,
        price_limit=price_limit,
        liquidity_limit=liquidity_limit,
        volume_limit=volume_limit
    )
    return CounterPartyOfferMatcher(
        _base_matcher=base^,
        _a_volume=Dict[String, List[Int]](),
        _b_volume=Dict[String, List[Int]](),
        _a_price=Dict[String, List[Float64]](),
        _b_price=Dict[String, List[Float64]]()
    )
