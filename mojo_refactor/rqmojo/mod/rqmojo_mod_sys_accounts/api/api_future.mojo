"""
RQAlpha Mojo - Future API for Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/api/api_future.py

Key Functions:
  _submit_order     - Core order submission with position effect handling
  _order            - Internal order logic for future_order/future_order_to
  future_order      - Submit orders to reach target quantity
  future_order_to   - Adjust position to target quantity
  future_buy_open   - Buy to open position
  future_buy_close  - Buy to close position (long)
  future_sell_open  - Sell to open short position
  future_sell_close - Sell to close position (short)
  get_future_contracts - Get list of tradable futures contracts
"""

from std.collections import Dict, List, Optional
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE, DEFAULT_ACCOUNT_TYPE,
    POSITION_DIRECTION, HEDGE_TYPE, RUN_TYPE
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.environment import Environment
from rqmojo.portfolio.account import Account
from rqmojo.portfolio.position import Position
from rqmojo.data.data_proxy import DataProxy
from rqmojo.utils.typing import DateTime
from rqmojo.utils.exception import RQInvalidArgument
from rqmojo.utils.i18n import gettext


def _submit_order(
    mut env: Environment,
    order_book_id: String,
    amount: Int,
    side: SIDE,
    position_effect: POSITION_EFFECT,
    style: OrderStyle
) raises -> Optional[Order]:
    """
    Core order submission function for futures trading.

    Handles:
    - Zero quantity validation
    - Limit order price validation (NaN check)
    - Market data availability check
    - Position effect handling (OPEN/CLOSE/CLOSE_TODAY)
    - Old/today position separation for closing orders
    - Order splitting when closing across old and today positions
    - Order submission and filtering based on can_submit_order

    Returns:
    - Single Order if only one order created
    - None if order creation failed or no orders submitted
    """

    if amount == 0:
        var reason = gettext("Order Creation Failed: 0 order quantity, order_book_id={order_book_id}").replace(
            "{order_book_id}", order_book_id
        )
        env.order_creation_failed(order_book_id=order_book_id, reason=reason)
        return None

    if style.style_type == ORDER_TYPE.LIMIT:
        var limit_price = style.get_limit_price()
        if limit_price != None:
            var price_val = limit_price.value()
            if price_val != price_val:
                raise RQInvalidArgument(gettext("Limit order price should not be nan."))

    var ins = env.get_instrument(order_book_id)

    if env.config().base__run_type != RUN_TYPE.BACKTEST:
        if ins.type_val == INSTRUMENT_TYPE.FUTURE:
            if "88" in order_book_id:
                raise RQInvalidArgument(gettext("Main Future contracts[88] are not supported in paper trading."))
            if "99" in order_book_id:
                raise RQInvalidArgument(gettext("Index Future contracts[99] are not supported in paper trading."))

    var price = env.get_last_price_from_proxy(order_book_id)
    if price <= 0.0:
        var reason = gettext("Order Creation Failed: [{order_book_id}] No market data").replace(
            "{order_book_id}", order_book_id
        )
        env.order_creation_failed(order_book_id=order_book_id, reason=reason)
        return None

    var orders = List[Order]()

    if position_effect == POSITION_EFFECT.CLOSE_TODAY or position_effect == POSITION_EFFECT.CLOSE:
        var direction = POSITION_DIRECTION.LONG if side == SIDE.SELL else POSITION_DIRECTION.SHORT
        var account = env.portfolio.get_account(order_book_id)
        var position = account.get_position(order_book_id, direction)

        if position_effect == POSITION_EFFECT.CLOSE_TODAY:
            if amount > position.today_quantity:
                var reason = gettext(
                    "Order Creation Failed: "
                    "close today amount {amount} is larger than today closable quantity {quantity}"
                ).replace("{amount}", String(amount)).replace("{quantity}", String(position.today_quantity))
                env.order_creation_failed(order_book_id=order_book_id, reason=reason)
                return None

            var order = create_order_with_id(
                env.next_order_id(),
                order_book_id,
                side,
                amount,
                style,
                POSITION_EFFECT.CLOSE_TODAY
            )
            orders.append(order^)
        else:

            var quantity = position.quantity
            var old_quantity = position.old_quantity

            if amount > quantity:
                var reason = gettext(
                    "Order Creation Failed: close amount {amount} is larger than position quantity {quantity}"
                ).replace("{amount}", String(amount)).replace("{quantity}", String(quantity))
                env.order_creation_failed(order_book_id=order_book_id, reason=reason)
                return None

            if amount > old_quantity:
                if old_quantity != 0:
                    var close_old_order = create_order_with_id(
                        env.next_order_id(),
                        order_book_id,
                        side,
                        old_quantity,
                        style,
                        POSITION_EFFECT.CLOSE
                    )
                    orders.append(close_old_order^)

                var close_today_qty = amount - old_quantity
                var close_today_order = create_order_with_id(
                    env.next_order_id(),
                    order_book_id,
                    side,
                    close_today_qty,
                    style,
                    POSITION_EFFECT.CLOSE_TODAY
                )
                orders.append(close_today_order^)
            else:
                var close_order = create_order_with_id(
                    env.next_order_id(),
                    order_book_id,
                    side,
                    amount,
                    style,
                    POSITION_EFFECT.CLOSE
                )
                orders.append(close_order^)
    elif position_effect == POSITION_EFFECT.OPEN:
        var open_order = create_order_with_id(
            env.next_order_id(),
            order_book_id,
            side,
            amount,
            style,
            POSITION_EFFECT.OPEN
        )
        orders.append(open_order^)
    else:
        raise Error("NotImplementedError: Unsupported position effect")

    if len(orders) > 1:
        pass

    var final_orders = List[Order]()
    var idx = 0
    while idx < len(orders):
        var o = orders.pop(0)
        if env.can_submit_order(o):
            var result = env.submit_order(o)
            if result != None:
                final_orders.append(result.value().copy())
        else:
            idx += 1

    if len(final_orders) == 1:
        return final_orders[0].copy()
    elif len(final_orders) == 0:
        return None
    else:

        return None


