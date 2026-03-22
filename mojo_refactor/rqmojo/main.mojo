"""
RQAlpha Mojo - Main Entry
Ported from rqalpha/main.py
"""

from std.collections import Dict, List
from std.python import Python, PythonObject
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, EXIT_CODE, PERSIST_MODE
from rqmojo.environment import Environment, create_environment_from_config
from rqmojo.core.events import EVENT, Event, EventBus, create_event_bus
from rqmojo.core.executor import Executor, create_executor
from rqmojo.core.execution_context import ExecutionContext, ContextStack
from rqmojo.core.strategy import BaseStrategy, create_base_strategy
from rqmojo.core.strategy_context import StrategyContext, create_strategy_context
from rqmojo.core.strategy_loader import (
    FileStrategyLoader, SourceCodeStrategyLoader, UserFuncStrategyLoader,
    create_file_strategy_loader, create_source_code_strategy_loader, create_user_func_strategy_loader
)
from rqmojo.core.strategy_universe import StrategyUniverse
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.data.base_data_source import BaseDataSource, create_base_data_source_with_path
from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board
from rqmojo.model.bar import BarMap, BarObject, create_bar_map
from rqmojo.model.instrument import Instrument
from rqmojo.model.order import Order
from rqmojo.model.trade import Trade
from rqmojo.interface import Persistable
from rqmojo.mod import ModHandler, create_mod_handler
from rqmojo.portfolio import Portfolio, create_portfolio, create_stock_portfolio
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.utils.exception import CustomError, is_user_exc
from rqmojo.utils.i18n import gettext
from rqmojo.utils.logger import user_log, system_log, user_system_log, init_logger
from rqmojo.utils.log_capture import LogCapture, create_log_capture
from rqmojo.utils.persist_helper import PersistHelper, PersistProvider, create_memory_persist_provider
from rqmojo.utils.config import RQAlphaConfig, BaseConfig, ExtraConfig, ModConfig, parse_config
from rqmojo.utils import RqAttrDict, RqValue


comptime RUN_TYPE_BACKTEST_VAL: RUN_TYPE = RUN_TYPE.BACKTEST


@fieldwise_init
struct RunResult(Movable, Writable):
    var exit_code: EXIT_CODE
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("RunResult(code=", self.exit_code.name(), ")")


def create_config(
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64 = 100000.0,
    strategy_file: String = "",
    data_bundle_path: String = "~/.rqalpha/bundle",
    frequency: String = "1d",
    persist_mode: PERSIST_MODE = PERSIST_MODE.ON_CRASH,
    rqdatac_uri: String = ""
) -> RQAlphaConfig:
    var base_cfg = BaseConfig(
        start_date=start_date,
        end_date=end_date,
        frequency=frequency,
        run_type=RUN_TYPE.BACKTEST,
        data_bundle_path=data_bundle_path,
        strategy_file=strategy_file,
        persist_mode=persist_mode,
        initial_cash=initial_cash,
        rqdatac_uri=rqdatac_uri
    )
    var extra_cfg = ExtraConfig(locale="zh_CN", context_vars="", is_hold=False)
    var mod_cfg = ModConfig(enabled=True)
    return RQAlphaConfig(base=base_cfg, extra=extra_cfg, mod=mod_cfg)


def create_base_scope() -> Dict[String, String]:
    var scope = Dict[String, String]()
    scope["__name__"] = "rqmojo.user_module"
    return scope^


def get_strategy_apis() -> Dict[String, String]:
    var apis = Dict[String, String]()
    apis["order_shares"] = "order_shares"
    apis["order_percent"] = "order_percent"
    apis["order_target_value"] = "order_target_value"
    apis["cancel_order"] = "cancel_order"
    apis["update_universe"] = "update_universe"
    apis["subscribe"] = "subscribe"
    apis["unsubscribe"] = "unsubscribe"
    return apis^


