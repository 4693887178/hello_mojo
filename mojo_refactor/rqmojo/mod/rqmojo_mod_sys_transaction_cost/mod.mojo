"""
RQAlpha Mojo - Transaction Cost Mod
Ported from rqalpha/mod/rqalpha_mod_sys_transaction_cost/mod.py

Python original provides:
  - TransactionCostMod(AbstractMod): registers stock/futures transaction cost deciders
  - start_up(): validates config, handles deprecated options, creates deciders per instrument type
  - tear_down(): no-op cleanup
"""

from rqmojo.const import INSTRUMENT_TYPE, EXIT_CODE, MARKET
from rqmojo.interface import ModInterface
from rqmojo.environment import Environment, TransactionCostDecider
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import (
    StockTransactionCostDecider,
    FutureTransactionCostDecider,
)
from rqmojo.mod.utils import ConfigValue
from std.collections import Dict, List, Optional
from std.io import Writer


def get_inst_type_in_stock_account() -> List[INSTRUMENT_TYPE]:
    """Python: INST_TYPE_IN_STOCK_ACCOUNT = [CS, ETF, LOF, INDX, PUBLIC_FUND, REITs]."""
    var result = List[INSTRUMENT_TYPE]()
    result.append(INSTRUMENT_TYPE.CS)
    result.append(INSTRUMENT_TYPE.ETF)
    result.append(INSTRUMENT_TYPE.LOF)
    result.append(INSTRUMENT_TYPE.INDX)
    result.append(INSTRUMENT_TYPE.PUBLIC_FUND)
    result.append(INSTRUMENT_TYPE.REITs)
    return result^


@fieldwise_init
struct TransactionCostMod(ModInterface, Writable, Movable):
    var name: String
    var enabled: Bool
    var stock_commission_multiplier: Float64
    var futures_commission_multiplier: Float64
    var min_commission: Float64
    var tax_multiplier: Float64
    var pit_tax: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TransactionCostMod(", self.name, ")")

    def start_up(mut self, env_name: String, mod_config_name: String):
        pass

    def tear_down(self, code: EXIT_CODE, exception_msg: Optional[String]):
        pass

    def init_from_config(mut self, config: Dict[String, ConfigValue]) raises:
        self.stock_commission_multiplier = config["stock_commission_multiplier"][Float64]
        self.futures_commission_multiplier = config["futures_commission_multiplier"][Float64]
        self.tax_multiplier = config["tax_multiplier"][Float64]
        self.pit_tax = config["pit_tax"][Bool]

        var cn_min_commission = config["cn_stock_min_commission"][Float64]
        if cn_min_commission >= 0:
            self.min_commission = cn_min_commission
        else:
            self.min_commission = config["stock_min_commission"][Float64]

    def validate_config(self) -> Optional[String]:
        if self.stock_commission_multiplier < 0 or self.tax_multiplier < 0:
            return Optional[String](
                "invalid commission multiplier or tax multiplier"
                " value: value range is [0, +inf)"
            )
        return Optional[String](None)

    def create_stock_deciders(self) -> List[INSTRUMENT_TYPE]:
        """Return list of instrument types for which stock deciders should be created.
        Mirrors Python: for instrument_type in INST_TYPE_IN_STOCK_ACCOUNT: skip PUBLIC_FUND."""
        var result = List[INSTRUMENT_TYPE]()
        var all_types = get_inst_type_in_stock_account()
        for inst_type in all_types:
            if inst_type == INSTRUMENT_TYPE.PUBLIC_FUND:
                continue
            result.append(inst_type)
        return result^

    def make_stock_decider_for(self, inst_type: INSTRUMENT_TYPE) -> StockTransactionCostDecider:
        """Create a single StockTransactionCostDecider for the given instrument type."""
        return StockTransactionCostDecider(
            commission_multiplier=self.stock_commission_multiplier,
            min_commission=self.min_commission,
            tax_multiplier=self.tax_multiplier,
        )

    def create_future_decider(self) -> FutureTransactionCostDecider:
        """Create FuturesTransactionCostDecider. Mirrors Python: env.set_transaction_cost_decider(FUTURE, ...)."""
        return FutureTransactionCostDecider(
            commission_multiplier=self.futures_commission_multiplier,
        )

    def setup_deciders(
        mut self,
        mut env: Environment,
    ) -> Optional[String]:
        """Full start_up logic: validate, then register all deciders on env.
        Returns error message if validation fails, None on success."""
        var err = self.validate_config()
        if err != Optional[String](None):
            return err

        var stock_types = self.create_stock_deciders()
        for inst_type in stock_types:
            var wrapper = TransactionCostDecider(
                name="stock_" + inst_type.value,
                instrument_type=inst_type,
                market=MARKET.CN,
            )
            env.set_transaction_cost_decider(inst_type, wrapper)

        var future_wrapper = TransactionCostDecider(
            name="future",
            instrument_type=INSTRUMENT_TYPE.FUTURE,
            market=MARKET.CN,
        )
        env.set_transaction_cost_decider(INSTRUMENT_TYPE.FUTURE, future_wrapper)

        return Optional[String](None)


def create_transaction_cost_mod(
    stock_commission: Float64 = 1.0,
    futures_commission: Float64 = 1.0,
) -> TransactionCostMod:
    return TransactionCostMod(
        name="transaction_cost",
        enabled=True,
        stock_commission_multiplier=stock_commission,
        futures_commission_multiplier=futures_commission,
        min_commission=5.0,
        tax_multiplier=1.0,
        pit_tax=False,
    )
