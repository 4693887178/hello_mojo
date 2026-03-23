"""
RQMojo - RQAlpha Mojo Implementation
Ported from rqalpha/__init__.py
"""

from std.collections import Dict, List
from std.python import Python, PythonObject
from rqmojo._version import get_version, __version__
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, EXIT_CODE
from rqmojo.utils.config import RQAlphaConfig, BaseConfig, parse_config
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.functools import clear_all_cached_functions
from rqmojo.utils.logger import user_log, system_log, init_logger
from rqmojo.utils.exception import CustomError
from rqmojo.main import run as main_run, create_config, RunResult


comptime __all__: List[String] = [
    "__version__",
    "version_info",
    "__main_version__",
    "run",
    "run_file",
    "run_code",
    "run_func",
]


comptime version_info: String = __version__
comptime __main_version__: String = "0.1.x"


def run(config: Dict[String, String], source_code: String = "") raises -> RunResult:
    """Run backtest with config dict."""
    var parsed_config = parse_config(config, source_code)
    return main_run(parsed_config, source_code)


def run_file(
    strategy_file_path: String,
    config: Dict[String, String] = Dict[String, String]()
) raises -> RunResult:
    """Run backtest from strategy file."""
    var merged_config = Dict[String, String]()
    
    for key in config.keys():
        merged_config[key] = config[key]
    
    merged_config["base.strategy_file"] = strategy_file_path
    
    var parsed_config = parse_config(merged_config)
    clear_all_cached_functions()
    
    return main_run(parsed_config)


def run_code(
    code: String,
    config: Dict[String, String] = Dict[String, String]()
) raises -> RunResult:
    """Run backtest from strategy code string."""
    var merged_config = Dict[String, String]()
    
    for key in config.keys():
        merged_config[key] = config[key]
    
    var parsed_config = parse_config(merged_config, source_code=code)
    clear_all_cached_functions()
    
    return main_run(parsed_config, source_code=code)


def run_func(
    config: Dict[String, String] = Dict[String, String](),
    init_fn: String = "",
    handle_bar_fn: String = "",
    handle_tick_fn: String = "",
    before_trading_fn: String = "",
    after_trading_fn: String = "",
    open_auction_fn: String = ""
) raises -> RunResult:
    """Run backtest with function callbacks."""
    var user_funcs = Dict[String, String]()
    
    if len(init_fn) > 0:
        user_funcs["init"] = init_fn
    if len(handle_bar_fn) > 0:
        user_funcs["handle_bar"] = handle_bar_fn
    if len(handle_tick_fn) > 0:
        user_funcs["handle_tick"] = handle_tick_fn
    if len(before_trading_fn) > 0:
        user_funcs["before_trading"] = before_trading_fn
    if len(after_trading_fn) > 0:
        user_funcs["after_trading"] = after_trading_fn
    if len(open_auction_fn) > 0:
        user_funcs["open_auction"] = open_auction_fn
    
    var parsed_config = parse_config(config, user_funcs=user_funcs)
    clear_all_cached_functions()
    
    return main_run(parsed_config, user_funcs=user_funcs)


def export_as_api(name: String) -> None:
    """Mark a function as API export."""
    pass


def main() -> None:
    """RQMojo main entry point."""
    print("RQMojo - RQAlpha Mojo Implementation")
    print("Version:", get_version())
    print("")
    print("Usage:")
    print("  from rqmojo import run_file, run_code, run_func")
