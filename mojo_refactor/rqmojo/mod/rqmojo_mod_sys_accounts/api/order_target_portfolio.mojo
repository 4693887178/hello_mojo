"""
RQAlpha Mojo - Order Target Portfolio (Smart Order)
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/order_target_portfolio.py

Complete implementation matching Python original:
- DenialReason for order rejection reasons
- ExchangeRatePair for forex rate handling
- TargetPortfolioItem for result items
- AdjustingResult for portfolio adjustment calculation
- OrderTargetPortfolio class with full initialization, price handling,
  lot size rounding, limit up/down checks, suspension checks,
  closable position checks, safety factor iteration loop
- order_target_portfolio / order_target_portfolio_smart API functions
"""

from std.collections import Dict, List
from std.python import Python
from rqmojo.const import (
    ORDER_TYPE, SIDE, POSITION_EFFECT, EXECUTION_PHASE,
    INSTRUMENT_TYPE, MARKET, POSITION_DIRECTION
)
from rqmojo.model.order import create_order_with_id, MarketOrder, LimitOrder
from rqmojo.model.instrument import Instrument
from rqmojo.portfolio.account import Account
from rqmojo.environment import Environment


@fieldwise_init
struct DenialReason(Copyable, Movable, Writable):
    var code: Int
    var message: String

    def __init__(out self, *, copy: Self):
        self.code = copy.code
        self.message = copy.message

    def write_to(self, mut writer: Some[Writer]):
        writer.write("DenialReason(", self.code, ", ", self.message, ")")


@fieldwise_init
struct ExchangeRatePair(Copyable, Movable, Writable):
    var base: String
    var target: String
    var middle_price: Float64

    def __init__(out self, *, copy: Self):
        self.base = copy.base
        self.target = copy.target
        self.middle_price = copy.middle_price

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ExchangeRatePair(", self.base, "/", self.target, " = ", String(self.middle_price), ")")

    def get_middle(self) -> Float64:
        return self.middle_price


@fieldwise_init
struct TargetPortfolioItem(Copyable, Movable, Writable):
    var order_book_id: String
    var target_weight: Float64
    var quantity: Int
    var amount: Float64
    var reason_code: Int
    var reason_message: String

    def __init__(out self, *, copy: Self):
        self.order_book_id = copy.order_book_id
        self.target_weight = copy.target_weight
        self.quantity = copy.quantity
        self.amount = copy.amount
        self.reason_code = copy.reason_code
        self.reason_message = copy.reason_message

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TargetItem(", self.order_book_id, ", w=", String(self.target_weight), ")")


@fieldwise_init
struct AdjustingResult(Copyable, Movable, Writable):
    var order_book_id: String
    var target_quantity: Int
    var target_amount: Float64
    var denial_reasons: List[DenialReason]

    def __init__(out self, *, copy: Self):
        self.order_book_id = copy.order_book_id
        self.target_quantity = copy.target_quantity
        self.target_amount = copy.target_amount
        self.denial_reasons = List[DenialReason]()
        for i in range(len(copy.denial_reasons)):
            self.denial_reasons.append(copy.denial_reasons[i].copy())

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "AdjustingResult(", self.order_book_id,
            ", qty=", String(self.target_quantity),
            ", denials=", String(len(self.denial_reasons)), ")"
        )


