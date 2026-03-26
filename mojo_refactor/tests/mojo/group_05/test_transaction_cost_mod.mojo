"""
第五组测试 - mod/rqmojo_mod_sys_transaction_cost/__init__.mojo
测试Mojo版本的事务成本模块
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
from rqmojo.mod.rqmojo_mod_sys_transaction_cost import TransactionCostMod, create_transaction_cost_mod


def test_create_transaction_cost_mod() -> Bool:
    var mod = create_transaction_cost_mod()
    return mod.name == "transaction_cost"


def test_transaction_cost_mod_name() -> Bool:
    var mod = create_transaction_cost_mod()
    return mod.name == "transaction_cost"


def test_stock_decider_exists() -> Bool:
    var decider = StockTransactionCostDecider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    return decider.commission_multiplier == 0.0003


def test_future_decider_exists() -> Bool:
    var decider = FutureTransactionCostDecider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.0001
    )
    return decider.commission_multiplier == 0.0001


def test_bond_decider_exists() -> Bool:
    var decider = BondTransactionCostDecider(
        commission_multiplier=0.0001
    )
    return decider.commission_multiplier == 0.0001


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: mod/rqmojo_mod_sys_transaction_cost/__init__.mojo")
    print("=" * 60)
    
    if test_create_transaction_cost_mod():
        print("PASS: test_create_transaction_cost_mod")
        passed += 1
    else:
        print("FAIL: test_create_transaction_cost_mod")
        failed += 1
    
    if test_transaction_cost_mod_name():
        print("PASS: test_transaction_cost_mod_name")
        passed += 1
    else:
        print("FAIL: test_transaction_cost_mod_name")
        failed += 1
    
    if test_stock_decider_exists():
        print("PASS: test_stock_decider_exists")
        passed += 1
    else:
        print("FAIL: test_stock_decider_exists")
        failed += 1
    
    if test_future_decider_exists():
        print("PASS: test_future_decider_exists")
        passed += 1
    else:
        print("FAIL: test_future_decider_exists")
        failed += 1
    
    if test_bond_decider_exists():
        print("PASS: test_bond_decider_exists")
        passed += 1
    else:
        print("FAIL: test_bond_decider_exists")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
