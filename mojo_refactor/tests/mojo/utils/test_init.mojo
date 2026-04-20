"""
Comprehensive tests for utils/__init__.mojo - RqAttrDict

Tests RqAttrDict which is the Mojo refactoring of Python's rqalpha.utils.RqAttrDict.
Python version uses a single __dict__ for all storage; Mojo uses _children + _values
with Variant types for type-safe value storage.

Covers:
  - Construction (default, from Int/Float64/String/Bool/None)
  - getitem/setitem chain access pattern
  - Nested child creation and traversal
  - Iteration (__iter__, keys, child_keys, value_keys)
  - Copy semantics (independence)
  - Update with deep merge, type replacement (child<->value)
  - convert_to_dict / items (flattened output)
  - write_to (Writable trait)
  - contains, size, is_empty, __bool__
  - NullValue equality
"""

from rqmojo.utils import RqAttrDict, NullValue
from std.testing import assert_equal, assert_true, assert_false, TestSuite


# ============ Construction Tests ============

def test_default_init() raises:
    var d = RqAttrDict()
    assert_true(d.is_empty(), "Default init should be empty")
    assert_false(d.has_value(), "Should not have __value__")
    assert_false(d.has_children(), "Should not have children")

def test_int_value() raises:
    var d = RqAttrDict(42)
    assert_true(d.has_value(), "Int should set __value__")
    assert_equal(d.to[Int](0), 42)

def test_string_value() raises:
    var d = RqAttrDict("hello")
    assert_equal(d.to[String](""), "hello")

def test_float_value() raises:
    var d = RqAttrDict(3.14)
    var f = d.to[Float64](0.0)
    assert_true(f > 3.1 and f < 3.2)

def test_bool_value_true() raises:
    var d = RqAttrDict(True)
    assert_true(d.to[Bool](False))

def test_bool_value_false() raises:
    var d = RqAttrDict(False)
    assert_false(d.to[Bool](True))

def test_none_value() raises:
    var d = RqAttrDict(None)
    assert_true(d.has_value(), "None should create __value__ key")


# ============ getitem/setitem Tests ============

def test_setitem_getitem_value() raises:
    var d = RqAttrDict()
    d["name"] = RqAttrDict("test")
    assert_true(d.contains("name"))
    var v = d["name"]
    assert_equal(v.to[String](""), "test")

def test_nested_children_chain() raises:
    var d = RqAttrDict()
    d["base"] = RqAttrDict()
    d["base"]["start_date"] = RqAttrDict("20150101")
    assert_true(d.has_children())
    var base = d["base"]
    assert_true(base.contains("start_date"))
    assert_equal(base["start_date"].to[String](""), "20150101")

def test_getitem_missing_key_returns_empty() raises:
    var d = RqAttrDict()
    var result = d["nonexistent"]
    assert_true(result.is_empty())

def test_set_same_key_overwrites() raises:
    var d = RqAttrDict()
    d["key"] = RqAttrDict("first")
    d["key"] = RqAttrDict("second")
    assert_equal(d["key"].to[String](""), "second")


# ============ Iteration & Keys Tests ============

def test_keys_mixed() raises:
    var d = RqAttrDict()
    d["a"] = RqAttrDict(1)
    d["b"] = RqAttrDict("two")
    var keys = d.keys()
    assert_equal(len(keys), 2)

def test_iter_count() raises:
    var d = RqAttrDict()
    d["k1"] = RqAttrDict(1)
    d["k2"] = RqAttrDict(2)
    var count = 0
    for _ in d:
        count += 1
    assert_equal(count, 2)

def test_child_keys_vs_value_keys() raises:
    var d = RqAttrDict()
    d["val"] = RqAttrDict("value_only")
    d["child"] = RqAttrDict()
    d["child"]["nested"] = RqAttrDict(1)
    var vk = d.value_keys()
    var ck = d.child_keys()
    assert_equal(len(vk), 1)
    assert_equal(len(ck), 1)

def test_contains_checks_both() raises:
    var d = RqAttrDict()
    d["a"] = RqAttrDict(1)
    d["b"] = RqAttrDict()
    d["b"]["c"] = RqAttrDict(2)
    assert_true(d.contains("a"))
    assert_true(d.contains("b"))
    assert_false(d.contains("nonexistent"))


# ============ Copy Tests ============

def test_copy_independence() raises:
    var d1 = RqAttrDict()
    d1["x"] = RqAttrDict(42)
    var d2 = d1.copy()
    d1["y"] = RqAttrDict(2)
    assert_false(d2.contains("y"))

def test_copy_preserves_data() raises:
    var d1 = RqAttrDict()
    d1["x"] = RqAttrDict(42)
    var d2 = d1.copy()
    assert_true(d2.contains("x"))


# ============ Update Tests ============

def test_update_basic_merge() raises:
    var d1 = RqAttrDict()
    d1["a"] = RqAttrDict(1)
    var d2 = RqAttrDict()
    d2["b"] = RqAttrDict(2)
    d1.update(d2)
    assert_true(d1.contains("a"))
    assert_true(d1.contains("b"))

def test_update_overwrite_value() raises:
    var d1 = RqAttrDict()
    d1["key"] = RqAttrDict("old")
    var d2 = RqAttrDict()
    d2["key"] = RqAttrDict("new")
    d1.update(d2)
    assert_equal(d1["key"].to[String](""), "new")

def test_update_nested_merge() raises:
    var d1 = RqAttrDict()
    d1["base"] = RqAttrDict()
    d1["base"]["start_date"] = RqAttrDict("20150101")
    var d2 = RqAttrDict()
    d2["base"] = RqAttrDict()
    d2["base"]["end_date"] = RqAttrDict("20201231")
    d2["extra"] = RqAttrDict("value")
    d1.update(d2)
    assert_true(d1.contains("base"))
    assert_true(d1.contains("extra"))
    var base = d1["base"]
    assert_true(base.contains("start_date"))
    assert_true(base.contains("end_date"))

