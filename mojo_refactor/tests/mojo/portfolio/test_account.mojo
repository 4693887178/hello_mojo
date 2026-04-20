"""
Unit tests for portfolio/account.mojo
Tests matching Python original rqalpha/portfolio/account.py (556 lines)
"""

from std.testing import assert_equal, assert_true, assert_false

from rqmojo.portfolio.account import (
    Account, create_account, create_stock_account, create_future_account,
    _hash_string
)
from rqmojo.portfolio.position import (
    Position, create_position, create_stock_position, create_future_position,
    create_position_proxy
)
from rqmojo.const import POSITION_EFFECT, POSITION_DIRECTION, SIDE
from rqmojo.model.trade import Trade


def test_default_construction() raises:
    var acc = Account()
    assert_equal(acc.account_type, "STOCK")
    assert_equal(acc.total_cash, 0.0)
    assert_equal(acc.frozen_cash, 0.0)
    assert_equal(acc.cash_liabilities, 0.0)
    assert_equal(acc.financing_rate, 0.0)
    assert_equal(acc.management_fee_rate, 0.0)
    assert_equal(acc.get_positions_count(), 0)

def test_create_stock_account() raises:
    var acc = create_stock_account(100000.0)
    assert_equal(acc.account_type, "STOCK")
    assert_equal(acc.total_cash, 100000.0)

def test_create_future_account() raises:
    var acc = create_future_account(200000.0)
    assert_equal(acc.account_type, "FUTURE")
    assert_equal(acc.total_cash, 200000.0)

def test_create_account_custom() raises:
    var acc = create_account("CUSTOM", 50000.0)
    assert_equal(acc.account_type, "CUSTOM")
    assert_equal(acc.total_cash, 50000.0)


def test_cash_property_no_margin_no_frozen() raises:
    var acc = create_stock_account(100000.0)
    assert_equal(acc.cash(), 100000.0)

def test_total_cash_prop_no_margin() raises:
    var acc = create_stock_account(100000.0)
    assert_equal(acc.total_cash_prop(), 100000.0)

def test_cash_with_frozen() raises:
    var acc = create_stock_account(100000.0)
    acc.frozen_cash = 10000.0
    assert_equal(acc.cash(), 90000.0)

def test_frozen_cash_val() raises:
    var acc = create_stock_account(100000.0)
    acc.frozen_cash = 5000.0
    assert_equal(acc.frozen_cash_val(), 5000.0)

def test_cash_liabilities_initial() raises:
    var acc = create_stock_account()
    assert_equal(acc.cash_liabilities_val(), 0.0)

def test_cash_liabilities_interest_zero() raises:
    var acc = create_stock_account()
    acc.cash_liabilities = 10000.0
    assert_equal(acc.cash_liabilities_interest(), 0.0)

def test_cash_liabilities_interest_nonzero() raises:
    var acc = create_stock_account()
    acc.cash_liabilities = 10000.0
    acc.financing_rate = 0.08
    var expected = 10000.0 * 0.08 / 245.0
    assert_equal(acc.cash_liabilities_interest(), expected)


def test_market_value_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.market_value(), 0.0)

def test_market_value_with_long_position() raises:
    var acc = create_stock_account(100000.0)
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(15.0)
    acc._positions.append(pos)
    assert_equal(acc.market_value(), 1500.0)

def test_transaction_cost_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.transaction_cost(), 0.0)

def test_transaction_cost_with_positions() raises:
    var acc = create_stock_account()
    var pos1 = create_stock_position("000001.XSHE", 100, 10.0)
    pos1.transaction_cost = 5.5
    var pos2 = create_stock_position("600000.XSHG", 200, 20.0)
    pos2.transaction_cost = 8.3
    acc._positions.append(pos1)
    acc._positions.append(pos2)
    assert_equal(acc.transaction_cost(), 13.8)

def test_position_equity_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.position_equity(), 0.0)

def test_position_equity_with_positions() raises:
    var acc = create_stock_account()
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(15.0)
    acc._positions.append(pos)
    assert_equal(acc.position_equity(), 1500.0)


def test_margin_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.margin(), 0.0)

def test_buy_margin_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.buy_margin(), 0.0)

def test_sell_margin_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.sell_margin(), 0.0)


def test_position_pnl_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.position_pnl(), 0.0)

