"""
Test compilation of __init__.mojo
"""

from rqmojo.mod.rqmojo_mod_sys_transaction_cost import StockTransactionCostDecider, FutureTransactionCostDecider, BondTransactionCostDecider
from rqmojo.mod.rqmojo_mod_sys_transaction_cost import TransactionCostMod, create_transaction_cost_mod

def main():
    print("__init__.mojo compiles OK")
