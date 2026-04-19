"""
Test for mod/rqmojo_mod_sys_accounts/validator.mojo
Comprehensive unit tests for MarginInstrumentValidator

Tests cover:
  1. Constructor and factory function
  2. validate_order always returns True
  3. can_submit_order always returns True
  4. can_cancel_order always returns True
  5. validate_submission returns None when account is None
  6. validate_submission returns None when cash_liabilities == 0
  7. validate_submission returns None when cash_liabilities < 0
  8. validate_submission returns reason when cash_liabilities > 0
  9. validate_submission reason format matches Python original
  10. validate_submission reason contains order_book_id
  11. validate_submission with sell order
  12. validate_submission with stock account (no cash_liabilities)
  13. validate_submission with future account (no cash_liabilities)
  14. validate_cancellation always returns None
  15. Writable trait (write_to)
  16. Copy semantics
  17. Different order_book_ids
  18. Large and small cash_liabilities values
"""

from std.collections import Optional, List
from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, DEFAULT_ACCOUNT_TYPE
from rqmojo.model.order import Order, OrderStyle, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.portfolio.account import Account, create_account, create_stock_account, create_future_account
from rqmojo.portfolio.position import Position, create_position
from rqmojo.interface import FrontendValidatorInterface
from rqmojo.mod.rqmojo_mod_sys_accounts.validator import MarginInstrumentValidator, create_margin_instrument_validator


def _create_account_with_cash_liabilities(cash_liabilities: Float64) -> Account:
    return Account(
        account_type=DEFAULT_ACCOUNT_TYPE.STOCK,
        total_cash=100000.0,
        total_value=100000.0,
        positions_count=0,
        frozen_cash=0.0,
        margin_val=0.0,
        daily_pnl=0.0,
        cash_liabilities=cash_liabilities,
        _positions=List[Position]()
    )


def _create_test_order(order_book_id: String = "000001.XSHE", side: SIDE = SIDE.BUY, quantity: Int = 100) -> Order:
    return create_order_with_id(1, order_book_id, side, quantity, MarketOrder())


# ============================================================
# Test: MarginInstrumentValidator struct creation
# ============================================================

def test_margin_instrument_validator_init() raises:
    var _ = MarginInstrumentValidator()
    assert_true(True, "MarginInstrumentValidator init succeeded")


def test_create_margin_instrument_validator_factory() raises:
    var _ = create_margin_instrument_validator()
    assert_true(True, "create_margin_instrument_validator factory succeeded")


def test_margin_instrument_validator_conforms_to_trait() raises:
    var validator = create_margin_instrument_validator()
    var result = validator.validate_order(_create_test_order())
    assert_true(result, "MarginInstrumentValidator conforms to FrontendValidatorInterface")


# ============================================================
# Test: validate_submission - core business logic
# ============================================================

def test_validate_submission_returns_none_when_account_is_none() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "validate_submission returns None when account is None")


def test_validate_submission_returns_none_when_cash_liabilities_zero() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(0.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "validate_submission returns None when cash_liabilities == 0")


def test_validate_submission_returns_none_when_cash_liabilities_negative() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(-100.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "validate_submission returns None when cash_liabilities < 0")


def test_validate_submission_returns_reason_when_cash_liabilities_positive() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order("000001.XSHE")
    var account = _create_account_with_cash_liabilities(1000.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "validate_submission returns reason when cash_liabilities > 0")


def test_validate_submission_reason_contains_order_book_id() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order("600000.XSHG")
    var account = _create_account_with_cash_liabilities(500.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "result should not be None")
    var reason = result.value()
    assert_true(reason.find("600000.XSHG") != -1, "reason contains order_book_id")


def test_validate_submission_reason_contains_order_creation_failed() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(500.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "result should not be None")
    var reason = result.value()
    assert_true(reason.find("Order Creation Failed") != -1, "reason contains 'Order Creation Failed'")


