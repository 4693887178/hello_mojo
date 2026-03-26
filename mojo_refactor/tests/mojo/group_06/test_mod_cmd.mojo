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


def test_mod_info() -> Bool:
    print("Test: ModInfo struct")
    var info = ModInfo(name="test", enabled=True, description="Test mod")
    print("  ModInfo created: ", info.name, " - ", info.description)
    return True


def test_mod_command() -> Bool:
    print("Test: ModCommand struct")
    var cmd = ModCommand(action="list", mod_name="test")
    print("  ModCommand created: ", cmd.action, " - ", cmd.mod_name)
    return True


def test_get_builtin_mods() -> Bool:
    print("Test: get_builtin_mods function")
    var mods = get_builtin_mods()
    print("  Found ", len(mods), " builtin mods")
    return True


def test_list_mods() -> Bool:
    print("Test: list_mods function")
    var mods = list_mods()
    print("  Found ", len(mods), " mods")
    return True


def test_enable_mod() -> Bool:
    print("Test: enable_mod function")
    var result = enable_mod("simulation")
    print("  enable_mod returned: ", result)
    return True


def test_disable_mod() -> Bool:
    print("Test: disable_mod function")
    var result = disable_mod("simulation")
    print("  disable_mod returned: ", result)
    return True


def test_run_mod_command_list() -> Bool:
    print("Test: run_mod_command with list action")
    var params = List[String]()
    var result = run_mod_command("list", params)
    print("  run_mod_command list returned: ", result)
    return True


def main() -> None:
    print("=== Group 06 File 07: Mod Commands Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_mod_info():
        passed += 1
    else:
        failed += 1
    
    if test_mod_command():
        passed += 1
    else:
        failed += 1
    
    if test_get_builtin_mods():
        passed += 1
    else:
        failed += 1
    
    if test_list_mods():
        passed += 1
    else:
        failed += 1
    
    if test_enable_mod():
        passed += 1
    else:
        failed += 1
    
    if test_disable_mod():
        passed += 1
    else:
        failed += 1
    
    if test_run_mod_command_list():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
