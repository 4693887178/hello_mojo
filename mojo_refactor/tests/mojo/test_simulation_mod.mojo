"""
Unit tests for SimulationMod
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.mod import SimulationMod
from rqmojo.const import MATCHING_TYPE, RUN_TYPE


def test_parse_matching_type():
    # Test with None input (should auto-select based on frequency)
    var result1 = SimulationMod.parse_matching_type(None, "1d")
    print("Test 1 passed: ", result1.value)
    
    var result2 = SimulationMod.parse_matching_type(None, "1m")
    print("Test 2 passed: ", result2.value)
    
    var result3 = SimulationMod.parse_matching_type(None, "tick")
    print("Test 3 passed: ", result3.value)

    # Test with valid matching type strings
    var result4 = SimulationMod.parse_matching_type("current_bar", "1d")
    print("Test 4 passed: ", result4.value)
    
    var result5 = SimulationMod.parse_matching_type("VWAP", "1d")
    print("Test 5 passed: ", result5.value)
    
    var result6 = SimulationMod.parse_matching_type("next_bar", "1d")
    print("Test 6 passed: ", result6.value)


def test_init():
    var mod = SimulationMod()
    print("Test init passed: mod created")


def main():
    test_parse_matching_type()
    test_init()
    print("All tests passed!")

main()
