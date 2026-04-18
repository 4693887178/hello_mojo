"""
RQAlpha Mojo - Risk Mod Module
Ported from rqalpha/mod/rqalpha_mod_sys_risk/__init__.py
"""

from std.collections import Dict
from rqmojo.mod.rqmojo_mod_sys_risk.mod import RiskManagerMod


def get_default_config() -> Dict[String, Bool]:
    var config = Dict[String, Bool]()
    config["validate_price"] = True
    config["validate_is_trading"] = True
    config["validate_cash"] = True
    config["validate_self_trade"] = False
    return config^


def load_mod() -> RiskManagerMod:
    return RiskManagerMod()
