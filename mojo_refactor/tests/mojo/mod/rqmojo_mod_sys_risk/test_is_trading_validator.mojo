"""
Test for mod/rqmojo_mod_sys_risk/validators/is_trading_validator.mojo
Tests cover: IsTradingValidator, _format_date, _pad_zero, create_is_trading_validator
"""

from rqmojo.mod.rqmojo_mod_sys_risk.validators.is_trading_validator import (
    IsTradingValidator, create_is_trading_validator, _format_date, _pad_zero
)
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.model.order import Order, LimitOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT, INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.utils.typing import DateTime
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.data.trading_dates_mixin import create_trading_dates_mixin_with_multiple_months

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Optional, Dict


comptime TEST_DT = Optional[DateTime](DateTime(2024, 6, 15, 10, 0, 0, 0))


def test_pad_zero_single_digit() raises:
    var result = _pad_zero(5)
    assert_equal(result, "05", "5 should be padded to 05")


def test_pad_zero_double_digit() raises:
    var result = _pad_zero(12)
    assert_equal(result, "12", "12 should not be padded")


def test_pad_zero_one() raises:
    var result = _pad_zero(1)
    assert_equal(result, "01", "1 should be padded to 01")


def test_pad_zero_nine() raises:
    var result = _pad_zero(9)
    assert_equal(result, "09", "9 should be padded to 09")


def test_format_date_normal() raises:
    var dt = DateTime(2024, 6, 15, 10, 30, 0, 0)
    var result = _format_date(dt)
    assert_equal(result, "2024-06-15", "Date should format as YYYY-MM-DD")


def test_format_date_new_year() raises:
    var dt = DateTime(2024, 1, 1, 0, 0, 0, 0)
    var result = _format_date(dt)
    assert_equal(result, "2024-01-01", "Jan 1 should format correctly")


def test_format_date_end_year() raises:
    var dt = DateTime(2024, 12, 31, 0, 0, 0, 0)
    var result = _format_date(dt)
    assert_equal(result, "2024-12-31", "Dec 31 should format correctly")


def test_is_trading_validator_init() raises:
    var dp = create_data_proxy()
    var _ = create_is_trading_validator(dp^)
    assert_true(True, "IsTradingValidator init succeeded")


def test_validate_cancellation_returns_none() raises:
    var dp = create_data_proxy()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_cancellation(order, Optional[Account](None))
    assert_true(result is None, "validate_cancellation should always return None")


def test_validate_submission_active_instrument() raises:
    var dp = create_data_proxy()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Active instrument should return None")


def test_validate_submission_not_listing() raises:
    var dp = _create_data_proxy_with_de_listed()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "DELISTED.XSHG", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "De-listed instrument should return reason")
    if not (result is None):
        assert_true(
            result.value().find("not listing") != -1,
            "Reason should contain 'not listing'",
        )


def test_validate_submission_suspended() raises:
    var dp = _create_data_proxy_with_suspended()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "SUSPENDED.XSHG", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_false(result is None, "Suspended CS stock should return reason")
    if not (result is None):
        assert_true(
            result.value().find("suspended") != -1,
            "Reason should contain 'suspended'",
        )


def test_validate_submission_reason_contains_order_book_id() raises:
    var dp = _create_data_proxy_with_de_listed()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "DELISTED.XSHG", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    if not (result is None):
        assert_true(
            result.value().find("DELISTED.XSHG") != -1,
            "Reason should contain order_book_id",
        )


def test_validate_submission_suspended_reason_format() raises:
    var dp = _create_data_proxy_with_suspended()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "SUSPENDED.XSHG", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    if not (result is None):
        var reason = result.value()
        assert_true(
            reason.find("SUSPENDED.XSHG") != -1,
            "Reason should contain order_book_id",
        )
        assert_true(
            reason.find("suspended on") != -1,
            "Reason should contain 'suspended on'",
        )


def test_validate_submission_suspended_non_cs_passes() raises:
    var dp = _create_data_proxy_with_suspended_future()
    var validator = create_is_trading_validator(dp^)
    var order = create_order_with_id(
        1, "FUTURE_SUSP.XSHG", SIDE.BUY, 100,
        LimitOrder(10.0),
        Optional[POSITION_EFFECT](POSITION_EFFECT.OPEN),
        trading_dt=TEST_DT,
    )
    var result = validator.validate_submission(order, Optional[Account](None))
    assert_true(result is None, "Suspended non-CS instrument should return None")


def test_data_proxy_get_active_instrument_active() raises:
    var dp = create_data_proxy()
    var result = dp.get_active_instrument("000001.XSHE", DateTime(2024, 6, 1, 0, 0, 0, 0))
    assert_equal(result.order_book_id(), "000001.XSHE", "Active instrument should be returned")


def test_data_proxy_get_active_instrument_not_active() raises:
    var dp = _create_data_proxy_with_de_listed()
    var raised = False
    try:
        var _ = dp.get_active_instrument("DELISTED.XSHG", DateTime(2024, 6, 1, 0, 0, 0, 0))
    except:
        raised = True
    assert_true(raised, "De-listed instrument should raise error")


def _create_data_proxy_with_de_listed() -> DataProxy:
    var custom = Dict[String, Instrument]()
    custom["DELISTED.XSHG"] = Instrument(
        order_book_id_val="DELISTED.XSHG",
        symbol_val="DeListed",
        type_val=INSTRUMENT_TYPE.CS,
        exchange_val=EXCHANGE.XSHG,
        listed_date_str="2020-01-01",
        de_listed_date_str="2023-01-01",
        maturity_date_str="2999-12-31",
        round_lot_val=100,
        contract_multiplier_val=1.0,
        underlying_symbol_val="",
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str="",
        market_tplus_val=1,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Delisted",
        special_type_val="Normal",
        settlement_method_val="",
        trading_code_val="",
    )
    return DataProxy(
        _data_source_name="test_de_listed",
        _trading_dates_mixin=create_trading_dates_mixin_with_multiple_months(),
        _suspended_ids=Dict[String, Bool](),
        _custom_instruments=custom^,
    )


def _create_data_proxy_with_suspended() -> DataProxy:
    var suspended = Dict[String, Bool]()
    suspended["SUSPENDED.XSHG"] = True
    return DataProxy(
        _data_source_name="test_suspended",
        _trading_dates_mixin=create_trading_dates_mixin_with_multiple_months(),
        _suspended_ids=suspended^,
        _custom_instruments=Dict[String, Instrument](),
    )


def _create_data_proxy_with_suspended_future() -> DataProxy:
    var suspended = Dict[String, Bool]()
    suspended["FUTURE_SUSP.XSHG"] = True
    var custom = Dict[String, Instrument]()
    custom["FUTURE_SUSP.XSHG"] = Instrument(
        order_book_id_val="FUTURE_SUSP.XSHG",
        symbol_val="FutureSuspended",
        type_val=INSTRUMENT_TYPE.FUTURE,
        exchange_val=EXCHANGE.SHFE,
        listed_date_str="2020-01-01",
        de_listed_date_str="2999-12-31",
        maturity_date_str="2999-12-31",
        round_lot_val=1,
        contract_multiplier_val=10.0,
        underlying_symbol_val="",
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str="",
        market_tplus_val=0,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Active",
        special_type_val="Normal",
        settlement_method_val="",
        trading_code_val="",
    )
    return DataProxy(
        _data_source_name="test_suspended_future",
        _trading_dates_mixin=create_trading_dates_mixin_with_multiple_months(),
        _suspended_ids=suspended^,
        _custom_instruments=custom^,
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
