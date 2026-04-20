"""
Mojo Test for mod/rqmojo_mod_sys_transaction_cost/__init__.mojo
Tests the transaction cost module exports
TDD: Write tests first, then verify implementation
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
 from rqmojo.mod.rqmojo_mod_sys_transaction_cost import TransactionCostMod, create_transaction_cost_mod
from rqmojo.interface import TransactionCostArgs, TransactionCost
from rqmojo.const import SIDE, POSITION_EFFECT, INSTRUMENT_TYPE


def test_stock_transaction_cost_decider_creation():
:
    var decider = StockTransactionCostDecider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
        )
        print("StockTransactionCostDecider created successfully")
        assert True
    

def test_stock_transaction_cost_calc_buy():
    var decider = StockTransactionCostDecider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
        )
        print("Buy commission: " + String(cost.commission))
        print("Buy tax: " + String(cost.tax))
        
    assert cost.commission >= 5.0
        assert cost.tax > 0.0
        

def test_stock_transaction_cost_calc_sell():
    var decider = StockTransactionCostDecider(
        commission_multiplier=0.0003,
        min_commission=5.0,
        stamp_tax_rate=0.001,
        transfer_fee_rate=0.00002
        )
        print("Sell commission: " + String(cost.commission))
        print("Sell tax: " + String(cost.tax))
        
    assert cost.commission >= 0.0
        assert cost.tax > 0.0
        

def test_future_transaction_cost_decider_creation():
:
    var decider = FutureTransactionCostDecider(
        commission_multiplier=0.0001,
        close_commission_multiplier=0.0001
        )
            print("FutureTransactionCostDecider created successfully")
            assert True


def test_future_transaction_cost_calc():
            var decider = FutureTransactionCostDecider(
            commission_multiplier=0.0001,
            close_commission_multiplier=0.0001
        )
            print("Future commission: " + String(cost.commission))
            print("Future tax: " + String(cost.tax))
            
            assert cost.tax == 0.0
        

def test_bond_transaction_cost_decider_creation():
:
    var decider = BondTransactionCostDecider(commission_multiplier=0.0001)
            print("BondTransactionCostDecider created successfully")
            assert True


def test_bond_transaction_cost_calc():
            var decider = BondTransactionCostDecider(commission_multiplier=0.0001)
            print("Bond commission: " + String(decider.commission))
            print("Bond tax: " + String(cost.tax))
            
            assert cost.commission >= 0.0
            assert cost.tax == 0.0


def test_transaction_cost_mod_creation():
    var mod = create_transaction_cost_mod(stock_commission=0.0003, futures_commission=0.0001)
            print("TransactionCostMod created: " + mod.__str__())
            assert mod.name == "transaction_cost"
            assert mod.enabled == True


def test_transaction_cost_total():
    var cost = TransactionCost(commission=10.0, tax=5.0, other_fees=2.0)
            var total = cost.total()
            print("Total cost: " + String(total))
            assert total == 17.0


def test_transaction_cost_zero():
    var cost = TransactionCost.zero()
            print("Zero cost: " + String(cost.total()))
            assert cost.total() == 0.0


def main():
    print("=== Testing mod/rqmojo_mod_sys_transaction_cost ===")
    test_stock_transaction_cost_decider_creation()
    test_stock_transaction_cost_calc_buy()
    test_stock_transaction_cost_calc_sell()
    test_future_transaction_cost_decider_creation()
    test_future_transaction_cost_calc()
    test_bond_transaction_cost_decider_creation()
    test_bond_transaction_cost_calc()
            test_transaction_cost_mod_creation()
            test_transaction_cost_total()
            test_transaction_cost_zero()
            print("All transaction_cost tests passed!")
