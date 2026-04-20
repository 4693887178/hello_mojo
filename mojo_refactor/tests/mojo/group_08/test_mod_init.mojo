"""
Test for mod/__init__.mojo
Group 08 - File 4
"""

from std.collections import Dict, List
from rqmojo.mod import ModInfo, ModHandler, create_mod_handler, get_system_mod_list, get_system_mod, register_mod, unregister_mod



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_mod_info() raises:
    print("Test: ModInfo")
    var info = ModInfo(name="test", version="1.0.0", enabled=True)
    if info.name != "test":
        raise "ModInfo name mismatch"
    print("  PASSED")


def test_mod_handler() raises:
    print("Test: ModHandler")
    var handler = create_mod_handler()
    if handler.get_mod_count() != 7:
        raise "ModHandler initial count should be 7 (default mods)"
    handler.add_mod("test_mod")
    if handler.get_mod_count() != 8:
        raise "ModHandler count should be 8 after add_mod"
    print("  PASSED")


def test_system_mod_list() raises:
    print("Test: System Mod List")
    var mod_list = get_system_mod_list()
    if len(mod_list) == 0:
        raise "System mod list should not be empty"
    print("  PASSED")


def test_get_system_mod() raises:
    print("Test: Get System Mod")
    var mod = get_system_mod("transaction_cost")
    if mod is None:
        raise "Should find transaction_cost mod"
    print("  PASSED")


def test_mod_handler_register_mod() raises:
    print("Test: ModHandler register_mod")
    var handler = create_mod_handler()
    var initial_count = handler.get_mod_count()
    var new_mod = ModInfo(name="custom_mod", version="1.0.0", enabled=True)
    handler.register_mod(new_mod)
    if handler.get_mod_count() != initial_count + 1:
        raise "ModHandler count should increase after register_mod"
    var found = handler.get_mod("custom_mod")
    if found is None:
        raise "Should find custom_mod after register"
    print("  PASSED")


def test_mod_handler_unregister_mod() raises:
    print("Test: ModHandler unregister_mod")
    var handler = create_mod_handler()
    handler.add_mod("test_to_remove")
    var result = handler.unregister_mod("test_to_remove")
    if not result:
        raise "Should successfully unregister test_to_remove"
    var found = handler.get_mod("test_to_remove")
    if found is not None:
        raise "Should not find test_to_remove after unregister"
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
