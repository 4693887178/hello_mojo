"""
Test for mod/rqmojo_mod_sys_accounts/__init__.mojo
Group 06 - File 03
"""

from rqmojo.mod.rqmojo_mod_sys_accounts import load_mod, get_cli_prefix


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_load_mod() raises:
    print("Test: load_mod function exists")
    var mod = load_mod()
    print("  load_mod returned successfully")
    assert_true(True, "test passed")


def test_cli_prefix() raises:
    print("Test: cli_prefix is correct")
    var prefix = get_cli_prefix()
    print("  cli_prefix: ", prefix)
    if prefix == "mod__sys_accounts__":
        assert_true(True, "test passed")
    else:
        print("  Expected: mod__sys_accounts__, got: ", prefix)
        assert_true(False, "test failed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
