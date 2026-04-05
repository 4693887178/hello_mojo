"""
RQAlpha Mojo - Simulation Broker
Ported from rqalpha/mod/rqalpha_mod_sys_simulation/simulation_broker.py
"""

from std.collections import Dict, List
from rqmojo.const import ORDER_STATUS, INSTRUMENT_TYPE, MATCHING_TYPE, POSITION_EFFECT, EXECUTION_PHASE
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade, create_trade_with_id
from rqmojo.model.bar import BarObject
from rqmojo.model.tick import TickObject
from rqmojo.core.events import EVENT, Event


@fieldwise_init
struct BrokerState(Movable):
    var order_count: Int
    var trade_count: Int
    var last_order_id: Int
    var open_orders_state: List[String]
    var open_auction_orders_state: List[String]


@fieldwise_init
struct OrderAccountPair(Copyable, Movable, ImplicitlyCopyable):
    var account: String
    var order: Order


@fieldwise_init
struct SimulationBroker(Movable):
    var _name: String
    var _order_count: Int
    var _trade_count: Int
    var _open_orders: List[OrderAccountPair]
    var _open_auction_orders: List[OrderAccountPair]
    var _trade_id: Int
    var _matching_type: MATCHING_TYPE
    var _match_immediately: Bool

    def __str__(self) -> String:
        return "SimulationBroker(orders=" + String(len(self._open_orders)) + ")"

    def submit_order(mut self, order: Order) -> None:
        if order.position_effect == POSITION_EFFECT.MATCH:
            return
        
        self._order_count += 1
        var pair = OrderAccountPair(account="", order=order)
        self._open_orders.append(pair)

    def cancel_order(mut self, order: Order) -> None:
        var new_orders = List[OrderAccountPair]()
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            if pair.order.order_id != order.order_id:
                new_orders.append(pair)
        self._open_orders = new_orders^

    def get_open_orders(self) -> List[Order]:
        var result = List[Order]()
        for i in range(len(self._open_orders)):
            result.append(self._open_orders[i].order)
        return result^

    def get_open_orders_for(self, order_book_id: String) -> List[Order]:
        var result = List[Order]()
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            if pair.order.order_book_id == order_book_id:
                result.append(pair.order)
        return result^

    def match_order(mut self, order: Order, bar: BarObject) -> Trade:
        self._trade_id += 1
        var price = bar.close()
        var quantity = order.unfilled_quantity
        
        var trade = create_trade_with_id(
            trade_id=self._trade_id,
            order=order,
            quantity=quantity,
            price=price
        )
        
        return trade^

    def match_all_orders(mut self, bars: Dict[String, BarObject]) raises -> List[Trade]:
        var trades = List[Trade]()
        var remaining_orders = List[OrderAccountPair]()
        
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            var order = pair.order
            if order.order_book_id in bars:
                var bar = bars[order.order_book_id]
                var trade = self.match_order(order, bar)
                trades.append(trade)
            else:
                remaining_orders.append(pair)
        
        self._open_orders = remaining_orders^
        return trades^

    def on_bar(mut self, bar: BarObject) -> List[Trade]:
        var trades = List[Trade]()
        var remaining_orders = List[OrderAccountPair]()
        var bar_ob_id = bar.order_book_id()
        
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            var order = pair.order
            if order.order_book_id == bar_ob_id:
                var trade = self.match_order(order, bar)
                trades.append(trade)
            else:
                remaining_orders.append(pair)
        
        self._open_orders = remaining_orders^
        return trades^

    def on_tick(mut self, tick: TickObject) -> List[Trade]:
        var trades = List[Trade]()
        var remaining_orders = List[OrderAccountPair]()
        var tick_ob_id = tick.order_book_id()
        
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            var order = pair.order
            if order.order_book_id == tick_ob_id:
                self._trade_id += 1
                var trade = create_trade_with_id(
                    trade_id=self._trade_id,
                    order=order,
                    quantity=order.unfilled_quantity,
                    price=tick.last
                )
                trades.append(trade)
            else:
                remaining_orders.append(pair)
        
        self._open_orders = remaining_orders^
        return trades^

    def before_trading(mut self) -> None:
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            pair.order.active()

    def after_trading(mut self) -> None:
        var new_orders = List[OrderAccountPair]()
        for i in range(len(self._open_orders)):
            var pair = self._open_orders[i]
            pair.order.mark_rejected("Order Rejected: " + pair.order.order_book_id + " can not match. Market close.")
            new_orders.append(pair)
        self._open_orders = new_orders^

    def pre_settlement(mut self) -> None:
        pass

    def get_state(self) -> BrokerState:
        var open_orders_state = List[String]()
        for i in range(len(self._open_orders)):
            open_orders_state.append(String(self._open_orders[i].order.order_id))
        
        return BrokerState(
            order_count=self._order_count,
            trade_count=self._trade_count,
            last_order_id=self._order_count,
            open_orders_state=open_orders_state^,
            open_auction_orders_state=List[String]()
        )

    def set_state(mut self, state: BrokerState) -> None:
        self._order_count = state.order_count
        self._trade_count = state.trade_count


def create_simulation_broker(matching_type: MATCHING_TYPE = MATCHING_TYPE.CURRENT_BAR_CLOSE) -> SimulationBroker:
    var match_immediately = (matching_type == MATCHING_TYPE.CURRENT_BAR_CLOSE or matching_type == MATCHING_TYPE.VWAP)
    
    return SimulationBroker(
        _name="simulation",
        _order_count=0,
        _trade_count=0,
        _open_orders=List[OrderAccountPair](),
        _open_auction_orders=List[OrderAccountPair](),
        _trade_id=0,
        _matching_type=matching_type,
        _match_immediately=match_immediately
    )
