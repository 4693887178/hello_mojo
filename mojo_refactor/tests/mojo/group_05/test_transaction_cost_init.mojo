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


def test_stock_decider_creation() -> Bool:
    var decider = create_stock_decider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    return decider.commission_multiplier == 0.0003 and decider.min_commission == 5.0


def test_stock_decider_calc_buy() -> Bool:
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
    return result.commission == 5.0 and result.tax == 0.0


def test_stock_decider_calc_sell() -> Bool:
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
    return result.commission == 5.0 and result.tax == 1.0


def test_future_decider_creation() -> Bool:
    var decider = create_future_decider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.0001
    )
    return decider.commission_multiplier == 0.0001


def test_future_decider_calc_open() -> Bool:
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
    return result.commission == 0.4 and result.tax == 0.0


def test_future_decider_calc_close() -> Bool:
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
    return result.commission == 0.2 and result.tax == 0.0


def test_bond_decider_creation() -> Bool:
    var decider = create_bond_decider(commission_multiplier=0.0001)
    return decider.commission_multiplier == 0.0001


def test_bond_decider_calc() -> Bool:
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
    return result.commission == 0.2 and result.tax == 0.0 and result.other_fees == 0.0


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_transaction_cost/__init__.mojo")
    print("=" * 60)
    
    if test_stock_decider_creation():
        print("PASS: test_stock_decider_creation")
        passed += 1
    else:
        print("FAIL: test_stock_decider_creation")
        failed += 1
    
    if test_stock_decider_calc_buy():
        print("PASS: test_stock_decider_calc_buy")
        passed += 1
    else:
        print("FAIL: test_stock_decider_calc_buy")
        failed += 1
    
    if test_stock_decider_calc_sell():
        print("PASS: test_stock_decider_calc_sell")
        passed += 1
    else:
        print("FAIL: test_stock_decider_calc_sell")
        failed += 1
    
    if test_future_decider_creation():
        print("PASS: test_future_decider_creation")
        passed += 1
    else:
        print("FAIL: test_future_decider_creation")
        failed += 1
    
    if test_future_decider_calc_open():
        print("PASS: test_future_decider_calc_open")
        passed += 1
    else:
        print("FAIL: test_future_decider_calc_open")
        failed += 1
    
    if test_future_decider_calc_close():
        print("PASS: test_future_decider_calc_close")
        passed += 1
    else:
        print("FAIL: test_future_decider_calc_close")
        failed += 1
    
    if test_bond_decider_creation():
        print("PASS: test_bond_decider_creation")
        passed += 1
    else:
        print("FAIL: test_bond_decider_creation")
        failed += 1
    
    if test_bond_decider_calc():
        print("PASS: test_bond_decider_calc")
        passed += 1
    else:
        print("FAIL: test_bond_decider_calc")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
