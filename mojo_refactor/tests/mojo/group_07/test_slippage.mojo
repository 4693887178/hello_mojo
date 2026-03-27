"""
Test for mod/rqmojo_mod_sys_simulation/slippage.mojo
Group 07 - File 07
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.slippage import (
    Slippage, FixedSlippage, PercentSlippage, VolumeShareSlippage,
    create_fixed_slippage, create_percent_slippage, create_volume_share_slippage
)
from rqmojo.model.order import Order, OrderStyle, MarketOrder, create_order_with_id
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import SIDE, POSITION_EFFECT
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

fn create_test_bar() -> BarObject:
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


fn create_test_order() -> Order:
    return create_order_with_id(
        order_id=1,
        order_book_id="000001.XSHE",
        side=SIDE.BUY,
        quantity=100,
        style=MarketOrder(),
        position_effect=POSITION_EFFECT.OPEN
    )

def test_fixed_slippage() raises:
    print("Test: FixedSlippage")
    
    var slippage = create_fixed_slippage(0.5)
    var bar = create_test_bar()
    var order = create_test_order()
    
    var result = slippage.get_slippage(order, bar)
    
    assert_equal(result, 0.5, "Fixed slippage should be 0.5")
    print("  PASSED")


def test_percent_slippage() raises:
    print("Test: PercentSlippage")
    
    var slippage = create_percent_slippage(0.01)
    var bar = create_test_bar()
    var order = create_test_order()
    
    var result = slippage.get_slippage(order, bar)
    
    print("  Slippage: ", result)
    print("  PASSED")


def test_volume_share_slippage() raises:
    print("Test: VolumeShareSlippage")
    
    var slippage = create_volume_share_slippage(volume_share_limit=0.25, price_impact=0.1)
    var bar = create_test_bar()
    var order = create_test_order()
    
    var result = slippage.get_slippage(order, bar)
    
    print("  Slippage: ", result)
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
