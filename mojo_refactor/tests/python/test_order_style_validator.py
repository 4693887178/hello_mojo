"""
Python comparison test for validator.py
Verifies that the Python OrderStyleValidator behavior matches the expected Mojo behavior.
Uses mocking to avoid Environment initialization dependency.
"""

import pytest
from unittest.mock import patch, MagicMock
from rqalpha.mod.rqalpha_mod_sys_simulation.validator import OrderStyleValidator
from rqalpha.model.order import Order, MarketOrder, LimitOrder, VWAPOrder, TWAPOrder, ALGO_ORDER_STYLES
from rqalpha.const import SIDE, POSITION_EFFECT, ORDER_TYPE


def _make_mock_order(style):
    order = MagicMock(spec=Order)
    order.style = style
    return order


class TestOrderStyleValidatorPython:
    """Test Python validator to confirm behavioral baseline for Mojo port."""

    def test_validator_init_default(self):
        validator = OrderStyleValidator(frequency="1d")
        assert validator._frequency == "1d"

    def test_validator_init_1m(self):
        validator = OrderStyleValidator(frequency="1m")
        assert validator._frequency == "1m"

    def test_validator_init_tick(self):
        validator = OrderStyleValidator(frequency="tick")
        assert validator._frequency == "tick"

    def test_validate_submission_market_order_1d(self):
        validator = OrderStyleValidator(frequency="1d")
        order = _make_mock_order(MarketOrder())
        result = validator.validate_submission(order)
        assert result is None

    def test_validate_submission_market_order_1m(self):
        validator = OrderStyleValidator(frequency="1m")
        order = _make_mock_order(MarketOrder())
        result = validator.validate_submission(order)
        assert result is None

    def test_validate_submission_market_order_tick(self):
        validator = OrderStyleValidator(frequency="tick")
        order = _make_mock_order(MarketOrder())
        result = validator.validate_submission(order)
        assert result is None

    def test_validate_submission_limit_order_1d(self):
        validator = OrderStyleValidator(frequency="1d")
        order = _make_mock_order(LimitOrder(10.0))
        result = validator.validate_submission(order)
        assert result is None

    def test_validate_submission_limit_order_1m(self):
        validator = OrderStyleValidator(frequency="1m")
        order = _make_mock_order(LimitOrder(10.0))
        result = validator.validate_submission(order)
        assert result is None

    def test_validate_submission_algo_order_1d_passes(self):
        validator = OrderStyleValidator(frequency="1d")
        order = _make_mock_order(VWAPOrder(0, 240))
        result = validator.validate_submission(order)
        assert result is None

    def test_validate_submission_algo_order_1m_raises(self):
        validator = OrderStyleValidator(frequency="1m")
        order = _make_mock_order(VWAPOrder(0, 240))
        with pytest.raises(RuntimeError, match="algo order no support 1m and tick frequency"):
            validator.validate_submission(order)

    def test_validate_submission_algo_order_tick_raises(self):
        validator = OrderStyleValidator(frequency="tick")
        order = _make_mock_order(VWAPOrder(0, 240))
        with pytest.raises(RuntimeError, match="algo order no support 1m and tick frequency"):
            validator.validate_submission(order)

    def test_validate_submission_twap_order_1m_raises(self):
        validator = OrderStyleValidator(frequency="1m")
        order = _make_mock_order(TWAPOrder(0, 240))
        with pytest.raises(RuntimeError, match="algo order no support 1m and tick frequency"):
            validator.validate_submission(order)

    def test_validate_cancellation_returns_none(self):
        validator = OrderStyleValidator(frequency="1d")
        order = _make_mock_order(MarketOrder())
        result = validator.validate_cancellation(order)
        assert result is None

    def test_validate_cancellation_algo_order_returns_none(self):
        validator = OrderStyleValidator(frequency="1m")
        order = _make_mock_order(VWAPOrder(0, 240))
        result = validator.validate_cancellation(order)
        assert result is None

    def test_algo_order_styles_tuple(self):
        assert ALGO_ORDER_STYLES == (VWAPOrder, TWAPOrder)

    def test_vwap_is_algo_order_style(self):
        assert isinstance(VWAPOrder(0, 240), ALGO_ORDER_STYLES)

    def test_twap_is_algo_order_style(self):
        assert isinstance(TWAPOrder(0, 240), ALGO_ORDER_STYLES)

    def test_market_order_is_not_algo(self):
        assert not isinstance(MarketOrder(), ALGO_ORDER_STYLES)

    def test_limit_order_is_not_algo(self):
        assert not isinstance(LimitOrder(10.0), ALGO_ORDER_STYLES)
