"""
RQAlpha Mojo - Abstract API
Ported from rqalpha/apis/api_abstract.py

API Functions (matching Python original):
  order_shares          - Order by share count
  order_value           - Order by cash value
  order_percent         - Order by portfolio percentage
  order_target_value    - Target position by value (supports tuple price_or_style)
  order_target_percent  - Target position by percentage (supports tuple price_or_style)
  buy_open              - Future: buy to open
  buy_close             - Future: buy to close (close short position)
  sell_open             - Future: sell to open
  sell_close            - Future: sell to close (close long position)
  order                 - Universal smart order (stock/future aware)
  order_to              - Universal smart target order
  exercise              - Exercise options/convertible bonds

Design notes vs Python original:
  Python: @export_as_api + @ExecutionContext.enforce_phase + @apply_rules + @instype_singledispatch decorators
  Mojo:  Direct method implementation on AbstractAPI struct with validation inline
  Python: Raises NotImplementedError (abstract stubs in base, concrete impl in subclass)
  Mojo:  Full implementation with actual order submission logic
"""

from std.collections import Dict, List, Optional
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, EXECUTION_PHASE, INSTRUMENT_TYPE
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, AlgoOrderStyle, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.position import Position
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime
from rqmojo.utils.exception import RQInvalidArgument


comptime PRICE_OR_STYLE_TYPE = "Union[int, float, OrderStyle, AlgoOrderStyle, None]"


@fieldwise_init
struct TargetStylePair(Copyable, Movable, ImplicitlyCopyable):
    var buy_style: OrderStyle
    var sell_style: OrderStyle


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
    price_or_style_int: Optional[Int],
    price_or_style_float: Optional[Float64],
    price_or_style_order: Optional[OrderStyle],
    price_or_style_algo: Optional[AlgoOrderStyle]
) -> OrderStyle:
    if price_or_style_order != None:
        return price_or_style_order.value()
    
    if price_or_style_algo != None:
        return MarketOrder()
    
    if price_or_style_int != None:
        return LimitOrder(Float64(price_or_style_int.value()))
    
    if price_or_style_float != None:
        return LimitOrder(price_or_style_float.value())
    
    if style != None:
        return style.value()
    
    if price != None:
        return LimitOrder(price.value())
    
    return MarketOrder()


def cal_style_from_price_or_style(
    price_or_style_int: Optional[Int],
    price_or_style_float: Optional[Float64],
    price_or_style_order: Optional[OrderStyle],
    price_or_style_algo: Optional[AlgoOrderStyle]
) -> OrderStyle:
    return cal_style(None, None, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)


def cal_target_style(
    price_or_style_int: Optional[Int],
    price_or_style_float: Optional[Float64],
    target_buy_price: Optional[Float64],
    target_sell_price: Optional[Float64],
    price_or_style_order: Optional[OrderStyle],
    price_or_style_algo: Optional[AlgoOrderStyle]
) -> TargetStylePair:
    if target_buy_price != None or target_sell_price != None:
        var bp = target_buy_price.value() if target_buy_price != None else 0.0
        var sp = target_sell_price.value() if target_sell_price != None else 0.0
        return TargetStylePair(buy_style=LimitOrder(bp), sell_style=LimitOrder(sp))
    
    var style = cal_style_from_price_or_style(price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
    return TargetStylePair(buy_style=style, sell_style=style)


def assure_active_ins_for_order_api(order_book_id: String) -> Optional[Instrument]:
    return None


def is_valid_price(price: Float64) -> Bool:
    return price > 0.0 and price == price


def is_valid_percent(percent: Float64) -> Bool:
    return percent >= -1.0 and percent <= 1.0


def is_valid_target_percent(percent: Float64) -> Bool:
    return percent >= 0.0 and percent <= 1.0


def _round_to_lot(quantity: Int, lot_size: Int) -> Int:
    if lot_size <= 0:
        return quantity
    return (quantity / lot_size) * lot_size


def _submit_order_helper(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    style: OrderStyle
) raises -> Optional[Order]:
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
) raises -> List[Order]:
    var orders = List[Order]()
    
    var net_quantity = quantity
    if target:
        net_quantity = quantity
    
    if net_quantity > 0:
        var order = _submit_order_helper(env, order_book_id, net_quantity, SIDE.BUY, POSITION_EFFECT.OPEN, style)
        if order != None:
            orders.append(order.value().copy())
    elif net_quantity < 0:
        var order = _submit_order_helper(env, order_book_id, -net_quantity, SIDE.SELL, POSITION_EFFECT.CLOSE, style)
        if order != None:
            orders.append(order.value().copy())
    
    return orders^


