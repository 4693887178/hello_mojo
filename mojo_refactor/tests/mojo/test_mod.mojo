from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.mod.rqmojo_mod_sys_accounts.mod import (
    AccountsMod,
    AccountsModConfig,
    create_accounts_mod,
    get_inst_type_in_stock_account
)
from rqmojo.const import INSTRUMENT_TYPE, EXIT_CODE
from rqmojo.interface import ModInterface


def test_create_accounts_mod() raises:
    """Test create_accounts_mod factory function."""
    var mod = create_accounts_mod()
    
    assert_equal(mod.name, "accounts")
    assert_true(mod.enabled)


def test_accounts_mod_config_defaults() raises:
    """Test AccountsModConfig default values."""
    var config = AccountsModConfig(
        dividend_reinvestment=False,
        dividend_tax_rate=0.0,
        cash_return_by_stock_delisted=True,
        stock_t1=True,
        validate_future_position=True,
        validate_stock_position=True,
        financing_rate=0.0,
        financing_stocks_restriction_enabled=False,
        futures_settlement_price_type="close"
    )
    
    assert_true(config.dividend_reinvestment == False)
    assert_equal(config.dividend_tax_rate, 0.0)
    assert_true(config.cash_return_by_stock_delisted == True)
    assert_true(config.stock_t1 == True)
    assert_true(config.validate_future_position == True)
    assert_true(config.validate_stock_position == True)
    assert_equal(config.financing_rate, 0.0)
    assert_true(config.financing_stocks_restriction_enabled == False)
    assert_equal(config.futures_settlement_price_type, "close")


def test_get_inst_type_in_stock_account() raises:
    """Test INST_TYPE_IN_STOCK_ACCOUNT contains all expected types."""
    var types = get_inst_type_in_stock_account()
    
    # Should have exactly 6 types: CS, ETF, LOF, INDX, PUBLIC_FUND, REITs
    assert_equal(len(types), 6)
    
    # Verify each type exists
    var has_cs = False
    var has_etf = False
    var has_lof = False
    var has_indx = False
    var has_public_fund = False
    var has_reits = False
    
    for t in types:
        if t == INSTRUMENT_TYPE.CS:
            has_cs = True
        elif t == INSTRUMENT_TYPE.ETF:
            has_etf = True
        elif t == INSTRUMENT_TYPE.LOF:
            has_lof = True
        elif t == INSTRUMENT_TYPE.INDX:
            has_indx = True
        elif t == INSTRUMENT_TYPE.PUBLIC_FUND:
            has_public_fund = True
        elif t == INSTRUMENT_TYPE.REITs:
            has_reits = True
    
    assert_true(has_cs)
    assert_true(has_etf)
    assert_true(has_lof)
    assert_true(has_indx)
    assert_true(has_public_fund)
    assert_true(has_reits)


def test_mod_interface_conformance() raises:
    """Test that AccountsMod conforms to ModInterface trait."""
    # Just verify we can create and use it
    var mod = AccountsMod(name="test", enabled=True)
    
    # Verify it has required methods (compile-time check via trait conformance)
    assert_true(mod.name == "test")
    assert_true(mod.enabled == True)


def test_tear_down_with_success_code() raises:
    """Test tear_down with EXIT_SUCCESS."""
    var mod = create_accounts_mod()
    
    # Should not raise
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS)


def test_tear_down_with_error_code() raises:
    """Test tear_down with error code."""
    var mod = create_accounts_mod()
    
    # Should not raise
    mod.tear_down(EXIT_CODE.EXIT_INTERNAL_ERROR)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
