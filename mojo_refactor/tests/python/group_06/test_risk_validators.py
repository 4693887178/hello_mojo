"""
Python Integration Tests for Risk Validators
Compares Python rqalpha validator behavior with expected behavior patterns.
Tests the original Python implementation to establish baseline behavior.
"""

import pytest
from unittest.mock import Mock, MagicMock, patch


class TestCashValidatorPythonBehavior:
    """Baseline tests for Python CashValidator behavior."""

    def test_cash_validator_import(self):
        """Test CashValidator can be imported."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import CashValidator
        assert CashValidator is not None

    def test_cash_validate_sufficient_cash_returns_none(self):
        """Sufficient cash should return None (no error)."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.cash_validator import validate_cash

        env = Mock()
        instrument = Mock()
        instrument.calc_cash_occupation.return_value = 1000.0
        env.data_proxy.instrument_not_none.return_value = instrument

        order = Mock()
        order.order_book_id = "000001.XSHE"
        order.frozen_price = 10.0
        order.quantity = 100
        order.position_direction = "LONG"
        order.trading_datetime = Mock()
        order.trading_datetime.date.return_value = None
        order.estimated_transaction_cost = 5.0

        result = validate_cash(env, order, 10000.0)
        # 1000.0 + 5.0 = 1005.0 <= 10000.0 → None
        assert result is None

    def test_cash_validate_insufficient_cash_returns_error(self):
        """Insufficient cash should return error message."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators.cash_validator import validate_cash

        env = Mock()
        instrument = Mock()
        instrument.calc_cash_occupation.return_value = 1000.0
        env.data_proxy.instrument_not_none.return_value = instrument

        order = Mock()
        order.order_book_id = "000001.XSHE"
        order.frozen_price = 10.0
        order.quantity = 100
        order.position_direction = "LONG"
        order.trading_datetime = Mock()
        order.trading_datetime.date.return_value = None
        order.estimated_transaction_cost = 5.0

        result = validate_cash(env, order, 500.0)
        # 1000.0 + 5.0 = 1005.0 > 500.0 → error
        assert result is not None
        assert "not enough money" in str(result)

    def test_cash_submission_none_account_returns_none(self):
        """None account should skip validation and return None."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import CashValidator

        env = Mock()
        validator = CashValidator(env)

        order = Mock()
        order.position_effect = "OPEN"
        result = validator.validate_submission(order, account=None)
        assert result is None

    def test_cash_submission_close_position_skips_validation(self):
        """CLOSE position effect should skip cash validation."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import CashValidator

        env = Mock()
        validator = CashValidator(env)

        order = Mock()
        order.position_effect = "CLOSE"

        mock_account = Mock()
        result = validator.validate_submission(order, account=mock_account)
        assert result is None

    def test_cash_cancellation_always_none(self):
        """validate_cancellation always returns None for CashValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import CashValidator

        env = Mock()
        validator = CashValidator(env)

        order = Mock()
        mock_account = Mock()
        result = validator.validate_cancellation(order, account=mock_account)
        assert result is None


class TestPriceValidatorPythonBehavior:
    """Baseline tests for Python PriceValidator behavior."""

    def test_price_validator_import(self):
        """Test PriceValidator can be imported."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator
        assert PriceValidator is not None

    def test_price_within_limits_returns_none(self):
        """Price within limit range should return None."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator

        env = Mock()
        env.price_board.get_limit_up.return_value = 11.0
        env.price_board.get_limit_down.return_value = 9.0

        validator = PriceValidator(env)

        order = Mock()
        order.type = "LIMIT"
        order.order_book_id = "000001.XSHE"
        order.price = 10.5
        order.position_effect = "OPEN"

        result = validator.validate_submission(order, account=None)
        assert result is None

    def test_price_above_limit_up_returns_error(self):
        """Price above limit up should return error."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator

        env = Mock()
        env.price_board.get_limit_up.return_value = 11.0
        env.price_board.get_limit_down.return_value = 9.0

        validator = PriceValidator(env)

        order = Mock()
        order.type = "LIMIT"
        order.order_book_id = "000001.XSHE"
        order.price = 12.0
        order.position_effect = "OPEN"

        result = validator.validate_submission(order, account=None)
        assert result is not None
        assert "higher than limit up" in str(result)

    def test_price_below_limit_down_returns_error(self):
        """Price below limit down should return error."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator

        env = Mock()
        env.price_board.get_limit_up.return_value = 11.0
        env.price_board.get_limit_down.return_value = 9.0

        validator = PriceValidator(env)

        order = Mock()
        order.type = "LIMIT"
        order.order_book_id = "000001.XSHE"
        order.price = 8.0
        order.position_effect = "OPEN"

        result = validator.validate_submission(order, account=None)
        assert result is not None
        assert "lower than limit down" in str(result)

    def test_market_order_skips_price_validation(self):
        """Market orders should skip price validation."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator

        env = Mock()
        validator = PriceValidator(env)

        order = Mock()
        order.type = "MARKET"
        order.position_effect = "OPEN"

        result = validator.validate_submission(order, account=None)
        assert result is None

    def test_exercise_skips_price_validation(self):
        """EXERCISE position effect should skip price validation."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator

        env = Mock()
        validator = PriceValidator(env)

        order = Mock()
        order.type = "LIMIT"
        order.position_effect = "EXERCISE"

        result = validator.validate_submission(order, account=None)
        assert result is None

    def test_price_cancellation_always_none(self):
        """validate_cancellation always returns None for PriceValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import PriceValidator

        env = Mock()
        validator = PriceValidator(env)

        order = Mock()
        result = validator.validate_cancellation(order, account=None)
        assert result is None


class TestIsTradingValidatorPythonBehavior:
    """Baseline tests for Python IsTradingValidator behavior."""

    def test_is_trading_validator_import(self):
        """Test IsTradingValidator can be imported."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import IsTradingValidator
        assert IsTradingValidator is not None

    def test_normal_instrument_returns_none(self):
        """Normal trading instrument should return None."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import IsTradingValidator

        env = Mock()

        mock_instrument = Mock()
        mock_instrument.type = "CS"
        env.data_proxy.get_active_instrument.return_value = mock_instrument
        env.data_proxy.is_suspended.return_value = False

        validator = IsTradingValidator(env)

        order = Mock()
        order.order_book_id = "000001.XSHE"

        result = validator.validate_submission(order, account=None)
        assert result is None

    def test_suspended_cs_stock_returns_error(self):
        """Suspended CS stock should return error."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import IsTradingValidator
        from datetime import date

        env = Mock()

        mock_instrument = Mock()
        mock_instrument.type = "CS"
        env.data_proxy.get_active_instrument.return_value = mock_instrument
        env.data_proxy.is_suspended.return_value = True

        validator = IsTradingValidator(env)

        order = Mock()
        order.order_book_id = "000001.XSHE"

        result = validator.validate_submission(order, account=None)
        assert result is not None
        assert "suspended" in str(result)

    def test_non_cs_type_passes_even_if_suspended(self):
        """Non-CS instruments should pass even if suspended check runs."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import IsTradingValidator

        env = Mock()

        mock_instrument = Mock()
        mock_instrument.type = "FUTURE"
        env.data_proxy.get_active_instrument.return_value = mock_instrument

        validator = IsTradingValidator(env)

        order = Mock()
        order.order_book_id = "RB1912"

        result = validator.validate_submission(order, account=None)
        assert result is None

    def test_is_trading_cancellation_always_none(self):
        """validate_cancellation always returns None for IsTradingValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import IsTradingValidator

        env = Mock()
        validator = IsTradingValidator(env)

        order = Mock()
        result = validator.validate_cancellation(order, account=None)
        assert result is None


