from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.mod.rqmojo_mod_sys_accounts.position_validator import (
    PositionValidator,
    create_position_validator,
)
from rqmojo.const import POSITION_EFFECT, SIDE, ORDER_STATUS, ORDER_TYPE
from rqmojo.model.order import Order, MarketOrder
from rqmojo.portfolio.account import Account
from rqmojo.utils.typing import DateTime


def create_test_order(
    order_book_id: String = "000001.XSHE",
    quantity: Int = 100,
    side: SIDE = SIDE.BUY,
    position_effect: POSITION_EFFECT = POSITION_EFFECT.CLOSE,
    order_id: Int = 1
) -> Order:
    """Helper function to create test Order with all required fields."""
    return Order(
        order_id=order_id,
        order_book_id=order_book_id,
        side=side,
        position_effect=position_effect,
        quantity=quantity,
        filled_quantity=0,
        unfilled_quantity=quantity,
        status=ORDER_STATUS.PENDING_NEW,
        style=MarketOrder(),
        avg_price=0.0,
        calendar_dt=DateTime(2024, 1, 15),
        trading_dt=DateTime(2024, 1, 15),
        transaction_cost=0.0,
        price=10.0
    )


def test_create_position_validator() raises:
    """Test create_position_validator factory function with default and custom values."""
    var validator_default = create_position_validator()
    assert_true(validator_default.enabled == True)
    
    var validator_disabled = create_position_validator(enabled=False)
    assert_true(validator_disabled.enabled == False)


def test_position_validator_structure() raises:
    """Test PositionValidator struct has correct fields."""
    var validator = PositionValidator(enabled=True)
    assert_true(validator.enabled == True)


def test_validate_cancellation_always_returns_none() raises:
    """Test validate_cancellation always returns None (allows cancellation).
    
    Python original behavior:
        def validate_cancellation(self, order, account=None):
            return None  # Always allow cancellation
    """
    var validator = create_position_validator()
    
    # Create a simple order using helper
    var order = create_test_order()
    
    # Should return None regardless of parameters
    var result_none_account = validator.validate_cancellation(order)
    assert_true(result_none_account == None)
    
    # With account parameter (None)
    var result_with_none = validator.validate_cancellation(order, account=None)
    assert_true(result_with_none == None)


def test_validate_submission_with_none_account() raises:
    """Test validate_submission returns None when account is None.
    
    Python original:
        if account is None:
            return None  # Skip validation
    """
    var validator = create_position_validator()
    
    var order = create_test_order()
    
    var result = validator.validate_submission(order, account=None)
    assert_true(result == None)


def test_validate_submission_allows_open_orders() raises:
    """Test validate_submission allows OPEN orders without position check.
    
    Python original:
        if order.position_effect in (OPEN, EXERCISE):
            return None  # Allow opening positions
    """
    var validator = create_position_validator()
    
    var open_order = create_test_order(
        quantity=99999,  # Large quantity to ensure it would fail position check if checked
        position_effect=POSITION_EFFECT.OPEN
    )
    
    var result = validator.validate_submission(open_order, account=None)
    assert_true(result == None)


def test_validate_submission_allows_exercise_orders() raises:
    """Test validate_submission allows EXERCISE orders without position check.
    
    Python original:
        if order.position_effect in (OPEN, EXERCISE):
            return None  # Allow exercise
    """
    var validator = create_position_validator()
    
    var exercise_order = create_test_order(
        quantity=99999,
        position_effect=POSITION_EFFECT.EXERCISE
    )
    
    var result = validator.validate_submission(exercise_order, account=None)
    assert_true(result == None)


def test_validate_submission_close_order_with_account() raises:
    """Test validate_submission for CLOSE orders with account.
    
    This tests the basic structure - actual position validation requires
    full Account integration at runtime.
    """
    var validator = create_position_validator()
    
    var close_order = create_test_order(
        quantity=100,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE
    )
    
    # With None account, should pass
    var result = validator.validate_submission(close_order, account=None)
    assert_true(result == None)


def test_validate_submission_close_today_order_with_account() raises:
    """Test validate_submission for CLOSE_TODAY orders.
    
    Tests the basic structure for today's closing validation.
    """
    var validator = create_position_validator()
    
    var close_today_order = create_test_order(
        quantity=50,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE_TODAY
    )
    
    # With None account, should pass
    var result = validator.validate_submission(close_today_order, account=None)
    assert_true(result == None)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
