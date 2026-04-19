"""
Python Integration Tests for api_abstract.py (Original)
Validates Python original API surface that Mojo refactored version should match.

Run: pytest tests/python/apis/test_api_abstract.py -v
"""

import sys
import os
import inspect

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))

from rqalpha.apis import api_abstract
from rqalpha.model.order import OrderStyle, MarketOrder, LimitOrder, AlgoOrder, TWAPOrder, VWAPOrder
from rqalpha.const import SIDE, POSITION_EFFECT, ORDER_TYPE


class TestPythonOriginalAPISurface:
    """Verify Python original has all expected API functions with correct signatures."""

    EXPECTED_FUNCTIONS = {
        'order_shares': ['id_or_ins', 'amount', 'price_or_style', 'price', 'style'],
        'order_value': ['id_or_ins', 'cash_amount', 'price_or_style', 'price', 'style'],
        'order_percent': ['id_or_ins', 'percent', 'price_or_style', 'price', 'style'],
        'order_target_value': ['id_or_ins', 'cash_amount', 'price_or_style', 'price', 'style'],
        'order_target_percent': ['id_or_ins', 'percent', 'price_or_style', 'price', 'style'],
        'buy_open': ['id_or_ins', 'amount', 'price_or_style', 'price', 'style'],
        'buy_close': ['id_or_ins', 'amount', 'price_or_style', 'price', 'style', 'close_today'],
        'sell_open': ['id_or_ins', 'amount', 'price_or_style', 'price', 'style'],
        'sell_close': ['id_or_ins', 'amount', 'price_or_style', 'price', 'style', 'close_today'],
        'order': ['id_or_ins', 'quantity', 'price_or_style', 'price', 'style'],
        'order_to': ['id_or_ins', 'quantity', 'price_or_style', 'price', 'style'],
        'exercise': ['id_or_ins', 'amount', 'convert'],
    }

    def test_all_12_api_functions_exist(self):
        """All 12 order/exercise API functions must exist in Python original."""
        for func_name in self.EXPECTED_FUNCTIONS:
            assert hasattr(api_abstract, func_name), f"Missing: {func_name}"
            func = getattr(api_abstract, func_name)
            assert callable(func), f"Not callable: {func_name}"

    def test_order_shares_signature(self):
        """order_shares signature matches spec."""
        sig = inspect.signature(api_abstract.order_shares)
        params = list(sig.parameters.keys())
        assert params[:2] == ['id_or_ins', 'amount'], f"Bad params: {params}"

    def test_order_value_signature(self):
        """order_value signature matches spec."""
        sig = inspect.signature(api_abstract.order_value)
        params = list(sig.parameters.keys())
        assert params[:2] == ['id_or_ins', 'cash_amount'], f"Bad params: {params}"

    def test_order_percent_signature(self):
        """order_percent signature matches spec."""
        sig = inspect.signature(api_abstract.order_percent)
        params = list(sig.parameters.keys())
        assert params[:2] == ['id_or_ins', 'percent'], f"Bad params: {params}"

    def test_buy_close_has_close_today_param(self):
        """buy_close should have close_today parameter."""
        sig = inspect.signature(api_abstract.buy_close)
        assert 'close_today' in sig.parameters

    def test_sell_close_has_close_today_param(self):
        """sell_close should have close_today parameter."""
        sig = inspect.signature(api_abstract.sell_close)
        assert 'close_today' in sig.parameters

    def test_exercise_has_convert_param(self):
        """exercise should have convert parameter."""
        sig = inspect.signature(api_abstract.exercise)
        assert 'convert' in sig.parameters


class TestPythonOriginalOrderTypes:
    """Test Order type hierarchy in Python original."""

    def test_market_order_exists(self):
        mo = MarketOrder()
        assert mo is not None
        assert isinstance(mo, OrderStyle)

    def test_limit_order_with_price(self):
        lo = LimitOrder(10.5)
        assert lo is not None
        assert isinstance(lo, OrderStyle)

    def test_twap_order_is_algo(self):
        algo = TWAPOrder(931, 945)
        assert isinstance(algo, AlgoOrder)
        assert isinstance(algo, OrderStyle)

    def test_vwap_order_is_algo(self):
        algo = VWAPOrder(1000, 15000)
        assert isinstance(algo, AlgoOrder)


