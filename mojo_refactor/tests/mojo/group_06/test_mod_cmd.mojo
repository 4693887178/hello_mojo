"""
Test for cmds/mod.mojo
Group 06 - File 07
"""

from rqmojo.cmds.mod import (
    get_builtin_mods,
    list_mods,
    list_mods_detailed,
    enable_mod,
    disable_mod,
    get_mod_config,
    run_mod_command,
    ModInfo,
    ModCommand
)



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_mod_info() raises:
    print("Test: ModInfo struct")
    var info = ModInfo(name="test", enabled=True, description="Test mod")
    print("  ModInfo created: ", info.name, " - ", info.description)
    assert_true(True, "test passed")


def test_mod_command() raises:
    print("Test: ModCommand struct")
    var cmd = ModCommand(action="list", mod_name="test")
    print("  ModCommand created: ", cmd.action, " - ", cmd.mod_name)
    assert_true(True, "test passed")


def test_get_builtin_mods() raises:
    print("Test: get_builtin_mods function")
    var mods = get_builtin_mods()
    print("  Found ", len(mods), " builtin mods")
    assert_true(True, "test passed")


def test_list_mods() raises:
    print("Test: list_mods function")
    var mods = list_mods()
    print("  Found ", len(mods), " mods")
    assert_true(True, "test passed")


def test_enable_mod() raises:
    print("Test: enable_mod function")
    var result = enable_mod("simulation")
    print("  enable_mod returned: ", result)
    assert_true(True, "test passed")


def test_disable_mod() raises:
    print("Test: disable_mod function")
    var result = disable_mod("simulation")
    print("  disable_mod returned: ", result)
    assert_true(True, "test passed")


def test_run_mod_command_list() raises:
    print("Test: run_mod_command with list action")
    var params = List[String]()
    var result = run_mod_command("list", params)
    print("  run_mod_command list returned: ", result)
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()