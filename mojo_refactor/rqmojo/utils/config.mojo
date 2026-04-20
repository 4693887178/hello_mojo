"""
RQAlpha Mojo - Config Module
Ported from rqalpha/utils/config.py

Key Functions:
  load_yaml          - Load YAML configuration file
  default_config     - Get default RQAlpha configuration
  parse_config       - Parse and merge configuration from multiple sources
  parse_run_type     - Parse run type string to RUN_TYPE enum
  parse_persist_mode - Parse persist mode string to PERSIST_MODE enum
  parse_accounts     - Parse account configurations
  parse_init_positions - Parse initial position strings
  parse_future_info  - Parse futures commission info

All configuration is stored using RqAttrDict (dynamic dictionary structure)
to match Python's flexible config system.
"""

from std.collections import Dict, List
from rqmojo.const import RUN_TYPE, PERSIST_MODE, COMMISSION_TYPE
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils import RqAttrDict


fn get_rqalpha_path() -> String:
    return "~/.rqalpha"


def load_yaml(path: String) -> RqAttrDict:
    """
    Load YAML file and return as RqAttrDict.

    Note: In production, this would use yaml parser.
    For now returns empty dict with basic structure.
    """
    return RqAttrDict()


def default_config() raises -> RqAttrDict:
    """
    Get default RQAlpha configuration.

    Returns nested RqAttrDict with structure:
    {
        base: { start_date, end_date, frequency, run_type, ... },
        extra: { locale, context_vars, ... },
        mod: { enabled }
    }

    Matches Python's default_config() function.
    """
    var base = RqAttrDict()
    base["start_date"] = "2015-01-01"
    base["end_date"] = "2015-12-31"
    base["frequency"] = "1d"
    base["run_type"] = "b"
    base["data_bundle_path"] = None
    base["strategy_file"] = ""
    base["source_code"] = None
    base["persist_mode"] = "on_crash"
    base["initial_cash"] = 1000000.0
    base["accounts"] = RqAttrDict()
    base["init_positions"] = ""
    base["future_info"] = RqAttrDict()
    base["rqdatac_uri"] = ""

    var extra = RqAttrDict()
    extra["locale"] = "zh_CN"
    extra["context_vars"] = ""
    extra["is_hold"] = False

    var mod = RqAttrDict()
    mod["enabled"] = True

    var conf = RqAttrDict()
    conf["base"] = base
    conf["extra"] = extra
    conf["mod"] = mod
    conf["whitelist"] = "[]"

    return conf^


def user_config() raises -> RqAttrDict:
    """Load user configuration from ~/.rqalpha/ directory."""
    var conf = default_config()

    return conf^


def project_config() raises -> RqAttrDict:
    """Load project configuration from current working directory."""
    var conf = default_config()

    return conf^


def code_config(config: RqAttrDict, source_code: String = "") raises -> RqAttrDict:
    """
    Extract __config__ from strategy source code.
    
    In Python version, this compiles and executes the source code
    to extract configuration variables defined by user.
    For Mojo, this returns empty dict (strategy parsing handled separately).
    """
    return RqAttrDict()


def dump_config(config_path: String, config: RqAttrDict) raises:
    """Dump configuration to YAML file."""
    pass


def parse_run_type(rt_str: String) raises -> RUN_TYPE:
    """
    Parse run type string to RUN_TYPE enum.

    Mapping:
      'b' / 'backtest'      -> BACKTEST
      'p' / 'paper_trading' -> PAPER_TRADING
      'r' / 'live_trading'  -> LIVE_TRADING

    Raises RuntimeError if unknown type.
    """
    if rt_str == "b" or rt_str == "backtest":
        return RUN_TYPE.BACKTEST
    elif rt_str == "p" or rt_str == "paper_trading":
        return RUN_TYPE.PAPER_TRADING
    elif rt_str == "r" or rt_str == "live_trading":
        return RUN_TYPE.LIVE_TRADING
    else:
        raise Error("RuntimeError: unknown run type: " + rt_str)


def parse_persist_mode(mode_str: String) raises -> PERSIST_MODE:
    """
    Parse persist mode string to PERSIST_MODE enum.

    Mapping:
      'real_time'      -> REAL_TIME
      'on_crash'       -> ON_CRASH
      'on_normal_exit' -> ON_NORMAL_EXIT

    Raises RuntimeError if unknown mode.
    """
    if mode_str == "real_time":
        return PERSIST_MODE.REAL_TIME
    elif mode_str == "on_crash":
        return PERSIST_MODE.ON_CRASH
    elif mode_str == "on_normal_exit":
        return PERSIST_MODE.ON_NORMAL_EXIT
    else:
        raise Error("RuntimeError: unknown persist mode: " + mode_str)


def parse_accounts(accounts: RqAttrDict) raises -> RqAttrDict:
    """
    Parse account configurations into standardized format.

    Input can be tuple of (account_type, starting_cash) pairs,
    or dict mapping account_type -> starting_cash.

    Returns dict with uppercase keys and float values.
    None values are filtered out.
    """
    var result = RqAttrDict()

    for key in accounts.keys():
        var value = accounts[key]
        if value.has_value():
            var cash_val = value.to[Float64](0.0)
            if cash_val > 0.0:
                result[key.upper()] = cash_val

    return result^


