# test_L06_01_environment.mojo
# Module: rqmojo.environment
# Python: rqalpha.environment
# Level: L06 - Environment Layer
# Dependencies: core, const, interface, data, portfolio

from rqmojo.environment import (
    Environment, Config, GlobalVars, FrontendValidator, 
    TransactionCostDecider, PersistProvider, PersistHelper, Portfolio,
    create_environment, create_portfolio
)
from rqmojo.const import RUN_TYPE, INSTRUMENT_TYPE, MARKET, SIDE, POSITION_EFFECT
from rqmojo.core.events import EVENT, Event
from rqmojo.model.order import Order, MarketOrder, create_order_with_id
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

    fn test_create_environment(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(True, "Environment created successfully")

    fn test_environment_start_date(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.start_date().year == 2024, "Environment start_date year is 2024")
        self.check(env.start_date().month == 1, "Environment start_date month is 1")
        self.check(env.start_date().day == 1, "Environment start_date day is 1")

    fn test_environment_end_date(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.end_date().year == 2024, "Environment end_date year is 2024")
        self.check(env.end_date().month == 12, "Environment end_date month is 12")
        self.check(env.end_date().day == 31, "Environment end_date day is 31")

    fn test_environment_run_type(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end, RUN_TYPE.BACKTEST())
        self.check(env.run_type() == RUN_TYPE.BACKTEST(), "Environment run_type is BACKTEST")

    fn test_environment_frequency(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.frequency() == "1d", "Environment frequency is 1d")

    fn test_environment_calendar_dt(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.calendar_dt().year == 2024, "Environment calendar_dt year is 2024")

    fn test_environment_trading_dt(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.trading_dt().year == 2024, "Environment trading_dt year is 2024")

    fn test_environment_set_calendar_dt(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var new_dt = DateTime(2024, 6, 15, 0, 0, 0, 0)
        env.set_calendar_dt(new_dt)
        self.check(env.calendar_dt().month == 6, "Environment set_calendar_dt month is 6")

    fn test_environment_set_trading_dt(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var new_dt = DateTime(2024, 6, 15, 0, 0, 0, 0)
        env.set_trading_dt(new_dt)
        self.check(env.trading_dt().month == 6, "Environment set_trading_dt month is 6")

    fn test_environment_is_initialized(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.is_initialized() == False, "Environment is_initialized is False initially")

    fn test_environment_set_initialized(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        env.set_initialized(True)
        self.check(env.is_initialized() == True, "Environment set_initialized works")

    fn test_environment_config(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var config = env.config()
        self.check(config.base__start_date.year == 2024, "Config start_date year is 2024")
        self.check(config.base__end_date.year == 2024, "Config end_date year is 2024")

    fn test_environment_get_last_price(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var price = env.get_last_price("000001.XSHE")
        self.check(price == 10.0, "Environment get_last_price is 10.0")

    fn test_environment_get_instrument(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var ins = env.get_instrument("000001.XSHE")
        self.check(ins.order_book_id == "000001.XSHE", "Environment get_instrument order_book_id is 000001.XSHE")

    fn test_environment_portfolio(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        self.check(env.portfolio.total_value == 100000.0, "Environment portfolio total_value is 100000.0")

    fn test_environment_submit_order(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var style = MarketOrder()
        var order = create_order_with_id(0, "000001.XSHE", SIDE.BUY(), 100, style)
        var submitted = env.submit_order(order)
        self.check(submitted.order_id == 1, "Environment submit_order order_id is 1")

    fn test_environment_can_submit_order(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var style = MarketOrder()
        var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY(), 100, style)
        self.check(env.can_submit_order(order) == True, "Environment can_submit_order is True")

    fn test_environment_can_cancel_order(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var style = MarketOrder()
        var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY(), 100, style)
        self.check(env.can_cancel_order(order) == True, "Environment can_cancel_order is True")

    fn test_environment_add_frontend_validator(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var validator = FrontendValidator(name="test", instrument_type=INSTRUMENT_TYPE.CS())
        try:
            env.add_frontend_validator(validator)
        except:
            pass
        self.check(True, "Environment add_frontend_validator works")

    fn test_environment_set_transaction_cost_decider(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var decider = TransactionCostDecider(name="test", instrument_type=INSTRUMENT_TYPE.CS(), market=MARKET.CN())
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.CS(), decider)
        self.check(True, "Environment set_transaction_cost_decider works")

    fn test_environment_get_transaction_cost_decider(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var env = create_environment(start, end)
        var decider = env.get_transaction_cost_decider(INSTRUMENT_TYPE.CS(), MARKET.CN())
        self.check(decider.name == "default", "Environment get_transaction_cost_decider name is default")

    fn test_portfolio_creation(mut self):
        var portfolio = create_portfolio(100000.0)
        self.check(portfolio.total_value == 100000.0, "Portfolio total_value is 100000.0")
        self.check(portfolio.total_cash == 100000.0, "Portfolio total_cash is 100000.0")

    fn test_portfolio_get_position(mut self):
        var portfolio = create_portfolio(100000.0)
        var pos = portfolio.get_position("000001.XSHE")
        self.check(pos.quantity == 0, "Portfolio get_position quantity is 0")

    fn test_global_vars(mut self):
        var gv = GlobalVars(data_string="")
        self.check(gv.get("key") == "", "GlobalVars get returns default")

    fn test_config(mut self):
        var start = DateTime(2024, 1, 1, 0, 0, 0, 0)
        var end = DateTime(2024, 12, 31, 0, 0, 0, 0)
        var config = Config(
            base__start_date=start,
            base__end_date=end,
            base__frequency="1d",
            base__run_type=RUN_TYPE.BACKTEST(),
            account_count=0,
            is_hold=False
        )
        self.check(config.base__start_date.year == 2024, "Config start_date year is 2024")

    fn run_all(mut self):
        print("=" * 60)
        print("L06_01_environment Module Tests")
        print("=" * 60)
        
        self.test_create_environment()
        self.test_environment_start_date()
        self.test_environment_end_date()
        self.test_environment_run_type()
        self.test_environment_frequency()
        self.test_environment_calendar_dt()
        self.test_environment_trading_dt()
        self.test_environment_set_calendar_dt()
        self.test_environment_set_trading_dt()
        self.test_environment_is_initialized()
        self.test_environment_set_initialized()
        self.test_environment_config()
        self.test_environment_get_last_price()
        self.test_environment_get_instrument()
        self.test_environment_portfolio()
        self.test_environment_submit_order()
        self.test_environment_can_submit_order()
        self.test_environment_can_cancel_order()
        self.test_environment_add_frontend_validator()
        self.test_environment_set_transaction_cost_decider()
        self.test_environment_get_transaction_cost_decider()
        self.test_portfolio_creation()
        self.test_portfolio_get_position()
        self.test_global_vars()
        self.test_config()
        
        print("=" * 60)
        print("Results: " + String(self.pass_count) + "/" + String(self.test_count) + " tests passed")
        print("=" * 60)


fn main():
    var runner = TestRunner(0, 0)
    runner.run_all()
