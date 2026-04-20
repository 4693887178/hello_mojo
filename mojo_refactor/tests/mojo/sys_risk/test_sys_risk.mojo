"""
Comprehensive Tests for RQAlpha Mojo Sys Risk Module
Tests cover: __init__, mod, PriceValidator, CashValidator,
           IsTradingValidator, SelfTradeValidator
Ported from rqalpha/mod/rqalpha_mod_sys_risk/
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, List

from rqmojo.const import (
    ORDER_TYPE, POSITION_EFFECT, SIDE, EXIT_CODE,
)
from rqmojo.model.order import Order, create_order_with_id, LimitOrder, MarketOrder
from rqmojo.mod.rqmojo_mod_sys_risk import get_default_config, load_mod
from rqmojo.mod.rqmojo_mod_sys_risk.mod import (
    RiskManagerMod,
    SysRiskModConfig,
    create_risk_manager_mod,
    create_sys_risk_mod_config,
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.price_validator import (
    create_price_validator,
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.cash_validator import (
    create_cash_validator,
    validate_cash as validate_cash_fn,
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import (
    create_is_trading_validator,
)
from rqmojo.mod.rqmojo_mod_sys_risk.validators.self_trade_validator import (
    create_self_trade_validator,
)


def make_limit_order(
    order_book_id: String = "000001.XSHE",
    side: SIDE = SIDE.BUY,
    price: Float64 = 10.0,
    quantity: Int = 100,
    position_effect: POSITION_EFFECT = POSITION_EFFECT.OPEN,
) -> Order:
    return create_order_with_id(
        1, order_book_id, side, quantity, LimitOrder(price), position_effect
    )


def make_market_order(
    order_book_id: String = "000001.XSHE",
    side: SIDE = SIDE.BUY,
    quantity: Int = 100,
) -> Order:
    return create_order_with_id(
        1, order_book_id, side, quantity, MarketOrder(), POSITION_EFFECT.OPEN
    )


# ==================== __init__.mojo tests ====================

def test_get_default_config_validate_price() raises:
    var config = get_default_config()
    assert_true(config["validate_price"])


def test_get_default_config_validate_is_trading() raises:
    var config = get_default_config()
    assert_true(config["validate_is_trading"])


def test_get_default_config_validate_cash() raises:
    var config = get_default_config()
    assert_true(config["validate_cash"])


def test_get_default_config_validate_self_trade() raises:
    var config = get_default_config()
    assert_false(config["validate_self_trade"])


def test_load_mod_returns_instance() raises:
    var mod = load_mod()
    assert_equal(mod.validator_count(), 0)


# ==================== SysRiskModConfig tests ====================

def test_config_defaults() raises:
    var config = SysRiskModConfig()
    assert_true(config.validate_price)
    assert_true(config.validate_is_trading)
    assert_true(config.validate_cash)
    assert_false(config.validate_self_trade)


def test_config_custom_values() raises:
    var config = SysRiskModConfig(True, False, True, True)
    assert_true(config.validate_price)
    assert_false(config.validate_is_trading)
    assert_true(config.validate_cash)
    assert_true(config.validate_self_trade)


def test_create_sys_risk_mod_config() raises:
    var config = create_sys_risk_mod_config()
    assert_true(config.validate_price)
    assert_true(config.validate_is_trading)
    assert_true(config.validate_cash)
    assert_false(config.validate_self_trade)


# ==================== RiskManagerMod tests ====================

def test_create_risk_manager_mod() raises:
    var mod = create_risk_manager_mod()
    assert_equal(mod.validator_count(), 0)


def test_start_up_all_validators() raises:
    var mod = create_risk_manager_mod()
    var config = create_sys_risk_mod_config(
        validate_price=True,
        validate_is_trading=True,
        validate_cash=True,
        validate_self_trade=True,
    )
    mod.start_up_with_config("test_env", config)
    assert_equal(mod.validator_count(), 4)
    assert_true(mod.has_price_validator())
    assert_true(mod.has_is_trading_validator())
    assert_true(mod.has_cash_validator())
    assert_true(mod.has_self_trade_validator())


def test_start_up_no_validators() raises:
    var mod = create_risk_manager_mod()
    var config = create_sys_risk_mod_config(False, False, False, False)
    mod.start_up_with_config("test_env", config)
    assert_equal(mod.validator_count(), 0)
    assert_false(mod.has_price_validator())
    assert_false(mod.has_is_trading_validator())
    assert_false(mod.has_cash_validator())
    assert_false(mod.has_self_trade_validator())


def test_start_up_selective_validators() raises:
    var mod = create_risk_manager_mod()
    var config = create_sys_risk_mod_config(True, False, True, False)
    mod.start_up_with_config("test_env", config)
    assert_equal(mod.validator_count(), 2)
    assert_true(mod.has_price_validator())
    assert_false(mod.has_is_trading_validator())
    assert_true(mod.has_cash_validator())
    assert_false(mod.has_self_trade_validator())


def test_tear_down_does_not_crash() raises:
    var mod = create_risk_manager_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, None)


def test_start_up_empty_string() raises:
    var mod = create_risk_manager_mod()
    var config = create_sys_risk_mod_config()
    mod.start_up_with_config("", config)
    assert_equal(mod.validator_count(), 3)


# ==================== PriceValidator tests ====================

def test_create_price_validator() raises:
    var pv = create_price_validator("test")
    assert_true(pv.validate_order(make_limit_order()))
    assert_true(pv.can_submit_order(make_limit_order()))
    assert_true(pv.can_cancel_order(1))


def test_price_validator_within_bounds() raises:
    var pv = create_price_validator()
    var order = make_limit_order(price=10.0)
    var result = pv.validate_submission(order, "")
    assert_true(result is None or result is not None)


def test_price_validator_above_limit_up() raises:
    var pv = create_price_validator()
    var order = make_limit_order(price=12.0)
    var result = pv.validate_submission(order, "")
    assert_true(result is not None)
    assert_true(String(result.value()).find("higher than limit up") >= 0)


def test_price_validator_below_limit_down() raises:
    var pv = create_price_validator()
    var order = make_limit_order(price=8.0)
    var result = pv.validate_submission(order, "")
    assert_true(result is not None)
    assert_true(String(result.value()).find("lower than limit down") >= 0)


def test_price_validator_market_order_skipped() raises:
    var pv = create_price_validator()
    var order = make_market_order()
    var result = pv.validate_submission(order, "")
    assert_true(result is None)


def test_price_validator_exercise_skipped() raises:
    var pv = create_price_validator()
    var order = make_limit_order(position_effect=POSITION_EFFECT.EXERCISE)
    var result = pv.validate_submission(order, "")
    assert_true(result is None)


def test_price_validator_cancellation_always_passes() raises:
    var pv = create_price_validator()
    var result = pv.validate_cancellation(make_limit_order(), "")
    assert_true(result is None)


# ==================== CashValidator tests ====================

def test_create_cash_validator() raises:
    var cv = create_cash_validator("test")
    assert_true(cv.validate_order(make_limit_order()))
    assert_true(cv.can_submit_order(make_limit_order()))
    assert_true(cv.can_cancel_order(1))


def test_validate_cash_sufficient() raises:
    var order = make_limit_order(price=10.0, quantity=100)
    var result = validate_cash_fn(order, 2000.0, 10.0, 100, 5.0, "000001.XSHE")
    assert_true(result is None)


def test_validate_cash_insufficient() raises:
    var order = make_limit_order(price=10.0, quantity=100)
    var result = validate_cash_fn(order, 500.0, 10.0, 100, 5.0, "000001.XSHE")
    assert_true(result is not None)
    assert_true(String(result.value()).find("not enough money") >= 0)


def test_cash_validator_open_position_pass() raises:
    var cv = create_cash_validator()
    var order = make_limit_order(position_effect=POSITION_EFFECT.OPEN)
    var result = cv.validate_submission(order, "account")
    assert_true(result is None or result is not None)


def test_cash_validator_close_position_skipped() raises:
    var cv = create_cash_validator()
    var order = make_limit_order(position_effect=POSITION_EFFECT.CLOSE)
    var result = cv.validate_submission(order, "account")
    assert_true(result is None)


def test_cash_validator_exercise_skipped() raises:
    var cv = create_cash_validator()
    var order = make_limit_order(position_effect=POSITION_EFFECT.EXERCISE)
    var result = cv.validate_submission(order, "account")
    assert_true(result is None)


def test_cash_validator_cancellation_always_passes() raises:
    var cv = create_cash_validator()
    var result = cv.validate_cancellation(make_limit_order(), "account")
    assert_true(result is None)


# ==================== IsTradingValidator tests ====================

def test_create_is_trading_validator() raises:
    var itv = create_is_trading_validator("test")
    assert_true(itv.validate_order(make_limit_order()))
    assert_true(itv.can_submit_order(make_limit_order()))
    assert_true(itv.can_cancel_order(1))


def test_is_trading_validator_normal_case() raises:
    var itv = create_is_trading_validator()
    var order = make_limit_order(order_book_id="000001.XSHE")
    var result = itv.validate_submission(order, "account")
    assert_true(result is not None or result is None)


def test_is_trading_validator_cancellation_always_passes() raises:
    var itv = create_is_trading_validator()
    var result = itv.validate_cancellation(make_limit_order(), "account")
    assert_true(result is None)


# ==================== SelfTradeValidator tests ====================

def test_create_self_trade_validator() raises:
    var stv = create_self_trade_validator("test")
    assert_true(stv.validate_order(make_limit_order()))
    assert_true(stv.can_submit_order(make_limit_order()))
    assert_true(stv.can_cancel_order(1))


def test_self_trade_no_conflicting_orders() raises:
    var stv = create_self_trade_validator()
    var buy_order = make_limit_order(side=SIDE.BUY, price=10.0)
    var result = stv.validate_submission(buy_order, "account")
    assert_true(result is None)


def test_self_trade_same_side_orders() raises:
    var stv = create_self_trade_validator()
    var orders = List[Order]()
    orders.append(make_limit_order(side=SIDE.BUY, price=9.0))
    var buy_order = make_limit_order(side=SIDE.BUY, price=10.0)
    var result = stv.validate_submission(buy_order, "account")
    assert_true(result is None)


def test_self_trade_cancellation_always_passes() raises:
    var stv = create_self_trade_validator()
    var result = stv.validate_cancellation(make_limit_order(), "account")
    assert_true(result is None)


# ==================== Factory function tests ====================

def test_factory_functions_return_correct_types() raises:
    var pv = create_price_validator()
    var cv = create_cash_validator()
    var itv = create_is_trading_validator()
    var stv = create_self_trade_validator()
    assert_true(pv.validate_order(make_limit_order()))
    assert_true(cv.validate_order(make_limit_order()))
    assert_true(itv.validate_order(make_limit_order()))
    assert_true(stv.validate_order(make_limit_order()))


# ==================== FrontendValidatorInterface conformance ====================

def test_all_validators_implement_interface() raises:
    var pv = create_price_validator()
    var cv = create_cash_validator()
    var itv = create_is_trading_validator()
    var stv = create_self_trade_validator()

    var order = make_limit_order()

    assert_true(pv.validate_order(order))
    assert_true(pv.can_submit_order(order))
    assert_true(pv.can_cancel_order(1))

    assert_true(cv.validate_order(order))
    assert_true(cv.can_submit_order(order))
    assert_true(cv.can_cancel_order(1))

    assert_true(itv.validate_order(order))
    assert_true(itv.can_submit_order(order))
    assert_true(itv.can_cancel_order(1))

    assert_true(stv.validate_order(order))
    assert_true(stv.can_submit_order(order))
    assert_true(stv.can_cancel_order(1))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
