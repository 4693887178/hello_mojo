"""
RQAlpha Mojo - Broker Implementation
Ported from rqalpha/core/broker.py
"""

from std.collections import Dict, List, Optional
from rqmojo.interface import Broker
from rqmojo.model.order import Order, OrderIdGenerator, create_order_id_generator
from rqmojo.model.trade import Trade, create_trade
from rqmojo.const import ORDER_STATUS, SIDE
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct SimulationBroker(Broker, Movable, Writable):
    var _open_orders: Dict[Int, Order]
    var _order_id_generator: OrderIdGenerator
    var _current_datetime: DateTime

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationBroker(orders=", String(len(self._open_orders)), ")")

    def submit_order(mut self, mut order: Order, mut account: Account):
        if order.order_id == 0:
            order.order_id = self._order_id_generator.next()
        order.status = ORDER_STATUS.PENDING_NEW
        self._open_orders[order.order_id] = order.copy()
        self._process_order(order, account)

    def cancel_order(mut self, order_id: Int):
        if order_id in self._open_orders:
            try:
                var order = self._open_orders[order_id]
                if order.status == ORDER_STATUS.PENDING_NEW or order.status == ORDER_STATUS.ACTIVE:
                    _ = self._open_orders.pop(order_id)
            except:
                pass

    def get_open_orders(self) -> List[Order]:
        var orders = List[Order]()
        for order in self._open_orders.values():
            orders.append(order)
        return orders^

    def get_open_orders_by_instrument(self, order_book_id: String) -> List[Order]:
        var orders = List[Order]()
        for order in self._open_orders.values():
            if order.order_book_id == order_book_id:
                orders.append(order)
        return orders^

    def _process_order(mut self, mut order: Order, mut account: Account):
        order.status = ORDER_STATUS.FILLED
        var trade = create_trade(
            order,
            order.quantity,
            order.price
        )
        account.apply_trade(trade)
        if order.order_id in self._open_orders:
            try:
                _ = self._open_orders.pop(order.order_id)
            except:
                pass

    def set_current_datetime(mut self, dt: DateTime):
        self._current_datetime = dt


def create_simulation_broker() -> SimulationBroker:
    return SimulationBroker(
        _open_orders=Dict[Int, Order](),
        _order_id_generator=create_order_id_generator(),
        _current_datetime=DateTime(2020, 1, 1, 0, 0, 0, 0)
    )


def create_broker() -> SimulationBroker:
    return create_simulation_broker()
