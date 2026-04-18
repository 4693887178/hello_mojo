"""
RQAlpha Mojo - Slippage Models
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/slippage.py
"""

from rqmojo.model.order import Order
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE


struct PriceRatioSlippage(Movable):
    var rate: Float64

    def __init__(out self, rate: Float64 = 0.0) raises:
        if rate < 0.0 or rate >= 1.0:
            raise Error("invalid slippage rate value: value range is [0, 1)")
        self.rate = rate

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("PriceRatioSlippage cannot handle exercise order")
        var temp_price = price + price * self.rate * (1.0 if order.side == SIDE.BUY else -1.0)
        return temp_price


struct TickSizeSlippage(Movable):
    var rate: Float64

    def __init__(out self, rate: Float64 = 0.0) raises:
        if rate < 0.0:
            raise Error("invalid slippage rate value: value range is greater than 0")
        self.rate = rate

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("TickSizeSlippage cannot handle exercise order")
        var tick_size = 0.01
        var result = price + tick_size * self.rate * (1.0 if order.side == SIDE.BUY else -1.0)
        if result <= 0.0:
            raise Error("invalid slippage rate value " + String(self.rate) + " which cause price <= 0")
        return result


struct LimitPriceSlippage(Movable):
    var rate: Float64

    def __init__(out self, rate: Float64 = 0.0):
        self.rate = rate

    def get_trade_price(self, order: Order, price: Float64) -> Float64:
        if order.order_type() == ORDER_TYPE.LIMIT:
            return order.price
        else:
            return price


struct SlippageDecider(Movable):
    var _slippage_model_name: String
    var _rate: Float64
    var _use_price_ratio: Bool
    var _use_tick_size: Bool
    var _use_limit_price: Bool

    def __init__(out self, module_name: String = "PriceRatioSlippage", rate: Float64 = 0.0):
        self._slippage_model_name = module_name
        self._rate = rate
        self._use_price_ratio = (module_name == "PriceRatioSlippage")
        self._use_tick_size = (module_name == "TickSizeSlippage")
        self._use_limit_price = (module_name == "LimitPriceSlippage")

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if self._use_price_ratio:
            var decider = PriceRatioSlippage(rate=self._rate)
            return decider.get_trade_price(order, price)
        elif self._use_tick_size:
            var decider2 = TickSizeSlippage(rate=self._rate)
            return decider2.get_trade_price(order, price)
        elif self._use_limit_price:
            var decider3 = LimitPriceSlippage(rate=self._rate)
            return decider3.get_trade_price(order, price)
        else:
            raise Error("Missing SlippageModel " + self._slippage_model_name)


def create_slippage_decider(module_name: String = "PriceRatioSlippage", rate: Float64 = 0.0) -> SlippageDecider:
    return SlippageDecider(module_name=module_name, rate=rate)


def create_price_ratio_slippage(rate: Float64 = 0.0) raises -> PriceRatioSlippage:
    return PriceRatioSlippage(rate=rate)


def create_tick_size_slippage(rate: Float64 = 0.0) raises -> TickSizeSlippage:
    return TickSizeSlippage(rate=rate)


def create_limit_price_slippage() -> LimitPriceSlippage:
    return LimitPriceSlippage(rate=0.0)