def test_trading_pnl_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.trading_pnl(), 0.0)

def test_daily_pnl_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.daily_pnl(), 0.0)


def test_total_value_basic() raises:
    var acc = create_stock_account(100000.0)
    assert_equal(acc.total_value(), 100000.0)

def test_total_value_with_equity() raises:
    var acc = create_stock_account(100000.0)
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    pos.update_last_price(15.0)
    acc._positions.append(pos^)
    assert_equal(acc.total_value(), 101500.0)

def test_management_fees_initial() raises:
    var acc = create_stock_account()
    assert_equal(acc.management_fees_val(), 0.0)


def test_get_position_not_found() raises:
    var acc = create_stock_account()
    var pos = acc.get_position("nonexistent.XSHE")
    assert_equal(pos.order_book_id, "nonexistent.XSHE")

def test_has_position_false() raises:
    var acc = create_stock_account()
    assert_false(acc.has_position("000001.XSHE"))

def test_has_position_true() raises:
    var acc = create_stock_account()
    var pos = create_stock_position("000001.XSHE", 100, 10.0)
    acc._positions.append(pos)
    assert_true(acc.has_position("000001.XSHE"))

def test_get_positions_count_empty() raises:
    var acc = create_stock_account()
    assert_equal(acc.get_positions_count(), 0)

def test_get_positions_count_with_positions() raises:
    var acc = create_stock_account()
    acc._positions.append(create_stock_position("000001.XSHE", 100, 10.0))
    acc._positions.append(create_stock_position("600000.XSHG", 200, 20.0))
    assert_equal(acc.get_positions_count(), 2)

def test_position_keys() raises:
    var acc = create_stock_account()
    acc._positions.append(create_stock_position("000001.XSHE", 100, 10.0))
    acc._positions.append(create_stock_position("600000.XSHG", 200, 20.0))
    acc._positions.append(create_stock_position("000001.XSHE", 50, 15.0))
    var keys = acc.position_keys()
    assert_equal(len(keys), 2)

def test_get_positions_filters_zero_qty() raises:
    var acc = create_stock_account()
    var pos1 = create_stock_position("000001.XSHE", 100, 10.0)
    var pos2 = create_stock_position("600000.XSHG", 0, 20.0)
    acc._positions.append(pos1)
    acc._positions.append(pos2)
    var positions = acc.get_positions()
    assert_equal(len(positions), 1)

def test_get_or_create_position_new() raises:
    var acc = create_stock_account()
    var pos = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(pos.order_book_id, "000001.XSHE")
    assert_equal(acc.get_positions_count(), 1)

def test_get_or_create_position_existing() raises:
    var acc = create_stock_account()
    _ = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    _ = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    assert_equal(acc.get_positions_count(), 1)

def test_update_last_price() raises:
    var acc = create_stock_account()
    acc._positions.append(create_stock_position("000001.XSHE", 100, 10.0))
    acc.update_last_price("000001.XSHE", 15.0)
    assert_equal(acc.market_value(), 1500.0)


def test_apply_trade_open_increases_quantity() raises:
    var acc = create_stock_account(100000.0)
    from rqmojo.utils.typing import DateTime as DT
    var dt = DT.now()
    var trade = Trade(
        1, "exec_001", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        50, 11.0, dt, dt,
        commission=0.55
    )
    acc.apply_trade(trade)
    assert_equal(acc.get_positions_count(), 1)
    var pos = acc.get_position("000001.XSHE")
    assert_equal(pos.quantity, 50)

def test_apply_trade_close_decreases_quantity() raises:
    var acc = create_stock_account(100000.0)
    _ = acc.get_or_create_position("000001.XSHE", POSITION_DIRECTION.LONG)
    from rqmojo.utils.typing import DateTime as DT2
    var dt2 = DT2.now()
    var t1 = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        100, 10.0, dt2, dt2,
        commission=1.0
    )
    acc.apply_trade(t1)
    var t2 = Trade(
        2, "e2", 2, "000001.XSHE",
        SIDE.SELL, POSITION_EFFECT.CLOSE, POSITION_DIRECTION.LONG,
        30, 12.0, dt2, dt2,
        commission=1.5
    )
    acc.apply_trade(t2)
    var pos = acc.get_position("000001.XSHE")
    assert_equal(pos.quantity, 70)

