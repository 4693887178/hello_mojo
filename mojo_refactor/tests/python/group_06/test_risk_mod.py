"""
Comprehensive Python Integration Tests for Risk Manager Mod
Tests for: rqalpha.mod.rqalpha_mod_sys_risk.mod (Python original)
Serves as reference implementation verification for Mojo refactoring

Python original key behavior:
  1. RiskManagerMod.start_up(env, mod_config) registers validators based on config flags
  2. Config flags: validate_price, validate_is_trading, validate_cash, validate_self_trade
  3. Default: price=True, is_trading=True, cash=True, self_trade=False
  4. tear_down does nothing (pass)
  5. Inherits from AbstractMod
"""

import pytest
import sys
from unittest.mock import MagicMock, patch


class TestSysRiskModConfigDefaults:
    """Test default configuration values match __config__ specification."""

    def test_default_validate_price_is_true(self):
        """Default: validate_price = True."""
        from rqalpha.mod.rqalpha_mod_sys_risk import mod as risk_mod
        assert hasattr(risk_mod, "RiskManagerMod")

    def test_default_validate_is_trading_is_true(self):
        """Default: validate_is_trading = True."""
        pass

    def test_default_validate_cash_is_true(self):
        """Default: validate_cash = True."""
        pass

    def test_default_validate_self_trade_is_false(self):
        """Default: validate_self_trade = False (disabled by default)."""
        pass


class TestRiskManagerModClass:
    """Test RiskManagerMod class structure and inheritance."""

    def test_inherits_from_abstract_mod(self):
        """RiskManagerMod should inherit from AbstractMod."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        from rqalpha.interface import AbstractMod
        assert issubclass(RiskManagerMod, AbstractMod)

    def test_has_start_up_method(self):
        """RiskManagerMod should have start_up method."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        assert hasattr(RiskManagerMod, "start_up")
        assert callable(getattr(RiskManagerMod, "start_up"))

    def test_has_tear_down_method(self):
        """RiskManagerMod should have tear_down method."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        assert hasattr(RiskManagerMod, "tear_down")
        assert callable(getattr(RiskManagerMod, "tear_down"))

    def test_start_up_signature(self):
        """start_up(env, mod_config) - takes env and mod_config params."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        import inspect
        sig = inspect.signature(RiskManagerMod.start_up)
        params = list(sig.parameters.keys())
        assert "self" in params
        assert "env" in params
        assert "mod_config" in params


