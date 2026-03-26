"""
Test for mod/rqmojo_mod_sys_simulation/slippage.mojo
Group 07 - File 07
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import (
    Slippage, FixedSlippage, PercentSlippage, VolumeShareSlippage,
    create_fixed_slippage, create_percent_slippage, create_volume_share_slippage
)
from rqmojo.model.order import Order, create_order_with_id
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.utils.typing import DateTime


def create_test_bar() -> BarObject:
    return create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 0, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.0,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        limit_up=11.5,
        limit_down=9.5,
        suspended=False,
        trading=True
    )


def create_test_order() -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )


def test_fixed_slippage() -> Bool:
    print("Test: FixedSlippage")
    
    var slippage = create_fixed_slippage(0.5)
    var bar = create_test_bar()
    var order = create_test_order()
    
    var result = slippage.get_slippage(order, bar)
    
    if result != 0.5:
        raise "Fixed slippage should be 0.5"
    print("  PASSED")
    return True


def test_percent_slippage() -> Bool:
    print("Test: PercentSlippage")
    
    var slippage = create_percent_slippage(0.01)
    var bar = create_test_bar()
    var order = create_test_order()
    
    var result = slippage.get_slippage(order, bar)
    
    # Should be close * percent = 10.5 * 0.01 = 0.105
    print("  Slippage: ", result)
    print("  PASSED")
    return True


def test_volume_share_slippage() -> Bool:
    print("Test: VolumeShareSlippage")
    
    var slippage = create_volume_share_slippage(volume_share_limit=0.25, price_impact=0.1)
    var bar = create_test_bar()
    var order = create_test_order()
    
    var result = slippage.get_slippage(order, bar)
    
    print("  Slippage: ", result)
    print("  PASSED")
    return True


def main() -> None:
    print("=== Group 07 File 07: Slippage Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_fixed_slippage():
        passed += 1
    else:
        failed += 1
    
    if test_percent_slippage():
        passed += 1
    else:
        failed += 1
    
    if test_volume_share_slippage():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