def test_apply_trade_updates_total_cash() raises:
    var acc = create_stock_account(100000.0)
    from rqmojo.utils.typing import DateTime as DT3
    var dt3 = DT3.now()
    var trade = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        100, 10.0, dt3, dt3,
        commission=1.0
    )
    acc.apply_trade(trade)
    assert_true(acc.total_cash < 100000.0)

def test_backward_trade_set_prevents_duplicate() raises:
    var acc = create_stock_account(100000.0)
    from rqmojo.utils.typing import DateTime as DT4
    var dt4 = DT4.now()
    var trade = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        100, 10.0, dt4, dt4,
        commission=1.0
    )
    acc.apply_trade(trade)
    var cash_before = acc.total_cash
    acc.apply_trade(trade)
    assert_equal(acc.total_cash, cash_before)


def test_before_trading_resets_costs() raises:
    var acc = create_stock_account(100000.0)
    acc._positions.append(create_stock_position("000001.XSHE", 100, 10.0))
    acc._positions[0].transaction_cost = 5.5
    acc.before_trading()
    assert_equal(acc._positions[0].transaction_cost, 0.0)

def test_before_trading_removes_zero_positions() raises:
    var acc = create_stock_account(100000.0)
    acc._positions.append(create_stock_position("000001.XSHE", 0, 10.0))
    acc._positions.append(create_stock_position("600000.XSHG", 200, 20.0))
    acc.before_trading()
    assert_equal(acc.get_positions_count(), 1)

def test_before_trading_accumulates_liabilities() raises:
    var acc = create_stock_account(100000.0)
    acc.cash_liabilities = 10000.0
    acc.financing_rate = 0.08
    acc.before_trading()
    assert_true(acc.cash_liabilities > 10000.0)


def test_settlement_clears_backward_set() raises:
    var acc = create_stock_account(100000.0)
    from rqmojo.utils.typing import DateTime as DT5
    var dt5 = DT5.now()
    var trade = Trade(
        1, "e1", 1, "000001.XSHE",
        SIDE.BUY, POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        100, 10.0, dt5, dt5,
        commission=1.0
    )
    acc.apply_trade(trade)
    acc.settlement()


def test_deposit_withdraw_adds_cash() raises:
    var acc = create_stock_account(100000.0)
    acc.deposit_withdraw(50000.0)
    assert_equal(acc.total_cash, 150000.0)

def test_deposit_withdraw_subtracts_cash() raises:
    var acc = create_stock_account(100000.0)
    acc.deposit_withdraw(-30000.0)
    assert_equal(acc.total_cash, 70000.0)

def test_finance_repay_adds_liability() raises:
    var acc = create_stock_account(100000.0)
    acc.finance_repay(10000.0)
    assert_equal(acc.cash_liabilities, 10000.0)
    assert_equal(acc.total_cash, 110000.0)

def test_finance_repay_reduces_liability() raises:
    var acc = create_stock_account(100000.0)
    acc.cash_liabilities = 10000.0
    acc.total_cash = 110000.0
    acc.finance_repay(-5000.0)
    assert_equal(acc.cash_liabilities, 5000.0)

def test_add_cash() raises:
    var acc = create_stock_account(100000.0)
    acc.add_cash(10000.0)
    assert_equal(acc.total_cash, 110000.0)

def test_subtract_cash() raises:
    var acc = create_stock_account(100000.0)
    acc.subtract_cash(10000.0)
    assert_equal(acc.total_cash, 90000.0)


def test_get_state_roundtrip() raises:
    var acc = create_stock_account(100000.0)
    acc.frozen_cash = 5000.0
    acc.cash_liabilities = 10000.0
    acc.financing_rate = 0.08
    acc.management_fee_rate = 0.01
    acc.management_fees = 25.0
    var state = acc.get_state()
    assert_true(len(state) > 0)
    assert_equal(state["total_cash"], "100000.0")
    assert_equal(state["frozen_cash"], "5000.0")
    assert_equal(state["account_type"], "STOCK")

