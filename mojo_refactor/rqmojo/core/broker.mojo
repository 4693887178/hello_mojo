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
    var _account: Optional[Account]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationBroker(orders=", String(len(self._open_orders)), ")")

    def submit_order(mut self, mut order: Order):
        if order.order_id == 0:
            order.order_id = self._order_id_generator.next()
        order.status = ORDER_STATUS.PENDING_NEW
        self._open_orders[order.order_id] = order.copy()
        if self._account is not None:
            var acc = self._account.value().copy()
            self._process_order(order, acc)

    def cancel_order(mut self, order: Order):
        if order.order_id in self._open_orders:
            try:
                if self._open_orders[order.order_id].status == ORDER_STATUS.PENDING_NEW or self._open_orders[order.order_id].status == ORDER_STATUS.ACTIVE:
                    _ = self._open_orders.pop(order.order_id)
            except:
                pass

    def get_open_orders(self, order_book_id: Optional[String] = None) -> List[Order]:
        var orders = List[Order]()
        for order in self._open_orders.values():
            if order_book_id is not None:
                if order.order_book_id != order_book_id.value():
                    continue
            orders.append(order.copy())
        return orders^

    def get_open_orders_by_instrument(self, order_book_id: String) -> List[Order]:
        return self.get_open_orders(order_book_id)

    def set_account(mut self, account: Account):
        self._account = account

    def _process_order(mut self, mut order: Order, mut account: Account):
        order.status = ORDER_STATUS.FILLED
        var trade = create_trade(
            order,
            order.quantity,
            order.price()
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
        _current_datetime=DateTime(2020, 1, 1, 0, 0, 0, 0),
        _account=None
    )


def create_broker() -> SimulationBroker:
    return create_simulation_broker()
