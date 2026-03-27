"""
RQAlpha Mojo - Transaction Cost Mod
Ported from rqalpha/mod/rqalpha_mod_sys_transaction_cost/mod.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXIT_CODE, MARKET
from rqmojo.interface import ModInterface
from rqmojo.environment import Environment, TransactionCostDecider
from std.collections import Dict, Optional
from std.python import PythonObject
from std.io import Writer


@fieldwise_init
struct TransactionCostMod(ModInterface, Writable, Movable):
    var name: String
    var enabled: Bool
    var stock_commission_multiplier: Float64
    var futures_commission_multiplier: Float64
    
    def write_to(self, mut writer: Some[Writer]):
        writer.write("TransactionCostMod(", self.name, ")")
    
    def start_up(mut self, env_name: String, mod_config_name: String):
        pass
    
    def tear_down(self, code: EXIT_CODE, exception_msg: Optional[String]):
        pass
    
    def init_from_config(mut self, config: Dict[String, String]):
        pass


def create_transaction_cost_mod(stock_commission: Float64 = 0.0003, futures_commission: Float64 = 0.0001) -> TransactionCostMod:
    return TransactionCostMod(
        name="transaction_cost",
        enabled=True,
        stock_commission_multiplier=stock_commission,
        futures_commission_multiplier=futures_commission
    )
