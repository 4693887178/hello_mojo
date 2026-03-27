"""
RQMojo Test for utils/dict_func.mojo
"""

from std.collections import Dict, List
from rqmojo.utils.dict_func import deep_update
from rqmojo.utils import RqValue, KIND_INT, KIND_DICT


def make_int_value(val: Int64) -> RqValue:
    var result = RqValue()
    result.kind = KIND_INT
    result.int_val = val
    return result^


def make_dict_value(d: Dict[String, RqValue]) -> RqValue:
    var result = RqValue()
    result.kind = KIND_DICT
    result.dict_val = d.copy()
    return result^


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_simple_update() raises:
    print("Testing deep_update simple update...")
    
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_int_value(1)
    from_dict["b"] = make_int_value(2)
    
    var to_dict = Dict[String, RqValue]()
    
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["a"].int_val, 1)
    assert_equal(to_dict["b"].int_val, 2)
    print("  deep_update simple update tests passed!")


def test_overwrite_value() raises:
    print("Testing deep_update overwrite value...")
    
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_int_value(0)
    from_dict["c"] = make_int_value(3)
    
    var to_dict = Dict[String, RqValue]()
    
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["a"].int_val, 0)
    assert_equal(to_dict["c"].int_val, 3)
    print("  deep_update overwrite value tests passed!")


def test_nested_dict_update() raises:
    print("Testing deep_update nested dict update...")
    
    var inner_from = Dict[String, RqValue]()
    inner_from["b"] = make_int_value(1)
    inner_from["c"] = make_int_value(2)
    
    var inner_to = Dict[String, RqValue]()
    inner_to["d"] = make_int_value(3)
    
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_dict_value(inner_from)
    
    var to_dict = Dict[String, RqValue]()
    to_dict["a"] = make_dict_value(inner_to)
    
    deep_update(from_dict, to_dict)
    
    assert_true(to_dict["a"].dict_val.__contains__("b"), "Should contain b")
    assert_true(to_dict["a"].dict_val.__contains__("c"), "Should contain c")
    assert_true(to_dict["a"].dict_val.__contains__("d"), "Should contain d")
    
    print("  deep_update nested dict update tests passed!")


def test_empty_from_dict() raises:
    print("Testing deep_update empty from_dict...")
    
    var from_dict = Dict[String, RqValue]()
    
    var to_dict = Dict[String, RqValue]()
    to_dict["a"] = make_int_value(1)
    
    deep_update(from_dict, to_dict)
    
    assert_equal(to_dict["a"].int_val, 1)
    print("  deep_update empty from_dict tests passed!")


def test_empty_to_dict() raises:
    print("Testing deep_update empty to_dict...")
    
    var from_dict = Dict[String, RqValue]()
    from_dict["a"] = make_int_value(1)
    
    var to_dict = Dict[String, RqValue]()
    
    deep_update(from_dict, to_dict)
    
    assert_true(to_dict.__contains__("a"), "Should contain a")
    assert_equal(to_dict["a"].int_val, 1)
    
    print("  deep_update empty to_dict tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
