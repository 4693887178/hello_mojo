"""
RQAlpha Mojo - Transaction Cost Mod
Ported from rqalpha/mod/rqalpha_mod_sys_transaction_cost/mod.py
"""

from rqmojo.const import INSTRUMENT_TYPE, EXIT_CODE
from rqmojo.interface import ModInterface
from rqmojo.environment import Environment
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider, create_stock_decider, create_future_decider, create_bond_decider


@fieldwise_init
struct TransactionCostMod(ModInterface, Stringable, Movable):
    var name: String
    var enabled: Bool
    var stock_commission_multiplier: Float64
    var futures_commission_multiplier: Float64
    
    def __str__(self) -> String:
        return "TransactionCostMod(" + self.name + ")"
    
    def start_up(mut self, env: Environment, config: Dict[String, String]) -> None:
        var stock_decider = create_stock_decider(commission_multiplier=self.stock_commission_multiplier)
        var future_decider = create_future_decider(commission_multiplier=self.futures_commission_multiplier)
        var bond_decider = create_bond_decider()
        
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.CS.__str__(), stock_decider, "CN")
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.ETF.__str__(), stock_decider, "CN")
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.LOF.__str__(), stock_decider, "CN")
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.FUTURE.__str__(), future_decider, "CN")
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.BOND.__str__(), bond_decider, "CN")
    
    def tear_down(mut self, code: EXIT_CODE, exception: Optional[object]) -> None:
        pass


def create_transaction_cost_mod(stock_commission: Float64 = 0.0003, futures_commission: Float64 = 0.0001) -> TransactionCostMod:
    return TransactionCostMod(
        name="transaction_cost",
        enabled=True,
        stock_commission_multiplier=stock_commission,
        futures_commission_multiplier=futures_commission
    )
