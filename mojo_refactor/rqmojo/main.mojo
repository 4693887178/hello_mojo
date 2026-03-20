"""
RQAlpha Mojo - Main Entry
Ported from rqalpha/main.py
"""

from collections import Dict, List
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, EXIT_CODE, RUN_TYPE_BACKTEST, RUN_TYPE_BACKTEST
from rqmojo.environment import Environment, create_environment
from rqmojo.core.events import EventBus, EVENT, Event, create_event_bus
from rqmojo.core.executor import Executor, create_executor
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.core.strategy_context import StrategyContext, create_strategy_context
from rqmojo.core.strategy_loader import StrategyLoader, create_file_strategy_loader
from rqmojo.portfolio.portfolio_manager import Portfolio, create_stock_portfolio
from rqmojo.utils.datetime_func import DateTime


@fieldwise_init
struct RQAlphaConfig(Movable):
    var start_date: DateTime
    var end_date: DateTime
    var run_type: RUN_TYPE
    var frequency: String
    var initial_cash: Float64
    var strategy_file: String
    var data_bundle_path: String
    var mod_config: Dict[String, Dict[String, String]]
    
    fn __str__(self) -> String:
        return "RQAlphaConfig(" + self.start_date.__str__() + " to " + self.end_date.__str__() + ")"


@fieldwise_init
struct RQAlpha(Movable):
    var config: RQAlphaConfig
    var _env: Environment
    var _executor: Executor
    var _data_proxy: DataProxy
    
    fn init(mut self) -> None:
        self._env = create_environment(
            start_date=self.config.start_date,
            end_date=self.config.end_date,
            run_type=self.config.run_type
        )
        var dp = create_data_proxy()
        self._env.set_data_proxy(dp^)
        self._data_proxy = create_data_proxy()
        
        self._executor = create_executor()
    
    fn run(mut self) -> Int:
        self.init()
        
        var post_init_event = Event.create(EVENT.POST_SYSTEM_INIT(), self._env.calendar_dt(), "")
        self._env._event_bus.publish(post_init_event)
        
        var before_run_event = Event.create(EVENT.BEFORE_STRATEGY_RUN(), self._env.calendar_dt(), "")
        self._env._event_bus.publish(before_run_event)
        
        var current = self.config.start_date
        while current.year < self.config.end_date.year or (current.year == self.config.end_date.year and current.month < self.config.end_date.month) or (current.year == self.config.end_date.year and current.month == self.config.end_date.month and current.day <= self.config.end_date.day):
            self._env._calendar_dt = current
            
            var before_trading_event = Event.create(EVENT.BEFORE_TRADING(), current, "")
            self._env._event_bus.publish(before_trading_event)
            
            var bar_event = Event.create(EVENT.BAR(), current, "")
            self._env._event_bus.publish(bar_event)
            
            var after_trading_event = Event.create(EVENT.AFTER_TRADING(), current, "")
            self._env._event_bus.publish(after_trading_event)
            
            current = DateTime(current.year, current.month, current.day + 1, 0, 0, 0, 0)
        
        var post_run_event = Event.create(EVENT.POST_STRATEGY_RUN(), self._env.calendar_dt(), "")
        self._env._event_bus.publish(post_run_event)
        
        var on_end_event = Event.create(EVENT.ON_END(), self._env.calendar_dt(), "")
        self._env._event_bus.publish(on_end_event)
        
        return 0
    
    fn get_start_date(self) -> DateTime:
        return self.config.start_date
    
    fn get_end_date(self) -> DateTime:
        return self.config.end_date
    
    fn get_env(ref self) -> ref Environment:
        return self._env


fn create_config(
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64 = 100000.0,
    strategy_file: String = "",
    data_bundle_path: String = "./bundle"
) -> RQAlphaConfig:
    return RQAlphaConfig(
        start_date=start_date,
        end_date=end_date,
        run_type=RUN_TYPE_BACKTEST,
        frequency="1d",
        initial_cash=initial_cash,
        strategy_file=strategy_file,
        data_bundle_path=data_bundle_path,
        mod_config=Dict[String, Dict[String, String]]()
    )


fn create_rqalpha(var config: RQAlphaConfig) -> RQAlpha:
    var start = config.start_date
    var end = config.end_date
    var run_type = config.run_type
    return RQAlpha(
        config=config^,
        _env=create_environment(start, end, run_type),
        _executor=create_executor(),
        _data_proxy=create_data_proxy()
    )


fn run_backtest(start_date: DateTime, end_date: DateTime, initial_cash: Float64 = 100000.0) -> Int:
    var config = create_config(start_date, end_date, initial_cash)
    var rqalpha = create_rqalpha(config^)
    return rqalpha.run()


fn run_strategy(strategy_file: String, start_date: DateTime, end_date: DateTime, initial_cash: Float64 = 100000.0) -> Int:
    var config = create_config(start_date, end_date, initial_cash, strategy_file)
    var rqalpha = create_rqalpha(config^)
    return rqalpha.run()


fn rqalpha_main() -> Int:
    print("=== RQAlpha Mojo ===")
    print("Quantitative Trading Framework in Mojo")
    print("Ported from Python rqalpha")
    print("")
    print("Usage:")
    print("  rqalpha run -f strategy.py -s 2020-01-01 -e 2020-12-31")
    print("  rqalpha bundle update")
    print("  rqalpha mod list")
    return 0
