"""
Group 5 tests - mod/rqmojo_mod_sys_transaction_cost/mod.mojo
Tests for Mojo version of transaction cost mod.
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
from rqmojo.mod.rqmojo_mod_sys_transaction_cost import TransactionCostMod, create_transaction_cost_mod

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def test_create_transaction_cost_mod() raises:
    var mod = create_transaction_cost_mod()
    assert_equal(mod.name, "transaction_cost")


def test_transaction_cost_mod_name() raises:
    var mod = create_transaction_cost_mod()
    assert_equal(mod.name, "transaction_cost")


def test_stock_decider_exists() raises:
    var decider = StockTransactionCostDecider(
        commission_multiplier=0.0003,
        min_commission=5.0,
    )
    assert_equal(decider.commission_multiplier, 0.0003)
    assert_equal(decider.min_commission, 5.0)


def test_future_decider_exists() raises:
    var decider = FutureTransactionCostDecider(commission_multiplier=0.0001)
    assert_equal(decider.commission_multiplier, 0.0001)


def test_bond_decider_exists() raises:
    var decider = BondTransactionCostDecider(commission_multiplier=0.0001)
    assert_equal(decider.commission_multiplier, 0.0001)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
