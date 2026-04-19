"""
Comprehensive tests for api.mojo
Tests ApiRegistry struct and module-level convenience functions.
Ported from Python rqalpha/api.py behavior.

Test categories:
  1. ApiRegistry struct lifecycle
  2. decorate_api_exc functionality
  3. register_api functionality
  4. export_as_api functionality
  5. Exception checking tracking
  6. Registry lookup and query
  7. Reset/clear functionality
  8. Copy semantics
  9. Edge cases
  10. Module-level convenience wrappers
"""

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite
from rqmojo.api import (
    ApiRegistry,
    decorate_api_exc,
    api_exc_patch,
    register_api,
    export_as_api,
    get_registered_api,
    is_exception_checked,
    get_all_apis,
    reset_api_registry,
)
from rqmojo.const import EXC_TYPE


def test_registry_initialization() raises:
    """Test 1: ApiRegistry starts with empty state."""
    var reg = ApiRegistry()
    assert_equal(len(reg.get_all_apis()), 0, "__all__ should be empty initially")


def test_decorate_api_exc_marks_checked() raises:
    """Test 2: decorate_api_exc adds func to exception_checked set."""
    var reg = ApiRegistry()
    assert_false(reg.is_exception_checked("my_func"), "func should not be checked initially")
    var result = reg.decorate_api_exc("my_func")
    assert_equal(result, "my_func", "should return original func name")
    assert_true(reg.is_exception_checked("my_func"), "func should be marked as checked")


def test_decorate_api_exc_idempotent() raises:
    """Test 3: Calling decorate_api_exc twice doesn't duplicate entries."""
    var reg = ApiRegistry()
    _ = reg.decorate_api_exc("func_a")
    _ = reg.decorate_api_exc("func_a")
    assert_true(reg.is_exception_checked("func_a"), "func should still be checked")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 0, "__all__ should not be populated by decorate_api_exc alone")


def test_register_api_basic() raises:
    """Test 4: register_api adds to both registry and __all__."""
    var reg = ApiRegistry()
    reg.register_api("order_shares", "order_shares_func")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 1, "should have 1 registered API")
    assert_equal(all_apis[0], "order_shares", "API name should match")
    var retrieved = reg.get_registered_api("order_shares")
    assert_true(retrieved != None, "should find registered API")
    assert_equal(retrieved.value(), "order_shares_func", "retrieved value should match")


def test_register_api_multiple() raises:
    """Test 5: Registering multiple APIs accumulates correctly."""
    var reg = ApiRegistry()
    reg.register_api("api_one", "func_one")
    reg.register_api("api_two", "func_two")
    reg.register_api("api_three", "func_three")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 3, "should have 3 registered APIs")


def test_export_as_api_with_name() raises:
    """Test 6: export_as_api with explicit name uses that name."""
    var reg = ApiRegistry()
    var result = reg.export_as_api("my_func_impl", "public_api_name")
    assert_equal(result, "my_func_impl", "should return original func identifier")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 1, "should have 1 API in __all__")
    assert_equal(all_apis[0], "public_api_name", "should use explicit name")
    assert_true(reg.is_exception_checked("my_func_impl"), "func should be exception-checked")


def test_export_as_api_without_name() raises:
    """Test 7: export_as_api without name uses func identifier as name."""
    var reg = ApiRegistry()
    var result = reg.export_as_api("auto_named_func")
    assert_equal(result, "auto_named_func", "should return func identifier")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 1, "should have 1 API")
    assert_equal(all_apis[0], "auto_named_func", "should use func as name when name is empty")


def test_export_as_api_with_empty_string_name() raises:
    """Test 8: export_as_api with empty string name falls back to func."""
    var reg = ApiRegistry()
    _ = reg.export_as_api("fallback_func", "")
    var all_apis = reg.get_all_apis()
    assert_equal(all_apis[0], "fallback_func", "empty string should trigger fallback")


def test_get_registered_api_found() raises:
    """Test 9: get_registered_api returns correct value for existing key."""
    var reg = ApiRegistry()
    reg.register_api("existing_api", "target_function")
    var result = reg.get_registered_api("existing_api")
    assert_true(result != None, "should find existing API")
    assert_equal(result.value(), "target_function", "value should match registered function")


def test_get_registered_api_not_found() raises:
    """Test 10: get_registered_api returns None for non-existing key."""
    var reg = ApiRegistry()
    var result = reg.get_registered_api("nonexistent")
    assert_true(result == None, "should return None for unregistered name")


def test_is_exception_checked_true() raises:
    """Test 11: is_exception_checked returns True after decoration."""
    var reg = ApiRegistry()
    _ = reg.decorate_api_exc("checked_func")
    assert_true(reg.is_exception_checked("checked_func"))


def test_is_exception_checked_false() raises:
    """Test 12: is_exception_checked returns False for undecorated function."""
    var reg = ApiRegistry()
    assert_false(reg.is_exception_checked("never_decorated"))


def test_get_all_apis_returns_copy() raises:
    """Test 13: get_all_apis returns a copy (modifying doesn't affect internal state)."""
    var reg = ApiRegistry()
    reg.register_api("api_1", "f1")
    reg.register_api("api_2", "f2")
    var apis = reg.get_all_apis()
    assert_equal(len(apis), 2)
    apis.append("injected")
    var apis_again = reg.get_all_apis()
    assert_equal(len(apis_again), 2, "modifying returned list should not affect registry")


