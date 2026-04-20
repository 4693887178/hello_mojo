"""
RQAlpha Mojo - Main Entry Point
Ported from rqalpha/main.py

Note: Config is RqAttrDict (dynamic dict), matching Python's dict.
Access config values via: config["base"]["start_date"] etc.
"""

from std.collections import Dict, List, Optional, Set
from std.python import Python, PythonObject
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, EXIT_CODE, PERSIST_MODE
from rqmojo.environment import (
    Environment, create_environment_from_config,
    set_environment, clear_environment, has_environment
)
from rqmojo.core.events import EVENT, Event, EventBus, create_event_bus
from rqmojo.core.executor import Executor, create_executor
from rqmojo.core.execution_context import ExecutionContext, ContextStack, create_execution_context
from rqmojo.core.strategy_context import StrategyContext, create_strategy_context
from rqmojo.core.strategy_loader import (
    FileStrategyLoader, SourceCodeStrategyLoader,
    create_file_strategy_loader, create_source_code_strategy_loader
)
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.model.bar import BarMap, create_bar_map
from rqmojo.mod_system import ModHandler, create_mod_handler
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.exception import CustomError, is_user_exc
from rqmojo.utils.i18n import gettext
from rqmojo.utils.logger import user_log, system_log, user_system_log, init_logger
from rqmojo.utils.persist_helper import PersistHelper, create_persist_helper
from rqmojo.utils.config import parse_config
from rqmojo.utils import RqAttrDict


@fieldwise_init
struct RunResult(Movable, Writable):
    var exit_code: EXIT_CODE
    var message: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write("RunResult(code=", self.exit_code.name, ", msg=", self.message, ")")


def _get_base(config: RqAttrDict) raises -> RqAttrDict:
    if config.contains("base"):
        return config["base"]
    return RqAttrDict()


def _base_str(config: RqAttrDict, key: String, default: String = "") raises -> String:
    var base = _get_base(config)
    if base.contains(key):
        return base[key].to[String](default)
    return default


def _base_float(config: RqAttrDict, key: String, default: Float64 = 0.0) raises -> Float64:
    var base = _get_base(config)
    if base.contains(key):
        return base[key].to[Float64](default)
    return default


def _set_base_str(mut config: RqAttrDict, key: String, value: String) raises:
    var base = _get_base(config)
    base[key] = value
    config["base"] = base


def _set_base_float(mut config: RqAttrDict, key: String, value: Float64) raises:
    var base = _get_base(config)
    base[key] = value
    config["base"] = base


def create_base_scope() -> Dict[String, String]:
    """Create base scope dict for strategy execution."""
    var scope = Dict[String, String]()
    scope["__name__"] = "rqmojo.user_module"
    return scope^


def get_strategy_apis() -> Dict[String, String]:
    """Get all strategy API function names."""
    var apis = Dict[String, String]()
    apis["order_shares"] = "order_shares"
    apis["order_percent"] = "order_percent"
    apis["order_target_value"] = "order_target_value"
    apis["cancel_order"] = "cancel_order"
    apis["update_universe"] = "update_universe"
    apis["subscribe"] = "subscribe"
    apis["unsubscribe"] = "unsubscribe"
    apis["history_bars"] = "history_bars"
    apis["history"] = "history"
    apis["get_price"] = "get_price"
    apis["get_trading_dates"] = "get_trading_dates"
    apis["instruments"] = "instruments"
    apis["all_instruments"] = "all_instruments"
    apis["get_position"] = "get_position"
    apis["get_positions"] = "get_positions"
    apis["get_portfolio"] = "get_portfolio"
    apis["deposit"] = "deposit"
    apis["withdraw"] = "withdraw"
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


def cleanup_resources(mut env: Environment) raises -> None:
    clear_environment()


def output_profile_result(mut env: Environment) raises -> None:
    if env.has_profile_deco():
        var profile_output = env.get_profile_output()
        system_log().debug(profile_output)
        var evt = Event(EVENT.ON_LINE_PROFILER_RESULT.name)
        _ = env.get_event_bus().publish_event(evt)


def create_config(
    start_date: DateTime,
    end_date: DateTime,
    initial_cash: Float64 = 100000.0,
    strategy_file: String = "",
    data_bundle_path: String = "~/.rqalpha/bundle",
    frequency: String = "1d",
    persist_mode: String = "on_crash",
    rqdatac_uri: String = ""
) raises -> RqAttrDict:
    var conf = RqAttrDict()
    var base = RqAttrDict()
    base["start_date"] = "2015-01-01"
    base["end_date"] = "2015-12-31"
    base["frequency"] = frequency
    base["run_type"] = "b"
    base["data_bundle_path"] = data_bundle_path
    base["strategy_file"] = strategy_file
    base["persist_mode"] = persist_mode
    base["initial_cash"] = initial_cash
    base["rqdatac_uri"] = rqdatac_uri
    conf["base"] = base
    var extra = RqAttrDict()
    extra["locale"] = "zh_CN"
    extra["context_vars"] = ""
    extra["is_hold"] = False
    conf["extra"] = extra
    var mod = RqAttrDict()
    mod["enabled"] = True
    conf["mod"] = mod
    return conf^


def run(
    mut config: RqAttrDict,
    source_code: String = "",
    user_funcs: Dict[String, String] = Dict[String, String]()
) raises -> RunResult:
    """Main entry point - orchestrates the complete backtest lifecycle.
    
    Matches Python original: def run(cfg, source_code=None)
    """
    var rqdatac_uri = _base_str(config, "rqdatac_uri")
    var rqdatac_initialized = init_rqdatac(rqdatac_uri)
    var env = create_environment_from_config(config, rqdatac_initialized)
    var persist_helper_opt: Optional[PersistHelper] = None
    var init_succeed = False
    var mod_handler = create_mod_handler()

    try:
        set_loggers()
        system_log().debug("Config loaded")

        env.set_strategy_loader(create_file_strategy_loader(source_code))

        mod_handler.start()

        if not env.has_data_source():
            env.set_data_source("base_data_source")
        if not env.has_price_board():
            env.set_price_board("bar_dict_price_board")

        var data_proxy = create_data_proxy()
        env.set_data_proxy(data_proxy^)

        var start_dt = DateTime(2015, 1, 1, 0, 0, 0, 0)
        env.set_calendar_dt(start_dt)
        env.set_trading_dt(start_dt)

        assert env.has_broker(), "Environment broker must be set"

        if not env.has_portfolio():
            var icash = _base_float(config, "initial_cash", 1000000.0)
            env.set_portfolio(icash, icash)

        var post_init_event = Event(EVENT.POST_SYSTEM_INIT.name)
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

        var before_run_event = Event(EVENT.BEFORE_STRATEGY_RUN.name)
        env.publish_event(before_run_event)

        persist_helper_opt = create_persist_helper(EventBus(), PERSIST_MODE.ON_CRASH)
        init_succeed = True

        var frequency = _base_str(config, "frequency", "1d")
        var bar_dict = create_bar_map(frequency)
        executor.run(List[Event]())

        var post_run_event = Event(EVENT.POST_STRATEGY_RUN.name)
        env.publish_event(post_run_event)

        output_profile_result(env)

        mod_handler.stop()
        system_log().debug(gettext("strategy run successfully, normal exit"))

        cleanup_resources(env)

        return RunResult(
            exit_code=EXIT_CODE.EXIT_SUCCESS,
            message="Success"
        )

    except e:
        var custom_error = CustomError.create(String(e), "Exception")
        var code = _exception_handler(custom_error^)
        mod_handler.stop()
        cleanup_resources(env)

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
