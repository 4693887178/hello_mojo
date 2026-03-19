# test_L08_01_position.mojo
# Module: rqmojo.portfolio.position
# Python: rqalpha/portfolio/position.py
# Level: L08 - Portfolio
# Dependencies: const, model

from rqmojo.portfolio.position import (
    Position, PositionProxy, create_position, create_stock_position,
    create_future_position, create_position_proxy
)
from rqmojo.const import POSITION_DIRECTION, POSITION_EFFECT, SIDE
from rqmojo.model.trade import Trade, create_trade_from_order


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

    fn test_create_position(mut self):
        var pos = create_position("000001.XSHE")
        self.check(pos.order_book_id == "000001.XSHE", "Position order_book_id")
        self.check(pos.quantity == 0, "Position quantity is 0 initially")
        self.check(pos.avg_price == 0.0, "Position avg_price is 0 initially")
        self.check(pos.direction == POSITION_DIRECTION.LONG(), "Position direction is LONG")

    fn test_create_stock_position(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        self.check(pos.order_book_id == "000001.XSHE", "Stock position order_book_id")
        self.check(pos.quantity == 100, "Stock position quantity")
        self.check(pos.avg_price == 10.0, "Stock position avg_price")
        self.check(pos._contract_multiplier == 1.0, "Stock position contract_multiplier")

    fn test_create_future_position(mut self):
        var pos = create_future_position("IF2401", POSITION_DIRECTION.LONG(), 10, 4000.0, 300.0, 0.1)
        self.check(pos.order_book_id == "IF2401", "Future position order_book_id")
        self.check(pos.quantity == 10, "Future position quantity")
        self.check(pos._contract_multiplier == 300.0, "Future position contract_multiplier")
        self.check(pos._margin_rate == 0.1, "Future position margin_rate")

    fn test_position_pnl(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.update_last_price(11.0)
        var pnl = pos.pnl()
        self.check(pnl == 100.0, "Position pnl calculation")

    fn test_position_daily_pnl(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.update_prev_close(10.0)
        pos.update_last_price(11.0)
        var daily_pnl = pos.daily_pnl()
        self.check(daily_pnl == 100.0, "Position daily_pnl calculation")

    fn test_position_margin(mut self):
        var pos = create_future_position("IF2401", POSITION_DIRECTION.LONG(), 10, 4000.0, 300.0, 0.1)
        pos.update_last_price(4000.0)
        var margin = pos.margin()
        self.check(margin == 120000.0, "Position margin calculation")

    fn test_position_market_value(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.update_last_price(11.0)
        self.check(pos.market_value == 1100.0, "Position market_value")

    fn test_position_closable(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        self.check(pos.closable() == 100, "Position closable")

    fn test_position_apply_trade_open(mut self):
        var pos = create_stock_position("000001.XSHE", 0, 0.0)
        var trade = create_trade_from_order(
            trade_id=1,
            order_id=1,
            order_book_id="000001.XSHE",
            side=SIDE.BUY(),
            position_effect=POSITION_EFFECT.OPEN(),
            position_direction=POSITION_DIRECTION.LONG(),
            quantity=100,
            price=10.0
        )
        var delta_cash = pos.apply_trade(trade)
        self.check(pos.quantity == 100, "Position quantity after open trade")
        self.check(pos.avg_price == 10.0, "Position avg_price after open trade")
        self.check(delta_cash == -1000.0, "Position delta_cash after open trade")

    fn test_position_apply_trade_close(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        var trade = create_trade_from_order(
            trade_id=1,
            order_id=1,
            order_book_id="000001.XSHE",
            side=SIDE.SELL(),
            position_effect=POSITION_EFFECT.CLOSE(),
            position_direction=POSITION_DIRECTION.LONG(),
            quantity=50,
            price=11.0
        )
        var delta_cash = pos.apply_trade(trade)
        self.check(pos.quantity == 50, "Position quantity after close trade")
        self.check(delta_cash == 550.0, "Position delta_cash after close trade")

    fn test_position_update_last_price(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.update_last_price(12.0)
        self.check(pos.last_price == 12.0, "Position last_price updated")
        self.check(pos.market_value == 1200.0, "Position market_value updated")

    fn test_position_before_trading(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.today_quantity = 50
        pos.before_trading()
        self.check(pos.old_quantity == 100, "Position old_quantity after before_trading")
        self.check(pos.today_quantity == 0, "Position today_quantity reset")

    fn test_position_settlement(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.update_last_price(11.0)
        pos.settlement()
        self.check(pos.prev_close == 11.0, "Position prev_close after settlement")

    fn test_position_short_pnl(mut self):
        var pos = create_future_position("IF2401", POSITION_DIRECTION.SHORT(), 10, 4000.0, 300.0, 0.1)
        pos.update_last_price(3900.0)
        var pnl = pos.pnl()
        self.check(pnl == 300000.0, "Position short pnl calculation")

    fn test_position_proxy(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        pos.update_last_price(11.0)
        var proxy = create_position_proxy(pos)
        self.check(proxy.order_book_id == "000001.XSHE", "PositionProxy order_book_id")
        self.check(proxy.quantity == 100, "PositionProxy quantity")
        self.check(proxy.pnl == 100.0, "PositionProxy pnl")

    fn test_position_str(mut self):
        var pos = create_stock_position("000001.XSHE", 100, 10.0)
        var result = pos.__str__()
        self.check(len(result) > 0, "Position __str__ returns non-empty")
        self.check(result.count("000001.XSHE") > 0, "Position __str__ contains order_book_id")

    fn run_all(mut self):
        print("=" * 60)
        print("L08_01_position Module Tests")
        print("=" * 60)
        
        self.test_create_position()
        self.test_create_stock_position()
        self.test_create_future_position()
        self.test_position_pnl()
        self.test_position_daily_pnl()
        self.test_position_margin()
        self.test_position_market_value()
        self.test_position_closable()
        self.test_position_apply_trade_open()
        self.test_position_apply_trade_close()
        self.test_position_update_last_price()
        self.test_position_before_trading()
        self.test_position_settlement()
        self.test_position_short_pnl()
        self.test_position_proxy()
        self.test_position_str()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
