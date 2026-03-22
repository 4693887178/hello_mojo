"""
RQAlpha Mojo - Accounts Mod
Ported from rqalpha/mod/rqalpha_mod_sys_accounts/
"""

from rqmojo.const import DEFAULT_ACCOUNT_TYPE
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account


@fieldwise_init
struct AccountsMod(Copyable, Movable, ImplicitlyCopyable):
    var name: String
    var enabled: Bool
    var account_count: Int
    
    def __str__(self) -> String:
        return "AccountsMod(" + self.name + ", accounts=" + String(self.account_count) + ")"
    
    def start(self) -> None:
        pass
    
    def stop(self) -> None:
        pass


struct AccountProxy:
    var _account_type: DEFAULT_ACCOUNT_TYPE
    var _total_cash: Float64
    var _total_value: Float64
    
    def __init__(account_type: DEFAULT_ACCOUNT_TYPE, cash: Float64) -> Self:
        return Self {
            _account_type: account_type,
            _total_cash: cash,
            _total_value: cash
        }
    
    def account_type(self) -> DEFAULT_ACCOUNT_TYPE:
        return self._account_type
    
    def total_cash(self) -> Float64:
        return self._total_cash
    
    def total_value(self) -> Float64:
        return self._total_value


def create_accounts_mod() -> AccountsMod:
    return AccountsMod(name="accounts", enabled=True, account_count=0)


def create_account_proxy(account_type: DEFAULT_ACCOUNT_TYPE, cash: Float64) -> AccountProxy:
    return AccountProxy(account_type=account_type, cash=cash)
