"""
Test for environment.mojo - Environment module
"""

from rqmojo.const import RUN_TYPE, DEFAULT_ACCOUNT_TYPE, INSTRUMENT_TYPE, MARKET, SIDE
from rqmojo.utils.datetime_func import DateTime
from rqmojo.environment import Environment, create_environment, Config, GlobalVars, FrontendValidator, TransactionCostDecider
from rqmojo.core.events import EVENT, Event, EventBus


fn test_global_vars():
    print("=== Testing GlobalVars ===")
    var gv = GlobalVars(data_string="test_data")
    print("GlobalVars: " + gv.__str__())
    print("get('key'): " + gv.get("key", "default_value"))
    gv.set("new_key", "new_value")
    print("contains('new_key'): " + String(gv.contains("new_key")))
    print("")


fn test_frontend_validator():
    print("=== Testing FrontendValidator ===")
    var validator = FrontendValidator(name="test_validator", instrument_type=INSTRUMENT_TYPE.CS)
    print("FrontendValidator: " + validator.__str__())
    print("")


fn test_transaction_cost_decider():
    print("=== Testing TransactionCostDecider ===")
    var decider = TransactionCostDecider(name="stock_decider", instrument_type=INSTRUMENT_TYPE.CS, market=MARKET.CN)
    print("TransactionCostDecider: " + decider.__str__())
    print("")


fn test_create_environment():
    print("=== Testing create_environment ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date, RUN_TYPE.BACKTEST)
    
    print("start_date: " + env.start_date().__str__())
    print("end_date: " + env.end_date().__str__())
    print("run_type: " + env.run_type().__str__())
    print("frequency: " + env.frequency())
    print("is_initialized: " + String(env.is_initialized()))
    print("")


fn test_environment_config():
    print("=== Testing Environment.config ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    var config = env.config()
    
    print("Config created successfully")
    print("")


fn test_environment_time():
    print("=== Testing Environment time functions ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    
    print("calendar_dt: " + env.calendar_dt().__str__())
    print("trading_dt: " + env.trading_dt().__str__())
    
    var new_dt = DateTime(2024, 6, 15, 9, 30, 0, 0)
    env.update_time(new_dt, new_dt)
    
    print("After update_time:")
    print("calendar_dt: " + env.calendar_dt().__str__())
    print("trading_dt: " + env.trading_dt().__str__())
    print("")


fn test_environment_initialized():
    print("=== Testing Environment initialization ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    print("is_initialized (before): " + String(env.is_initialized()))
    
    env.set_initialized(True)
    print("is_initialized (after): " + String(env.is_initialized()))
    print("")


fn test_environment_hold_strategy():
    print("=== Testing Environment hold strategy ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    print("is_hold (before): " + String(env.config().is_hold))
    
    env.set_hold_strategy()
    print("is_hold (after set_hold_strategy): " + String(env.config().is_hold))
    
    env.cancel_hold_strategy()
    print("is_hold (after cancel_hold_strategy): " + String(env.config().is_hold))
    print("")


fn test_environment_universe():
    print("=== Testing Environment universe ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    var universe = env.get_universe()
    print("Universe size: " + String(universe.__len__()))
    
    universe.add("000001.XSHE")
    universe.add("600000.XSHG")
    env.update_universe(universe^)
    
    var updated_universe = env.get_universe()
    print("Updated universe size: " + String(updated_universe.__len__()))
    print("")


fn test_environment_transaction_cost_decider():
    print("=== Testing Environment transaction cost decider ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    
    var decider = TransactionCostDecider(name="stock_decider", instrument_type=INSTRUMENT_TYPE.CS, market=MARKET.CN)
    env.set_transaction_cost_decider(INSTRUMENT_TYPE.CS, decider, MARKET.CN)
    
    var retrieved = env.get_transaction_cost_decider(INSTRUMENT_TYPE.CS, MARKET.CN)
    print("Retrieved decider: " + retrieved.__str__())
    print("")


fn test_environment_account_type():
    print("=== Testing Environment account type ===")
    var start_date = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2024, 12, 31, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    var account_type = env.get_account_type("000001.XSHE")
    print("Account type: " + account_type.__str__())
    print("")


fn main():
    print("=" * 60)
    print("RQAlpha Mojo environment.mojo Test")
    print("=" * 60)
    print("")
    
    test_global_vars()
    test_frontend_validator()
    test_transaction_cost_decider()
    test_create_environment()
    test_environment_config()
    test_environment_time()
    test_environment_initialized()
    test_environment_hold_strategy()
    test_environment_universe()
    test_environment_transaction_cost_decider()
    test_environment_account_type()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
