# test_L08_02_account.mojo
# Module: rqmojo.portfolio.account
# Python: rqalpha/portfolio/account.py
# Level: L08 - Portfolio
# Dependencies: position, trade

from rqmojo.portfolio.account import (
    Account, create_account, create_stock_account, create_future_account
)
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, SIDE, POSITION_EFFECT, POSITION_DIRECTION
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

    fn test_create_account(mut self):
        var acc = create_account(DEFAULT_ACCOUNT_TYPE.STOCK(), 100000.0)
        self.check(acc.account_type == DEFAULT_ACCOUNT_TYPE.STOCK(), "Account account_type")
        self.check(acc.total_cash == 100000.0, "Account total_cash")
        self.check(acc.total_value == 100000.0, "Account total_value")

    fn test_create_stock_account(mut self):
        var acc = create_stock_account(200000.0)
        self.check(acc.account_type == DEFAULT_ACCOUNT_TYPE.STOCK(), "Stock account type")
        self.check(acc.total_cash == 200000.0, "Stock account total_cash")

    fn test_create_future_account(mut self):
        var acc = create_future_account(50000.0)
        self.check(acc.account_type == DEFAULT_ACCOUNT_TYPE.FUTURE(), "Future account type")
        self.check(acc.total_cash == 50000.0, "Future account total_cash")

    fn test_account_available_cash(mut self):
        var acc = create_stock_account(100000.0)
        self.check(acc.available_cash() == 100000.0, "Account available_cash")

    fn test_account_add_cash(mut self):
        var acc = create_stock_account(100000.0)
        acc.add_cash(10000.0)
        self.check(acc.total_cash == 110000.0, "Account total_cash after add_cash")
        self.check(acc.total_value == 110000.0, "Account total_value after add_cash")

    fn test_account_subtract_cash(mut self):
        var acc = create_stock_account(100000.0)
        acc.subtract_cash(5000.0)
        self.check(acc.total_cash == 95000.0, "Account total_cash after subtract_cash")

    fn test_account_get_position(mut self):
        var acc = create_stock_account(100000.0)
        var pos = acc.get_position("000001.XSHE")
        self.check(pos.order_book_id == "000001.XSHE", "Account get_position order_book_id")
        self.check(pos.quantity == 0, "Account get_position quantity is 0")

    fn test_account_get_or_create_position(mut self):
        var acc = create_stock_account(100000.0)
        _ = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG())
        self.check(acc.positions_count == 1, "Account positions_count after create")

    fn test_account_update_last_price(mut self):
        var acc = create_stock_account(100000.0)
        var pos = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG())
        pos.quantity = 100
        pos.avg_price = 10.0
        acc.update_last_price("000001.XSHE", 11.0)
        self.check(pos.last_price == 11.0, "Account position last_price after update")

    fn test_account_update_positions_value(mut self):
        var acc = create_stock_account(100000.0)
        var pos = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG())
        pos.quantity = 100
        pos.avg_price = 10.0
        pos.update_last_price(11.0)
        acc.update_positions_value()
        self.check(acc.total_value == 111000.0, "Account total_value after update_positions_value")

    fn test_account_get_positions(mut self):
        var acc = create_stock_account(100000.0)
        _ = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG())
        _ = acc.get_or_create_position("000002.XSHE", POSITION_DIRECTION.LONG())
        var positions = acc.get_positions()
        self.check(len(positions) == 2, "Account get_positions count")

    fn test_account_settlement(mut self):
        var acc = create_stock_account(100000.0)
        var pos = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG())
        pos.quantity = 100
        pos.today_quantity = 50
        acc.settlement()
        self.check(pos.old_quantity == 100, "Account position old_quantity after settlement")
        self.check(pos.today_quantity == 0, "Account position today_quantity after settlement")

    fn test_account_str(mut self):
        var acc = create_stock_account(100000.0)
        var result = acc.__str__()
        self.check(len(result) > 0, "Account __str__ returns non-empty")

    fn run_all(mut self):
        print("=" * 60)
        print("L08_02_account Module Tests")
        print("=" * 60)
        
        self.test_create_account()
        self.test_create_stock_account()
        self.test_create_future_account()
        self.test_account_available_cash()
        self.test_account_add_cash()
        self.test_account_subtract_cash()
        self.test_account_get_position()
        self.test_account_get_or_create_position()
        self.test_account_update_last_price()
        self.test_account_update_positions_value()
        self.test_account_get_positions()
        self.test_account_settlement()
        self.test_account_str()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
