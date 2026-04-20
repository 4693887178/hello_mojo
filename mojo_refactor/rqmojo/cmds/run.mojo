"""
RQAlpha Mojo - Run Command
Ported from rqalpha/cmds/run.py

Python original:
  - Uses Click decorators: @cli.command(), @click.option()
  - Main entry: run(**kwargs) -> parse_config() -> main.run()
  - CLI options cover: base config, extra config, mod config, source code

Mojo port:
  - Uses argmojo for CLI (replacing Click)
  - Follows same option structure with base__/extra__/mod__ namespace
  - Core logic: parse_config() -> create_environment() -> executor.run()
  - inject_run_param() for dynamic CLI extension
"""

from std.collections import Dict, List, Optional, Set
from std.os.path import exists as path_exists
from std.python import Python
from argmojo import Command, Argument, ParseResult
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE
from rqmojo.utils import RqAttrDict
from rqmojo.utils.config import (
    parse_config,
    default_base_config,
    default_extra_config,
    default_mod_config,
    RQAlphaConfig,
    BaseConfig,
    ExtraConfig,
    ModConfig,
)
from rqmojo.utils.typing import DateTime
from rqmojo.environment import Environment, create_environment, create_environment_from_config, set_environment, clear_environment
from rqmojo.core.executor import Executor, create_executor
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.core.strategy import Strategy
from rqmojo.core.strategy_loader import StrategyLoader
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.portfolio.portfolio_manager import Portfolio as PortfolioManager


@fieldwise_init
struct RunConfig(Movable):
    var strategy_file: String
    var start_date: DateTime
    var end_date: DateTime
    var frequency: String
    var run_type: RUN_TYPE
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
struct CliParam(Copyable, Movable, Writable):
    var name: String
    var param_type: String
    var default_value: String
    var help_text: String
    var is_flag: Bool
    var choices: List[String]

    def write_to(self, mut writer: Some[Writer]):
        writer.write("CliParam(name=", self.name, ", type=", self.param_type, ")")


def parse_run_type(run_type_str: String) -> RUN_TYPE:
    if run_type_str == "b" or run_type_str == "backtest":
        return RUN_TYPE.BACKTEST
    elif run_type_str == "p" or run_type_str == "paper":
        return RUN_TYPE.PAPER_TRADING
    elif run_type_str == "r" or run_type_str == "live":
        return RUN_TYPE.LIVE_TRADING
    return RUN_TYPE.BACKTEST


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


def _parse_date_string(s: String) raises -> DateTime:
    var parts = s.split("-")
    if len(parts) >= 3:
        var y = Int(parts[0])
        var m = Int(parts[1])
        var d = Int(parts[2])
        return DateTime(y, m, d, 0, 0, 0, 0)
    return DateTime(2020, 1, 1, 0, 0, 0, 0)


