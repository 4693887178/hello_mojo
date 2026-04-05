"""
RQAlpha Mojo - Broker Implementation
Ported from rqalpha/core/broker.py
"""

from std.collections import Dict, List, Optional
from rqmojo.interface import Broker
from rqmojo.model.order import Order, OrderIdGenerator, create_order_id_generator
from rqmojo.model.trade import Trade, create_trade
from rqmojo.const import ORDER_STATUS, SIDE
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct SimulationBroker(Broker, Movable, Writable):
    var _open_orders: Dict[Int, Order]
    var _order_id_generator: OrderIdGenerator
    var _current_datetime: DateTime
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("SimulationBroker(orders=", String(self._open_orders.len()), ")")
    
    def submit_order(mut self, order: Order, account: Account):
        """提交订单"""
        # 生成订单ID
        if order.id == 0:
            order.id = self._order_id_generator.next()
        
        # 设置订单状态
        order.status = ORDER_STATUS.PENDING_NEW
        
        # 添加到未成交订单列表
        self._open_orders[order.id] = order
        
        # 模拟订单执行
        self._process_order(order, account)
    
    def cancel_order(mut self, order_id: Int):
        """取消订单"""
        if order_id in self._open_orders:
            var order = self._open_orders[order_id]
            if order.status in [ORDER_STATUS.PENDING_NEW, ORDER_STATUS.ACTIVE]:
                order.status = ORDER_STATUS.CANCELLED
                del self._open_orders[order_id]
    
    def get_open_orders(self) -> List[Order]:
        """获取所有未成交订单"""
        var orders = List[Order]()
        for order in self._open_orders.values():
            orders.append(order)
        return orders^
    
    def get_open_orders_by_instrument(self, order_book_id: String) -> List[Order]:
        """获取指定标的的未成交订单"""
        var orders = List[Order]()
        for order in self._open_orders.values():
            if order.order_book_id == order_book_id:
                orders.append(order)
        return orders^
    
    def _process_order(mut self, order: Order, account: Account):
        """处理订单执行"""
        # 模拟订单执行
        order.status = ORDER_STATUS.FILLED
        
        # 创建交易记录
        var trade = create_trade(
            order_id=order.id,
            order_book_id=order.order_book_id,
            price=order.price,
            quantity=order.quantity,
            side=order.side,
            datetime=self._current_datetime
        )
        
        # 应用交易到账户
        account.apply_trade(trade)
        
        # 从未成交订单列表中移除
        if order.id in self._open_orders:
            del self._open_orders[order.id]
    
    def set_current_datetime(mut self, dt: DateTime):
        """设置当前时间"""
        self._current_datetime = dt


def create_simulation_broker() -> SimulationBroker:
    """创建模拟broker实例"""
    return SimulationBroker(
        _open_orders=Dict[Int, Order](),
        _order_id_generator=create_order_id_generator(),
        _current_datetime=DateTime(2020, 1, 1, 0, 0, 0, 0)
    )


def create_broker() -> SimulationBroker:
    """创建broker实例"""
    return create_simulation_broker()
