"""
Mojo Test for mod/rqmojo_mod_sys_simulation/__init__.mojo
Tests the simulation module exports
TDD: Write tests first, then verify implementation
"""

from rqmojo.mod.rqmojo_mod_sys_simulation import create_simulation_mod
from rqmojo.const import MATCHING_TYPE


def test_simulation_mod_import():
    print("Testing simulation module imports")
    assert True


def test_matching_type_constants():
    var current_bar = MATCHING_TYPE.CURRENT_BAR_CLOSE
    print("MATCHING_TYPE.CURRENT_BAR_CLOSE: " + current_bar.name())
    assert current_bar.name() == "CURRENT_BAR_CLOSE"
    
    var vwap = MATCHING_TYPE.VWAP
    print("MATCHING_TYPE.VWAP: " + vwap.name())
    assert vwap.name() == "VWAP"


def test_matching_type_from_name():
    var mt = MATCHING_TYPE.from_name("CURRENT_BAR_CLOSE")
    if var value = mt.value():
        print("MATCHING_TYPE from name: " + value.name())
        assert value.name() == "CURRENT_BAR_CLOSE"
    else:
        assert False


def main():
    print("=== Testing mod/rqmojo_mod_sys_simulation ===")
    test_simulation_mod_import()
    test_matching_type_constants()
    test_matching_type_from_name()
    print("All simulation tests passed!")
