"""
RQAlpha Mojo - Mod Utilities
Ported from rqalpha/mod/utils.py
"""

from rqmojo.const import INSTRUMENT_TYPE, MARKET, INSTRUMENT_TYPE_CS, INSTRUMENT_TYPE_ETF, INSTRUMENT_TYPE_FUTURE, MARKET_CN, MARKET_HK


def register_mod(mod_name: String, mod_config: Dict[String, String]):
    pass


def unregister_mod(mod_name: String):
    pass


def get_mod_config(mod_name: String) -> Dict[String, String]:
    return Dict[String, String]()


def parse_instrument_types(type_str: String) -> List[INSTRUMENT_TYPE]:
    var result = List[INSTRUMENT_TYPE]()
    var parts = type_str.split(",")
    for part in parts:
        var trimmed = part.strip()
        if trimmed == "CS":
            result.append(INSTRUMENT_TYPE_CS)
        elif trimmed == "ETF":
            result.append(INSTRUMENT_TYPE_ETF)
        elif trimmed == "FUTURE":
            result.append(INSTRUMENT_TYPE_FUTURE)
    return result^


def parse_markets(market_str: String) -> List[MARKET]:
    var result = List[MARKET]()
    var parts = market_str.split(",")
    for part in parts:
        var trimmed = part.strip()
        if trimmed == "CN":
            result.append(MARKET_CN)
        elif trimmed == "HK":
            result.append(MARKET_HK)
    return result^
