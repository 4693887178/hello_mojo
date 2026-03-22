"""
RQAlpha Mojo - Abstract API
Ported from rqalpha/apis/api_abstract.py
"""

from std.collections import Dict, List, Optional
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, EXECUTION_PHASE, INSTRUMENT_TYPE, SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.environment import Environment
from rqmojo.portfolio.position import Position
from rqmojo.portfolio.account import Account
from rqmojo.utils.datetime_func import DateTime
from rqmojo.utils.exception import RQInvalidArgument


comptime PRICE_OR_STYLE_TYPE = "Union[int, float, OrderStyle, None]"


@fieldwise_init
struct OrderParams(Movable, Copyable, ImplicitlyCopyable):
    var order_book_id: String
    var quantity: Int
    var side: SIDE
    var position_effect: POSITION_EFFECT
    var style: OrderStyle
    var price: Float64


def cal_style(
    price: Optional[Float64],
    style: Optional[OrderStyle],
    price_or_style: Optional[OrderStyle]
) -> OrderStyle:
    if price_or_style != None:
        return price_or_style.value()
    
    if style != None:
        return style.value()
    
    if price != None:
        return LimitOrder(price.value())
    
    return MarketOrder()


def assure_active_ins_for_order_api(order_book_id: String) -> Optional[Instrument]:
    return None


def is_valid_price(price: Float64) -> Bool:
    return price > 0.0 and price == price


def _submit_order_helper(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    style: OrderStyle
) -> Optional[Order]:
    if amount == 0:
        return None
    
    var order = create_order_with_id(
        order_id=env.next_order_id(),
        order_book_id=order_book_id,
        side=side,
        quantity=amount,
        style=style,
        position_effect=position_effect
    )
    
    return env.submit_order(order)


def _order_helper(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle,
    target: Bool
) -> List[Order]:
    var orders = List[Order]()
    
    var net_quantity = quantity
    if target:
        net_quantity = quantity
    
    if net_quantity > 0:
        var order = _submit_order_helper(env, order_book_id, net_quantity, SIDE_BUY, POSITION_EFFECT_OPEN, style)
        if order != None:
            orders.append(order.value())
    elif net_quantity < 0:
        var order = _submit_order_helper(env, order_book_id, -net_quantity, SIDE_SELL, POSITION_EFFECT_CLOSE, style)
        if order != None:
            orders.append(order.value())
    
    return orders^


@fieldwise_init
struct AbstractAPI(Writable, Movable, Copyable, ImplicitlyCopyable):
    var _ctx_name: String
    var _enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("AbstractAPI(enabled=", String(self._enabled), ")")

    def order_shares(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        price_or_style: Optional[OrderStyle] = None
    ) -> Optional[Order]:
        if not self._enabled:
            return None
        var style = cal_style(None, None, price_or_style)
        var side = SIDE_BUY if amount > 0 else SIDE_SELL
        var effect = POSITION_EFFECT_OPEN if amount > 0 else POSITION_EFFECT_CLOSE
        return _submit_order_helper(env, id_or_ins, abs(amount), side, effect, style)

    def order_value(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        cash_amount: Float64,
        price_or_style: Optional[OrderStyle] = None
    ) -> Optional[Order]:
        if not self._enabled:
            return None
        var style = cal_style(None, None, price_or_style)
        var side = SIDE_BUY if cash_amount > 0 else SIDE_SELL
        var effect = POSITION_EFFECT_OPEN if cash_amount > 0 else POSITION_EFFECT_CLOSE
        var quantity = Int(abs(cash_amount) / 10.0)
        return _submit_order_helper(env, id_or_ins, quantity, side, effect, style)

    def order_percent(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        percent: Float64,
        price_or_style: Optional[OrderStyle] = None
    ) -> Optional[Order]:
        if not self._enabled:
            return None
        var style = cal_style(None, None, price_or_style)
        var side = SIDE_BUY if percent > 0 else SIDE_SELL
        var effect = POSITION_EFFECT_OPEN if percent > 0 else POSITION_EFFECT_CLOSE
        var quantity = Int(abs(percent) * 1000.0)
        return _submit_order_helper(env, id_or_ins, quantity, side, effect, style)

    def cancel_order(mut self, mut env: Environment, order: Order) -> None:
        pass

    def get_open_orders(self, env: Environment, order_book_id: String = "") -> List[Order]:
        var orders = List[Order]()
        return orders^


def create_abstract_api(ctx_name: String = "", enabled: Bool = True) -> AbstractAPI:
    return AbstractAPI(_ctx_name=ctx_name, _enabled=enabled)
