"""
Comprehensive unit tests for rqmojo.utils.testing.__init__
Tests all functionality to ensure consistency with Python version.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.python import Python, PythonObject
from std.collections import Dict, List

from rqmojo.utils.testing import RQAlphaTestCase
from rqmojo.utils.testing import isinstance_pydict, str_pyobject, pyobject_to_dict


def test_init_fixture_default() raises:
    """Test that init_fixture can be called without error."""
    var tc = RQAlphaTestCase()
    tc.init_fixture()
    print("[PASS] test_init_fixture_default")


def test_set_up_calls_init_fixture() raises:
    """Test that setUp calls init_fixture."""
    var tc = RQAlphaTestCase()
    tc.set_up()
    print("[PASS] test_set_up_calls_init_fixture")


def test_assert_obj_simple_attributes() raises:
    """Test assert_obj with simple attribute matching."""
    var builtins = Python().import_module("builtins")

    var obj: PythonObject = Python.evaluate(
        """
class SimpleObj:
    pass
obj = SimpleObj()
obj.name = 'test'
obj.value = 42
""",
        file=True
    )
    obj = builtins.getattr(obj, "obj")

    var tc = RQAlphaTestCase()
    var expected = Dict[String, PythonObject]()
    expected["name"] = PythonObject("test")
    expected["value"] = PythonObject(42)

    tc.assert_obj(obj, expected)
    print("[PASS] test_assert_obj_simple_attributes")


def test_assert_obj_nested_dict() raises:
    """Test assert_obj with nested dict (recursive assertion)."""
    var builtins = Python().import_module("builtins")

    var outer: PythonObject = Python.evaluate(
        """
class InnerObj:
    pass

class OuterObj:
    pass

inner = InnerObj()
inner.x = 10
inner.y = 20

outer = OuterObj()
outer.inner_obj = inner
outer.label = 'outer'
""",
        file=True
    )
    outer = builtins.getattr(outer, "outer")

    var tc = RQAlphaTestCase()

    var inner_expected: PythonObject = Python.dict()
    inner_expected["x"] = PythonObject(10)
    inner_expected["y"] = PythonObject(20)

    var outer_expected = Dict[String, PythonObject]()
    outer_expected["inner_obj"] = inner_expected
    outer_expected["label"] = PythonObject("outer")

    tc.assert_obj(outer, outer_expected)
    print("[PASS] test_assert_obj_nested_dict")


def test_assert_obj_missing_attribute_raises() raises:
    """Test that assert_obj raises error when attribute is missing."""
    var builtins = Python().import_module("builtins")

    var obj: PythonObject = Python.evaluate(
        """
class SimpleObj:
    pass
obj = SimpleObj()
obj.name = 'test'
""",
        file=True
    )
    obj = builtins.getattr(obj, "obj")

    var tc = RQAlphaTestCase()
    var expected = Dict[String, PythonObject]()
    expected["name"] = PythonObject("test")
    expected["nonexistent"] = PythonObject("value")

    try:
        tc.assert_obj(obj, expected)
        raise Error("Expected assertion error but none was raised")
    except e:
        var err_str = String(e)
        if not (err_str.find("not found") != -1):
            raise Error("Expected 'not found' in error message but got: " + err_str)
        print("[PASS] test_assert_obj_missing_attribute_raises")


def test_assert_obj_value_mismatch_raises() raises:
    """Test that assert_obj raises error when values don't match."""
    var builtins = Python().import_module("builtins")

    var obj: PythonObject = Python.evaluate(
        """
class SimpleObj:
    pass
obj = SimpleObj()
obj.value = 100
""",
        file=True
    )
    obj = builtins.getattr(obj, "obj")

    var tc = RQAlphaTestCase()
    var expected = Dict[String, PythonObject]()
    expected["value"] = PythonObject(200)

    try:
        tc.assert_obj(obj, expected)
        raise Error("Expected assertion error but none was raised")
    except e:
        var err_str = String(e)
        if not (err_str.find("mismatch") != -1):
            raise Error("Expected 'mismatch' in error message but got: " + err_str)
        print("[PASS] test_assert_obj_value_mismatch_raises")


