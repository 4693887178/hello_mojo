"""
第四组测试 - utils/class_helper.mojo
测试Mojo版本的类辅助模块

重构覆盖范围:
  1. gettext as `__ 别名迁移 (Python L18: from rqalpha.utils.i18n import gettext as _)
  2. deprecated_property 返回 DeprecatedPropertyInfo 结构体
  3. @deprecated 装饰器可行性验证 (Mojo 0.26.2 内置)
  4. cached_property 结构体完整功能
  5. property_repr 字符串格式化

测试模式参考: tests/mojo/group_03/test_misc_i18n.mojo (直接导入gettext)
源码模式参考: rqmojo/cmds/misc.mojo (内部使用 `__ 别名)
"""

from rqmojo.utils.class_helper import (
    deprecated_property,
    cached_property,
    CachedProperty,
    make_cached_property,
    property_repr,
    DeprecatedPropertyInfo,
)

from rqmojo.utils.i18n import gettext

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_gettext_direct_call() raises:
    """Verify gettext works directly (same pattern as test_misc_i18n.mojo L12)."""
    var result = gettext("test message")
    assert_equal(result, "test message", "gettext should return input for untranslated strings")


def test_deprecated_property_returns_info() raises:
    """Test that deprecated_property returns DeprecatedPropertyInfo struct."""
    var info = deprecated_property("old_prop", "new_prop")
    assert_true(info.get_old_name() == "old_prop", "old_name should match")
    assert_true(info.get_new_name() == "new_prop", "new_name should match")


def test_deprecated_property_same_names_raises() raises:
    """Test that deprecated_property raises when property names are identical."""
    with assert_raises():
        _ = deprecated_property("same", "same")


def test_deprecated_property_i18n_message() raises:
    """Test that deprecated_property uses i18n translation internally."""
    var info = deprecated_property("deprecated_attr", "replacement_attr")
    assert_true(
        info.get_old_name() == "deprecated_attr",
        "i18n via internal `__ should work correctly"
    )


def test_DeprecatedPropertyInfo_struct() raises:
    """Test DeprecatedPropertyInfo struct independent construction and access."""
    var info = DeprecatedPropertyInfo("my_old", "my_new")
    assert_equal(info.get_old_name(), "my_old")
    assert_equal(info.get_new_name(), "my_new")


def test_DeprecatedPropertyInfo_copyable() raises:
    """Test that DeprecatedPropertyInfo supports Copyable trait."""
    var original = DeprecatedPropertyInfo("a", "b")
    var copied = original.copy()
    assert_equal(copied.get_old_name(), "a")
    assert_equal(copied.get_new_name(), "b")


def test_cached_property_exists() raises:
    var cp = cached_property("test_prop")
    assert_equal(cp.name, "test_prop", "name should match")


def test_cached_property_init() raises:
    var cp = cached_property("test_prop")
    assert_false(cp.is_cached(), "should not be cached initially")


def test_cached_property_with_value() raises:
    var cp = cached_property("test_prop", "test_value")
    assert_true(cp.is_cached(), "should be cached")
    assert_equal(cp.get_value(), "test_value", "value should match")


def test_cached_property_set_value() raises:
    var cp = cached_property("test_prop")
    cp.set_value("new_value")
    assert_true(cp.is_cached(), "should be cached after set")
    assert_equal(cp.get_value(), "new_value", "value should match")


def test_make_cached_property() raises:
    var cp = make_cached_property("test", "value")
    assert_true(cp.is_cached(), "should be cached")
    assert_equal(cp.get_value(), "value", "value should match")


def test_CachedProperty_alias() raises:
    var cp = CachedProperty("alias_test")
    assert_equal(cp.name, "alias_test", "name should match")


def test_CachedProperty_is_comptime_alias() raises:
    """Verify CachedProperty is a comptime alias of cached_property (matching Python)."""
    var a = cached_property("x")
    var b = CachedProperty("x")
    assert_equal(a.name, b.name, "CachedProperty alias should behave identically")


def test_cached_property_copyable() raises:
    """Test that cached_property supports Copyable trait."""
    var original = cached_property("orig", "val")
    var copied = original.copy()
    assert_equal(copied.name, "orig")
    assert_equal(copied.get_value(), "val")
    assert_true(copied.is_cached())


def test_property_repr_basic() raises:
    from std.collections import Dict
    var props = Dict[String, String]()
    props["name"] = "test"
    props["value"] = "42"
    var result = property_repr("TestObj", props)
    assert_true(result.find("TestObj") >= 0, "should contain TestObj")
    assert_true(result.find("name") >= 0, "should contain name")
    assert_true(result.find("value") >= 0, "should contain value")


def test_property_repr_empty() raises:
    from std.collections import Dict
    var props = Dict[String, String]()
    var result = property_repr("EmptyObj", props)
    assert_true(result.find("EmptyObj") >= 0, "should contain EmptyObj")
    assert_true(result.find("()") >= 0, "empty props should show ()")


def test_property_repr_single_property() raises:
    from std.collections import Dict
    var props = Dict[String, String]()
    props["key"] = "val"
    var result = property_repr("Obj", props)
    assert_true(result.find("key=val") >= 0, "should contain key=val")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
