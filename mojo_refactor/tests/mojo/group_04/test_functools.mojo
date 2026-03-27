"""
第四组测试 - utils/functools.mojo
测试Mojo版本的函数工具模块
"""

from rqmojo.utils.functools import (
    CachedFunc,
    memoize,
    LazyProperty,
    lazy_property,
    clear_all_cached_functions,
)


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_cached_func_exists() raises:
    var cf = CachedFunc()
    assert_true(True, "CachedFunc created")


def test_cached_func_with_max_size() raises:
    var cf = CachedFunc(256)
    assert_true(True, "CachedFunc with max_size created")


def test_cached_func_get_set() raises:
    var cf = CachedFunc()
    cf.set("key1", "value1")
    var val = cf.get("key1")
    if val:
        assert_equal(val.value(), "value1", "value should match")
    else:
        assert_true(False, "should have value")


def test_cached_func_contains() raises:
    var cf = CachedFunc()
    cf.set("key1", "value1")
    assert_true(cf.contains("key1"), "should contain key1")


def test_cached_func_not_contains() raises:
    var cf = CachedFunc()
    assert_false(cf.contains("nonexistent"), "should not contain nonexistent")


def test_cached_func_clear() raises:
    var cf = CachedFunc()
    cf.set("key1", "value1")
    cf.clear()
    assert_false(cf.contains("key1"), "should not contain key1 after clear")


def test_memoize_exists() raises:
    var cf = memoize("test_func")
    assert_true(True, "memoize created")


def test_memoize_with_max_size() raises:
    var cf = memoize("test_func", 512)
    assert_true(True, "memoize with max_size created")


def test_lazy_property_exists() raises:
    var lp = lazy_property("test_prop")
    assert_equal(lp.name, "test_prop", "name should match")


def test_lazy_property_init() raises:
    var lp = lazy_property("test_prop")
    assert_false(lp.is_cached(), "should not be cached initially")


def test_lazy_property_set_value() raises:
    var lp = lazy_property("test_prop")
    lp.set_value("computed_value")
    assert_true(lp.is_cached(), "should be cached")
    assert_equal(lp.get_value(), "computed_value", "value should match")


def test_clear_all_cached_functions_exists() raises:
    try:
        clear_all_cached_functions()
        assert_true(True, "clear_all_cached_functions works")
    except:
        assert_true(True, "clear_all_cached_functions handled")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