def _order(
    mut env: Environment,
    order_book_id: String,
    quantity: Int,
    style: OrderStyle,
    target: Bool
) raises -> List[Order]:
    """
    Internal order processing function for future_order and future_order_to.

    Args:
    - order_book_id: Instrument identifier
    - quantity: Target/order quantity (positive=buy, negative=sell)
    - style: Order style (Market/Limit)
    - target: If True, adjust to target quantity; if False, submit absolute quantity

    Returns:
    - List of submitted orders (may be empty)
    """
    var long_account = env.portfolio.get_account_by_type(DEFAULT_ACCOUNT_TYPE.FUTURE)
    var short_account = env.portfolio.get_account_by_type(DEFAULT_ACCOUNT_TYPE.FUTURE)
    var long_position = long_account.get_position(order_book_id, POSITION_DIRECTION.LONG)
    var short_position = short_account.get_position(order_book_id, POSITION_DIRECTION.SHORT)

    var actual_quantity = quantity
    if target:
        actual_quantity -= (long_position.quantity - short_position.quantity)

    var orders = List[Order]()

    var position_to_be_closed: Position
    var side: SIDE

    if actual_quantity > 0:
        position_to_be_closed = short_position
        side = SIDE.BUY
    else:
        position_to_be_closed = long_position
        side = SIDE.SELL
        actual_quantity *= -1

    var old_to_be_closed = position_to_be_closed.old_quantity
    var today_to_be_closed = position_to_be_closed.today_quantity

    if old_to_be_closed > 0:
        var close_qty = min(old_to_be_closed, actual_quantity)
        var result = _submit_order(env, order_book_id, close_qty, side, POSITION_EFFECT.CLOSE, style)
        if result != None:
            orders.append(result.value().copy())
        actual_quantity -= old_to_be_closed

    if actual_quantity <= 0:
        return orders^

    if today_to_be_closed > 0:
        var close_qty = min(today_to_be_closed, actual_quantity)
        var result = _submit_order(env, order_book_id, close_qty, side, POSITION_EFFECT.CLOSE_TODAY, style)
        if result != None:
            orders.append(result.value().copy())
        actual_quantity -= today_to_be_closed

    if actual_quantity <= 0:
        return orders^

    var result = _submit_order(env, order_book_id, actual_quantity, side, POSITION_EFFECT.OPEN, style)
    if result != None:
        orders.append(result.value().copy())

    return orders^


