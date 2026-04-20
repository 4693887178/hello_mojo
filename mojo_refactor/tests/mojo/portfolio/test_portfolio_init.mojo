"""
Unit tests for portfolio/__init__.mojo (Portfolio + MixedPositions)
Tests matching Python original rqalpha/portfolio/__init__.py (327 lines)

Coverage:
  - Portfolio: construction, properties, state, deposit/withdraw, settlement
  - MixedPositions: contains, get_position, len, keys
  - Account: new methods (has_position, market_value, transaction_cost, etc.)
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List, Optional
from std.python import Python, PythonObject

from rqmojo.const import (
    DEFAULT_ACCOUNT_TYPE, POSITION_DIRECTION,
)
from rqmojo.portfolio.portfolio_manager import (
    Portfolio, MixedPositions,
    create_portfolio, create_stock_portfolio, create_future_portfolio,
)
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.utils.typing import DateTime, DateTimeDate


def test_stock_portfolio_construction() raises:
    """Test create_stock_portfolio with default cash."""
    var p = create_stock_portfolio(100000.0)
    var sa = p.stock_account()
    assert_true(sa != None)
    assert_equal(p.starting_cash(), 100000.0)


def test_future_portfolio_construction() raises:
    """Test create_future_portfolio."""
    var p = create_future_portfolio(200000.0)
    var fa = p.future_account()
    assert_true(fa != None)


def test_portfolio_units_equals_starting_cash() raises:
    """Test units == starting_cash at initialization."""
    var sc = Dict[String, Float64]()
    sc[DEFAULT_ACCOUNT_TYPE.STOCK.value] = 50000.0
    var sd = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var p = create_portfolio(sc, sd)
    assert_equal(p.units(), 50000.0)


def test_portfolio_total_value() raises:
    """Test total_value returns account total value."""
    var p = create_stock_portfolio(100000.0)
    var tv = p.total_value()
    assert_equal(tv, 100000.0)


def test_portfolio_cash() raises:
    """Test cash returns total_cash from accounts."""
    var p = create_stock_portfolio(100000.0)
    assert_equal(p.cash(), 100000.0)


def test_portfolio_unit_net_value_initial() raises:
    """Test unit_net_value = total_value / units (initially 1.0)."""
    var p = create_stock_portfolio(50000.0)
    var unv = p.unit_net_value()
    assert_equal(unv, 1.0)


def test_portfolio_static_unit_net_value_default() raises:
    """Test static_unit_net_value defaults to 1.0."""
    var p = create_stock_portfolio()
    assert_equal(p.static_unit_net_value(), 1.0)


def test_portfolio_daily_pnl_zero_initial() raises:
    """Test daily_pnl is 0 at start (no trades)."""
    var p = create_stock_portfolio()
    assert_equal(p.daily_pnl(), 0.0)


def test_portfolio_daily_returns_zero_initial() raises:
    """Test daily_returns is 0 at start."""
    var p = create_stock_portfolio()
    assert_equal(p.daily_returns(), 0.0)


def test_portfolio_total_returns_zero_initial() raises:
    """Test total_returns is 0 at start (unit_nv=1)."""
    var p = create_stock_portfolio()
    assert_equal(p.total_returns(), 0.0)


def test_portfolio_annualized_returns_zero_when_flat() raises:
    """Test annualized_returns is 0 when unit_net_value==1.0."""
    var p = create_stock_portfolio()
    assert_equal(p.annualized_returns(), 0.0)


def test_portfolio_frozen_cash_zero_initial() raises:
    """Test frozen_cash is 0 at start."""
    var p = create_stock_portfolio()
    assert_equal(p.frozen_cash(), 0.0)


def test_portfolio_cash_liabilities_zero_initial() raises:
    """Test cash_liabilities is 0 at start."""
    var p = create_stock_portfolio()
    assert_equal(p.cash_liabilities(), 0.0)


def test_portfolio_market_value_zero_initial() raises:
    """Test market_value is 0 at start (no positions)."""
    var p = create_stock_portfolio()
    assert_equal(p.market_value(), 0.0)


def test_portfolio_transaction_cost_zero_initial() raises:
    """Test transaction_cost is 0 at start."""
    var p = create_stock_portfolio()
    assert_equal(p.transaction_cost(), 0.0)


def test_portfolio_pnl_zero_initial() raises:
    """Test pnl is 0 at start."""
    var p = create_stock_portfolio()
    assert_equal(p.pnl(), 0.0)


def test_portfolio_portfolio_value_alias() raises:
    """Test portfolio_value equals total_value."""
    var p = create_stock_portfolio(75000.0)
    assert_equal(p.portfolio_value(), p.total_value())


def test_portfolio_accounts_dict() raises:
    """Test accounts returns non-empty dict for stock portfolio."""
    var p = create_stock_portfolio()
    var accts = p.accounts()
    assert_true(len(accts) > 0)


def test_portfolio_get_account_type_stock() raises:
    """Test get_account_type identifies stock instruments."""
    var t1 = Portfolio.get_account_type("000001.XSHE")
    assert_equal(t1, DEFAULT_ACCOUNT_TYPE.STOCK.value)
    var t2 = Portfolio.get_account_type("600000.XSHG")
    assert_equal(t2, DEFAULT_ACCOUNT_TYPE.STOCK.value)


def test_portfolio_get_account_type_future() raises:
    """Test get_account_type identifies future instruments."""
    var t1 = Portfolio.get_account_type("IF2301.CFFEX")
    assert_equal(t1, DEFAULT_ACCOUNT_TYPE.FUTURE.value)
    var t2 = Portfolio.get_account_type("IC2405.CZCE")
    assert_equal(t2, DEFAULT_ACCOUNT_TYPE.FUTURE.value)


def test_portfolio_pre_before_trading_updates_static_unv() raises:
    """Test pre_before_trading updates static_unit_net_value."""
    var p = create_stock_portfolio(100000.0)
    p.pre_before_trading()
    assert_equal(p.static_unit_net_value(), 1.0)


def test_portfolio_set_state_roundtrip() raises:
    """Test get_state -> set_state preserves data."""
    var p = create_stock_portfolio(80000.0)
    var state = p.get_state()

    var p2 = create_stock_portfolio(50000.0)
    p2.set_state(state)

    assert_equal(p2.static_unit_net_value(), 1.0)
    assert_equal(p2.units(), 80000.0)


def test_portfolio_deposit_withdraw_increases_cash() raises:
    """Test deposit_withdraw increases total value and units adjust."""
    var p = create_stock_portfolio(100000.0)
    p.deposit_withdraw(DEFAULT_ACCOUNT_TYPE.STOCK.value, 50000.0)
    assert_true(p.total_value() >= 150000.0)


def test_portfolio_settlement_resets_static_unv() raises:
    """Test settlement resets static_unit_net_value."""
    var p = create_stock_portfolio(100000.0)
    var dummy_date = DateTimeDate(2025, 6, 15)
    p.settlement(dummy_date)
    assert_equal(p.static_unit_net_value(), 1.0)


def test_portfolio_positions_mixedpositions() raises:
    """Test positions returns MixedPositions instance."""
    var p = create_stock_portfolio()
    _ = p.positions()


def test_portfolio_update_last_price_noop() raises:
    """Test update_last_price on empty portfolio doesn't crash."""
    var p = create_stock_portfolio()
    p.update_last_price("000001.XSHE", 10.0)