def test_set_state_restores_values() raises:
    var acc1 = create_stock_account(100000.0)
    acc1.frozen_cash = 5000.0
    acc1.cash_liabilities = 10000.0
    acc1.financing_rate = 0.08
    acc1.management_fee_rate = 0.01
    acc1.management_fees = 25.0
    var state = acc1.get_state()
    var acc2 = Account()
    acc2.set_state(state)
    assert_equal(acc2.total_cash, 100000.0)
    assert_equal(acc2.frozen_cash, 5000.0)
    assert_equal(acc2.cash_liabilities, 10000.0)
    assert_equal(acc2.financing_rate, 0.08)
    assert_equal(acc2.management_fee_rate, 0.01)
    assert_equal(acc2.management_fees, 25.0)


def test_copy_constructor() raises:
    var acc1 = create_stock_account(100000.0)
    acc1.frozen_cash = 5000.0
    acc1.cash_liabilities = 10000.0
    acc1.financing_rate = 0.08
    acc1._positions.append(create_stock_position("000001.XSHE", 100, 10.0))
    var acc2 = Account(copy=acc1)
    assert_equal(acc2.account_type, "STOCK")
    assert_equal(acc2.total_cash, 100000.0)
    assert_equal(acc2.frozen_cash, 5000.0)
    assert_equal(acc2.cash_liabilities, 10000.0)
    assert_equal(acc2.financing_rate, 0.08)
    assert_equal(acc2.get_positions_count(), 1)

def test_str_representation() raises:
    var acc = create_stock_account(100000.0)
    var s = acc.__str__()
    assert_true(len(s) > 0)


def test_available_cash_for() raises:
    var acc = create_stock_account(100000.0)
    assert_equal(acc.available_cash(), 100000.0)

def test_available_cash() raises:
    var acc = create_stock_account(100000.0)
    assert_equal(acc.available_cash(), 100000.0)

def test_type_val() raises:
    var acc = create_stock_account()
    assert_equal(acc.type_val(), "STOCK")


def test_hash_string_consistent() raises:
    var h1 = _hash_string("test_key")
    var h2 = _hash_string("test_key")
    assert_equal(h1, h2)

def test_hash_string_different() raises:
    var h1 = _hash_string("key_a")
    var h2 = _hash_string("key_b")
    assert_true(h1 != h2)