def test_update_deep_3_level_merge() raises:
    var d1 = RqAttrDict()
    d1["a"] = RqAttrDict()
    d1["a"]["b"] = RqAttrDict()
    d1["a"]["b"]["c1"] = RqAttrDict("original")
    var d2 = RqAttrDict()
    d2["a"] = RqAttrDict()
    d2["a"]["b"] = RqAttrDict()
    d2["a"]["b"]["c2"] = RqAttrDict("added")
    d2["a"]["b"]["c1"] = RqAttrDict("modified")
    d1.update(d2)
    var ab = d1["a"]["b"]
    assert_equal(ab["c1"].to[String](""), "modified")
    assert_equal(ab["c2"].to[String](""), "added")

def test_update_replace_child_with_value() raises:
    var d1 = RqAttrDict()
    d1["node"] = RqAttrDict()
    d1["node"]["inner"] = RqAttrDict(42)
    var d2 = RqAttrDict()
    d2["node"] = RqAttrDict("replaced")
    d1.update(d2)
    assert_equal(d1["node"].to[String](""), "replaced")

def test_update_replace_value_with_child() raises:
    var d1 = RqAttrDict()
    d1["node"] = RqAttrDict("scalar")
    var d2 = RqAttrDict()
    d2["node"] = RqAttrDict()
    d2["node"]["new_key"] = RqAttrDict("nested")
    d1.update(d2)
    var node = d1["node"]
    assert_false(node.is_empty())
    assert_true(node.contains("new_key"))
    assert_equal(node["new_key"].to[String](""), "nested")


# ============ convert_to_dict / items Tests ============

def test_convert_to_dict_basic() raises:
    var d = RqAttrDict()
    d["name"] = RqAttrDict("test")
    d["count"] = RqAttrDict(42)
    var result = d.convert_to_dict()
    assert_true(len(result) >= 1)

def test_items_method() raises:
    var d = RqAttrDict()
    d["str_key"] = RqAttrDict("hello")
    d["int_key"] = RqAttrDict(123)
    d["bool_key"] = RqAttrDict(True)
    var items = d.items()
    assert_equal(len(items), 3)

def test_items_includes_nested_keys() raises:
    var d = RqAttrDict()
    d["base"] = RqAttrDict()
    d["base"]["start_date"] = RqAttrDict("20150101")
    var items = d.items()
    assert_true(len(items) >= 1)

def test_convert_to_dict_nested_structure() raises:
    var d = RqAttrDict()
    d["name"] = RqAttrDict("test")
    d["config"] = RqAttrDict()
    d["config"]["debug"] = RqAttrDict(True)
    d["config"]["port"] = RqAttrDict(8080)
    var result = d.convert_to_dict()
    assert_true("name" in result)
    assert_true("config" in result)
    assert_true("config.debug" in result)
    assert_true("config.port" in result)

def test_items_flattened_nested() raises:
    var d = RqAttrDict()
    d["level1"] = RqAttrDict()
    d["level1"]["level2"] = RqAttrDict("deep_value")
    var items = d.items()
    assert_true("level1.level2" in items)


# ============ write_to (Writable) Tests ============

def test_write_to_empty() raises:
    var d = RqAttrDict()
    var s = String.write(d)
    assert_true(s.find("{") >= 0)
    assert_true(s.find("}") >= 0)

def test_write_to_with_values() raises:
    var d = RqAttrDict()
    d["name"] = RqAttrDict("test")
    d["count"] = RqAttrDict(42)
    var s = String.write(d)
    assert_true(s.find("name") >= 0)
    assert_true(s.find("test") >= 0)
    assert_true(s.find("count") >= 0)

def test_write_to_nested() raises:
    var d = RqAttrDict()
    d["base"] = RqAttrDict()
    d["base"]["start_date"] = RqAttrDict("20150101")
    var s = String.write(d)
    assert_true(s.find("base") >= 0)


# ============ Size / Bool Semantics ============

def test_size_and_bool() raises:
    var d1 = RqAttrDict()
    assert_equal(d1.size(), 0)
    assert_false(d1.__bool__())
    var d2 = RqAttrDict(42)
    assert_true(d2.__bool__())

def test_size_counts_top_level_only() raises:
    var d = RqAttrDict()
    d["v1"] = RqAttrDict(1)
    d["c1"] = RqAttrDict()
    d["c1"]["n1"] = RqAttrDict(2)
    assert_equal(d.size(), 2)


# ============ Type Conversion in items() ============

def test_float_in_items() raises:
    var d = RqAttrDict()
    d["pi"] = RqAttrDict(3.14159)
    var items = d.items()
    assert_true("pi" in items)

def test_bool_values_in_items() raises:
    var d = RqAttrDict()
    d["flag_true"] = RqAttrDict(True)
    d["flag_false"] = RqAttrDict(False)
    var items = d.items()
    assert_equal(len(items), 2)


# ============ NullValue Tests ============

def test_null_value_equality() raises:
    var n1 = NullValue()
    var n2 = NullValue()
    assert_true(n1 == n2)

def test_null_value_writable() raises:
    var n = NullValue()
    var s = String.write(n)
    assert_true(s.find("None") >= 0)


# ============ Empty Dict Edge Cases ============

def test_empty_iteration_yields_nothing() raises:
    var d = RqAttrDict()
    var count = 0
    for _ in d:
        count += 1
    assert_equal(count, 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
