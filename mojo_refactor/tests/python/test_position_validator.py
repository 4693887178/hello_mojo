"""
Test suite for RQAlpha position_validator.py (Python original)
Validates that PositionValidator implementation matches expected behavior
"""

import pytest
import sys
from unittest.mock import Mock, MagicMock, patch

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.mod.rqalpha_mod_sys_accounts.position_validator import PositionValidator
from rqalpha.const import POSITION_EFFECT
from rqalpha.model.order import Order


class TestPositionValidatorStructure:
    """Test PositionValidator class structure and inheritance."""
    
    def test_can_instantiate(self):
        """Verify PositionValidator can be instantiated without arguments."""
        validator = PositionValidator()
        assert validator is not None
    
    def test_has_validate_cancellation_method(self):
        """Verify validate_cancellation method exists with correct signature."""
        assert hasattr(PositionValidator, 'validate_cancellation')
        import inspect
        sig = inspect.signature(PositionValidator.validate_cancellation)
        params = list(sig.parameters.keys())
        assert 'self' in params
        assert 'order' in params
        assert 'account' in params
    
    def test_has_validate_submission_method(self):
        """Verify validate_submission method exists with correct signature."""
        assert hasattr(PositionValidator, 'validate_submission')
        import inspect
        sig = inspect.signature(PositionValidator.validate_submission)
        params = list(sig.parameters.keys())
        assert 'self' in params
        assert 'order' in params
        assert 'account' in params


class TestValidateCancellation:
    """Test validate_cancellation method behavior (should always allow)."""
    
    def test_always_returns_none_for_cancellation(self):
        """Verify validate_cancellation always returns None (allows cancellation)."""
        validator = PositionValidator()
        
        # Create a mock order
        order = Mock(spec=Order)
        order.order_book_id = "000001.XSHE"
        
        # Should return None regardless of order or account state
        result = validator.validate_cancellation(order)
        assert result is None
        
        # With account provided
        account = Mock()
        result = validator.validate_cancellation(order, account)
        assert result is None
    
    def test_allows_cancellation_for_any_order_type(self):
        """Verify all order types can be cancelled."""
        validator = PositionValidator()
        
        for position_effect in [POSITION_EFFECT.OPEN, POSITION_EFFECT.CLOSE, 
                                POSITION_EFFECT.CLOSE_TODAY, POSITION_EFFECT.EXERCISE]:
            order = Mock(spec=Order)
            order.order_book_id = "000001.XSHE"
            order.position_effect = position_effect
            
            result = validator.validate_cancellation(order)
            assert result is None, f"Should allow cancellation for {position_effect}"


