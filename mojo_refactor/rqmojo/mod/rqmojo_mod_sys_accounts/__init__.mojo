"""
RQAlpha Mojo - System Accounts Module
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/__init__.py

Python original provides:
  - __config__: 11 config items (stock_t1, dividend_reinvestment, etc.)
  - load_mod(): returns AccountMod()
  - CLI injection: 5 click.Options via cli.commands['run'].params.append
  - cli_prefix = "mod__sys_accounts__"

CLI Options (from Python):
  1. --stock-t1 / --no-stock-t1          (bool toggle, default=None)
  2. --dividend-reinvestment              (flag, default=None)
  3. --cash-return-by-stock-delisted / --no-cash-return-by-stock-delisted  (bool toggle, default=True)
  4. --no-short-stock / --short-stock     (flag inverted, default=True)
  5. --futures-settlement-price-type      (string option, default=None)
"""

from rqmojo.mod.rqmojo_mod_sys_accounts.mod import AccountsMod, create_accounts_mod
from rqmojo.mod.utils import ConfigValue
from argmojo import Argument, Command
from std.collections import Dict, List


def get_config() -> Dict[String, ConfigValue]:
    """Get module config, corresponds to Python __config__ dict with 10 items.

    Python original:
        __config__ = {
            "stock_t1": True,
            "dividend_reinvestment": False,
            "dividend_tax_rate": 0.0,
            "cash_return_by_stock_delisted": True,
            "auto_switch_order_value": False,
            "validate_stock_position": True,
            "validate_future_position": True,
            "financing_rate": 0.00,
            "financing_stocks_restriction_enabled": False,
            "futures_settlement_price_type": "close",
        }
    """
    var config = Dict[String, ConfigValue]()
    config["stock_t1"] = ConfigValue(True)
    config["dividend_reinvestment"] = ConfigValue(False)
    config["dividend_tax_rate"] = ConfigValue(0.0)
    config["cash_return_by_stock_delisted"] = ConfigValue(True)
    config["auto_switch_order_value"] = ConfigValue(False)
    config["validate_stock_position"] = ConfigValue(True)
    config["validate_future_position"] = ConfigValue(True)
    config["financing_rate"] = ConfigValue(0.0)
    config["financing_stocks_restriction_enabled"] = ConfigValue(False)
    config["futures_settlement_price_type"] = ConfigValue("close")
    return config^


def get_cli_prefix() -> String:
    """Get CLI argument prefix, corresponds to Python cli_prefix variable.

    Python: cli_prefix = "mod__sys_accounts__"
    """
    return "mod__sys_accounts__"


def get_cli_options() -> List[Argument]:
    """Get CLI options list, corresponds to Python 5 click.Option registrations.

    Python original registers these via cli.commands['run'].params.append():
      1. click.Option(('--stock-t1/--no-stock-t1', prefix+'stock_t1'), default=None, ...)
      2. click.Option(('--dividend-reinvestment', prefix+'dividend_reinvestment'), default=None, is_flag=True, ...)
      3. click.Option(('--cash-return-by-stock-delisted/--no-cash-return-by-stock-delisted', ...), default=True, ...)
      4. click.Option(("--no-short-stock/--short-stock", prefix+'validate_stock_position'), is_flag=True, default=True, ...)
      5. click.Option(('--futures-settlement-price-type', prefix+'futures_settlement_price_type'), default=None, ...)
    """
    var options = List[Argument]()

    options.append(
        Argument(name="mod__sys_accounts__stock_t1", help="[sys_accounts] enable/disable stock T+1")
            .long["stock-t1"]().flag().negatable()
    )

    options.append(
        Argument(name="mod__sys_accounts__dividend_reinvestment", help="[sys_accounts] enable dividend reinvestment")
            .long["dividend-reinvestment"]().flag()
    )

    options.append(
        Argument(name="mod__sys_accounts__cash_return_by_stock_delisted", help="[sys_accounts] return cash when stock delisted")
            .long["cash-return-by-stock-delisted"]().flag().negatable()
    )

    options.append(
        Argument(name="mod__sys_accounts__validate_stock_position", help="[sys_accounts] enable stock shorting")
            .long["short-stock"]().flag().negatable()
    )

    options.append(
        Argument(name="mod__sys_accounts__futures_settlement_price_type", help="[sys_accounts] future settlement price")
            .long["futures-settlement-price-type"]().value_name["TYPE"]()
    )

    return options^


def register_cli_options(mut cmd: Command) raises -> None:
    """Register CLI options to command, corresponds to Python cli.commands['run'].params.append.

    Python original:
        cli.commands['run'].params.append(click.Option(...))
    Mojo equivalent:
        cmd.add_argument(option)
    """
    for option in get_cli_options():
        cmd.add_argument(option.copy())


def load_mod() -> AccountsMod:
    """Load module instance, corresponds to Python load_mod().

    Python original:
        def load_mod():
            from .mod import AccountMod
            return AccountMod()
    """
    return create_accounts_mod()


comptime __all__: List[String] = [
    "AccountsMod",
    "create_accounts_mod",
    "get_config",
    "get_cli_prefix",
    "get_cli_options",
    "register_cli_options",
    "load_mod",
]
