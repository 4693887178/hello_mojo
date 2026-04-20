"""
Mojo Unit Tests for OrderTargetPortfolio
Uses std.testing framework (mojo test)
Covers all structs, functions, and the full portfolio adjustment pipeline.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List
from rqmojo.const import (
    POSITION_DIRECTION, SIDE, POSITION_EFFECT,
    INSTRUMENT_TYPE, MARKET, EXECUTION_PHASE
)
from rqmojo.model.order import MarketOrder, LimitOrder
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.environment import Environment, create_environment
from rqmojo.utils.typing import DateTime
from rqmojo.mod.rqmojo_mod_sys_accounts.api.order_target_portfolio import (
    DenialReason, ExchangeRatePair, TargetPortfolioItem, AdjustingResult,
    OrderTargetPortfolio, _round_order_quantity_for_portfolio,
    MockAccountForTest, MockPositionForTest
)


def is_close(a: Float64, b: Float64, tolerance: Float64 = 1e-6) -> Bool:
    var diff = a - b
    if diff < 0:
        diff = -diff
    return diff < tolerance


def make_env() -> Environment:
    return create_environment(
        start_date=DateTime(2024, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2025, 12, 31, 0, 0, 0, 0)
    )


def run_order_target_portfolio(
    var account: Account,
    var target_weights: Dict[String, Float64],
    var prices: Dict[String, Float64],
    var env: Environment,
    round_lot_size: Bool = True
) raises -> List[TargetPortfolioItem]:
    var portfolio = OrderTargetPortfolio(
        account=account^,
        target_weights=target_weights^,
        valuation_prices=prices^,
        env=env^,
        round_lot_size=round_lot_size
    )
    return portfolio()


def run_order_target_portfolio_smart(
    var account: Account,
    var target_weights: Dict[String, Float64],
    var prices: Dict[String, Float64],
    var env: Environment,
    round_lot_size: Bool = True,
    safety_factor: Float64 = 1.0
) raises -> List[TargetPortfolioItem]:
    var portfolio = OrderTargetPortfolio(
        account=account^,
        target_weights=target_weights^,
        valuation_prices=prices^,
        env=env^,
        round_lot_size=round_lot_size
    )
    return portfolio(safety_factor=safety_factor)


# ============================================================
# DenialReason Tests
# ============================================================

def test_denial_reason_creation() raises:
    var dr = DenialReason(code=100, message="SUSPENDED")
    assert_equal(dr.code, 100)
    assert_equal(dr.message, "SUSPENDED")


def test_denial_reason_copy() raises:
    var dr1 = DenialReason(code=103, message="INSUFFICIENT_CASH")
    var dr2 = dr1.copy()
    assert_equal(dr2.code, 103)
    assert_equal(dr2.message, "INSUFFICIENT_CASH")
    dr2.code = 999
    assert_equal(dr1.code, 103)


def test_denial_reason_fields() raises:
    var dr = DenialReason(code=104, message="NOT_ENOUGH_SELLABLE")
    assert_equal(dr.code, 104)
    assert_equal(dr.message, "NOT_ENOUGH_SELLABLE")


# ============================================================
# ExchangeRatePair Tests
# ============================================================

def test_exchange_rate_pair_creation() raises:
    var pair = ExchangeRatePair(base="HKD", target="CNY", middle_price=0.92)
    assert_equal(pair.base, "HKD")
    assert_equal(pair.target, "CNY")
    assert_true(is_close(pair.middle_price, 0.92))


def test_exchange_rate_pair_get_middle() raises:
    var pair = ExchangeRatePair(base="USD", target="CNY", middle_price=7.25)
    assert_true(is_close(pair.get_middle(), 7.25))


def test_exchange_rate_pair_copy() raises:
    var p1 = ExchangeRatePair(base="EUR", target="CNY", middle_price=8.0)
    var p2 = p1.copy()
    assert_equal(p2.base, "EUR")
    assert_true(is_close(p2.middle_price, 8.0))
    p2.middle_price = 9.0
    assert_true(is_close(p1.middle_price, 8.0))


def test_exchange_rate_pair_fields() raises:
    var pair = ExchangeRatePair(base="JPY", target="CNY", middle_price=0.05)
    assert_equal(pair.base, "JPY")
    assert_equal(pair.target, "CNY")


# ============================================================
# TargetPortfolioItem Tests
# ============================================================

def test_target_item_creation() raises:
    var item = TargetPortfolioItem(
        order_book_id="000001.XSHE",
        target_weight=0.3,
        quantity=1000,
        amount=14500.0,
        reason_code=0,
        reason_message=""
    )
    assert_equal(item.order_book_id, "000001.XSHE")
    assert_true(is_close(item.target_weight, 0.3))
    assert_equal(item.quantity, 1000)
    assert_true(is_close(item.amount, 14500.0))
    assert_equal(item.reason_code, 0)


def test_target_item_copy() raises:
    var i1 = TargetPortfolioItem(
        order_book_id="600000.XSHG",
        target_weight=0.5,
        quantity=2000,
        amount=40000.0,
        reason_code=103,
        reason_message="INSUFFICIENT_CASH"
    )
    var i2 = i1.copy()
    assert_equal(i2.order_book_id, "600000.XSHG")
    assert_equal(i2.reason_code, 103)
    i2.quantity = 9999
    assert_equal(i1.quantity, 2000)


def test_target_item_with_denial_reason() raises:
    var item = TargetPortfolioItem(
        order_book_id="000002.XSHE",
        target_weight=0.2,
        quantity=0,
        amount=0.0,
        reason_code=100,
        reason_message="SUSPENDED"
    )
    assert_equal(item.reason_code, 100)
    assert_equal(item.reason_message, "SUSPENDED")
    assert_equal(item.quantity, 0)


# ============================================================
# AdjustingResult Tests
# ============================================================

def test_adjusting_result_creation() raises:
    var ar = AdjustingResult(
        order_book_id="000001.XSHE",
        target_quantity=500,
        target_amount=7250.0,
        denial_reasons=List[DenialReason]()
    )
    assert_equal(ar.order_book_id, "000001.XSHE")
    assert_equal(ar.target_quantity, 500)
    assert_true(is_close(ar.target_amount, 7250.0))
    assert_equal(len(ar.denial_reasons), 0)


def test_adjusting_result_with_denials() raises:
    var denials = List[DenialReason]()
    denials.append(DenialReason(code=100, message="SUSPENDED"))
    var ar = AdjustingResult(
        order_book_id="000001.XSHE",
        target_quantity=0,
        target_amount=0.0,
        denial_reasons=denials^
    )
    assert_equal(len(ar.denial_reasons), 1)
    assert_equal(ar.denial_reasons[0].code, 100)
    assert_equal(ar.target_quantity, 0)


def test_adjusting_result_multiple_denials() raises:
    var denials = List[DenialReason]()
    denials.append(DenialReason(code=103, message="INSUFFICIENT_CASH"))
    denials.append(DenialReason(code=104, message="NOT_ENOUGH_SELLABLE"))
    var ar = AdjustingResult(
        order_book_id="600000.XSHG",
        target_quantity=-50,
        target_amount=-550.0,
        denial_reasons=denials^
    )
    assert_equal(len(ar.denial_reasons), 2)
    assert_equal(ar.denial_reasons[0].code, 103)
    assert_equal(ar.denial_reasons[1].code, 104)


def test_adjusting_result_copy() raises:
    var d1 = List[DenialReason]()
    d1.append(DenialReason(code=103, message="INSUFFICIENT_CASH"))
    var ar1 = AdjustingResult(
        order_book_id="600000.XSHG",
        target_quantity=300,
        target_amount=6000.0,
        denial_reasons=d1^
    )
    var ar2 = ar1.copy()
    assert_equal(ar2.order_book_id, "600000.XSHG")
    assert_equal(ar2.target_quantity, 300)
    assert_equal(len(ar2.denial_reasons), 1)
    assert_equal(ar2.denial_reasons[0].code, 103)
    ar2.target_quantity = 999
    assert_equal(ar1.target_quantity, 300)


def test_adjusting_result_sell_quantity() raises:
    var ar = AdjustingResult(
        order_book_id="000002.XSHE",
        target_quantity=-100,
        target_amount=-1500.0,
        denial_reasons=List[DenialReason]()
    )
    assert_equal(ar.target_quantity, -100)
    assert_true(ar.target_amount < 0)


# ============================================================
# _round_order_quantity_for_portfolio Tests
# ============================================================

def test_round_lot_size_1_no_round() raises:
    assert_equal(_round_order_quantity_for_portfolio(150, 1), 150)


def test_round_positive_quantity() raises:
    assert_equal(_round_order_quantity_for_portfolio(157, 100), 100)


def test_round_negative_quantity() raises:
    assert_equal(_round_order_quantity_for_portfolio(-157, 100), -100)


def test_round_exact_multiple() raises:
    assert_equal(_round_order_quantity_for_portfolio(300, 100), 300)


def test_round_zero_quantity() raises:
    assert_equal(_round_order_quantity_for_portfolio(0, 100), 0)


def test_round_small_positive() raises:
    assert_equal(_round_order_quantity_for_portfolio(50, 100), 0)


def test_round_small_negative() raises:
    assert_equal(_round_order_quantity_for_portfolio(-50, 100), 0)


def test_round_lot_200_positive() raises:
    assert_equal(_round_order_quantity_for_portfolio(350, 200), 200)


def test_round_lot_200_negative() raises:
    assert_equal(_round_order_quantity_for_portfolio(-350, 200), -200)


# ============================================================
# MockAccountForTest / MockPositionForTest Tests
# ============================================================

def test_mock_position_creation() raises:
    var pos = MockPositionForTest(
        _quantity=1000,
        _direction=POSITION_DIRECTION.LONG,
        _order_book_id="000001.XSHE"
    )
    assert_equal(pos.quantity(), 1000)
    assert_equal(pos.direction(), POSITION_DIRECTION.LONG)
    assert_equal(pos.closable(), 1000)
    assert_equal(pos.order_book_id(), "000001.XSHE")


def test_mock_position_short_direction() raises:
    var pos = MockPositionForTest(
        _quantity=500,
        _direction=POSITION_DIRECTION.SHORT,
        _order_book_id="future_test"
    )
    assert_equal(pos.direction(), POSITION_DIRECTION.SHORT)
    assert_equal(pos.closable(), 500)


def test_mock_account_creation() raises:
    var positions = Dict[String, Int]()
    positions["000001.XSHE"] = 1000
    positions["600000.XSHG"] = 500
    var acct = MockAccountForTest(
        _cash=50000.0,
        _positions=positions^,
        _total_value=200000.0
    )
    assert_true(is_close(acct.cash(), 50000.0))
    assert_true(is_close(acct.total_value(), 200000.0))
    assert_true(is_close(acct.market_value(), 150000.0))


def test_mock_account_get_position_exists() raises:
    var positions = Dict[String, Int]()
    positions["000001.XSHE"] = 800
    var acct = MockAccountForTest(
        _cash=30000.0,
        _positions=positions^,
        _total_value=150000.0
    )
    var pos = acct.get_position("000001.XSHE")
    assert_equal(pos.quantity(), 800)


def test_mock_account_get_position_not_found() raises:
    var positions = Dict[String, Int]()
    var acct = MockAccountForTest(
        _cash=100000.0,
        _positions=positions^,
        _total_value=100000.0
    )
    var pos = acct.get_position("999999.XSHE")
    assert_equal(pos.quantity(), 0)


def test_mock_account_multiple_positions() raises:
    var positions = Dict[String, Int]()
    positions["000001.XSHE"] = 1000
    positions["600000.XSHG"] = 2000
    positions["000002.XSHE"] = 500
    var acct = MockAccountForTest(
        _cash=80000.0,
        _positions=positions^,
        _total_value=500000.0
    )
    assert_equal(acct.get_position("000001.XSHE").quantity(), 1000)
    assert_equal(acct.get_position("600000.XSHG").quantity(), 2000)
    assert_equal(acct.get_position("000002.XSHE").quantity(), 500)


# ============================================================
# OrderTargetPortfolio Integration Tests
#   Uses real Environment + Account from factories
# ============================================================

def test_order_target_portfolio_basic_buy() raises:
    var env = make_env()
    var account = create_stock_account(100000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.5
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 10.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)
    assert_equal(result[0].order_book_id, "000001.XSHE")
    assert_true(result[0].quantity > 0)
    assert_true(is_close(result[0].target_weight, 0.5))


def test_order_target_portfolio_multi_stock() raises:
    var env = make_env()
    var account = create_stock_account(1000000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.3
    weights["600000.XSHG"] = 0.4
    weights["000002.XSHE"] = 0.2
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 14.5
    prices["600000.XSHG"] = 11.0
    prices["000002.XSHE"] = 8.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 3)
    var total_weight = 0.0
    for i in range(len(result)):
        total_weight += result[i].target_weight
        assert_true(result[i].order_book_id != "")
    assert_true(is_close(total_weight, 0.9))


def test_order_target_portfolio_zero_cash() raises:
    var env = make_env()
    var account = create_stock_account(1.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.99
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 100.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)
    assert_equal(result[0].quantity, 0)


def test_order_target_portfolio_insufficient_cash() raises:
    var env = make_env()
    var account = create_stock_account(500.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.9
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 100.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)


def test_order_target_portfolio_smart_basic() raises:
    var env = make_env()
    var account = create_stock_account(500000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.6
    weights["600000.XSHG"] = 0.3
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 15.0
    prices["600000.XSHG"] = 12.0
    var result = run_order_target_portfolio_smart(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^,
        safety_factor=1.0
    )
    assert_equal(len(result), 2)
    for i in range(len(result)):
        assert_true(result[i].order_book_id != "")


def test_order_target_portfolio_smart_safety_factor() raises:
    var env1 = make_env()
    var account1 = create_stock_account(100000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.8
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 20.0
    var result_high = run_order_target_portfolio_smart(
        account=account1^,
        target_weights=weights^,
        prices=prices^,
        env=env1^,
        safety_factor=1.5
    )
    var env2 = make_env()
    var account2 = create_stock_account(100000.0)
    var w2 = Dict[String, Float64]()
    w2["000001.XSHE"] = 0.8
    var p2 = Dict[String, Float64]()
    p2["000001.XSHE"] = 20.0
    var result_low = run_order_target_portfolio_smart(
        account=account2^,
        target_weights=w2^,
        prices=p2^,
        env=env2^,
        safety_factor=0.5
    )
    assert_equal(len(result_high), 1)
    assert_equal(len(result_low), 1)


def test_order_target_portfolio_round_lot_disabled() raises:
    var env = make_env()
    var account = create_stock_account(100000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.5
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 13.33
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^,
        round_lot_size=False
    )
    assert_equal(len(result), 1)
    assert_true(result[0].quantity > 0 or result[0].reason_code != 0)


def test_order_target_portfolio_empty_weights() raises:
    var env = make_env()
    var account = create_stock_account(100000.0)
    var weights = Dict[String, Float64]()
    var prices = Dict[String, Float64]()
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 0)


def test_order_target_portfolio_single_full_invest() raises:
    var env = make_env()
    var account = create_stock_account(1000000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 1.0
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 25.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)
    assert_true(is_close(result[0].target_weight, 1.0))
    assert_true(result[0].quantity > 0)


def test_order_target_portfolio_very_small_weight() raises:
    var env = make_env()
    var account = create_stock_account(100000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.001
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 100.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)
    assert_true(is_close(result[0].target_weight, 0.001))


def test_order_target_portfolio_high_price_stock() raises:
    var env = make_env()
    var account = create_stock_account(50000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.9
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 500.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)


def test_order_target_portfolio_result_items_match_weights() raises:
    var env = make_env()
    var account = create_stock_account(200000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.25
    weights["600000.XSHG"] = 0.35
    weights["000002.XSHE"] = 0.15
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 10.0
    prices["600000.XSHG"] = 12.0
    prices["000002.XSHE"] = 15.0
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 3)
    var found_000001 = False
    var found_600000 = False
    var found_000002 = False
    for i in range(len(result)):
        if result[i].order_book_id == "000001.XSHE":
            found_000001 = True
            assert_true(is_close(result[i].target_weight, 0.25))
        elif result[i].order_book_id == "600000.XSHG":
            found_600000 = True
            assert_true(is_close(result[i].target_weight, 0.35))
        elif result[i].order_book_id == "000002.XSHE":
            found_000002 = True
            assert_true(is_close(result[i].target_weight, 0.15))
    assert_true(found_000001)
    assert_true(found_600000)
    assert_true(found_000002)


def test_order_target_portfolio_quantity_is_int() raises:
    var env = make_env()
    var account = create_stock_account(100000.0)
    var weights = Dict[String, Float64]()
    weights["000001.XSHE"] = 0.5
    var prices = Dict[String, Float64]()
    prices["000001.XSHE"] = 12.34
    var result = run_order_target_portfolio(
        account=account^,
        target_weights=weights^,
        prices=prices^,
        env=env^
    )
    assert_equal(len(result), 1)
    assert_true(result[0].quantity >= 0)


# ============================================================
# Main - run all tests
# ============================================================

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
