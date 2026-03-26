"""
Test for mod/rqmojo_mod_sys_analyser/mod.mojo
Group 08 - File 9
"""

from std.collections import Dict, List
from rqmojo.mod.rqmojo_mod_sys_analyser.mod import AnalyserMod, create_analyser_mod
from rqmojo.interface import Mod
from python import PythonObject
from rqmojo.const import EXIT_CODE


fn test_analyser_mod_struct() -> Bool:
    print("Test: AnalyserMod struct exists")
    var mod = create_analyser_mod()
    print("  PASSED")
    return True


fn test_analyser_mod_methods() -> Bool:
    print("Test: AnalyserMod methods exist")
    var mod = create_analyser_mod()
    mod.start_up(PythonObject(None), PythonObject(None))
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, PythonObject(None))
    print("  PASSED")
    return True


fn test_analyser_mod_name() -> Bool:
    print("Test: AnalyserMod name")
    var mod = create_analyser_mod()
    if mod.name != "analyser":
        return False
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 08 File 9: Analyser Mod Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_analyser_mod_struct():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_analyser_mod_methods():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_analyser_mod_name():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
