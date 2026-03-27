"""
第五组测试 - mod/rqmojo_mod_sys_transaction_cost/__init__.mojo
测试Mojo版本的事务成本模块
"""

from rqmojo.const import INSTRUMENT_TYPE, SIDE, POSITION_EFFECT
from rqmojo.interface import TransactionCostArgs, TransactionCost
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import (
    StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider,
    create_stock_decider, create_future_decider, create_bond_decider
)


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_stock_decider_creation() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    assert_equal(decider.commission_multiplier, 0.0003, "commission_multiplier should match")
    assert_equal(decider.min_commission, 5.0, "min_commission should match")


def test_stock_decider_calc_buy() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=1,
        close_today_quantity=0
    )
    
    var result = decider.calc(args)
    assert_equal(result.commission, 5.0, "commission should be 5.0")
    assert_equal(result.tax, 0.0, "tax should be 0.0")


def test_stock_decider_calc_sell() raises:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="000001.XSHE",
        price=10.0,
        quantity=100,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=2,
        close_today_quantity=0
    )
    
    var result = decider.calc(args)
    assert_equal(result.commission, 5.0, "commission should be 5.0")
    assert_equal(result.tax, 1.0, "tax should be 1.0")


def test_future_decider_creation() raises:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.0001
    )
    assert_equal(decider.commission_multiplier, 0.0001, "commission_multiplier should match")


def test_future_decider_calc_open() raises:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.00005
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2501",
        price=4000.0,
        quantity=1,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=3,
        close_today_quantity=0
    )
    
    var result = decider.calc(args)
    assert_equal(result.commission, 0.4, "commission should be 0.4")
    assert_equal(result.tax, 0.0, "tax should be 0.0")


def test_future_decider_calc_close() raises:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.00005
    )
    
    var args = TransactionCostArgs(
        instrument_order_book_id="IF2501",
        price=4000.0,
        quantity=1,
        side=SIDE.SELL,
        position_effect=POSITION_EFFECT.CLOSE,
        order_id=4,
        close_today_quantity=0
    )
    
    var result = decider.calc(args)
    assert_equal(result.commission, 0.2, "commission should be 0.2")
    assert_equal(result.tax, 0.0, "tax should be 0.0")


def test_bond_decider_creation() raises:
    var decider = create_bond_decider(commission_multiplier=0.0001)
    assert_equal(decider.commission_multiplier, 0.0001, "commission_multiplier should match")


def test_bond_decider_calc() raises:
    var decider = create_bond_decider(commission_multiplier=0.0002)
    
    var args = TransactionCostArgs(
        instrument_order_book_id="123456.SH",
        price=100.0,
        quantity=10,
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        order_id=5,
        close_today_quantity=0
    )
    
    var result = decider.calc(args)
    assert_equal(result.commission, 0.2, "commission should be 0.2")
    assert_equal(result.tax, 0.0, "tax should be 0.0")
    assert_equal(result.other_fees, 0.0, "other_fees should be 0.0")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
