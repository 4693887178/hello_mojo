"""
Test for mod/rqmojo_mod_sys_simulation/mod.mojo
Group 09 - File 5
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.mod import SimulationMod, create_simulation_mod
from rqmojo.const import MATCHING_TYPE

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_simulation_mod_init() raises:
    print("Test: SimulationMod init")
    var _ = create_simulation_mod()
    print("  PASSED")


def test_simulation_mod_with_slippage() raises:
    print("Test: SimulationMod with slippage")
    var _ = create_simulation_mod(slippage=0.01)
    print("  PASSED")


def test_simulation_mod_get_matching_type() raises:
    print("Test: SimulationMod get_matching_type")
    var mod = create_simulation_mod()
    var _ = mod.get_matching_type()
    print("  PASSED")


def test_simulation_mod_get_slippage() raises:
    print("Test: SimulationMod get_slippage")
    var mod = create_simulation_mod(slippage=0.02)
    var _ = mod.get_slippage()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
