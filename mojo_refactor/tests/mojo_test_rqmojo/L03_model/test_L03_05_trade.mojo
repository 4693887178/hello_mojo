# test_L03_05_trade.mojo
# Module: rqmojo.model.trade
# Python: rqalpha.model.trade
# Level: L03 - Data Model
# Dependencies: const, order

from rqmojo.model.trade import (
    Trade, TradeIdGenerator,
    create_trade_id_generator,
    create_trade_with_id, create_trade, create_trade_from_order
)
from rqmojo.model.order import Order, MarketOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION
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

    fn test_trade_id_generator(mut self):
        var gen = create_trade_id_generator()
        var id1 = gen.next()
        var id2 = gen.next()
        self.check(id1 != id2, "TradeIdGenerator generates unique IDs")
        self.check(id1 == 1, "TradeIdGenerator first ID is 1")
        self.check(id2 == 2, "TradeIdGenerator second ID is 2")

    fn test_trade_id_generator_str(mut self):
        var gen = create_trade_id_generator()
        var str_repr = gen.__str__()
        self.check(str_repr.find("TradeIdGenerator") >= 0, "TradeIdGenerator __str__ contains TradeIdGenerator")

    fn test_create_trade_with_id(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        self.check(trade.trade_id == 1, "Trade trade_id is 1")
        self.check(trade.exec_id == "1", "Trade exec_id is '1'")
        self.check(trade.order_id == 1, "Trade order_id is 1")
        self.check(trade.order_book_id == "000001.XSHE", "Trade order_book_id is 000001.XSHE")

    fn test_trade_side(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(2, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        self.check(trade.side == SIDE.BUY, "Trade side is BUY")

    fn test_trade_position_effect(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(3, "000001.XSHE", SIDE.BUY, 100, style, POSITION_EFFECT.OPEN)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        self.check(trade.position_effect == POSITION_EFFECT.OPEN, "Trade position_effect is OPEN")

    fn test_trade_position_direction(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(4, "000001.XSHE", SIDE.BUY, 100, style, POSITION_EFFECT.OPEN)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        self.check(trade.position_direction == POSITION_DIRECTION.LONG, "Trade position_direction is LONG")

    fn test_trade_quantity_price(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(5, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.5)
        self.check(trade.quantity == 100, "Trade quantity is 100")
        self.check(trade.price == 10.5, "Trade price is 10.5")

    fn test_trade_commission_tax(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(6, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.0, 5.0, 1.0)
        self.check(trade.commission == 5.0, "Trade commission is 5.0")
        self.check(trade.tax == 1.0, "Trade tax is 1.0")

    fn test_trade_default_commission_tax(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(7, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        self.check(trade.commission == 0.0, "Trade default commission is 0.0")
        self.check(trade.tax == 0.0, "Trade default tax is 0.0")

    fn test_create_trade(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(8, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade(order, 100, 10.0)
        self.check(trade.trade_id == 1, "create_trade trade_id is 1")
        self.check(trade.quantity == 100, "create_trade quantity is 100")
        self.check(trade.price == 10.0, "create_trade price is 10.0")

    fn test_create_trade_from_order(mut self):
        var trade = create_trade_from_order(
            1, 100, "000001.XSHE", SIDE.BUY, POSITION_EFFECT.OPEN,
            POSITION_DIRECTION.LONG, 100, 10.0
        )
        self.check(trade.trade_id == 1, "create_trade_from_order trade_id is 1")
        self.check(trade.order_id == 100, "create_trade_from_order order_id is 100")
        self.check(trade.order_book_id == "000001.XSHE", "create_trade_from_order order_book_id is 000001.XSHE")
        self.check(trade.side == SIDE.BUY, "create_trade_from_order side is BUY")
        self.check(trade.quantity == 100, "create_trade_from_order quantity is 100")
        self.check(trade.price == 10.0, "create_trade_from_order price is 10.0")

    fn test_trade_str(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(9, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        var str_repr = trade.__str__()
        self.check(str_repr.find("Trade") >= 0, "Trade __str__ contains Trade")
        self.check(str_repr.find("000001.XSHE") >= 0, "Trade __str__ contains order_book_id")
        self.check(str_repr.find("BUY") >= 0, "Trade __str__ contains side")

    fn test_trade_sell_side(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(10, "000001.XSHE", SIDE.SELL, 100, style, POSITION_EFFECT.CLOSE)
        var trade = create_trade_with_id(2, order, 100, 10.0)
        self.check(trade.side == SIDE.SELL, "Trade sell side is SELL")
        self.check(trade.position_effect == POSITION_EFFECT.CLOSE, "Trade sell position_effect is CLOSE")

    fn test_trade_datetime(mut self):
        var style = MarketOrder()
        var order = create_order_with_id(11, "000001.XSHE", SIDE.BUY, 100, style)
        var trade = create_trade_with_id(1, order, 100, 10.0)
        self.check(trade.datetime.year == 1970, "Trade datetime year is 1970")
        self.check(trade.datetime.month == 1, "Trade datetime month is 1")
        self.check(trade.datetime.day == 1, "Trade datetime day is 1")

    fn run_all(mut self):
        print("=" * 60)
        print("L03_05_trade Module Tests")
        print("=" * 60)
        
        self.test_trade_id_generator()
        self.test_trade_id_generator_str()
        self.test_create_trade_with_id()
        self.test_trade_side()
        self.test_trade_position_effect()
        self.test_trade_position_direction()
        self.test_trade_quantity_price()
        self.test_trade_commission_tax()
        self.test_trade_default_commission_tax()
        self.test_create_trade()
        self.test_create_trade_from_order()
        self.test_trade_str()
        self.test_trade_sell_side()
        self.test_trade_datetime()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
