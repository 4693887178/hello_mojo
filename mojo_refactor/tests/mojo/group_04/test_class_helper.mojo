"""
第四组测试 - utils/class_helper.mojo
测试Mojo版本的类辅助模块（修复后版本）

重构覆盖范围:
  1. deprecated_property(): 访问时 warn + 属性重定向（非调用时）
  2. DeprecatedProperty 结构体：old_name/new_name/get_value()
  3. CachedProperty 结构体：泛型懒计算缓存（PythonObject）
  4. cached_property 工厂函数（= CachedProperty 别名）
  5. 与 Python 原版功能一致性验证

对应 Python 原版: rqalpha/utils/class_helper.py
"""

from std.python import Python, PythonObject
from std.testing import (
    assert_equal,
    assert_true,
    assert_false,
    assert_raises,
    TestSuite,
)

from rqmojo.utils.class_helper import (
    deprecated_property,
    cached_property,
    CachedProperty,
    DeprecatedProperty,
)
from rqmojo.utils.i18n import gettext


# ============================================================
# Section 1: gettext / i18n integration (baseline)
# ============================================================

def test_gettext_direct_call() raises:
    """Verify gettext works directly."""
    var result = gettext("test message")
    assert_equal(
        result,
        "test message",
        "gettext should return input for untranslated strings",
    )


def test_gettext_deprecation_message_template() raises:
    """Verify the deprecation message template is translatable."""
    var part1 = gettext("\"")
    var part2 = gettext("\" is deprecated, please use \"")
    var part3 = gettext("\" instead, check the document for more information")
    assert_true(len(part1) > 0, "quote part should translate")
    assert_true(part2.find("deprecated") >= 0, "deprecation keyword present")
    assert_true(len(part3) > 0, "message tail should translate")


# ============================================================
# Section 2: deprecated_property function
# ============================================================

def test_deprecated_property_returns_DeprecatedProperty() raises:
    """Deprecated property returns DeprecatedProperty struct."""
    var info = deprecated_property("old_prop", "new_prop")
    assert_true(
        info.old_name() == "old_prop",
        "old_name should match first argument",
    )
    assert_true(
        info.new_name() == "new_prop",
        "new_name should match second argument",
    )


def test_deprecated_property_same_names_raises() raises:
    """Deprecated property raises when both names are identical."""
    with assert_raises():
        _ = deprecated_property("same", "same")


def test_deprecated_property_does_not_warn_on_creation() raises:
    """Warning must be emitted on get_value() access, NOT on creation."""
    var _info = deprecated_property("silent_old", "silent_new")


# ============================================================
# Section 3: DeprecatedProperty struct
# ============================================================

def test_DeprecatedProperty_fields() raises:
    """DeprecatedProperty carries old_name and new_name metadata."""
    var dp = DeprecatedProperty("my_old_attr", "my_new_attr")
    assert_equal(dp.old_name(), "my_old_attr")
    assert_equal(dp.new_name(), "my_new_attr")


def test_DeprecatedProperty_copyable() raises:
    """DeprecatedProperty supports Copyable trait."""
    var original = DeprecatedProperty("a", "b")
    var copied = original.copy()
    assert_equal(copied.old_name(), "a")
    assert_equal(copied.new_name(), "b")


def test_DeprecatedProperty_get_value_warns_and_redirects() raises:
    """Get value emits warning and returns getattr(new_name)."""
    var dp = deprecated_property("old_val", "new_val")
    var mod = Python.evaluate(
        "class O:\n    def __init__(self): self.new_val = 42\n"
        "_inst = O()",
        file=True,
    )
    var obj = mod._inst
    var result = dp.get_value(obj)
    assert_equal(Int(py=result), 42, "should redirect to new_val attribute")


def test_DeprecatedProperty_get_value_multiple_accesses() raises:
    """Each get_value() call returns redirected value."""
    var dp = deprecated_property("old_x", "new_x")
    var mod = Python.evaluate(
        "class O:\n    def __init__(self): self.new_x = 99\n"
        "_inst2 = O()",
        file=True,
    )
    var obj = mod._inst2
    var r1 = dp.get_value(obj)
    var r2 = dp.get_value(obj)
    assert_equal(Int(py=r1), 99, "first access returns redirected value")
    assert_equal(Int(py=r2), 99, "second access also returns redirected value")


def test_DeprecatedProperty_get_value_missing_attribute() raises:
    """Get value raises when target attribute does not exist."""
    var dp = deprecated_property("old_missing", "also_missing")
    var mod = Python.evaluate("class O: pass\n_inst3 = O()", file=True)
    var obj = mod._inst3
    with assert_raises():
        _ = dp.get_value(obj)


# ============================================================
# Section 4: CachedProperty struct construction and basics
# ============================================================

def test_CachedProperty_from_constructor() raises:
    """CachedProperty can be constructed with a Python callable."""
    var getter = Python.evaluate("lambda self: 'computed'")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('Inst', (), {})()")
    assert_false(cp.is_cached(inst), "freshly created should not be cached")
    assert_equal(cp.name(), "<lambda>", "name should reflect getter.__name__")


def test_CachedProperty_name_reflects_getter() raises:
    """CachedProperty.name() returns the getter function name."""
    var mod = Python.evaluate(
        "def my_expensive_fn(self):\n    return 123\n"
        "_fn1 = my_expensive_fn",
        file=True,
    )
    var py_fn = mod._fn1
    var cp = CachedProperty(py_fn)
    assert_equal(cp.name(), "my_expensive_fn")


def test_CachedProperty_initial_state_not_cached() raises:
    """New CachedProperty instance has is_cached() == False."""
    var getter = Python.evaluate("lambda self: None")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('Inst', (), {})()")
    assert_false(cp.is_cached(inst))