def test_isinstance_pydict_with_dict() raises:
    """Test isinstance_pydict returns True for dict objects."""
    var test_dict: PythonObject = Python.dict()
    test_dict["key"] = PythonObject("value")
    var result = isinstance_pydict(test_dict)
    assert_true(result)
    print("[PASS] test_isinstance_pydict_with_dict")


def test_isinstance_pydict_with_non_dict() raises:
    """Test isinstance_pydict returns False for non-dict objects."""
    var test_str = PythonObject("not a dict")
    var result = isinstance_pydict(test_str)
    assert_false(result)
    print("[PASS] test_isinstance_pydict_with_non_dict")


def test_isinstance_pydict_with_list() raises:
    """Test isinstance_pydict returns False for list objects."""
    var test_list = Python.list(1, 2, 3)
    var result = isinstance_pydict(test_list)
    assert_false(result)
    print("[PASS] test_isinstance_pydict_with_list")


def test_str_pyobject_basic_types() raises:
    """Test str_pyobject with basic types."""
    var int_obj = PythonObject(42)
    var int_result = str_pyobject(int_obj)
    assert_equal(int_result, "42")

    var str_obj = PythonObject("hello")
    var str_result = str_pyobject(str_obj)
    assert_equal(str_result, "hello")

    print("[PASS] test_str_pyobject_basic_types")


def test_pyobject_to_dict_conversion() raises:
    """Test pyobject_to_dict converts Python dict correctly."""
    var py_dict: PythonObject = Python.dict()
    py_dict["a"] = PythonObject(1)
    py_dict["b"] = PythonObject("two")
    py_dict["c"] = PythonObject(3.0)
    var result = pyobject_to_dict(py_dict)

    assert_equal(len(result), 3)
    assert_true("a" in result)
    assert_true("b" in result)
    assert_true("c" in result)

    print("[PASS] test_pyobject_to_dict_conversion")


def test_empty_kwargs_assert_obj() raises:
    """Test assert_obj with empty kwargs (should succeed)."""
    var builtins = Python().import_module("builtins")

    var obj: PythonObject = Python.evaluate(
        """
class EmptyObj:
    pass
obj = EmptyObj()
""",
        file=True
    )
    obj = builtins.getattr(obj, "obj")

    var tc = RQAlphaTestCase()
    var expected = Dict[String, PythonObject]()

    tc.assert_obj(obj, expected)
    print("[PASS] test_empty_kwargs_assert_obj")


def test_multiple_attributes_assert_obj() raises:
    """Test assert_obj with multiple attributes of different types."""
    var builtins = Python().import_module("builtins")

    var obj: PythonObject = Python.evaluate(
        """
class MultiAttrObj:
    pass
obj = MultiAttrObj()
obj.int_val = 123
obj.str_val = 'test string'
obj.float_val = 3.14
obj.bool_val = True
""",
        file=True
    )
    obj = builtins.getattr(obj, "obj")

    var tc = RQAlphaTestCase()
    var expected = Dict[String, PythonObject]()
    expected["int_val"] = PythonObject(123)
    expected["str_val"] = PythonObject("test string")
    expected["float_val"] = PythonObject(3.14)
    expected["bool_val"] = PythonObject(True)

    tc.assert_obj(obj, expected)
    print("[PASS] test_multiple_attributes_assert_obj")


def main() raises:
    """Run all tests."""
    print("=" * 60)
    print("Running rqmojo.utils.testing Unit Tests")
    print("=" * 60)
    print("")

    test_init_fixture_default()
    test_set_up_calls_init_fixture()
    test_assert_obj_simple_attributes()
    test_assert_obj_nested_dict()
    test_assert_obj_missing_attribute_raises()
    test_assert_obj_value_mismatch_raises()
    test_isinstance_pydict_with_dict()
    test_isinstance_pydict_with_non_dict()
    test_isinstance_pydict_with_list()
    test_str_pyobject_basic_types()
    test_pyobject_to_dict_conversion()
    test_empty_kwargs_assert_obj()
    test_multiple_attributes_assert_obj()

    print("")
    print("=" * 60)
    print("All tests passed successfully!")
    print("=" * 60)
