"""
RQAlpha Mojo - Transaction Cost Module
Ported from rqalpha/mod/rqalpha_mod_sys_transaction_cost/__init__.py
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.mod import TransactionCostMod, create_transaction_cost_mod
from rqmojo.mod.utils import ConfigValue
from argmojo import Argument, Command
from std.collections import Dict, List


def get_config() -> Dict[String, ConfigValue]:
    """Get module config, corresponds to Python __config__."""
    var config = Dict[String, ConfigValue]()
    config["cn_stock_min_commission"] = ConfigValue(-1.0)
    config["stock_min_commission"] = ConfigValue(5.0)
    config["stock_commission_multiplier"] = ConfigValue(1.0)
    config["futures_commission_multiplier"] = ConfigValue(1.0)
    config["tax_multiplier"] = ConfigValue(1.0)
    config["pit_tax"] = ConfigValue(False)
    return config^


def get_cli_prefix() -> String:
    """Get CLI argument prefix, corresponds to Python cli_prefix."""
    return "mod__sys_transaction_cost__"


def get_cli_options() -> List[Argument]:
    """Get CLI options list, corresponds to Python 7 click.Options."""
    var options = List[Argument]()

    options.append(
        Argument(name="commission-multiplier", help="[sys_transaction_cost][deprecated] set commission multiplier")
            .long["commission-multiplier"]().short["c"]().value_name["FLOAT"]()
    )
    options.append(
        Argument(name="stock-commission-multiplier", help="[sys_transaction_cost] set stock commission multiplier")
            .long["stock-commission-multiplier"]().short["s"]().value_name["FLOAT"]()
    )
    options.append(
        Argument(name="futures-commission-multiplier", help="[sys_transaction_cost] set futures commission multiplier")
            .long["futures-commission-multiplier"]().short["f"]().value_name["FLOAT"]()
    )
    options.append(
        Argument(name="cn-stock-min-commission", help="[sys_transaction_cost] set minimum commission in chinese stock trades.")
            .long["cn-stock-min-commission"]().short["n"]().value_name["FLOAT"]()
    )
    options.append(
        Argument(name="stock-min-commission", help="[sys_transaction_cost][deprecated] set minimum commission in chinese stock trades.")
            .long["stock-min-commission"]().short["S"]().value_name["FLOAT"]()
    )
    options.append(
        Argument(name="tax-multiplier", help="[sys_transaction_cost] set tax multiplier")
            .long["tax-multiplier"]().short["t"]().value_name["FLOAT"]()
    )
    options.append(
        Argument(name="pit-tax", help="[sys_transaction_cost] use historical tax")
            .long["pit-tax"]().flag()
    )

    return options^


def register_cli_options(mut cmd: Command) raises -> None:
    """Register CLI options to command, corresponds to Python cli.commands['run'].params.append."""
    for option in get_cli_options():
        cmd.add_argument(option.copy())


def load_mod() -> TransactionCostMod:
    """Load module instance, corresponds to Python load_mod()."""
    return create_transaction_cost_mod()
