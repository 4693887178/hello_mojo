"""
RQAlpha Mojo - Signal Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/signal_broker.py
"""

from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT, ORDER_STATUS_CANCELLED, ORDER_STATUS_ACTIVE
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct SignalBroker(Writable, Movable):
    var _orders: Dict[Int, Order]
    var _order_count: Int
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("SignalBroker(orders=", String(self._order_count), ")")
    
    def submit_order(mut self, order: Order) -> None:
        self._order_count += 1
        self._orders[self._order_count] = order
    
    def cancel_order(mut self, order_id: Int) raises -> None:
        var found = False
        for entry in self._orders.items():
            if entry.key == order_id:
                found = True
                break
        if found:
            var existing = self._orders[order_id]
            existing.status = ORDER_STATUS_CANCELLED
            self._orders[order_id] = existing
    
    def get_open_orders(self) -> List[Order]:
        var result = List[Order]()
        for entry in self._orders.items():
            if entry.value.status == ORDER_STATUS_ACTIVE:
                result.append(entry.value)
        return result^
    
    def get_order_count(self) -> Int:
        return self._order_count


def create_signal_broker() -> SignalBroker:
    return SignalBroker(
        _orders=Dict[Int, Order](),
        _order_count=0
    )