def init_rqdatac(rqdatac_uri: String) -> Bool:
    if rqdatac_uri == "disabled" or rqdatac_uri == "DISABLED":
        return False
    return False


def set_loggers() -> None:
    init_logger()


def _exception_handler(e: CustomError) -> EXIT_CODE:
    user_system_log().exception(gettext("strategy execute exception"))
    user_system_log().error(e.msg)
    
    if not is_user_exc(e.error_type):
        return EXIT_CODE.EXIT_INTERNAL_ERROR
    
    return EXIT_CODE.EXIT_USER_ERROR


def run(
    mut config: RQAlphaConfig,
    source_code: String = "",
    user_funcs: Dict[String, String] = Dict[String, String]()
) raises -> RunResult:
    var rqdatac_initialized = init_rqdatac(config.base.rqdatac_uri)
    var env = create_environment_from_config(config, rqdatac_initialized)
    var mod_handler = create_mod_handler()
    
    try:
        set_loggers()
        system_log().debug("Config: " + config.__str__())
        
        mod_handler.set_env("backtest")
        mod_handler.start_up()
        
        var data_proxy = create_data_proxy()
        env.set_data_proxy(data_proxy^)
        
        var start_dt = DateTime(config.base.start_date.year, config.base.start_date.month, config.base.start_date.day, 0, 0, 0, 0)
        env.set_calendar_dt(start_dt)
        env.set_trading_dt(start_dt)
        
        env.set_portfolio(config.base.initial_cash, config.base.initial_cash)
        
        var post_init_evt = EVENT.POST_SYSTEM_INIT()
        var post_init_event = Event(post_init_evt.value)
        env.publish_event(post_init_event)
        
        var scope = create_base_scope()
        scope["g"] = "global_vars"
        
        var apis = get_strategy_apis()
        var api_keys = List[String]()
        for key in apis.keys():
            api_keys.append(key)
        for key in api_keys:
            try:
                var val = apis[key]
                scope[key] = val
            except:
                pass
        
        var executor = create_executor()
        
        var before_run_evt = EVENT.BEFORE_STRATEGY_RUN()
        var before_run_event = Event(before_run_evt.value)
        env.publish_event(before_run_event)
        
        var bar_dict = create_bar_map(config.base.frequency)
        executor.run()
        
        var post_run_evt = EVENT.POST_STRATEGY_RUN()
        var post_run_event = Event(post_run_evt.value)
        env.publish_event(post_run_event)
        
        var result = mod_handler.tear_down(EXIT_CODE.EXIT_SUCCESS)
        system_log().debug(gettext("strategy run successfully, normal exit"))
        
        return RunResult(
            exit_code=EXIT_CODE.EXIT_SUCCESS,
            message="Success"
        )
        
    except e:
        var custom_error = CustomError.create(String(e), "Exception")
        var code = _exception_handler(custom_error)
        mod_handler.tear_down(code, custom_error)
        
        return RunResult(
            exit_code=code,
            message=String(e)
        )


def run_backtest(
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64 = 100000.0
) raises -> RunResult:
    var config = create_config(start_date, end_date, initial_cash)
    return run(config)


def run_strategy(
    strategy_file: String,
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64 = 100000.0
) raises -> RunResult:
    var config = create_config(start_date, end_date, initial_cash, strategy_file)
    return run(config)


def run_code(
    code: String,
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64 = 100000.0
) raises -> RunResult:
    var config = create_config(start_date, end_date, initial_cash)
    return run(config, source_code=code)


def rqalpha_main() -> None:
    print("=== RQAlpha Mojo ===")
    print("Quantitative Trading Framework in Mojo")
    print("Ported from Python rqalpha")
    print("")
    print("Usage:")
    print("  rqalpha run -f strategy.py -s 2020-01-01 -e 2020-12-31")
    print("  rqalpha bundle update")
    print("  rqalpha mod list")


def main() -> None:
    rqalpha_main()
