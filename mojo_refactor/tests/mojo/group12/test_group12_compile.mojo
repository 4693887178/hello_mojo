"""
Simplified test for Group 12 core modules
"""

from rqmojo.mod.rqmojo_mod_sys_accounts.position_model import PositionModel, create_position_model
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.account import Account, create_stock_account


def main() raises:
    print("=" * 60)
    print("Testing Group 12 Core Modules")
    print("=" * 60)
    
    print("Testing position_model...")
    var pos = create_position_model("000001.XSHE")
    print("PositionModel created OK")
    
    print("Testing position...")
    var position = create_stock_position("000001.XSHE", 100, 10.0)
    print("Position created OK")
    
    print("Testing account...")
    var account = create_stock_account(100000.0)
    print("Account created OK")
    
    print("=" * 60)
    print("All core modules compiled successfully!")
    print("=" * 60)
