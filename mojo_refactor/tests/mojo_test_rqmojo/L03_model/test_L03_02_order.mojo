# test_L03_02_order.mojo
# Module: rqmojo.model.order
# Python: rqalpha.model.order
# Level: L03 - Data Model
# Dependencies: const, instrument

from rqmojo.model.order import (
    Order, OrderStyle, OrderIdGenerator,
    MarketOrder, LimitOrder,
    create_order_with_id, create_order_id_generator,
    buy, sell
)
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, ORDER_TYPE
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct TestRunner:
    var test_count: Int
    var pass_count: Int
    
    fn check(mut self, condition: Bool, test_name: String):
        self.test_count += 1
        if condition:
            self.pass_count += 1
            print("PASS: " + test_name)
        else:
            print("FAIL: " + test_name)

    fn test_order_id_generator(mut self):
        var gen = create_order_id_generator()
        var id1 = gen.next()
        var id2 = gen.next()
        self.check(id1 != id2, "OrderIdGenerator generates unique IDs")
        self.check(id1 == 1, "OrderIdGenerator first ID is 1")
        self.check(id2 == 2, "OrderIdGenerator second ID is 2")

    fn test_market_order_style(mut self):
        var style = MarketOrder()
        self.check(style.style_type == ORDER_TYPE.MARKET(), "MarketOrder style_type is MARKET")
        self.check(style.limit_price == 0.0, "MarketOrder limit_price is 0.0")

    fn test_limit_order_style(mut self):
        var style = LimitOrder(15.5)
        self.check(style.style_type == ORDER_TYPE.LIMIT(), "LimitOrder style_type is LIMIT")
        self.check(style.limit_price == 15.5, "LimitOrder limit_price is 15.5")

    fn test_order_style_str(mut self):
        var market_style = MarketOrder()
        var limit_style = LimitOrder(10.0)
        self.check(market_style.__str__() == "MarketOrder", "MarketOrder __str__ is MarketOrder")
        self.check(limit_style.__str__().find("LimitOrder") >= 0, "LimitOrder __str__ contains LimitOrder")

    fn test_create_order_with_id(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY(), 100, style)
        self.check(order.order_id == 1, "Order order_id is 1")
        self.check(order.order_book_id == "000001.XSHE", "Order order_book_id is 000001.XSHE")
        self.check(order.side == SIDE.BUY(), "Order side is BUY")
        self.check(order.quantity == 100, "Order quantity is 100")

    fn test_create_order_with_limit_style(mut self):
        var style = LimitOrder(10.0)
        var order = create_order_with_id(2, "000002.XSHE", SIDE.SELL(), 200, style, POSITION_EFFECT.CLOSE())
        self.check(order.order_id == 2, "Order with limit style order_id is 2")
        self.check(order.style.style_type == ORDER_TYPE.LIMIT(), "Order with limit style type is LIMIT")
        self.check(order.style.limit_price == 10.0, "Order with limit style limit_price is 10.0")
        self.check(order.position_effect == POSITION_EFFECT.CLOSE(), "Order position_effect is CLOSE")

    fn test_order_initial_status(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(3, "000001.XSHE", SIDE.BUY(), 100, style)
        self.check(order.status == ORDER_STATUS.PENDING_NEW(), "Order initial status is PENDING_NEW")
        self.check(order.filled_quantity == 0, "Order initial filled_quantity is 0")
        self.check(order.unfilled_quantity == 100, "Order initial unfilled_quantity is 100")

    fn test_order_fill(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(4, "000001.XSHE", SIDE.BUY(), 100, style)
        order.fill(50, 10.0)
        self.check(order.filled_quantity == 50, "Order filled_quantity after fill is 50")
        self.check(order.unfilled_quantity == 50, "Order unfilled_quantity after fill is 50")
        self.check(order.avg_price == 10.0, "Order avg_price after fill is 10.0")
        self.check(order.status == ORDER_STATUS.ACTIVE(), "Order status after partial fill is ACTIVE")

    fn test_order_fill_complete(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(5, "000001.XSHE", SIDE.BUY(), 100, style)
        order.fill(100, 10.0)
        self.check(order.filled_quantity == 100, "Order filled_quantity after complete fill is 100")
        self.check(order.unfilled_quantity == 0, "Order unfilled_quantity after complete fill is 0")
        self.check(order.status == ORDER_STATUS.FILLED(), "Order status after complete fill is FILLED")

    fn test_order_fill_multiple(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(6, "000001.XSHE", SIDE.BUY(), 100, style)
        order.fill(50, 10.0)
        order.fill(50, 12.0)
        self.check(order.filled_quantity == 100, "Order filled_quantity after multiple fills is 100")
        self.check(order.avg_price == 11.0, "Order avg_price after multiple fills is 11.0")

    fn test_order_is_active(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(7, "000001.XSHE", SIDE.BUY(), 100, style)
        self.check(order.is_active() == True, "Order is_active initially is True")
        order.fill(100, 10.0)
        self.check(order.is_active() == False, "Order is_active after fill is False")

    fn test_order_is_filled(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(8, "000001.XSHE", SIDE.BUY(), 100, style)
        self.check(order.is_filled() == False, "Order is_filled initially is False")
        order.fill(100, 10.0)
        self.check(order.is_filled() == True, "Order is_filled after complete fill is True")

    fn test_order_str(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(9, "000001.XSHE", SIDE.BUY(), 100, style)
        var str_repr = order.__str__()
        self.check(str_repr.find("Order") >= 0, "Order __str__ contains Order")
        self.check(str_repr.find("000001.XSHE") >= 0, "Order __str__ contains order_book_id")
        self.check(str_repr.find("BUY") >= 0, "Order __str__ contains side")

    fn test_buy_function(mut self):
        var order = buy("000001.XSHE", 100)
        self.check(order.side == SIDE.BUY(), "buy() creates order with BUY side")
        self.check(order.position_effect == POSITION_EFFECT.OPEN(), "buy() creates order with OPEN position_effect")

    fn test_sell_function(mut self):
        var order = sell("000001.XSHE", 100)
        self.check(order.side == SIDE.SELL(), "sell() creates order with SELL side")

    fn test_order_with_different_sides(mut self):
        var style = MarketOrder()
        var buy_order = create_order_with_id(10, "000001.XSHE", SIDE.BUY(), 100, style)
        var sell_order = create_order_with_id(11, "000001.XSHE", SIDE.SELL(), 100, style)
        self.check(buy_order.side == SIDE.BUY(), "Order with BUY side")
        self.check(sell_order.side == SIDE.SELL(), "Order with SELL side")

    fn test_order_with_different_position_effects(mut self):
        var style = MarketOrder()
        var open_order = create_order_with_id(12, "IF2401.CFFEX", SIDE.BUY(), 1, style, POSITION_EFFECT.OPEN())
        var close_order = create_order_with_id(13, "IF2401.CFFEX", SIDE.SELL(), 1, style, POSITION_EFFECT.CLOSE())
        var close_today_order = create_order_with_id(14, "IF2401.CFFEX", SIDE.SELL(), 1, style, POSITION_EFFECT.CLOSE_TODAY())
        self.check(open_order.position_effect == POSITION_EFFECT.OPEN(), "Order with OPEN position_effect")
        self.check(close_order.position_effect == POSITION_EFFECT.CLOSE(), "Order with CLOSE position_effect")
        self.check(close_today_order.position_effect == POSITION_EFFECT.CLOSE_TODAY(), "Order with CLOSE_TODAY position_effect")

    fn run_all(mut self):
        print("=" * 60)
        print("L03_02_order Module Tests")
        print("=" * 60)
        
        self.test_order_id_generator()
        self.test_market_order_style()
        self.test_limit_order_style()
        self.test_order_style_str()
        self.test_create_order_with_id()
        self.test_create_order_with_limit_style()
        self.test_order_initial_status()
        self.test_order_fill()
        self.test_order_fill_complete()
        self.test_order_fill_multiple()
        self.test_order_is_active()
        self.test_order_is_filled()
        self.test_order_str()
        self.test_buy_function()
        self.test_sell_function()
        self.test_order_with_different_sides()
        self.test_order_with_different_position_effects()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