def test_reset_clears_all_state() raises:
    """Test 14: reset() clears __all__, registry, and exception_checked."""
    var reg = ApiRegistry()
    reg.register_api("api_x", "func_x")
    _ = reg.decorate_api_exc("func_y")
    reg.reset()
    assert_equal(len(reg.get_all_apis()), 0, "__all__ should be empty after reset")
    var lookup = reg.get_registered_api("api_x")
    assert_true(lookup == None, "registry should be empty after reset")
    assert_false(reg.is_exception_checked("func_y"), "exception_checked should be empty after reset")


def test_copy_constructor() raises:
    """Test 15: Copy constructor creates independent copy."""
    var reg1 = ApiRegistry()
    reg1.register_api("shared_api", "shared_func")
    _ = reg1.decorate_api_exc("checked_in_original")
    var reg2 = ApiRegistry(copy=reg1)
    assert_equal(len(reg2.get_all_apis()), 1, "copy should have same number of APIs")
    assert_true(reg2.is_exception_checked("checked_in_original"), "copy should preserve checked status")
    reg1.register_api("only_in_1", "new_func")
    assert_equal(len(reg1.get_all_apis()), 2, "original should have 2 APIs")
    assert_equal(len(reg2.get_all_apis()), 1, "copy should still have 1 API")


def test_api_exc_patch_default_params() raises:
    """Test 16: api_exc_patch works with default parameters."""
    var reg = ApiRegistry()
    var result = reg.api_exc_patch("test_func")
    assert_equal(result, "test_func", "should return func name with defaults")


def test_api_exc_patch_with_invalid_arg() raises:
    """Test 17: api_exc_patch accepts raises_invalid_arg=True."""
    var reg = ApiRegistry()
    var result = reg.api_exc_patch("test_func", raises_invalid_arg=True)
    assert_equal(result, "test_func")


def test_api_exc_patch_with_exc_type() raises:
    """Test 18: api_exc_patch accepts custom exc_type."""
    var reg = ApiRegistry()
    var result = reg.api_exc_patch("test_func", exc_type=EXC_TYPE.USER_EXC)
    assert_equal(result, "test_func")


def test_register_api_overwrite() raises:
    """Test 19: Re-registering same name overwrites previous value."""
    var reg = ApiRegistry()
    reg.register_api("my_api", "original_func")
    reg.register_api("my_api", "updated_func")
    var result = reg.get_registered_api("my_api")
    assert_equal(result.value(), "updated_func", "should have updated value")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 2, "__all__ should accumulate both registrations")


def test_export_as_api_chain() raises:
    """Test 20: Multiple export_as_api calls accumulate correctly."""
    var reg = ApiRegistry()
    _ = reg.export_as_api("func_a")
    _ = reg.export_as_api("func_b", "alias_b")
    _ = reg.export_as_api("func_c", "alias_c")
    var all_apis = reg.get_all_apis()
    assert_equal(len(all_apis), 3)
    assert_equal(all_apis[0], "func_a")
    assert_equal(all_apis[1], "alias_b")
    assert_equal(all_apis[2], "alias_c")


def test_write_to_format() raises:
    """Test 21: ApiRegistry.write_to produces readable output."""
    var reg = ApiRegistry()
    reg.register_api("test_api", "test_func")
    var s = String()
    reg.write_to(s)
    assert_true(len(s) > 0, "write_to should produce non-empty output")


def test_module_level_decorate_api_exc() raises:
    """Test 22: Module-level decorate_api_exc works (ephemeral)."""
    var result = decorate_api_exc("module_func")
    assert_equal(result, "module_func", "should return func name")


def test_module_level_export_as_api() raises:
    """Test 23: Module-level export_as_api works (ephemeral)."""
    var result = export_as_api("module_func_export")
    assert_equal(result, "module_func_export", "should return func name")


def test_module_level_register_api_no_crash() raises:
    """Test 24: Module-level register_api doesn't crash."""
    register_api("test_module_api", "test_module_func")


def test_module_level_get_all_apis_empty() raises:
    """Test 25: Module-level get_all_apis returns empty list."""
    var apis = get_all_apis()
    assert_equal(len(apis), 0, "module-level should return empty list")


def test_module_level_is_exception_checked_false() raises:
    """Test 26: Module-level is_exception_checked returns False."""
    assert_false(is_exception_checked("any_func"))


def test_module_level_get_registered_api_none() raises:
    """Test 27: Module-level get_registered_api returns None."""
    var result = get_registered_api("anything")
    assert_true(result == None)


def test_module_level_reset_no_crash() raises:
    """Test 28: Module-level reset_api_registry doesn't crash."""
    reset_api_registry()


def test_large_number_of_registrations() raises:
    """Test 29: Registry handles many registrations efficiently."""
    var reg = ApiRegistry()
    for i in range(100):
        var name = "api_" + String(i)
        var func = "func_" + String(i)
        reg.register_api(name, func)
    assert_equal(len(reg.get_all_apis()), 100)
    var found = reg.get_registered_api("api_50")
    assert_true(found != None)
    assert_equal(found.value(), "func_50")


def test_special_characters_in_names() raises:
    """Test 30: Registry handles special characters in API names."""
    var reg = ApiRegistry()
    reg.register_api("order_shares-v2", "order_func_v2")
    var result = reg.get_registered_api("order_shares-v2")
    assert_true(result != None, "should handle hyphens in names")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