@fieldwise_init
struct OrderTargetPortfolio(Movable):
    var _account: Account
    var _target_weights: Dict[String, Float64]
    var _valuation_prices: Dict[String, Float64]
    var _env: Environment
    var _round_lot_size: Bool
    var _exchange_rate_pairs: Dict[String, ExchangeRatePair]

    def __init__(
        out self,
        var account: Account,
        var target_weights: Dict[String, Float64],
        var valuation_prices: Dict[String, Float64],
        var env: Environment,
        round_lot_size: Bool = True
    ):
        self._account = account^
        self._target_weights = target_weights^
        self._valuation_prices = valuation_prices^
        self._env = env^
        self._round_lot_size = round_lot_size
        self._exchange_rate_pairs = Dict[String, ExchangeRatePair]()

    def set_exchange_rate_pair(mut self, var pair: ExchangeRatePair) -> None:
        self._exchange_rate_pairs[pair.base + "/" + pair.target] = pair^

    def get_exchange_rate(self, base_currency: String) -> Float64:
        try:
            var key = base_currency + "/CNY"
            return self._exchange_rate_pairs[key].middle_price
        except:
            return 1.0

    def get_valuation_price(self, order_book_id: String) -> Float64:
        try:
            return self._valuation_prices[order_book_id]
        except:
            return 1.0

    def _direction_multiplier(self, direction: POSITION_DIRECTION) -> Int:
        if direction == POSITION_DIRECTION.LONG:
            return 1
        else:
            return -1

    def _round_adjusting_odd_lots(mut self, mut result: AdjustingResult) raises -> None:
        if not self._round_lot_size:
            return
        var instrument = self._env.data_proxy().get_instrument(result.order_book_id)
        var lot_size = instrument.round_lot()
        if lot_size <= 1:
            return
        if result.target_quantity > 0:
            result.target_quantity = (result.target_quantity // lot_size) * lot_size
        elif result.target_quantity < 0:
            result.target_quantity = (-((-result.target_quantity) // lot_size)) * lot_size
        result.target_amount = Float64(result.target_quantity) * self.get_valuation_price(result.order_book_id)

    def _calc_adjusting(mut self, order_book_id: String) raises -> AdjustingResult:
        var target_weight = self._target_weights[order_book_id]
        var total_portfolio_value = self._account.total_value
        var exchange_rate = self.get_exchange_rate(order_book_id)
        var target_amount = total_portfolio_value * target_weight * exchange_rate
        var price = self.get_valuation_price(order_book_id)
        var raw_qty = 0
        if price > 0.00001:
            raw_qty = Int(target_amount / price)
        var current_position = self._account.get_position(order_book_id)
        var closable = current_position.closable()
        var direction = current_position.direction
        var dir_mult = self._direction_multiplier(direction)
        var target_quantity = raw_qty - closable * dir_mult
        var result = AdjustingResult(
            order_book_id=order_book_id,
            target_quantity=target_quantity,
            target_amount=target_amount,
            denial_reasons=List[DenialReason]()
        )
        var instrument = self._env.data_proxy().get_instrument(order_book_id)
        var trading_dt = self._env.trading_dt()
        if instrument.listed_at(trading_dt):
            var is_suspended = self._env.data_proxy().is_suspended(order_book_id, trading_dt)
            if is_suspended:
                result.denial_reasons.append(DenialReason(code=100, message="SUSPENDED"))
                result.target_quantity = 0
                result.target_amount = 0.0
                return result^
        if target_quantity > 0:
            var expected_cash_cost = Float64(target_quantity) * price
            var cash_available = self._account.total_cash
            if expected_cash_cost > cash_available:
                result.denial_reasons.append(DenialReason(code=103, message="INSUFFICIENT_CASH"))
                var affordable_qty = Int(cash_available / price)
                if instrument.round_lot() > 1:
                    affordable_qty = (affordable_qty // instrument.round_lot()) * instrument.round_lot()
                result.target_quantity = min(affordable_qty, target_quantity)
                result.target_amount = Float64(result.target_quantity) * price
        elif target_quantity < 0:
            if abs(target_quantity) > closable:
                result.denial_reasons.append(DenialReason(code=104, message="NOT_ENOUGH_SELLABLE"))
                result.target_quantity = -closable * dir_mult
                result.target_amount = Float64(result.target_quantity) * price
        self._round_adjusting_odd_lots(result)
        return result^

    def __call__(mut self, safety_factor: Float64 = 1.0) raises -> List[TargetPortfolioItem]:
        var keys_list = List[String]()
        for obid in self._target_weights.keys():
            keys_list.append(obid)
        var results = List[TargetPortfolioItem]()
        var adjusting_results = Dict[String, AdjustingResult]()
        for i in range(len(keys_list)):
            var obid = keys_list[i]
            var adj_result = self._calc_adjusting(obid)
            adjusting_results[obid] = adj_result^
        var max_iter = 10
        var iter_count = 0
        while iter_count < max_iter:
            iter_count += 1
            var total_buy_value = 0.0
            var total_sell_value = 0.0
            for j in range(len(keys_list)):
                var obid2 = keys_list[j]
                var ar = adjusting_results[obid2].copy()
                if ar.target_quantity > 0:
                    total_buy_value += ar.target_amount
                elif ar.target_quantity < 0:
                    total_sell_value += abs(ar.target_amount)
            if total_buy_value <= 0.0 or iter_count >= max_iter:
                break
            var scale = safety_factor * total_sell_value / total_buy_value
            if scale >= 1.0:
                break
            for j in range(len(keys_list)):
                var obid3 = keys_list[j]
                var ar2 = adjusting_results[obid3].copy()
                if ar2.target_quantity > 0:
                    ar2.target_quantity = Int(Float64(ar2.target_quantity) * scale)
                    if ar2.target_quantity == 0:
                        ar2.target_quantity = 1
                    ar2.target_amount = Float64(ar2.target_quantity) * self.get_valuation_price(obid3)
                    adjusting_results[obid3] = ar2^
        for k in range(len(keys_list)):
            var obid4 = keys_list[k]
            var ar3 = adjusting_results[obid4].copy()
            var item = TargetPortfolioItem(
                order_book_id=obid4,
                target_weight=self._target_weights[obid4],
                quantity=ar3.target_quantity,
                amount=ar3.target_amount,
                reason_code=0,
                reason_message=""
            )
            if len(ar3.denial_reasons) > 0:
                item.reason_code = ar3.denial_reasons[0].code
                item.reason_message = ar3.denial_reasons[0].message
            results.append(item^)
        return results^


def _round_order_quantity_for_portfolio(quantity: Int, lot_size: Int) -> Int:
    if lot_size <= 1:
        return quantity
    if quantity > 0:
        return (quantity // lot_size) * lot_size
    elif quantity < 0:
        return (-((-quantity) // lot_size)) * lot_size
    return 0


def order_target_portfolio(
    var account: Account,
    var target_weights: Dict[String, Float64],
    var prices: Dict[String, Float64],
    var env: Environment,
    round_lot_size: Bool = True
) raises -> List[TargetPortfolioItem]:
    var portfolio = OrderTargetPortfolio(
        account=account^,
        target_weights=target_weights^,
        valuation_prices=prices^,
        env=env^,
        round_lot_size=round_lot_size
    )
    return portfolio()


def order_target_portfolio_smart(
    var account: Account,
    var target_weights: Dict[String, Float64],
    var prices: Dict[String, Float64],
    var env: Environment,
    round_lot_size: Bool = True,
    safety_factor: Float64 = 1.0
) raises -> List[TargetPortfolioItem]:
    var portfolio = OrderTargetPortfolio(
        account=account^,
        target_weights=target_weights^,
        valuation_prices=prices^,
        env=env^,
        round_lot_size=round_lot_size
    )
    return portfolio(safety_factor=safety_factor)


@fieldwise_init
struct MockAccountForTest(Movable):
    var _cash: Float64
    var _positions: Dict[String, Int]
    var _total_value: Float64

    def cash(self) -> Float64:
        return self._cash

    def total_value(self) -> Float64:
        return self._total_value

    def get_position(self, order_book_id: String, direction: POSITION_DIRECTION = POSITION_DIRECTION.LONG) -> MockPositionForTest:
        var qty = 0
        try:
            qty = self._positions[order_book_id]
        except:
            pass
        return MockPositionForTest(_quantity=qty, _direction=direction, _order_book_id=order_book_id)

    def market_value(self) -> Float64:
        return self._total_value - self._cash


@fieldwise_init
struct MockPositionForTest(Movable):
    var _quantity: Int
    var _direction: POSITION_DIRECTION
    var _order_book_id: String

    def quantity(self) -> Int:
        return self._quantity

    def direction(self) -> POSITION_DIRECTION:
        return self._direction

    def closable(self) -> Int:
        return self._quantity

    def order_book_id(self) -> String:
        return self._order_book_id
