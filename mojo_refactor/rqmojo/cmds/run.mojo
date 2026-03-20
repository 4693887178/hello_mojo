"""
RQAlpha Mojo - Run Command
Ported from rqalpha/cmds/run.py
"""

from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, RUN_TYPE_BACKTEST, RUN_TYPE_BACKTEST
from rqmojo.environment import Environment, create_environment
from rqmojo.core.executor import Executor, create_executor
from rqmojo.core.events import EVENT, Event, create_event_bus
from rqmojo.core.strategy import Strategy
from rqmojo.core.strategy_loader import StrategyLoader
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.data.bar_dict_price_board import BarDictPriceBoard
from rqmojo.portfolio.portfolio_manager import Portfolio
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct RunConfig(Movable):
    var strategy_file: String
    var start_date: DateTime
    var end_date: DateTime
    var frequency: String
    var run_type: RUN_TYPE
    var base_port: Int
    var accounts: Dict[String, Float64]
    var init_cash: Float64


fn run_backtest(config: RunConfig) -> Int:
    var env = create_environment(
        start_date=config.start_date,
        end_date=config.end_date,
        run_type=config.run_type
    )
    env.set_data_source("default")
    env.set_broker("simulation")
    env.set_data_proxy(DataProxy(_data_source_name="default", _trading_dates_mixin=TradingDatesMixin()))
    env.set_portfolio(100000.0, config.init_cash)
    
    var event_bus = env.get_event_bus()
    event_bus.publish_event(Event.create(EVENT.POST_SYSTEM_INIT(), env.calendar_dt()))
    
    var executor = create_executor()
    
    event_bus.publish_event(Event.create(EVENT.BEFORE_STRATEGY_RUN(), env.calendar_dt()))
    
    event_bus.publish_event(Event.create(EVENT.POST_STRATEGY_RUN(), env.calendar_dt()))
    
    event_bus.publish_event(Event.create(EVENT.ON_END(), env.calendar_dt()))
    
    return 0


fn run_strategy(strategy_file: String, start_date: DateTime, end_date: DateTime, frequency: String = "1d", init_cash: Float64 = 100000.0) -> Int:
    var config = RunConfig(
        strategy_file=strategy_file,
        start_date=start_date,
        end_date=end_date,
        frequency=frequency,
        run_type=RUN_TYPE_BACKTEST,
        base_port=0,
        accounts=Dict[String, Float64](),
        init_cash=init_cash
    )
    
    return run_backtest(config)