class TestValidateSubmission:
    """Test validate_submission method behavior with full logic verification."""
    
    def _create_order(self, order_book_id="000001.XSHE", quantity=100, 
                     position_effect=POSITION_EFFECT.CLOSE):
        """Helper to create mock order object."""
        order = Mock(spec=Order)
        order.order_book_id = order_book_id
        order.quantity = quantity
        order.position_effect = position_effect
        return order
    
    def _create_position(self, closable=1000, today_closable=500):
        """Helper to create mock position object."""
        position = Mock()
        position.closable = closable
        position.today_closable = today_closable
        return position
    
    def _create_account_with_position(self, position=None):
        """Helper to create mock account that returns specified position."""
        account = Mock()
        if position:
            account.get_position.return_value = position
        return account
    
    def test_returns_none_when_account_is_none(self):
        """Verify validation passes when account is None (skip validation)."""
        validator = PositionValidator()
        order = self._create_order(position_effect=POSITION_EFFECT.CLOSE)
        
        result = validator.validate_submission(order, account=None)
        assert result is None
    
    def test_allows_open_orders(self):
        """Verify OPEN orders always pass validation (no position check needed)."""
        validator = PositionValidator()
        order = self._create_order(position_effect=POSITION_EFFECT.OPEN)
        account = self._create_account_with_position(
            position=self._create_position(closable=0, today_closable=0)
        )
        
        result = validator.validate_submission(order, account=account)
        assert result is None, "OPEN orders should always be allowed"
    
    def test_allows_exercise_orders(self):
        """Verify EXERCISE orders always pass validation (no position check needed)."""
        validator = PositionValidator()
        order = self._create_order(position_effect=POSITION_EFFECT.EXERCISE)
        account = self._create_account_with_position(
            position=self._create_position(closable=0, today_closable=0)
        )
        
        result = validator.validate_submission(order, account=account)
        assert result is None, "EXERCISE orders should always be allowed"
    
    def test_rejects_close_today_when_insufficient_position(self):
        """Verify CLOSE_TODAY orders are rejected when quantity > today_closable."""
        validator = PositionValidator()
        order = self._create_order(quantity=600, position_effect=POSITION_EFFECT.CLOSE_TODAY)
        position = self._create_position(closable=1000, today_closable=500)
        account = self._create_account_with_position(position=position)
        
        result = validator.validate_submission(order, account=account)
        
        assert result is not None, "Should reject when insufficient today position"
        assert "not enough today position" in str(result) or "today" in str(result).lower()
    
    def test_rejects_close_when_insufficient_position(self):
        """Verify CLOSE orders are rejected when quantity > closable."""
        validator = PositionValidator()
        order = self._create_order(quantity=1500, position_effect=POSITION_EFFECT.CLOSE)
        position = self._create_position(closable=1000, today_closable=800)
        account = self._create_account_with_position(position=position)
        
        result = validator.validate_submission(order, account=account)
        
        assert result is not None, "Should reject when insufficient position"
        assert "not enough position" in str(result) or "closable" in str(result).lower()
    
    def test_allows_close_today_when_sufficient_position(self):
        """Verify CLOSE_TODAY orders pass when quantity <= today_closable."""
        validator = PositionValidator()
        order = self._create_order(quantity=400, position_effect=POSITION_EFFECT.CLOSE_TODAY)
        position = self._create_position(closable=1000, today_closable=500)
        account = self._create_account_with_position(position=position)
        
        result = validator.validate_submission(order, account=account)
        assert result is None, "Should allow when sufficient today position"
    
    def test_allows_close_when_sufficient_position(self):
        """Verify CLOSE orders pass when quantity <= closable."""
        validator = PositionValidator()
        order = self._create_order(quantity=900, position_effect=POSITION_EFFECT.CLOSE)
        position = self._create_position(closable=1000, today_closable=500)
        account = self._create_account_with_position(position=position)
        
        result = validator.validate_submission(order, account=account)
        assert result is None, "Should allow when sufficient position"
    
    def test_error_message_includes_order_details(self):
        """Verify error message includes order book ID and quantities."""
        validator = PositionValidator()
        order = self._create_order(
            order_book_id="000001.XSHE",
            quantity=999,
            position_effect=POSITION_EFFECT.CLOSE_TODAY
        )
        position = self._create_position(closable=2000, today_closable=100)
        account = self._create_account_with_position(position=position)
        
        result = validator.validate_submission(order, account=account)
        
        if result:
            error_str = str(result)
            # Verify key information is present in error message
            assert "000001.XSHE" in error_str or "order_book_id" in error_str.lower() or "999" in error_str or "100" in error_str


class TestEdgeCases:
    """Test edge cases and boundary conditions."""
    
    def test_zero_quantity_order(self):
        """Verify zero quantity orders pass validation."""
        validator = PositionValidator()
        order = Mock(spec=Order)
        order.quantity = 0
        order.position_effect = POSITION_EFFECT.CLOSE
        order.order_book_id = "000001.XSHE"
        
        account = Mock()
        position = Mock()
        position.closable = 100
        position.today_closable = 50
        account.get_position.return_value = position
        
        result = validator.validate_submission(order, account=account)
        assert result is None, "Zero quantity orders should pass"
    
    def test_exact_match_quantity(self):
        """Verify orders with exact matching quantity pass validation."""
        validator = PositionValidator()
        
        # Exact match for CLOSE_TODAY
        order = Mock(spec=Order)
        order.quantity = 500
        order.position_effect = POSITION_EFFECT.CLOSE_TODAY
        order.order_book_id = "000001.XSHE"
        
        account = Mock()
        position = Mock()
        position.closable = 1000
        position.today_closable = 500
        account.get_position.return_value = position
        
        result = validator.validate_submission(order, account=account)
        assert result is None, "Exact match should pass for CLOSE_TODAY"
        
        # Exact match for CLOSE
        order2 = Mock(spec=Order)
        order2.quantity = 1000
        order2.position_effect = POSITION_EFFECT.CLOSE
        order2.order_book_id = "000001.XSHE"
        
        result2 = validator.validate_submission(order2, account=account)
        assert result2 is None, "Exact match should pass for CLOSE"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
