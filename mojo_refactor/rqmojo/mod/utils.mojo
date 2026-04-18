"""
RQAlpha Mojo - Mod Utilities
Ported from rqalpha/mod/utils.py
"""

from rqmojo.const import INSTRUMENT_TYPE, MARKET
from rqmojo.utils import RqAttrDict


@fieldwise_init
struct ConfigValue(Movable, Copyable, Writable, ImplicitlyCopyable):
    var bool_value: Optional[Bool]
    var float_value: Optional[Float64]
    var int_value: Optional[Int]
    var string_value: Optional[String]

    def __init__(out self, value: Bool):
        self.bool_value = value
        self.float_value = None
        self.int_value = None
        self.string_value = None

    def __init__(out self, value: Float64):
        self.bool_value = None
        self.float_value = value
        self.int_value = None
        self.string_value = None

    def __init__(out self, value: Int):
        self.bool_value = None
        self.float_value = None
        self.int_value = value
        self.string_value = None

    def __init__(out self, value: String):
        self.bool_value = None
        self.float_value = None
        self.int_value = None
        self.string_value = value

    def __init__(out self, *, copy: Self):
        self.bool_value = copy.bool_value
        self.float_value = copy.float_value
        self.int_value = copy.int_value
        self.string_value = copy.string_value

    def write_to(self, mut writer: Some[Writer]):
        if self.bool_value.__ne__(None):
            writer.write("ConfigValue(bool=", self.bool_value.or_else(False), ")")
        elif self.float_value.__ne__(None):
            writer.write("ConfigValue(float=", self.float_value.or_else(0.0), ")")
        elif self.int_value.__ne__(None):
            writer.write("ConfigValue(int=", self.int_value.or_else(0), ")")
        elif self.string_value.__ne__(None):
            writer.write("ConfigValue(string=", self.string_value.or_else(""), ")")
        else:
            writer.write("ConfigValue(None)")

    def as_bool(self) -> Bool:
        return self.bool_value.or_else(False)

    def as_float(self) -> Float64:
        return self.float_value.or_else(0.0)

    def as_int(self) -> Int:
        return self.int_value.or_else(0)

    def as_string(self) -> String:
        return self.string_value.or_else("")


def register_mod(mod_name: String, mod_config: RqAttrDict):
    pass


def unregister_mod(mod_name: String):
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
