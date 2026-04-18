"""
RQAlpha Mojo - Run Command
Ported from rqalpha/cmds/run.py
"""

from std.collections import Dict, List, Optional
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, RUN_TYPE_BACKTEST, RUN_TYPE_PAPER_TRADING, RUN_TYPE_LIVE_TRADING
from rqmojo.utils import RqAttrDict
from rqmojo.environment import Environment, create_environment
from rqmojo.core.executor import Executor, create_executor
from rqmojo.core.events import EVENT, Event, create_event_bus
from rqmojo.core.strategy import Strategy
from rqmojo.core.strategy_loader import StrategyLoader
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.data.bar_dict_price_board import BarDictPriceBoard
from rqmojo.data.trading_dates_mixin import TradingDatesMixin, create_trading_dates_mixin
from rqmojo.portfolio.portfolio_manager import Portfolio
from rqmojo.utils.typing import DateTime


@fieldwise_init
struct RunConfig(Movable, Copyable, ImplicitlyCopyable):
    var strategy_file: String
    var start_date: DateTime
    var end_date: DateTime
    var frequency: String
    var run_type: RUN_TYPE
    var base_port: Int
    var accounts: Dict[String, Float64]
    var init_cash: Float64
    var data_bundle_path: String
    var margin_multiplier: Float64
    var init_positions: String
    var round_price: Bool
    var source_code: String
    var rqdatac_uri: String
    var log_level: String
    var locale: String
    var extra_vars: String
    var enable_profiler: Bool
    var config_path: String
    var mod_configs: RqAttrDict
    var resume_mode: Bool


@fieldwise_init
struct CliParam(Movable, Copyable, ImplicitlyCopyable):
    var name: String
    var param_type: String
    var default_value: String
    var help_text: String
    var is_flag: Bool
    var choices: List[String]


def run_backtest(config: RunConfig) -> Int:
    var env = create_environment(
        start_date=config.start_date,
        end_date=config.end_date,
        run_type=config.run_type
    )
    env.set_data_source("default")
    env.set_broker("simulation")
    env.set_data_proxy(create_data_proxy())
    env.set_portfolio(100000.0, config.init_cash)
    
    env.publish_event(Event(event_type=EVENT.POST_SYSTEM_INIT().value))
    
    var executor = create_executor()
    
    env.publish_event(Event(event_type=EVENT.BEFORE_STRATEGY_RUN().value))
    
    env.publish_event(Event(event_type=EVENT.POST_STRATEGY_RUN().value))
    
    return 0


def run_strategy(
    strategy_file: String,
    start_date: DateTime,
    end_date: DateTime,
    frequency: String = "1d",
    init_cash: Float64 = 100000.0
) -> Int:
    var config = RunConfig(
        strategy_file=strategy_file,
        start_date=start_date,
        end_date=end_date,
        frequency=frequency,
        run_type=RUN_TYPE.BACKTEST,
        base_port=0,
        accounts=Dict[String, Float64](),
        init_cash=init_cash,
        data_bundle_path="",
        margin_multiplier=1.0,
        init_positions="",
        round_price=False,
        source_code="",
        rqdatac_uri="",
        log_level="info",
        locale="cn",
        extra_vars="",
        enable_profiler=False,
        config_path="",
        mod_configs=RqAttrDict(),
        resume_mode=False
    )

    return run_backtest(config)


def run_with_config(config: RunConfig) -> Optional[Dict[String, String]]:
    var result_code = run_backtest(config)
    if result_code == 0:
        var results = Dict[String, String]()
        results["status"] = "success"
        return results
    return None


def inject_run_param(param: CliParam, ref params: List[CliParam]) -> None:
    params.append(param)


def create_run_params() -> List[CliParam]:
    var params = List[CliParam]()
    
    params.append(CliParam(
        name="data_bundle_path",
        param_type="path",
        default_value="",
        help_text="data bundle path",
        is_flag=False,
        choices=List[String]()
    ))
    
    params.append(CliParam(
        name="strategy_file",
        param_type="path",
        default_value="",
        help_text="strategy file path",
        is_flag=False,
        choices=List[String]()
    ))
    
    params.append(CliParam(
        name="start_date",
        param_type="date",
        default_value="",
        help_text="backtest start date",
        is_flag=False,
        choices=List[String]()
    ))
    
    params.append(CliParam(
        name="end_date",
        param_type="date",
        default_value="",
        help_text="backtest end date",
        is_flag=False,
        choices=List[String]()
    ))
    
    params.append(CliParam(
        name="frequency",
        param_type="choice",
        default_value="1d",
        help_text="bar frequency",
        is_flag=False,
        choices=["1d", "1m", "tick"]
    ))
    
    params.append(CliParam(
        name="run_type",
        param_type="choice",
        default_value="b",
        help_text="run type: b=backtest, p=paper trading, r=real trading",
        is_flag=False,
        choices=["b", "p", "r"]
    ))
    
    params.append(CliParam(
        name="log_level",
        param_type="choice",
        default_value="info",
        help_text="log level",
        is_flag=False,
        choices=["verbose", "debug", "info", "error", "none"]
    ))
    
    params.append(CliParam(
        name="locale",
        param_type="choice",
        default_value="cn",
        help_text="locale",
        is_flag=False,
        choices=["cn", "en"]
    ))
    
    return params^


def parse_run_type(run_type_str: String) -> RUN_TYPE:
    if run_type_str == "b" or run_type_str == "backtest":
        return RUN_TYPE.BACKTEST
    elif run_type_str == "p" or run_type_str == "paper":
        return RUN_TYPE.PAPER_TRADING
    elif run_type_str == "r" or run_type_str == "live":
        return RUN_TYPE.LIVE_TRADING
    return RUN_TYPE.BACKTEST


def create_run_config_from_dict(params: Dict[String, String]) -> RunConfig:
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var frequency = "1d"
    var run_type = RUN_TYPE.BACKTEST
    var init_cash = 100000.0
    
    try:
        var sd = params["start_date"]
    except:
        pass
    
    try:
        var ed = params["end_date"]
    except:
        pass
    
    try:
        frequency = params["frequency"]
    except:
        pass
    
    try:
        var rt = params["run_type"]
        run_type = parse_run_type(rt)
    except:
        pass
    
    try:
        var cash_str = params["init_cash"]
        init_cash = Float64(cash_str)
    except:
        pass
    
    return RunConfig(
        strategy_file=params.get("strategy_file", ""),
        start_date=start_date,
        end_date=end_date,
        frequency=frequency,
        run_type=run_type,
        base_port=0,
        accounts=Dict[String, Float64](),
        init_cash=init_cash,
        data_bundle_path=params.get("data_bundle_path", ""),
        margin_multiplier=1.0,
        init_positions=params.get("init_positions", ""),
        round_price=False,
        source_code=params.get("source_code", ""),
        rqdatac_uri=params.get("rqdatac_uri", ""),
        log_level=params.get("log_level", "info"),
        locale=params.get("locale", "cn"),
        extra_vars=params.get("extra_vars", ""),
        enable_profiler=False,
        config_path=params.get("config_path", ""),
        mod_configs=RqAttrDict(),
        resume_mode=False
    )
