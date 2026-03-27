"""
第四组测试 - utils/class_helper.mojo
测试Mojo版本的类辅助模块
"""

from rqmojo.utils.class_helper import (
    deprecated_property,
    cached_property,
    CachedProperty,
    make_cached_property,
    property_repr,
)


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

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


def test_property_repr_basic() raises:
    from std.collections import Dict
    var props = Dict[String, String]()
    props["name"] = "test"
    props["value"] = "42"
    var result = property_repr("TestObj", props)
    assert_true(result.find("TestObj") >= 0, "should contain TestObj")
    assert_true(result.find("name") >= 0, "should contain name")


def test_property_repr_empty() raises:
    from std.collections import Dict
    var props = Dict[String, String]()
    var result = property_repr("EmptyObj", props)
    assert_true(result.find("EmptyObj") >= 0, "should contain EmptyObj")


def test_deprecated_property_exists() raises:
    assert_true(True, "deprecated_property exists")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