class TestSelfTradeValidatorPythonBehavior:
    """Baseline tests for Python SelfTradeValidator behavior."""

    def test_self_trade_validator_import(self):
        """Test SelfTradeValidator can be imported."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator
        assert SelfTradeValidator is not None

    def test_no_open_orders_returns_none(self):
        """No open orders means no self-trade risk → None."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator

        env = Mock()
        env.get_open_orders.return_value = []

        validator = SelfTradeValidator(env)

        buy_order = Mock()
        buy_order.order_book_id = "000001.XSHE"
        buy_order.side = "BUY"
        buy_order.type = "LIMIT"
        buy_order.position_effect = "OPEN"

        result = validator.validate_submission(buy_order, account=None)
        assert result is None

    def test_market_order_with_conflicting_sell_triggers_warning(self):
        """Market BUY with open SELL order triggers self-trade warning."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator

        sell_order = Mock()
        sell_order.order_id = 100
        sell_order.order_book_id = "000001.XSHE"
        sell_order.side = "SELL"
        sell_order.position_effect = "OPEN"

        env = Mock()
        env.get_open_orders.return_value = [sell_order]

        validator = SelfTradeValidator(env)

        market_buy = Mock()
        market_buy.order_book_id = "000001.XSHE"
        market_buy.side = "BUY"
        market_buy.type = "MARKET"
        market_buy.position_effect = "OPEN"

        result = validator.validate_submission(market_buy, account=None)
        assert result is not None
        assert "self-trade" in str(result)

    def test_same_side_ignored(self):
        """Same-side open orders should be ignored."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator

        other_buy = Mock()
        other_buy.order_id = 103
        other_buy.order_book_id = "000001.XSHE"
        other_buy.side = "BUY"
        other_buy.position_effect = "OPEN"

        env = Mock()
        env.get_open_orders.return_value = [other_buy]

        validator = SelfTradeValidator(env)

        buy_order = Mock()
        buy_order.order_book_id = "000001.XSHE"
        buy_order.side = "BUY"
        buy_order.type = "LIMIT"
        buy_order.position_effect = "OPEN"

        result = validator.validate_submission(buy_order, account=None)
        assert result is None

    def test_exercise_orders_ignored(self):
        """EXERCISE position effect orders ignored as conflicting."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator

        exercise_sell = Mock()
        exercise_sell.order_id = 104
        exercise_sell.order_book_id = "000001.XSHE"
        exercise_sell.side = "SELL"
        exercise_sell.position_effect = "EXERCISE"

        env = Mock()
        env.get_open_orders.return_value = [exercise_sell]

        validator = SelfTradeValidator(env)

        buy_order = Mock()
        buy_order.order_book_id = "000001.XSHE"
        buy_order.side = "BUY"
        buy_order.type = "LIMIT"
        buy_order.position_effect = "OPEN"

        result = validator.validate_submission(buy_order, account=None)
        assert result is None

    def test_self_trade_cancellation_always_none(self):
        """validate_cancellation always returns None for SelfTradeValidator."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import SelfTradeValidator

        env = Mock()
        validator = SelfTradeValidator(env)

        order = Mock()
        result = validator.validate_cancellation(order, account=None)
        assert result is None


class TestValidatorsInitExports:
    """Test __init__.py exports all 4 validators."""

    def test_all_validators_exported_from_init(self):
        """All 4 validators should be importable from __init__."""
        from rqalpha.mod.rqalpha_mod_sys_risk.validators import (
            CashValidator,
            PriceValidator,
            IsTradingValidator,
            SelfTradeValidator,
        )

        assert CashValidator is not None
        assert PriceValidator is not None
        assert IsTradingValidator is not None
        assert SelfTradeValidator is not None


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