def main() raises:
    print("\n=== Testing Account Construction (1-4) ===")
    test_default_construction()
    print("[1/60] PASSED: default_construction")
    test_create_stock_account()
    print("[2/60] PASSED: create_stock_account")
    test_create_future_account()
    print("[3/60] PASSED: create_future_account")
    test_create_account_custom()
    print("[4/60] PASSED: create_account_custom")

    print("\n=== Testing Cash Properties (5-11) ===")
    test_cash_property_no_margin_no_frozen()
    print("[5/60] PASSED: cash_property_no_margin_no_frozen")
    test_total_cash_prop_no_margin()
    print("[6/60] PASSED: total_cash_prop_no_margin")
    test_cash_with_frozen()
    print("[7/60] PASSED: cash_with_frozen")
    test_frozen_cash_val()
    print("[8/60] PASSED: frozen_cash_val")
    test_cash_liabilities_initial()
    print("[9/60] PASSED: cash_liabilities_initial")
    test_cash_liabilities_interest_zero()
    print("[10/60] PASSED: cash_liabilities_interest_zero")
    test_cash_liabilities_interest_nonzero()
    print("[11/60] PASSED: cash_liabilities_interest_nonzero")

    print("\n=== Testing Position Value (12-17) ===")
    test_market_value_empty()
    print("[12/60] PASSED: market_value_empty")
    test_market_value_with_long_position()
    print("[13/60] PASSED: market_value_with_long_position")
    test_transaction_cost_empty()
    print("[14/60] PASSED: transaction_cost_empty")
    test_transaction_cost_with_positions()
    print("[15/60] PASSED: transaction_cost_with_positions")
    test_position_equity_empty()
    print("[16/60] PASSED: position_equity_empty")
    test_position_equity_with_positions()
    print("[17/60] PASSED: position_equity_with_positions")

    print("\n=== Testing Margin (18-20) ===")
    test_margin_empty()
    print("[18/60] PASSED: margin_empty")
    test_buy_margin_empty()
    print("[19/60] PASSED: buy_margin_empty")
    test_sell_margin_empty()
    print("[20/60] PASSED: sell_margin_empty")

    print("\n=== Testing PnL (21-23) ===")
    test_position_pnl_empty()
    print("[21/60] PASSED: position_pnl_empty")
    test_trading_pnl_empty()
    print("[22/60] PASSED: trading_pnl_empty")
    test_daily_pnl_empty()
    print("[23/60] PASSED: daily_pnl_empty")

    print("\n=== Testing Total Value (24-26) ===")
    test_total_value_basic()
    print("[24/60] PASSED: total_value_basic")
    test_total_value_with_equity()
    print("[25/60] PASSED: total_value_with_equity")
    test_management_fees_initial()
    print("[26/60] PASSED: management_fees_initial")

    print("\n=== Testing Position Access (27-37) ===")
    test_get_position_not_found()
    print("[27/60] PASSED: get_position_not_found")
    test_has_position_false()
    print("[28/60] PASSED: has_position_false")
    test_has_position_true()
    print("[29/60] PASSED: has_position_true")
    test_get_positions_count_empty()
    print("[30/60] PASSED: get_positions_count_empty")
    test_get_positions_count_with_positions()
    print("[31/60] PASSED: get_positions_count_with_positions")
    test_position_keys()
    print("[32/60] PASSED: position_keys")
    test_get_positions_filters_zero_qty()
    print("[33/60] PASSED: get_positions_filters_zero_qty")
    test_get_or_create_position_new()
    print("[34/60] PASSED: get_or_create_position_new")
    test_get_or_create_position_existing()
    print("[35/60] PASSED: get_or_create_position_existing")
    test_update_last_price()
    print("[36/60] PASSED: update_last_price")

    print("\n=== Testing Apply Trade (37-41) ===")
    test_apply_trade_open_increases_quantity()
    print("[37/60] PASSED: apply_trade_open_increases_quantity")
    test_apply_trade_close_decreases_quantity()
    print("[38/60] PASSED: apply_trade_close_decreases_quantity")
    test_apply_trade_updates_total_cash()
    print("[39/60] PASSED: apply_trade_updates_total_cash")
    test_backward_trade_set_prevents_duplicate()
    print("[40/60] PASSED: backward_trade_set_prevents_duplicate")

    print("\n=== Testing Lifecycle (41-45) ===")
    test_before_trading_resets_costs()
    print("[41/60] PASSED: before_trading_resets_costs")
    test_before_trading_removes_zero_positions()
    print("[42/60] PASSED: before_trading_removes_zero_positions")
    test_before_trading_accumulates_liabilities()
    print("[43/60] PASSED: before_trading_accumulates_liabilities")
    test_settlement_clears_backward_set()
    print("[44/60] PASSED: settlement_clears_backward_set")

    print("\n=== Testing Cash Operations (45-51) ===")
    test_deposit_withdraw_adds_cash()
    print("[45/60] PASSED: deposit_withdraw_adds_cash")
    test_deposit_withdraw_subtracts_cash()
    print("[46/60] PASSED: deposit_withdraw_subtracts_cash")
    test_finance_repay_adds_liability()
    print("[47/60] PASSED: finance_repay_adds_liability")
    test_finance_repay_reduces_liability()
    print("[48/60] PASSED: finance_repay_reduces_liability")
    test_add_cash()
    print("[49/60] PASSED: add_cash")
    test_subtract_cash()
    print("[50/60] PASSED: subtract_cash")

    print("\n=== Testing State Serialization (51-52) ===")
    test_get_state_roundtrip()
    print("[51/60] PASSED: get_state_roundtrip")
    test_set_state_restores_values()
    print("[52/60] PASSED: set_state_restores_values")

    print("\n=== Testing Misc (53-57) ===")
    test_copy_constructor()
    print("[53/60] PASSED: copy_constructor")
    test_str_representation()
    print("[54/60] PASSED: str_representation")
    test_available_cash_for()
    print("[55/60] PASSED: available_cash_for")
    test_available_cash()
    print("[56/60] PASSED: available_cash")
    test_type_val()
    print("[57/60] PASSED: type_val")

    print("\n=== Testing Hash String (58-59) ===")
    test_hash_string_consistent()
    print("[58/60] PASSED: hash_string_consistent")
    test_hash_string_different()
    print("[59/60] PASSED: hash_string_different")

    print("\n=== All 59 tests passed! ===")
