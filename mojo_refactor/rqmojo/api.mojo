"""
RQAlpha Mojo - API Base
Ported from rqalpha/api.py and rqalpha/apis/api_base.py
"""

from collections import Set
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_TYPE, INSTRUMENT_TYPE
from rqmojo.model.order import Order, buy, sell, MarketOrder, LimitOrder, OrderStyle, create_order_with_id
from rqmojo.model.instrument import Instrument
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.model.trade import Trade
from rqmojo.utils.datetime_func import DateTime
from rqmojo.environment import Environment, create_environment


fn order_shares(order_book_id: String, quantity: Int, style: OrderStyle = MarketOrder()) -> Order:
    if quantity > 0:
        return buy(order_book_id, quantity, style)
    else:
        return sell(order_book_id, -quantity, style)


fn order_percent(order_book_id: String, percent: Float64, style: OrderStyle = MarketOrder()) -> Optional[Order]:
    if percent <= 0 or percent > 1:
        return None
    
    var quantity = Int(100000.0 * percent / 10.0 / 100.0) * 100
    if quantity == 0:
        return None
    
    return order_shares(order_book_id, quantity, style)


fn order_target_value(order_book_id: String, target_value: Float64, style: OrderStyle = MarketOrder()) -> Optional[Order]:
    if target_value == 0:
        return None
    
    var quantity = Int(target_value / 10.0 / 100.0) * 100
    if quantity == 0:
        return None
    
    return order_shares(order_book_id, quantity, style)


fn order_value(order_book_id: String, value: Float64, style: OrderStyle = MarketOrder()) -> Optional[Order]:
    if value == 0:
        return None
    
    var quantity = Int(value / 10.0 / 100.0) * 100
    if quantity == 0:
        return None
    
    if value < 0:
        return sell(order_book_id, -quantity, style)
    return order_shares(order_book_id, quantity, style)


fn order_target_percent(order_book_id: String, percent: Float64, style: OrderStyle = MarketOrder()) -> Optional[Order]:
    if percent <= 0 or percent > 1:
        return None
    
    var target_value = 100000.0 * percent
    return order_target_value(order_book_id, target_value, style)


fn cancel_order(order_id: Int) -> None:
    pass


fn get_order(order_id: Int) -> Order:
    return create_order_with_id(order_id, "", SIDE.BUY(), 0, MarketOrder())


fn get_open_orders() -> List[Order]:
    var orders = List[Order]()
    return orders^


fn update_universe(order_book_ids: List[String]) -> None:
    pass


fn is_suspended(order_book_id: String) -> Bool:
    return False


fn is_trading(order_book_id: String) -> Bool:
    return True


fn get_previous_trading_date(date: DateTime) -> DateTime:
    return DateTime(date.year, date.month, date.day - 1, 0, 0, 0, 0)


fn get_next_trading_date(date: DateTime) -> DateTime:
    return DateTime(date.year, date.month, date.day + 1, 0, 0, 0, 0)


fn get_trading_dates(start_date: DateTime, end_date: DateTime) -> List[DateTime]:
    var result = List[DateTime]()
    var current = start_date
    while current.year < end_date.year or (current.year == end_date.year and current.month < end_date.month) or (current.year == end_date.year and current.month == end_date.month and current.day <= end_date.day):
        result.append(current)
        current = DateTime(current.year, current.month, current.day + 1, 0, 0, 0, 0)
    return result^