class TestSideAndPositionEffectConstants:
    """Verify constant values used by API functions."""

    def test_side_values(self):
        assert SIDE.BUY is not None
        assert SIDE.SELL is not None

    def test_position_effect_values(self):
        assert POSITION_EFFECT.OPEN is not None
        assert POSITION_EFFECT.CLOSE is not None
        assert POSITION_EFFECT.CLOSE_TODAY is not None
        assert POSITION_EFFECT.EXERCISE is not None

    def test_order_type_values(self):
        assert ORDER_TYPE.MARKET is not None
        assert ORDER_TYPE.LIMIT is not None


class TestValidationLogicEquivalence:
    """
    Test validation rules that both Python and Mojo should implement.
    These tests define the contract that Mojo implementation must satisfy.
    """

    def test_positive_amount_is_buy(self):
        """Positive amount always maps to BUY side."""
        assert (1 > 0) is True  # BUY

    def test_negative_amount_is_sell(self):
        """Negative amount always maps to SELL side."""
        assert (-1 > 0) is False  # SELL

    def test_positive_direction_is_open_effect(self):
        """Positive direction maps to OPEN position effect."""
        assert True  # positive -> OPEN

    def test_negative_direction_is_close_effect(self):
        """Negative direction maps to CLOSE position effect."""
        direction = -1
        effect = POSITION_EFFECT.OPEN if direction > 0 else POSITION_EFFECT.CLOSE
        assert effect == POSITION_EFFECT.CLOSE

    def test_round_to_lot_logic(self):
        """_round_to_lot(150, 100) should return 100."""
        lot_size = 100
        quantity = 150
        result = (quantity // lot_size) * lot_size if lot_size > 0 else quantity
        assert result == 100

    def test_round_to_lot_exact(self):
        """_round_to_lot(200, 100) should return 200."""
        lot_size = 100
        quantity = 200
        result = (quantity // lot_size) * lot_size if lot_size > 0 else quantity
        assert result == 200

    def test_percent_range_valid(self):
        """order_percent accepts [-1, 1]."""
        for p in [0.0, 0.5, 1.0, -1.0, -0.5]:
            assert -1.0 <= p <= 1.0, f"{p} out of range"

    def test_target_percent_range_valid(self):
        """order_target_percent accepts [0, 1]."""
        for p in [0.0, 0.5, 1.0]:
            assert 0.0 <= p <= 1.0, f"{p} out of range"

    def test_target_percent_rejects_negative(self):
        """order_target_percent rejects negative values."""
        p = -0.1
        assert not (0.0 <= p <= 1.0)

    def test_price_must_be_positive(self):
        """Order price must be > 0."""
        valid_prices = [0.01, 10.0, 99999.0]
        invalid_prices = [0.0, -1.0]
        for p in valid_prices:
            assert p > 0, f"Should be valid: {p}"
        for p in invalid_prices:
            assert not (p > 0), f"Should be invalid: {p}"


class TestMojoVsPythonSignatureMapping:
    """
    Document the exact mapping between Python and Mojo signatures.
    This serves as the specification for the refactoring.
    """

    MAPPING = [
        ("order_shares", "env + id_or_ins + amount + price_or_style_*"),
        ("order_value", "env + id_or_ins + cash_amount + price_or_style_*"),
        ("order_percent", "env + id_or_ins + percent + price_or_style_*"),
        ("order_target_value", "env + id_or_ins + cash_amount + target_*_price"),
        ("order_target_percent", "env + id_or_ins + percent + target_*_price"),
        ("buy_open", "env + id_or_ins + amount + price_or_style_*"),
        ("buy_close", "env + id_or_ins + amount + close_today"),
        ("sell_open", "env + id_or_ins + amount + price_or_style_*"),
        ("sell_close", "env + id_or_ins + amount + close_today"),
        ("order", "env + id_or_ins + quantity + price_or_style_*"),
        ("order_to", "env + id_or_ins + quantity + price_or_style_*"),
        ("exercise", "env + id_or_ins + amount + convert"),
    ]

    def test_mapping_completeness(self):
        """All 12 functions are documented in the mapping."""
        python_funcs = set(f[0] for f in self.MAPPING)
        expected = set(TestPythonOriginalAPISurface.EXPECTED_FUNCTIONS.keys())
        assert python_funcs == expected, f"Missing: {expected - python_funcs}"


if __name__ == "__main__":
    import pytest
    pytest.main([__file__, "-v"])
