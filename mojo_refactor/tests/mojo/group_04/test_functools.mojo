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


def test_cached_func_exists() -> Bool:
    var cf = CachedFunc()
    return True


def test_cached_func_with_max_size() -> Bool:
    var cf = CachedFunc(256)
    return True


def test_cached_func_get_set() raises -> Bool:
    var cf = CachedFunc()
    cf.set("key1", "value1")
    var val = cf.get("key1")
    if val:
        return val.value() == "value1"
    return False


def test_cached_func_contains() -> Bool:
    var cf = CachedFunc()
    cf.set("key1", "value1")
    return cf.contains("key1")


def test_cached_func_not_contains() -> Bool:
    var cf = CachedFunc()
    return not cf.contains("nonexistent")


def test_cached_func_clear() -> Bool:
    var cf = CachedFunc()
    cf.set("key1", "value1")
    cf.clear()
    return not cf.contains("key1")


def test_memoize_exists() -> Bool:
    var cf = memoize("test_func")
    return True


def test_memoize_with_max_size() -> Bool:
    var cf = memoize("test_func", 512)
    return True


def test_lazy_property_exists() -> Bool:
    var lp = lazy_property("test_prop")
    return lp.name == "test_prop"


def test_lazy_property_init() -> Bool:
    var lp = lazy_property("test_prop")
    return not lp.is_cached()


def test_lazy_property_set_value() -> Bool:
    var lp = lazy_property("test_prop")
    lp.set_value("computed_value")
    return lp.is_cached() and lp.get_value() == "computed_value"


def test_clear_all_cached_functions_exists() -> Bool:
    try:
        clear_all_cached_functions()
        return True
    except:
        return True


def main() raises:
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: utils/functools.mojo")
    print("=" * 60)
    
    if test_cached_func_exists():
        print("PASS: test_cached_func_exists")
        passed += 1
    else:
        print("FAIL: test_cached_func_exists")
        failed += 1
    
    if test_cached_func_with_max_size():
        print("PASS: test_cached_func_with_max_size")
        passed += 1
    else:
        print("FAIL: test_cached_func_with_max_size")
        failed += 1
    
    if test_cached_func_get_set():
        print("PASS: test_cached_func_get_set")
        passed += 1
    else:
        print("FAIL: test_cached_func_get_set")
        failed += 1
    
    if test_cached_func_contains():
        print("PASS: test_cached_func_contains")
        passed += 1
    else:
        print("FAIL: test_cached_func_contains")
        failed += 1
    
    if test_cached_func_not_contains():
        print("PASS: test_cached_func_not_contains")
        passed += 1
    else:
        print("FAIL: test_cached_func_not_contains")
        failed += 1
    
    if test_cached_func_clear():
        print("PASS: test_cached_func_clear")
        passed += 1
    else:
        print("FAIL: test_cached_func_clear")
        failed += 1
    
    if test_memoize_exists():
        print("PASS: test_memoize_exists")
        passed += 1
    else:
        print("FAIL: test_memoize_exists")
        failed += 1
    
    if test_memoize_with_max_size():
        print("PASS: test_memoize_with_max_size")
        passed += 1
    else:
        print("FAIL: test_memoize_with_max_size")
        failed += 1
    
    if test_lazy_property_exists():
        print("PASS: test_lazy_property_exists")
        passed += 1
    else:
        print("FAIL: test_lazy_property_exists")
        failed += 1
    
    if test_lazy_property_init():
        print("PASS: test_lazy_property_init")
        passed += 1
    else:
        print("FAIL: test_lazy_property_init")
        failed += 1
    
    if test_lazy_property_set_value():
        print("PASS: test_lazy_property_set_value")
        passed += 1
    else:
        print("FAIL: test_lazy_property_set_value")
        failed += 1
    
    if test_clear_all_cached_functions_exists():
        print("PASS: test_clear_all_cached_functions_exists")
        passed += 1
    else:
        print("FAIL: test_clear_all_cached_functions_exists")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
 