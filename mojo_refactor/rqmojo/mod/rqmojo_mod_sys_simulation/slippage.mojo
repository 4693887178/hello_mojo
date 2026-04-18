"""
RQAlpha Mojo - Slippage Models
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/slippage.py
"""

from rqmojo.model.order import Order
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE


trait BaseSlippage:
    var rate: Float64

    def get_trade_price(self, order: Order, price: Float64) -> Float64:
        ...


struct PriceRatioSlippage(BaseSlippage, Movable):
    def __init__(out self, rate: Float64 = 0.0):
        if rate < 0.0 or rate >= 1.0:
            raise Error("invalid slippage rate value: value range is [0, 1)")
        self.rate = rate

    def get_trade_price(self, order: Order, price: Float64) -> Float64:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("PriceRatioSlippage cannot handle exercise order")
        var temp_price = price + price * self.rate * (1.0 if order.side == SIDE.BUY else -1.0)

        from rqmojo.environment import Environment
        from rqmojo.apis.api_abstract import is_valid_price
        var env = Environment.get_instance()
        var limit_up = env.price_board.get_limit_up(order.order_book_id)
        var limit_down = env.price_board.get_limit_down(order.order_book_id)
        if is_valid_price(limit_up):
            temp_price = min(temp_price, limit_up)
        if is_valid_price(limit_down):
            temp_price = max(temp_price, limit_down)
        return temp_price


struct TickSizeSlippage(BaseSlippage, Movable):
    def __init__(out self, rate: Float64 = 0.0):
        if rate < 0.0:
            raise Error("invalid slippage rate value: value range is greater than 0")
        self.rate = rate

    def get_trade_price(self, order: Order, price: Float64) -> Float64:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("TickSizeSlippage cannot handle exercise order")

        from rqmojo.environment import Environment
        var env = Environment.get_instance()
        var instrument = env.data_proxy.get_instrument(order.order_book_id)
        var tick_size = instrument.tick_size()

        var result = price + tick_size * self.rate * (1.0 if order.side == SIDE.BUY else -1.0)

        if result <= 0.0:
            raise Error("invalid slippage rate value " + String(self.rate) + " which cause price <= 0")

        return result


struct LimitPriceSlippage(BaseSlippage, Movable):
    def __init__(out self, rate: Float64 = 0.0):
        self.rate = rate

    def get_trade_price(self, order: Order, price: Float64) -> Float64:
        if order.order_type() == ORDER_TYPE.LIMIT:
            return order.price
        else:
            return price


@fieldwise_init
struct SlippageDecider(Movable):
    var decider: BaseSlippage

    def __init__(out self, module_name: String = "PriceRatioSlippage", rate: Float64 = 0.0):
        if module_name == "PriceRatioSlippage":
            self.decider = PriceRatioSlippage(rate=rate)
        elif module_name == "TickSizeSlippage":
            self.decider = TickSizeSlippage(rate=rate)
        elif module_name == "LimitPriceSlippage":
            self.decider = LimitPriceSlippage(rate=rate)
        else:
            raise Error("Missing SlippageModel " + module_name)

    def get_trade_price(self, order: Order, price: Float64) -> Float64:
        return self.decider.get_trade_price(order, price)


def create_slippage_decider(module_name: String = "PriceRatioSlippage", rate: Float64 = 0.0) -> SlippageDecider:
    return SlippageDecider(module_name=module_name, rate=rate)


def create_price_ratio_slippage(rate: Float64 = 0.0) -> PriceRatioSlippage:
    return PriceRatioSlippage(rate=rate)


def create_tick_size_slippage(rate: Float64 = 0.0) -> TickSizeSlippage:
    return TickSizeSlippage(rate=rate)


def create_limit_price_slippage() -> LimitPriceSlippage:
    return LimitPriceSlippage(rate=0.0)
