"""
Test for mod/rqmojo_mod_sys_accounts/__init__.mojo
Group 06 - File 03
"""

from rqmojo.mod.rqmojo_mod_sys_accounts import load_mod, get_cli_prefix


def test_load_mod() raises -> Bool:
    print("Test: load_mod function exists")
    var mod = load_mod()
    print("  load_mod returned successfully")
    return True


def test_cli_prefix() -> Bool:
    print("Test: cli_prefix is correct")
    var prefix = get_cli_prefix()
    print("  cli_prefix: ", prefix)
    if prefix == "mod__sys_accounts__":
        return True
    else:
        print("  Expected: mod__sys_accounts__, got: ", prefix)
        return False


def main() -> None:
    print("=== Group 06 File 03: Accounts Mod Init Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    try:
        if test_load_mod():
            passed += 1
        else:
            failed += 1
    except:
        print("  test_load_mod raised exception")
        failed += 1
    
    if test_cli_prefix():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
