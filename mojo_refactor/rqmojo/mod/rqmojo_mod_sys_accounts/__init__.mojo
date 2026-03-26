"""
RQAlpha Mojo - System Accounts Module
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/__init__.py
"""

from python import click
from rqmojo import cli
from .mod import AccountsMod, create_accounts_mod


comptime __config__ = {
    "stock_t1": True,
    "dividend_reinvestment": False,
    "dividend_tax_rate": 0.0,
    "cash_return_by_stock_delisted": True,
    "auto_switch_order_value": False,
    "validate_stock_position": True,
    "validate_future_position": True,
    "financing_rate": 0.0,
    "financing_stocks_restriction_enabled": False,
    "futures_settlement_price_type": "close",
}


def load_mod() -> AccountsMod:
    return create_accounts_mod()


def get_cli_prefix() -> String:
    return "mod__sys_accounts__"
