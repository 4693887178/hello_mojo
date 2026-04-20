"""
RQAlpha Mojo - GlobalVars Comprehensive Test Suite
Tests for core/global_var.mojo (ported from rqalpha/core/global_var.py)

Coverage:
  1. Basic CRUD operations (create, read, update, delete)
  2. State serialization/deserialization (get_state/set_state)
  3. Edge cases (None, empty, type coercion, boundary conditions)
  4. Type system behavior across Python interop boundary
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.python import Python, PythonObject
from rqmojo.core.global_var import GlobalVars, create_global_vars


def test_01_creation_and_init() raises:
    var gv = create_global_vars()
    assert_equal(len(gv.keys()), 0, "New GlobalVars should be empty")


def test_02_contains_empty() raises:
    var gv = create_global_vars()
    assert_false(gv.contains("nonexistent"), "Empty GV should not contain any key")


def test_03_contains_after_set() raises:
    var gv = create_global_vars()
    gv.set("my_key", PythonObject("my_value"))
    assert_true(gv.contains("my_key"), "Key should exist after set")
    assert_false(gv.contains("nope"), "Non-existent key should not exist")


def test_04_remove_existing() raises:
    var gv = create_global_vars()
    gv.set("to_remove", PythonObject("val"))
    assert_true(gv.remove("to_remove"), "remove returns True for existing key")
    assert_false(gv.contains("to_remove"), "Key gone after remove")


def test_05_remove_nonexistent() raises:
    var gv = create_global_vars()
    assert_false(gv.remove("ghost"), "remove returns False for missing key")


def test_06_keys_returns_all() raises:
    var gv = create_global_vars()
    gv.set("a", PythonObject("1"))
    gv.set("b", PythonObject("2"))
    gv.set("c", PythonObject("3"))
    var keys = gv.keys()
    assert_equal(len(keys), 3, "Should have 3 keys")


def test_07_clear_empts_all() raises:
    var gv = create_global_vars()
    gv.set("x", PythonObject("1"))
    gv.set("y", PythonObject("2"))
    gv.clear()
    assert_equal(len(gv.keys()), 0, "clear should remove all keys")


def test_08_get_missing_returns_none() raises:
    var gv = create_global_vars()
    var result = gv.get("nonexistent")
    assert_true(result == Python.none(), "Missing key should return None")


def test_09_overwrite_value() raises:
    var gv = create_global_vars()
    gv.set("key", PythonObject("first"))
    gv.set("key", PythonObject("second"))
    var val = gv.get("key")
    assert_equal(String(py=val), "second", "Overwrite should replace value")


def test_10_int_value_roundtrip() raises:
    var gv = create_global_vars()
    gv.set("int_val", PythonObject(42))
    var val = gv.get("int_val")
    assert_equal(Int(py=val), 42, "Int roundtrip works")


def test_11_float_value_roundtrip() raises:
    var gv = create_global_vars()
    gv.set("float_val", PythonObject(3.14))
    var val = gv.get("float_val")
    var f = Float64(py=val)
    assert_true(f > 3.0 and f < 3.2, "Float roundtrip works")


def test_12_bool_values() raises:
    var gv = create_global_vars()
    gv.set("bool_t", PythonObject(True))
    gv.set("bool_f", PythonObject(False))
    assert_true(Bool(py=gv.get("bool_t")), "True persists")
    assert_false(Bool(py=gv.get("bool_f")), "False persists")


def test_13_none_value_storable() raises:
    var gv = create_global_vars()
    gv.set("none_key", PythonObject(None))
    var val = gv.get("none_key")
    assert_true(val == Python.none(), "None is storable and retrievable")


def test_14_multiple_types_coexist() raises:
    var gv = create_global_vars()
    gv.set("s", PythonObject("string"))
    gv.set("i", PythonObject(99))
    gv.set("f", PythonObject(2.5))
    gv.set("b", PythonObject(False))
    gv.set("n", PythonObject(None))
    assert_equal(len(gv.keys()), 5, "All 5 types coexist")


def test_15_many_keys() raises:
    var gv = create_global_vars()
    for i in range(100):
        var k = "key_" + String(i)
        gv.set(k, PythonObject(i))
    assert_equal(len(gv.keys()), 100, "Holds 100 keys")


def test_16_unicode_keys() raises:
    var gv = create_global_vars()
    gv.set("中文键", PythonObject("中文值"))
    assert_true(gv.contains("中文键"), "Unicode Chinese key works")


def test_17_empty_string_key() raises:
    var gv = create_global_vars()
    gv.set("", PythonObject("empty_key_value"))
    assert_true(gv.contains(""), "Empty string key works")
    var val = gv.get("")
    assert_equal(String(py=val), "empty_key_value", "Empty key retrieval works")


def test_18_rapid_set_clear_cycle() raises:
    var gv = create_global_vars()
    for i in range(30):
        gv.set("cycle", PythonObject(i))
        gv.clear()
    assert_equal(len(gv.keys()), 0, "Rapid set/clear leaves empty")


def test_19_state_serialization_basic() raises:
    var gv1 = create_global_vars()
    gv1.set("data", PythonObject("important"))
    gv1.set("count", PythonObject(100))
    var state = gv1.get_state()

    var gv2 = create_global_vars()
    gv2.set_state(state)

    var restored = gv2.get("data")
    assert_equal(String(py=restored), "important", "State roundtrip: string restored")
    var count_restored = gv2.get("count")
    assert_equal(Int(py=count_restored), 100, "State roundtrip: int restored")


def test_20_state_of_empty_globals() raises:
    var gv = create_global_vars()
    var state = gv.get_state()

    var gv2 = create_global_vars()
    gv2.set_state(state)
    assert_equal(len(gv2.keys()), 0, "Empty state restores to empty")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
