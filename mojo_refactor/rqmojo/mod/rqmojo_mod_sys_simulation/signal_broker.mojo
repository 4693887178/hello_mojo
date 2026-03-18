"""
RQAlpha Mojo - Signal Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/signal_broker.py
"""

from rqmojo.const import ORDER_STATUS, SIDE, POSITION_EFFECT
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct SignalBroker(Movable):
    var _orders: Dict[Int, Order]
    var _order_count: Int
    
    fn submit_order(mut self, order: Order) -> None:
        self._order_count += 1
        self._orders[self._order_count] = order
    
    fn cancel_order(mut self, order_id: Int) -> None:
        if self._orders.contains(order_id):
            self._orders[order_id].status = ORDER_STATUS.CANCELLED()
    
    fn get_open_orders(self) -> List[Order]:
        var result = List[Order]()
        for order_id in self._orders.keys():
            var order = self._orders[order_id]
            if order.status == ORDER_STATUS.ACTIVE():
                result.append(order)
        return result
    
    fn get_order_count(self) -> Int:
        return self._order_count


fn create_signal_broker() -> SignalBroker:
    return SignalBroker(
        _orders=Dict[Int, Order](),
        _order_count=0
    )