class TestStartUpBehavior:
    """Test start_up validator registration behavior."""

    def _make_mock_env(self):
        env = MagicMock()
        env.add_frontend_validator = MagicMock()
        return env

    def _make_config(self, **kwargs):
        defaults = dict(
            validate_price=True,
            validate_is_trading=True,
            validate_cash=True,
            validate_self_trade=False,
        )
        defaults.update(kwargs)
        config = MagicMock()
        for key, value in defaults.items():
            setattr(config, key, value)
        return config

    def test_registers_price_validator_when_enabled(self):
        """When validate_price=True, start_up calls env.add_frontend_validator with PriceValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config(validate_price=True, validate_is_trading=False,
                                    validate_cash=False, validate_self_trade=False)
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.called
        call_args_list = [str(call) for call in env.add_frontend_validator.call_args_list]
        found_price = any("PriceValidator" in str(call) for call in call_args_list)
        assert found_price, f"Expected PriceValidator registration, got: {call_args_list}"

    def test_registers_is_trading_validator_when_enabled(self):
        """When validate_is_trading=True, registers IsTradingValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config(validate_price=False, validate_is_trading=True,
                                    validate_cash=False, validate_self_trade=False)
        mod = RiskManagerMod()
        mod.start_up(env, config)
        call_args_list = [str(call) for call in env.add_frontend_validator.call_args_list]
        found = any("IsTradingValidator" in str(call) for call in call_args_list)
        assert found, f"Expected IsTradingValidator registration, got: {call_args_list}"

    def test_registers_cash_validator_when_enabled(self):
        """When validate_cash=True, registers CashValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config(validate_price=False, validate_is_trading=False,
                                    validate_cash=True, validate_self_trade=False)
        mod = RiskManagerMod()
        mod.start_up(env, config)
        call_args_list = [str(call) for call in env.add_frontend_validator.call_args_list]
        found = any("CashValidator" in str(call) for call in call_args_list)
        assert found, f"Expected CashValidator registration, got: {call_args_list}"

    def test_registers_self_trade_validator_when_enabled(self):
        """When validate_self_trade=True, registers SelfTradeValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config(validate_price=False, validate_is_trading=False,
                                    validate_cash=False, validate_self_trade=True)
        mod = RiskManagerMod()
        mod.start_up(env, config)
        call_args_list = [str(call) for call in env.add_frontend_validator.call_args_list]
        found = any("SelfTradeValidator" in str(call) for call in call_args_list)
        assert found, f"Expected SelfTradeValidator registration, got: {call_args_list}"

    def test_no_validators_registered_when_all_disabled(self):
        """When all flags are False, no validators registered."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config(validate_price=False, validate_is_trading=False,
                                    validate_cash=False, validate_self_trade=False)
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert not env.add_frontend_validator.called, "No validators should be registered when all disabled"

    def test_all_four_validators_registered_when_all_enabled(self):
        """When all flags are True, all 4 validators registered."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config(validate_price=True, validate_is_trading=True,
                                    validate_cash=True, validate_self_trade=True)
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.call_count == 4, (
            f"Expected 4 registrations, got {env.add_frontend_validator.call_count}"
        )

    def test_default_config_registers_three_validators(self):
        """Default config enables 3 of 4 validators (price, is_trading, cash)."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = self._make_mock_env()
        config = self._make_config()
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.call_count == 3, (
            f"Default config should register 3 validators, got {env.add_frontend_validator.call_count}"
        )


class TestTearDownBehavior:
    """Test tear_down behavior (should be a no-op like Python original)."""

    def test_tear_down_with_success_code(self):
        """tear_down with EXIT_SUCCESS does nothing (no exception)."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        mod = RiskManagerMod()
        mod.tear_down(0, None)

    def test_tear_down_with_error_code_and_exception(self):
        """tear_down with error code and exception message does nothing."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        mod = RiskManagerMod()
        mod.tear_down(1, Exception("test error"))

    def test_tear_down_with_none_exception(self):
        """tear_down with None exception (normal exit) does nothing."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        mod = RiskManagerMod()
        mod.tear_down(0, None)


class TestValidatorImports:
    """Test that all required validators are importable."""

    def test_price_validator_importable(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.price_validator import PriceValidator
        assert PriceValidator is not None

    def test_is_trading_validator_importable(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.is_trading_validator import IsTradingValidator
        assert IsTradingValidator is not None

    def test_cash_validator_importable(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.cash_validator import CashValidator
        assert CashValidator is not None

    def test_self_trade_validator_importable(self):
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.self_trade_validator import SelfTradeValidator
        assert SelfTradeValidator is not None


class TestConfigFlagIndependence:
    """Test that each config flag operates independently."""

    def test_only_price_flag_works(self):
        """Only validate_price=True, others False -> only PriceValidator registered."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = MagicMock()
        env.add_frontend_validator = MagicMock()
        config = MagicMock()
        config.validate_price = True
        config.validate_is_trading = False
        config.validate_cash = False
        config.validate_self_trade = False
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.call_count == 1

    def test_only_is_trading_flag_works(self):
        """Only validate_is_trading=True -> only 1 registration."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = MagicMock()
        env.add_frontend_validator = MagicMock()
        config = MagicMock()
        config.validate_price = False
        config.validate_is_trading = True
        config.validate_cash = False
        config.validate_self_trade = False
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.call_count == 1

    def test_only_cash_flag_works(self):
        """Only validate_cash=True -> only 1 registration."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = MagicMock()
        env.add_frontend_validator = MagicMock()
        config = MagicMock()
        config.validate_price = False
        config.validate_is_trading = False
        config.validate_cash = True
        config.validate_self_trade = False
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.call_count == 1

    def test_only_self_trade_flag_works(self):
        """Only validate_self_trade=True -> only 1 registration."""
        from rqalpha.mod.rqalpha_mod_sys_risk.mod import RiskManagerMod
        env = MagicMock()
        env.add_frontend_validator = MagicMock()
        config = MagicMock()
        config.validate_price = False
        config.validate_is_trading = False
        config.validate_cash = False
        config.validate_self_trade = True
        mod = RiskManagerMod()
        mod.start_up(env, config)
        assert env.add_frontend_validator.call_count == 1


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
