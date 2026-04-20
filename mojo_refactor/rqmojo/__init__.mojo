"""
RQMojo - RQAlpha Mojo Implementation
Ported from rqalpha/__init__.py (219 lines)

Key public API:
  run          - Run backtest with config dict (deprecated, use run_file/run_code)
  run_file     - Run backtest from strategy file path
  run_code     - Run backtest from strategy code string
  run_func     - Run backtest with user-defined callback functions

Differences from Python original:
  - No IPython integration ( Mojo has no IPython)
  - run_func uses positional params instead of **kwargs (Mojo limitation)
  - Config uses RqAttrDict for dynamic nested structure
  - export_as_api imported from api module
"""

from std.collections import Dict, List
from std.python import Python, PythonObject
from std.utils import Variant

from rqmojo._version import get_version, __version__
from rqmojo.utils.config import parse_config
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.functools import clear_all_cached_functions
from rqmojo.utils.logger import user_log, system_log, init_logger
from rqmojo.utils.exception import CustomError
from rqmojo.utils import RqAttrDict
from rqmojo.main import run as main_run, RunResult
from rqmojo.api import export_as_api


comptime __all__: List[String] = [
    "__version__",
]


comptime version_info: List[Variant[Int, String]] = [
    Variant[Int, String](0),
    Variant[Int, String](1),
    Variant[Int, String](0),
]

comptime __main_version__: String = "0.1.x"


def load_ipython_extension(ipython_obj: PythonObject) raises -> None:
    """
    Call by IPython to register extension.
    In Mojo this is a no-op since there's no IPython.
    """
    pass


def run_ipython_cell(line: String, cell: String = "") raises -> None:
    """
    IPython cell magic for running RQAlpha in notebooks.
    In Mojo this is a no-op since there's no IPython.
    """
    pass


def run(config: RqAttrDict, source_code: String = "") raises -> RunResult:
    """
    Run backtest with config dict.

    [Deprecated] Prefer using run_file() or run_code().

    Matches Python: def run(config, source_code=None)
    """
    var parsed_config = parse_config(config, source_code=source_code)
    return main_run(parsed_config, source_code=source_code)


def run_file(
    strategy_file_path: String,
    config: RqAttrDict = RqAttrDict()
) raises -> RunResult:
    """
    Run backtest from strategy file path.

    Matches Python: def run_file(strategy_file_path, config=None)

    Config handling (aligned with Python):
      - If config is empty/default: creates {"base": {"strategy_file": path}}
      - If config has "base" child: sets base.strategy_file = path
      - Otherwise: creates base child with strategy_file
    """
    var merged_config: RqAttrDict

    if config.is_empty():
        merged_config = RqAttrDict()
        var base_cfg = RqAttrDict()
        base_cfg["strategy_file"] = strategy_file_path
        merged_config["base"] = base_cfg
    else:
        merged_config = config.copy()
        if merged_config.contains("base"):
            var base_ref = merged_config["base"]
            base_ref["strategy_file"] = strategy_file_path
            merged_config["base"] = base_ref
        else:
            var base_cfg = RqAttrDict()
            base_cfg["strategy_file"] = strategy_file_path
            merged_config["base"] = base_cfg

    var parsed_config = parse_config(merged_config)
    clear_all_cached_functions()

    return main_run(parsed_config)


def run_code(
    code: String,
    config: RqAttrDict = RqAttrDict()
) raises -> RunResult:
    """
    Run backtest from strategy code string.

    Matches Python: def run_code(code, config=None)

    Config handling (aligned with Python):
      - Removes base.strategy_file if present (code mode doesn't use files)
      - Passes source_code to parse_config
    """
    var merged_config: RqAttrDict

    if config.is_empty():
        merged_config = RqAttrDict()
    else:
        merged_config = config.copy()
        if merged_config.contains("base"):
            var base_ref = merged_config["base"]
            if base_ref.contains("strategy_file"):
                _ = base_ref._values.pop("strategy_file")
            merged_config["base"] = base_ref

    var parsed_config = parse_config(merged_config, source_code=code)
    clear_all_cached_functions()

    return main_run(parsed_config, source_code=code)


def run_func(
    config: RqAttrDict = RqAttrDict(),
    init_fn: String = "",
    handle_bar_fn: String = "",
    handle_tick_fn: String = "",
    before_trading_fn: String = "",
    after_trading_fn: String = "",
    open_auction_fn: String = ""
) raises -> RunResult:
    """
    Run backtest with user-defined callback functions.

    Matches Python: def run_func(**kwargs)

    Mojo adaptation: Uses named params instead of **kwargs.
    Extracts config and user_funcs same as Python original.

    Supported callbacks (same as Python):
      - init(context): Strategy initialization
      - handle_bar(context, bar_dict): Bar event handler
      - handle_tick(context, tick): Tick event handler
      - before_trading(context): Pre-market handler
      - after_trading(context): Post-market handler
      - open_auction(context, bar_dict): Auction handler
    """
    var user_funcs = RqAttrDict()

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

    var clean_config: RqAttrDict
    if config.is_empty():
        clean_config = RqAttrDict()
    else:
        clean_config = config.copy()
        if clean_config.contains("base"):
            var base_ref = clean_config["base"]
            if base_ref.contains("strategy_file"):
                _ = base_ref._values.pop("strategy_file")
            clean_config["base"] = base_ref

    var parsed_config = parse_config(clean_config, user_funcs=user_funcs)
    clear_all_cached_functions()

    return main_run(parsed_config)


def print_main() -> None:
    """RQMojo main entry point."""
    print("RQMojo - RQAlpha Mojo Implementation")
    print("Version:", get_version())
    print("")
    print("Usage:")
    print("  from rqmojo import run_file, run_code, run_func")
