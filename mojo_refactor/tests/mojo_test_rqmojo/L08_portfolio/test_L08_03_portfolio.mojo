# test_L08_03_portfolio.mojo
# Module: rqmojo.portfolio.portfolio_manager
# Python: rqalpha/portfolio/portfolio.py
# Level: L08 - Portfolio
# Dependencies: account, position

from rqmojo.portfolio.portfolio_manager import (
    Portfolio, create_portfolio, create_stock_portfolio
)
from rqmojo.const import DEFAULT_ACCOUNT_TYPE, SIDE, POSITION_EFFECT, POSITION_DIRECTION
from rqmojo.model.trade import Trade, create_trade_from_order
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

    fn test_create_portfolio(mut self):
        var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
        var portfolio = create_portfolio(start_date, 100000.0)
        self.check(portfolio.total_value == 100000.0, "Portfolio total_value")
        self.check(portfolio.cash == 100000.0, "Portfolio cash")

    fn test_create_stock_portfolio(mut self):
        var portfolio = create_stock_portfolio(200000.0)
        self.check(portfolio.total_value == 200000.0, "Stock portfolio total_value")
        self.check(portfolio.cash == 200000.0, "Stock portfolio cash")

    fn test_portfolio_get_account(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var acc = portfolio.get_account()
        self.check(acc.account_type == DEFAULT_ACCOUNT_TYPE.STOCK, "Portfolio get_account type")
        self.check(acc.total_cash == 100000.0, "Portfolio get_account total_cash")

    fn test_portfolio_stock_account(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var acc = portfolio.stock_account()
        self.check(acc.account_type == DEFAULT_ACCOUNT_TYPE.STOCK, "Portfolio stock_account type")

    fn test_portfolio_future_account(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var acc = portfolio.future_account()
        self.check(acc.account_type == DEFAULT_ACCOUNT_TYPE.FUTURE, "Portfolio future_account type")

    fn test_portfolio_get_position(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var pos = portfolio.get_position("000001.XSHE")
        self.check(pos.order_book_id == "000001.XSHE", "Portfolio get_position order_book_id")
        self.check(pos.quantity == 0, "Portfolio get_position quantity is 0")

    fn test_portfolio_get_positions(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var positions = portfolio.get_positions()
        self.check(len(positions) == 0, "Portfolio get_positions empty initially")

    fn test_portfolio_apply_trade(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var trade = create_trade_from_order(
            trade_id=1,
            order_id=1,
            order_book_id="000001.XSHE",
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            position_direction=POSITION_DIRECTION.LONG,
            quantity=100,
            price=10.0
        )
        portfolio.apply_trade(trade)
        var pos = portfolio.get_position("000001.XSHE")
        self.check(pos.quantity == 100, "Portfolio position quantity after apply_trade")

    fn test_portfolio_update_last_price(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var trade = create_trade_from_order(
            trade_id=1,
            order_id=1,
            order_book_id="000001.XSHE",
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            position_direction=POSITION_DIRECTION.LONG,
            quantity=100,
            price=10.0
        )
        portfolio.apply_trade(trade)
        portfolio.update_last_price("000001.XSHE", 11.0)
        var pos = portfolio.get_position("000001.XSHE")
        self.check(pos.last_price == 11.0, "Portfolio position last_price after update")

    fn test_portfolio_update_portfolio(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var trade = create_trade_from_order(
            trade_id=1,
            order_id=1,
            order_book_id="000001.XSHE",
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            position_direction=POSITION_DIRECTION.LONG,
            quantity=100,
            price=10.0
        )
        portfolio.apply_trade(trade)
        portfolio.update_last_price("000001.XSHE", 11.0)
        portfolio.update_portfolio()
        self.check(portfolio.total_value == 101000.0, "Portfolio total_value after update")

    fn test_portfolio_positions_value(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var trade = create_trade_from_order(
            trade_id=1,
            order_id=1,
            order_book_id="000001.XSHE",
            side=SIDE.BUY,
            position_effect=POSITION_EFFECT.OPEN,
            position_direction=POSITION_DIRECTION.LONG,
            quantity=100,
            price=10.0
        )
        portfolio.apply_trade(trade)
        portfolio.update_last_price("000001.XSHE", 11.0)
        var pos_value = portfolio.positions_value()
        self.check(pos_value == 1100.0, "Portfolio positions_value")

    fn test_portfolio_start_date(mut self):
        var start_date = DateTime(2020, 6, 15, 0, 0, 0, 0)
        var portfolio = create_portfolio(start_date, 100000.0)
        self.check(portfolio.start_date().year == 2020, "Portfolio start_date year")
        self.check(portfolio.start_date().month == 6, "Portfolio start_date month")

    fn test_portfolio_units(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        self.check(portfolio.units() == 1.0, "Portfolio units")

    fn test_portfolio_static_unit_net_value(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        self.check(portfolio.static_unit_net_value == 1.0, "Portfolio static_unit_net_value")

    fn test_portfolio_str(mut self):
        var portfolio = create_stock_portfolio(100000.0)
        var result = portfolio.__str__()
        self.check(len(result) > 0, "Portfolio __str__ returns non-empty")

    fn run_all(mut self):
        print("=" * 60)
        print("L08_03_portfolio Module Tests")
        print("=" * 60)
        
        self.test_create_portfolio()
        self.test_create_stock_portfolio()
        self.test_portfolio_get_account()
        self.test_portfolio_stock_account()
        self.test_portfolio_future_account()
        self.test_portfolio_get_position()
        self.test_portfolio_get_positions()
        self.test_portfolio_apply_trade()
        self.test_portfolio_update_last_price()
        self.test_portfolio_update_portfolio()
        self.test_portfolio_positions_value()
        self.test_portfolio_start_date()
        self.test_portfolio_units()
        self.test_portfolio_static_unit_net_value()
        self.test_portfolio_str()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
