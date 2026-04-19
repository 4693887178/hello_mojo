"""
RQAlpha Mojo - Slippage Models
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/slippage.py

Key differences from Python:
  - Python uses Environment.get_instance() singleton for price_board/data_proxy access.
  - Mojo passes DataProxy explicitly as a constructor parameter (no global singleton).
  - Python uses dynamic import for SlippageDecider; Mojo uses string-based dispatch.
  - BaseSlippage abstract class -> SlippageModel trait.
"""

from rqmojo.model.order import Order
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE
from rqmojo.data.data_proxy import DataProxy, create_data_proxy


def is_valid_price(price: Float64) -> Bool:
    return price > 0.0 and price == price


trait SlippageModel:
    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        ...


struct PriceRatioSlippage(SlippageModel, Movable):
    var rate: Float64
    var _data_proxy: DataProxy

    def __init__(out self, rate: Float64 = 0.0, var data_proxy: DataProxy = create_data_proxy()) raises:
        if rate < 0.0 or rate >= 1.0:
            raise Error("invalid slippage rate value: value range is [0, 1)")
        self.rate = rate
        self._data_proxy = data_proxy^

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("PriceRatioSlippage cannot handle exercise order")
        var temp_price = price + price * self.rate * (1.0 if order.side == SIDE.BUY else -1.0)
        var limit_up = self._data_proxy.get_limit_up(order.order_book_id)
        var limit_down = self._data_proxy.get_limit_down(order.order_book_id)
        if is_valid_price(limit_up):
            if temp_price > limit_up:
                temp_price = limit_up
        if is_valid_price(limit_down):
            if temp_price < limit_down:
                temp_price = limit_down
        return temp_price


struct TickSizeSlippage(SlippageModel, Movable):
    var rate: Float64
    var _data_proxy: DataProxy

    def __init__(out self, rate: Float64 = 0.0, var data_proxy: DataProxy = create_data_proxy()) raises:
        if rate < 0.0:
            raise Error("invalid slippage rate value: value range is greater than 0")
        self.rate = rate
        self._data_proxy = data_proxy^

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if order.position_effect == POSITION_EFFECT.EXERCISE:
            raise Error("TickSizeSlippage cannot handle exercise order")
        var instrument = self._data_proxy.get_instrument(order.order_book_id)
        var tick_size = instrument.tick_size()
        var result = price + tick_size * self.rate * (1.0 if order.side == SIDE.BUY else -1.0)
        if result <= 0.0:
            raise Error("invalid slippage rate value " + String(self.rate) + " which cause price <= 0")
        return result


struct LimitPriceSlippage(SlippageModel, Movable):
    def __init__(out self):
        pass

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if order.order_type() == ORDER_TYPE.LIMIT:
            return order.price
        else:
            return price


struct SlippageDecider(Movable):
    var _model_name: String
    var _rate: Float64
    var _data_proxy: DataProxy

    def __init__(out self, module_name: String = "PriceRatioSlippage", rate: Float64 = 0.0, var data_proxy: DataProxy = create_data_proxy()) raises:
        if module_name != "PriceRatioSlippage" and module_name != "TickSizeSlippage" and module_name != "LimitPriceSlippage":
            raise Error("Missing SlippageModel " + module_name)
        self._model_name = module_name
        self._rate = rate
        self._data_proxy = data_proxy^

    def get_trade_price(self, order: Order, price: Float64) raises -> Float64:
        if self._model_name == "PriceRatioSlippage":
            if order.position_effect == POSITION_EFFECT.EXERCISE:
                raise Error("PriceRatioSlippage cannot handle exercise order")
            var temp_price = price + price * self._rate * (1.0 if order.side == SIDE.BUY else -1.0)
            var limit_up = self._data_proxy.get_limit_up(order.order_book_id)
            var limit_down = self._data_proxy.get_limit_down(order.order_book_id)
            if is_valid_price(limit_up):
                if temp_price > limit_up:
                    temp_price = limit_up
            if is_valid_price(limit_down):
                if temp_price < limit_down:
                    temp_price = limit_down
            return temp_price
        elif self._model_name == "TickSizeSlippage":
            if order.position_effect == POSITION_EFFECT.EXERCISE:
                raise Error("TickSizeSlippage cannot handle exercise order")
            var instrument = self._data_proxy.get_instrument(order.order_book_id)
            var tick_size = instrument.tick_size()
            var result = price + tick_size * self._rate * (1.0 if order.side == SIDE.BUY else -1.0)
            if result <= 0.0:
                raise Error("invalid slippage rate value " + String(self._rate) + " which cause price <= 0")
            return result
        elif self._model_name == "LimitPriceSlippage":
            if order.order_type() == ORDER_TYPE.LIMIT:
                return order.price()
            else:
                return price
        else:
            raise Error("Missing SlippageModel " + self._model_name)


def create_slippage_decider(module_name: String = "PriceRatioSlippage", rate: Float64 = 0.0, var data_proxy: DataProxy = create_data_proxy()) raises -> SlippageDecider:
    return SlippageDecider(module_name=module_name, rate=rate, data_proxy=data_proxy^)


def create_price_ratio_slippage(rate: Float64 = 0.0, var data_proxy: DataProxy = create_data_proxy()) raises -> PriceRatioSlippage:
    return PriceRatioSlippage(rate=rate, data_proxy=data_proxy^)


def create_tick_size_slippage(rate: Float64 = 0.0, var data_proxy: DataProxy = create_data_proxy()) raises -> TickSizeSlippage:
    return TickSizeSlippage(rate=rate, data_proxy=data_proxy^)


def create_limit_price_slippage() -> LimitPriceSlippage:
    return LimitPriceSlippage()
