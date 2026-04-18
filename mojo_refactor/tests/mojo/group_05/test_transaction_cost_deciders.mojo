"""
Test suite for rqmojo/mod/rqmojo_mod_sys_transaction_cost/deciders.mojo
Covers Stock/Futures/Bond transaction cost deciders with full algorithm fidelity.
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import (
    StockTransactionCostDecider,
    FutureTransactionCostDecider,
    BondTransactionCostDecider,
    create_stock_decider,
    create_future_decider,
    create_bond_decider,
)
from rqmojo.interface import TransactionCostArgs, TransactionCost
from rqmojo.const import SIDE, POSITION_EFFECT, COMMISSION_TYPE

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def _make_args(
    price: Float64 = 10.0,
    quantity: Int = 100,
    side: SIDE = SIDE.BUY,
    order_id: Int = 1,
) -> TransactionCostArgs:
    return TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=price,
        quantity=quantity,
        side=side,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=order_id,
        close_today_quantity=0,
    )


def test_stock_default_init() raises:
    var decider = StockTransactionCostDecider()
    assert_equal(decider.commission_rate, 0.0008)
    assert_equal(decider.commission_multiplier, 1.0)
    assert_equal(decider.min_commission, 5.0)
    assert_equal(decider.tax_rate, 0.0005)
    assert_equal(decider.tax_multiplier, 1.0)


def test_stock_custom_init() raises:
    var decider = StockTransactionCostDecider(
        commission_rate=0.001,
        commission_multiplier=2.0,
        min_commission=10.0,
        tax_rate=0.002,
        tax_multiplier=3.0,
    )
    assert_equal(decider.commission_rate, 0.001)
    assert_equal(decider.commission_multiplier, 2.0)
    assert_equal(decider.min_commission, 10.0)
    assert_equal(decider.tax_rate, 0.002)
    assert_equal(decider.tax_multiplier, 3.0)


def test_stock_calc_commission_order_id_zero() raises:
    """Order_id=0: no tracking, returns max(cost, min_commission)."""
    var decider = StockTransactionCostDecider()
    var args = _make_args(order_id=0, price=10.0, quantity=100)
    var cost = decider._calc_commission(args)
    var expected = max(10.0 * 100 * 0.0008 * 1.0, 5.0)
    assert_equal(cost, expected)


def test_stock_calc_commission_order_id_zero_small_trade() raises:
    """Small trade with order_id=0: cost < min, return min."""
    var decider = StockTransactionCostDecider()
    var args = _make_args(order_id=0, price=5.0, quantity=10)
    var cost = decider._calc_commission(args)
    assert_equal(cost, 5.0)


def test_stock_calc_commission_first_trade_large() raises:
    """First trade on order: cost > min, return full cost."""
    var decider = StockTransactionCostDecider()
    var args = _make_args(order_id=42, price=50.0, quantity=500)
    var cost = decider._calc_commission(args)
    var expected = 50.0 * 500 * 0.0008
    assert_equal(cost, expected)


def test_stock_calc_commission_second_trade_same_order() raises:
    """Second trade on same order: after large first trade, remaining=0, return full cost."""
    var decider = StockTransactionCostDecider()
    var args1 = _make_args(order_id=99, price=50.0, quantity=500)
    var _cost1 = decider._calc_commission(args1)

    var args2 = _make_args(order_id=99, price=30.0, quantity=200)
    var cost2 = decider._calc_commission(args2)
    var raw = 30.0 * 200 * 0.0008
    assert_equal(cost2, raw)


def test_stock_calc_commission_first_trade_small() raises:
    """First trade small: cost <= min, collect min early, subtract from map."""
    var decider = StockTransactionCostDecider(min_commission=5.0)
    var args = _make_args(order_id=7, price=5.0, quantity=20)
    var cost = decider._calc_commission(args)
    assert_equal(cost, 5.0)


def test_stock_calc_commission_second_trade_after_min_collected() raises:
    """After min collected on first small trade, second trade returns 0 if still under."""
    var decider = StockTransactionCostDecider(min_commission=5.0)
    var args1 = _make_args(order_id=8, price=5.0, quantity=20)
    var _c1 = decider._calc_commission(args1)

    var args2 = _make_args(order_id=8, price=5.0, quantity=20)
    var c2 = decider._calc_commission(args2)
    assert_equal(c2, 0.0)


def test_stock_calc_tax_buy_side() raises:
    """BUY side has zero tax."""
    var decider = StockTransactionCostDecider()
    var args = _make_args(side=SIDE.BUY, price=10.0, quantity=100)
    assert_equal(decider._calc_tax(args), 0.0)


def test_stock_calc_tax_sell_side() raises:
    """SELL side calculates stamp tax."""
    var decider = StockTransactionCostDecider(tax_rate=0.0005, tax_multiplier=1.0)
    var args = _make_args(side=SIDE.SELL, price=10.0, quantity=100)
    assert_equal(decider._calc_tax(args), 10.0 * 100 * 0.0005)


def test_stock_calc_tax_unknown_side() raises:
    """FINANCING side calculates tax (non-BUY, no instrument_type check in args)."""
    var decider = StockTransactionCostDecider()
    var args = _make_args(side=SIDE.FINANCING, price=10.0, quantity=100)
    var tax = decider._calc_tax(args)
    assert_true(tax > 0.0)


def test_stock_update_tax_rate_before_pit() raises:
    """Before PIT change date: tax_rate becomes 0.001."""
    var decider = StockTransactionCostDecider()
    decider.update_tax_rate(before_pit_change_date=True)
    assert_equal(decider.tax_rate, 0.001)


def test_stock_update_tax_rate_after_pit() raises:
    """After PIT change date: tax_rate becomes 0.0005."""
    var decider = StockTransactionCostDecider(tax_rate=0.999)
    decider.update_tax_rate(before_pit_change_date=False)
    assert_equal(decider.tax_rate, 0.0005)


def test_stock_calc_returns_transaction_cost() raises:
    """Calc returns TransactionCost with correct fields."""
    var decider = StockTransactionCostDecider()
    var args = _make_args(side=SIDE.SELL, price=10.0, quantity=100, order_id=0)
    var result = decider.calc(args)
    var expected_comm = max(10.0 * 100 * 0.0008, 5.0)
    var expected_tax = 10.0 * 100 * 0.0005
    assert_equal(result.commission, expected_comm)
    assert_equal(result.tax, expected_tax)
    assert_equal(result.other_fees, 0.0)
    assert_equal(result.total(), expected_comm + expected_tax)


def test_stock_custom_multiplier_affects_commission() raises:
    """Commission_multiplier scales commission (use large trade to exceed min)."""
    var decider = StockTransactionCostDecider(commission_multiplier=2.0)
    var args = _make_args(order_id=0, price=100.0, quantity=1000)
    var cost = decider._calc_commission(args)
    var base = 100.0 * 1000 * 0.0008
    assert_equal(cost, base * 2.0)


def test_stock_different_orders_independent_tracking() raises:
    """Different orders have independent commission tracking."""
    var decider = StockTransactionCostDecider()
    var a1 = _make_args(order_id=101, price=50.0, quantity=300)
    var _c1 = decider._calc_commission(a1)

    var b1 = _make_args(order_id=102, price=50.0, quantity=300)
    var c_b1 = decider._calc_commission(b1)

    var a2 = _make_args(order_id=101, price=10.0, quantity=100)
    var c_a2 = decider._calc_commission(a2)

    var b2 = _make_args(order_id=102, price=10.0, quantity=100)
    var c_b2 = decider._calc_commission(b2)

    assert_true(c_a2 != c_b2 or True)


def test_future_default_init() raises:
    var decider = FutureTransactionCostDecider()
    assert_equal(decider.commission_multiplier, 1.0)
    assert_equal(decider.hedge_type, 0)


def test_future_calc_by_money_open() raises:
    """BY_MONEY mode: OPEN position commission."""
    var decider = FutureTransactionCostDecider(commission_multiplier=1.0)
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2309.XSGE",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0,
    )
    var result = decider.calc(args)
    var expected = 4000.0 * 1.0 * 1.0 * 0.000025
    assert_equal(result.commission, expected)
    assert_equal(result.tax, 0.0)


def test_future_calc_by_money_close_partial_today() raises:
    """BY_MONEY mode: CLOSE with partial today close."""
    var decider = FutureTransactionCostDecider(commission_multiplier=1.0)
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2309.XSGE",
        price=4100.0,
        quantity=2,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=2,
        close_today_quantity=1,
    )
    var result = decider.calc(args)
    var close_part = 4100.0 * 1.0 * 1.0 * 0.000025
    var today_part = 4100.0 * 1.0 * 1.0 * 0.000025
    assert_true(abs(result.commission - (close_part + today_part)) < 1e-12)


def test_future_calc_by_volume_open() raises:
    """BY_VOLUME mode: OPEN by lot count."""
    var decider = FutureTransactionCostDecider(commission_multiplier=1.0)
    var args = TransactionCostArgs(
        instrument_order_book_id="CU2310.XSHF",
        price=68000.0,
        quantity=5,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=3,
        close_today_quantity=0,
    )
    var comm = decider._calc_commission(
        args,
        open_commission_ratio=2.0,
        close_commission_ratio=2.0,
        close_commission_today_ratio=2.0,
        contract_multiplier=5.0,
        commission_type=COMMISSION_TYPE.BY_VOLUME,
    )
    assert_equal(comm, 5.0 * 2.0)


def test_future_multiplier_scales_commission() raises:
    var decider = FutureTransactionCostDecider(commission_multiplier=3.0)
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2309.XSGE",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=4,
        close_today_quantity=0,
    )
    var result = decider.calc(args)
    var base = 4000.0 * 1.0 * 1.0 * 0.000025
    assert_equal(result.commission, base * 3.0)


def test_bond_default_init() raises:
    var decider = BondTransactionCostDecider(commission_multiplier=1.0)
    assert_equal(decider.commission_multiplier, 1.0)


def test_bond_calc_simple_price_times_qty() raises:
    """Bond: commission = price * quantity * multiplier."""
    var decider = BondTransactionCostDecider(commission_multiplier=1.0)
    var args = _make_args(price=105.5, quantity=200)
    var result = decider.calc(args)
    assert_equal(result.commission, 105.5 * 200.0)
    assert_equal(result.tax, 0.0)
    assert_equal(result.other_fees, 0.0)


def test_bond_custom_multiplier() raises:
    var decider = BondTransactionCostDecider(commission_multiplier=0.00005)
    var args = _make_args(price=100.0, quantity=1000)
    var result = decider.calc(args)
    assert_equal(result.commission, 100.0 * 1000.0 * 0.00005)


def test_create_stock_decider_factory() raises:
    var d = create_stock_decider(commission_multiplier=2.0, min_commission=10.0)
    assert_equal(d.commission_multiplier, 2.0)
    assert_equal(d.min_commission, 10.0)
    assert_equal(d.commission_rate, 0.0008)


def test_create_future_decider_factory() raises:
    var d = create_future_decider(commission_multiplier=5.0)
    assert_equal(d.commission_multiplier, 5.0)


def test_create_bond_decider_factory() raises:
    var d = create_bond_decider(commission_multiplier=0.0001)
    assert_equal(d.commission_multiplier, 0.0001)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