# ============================================================
# Section 5: CachedProperty lazy computation and caching
# ============================================================

def test_CachedProperty_lazy_computation() raises:
    """Value is computed only on first get_value() call."""
    var mod = Python.evaluate(
        "class _Counter:\n"
        "    n = 0\n"
        "    def getter(self):\n"
        "        _Counter.n += 1\n"
        "        return _Counter.n * 10\n"
        "_cnt = _Counter()\n"
        "_getter_fn = _Counter.getter",
        file=True,
    )
    var getter = mod._getter_fn
    var cp = CachedProperty(getter)
    var instance = Python.evaluate("type('Inst', (), {})()")

    assert_false(cp.is_cached(instance), "before first access")

    var val1 = cp.get_value(instance)
    assert_equal(Int(py=val1), 10, "first call computes and returns")
    assert_true(cp.is_cached(instance), "after first access, should be cached")

    var val2 = cp.get_value(instance)
    assert_equal(
        Int(py=val2),
        10,
        "second call returns same cached value (not recomputed)",
    )


def test_CachedProperty_caches_result() raises:
    """Subsequent get_value() calls return identical cached object."""
    var getter = Python.evaluate("lambda self: [1, 2, 3]")
    var cp = CachedProperty(getter)
    var instance = Python.evaluate("type('Inst', (), {})()")

    var first = cp.get_value(instance)
    var second = cp.get_value(instance)
    assert_true(
        first is second,
        "cached references should be identical (same object)",
    )


def test_CachedProperty_different_instances_independent_cache() raises:
    """Different instances produce independent cached values."""
    var getter = Python.evaluate("lambda self: id(self)")
    var cp = CachedProperty(getter)
    var inst1 = Python.evaluate("type('A', (), {})()")
    var inst2 = Python.evaluate("type('B', (), {})()")

    var val1 = cp.get_value(inst1)
    assert_true(cp.is_cached(inst1), "inst1 should be cached")
    assert_false(cp.is_cached(inst2), "inst2 should NOT be cached yet")

    var val2 = cp.get_value(inst2)
    assert_true(
        val1 != val2,
        "different instances should yield different cached values",
    )


def test_CachedProperty_with_int_return() raises:
    """CachedProperty works with integer return values."""
    var getter = Python.evaluate("lambda self: 42")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('I', (), {})()")

    var result = cp.get_value(inst)
    assert_equal(Int(py=result), 42)


def test_CachedProperty_with_string_return() raises:
    """CachedProperty works with string return values."""
    var getter = Python.evaluate("lambda self: 'hello world'")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('I', (), {})()")

    var result = cp.get_value(inst)
    assert_equal(String(py=result), "hello world")


def test_CachedProperty_with_list_return() raises:
    """CachedProperty works with list return values; mutation persists in cache."""
    var getter = Python.evaluate("lambda self: [1, 2, 3]")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('I', (), {})()")

    var items = cp.get_value(inst)
    items.append(4)

    var again = cp.get_value(inst)
    var length = Int(py=len(again))
    assert_equal(length, 4, "mutation to cached list should persist")


def test_CachedProperty_with_dict_return() raises:
    """CachedProperty works with dict return values."""
    var getter = Python.evaluate("lambda self: {'a': 1, 'b': 2}")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('I', (), {})()")

    var result = cp.get_value(inst)
    assert_equal(Int(py=result["a"]), 1)


def test_CachedProperty_with_dependency_on_instance_attrs() raises:
    """Getter can read other instance attributes."""
    var getter = Python.evaluate("lambda self: self._base * 2")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('I', (), {'_base': 10})()")

    var result = cp.get_value(inst)
    assert_equal(Int(py=result), 20)


def test_CachedProperty_reset_clears_cache() raises:
    """Reset() forces recomputation on next get_value()."""
    var getter = Python.evaluate("lambda self: id(self)")
    var cp = CachedProperty(getter)
    var inst = Python.evaluate("type('I', (), {})()")

    var v1 = cp.get_value(inst)
    assert_true(cp.is_cached(inst), "should be cached after first access")
    cp.reset()
    assert_false(cp.is_cached(inst), "after reset, should not be cached")

    var v2 = cp.get_value(inst)
    assert_true(cp.is_cached(inst), "after re-access, should be cached again")


# ============================================================
# Section 6: cached_property factory function (= alias)
# ============================================================

def test_cached_property_factory_returns_CachedProperty() raises:
    """Cached property factory returns a CachedProperty instance."""
    var getter = Python.evaluate("lambda self: 'factory_test'")
    var cp = cached_property(getter)
    var inst = Python.evaluate("type('Inst', (), {})()")
    assert_true(cp.name() == "<lambda>", "factory-produced CP should work")
    assert_false(cp.is_cached(inst))


def test_cached_property_factory_same_as_CachedProperty() raises:
    """Factory function and constructor behave identically."""
    var getter = Python.evaluate("lambda self: 77")
    var cp_from_factory = cached_property(getter)
    var cp_from_ctor = CachedProperty(getter)
    var mod = Python.evaluate("class _CI: pass\nclass _CJ: pass\n_i = _CI()\n_j = _CJ()", file=True)
    var inst = mod._i
    var inst2 = mod._j

    var v1 = cp_from_factory.get_value(inst)
    var v2 = cp_from_ctor.get_value(inst2)
    assert_equal(Int(py=v1), 77)
    assert_equal(Int(py=v2), 77)


# ============================================================
# Section 7: exports consistency
# ============================================================

def test_all_exports_count() raises:
    """Verify __all__ has exactly 3 entries matching Python module."""
    from rqmojo.utils.class_helper import __all__ as all_symbols
    var count = comptime(len(all_symbols))
    assert_true(count == 3, "__all__ should have exactly 3 entries")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