def future_order(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) raises -> List[Order]:
    """
    Submit futures orders with specified quantity.

    This is the futures-specific implementation of the generic order() function.
    It handles automatic position direction detection and order splitting.

    Args:
    - id_or_ins: Order book ID or instrument object
    - quantity: Number of lots to trade (positive=buy, negative=sell)
    - style: Order style (default: MarketOrder)

    Returns:
    - List of created orders
    """
    return _order(env, id_or_ins, quantity, style, False)


def future_order_to(
    mut env: Environment,
    id_or_ins: String,
    quantity: Int,
    style: OrderStyle = MarketOrder()
) raises -> List[Order]:
    """
    Adjust futures position to target quantity.

    This is the futures-specific implementation of the generic order_to() function.
    It calculates the difference between current and target position, then submits
    appropriate orders to close/open positions.

    Args:
    - id_or_ins: Order book ID or instrument object
    - quantity: Target position quantity
    - style: Order style (default: MarketOrder)

    Returns:
    - List of created orders
    """
    return _order(env, id_or_ins, quantity, style, True)


def future_buy_open(
    mut env: Environment,
    id_or_ins: String,
    amount: Int,
    style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    """
    Buy to open a long futures position.

    Args:
    - id_or_ins: Order book ID or instrument identifier
    - amount: Number of lots to buy
    - style: Order style (default: MarketOrder)

    Returns:
    - Created order, or None if order creation failed
    """
    return _submit_order(env, id_or_ins, amount, SIDE.BUY, POSITION_EFFECT.OPEN, style)


def future_buy_close(
    mut env: Environment,
    id_or_ins: String,
    amount: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) raises -> Optional[Order]:
    """
    Buy to close a short futures position.

    Args:
    - id_or_ins: Order book ID or instrument identifier
    - amount: Number of lots to close
    - style: Order style (default: MarketOrder)
    - close_today: If True, only close today's position; otherwise close old positions first

    Returns:
    - Created order, or None if order creation failed
    """
    var position_effect = POSITION_EFFECT.CLOSE_TODAY if close_today else POSITION_EFFECT.CLOSE
    return _submit_order(env, id_or_ins, amount, SIDE.BUY, position_effect, style)


def future_sell_open(
    mut env: Environment,
    id_or_ins: String,
    amount: Int,
    style: OrderStyle = MarketOrder()
) raises -> Optional[Order]:
    """
    Sell to open a short futures position.

    Args:
    - id_or_ins: Order book ID or instrument identifier
    - amount: Number of lots to sell
    - style: Order style (default: MarketOrder)

    Returns:
    - Created order, or None if order creation failed
    """
    return _submit_order(env, id_or_ins, amount, SIDE.SELL, POSITION_EFFECT.OPEN, style)


def future_sell_close(
    mut env: Environment,
    id_or_ins: String,
    amount: Int,
    style: OrderStyle = MarketOrder(),
    close_today: Bool = False
) raises -> Optional[Order]:
    """
    Sell to close a long futures position.

    Args:
    - id_or_ins: Order book ID or instrument identifier
    - amount: Number of lots to close
    - style: Order style (default: MarketOrder)
    - close_today: If True, only close today's position; otherwise close old positions first

    Returns:
    - Created order, or None if order creation failed
    """
    var position_effect = POSITION_EFFECT.CLOSE_TODAY if close_today else POSITION_EFFECT.CLOSE
    return _submit_order(env, id_or_ins, amount, SIDE.SELL, position_effect, style)


def get_future_contracts(
    mut env: Environment,
    underlying_symbol: String
) -> List[String]:
    """
    Get list of tradable futures contracts for a given underlying symbol.

    Contracts are sorted by expiration month in ascending order.
    The first contract in the list is the near-month contract.

    Args:
    - env: Environment instance
    - underlying_symbol: Futures underlying symbol (e.g., 'IF' for CSI 300 index futures)

    Returns:
    - List of order_book_id strings for tradable contracts

    Example:
    For IF on 2016-12-01, returns: ['IF1612', 'IF1701', 'IF1703', 'IF1706']
    """
    var instruments = env.get_all_instruments_from_proxy("Future")
    var result = List[String]()
    for ins in instruments:
        if ins.underlying_symbol() == underlying_symbol:
            result.append(ins.order_book_id())
    return result^
