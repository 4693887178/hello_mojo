"""
RQAlpha Mojo - Mod Utilities
Ported from rqalpha/mod/utils.py

Core functions:
  - mod_config_value_parse: Parse config string values to typed values (returns ConfigValue)
  - inject_mod_commands: Inject mod commands from config

Utility functions (rqmojo extensions):
  - parse_instrument_types: Parse instrument type strings to INSTRUMENT_TYPE list
  - parse_markets: Parse market strings to MARKET list
"""

from std.python import Python, PythonObject
from std.collections import Dict, List
from std.utils import Variant
from rqmojo.const import INSTRUMENT_TYPE, MARKET
from rqmojo.utils import RqAttrDict


comptime ConfigValue = Variant[Bool, Int, Float64, String]


def mod_config_value_parse(value: String) raises -> ConfigValue:
    if value == "True" or value == "true":
        return ConfigValue(True)
    if value == "False" or value == "false":
        return ConfigValue(False)

    var is_all_digits = True
    if value.count_codepoints() == 0:
        is_all_digits = False
    else:
        for cp in value.codepoints():
            var val = Int(cp)
            if val < 48 or val > 57:
                is_all_digits = False
                break

    if is_all_digits:
        var result: Int = 0
        for cp in value.codepoints():
            result = result * 10 + (Int(cp) - 48)
        return ConfigValue(result)

    try:
        var fval = Float64(py=Python.evaluate("__builtins__.float('" + value + "')"))
        return ConfigValue(fval)
    except:
        pass

    return ConfigValue(value)


def inject_mod_commands() raises:
    from std.python import Python
    var rqalpha_utils_config = Python.import_module("rqalpha.utils.config")
    var get_mod_conf = rqalpha_utils_config.get_mod_conf
    var mod_config = get_mod_conf()
    var mod_dict = mod_config["mod"]

    var system_mod_list = Python.import_module("rqalpha.mod").SYSTEM_MOD_LIST
    var package_helper = Python.import_module("rqalpha.utils.package_helper")
    var import_mod_fn = package_helper.import_mod
    var builtins = Python.import_module("builtins")

    for entry in mod_dict.items():
        var mod_name = String(py=entry.key())
        var config = entry.value()
        var enabled = config.get("enabled", True)
        if not Bool(py=enabled):
            continue
        var lib_name: String
        if builtins.hasattr(config, "lib"):
            lib_name = String(py=builtins.getattr(config, "lib"))
        else:
            lib_name = "rqalpha_mod_" + mod_name
        try:
            var is_system = Bool(py=system_mod_list.__contains__(PythonObject(mod_name)))
            if is_system:
                import_mod_fn("rqalpha.mod." + lib_name)
            else:
                import_mod_fn(lib_name)
        except:
            pass


def register_mod(mod_name: String, mut mod_config: RqAttrDict) raises:
    pass


def unregister_mod(mod_name: String) raises:
    pass


def get_mod_config(mod_name: String) -> RqAttrDict:
    return RqAttrDict()


def parse_instrument_types(type_str: String) -> List[INSTRUMENT_TYPE]:
    var result = List[INSTRUMENT_TYPE]()
    var parts = type_str.split(",")
    for part in parts:
        var trimmed = part.strip()
        if trimmed == "CS":
            result.append(INSTRUMENT_TYPE.CS)
        elif trimmed == "ETF":
            result.append(INSTRUMENT_TYPE.ETF)
        elif trimmed == "FUTURE":
            result.append(INSTRUMENT_TYPE.FUTURE)
        elif trimmed == "INDX":
            result.append(INSTRUMENT_TYPE.INDX)
        elif trimmed == "LOF":
            result.append(INSTRUMENT_TYPE.LOF)
        elif trimmed == "FUND":
            result.append(INSTRUMENT_TYPE.FUND)
        elif trimmed == "BOND":
            result.append(INSTRUMENT_TYPE.BOND)
    return result^


def parse_markets(market_str: String) -> List[MARKET]:
    var result = List[MARKET]()
    var parts = market_str.split(",")
    for part in parts:
        var trimmed = part.strip()
        if trimmed == "CN":
            result.append(MARKET.CN)
        elif trimmed == "HK":
            result.append(MARKET.HK)
    return result^
