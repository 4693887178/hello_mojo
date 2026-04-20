"""
RQMojo Test for utils/dict_func.mojo (with RqValue helper methods)
"""

from std.collections import Dict, List
from rqmojo.utils import RqValue, make_string_value, make_int_value, make_dict_value, make_float_value, make_bool_value
from rqmojo.utils.dict_func import deep_update

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


def test_deep_update_basic() raises:
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_string_value("test")
    from_dict["b"] = make_int_value(Int64(123))
    
    var to_dict = Dict[String, RqValue]()
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["a"].string_val, "test")
    assert_equal(to_dict["b"].int_val, Int64(123))


def test_deep_update_existing_non_dict() raises:
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_string_value("updated")
    
    var to_dict = Dict[String, RqValue]()
    to_dict["a"] = make_string_value("original")
    to_dict["b"] = make_int_value(Int64(456))
    
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["a"].string_val, "updated")
    assert_equal(to_dict["b"].int_val, Int64(456))


def test_deep_update_deep_nested() raises:
    var inner_from = Dict[String, RqValue]()
    inner_from["x"] = make_int_value(Int64(999))
    
    var from_dict = Dict[String, RqValue]()
    from_dict["nested"] = make_dict_value(inner_from)
    
    var inner_to = Dict[String, RqValue]()
    inner_to["y"] = make_string_value("existing")
    
    var to_dict = Dict[String, RqValue]()
    to_dict["nested"] = make_dict_value(inner_to)
    
    deep_update(from_dict, to_dict)
    
    assert_true(to_dict["nested"].is_dict())
    var nested_dict = to_dict["nested"].dict_val.copy()
    assert_equal(nested_dict["x"].int_val, Int64(999))
    assert_equal(nested_dict["y"].string_val, "existing")


def test_deep_update_replace_dict_with_non_dict() raises:
    var from_dict = Dict[String, RqValue]()
    from_dict["nested"] = make_string_value("not a dict")
    
    var inner_to = Dict[String, RqValue]()
    inner_to["y"] = make_string_value("existing")
    
    var to_dict = Dict[String, RqValue]()
    to_dict["nested"] = make_dict_value(inner_to)
    
    deep_update(from_dict, to_dict)
    
    assert_true(to_dict["nested"].is_string())
    assert_equal(to_dict["nested"].string_val, "not a dict")


def test_deep_update_replace_non_dict_with_dict() raises:
    var inner_from = Dict[String, RqValue]()
    inner_from["x"] = make_int_value(Int64(999))
    
    var from_dict = Dict[String, RqValue]()
    from_dict["nested"] = make_dict_value(inner_from)
    
    var to_dict = Dict[String, RqValue]()
    to_dict["nested"] = make_string_value("original")
    
    deep_update(from_dict, to_dict)
    
    assert_true(to_dict["nested"].is_dict())
    var nested_dict = to_dict["nested"].dict_val.copy()
    assert_equal(nested_dict["x"].int_val, Int64(999))


def test_deep_update_empty_dicts() raises:
    var from_dict = Dict[String, RqValue]()
    var to_dict = Dict[String, RqValue]()
    
    deep_update(from_dict, to_dict)
    
    assert_equal(len(to_dict), 0)


def test_deep_update_mixed_types() raises:
    var from_dict = Dict[String, RqValue]()
    from_dict["str"] = make_string_value("test")
    from_dict["int"] = make_int_value(Int64(123))
    from_dict["float"] = make_float_value(Float64(1.23))
    from_dict["bool"] = make_bool_value(True)
    
    var inner_from = Dict[String, RqValue]()
    inner_from["x"] = make_int_value(Int64(999))
    from_dict["nested"] = make_dict_value(inner_from)
    
    var to_dict = Dict[String, RqValue]()
    to_dict["str"] = make_string_value("original")
    
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["str"].string_val, "test")
    assert_equal(to_dict["int"].int_val, Int64(123))
    assert_equal(to_dict["float"].float_val, Float64(1.23))
    assert_equal(to_dict["bool"].bool_val, True)
    assert_true(to_dict["nested"].is_dict())
    var nested_dict = to_dict["nested"].dict_val.copy()
    assert_equal(nested_dict["x"].int_val, Int64(999))


def test_deep_update_multiple_nested_levels() raises:
    var level3 = Dict[String, RqValue]()
    level3["deep"] = make_string_value("deep_value")
    
    var level2 = Dict[String, RqValue]()
    level2["level3"] = make_dict_value(level3)
    
    var level1 = Dict[String, RqValue]()
    level1["level2"] = make_dict_value(level2)
    
    var from_dict = Dict[String, RqValue]()
    from_dict["level1"] = make_dict_value(level1)
    
    var to_dict = Dict[String, RqValue]()
    
    deep_update(from_dict, to_dict)
    
    assert_true(to_dict["level1"].is_dict())
    var l1 = to_dict["level1"].dict_val.copy()
    assert_true(l1["level2"].is_dict())
    var l2 = l1["level2"].dict_val.copy()
    assert_true(l2["level3"].is_dict())
    var l3 = l2["level3"].dict_val.copy()
    assert_equal(l3["deep"].string_val, "deep_value")


def test_deep_update_no_overwrite_unrelated_keys() raises:
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_string_value("updated")
    
    var to_dict = Dict[String, RqValue]()
    to_dict["a"] = make_string_value("original")
    to_dict["b"] = make_int_value(Int64(456))
    to_dict["c"] = make_float_value(Float64(1.23))
    
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["a"].string_val, "updated")
    assert_equal(to_dict["b"].int_val, Int64(456))
    assert_equal(to_dict["c"].float_val, Float64(1.23))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