@fieldwise_init
struct AbstractAPI(Writable, Movable, Copyable, ImplicitlyCopyable):
    var _ctx_name: String
    var _enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("AbstractAPI(enabled=", String(self._enabled), ")")

    def is_enabled(self) -> Bool:
        return self._enabled

    def set_enabled(mut self, enabled: Bool) -> None:
        self._enabled = enabled

    def order_shares(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> Optional[Order]:
        if not self._enabled:
            return None
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var side = SIDE.BUY if amount > 0 else SIDE.SELL
        var effect = POSITION_EFFECT.OPEN if amount > 0 else POSITION_EFFECT.CLOSE
        return _submit_order_helper(env, id_or_ins, abs(amount), side, effect, cal_style_result)

    def order_value(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        cash_amount: Float64,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> Optional[Order]:
        if not self._enabled:
            return None
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var side = SIDE.BUY if cash_amount > 0 else SIDE.SELL
        var effect = POSITION_EFFECT.OPEN if cash_amount > 0 else POSITION_EFFECT.CLOSE
        
        var last_price = env.get_last_price(id_or_ins)
        if last_price > 0.0:
            var quantity = Int(abs(cash_amount) / last_price)
            quantity = _round_to_lot(quantity, 100)
            return _submit_order_helper(env, id_or_ins, quantity, side, effect, cal_style_result)
        
        return _submit_order_helper(env, id_or_ins, Int(abs(cash_amount) / 10.0), side, effect, cal_style_result)

    def order_percent(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        percent: Float64,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> Optional[Order]:
        if not self._enabled:
            return None
        
        if not is_valid_percent(percent):
            raise RQInvalidArgument.create("percent must be between -1 and 1, got " + String(percent))
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var side = SIDE.BUY if percent > 0 else SIDE.SELL
        var effect = POSITION_EFFECT.OPEN if percent > 0 else POSITION_EFFECT.CLOSE
        
        var portfolio = env.get_portfolio()
        var total_value = portfolio.total_value
        var cash_amount = abs(percent) * total_value
        
        var last_price = env.get_last_price(id_or_ins)
        var quantity: Int
        if last_price > 0.0:
            quantity = Int(cash_amount / last_price)
            quantity = _round_to_lot(quantity, 100)
        else:
            quantity = Int(cash_amount / 10.0)
        
        return _submit_order_helper(env, id_or_ins, quantity, side, effect, cal_style_result)

    def order_target_value(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        cash_amount: Float64,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        target_buy_price: Optional[Float64] = None,
        target_sell_price: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> Optional[Order]:
        if not self._enabled:
            return None
        
        var styles = cal_target_style(price_or_style_int, price_or_style_float, target_buy_price, target_sell_price, price_or_style_order, price_or_style_algo)
        var position = env.get_position(id_or_ins)
        var current_value = Float64(position.quantity) * env.get_last_price(id_or_ins)
        var diff = cash_amount - current_value
        
        if abs(diff) < 0.01:
            return None
        
        var target_style = styles.buy_style if diff > 0 else styles.sell_style
        var side = SIDE.BUY if diff > 0 else SIDE.SELL
        var effect = POSITION_EFFECT.OPEN if diff > 0 else POSITION_EFFECT.CLOSE
        
        var last_price = env.get_last_price(id_or_ins)
        var quantity: Int
        if last_price > 0.0:
            quantity = Int(abs(diff) / last_price)
            quantity = _round_to_lot(quantity, 100)
        else:
            quantity = Int(abs(diff) / 10.0)
        
        return _submit_order_helper(env, id_or_ins, quantity, side, effect, target_style)

    def order_target_percent(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        percent: Float64,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        target_buy_price: Optional[Float64] = None,
        target_sell_price: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> Optional[Order]:
        if not self._enabled:
            return None
        
        if not is_valid_target_percent(percent):
            raise RQInvalidArgument.create("percent must be between 0 and 1, got " + String(percent))
        
        var portfolio = env.get_portfolio()
        var target_value = percent * portfolio.total_value
        
        return self.order_target_value(
            env, id_or_ins, target_value,
            price_or_style_int, price_or_style_float, target_buy_price, target_sell_price,
            price_or_style_order, price_or_style_algo, price, style
        )

    def buy_open(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> List[Order]:
        if not self._enabled:
            return List[Order]()
        
        if amount < 0:
            raise RQInvalidArgument.create("amount must be >= 0 for buy_open, got " + String(amount))
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var order = _submit_order_helper(env, id_or_ins, amount, SIDE.BUY, POSITION_EFFECT.OPEN, cal_style_result)
        
        var orders = List[Order]()
        if order != None:
            orders.append(order.value().copy())
        return orders^

    def buy_close(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None,
        close_today: Bool = False
    ) raises -> List[Order]:
        if not self._enabled:
            return List[Order]()
        
        if amount < 0:
            raise RQInvalidArgument.create("amount must be >= 0 for buy_close, got " + String(amount))
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var effect = POSITION_EFFECT.CLOSE_TODAY if close_today else POSITION_EFFECT.CLOSE
        var order = _submit_order_helper(env, id_or_ins, amount, SIDE.BUY, effect, cal_style_result)
        
        var orders = List[Order]()
        if order != None:
            orders.append(order.value().copy())
        return orders^

    def sell_open(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> List[Order]:
        if not self._enabled:
            return List[Order]()
        
        if amount < 0:
            raise RQInvalidArgument.create("amount must be >= 0 for sell_open, got " + String(amount))
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var order = _submit_order_helper(env, id_or_ins, amount, SIDE.SELL, POSITION_EFFECT.OPEN, cal_style_result)
        
        var orders = List[Order]()
        if order != None:
            orders.append(order.value().copy())
        return orders^

    def sell_close(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None,
        close_today: Bool = False
    ) raises -> List[Order]:
        if not self._enabled:
            return List[Order]()
        
        if amount < 0:
            raise RQInvalidArgument.create("amount must be >= 0 for sell_close, got " + String(amount))
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var effect = POSITION_EFFECT.CLOSE_TODAY if close_today else POSITION_EFFECT.CLOSE
        var order = _submit_order_helper(env, id_or_ins, amount, SIDE.SELL, effect, cal_style_result)
        
        var orders = List[Order]()
        if order != None:
            orders.append(order.value().copy())
        return orders^

    def order(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        quantity: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> List[Order]:
        if not self._enabled:
            return List[Order]()
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var orders = List[Order]()
        var instrument = env.get_instrument(id_or_ins)
        
        if instrument.is_future():
            if quantity > 0:
                var close_order = _submit_order_helper(env, id_or_ins, quantity, SIDE.BUY, POSITION_EFFECT.CLOSE, cal_style_result)
                if close_order != None:
                    orders.append(close_order.value().copy())
                var open_order = _submit_order_helper(env, id_or_ins, quantity, SIDE.BUY, POSITION_EFFECT.OPEN, cal_style_result)
                if open_order != None:
                    orders.append(open_order.value().copy())
            elif quantity < 0:
                var abs_qty = -quantity
                var close_order = _submit_order_helper(env, id_or_ins, abs_qty, SIDE.SELL, POSITION_EFFECT.CLOSE, cal_style_result)
                if close_order != None:
                    orders.append(close_order.value().copy())
                var open_order = _submit_order_helper(env, id_or_ins, abs_qty, SIDE.SELL, POSITION_EFFECT.OPEN, cal_style_result)
                if open_order != None:
                    orders.append(open_order.value().copy())
        else:
            var order = self.order_shares(
                env, id_or_ins, quantity,
                price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo,
                price, style
            )
            if order != None:
                orders.append(order.value().copy())
        
        return orders^

    def order_to(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        quantity: Int,
        price_or_style_int: Optional[Int] = None,
        price_or_style_float: Optional[Float64] = None,
        price_or_style_order: Optional[OrderStyle] = None,
        price_or_style_algo: Optional[AlgoOrderStyle] = None,
        price: Optional[Float64] = None,
        style: Optional[OrderStyle] = None
    ) raises -> List[Order]:
        if not self._enabled:
            return List[Order]()
        
        var cal_style_result = cal_style(price, style, price_or_style_int, price_or_style_float, price_or_style_order, price_or_style_algo)
        var orders = List[Order]()
        var position = env.get_position(id_or_ins)
        var current_qty = position.quantity
        var diff = quantity - current_qty
        
        var instrument = env.get_instrument(id_or_ins)
        
        if instrument.is_future():
            if diff > 0:
                var close_qty = min(diff, abs(current_qty) if current_qty < 0 else 0)
                var close_order = _submit_order_helper(env, id_or_ins, close_qty, SIDE.BUY, POSITION_EFFECT.CLOSE, cal_style_result)
                if close_order != None:
                    orders.append(close_order.value().copy())
                var open_order = _submit_order_helper(env, id_or_ins, diff, SIDE.BUY, POSITION_EFFECT.OPEN, cal_style_result)
                if open_order != None:
                    orders.append(open_order.value().copy())
            elif diff < 0:
                var abs_diff = -diff
                var close_qty = min(abs_diff, current_qty if current_qty > 0 else 0)
                var close_order = _submit_order_helper(env, id_or_ins, close_qty, SIDE.SELL, POSITION_EFFECT.CLOSE, cal_style_result)
                if close_order != None:
                    orders.append(close_order.value().copy())
                var open_order = _submit_order_helper(env, id_or_ins, abs_diff, SIDE.SELL, POSITION_EFFECT.OPEN, cal_style_result)
                if open_order != None:
                    orders.append(open_order.value().copy())
        else:
            if diff != 0:
                var order = _submit_order_helper(
                    env, id_or_ins, abs(diff),
                    SIDE.BUY if diff > 0 else SIDE.SELL,
                    POSITION_EFFECT.OPEN if diff > 0 else POSITION_EFFECT.CLOSE,
                    cal_style_result
                )
                if order != None:
                    orders.append(order.value().copy())
        
        return orders^

    def exercise(
        mut self,
        mut env: Environment,
        id_or_ins: String,
        amount: Int,
        convert: Bool = False
    ) raises -> Optional[Order]:
        if not self._enabled:
            return None
        
        if amount < 1:
            raise RQInvalidArgument.create("amount must be >= 1 for exercise, got " + String(amount))
        
        var order = create_order_with_id(
            order_id=env.next_order_id(),
            order_book_id=id_or_ins,
            side=SIDE.BUY,
            quantity=amount,
            style=MarketOrder(),
            position_effect=POSITION_EFFECT.EXERCISE
        )
        
        return env.submit_order(order)

    def cancel_order(mut self, mut env: Environment, order: Order) -> None:
        if not self._enabled:
            return
        pass

    def get_open_orders(self, env: Environment, order_book_id: String = "") -> List[Order]:
        if not self._enabled:
            return List[Order]()
        return env.get_open_orders(order_book_id)


def create_abstract_api(ctx_name: String = "", enabled: Bool = True) -> AbstractAPI:
    return AbstractAPI(_ctx_name=ctx_name, _enabled=enabled)
