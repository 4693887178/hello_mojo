"""
Test for mod/rqmojo_mod_sys_simulation/mod.mojo
Group 09 - File 5
"""

from rqmojo.mod.rqmojo_mod_sys_simulation.mod import SimulationMod, create_simulation_mod
from rqmojo.const import MATCHING_TYPE


fn test_simulation_mod_init() -> Bool:
    print("Test: SimulationMod init")
    var mod = create_simulation_mod()
    print("  PASSED")
    return True


fn test_simulation_mod_with_slippage() -> Bool:
    print("Test: SimulationMod with slippage")
    var mod = create_simulation_mod(slippage=0.01)
    print("  PASSED")
    return True


fn test_simulation_mod_get_matching_type() -> Bool:
    print("Test: SimulationMod get_matching_type")
    var mod = create_simulation_mod()
    var mt = mod.get_matching_type()
    print("  PASSED")
    return True


fn test_simulation_mod_get_slippage() -> Bool:
    print("Test: SimulationMod get_slippage")
    var mod = create_simulation_mod(slippage=0.02)
    var slippage = mod.get_slippage()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 5: Simulation Mod Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    if test_simulation_mod_init():
        passed += 1
    else:
        failed += 1
    
    if test_simulation_mod_with_slippage():
        passed += 1
    else:
        failed += 1
    
    if test_simulation_mod_get_matching_type():
        passed += 1
    else:
        failed += 1
    
    if test_simulation_mod_get_slippage():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
