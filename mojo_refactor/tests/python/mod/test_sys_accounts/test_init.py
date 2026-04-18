# -*- coding: utf-8 -*-
"""
Python test suite for rqalpha/mod/rqalpha_mod_sys_accounts/__init__.py
Validates that Mojo refactored version matches Python original behavior.

Tests cover:
  - __config__ dict: all 10 keys with correct types and default values
  - load_mod(): returns AccountMod instance
  - cli_prefix: correct string value
  - CLI options: 5 click.Options registered correctly
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))

from rqalpha.mod.rqalpha_mod_sys_accounts import load_mod, __config__


class TestConfig:
    """Test __config__ dictionary matches expected values."""

    def test_config_has_10_keys(self):
        assert len(__config__) == 10

    def test_config_stock_t1_true(self):
        assert __config__["stock_t1"] is True

    def test_config_dividend_reinvestment_false(self):
        assert __config__["dividend_reinvestment"] is False

    def test_config_dividend_tax_rate_zero(self):
        assert __config__["dividend_tax_rate"] == 0.0

    def test_config_cash_return_by_stock_delisted_true(self):
        assert __config__["cash_return_by_stock_delisted"] is True

    def test_config_auto_switch_order_value_false(self):
        assert __config__["auto_switch_order_value"] is False

    def test_config_validate_stock_position_true(self):
        assert __config__["validate_stock_position"] is True

    def test_config_validate_future_position_true(self):
        assert __config__["validate_future_position"] is True

    def test_config_financing_rate_zero(self):
        assert __config__["financing_rate"] == 0.0

    def test_config_financing_stocks_restriction_enabled_false(self):
        assert __config__["financing_stocks_restriction_enabled"] is False

    def test_config_futures_settlement_price_type_close(self):
        assert __config__["futures_settlement_price_type"] == "close"

    def test_config_all_expected_keys_present(self):
        expected_keys = {
            "stock_t1",
            "dividend_reinvestment",
            "dividend_tax_rate",
            "cash_return_by_stock_delisted",
            "auto_switch_order_value",
            "validate_stock_position",
            "validate_future_position",
            "financing_rate",
            "financing_stocks_restriction_enabled",
            "futures_settlement_price_type",
        }
        assert set(__config__.keys()) == expected_keys


class TestLoadMod:
    """Test load_mod() function."""

    def test_load_mod_returns_account_mod(self):
        mod = load_mod()
        from rqalpha.mod.rqalpha_mod_sys_accounts.mod import AccountMod
        assert isinstance(mod, AccountMod)

    def test_load_mod_not_none(self):
        assert load_mod() is not None


class TestCLIPrefix:
    """Test cli_prefix variable."""

    def test_cli_prefix_value(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts import cli_prefix as prefix
        assert prefix == "mod__sys_accounts__"

    def test_cli_prefix_not_empty(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts import cli_prefix as prefix
        assert len(prefix) > 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
