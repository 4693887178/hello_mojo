"""
第五组测试 - mod/rqmojo_mod_sys_transaction_cost/__init__.mojo
测试Mojo版本的事务成本模块
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
from rqmojo.mod.rqmojo_mod_sys_transaction_cost import TransactionCostMod, create_transaction_cost_mod



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_create_transaction_cost_mod() raises:
    var mod = create_transaction_cost_mod()
    assert_equal(mod.name, "transaction_cost", "values should match")


def test_transaction_cost_mod_name() raises:
    var mod = create_transaction_cost_mod()
    assert_equal(mod.name, "transaction_cost", "values should match")


def test_stock_decider_exists() raises:
    var decider = StockTransactionCostDecider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
    )
    assert_equal(decider.commission_multiplier, 0.0003, "values should match")


def test_future_decider_exists() raises:
    var decider = FutureTransactionCostDecider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.0001
    )
    assert_equal(decider.commission_multiplier, 0.0001, "values should match")


def test_bond_decider_exists() raises:
    var decider = BondTransactionCostDecider(
        commission_multiplier=0.0001
    )
    assert_equal(decider.commission_multiplier, 0.0001, "values should match")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()