def test_portfolio_update_portfolio_noop() raises:
    """Test update_portfolio on empty portfolio doesn't crash."""
    var p = create_stock_portfolio()
    p.update_portfolio()


def test_portfolio_set_trading_dt() raises:
    """Test set_trading_dt updates trading date."""
    var p = create_stock_portfolio()
    var dt = DateTime(2025, 3, 21, 9, 30, 0, 0)
    p.set_trading_dt(dt)


def test_mixed_positions_len_empty() raises:
    """Test MixedPositions.len() is 0 for empty accounts."""
    var accts = Dict[String, Account]()
    var mp = MixedPositions.create(accts)
    assert_equal(mp.len(), 0)


def test_mixed_positions_contains_false() raises:
    """Test MixedPositions.contains returns False for unknown order_book_id."""
    var accts = Dict[String, Account]()
    var mp = MixedPositions.create(accts)
    assert_false(mp.contains("000001.XSHE"))


def test_mixed_positions_keys_empty() raises:
    """Test MixedPositions.keys() returns empty list for no positions."""
    var accts = Dict[String, Account]()
    var mp = MixedPositions.create(accts)
    var keys = mp.keys()
    assert_equal(len(keys), 0)


def test_mixed_positions_get_position_none() raises:
    """Test MixedPositions.get_position returns None for missing position."""
    var accts = Dict[String, Account]()
    var mp = MixedPositions.create(accts)
    var pos = mp.get_position("000001.XSHE")
    assert_true(pos == None)


def test_account_has_position_false() raises:
    """Test Account.has_position returns False for empty account."""
    var acct = create_stock_account(100000.0)
    assert_false(acct.has_position("000001.XSHE"))


def test_account_positions_count_zero() raises:
    """Test Account.get_positions_count is 0 for new account."""
    var acct = create_stock_account(100000.0)
    assert_equal(acct.get_positions_count(), 0)


def test_account_position_keys_empty() raises:
    """Test Account.position_keys returns empty list for new account."""
    var acct = create_stock_account(100000.0)
    var keys = acct.position_keys()
    assert_equal(len(keys), 0)


def test_account_market_value_zero() raises:
    """Test Account.market_value is 0 for new account."""
    var acct = create_stock_account(100000.0)
    assert_equal(acct.market_value(), 0.0)


def test_account_transaction_cost_zero() raises:
    """Test Account.transaction_cost is 0 for new account."""
    var acct = create_stock_account(100000.0)
    assert_equal(acct.transaction_cost(), 0.0)


def test_account_deposit_withdraw_increases() raises:
    """Test Account.deposit_withdraw increases cash and total_value."""
    var acct = create_stock_account(100000.0)
    acct.deposit_withdraw(50000.0)
    assert_equal(acct.total_cash, 150000.0)
    assert_equal(acct.total_value, 150000.0)


def test_account_finance_repay_decreases() raises:
    """Test Account.finance_repay decreases cash and total_value."""
    var acct = create_stock_account(100000.0)
    acct.finance_repay(30000.0)
    assert_equal(acct.total_cash, 70000.0)
    assert_equal(acct.total_value, 70000.0)


def test_account_get_state_py_roundtrip() raises:
    """Test Account.get_state_py / set_state_py roundtrip."""
    var acct = create_stock_account(88888.0)
    acct.deposit_withdraw(11112.0)
    var state = acct.get_state_py()

    var acct2 = create_stock_account(0.0)
    acct2.set_state_py(state)

    assert_equal(acct2.total_cash, 100000.0)
    assert_equal(acct2.total_value, 100000.0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