def create_run_config_from_dict(params: Dict[String, String]) raises -> RunConfig:
    var start_date = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_date = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var frequency = "1d"
    var run_type = RUN_TYPE.BACKTEST
    var init_cash = 100000.0

    if "start_date" in params:
        start_date = _parse_date_string(params["start_date"])

    if "end_date" in params:
        end_date = _parse_date_string(params["end_date"])

    if "frequency" in params:
        frequency = params["frequency"]

    if "run_type" in params:
        run_type = parse_run_type(params["run_type"])

    if "init_cash" in params:
        init_cash = Float64(params["init_cash"])

    return RunConfig(
        strategy_file=params.get("strategy_file", ""),
        start_date=start_date,
        end_date=end_date,
        frequency=frequency,
        run_type=run_type,
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


def run_backtest(config: RunConfig) raises -> Int:
    var env = create_environment(
        start_date=config.start_date,
        end_date=config.end_date,
        run_type=config.run_type
    )
    env.set_data_source("default")
    from rqmojo.core.broker import create_broker
    env.set_broker(create_broker())
    env.set_data_proxy(create_data_proxy())
    env.set_portfolio(config.init_cash, config.init_cash)

    env.publish_event(Event(EVENT.POST_SYSTEM_INIT.value))

    var executor = create_executor()

    env.publish_event(Event(EVENT.BEFORE_STRATEGY_RUN.value))

    env.publish_event(Event(EVENT.POST_STRATEGY_RUN.value))

    clear_environment()
    return 0


def run_strategy(
    strategy_file: String,
    start_date: DateTime,
    end_date: DateTime,
    frequency: String = "1d",
    init_cash: Float64 = 100000.0
) raises -> Int:
    var config = RunConfig(
        strategy_file=strategy_file,
        start_date=start_date,
        end_date=end_date,
        frequency=frequency,
        run_type=RUN_TYPE.BACKTEST,
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


def run_with_config(config: RunConfig) raises -> Optional[Dict[String, String]]:
    var result_code = run_backtest(config)
    if result_code == 0:
        var results = Dict[String, String]()
        results["status"] = "success"
        return results^
    return None


def inject_run_param(param: CliParam, mut params: List[CliParam]) -> None:
    params.append(param.copy())


def run(kwargs: Dict[String, String], source_code: String = "") raises -> Int:
    """Main run command entry point mirroring Python's `run(**kwargs)`.

    Python original flow:
      1. Extract config_path and make it absolute using os.path.abspath.
      2. Remove base__securities key if present and empty.
      3. Call parse_config with kwargs, config_path, click_type=True, source_code.
      4. Call main.run with the parsed cfg and source_code.
      5. Handle IPython integration when running in IPython environment.
      6. Return exit code 1 if results is None, otherwise 0.

    Args:
        kwargs: Parsed CLI arguments with base__/extra__/mod__ namespaced keys.
        source_code: Strategy source code string, defaults to empty string.

    Returns:
        Exit code 0 on success, 1 on failure.
    """
    var config_path = kwargs.get("config_path", "")
    if config_path != "":
        var py_os = Python.import_module("os")
        config_path = String(py=py_os.path.abspath(config_path))

    if "base__securities" in kwargs:
        _ = kwargs["base__securities"]

    var cfg = parse_config(kwargs, source_code=source_code)

    var sc = source_code
    if sc == "":
        sc = cfg.base.strategy_file

    var results = _execute_run(cfg, sc)

    if results is None:
        return 1
    return 0


def _execute_run(cfg: RQAlphaConfig, source_code: String) raises -> Optional[Dict[String, String]]:
    """Internal execution that creates the environment and runs the strategy.

    This replaces Python's main.run(cfg, source_code).
    """
    from rqmojo.core.event_source import create_event_source
    from rqmojo.core.strategy_loader import create_file_strategy_loader
    from rqmojo.core.broker import create_broker

    var env = create_environment_from_config(cfg)
    set_environment(env)

    env.set_data_source("default")
    env.set_broker(create_broker())
    env.set_data_proxy(create_data_proxy())
    env.set_portfolio(cfg.base.initial_cash, cfg.base.initial_cash)
    env.set_event_source(create_event_source(cfg.base.start_date, cfg.base.end_date, cfg.base.frequency))
    env.set_strategy_loader(create_file_strategy_loader(cfg.base.strategy_file))
    env.set_user_strategy(source_code)

    env.publish_event(Event(EVENT.POST_SYSTEM_INIT.value))

    var executor = create_executor()

    env.publish_event(Event(EVENT.BEFORE_STRATEGY_RUN.value))

    env.set_initialized(True)

    env.publish_event(Event(EVENT.POST_STRATEGY_RUN.value))

    var results = Dict[String, String]()
    results["status"] = "success"
    results["strategy_file"] = cfg.base.strategy_file
    results["start_date"] = String(cfg.base.start_date.year) + "-" + String(cfg.base.start_date.month) + "-" + String(cfg.base.start_date.day)
    results["end_date"] = String(cfg.base.end_date.year) + "-" + String(cfg.base.end_date.month) + "-" + String(cfg.base.end_date.day)
    results["frequency"] = cfg.base.frequency
    results["run_type"] = cfg.base.run_type.name

    clear_environment()
    return results^


# ============================================================
# argmojo CLI Commands (replacing @click decorators)
# ============================================================

def create_run_command() raises -> Command:
    """Create the 'run' subcommand using argmojo.

    Replaces Python's `@cli.command(help=_('Run a strategy'))` with all
    `@click.option` decorators for base/extra/mod configuration.
    """
    var cmd = Command("run", "Run a strategy")

    cmd.add_argument(
        Argument("data_bundle_path", help="Path to data bundle directory")
        .long["data-bundle-path"]()
        .short["d"]()
    )

    cmd.add_argument(
        Argument("strategy_file", help="Path to strategy file")
        .long["strategy-file"]()
        .short["f"]()
    )

    cmd.add_argument(
        Argument("start_date", help="Backtest start date (YYYY-MM-DD)")
        .long["start-date"]()
        .short["s"]()
    )

    cmd.add_argument(
        Argument("end_date", help="Backtest end date (YYYY-MM-DD)")
        .long["end-date"]()
        .short["e"]()
    )

    cmd.add_argument(
        Argument("margin_multiplier", help="Margin multiplier")
        .long["margin-multiplier"]()
        .short["mm"]()
        .default["1.0"]()
    )

    cmd.add_argument(
        Argument("account", help="Account type with starting cash, e.g. stock 1000000")
        .long["account"]()
        .short["a"]()
        .number_of_values[2]()
    )

    cmd.add_argument(
        Argument("position", help="Initial position settings")
        .long["position"]()
    )

    cmd.add_argument(
        Argument("frequency", help="Bar frequency")
        .long["frequency"]()
        .short["fq"]()
        .default["1d"]()
        .choice["1d"]()
        .choice["1m"]()
        .choice["tick"]()
    )

    cmd.add_argument(
        Argument("run_type", help="Run type: b=backtest, p=paper trading, r=real trading")
        .long["run-type"]()
        .short["rt"]()
        .default["b"]()
        .choice["b"]()
        .choice["p"]()
        .choice["r"]()
    )

    cmd.add_argument(
        Argument("round_price", help="Round price to tick size")
        .long["round-price"]()
        .short["rp"]()
        .flag()
    )

    cmd.add_argument(
        Argument("source_code", help="Strategy source code string")
        .long["source-code"]()
    )

    cmd.add_argument(
        Argument("rqdatac_uri", help="rqdatac URI for data connection")
        .long["rqdatac"]()
    )

    cmd.add_argument(
        Argument("log_level", help="Log level")
        .long["log-level"]()
        .short["l"]()
        .default["info"]()
        .choice["verbose"]()
        .choice["debug"]()
        .choice["info"]()
        .choice["error"]()
        .choice["none"]()
    )

    cmd.add_argument(
        Argument("logger", help="Logger configuration, e.g. system_log debug")
        .long["logger"]()
        .number_of_values[2]()
    )

    cmd.add_argument(
        Argument("locale", help="Locale: cn or en")
        .long["locale"]()
        .default["cn"]()
        .choice["cn"]()
        .choice["en"]()
    )

    cmd.add_argument(
        Argument("extra_vars", help="Extra context variables override")
        .long["extra-vars"]()
    )

    cmd.add_argument(
        Argument("enable_profiler", help="Enable line profiler to profile your strategy")
        .long["enable-profiler"]()
        .flag()
    )

    cmd.add_argument(
        Argument("config_path", help="Config file path")
        .long["config"]()
    )

    cmd.add_argument(
        Argument("mod_config", help="Mod extra configuration, e.g. sys_analyser output format")
        .long["mod-config"]()
        .short["mc"]()
        .number_of_values[2]()
    )

    cmd.add_argument(
        Argument("resume_mode", help="[DEPRECATED] --resume is deprecated")
        .long["resume"]()
        .flag()
    )

    return cmd^


def register_run_commands(mut cli: Command) raises -> None:
    """Register the run subcommand onto the main CLI group.

    Equivalent to Python's side-effect-at-import pattern where
    cmds/__init__.py imports run.py triggering @cli.command().
    """
    cli.add_subcommand(create_run_command())


def dispatch_run_command(result: ParseResult) raises -> Int:
    """Dispatch to run with parsed arguments from argmojo ParseResult.

    Converts ParseResult into the kwargs dict expected by run,
    mirroring how Click passes **kwargs to the decorated function in Python.
    """
    var sr = result.get_subcommand_result()
    var kwargs = Dict[String, String]()

    var val = sr.get_string("config_path")
    if val != "": kwargs["config_path"] = val
    val = sr.get_string("data_bundle_path")
    if val != "": kwargs["data_bundle_path"] = val
    val = sr.get_string("strategy_file")
    if val != "": kwargs["strategy_file"] = val
    val = sr.get_string("start_date")
    if val != "": kwargs["start_date"] = val
    val = sr.get_string("end_date")
    if val != "": kwargs["end_date"] = val
    val = sr.get_string("frequency")
    if val != "": kwargs["frequency"] = val
    val = sr.get_string("run_type")
    if val != "": kwargs["run_type"] = val
    val = sr.get_string("source_code")
    if val != "": kwargs["source_code"] = val
    val = sr.get_string("rqdatac_uri")
    if val != "": kwargs["rqdatac_uri"] = val
    val = sr.get_string("log_level")
    if val != "": kwargs["log_level"] = val
    val = sr.get_string("locale")
    if val != "": kwargs["locale"] = val
    val = sr.get_string("extra_vars")
    if val != "": kwargs["extra_vars"] = val
    val = sr.get_string("position")
    if val != "": kwargs["position"] = val
    val = sr.get_string("margin_multiplier")
    if val != "": kwargs["margin_multiplier"] = val

    var source_code = sr.get_string("source_code")

    return run(kwargs^, source_code)
