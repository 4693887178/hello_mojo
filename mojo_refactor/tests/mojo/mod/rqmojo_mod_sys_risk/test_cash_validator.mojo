"""
Test for mod/rqmojo_mod_sys_risk/validators/cash_validator.mojo
Tests cover: validate_cash, CashValidator, _format_float2, create_cash_validator
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import (
    CashValidator, validate_cash, create_cash_validator, _format_float2
)
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.model.order import Order, LimitOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION, INSTRUMENT_TYPE, EXCHANGE, MARKET, DEFAULT_ACCOUNT_TYPE
from rqmojo.utils.typing import DateTime
from rqmojo.portfolio.position import Position

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, List


def test_format_float2_whole_number() raises:
    var result = _format_float2(100.0)
    assert_equal(result, "100.00", "100.0 should format as 100.00")


def test_format_float2_fractional() raises:
    var result = _format_float2(123.45)
    assert_equal(result, "123.45", "123.45 should format as 123.45")


def test_format_float2_small_fraction() raises:
    var result = _format_float2(1.05)
    assert_equal(result, "1.05", "1.05 should format as 1.05")


def test_format_float2_zero() raises:
    var result = _format_float2(0.0)
    assert_equal(result, "0.00", "0.0 should format as 0.00")


def test_format_float2_large_number() raises:
    var result = _format_float2(99999.99)
    assert_equal(result, "99999.99", "99999.99 should format as 99999.99")


def test_format_float2_rounding() raises:
    var result = _format_float2(100.006)
    assert_equal(result, "100.01", "100.006 should round to 100.01")


def test_validate_cash_sufficient() raises:
    var dp = create_data_proxy()
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validate_cash(order=order, cash=100000.0, data_proxy=dp^)
    assert_true(result is None, "Sufficient cash should return None")


def test_validate_cash_insufficient() raises:
    var dp = create_data_proxy()
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validate_cash(order=order, cash=50.0, data_proxy=dp^)
    assert_false(result is None, "Insufficient cash should return reason string")
    if not (result is None):
        assert_true(
            result.value().find("not enough money") != -1,
            "Reason should contain 'not enough money'",
        )


def test_validate_cash_exact_amount() raises:
    var dp = create_data_proxy()
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validate_cash(order=order, cash=1000.0, data_proxy=dp^)
    assert_true(result is None, "Exact amount (price * qty) should return None")


def test_validate_cash_with_transaction_cost() raises:
    var dp = create_data_proxy()
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    order.set_estimated_transaction_cost(50.0)
    var result = validate_cash(order=order, cash=1000.0, data_proxy=dp^)
    assert_false(result is None, "Cash=1000 with cost=1000+50 should fail")


def test_validate_cash_with_zero_transaction_cost() raises:
    var dp = create_data_proxy()
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    order.set_estimated_transaction_cost(0.0)
    var result = validate_cash(order=order, cash=1000.0, data_proxy=dp^)
    assert_true(result is None, "Zero transaction cost with exact cash should pass")


def test_cash_validator_init() raises:
    var dp = create_data_proxy()
    var _ = create_cash_validator(dp^)
    assert_true(True, "CashValidator init succeeded")


def test_cash_validator_validate_cancellation() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")


def test_cash_validator_validate_submission_no_account() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "No account should return None")


def test_cash_validator_validate_submission_close_position() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(100000.0)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.SELL, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.CLOSE),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "CLOSE position_effect should return None")


def test_cash_validator_validate_submission_close_today() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(100000.0)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.SELL, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.CLOSE_TODAY),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "CLOSE_TODAY position_effect should return None")


def test_cash_validator_validate_submission_none_position_effect() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(100000.0)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "None position_effect should return None")


def test_cash_validator_validate_submission_sufficient_cash() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(100000.0)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_true(result is None, "Sufficient cash with OPEN should return None")


def test_cash_validator_validate_submission_insufficient_cash() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(50.0)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "Insufficient cash with OPEN should return reason")


def test_cash_validator_validate_submission_reason_format() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(50.0)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    if not (result is None):
        var reason = result.value()
        assert_true(
            reason.find("000001.XSHE") != -1,
            "Reason should contain order_book_id",
        )
        assert_true(
            reason.find("not enough money") != -1,
            "Reason should contain 'not enough money'",
        )


def test_cash_validator_validate_submission_with_frozen_cash() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(2000.0)
    account.frozen_cash = 1500.0
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "Available cash=500, need 1000, should fail")


def test_cash_validator_validate_submission_with_margin() raises:
    var dp = create_data_proxy()
    var validator = create_cash_validator(dp^)
    var account = create_stock_account(2000.0)
    account.margin_val = 1500.0
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    var result = validator.validate_submission(order, Optional[Account](account))
    assert_false(result is None, "Available cash=500 (margin=1500), need 1000, should fail")


def test_instrument_calc_cash_occupation_stock() raises:
    var ins = create_stock_instrument(
        "000001.XSHE", "TestStock",
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        EXCHANGE.XSHE,
    )
    var result = ins.calc_cash_occupation(
        10.0, 100, POSITION_DIRECTION.LONG,
        DateTime(2024, 1, 1, 0, 0, 0, 0),
    )
    assert_equal(result, 1000.0, "Stock cash occupation = price * quantity")


def test_instrument_calc_cash_occupation_future() raises:
    var ins = create_future_instrument(
        "RB2410", "Rebar2410",
        DateTime(2024, 1, 1, 0, 0, 0, 0),
        DateTime(2024, 10, 1, 0, 0, 0, 0),
        DateTime(2024, 10, 15, 0, 0, 0, 0),
        10.0,
        EXCHANGE.SHFE,
        "RB",
    )
    var result = ins.calc_cash_occupation(
        3500.0, 1, POSITION_DIRECTION.LONG,
        DateTime(2024, 6, 1, 0, 0, 0, 0),
    )
    assert_equal(result, 3500.0, "Future cash occupation = price * qty * multiplier * margin_rate = 3500*1*10*0.1")


def test_account_available_cash_for() raises:
    var account = create_stock_account(100000.0)
    var ins = create_stock_instrument(
        "000001.XSHE", "TestStock",
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        EXCHANGE.XSHE,
    )
    var result = account.available_cash_for(ins)
    assert_equal(result, 100000.0, "available_cash_for should return available_cash")


def test_order_estimated_transaction_cost() raises:
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
    )
    assert_equal(order.estimated_transaction_cost(), 0.0, "Default estimated_transaction_cost should be 0.0")
    order.set_estimated_transaction_cost(25.5)
    assert_equal(order.estimated_transaction_cost(), 25.5, "estimated_transaction_cost should be 25.5 after set")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
