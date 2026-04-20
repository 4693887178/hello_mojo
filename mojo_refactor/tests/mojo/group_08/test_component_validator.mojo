"""
Test for mod/rqmojo_mod_sys_accounts/component_validator.mojo
Group 08 - File 1
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_accounts.component_validator import ComponentValidator, create_component_validator
from rqmojo.model.order import Order, MarketOrder, create_order_with_id
from rqmojo.const import SIDE, POSITION_EFFECT



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_component_validator_init() raises:
    print("Test: ComponentValidator init")
    var validator = create_component_validator()
    print("  PASSED")
    assert_true(True, "test passed")


def test_component_validator_validate() raises:
    print("Test: ComponentValidator validate")
    var validator = create_component_validator()
    var order = create_order_with_id(1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var result = validator.validate_order(order)
    if not result:
        raise "ComponentValidator should validate order"
    print("  PASSED")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()