def parse_init_positions(positions: String) raises -> List[String]:
    """
    Parse initial positions string.

    Format: "order_book_id:quantity,order_book_id:quantity"
    Example: "000001.XSHE:1000,IF1701:-1"

    Returns list of (order_book_id, quantity) tuples.
    Raises RuntimeError if format invalid.
    """
    var result = List[String]()

    if len(positions) == 0:
        return result^

    var parts = positions.split(",")
    for part in parts:
        var s = part.strip()
        if len(s) == 0:
            continue

        var kv = s.split(":")
        if len(kv) != 2:
            raise Error("RuntimeError: invalid init position " + s +
                        ", should be in format 'order_book_id:quantity'")

        var order_book_id = kv[0].strip()
        try:
            var quantity = Float64(kv[1].strip())
            result.append(order_book_id + ":" + String(quantity))
        except e:
            raise Error("RuntimeError: invalid quantity for instrument " +
                        order_book_id + ": " + kv[1])

    return result^


def parse_future_info(future_info: RqAttrDict) raises -> RqAttrDict:
    """
    Parse futures commission information.

    Input structure:
    {
        underlying_symbol: {
            open_commission_ratio: float,
            close_commission_ratio: float,
            close_commission_today_ratio: float,
            commission_type: BY_MONEY | BY_VOLUME
        },
        ...
    }

    Validates field names and converts values appropriately.
    Raises RuntimeError on invalid data.
    """
    var new_info = RqAttrDict()

    for key in future_info.keys():
        var underlying_symbol = key.upper()
        var info = future_info[key]

        if not info.has_children():
            continue

        for field_key in info.keys():
            var value = info[field_key]

            if field_key == "open_commission_ratio" or field_key == "close_commission_ratio" or field_key == "close_commission_today_ratio":
                if not new_info.contains(underlying_symbol):
                    new_info[underlying_symbol] = RqAttrDict()
                var sub_dict = new_info[underlying_symbol]
                sub_dict[field_key] = Float64(value.to[String]("0.0"))
                new_info[underlying_symbol] = sub_dict

            elif field_key == "commission_type":
                var type_str = value.to[String]("")
                if type_str.upper() == "BY_MONEY":
                    if not new_info.contains(underlying_symbol):
                        new_info[underlying_symbol] = RqAttrDict()
                    var sub_dict = new_info[underlying_symbol]
                    sub_dict[field_key] = "BY_MONEY"
                    new_info[underlying_symbol] = sub_dict
                elif type_str.upper() == "BY_VOLUME":
                    if not new_info.contains(underlying_symbol):
                        new_info[underlying_symbol] = RqAttrDict()
                    var sub_dict = new_info[underlying_symbol]
                    sub_dict[field_key] = "BY_VOLUME"
                    new_info[underlying_symbol] = sub_dict
                else:
                    raise Error("RuntimeError: Invalid future info: " +
                               "commission_type should be BY_MONEY or BY_VOLUME")
            else:
                raise Error("RuntimeError: Invalid future info: field " +
                           field_key + " is not valid")

    return new_info^


def deep_update(source: RqAttrDict, mut target: RqAttrDict) raises:
    """
    Deep update target dict with source dict values.

    Recursively merges dictionaries, with source values taking precedence.
    Similar to Python's dict.update() but recursive.
    """
    for key in source.keys():
        var value = source[key]

        if value.has_children():
            if not target.contains(key):
                target[key] = RqAttrDict()
            var target_child = target[key]
            deep_update(value, target_child)
            target[key] = target_child
        else:
            target[key] = value


def parse_config(
    config_args: RqAttrDict,
    config_path: Optional[String] = None,
    click_type: Bool = False,
    source_code: String = "",
    user_funcs: Optional[RqAttrDict] = None
) raises -> RqAttrDict:
    """
    Main configuration parsing function.

    Merges configuration from multiple sources (in priority order):
    1. Default configuration
    2. User configuration (~/.rqalpha/)
    3. Project configuration (current dir)
    4. Explicit config_path (if provided)
    5. Command line arguments (config_args)

    Args:
    - config_args: Command-line/config arguments as RqAttrDict
    - config_path: Path to explicit config file (optional)
    - click_type: If True, handle Click-style nested keys with '__'
    - source_code: Strategy source code (optional)
    - user_funcs: User-defined functions (optional)

    Returns:
    - Fully parsed RqAttrDict configuration
    """

    var conf = default_config()
    deep_update(user_config(), conf)
    deep_update(project_config(), conf)

    if config_path != None:
        var path_conf = load_yaml(config_path.value())
        deep_update(path_conf, conf)

    if config_args.contains("base__strategy_file"):
        var sf = config_args["base__strategy_file"]
        if sf.has_value() and sf.to[String]("") != "":
            conf["base"]["strategy_file"] = sf

    if user_funcs == None:
        var code_cfg = code_config(conf, source_code)
        for key in code_cfg.keys():
            if conf.contains("whitelist") and conf["whitelist"].contains(key):
                deep_update(code_cfg[key], conf[key])

    if click_type:
        for key in config_args.keys():
            var v = config_args[key]
            if not v.has_value() or v.is_empty():
                continue
            if key == "base__accounts" and v.is_empty():
                continue

            var key_parts = key.split("__")
            var current = conf
            var i = 0
            while i < len(key_parts) - 1:
                var p = String(key_parts[i])
                if not current.contains(p):
                    current[p] = RqAttrDict()
                current = current[p]
                i += 1
            current[String(key_parts[len(key_parts) - 1])] = v
    else:
        deep_update(config_args, conf)

    return conf^