def test_validate_submission_reason_contains_cash_liabilities() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(500.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "result should not be None")
    var reason = result.value()
    assert_true(reason.find("cash liabilities > 0") != -1, "reason contains 'cash liabilities > 0'")


def test_validate_submission_reason_format_matches_python() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order("000001.XSHE")
    var account = _create_account_with_cash_liabilities(1000.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "result should not be None")
    var reason = result.value()
    var expected = "Order Creation Failed: cash liabilities > 0, 000001.XSHE not support submit order"
    assert_equal(reason, expected, "reason format matches Python original")


def test_validate_submission_with_sell_order() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order("000001.XSHE", SIDE.SELL, 200)
    var account = _create_account_with_cash_liabilities(1000.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "validate_submission returns reason for sell order with cash_liabilities > 0")


def test_validate_submission_with_stock_account() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = create_stock_account()
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "validate_submission returns None for stock account with no cash_liabilities")


def test_validate_submission_with_future_account() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = create_future_account()
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "validate_submission returns None for future account with no cash_liabilities")


# ============================================================
# Test: validate_cancellation
# ============================================================

def test_validate_cancellation_returns_none_with_account() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(1000.0)
    var result = validator.validate_cancellation(order, Optional[Account](account))
    assert_true(result is None, "validate_cancellation always returns None with account")


def test_validate_cancellation_returns_none_without_account() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation always returns None without account")


def test_validate_cancellation_returns_none_when_cash_liabilities_zero() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(0.0)
    var result = validator.validate_cancellation(order, Optional[Account](account))
    assert_true(result is None, "validate_cancellation always returns None")


# ============================================================
# Test: validate_order
# ============================================================

def test_validate_order_returns_true() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var result = validator.validate_order(order)
    assert_true(result, "validate_order always returns True")


# ============================================================
# Test: can_submit_order
# ============================================================

def test_can_submit_order_returns_true() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var result = validator.can_submit_order(order)
    assert_true(result, "can_submit_order always returns True")


# ============================================================
# Test: can_cancel_order
# ============================================================

def test_can_cancel_order_returns_true() raises:
    var validator = create_margin_instrument_validator()
    var result = validator.can_cancel_order(1)
    assert_true(result, "can_cancel_order always returns True")


# ============================================================
# Test: write_to (Writable trait)
# ============================================================

def test_write_to() raises:
    var validator = create_margin_instrument_validator()
    var s = String.write(validator)
    assert_equal(s, "MarginInstrumentValidator()", "write_to produces correct string")


# ============================================================
# Test: Copy semantics
# ============================================================

def test_copy_validator() raises:
    var validator = create_margin_instrument_validator()
    var copy = validator.copy()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(1000.0)
    var result1 = validator.validate_submission(order, Optional[Account](account))
    var result2 = copy.validate_submission(order, Optional[Account](account))
    assert_equal(result1 is None, result2 is None, "copy has same behavior as original")


# ============================================================
# Test: Different order_book_ids
# ============================================================

def test_validator_with_different_order_book_ids() raises:
    var validator = create_margin_instrument_validator()
    var account = _create_account_with_cash_liabilities(1000.0)

    var order1 = _create_test_order("000001.XSHE")
    var result1 = validator.validate_submission(order1, Optional[Account](account))
    assert_false(result1 is None, "returns reason for 000001.XSHE")

    var order2 = _create_test_order("600000.XSHG")
    var result2 = validator.validate_submission(order2, Optional[Account](account))
    assert_false(result2 is None, "returns reason for 600000.XSHG")
    assert_true(result2.value().find("600000.XSHG") != -1, "reason contains correct order_book_id")


# ============================================================
# Test: Edge cases for cash_liabilities values
# ============================================================

def test_validator_with_large_cash_liabilities() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(1000000.0)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "returns reason for large cash_liabilities")


def test_validator_with_very_small_cash_liabilities() raises:
    var validator = create_margin_instrument_validator()
    var order = _create_test_order()
    var account = _create_account_with_cash_liabilities(0.01)
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "returns reason even for tiny cash_liabilities > 0")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
