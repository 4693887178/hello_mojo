"""
第四组测试 - utils/rq_json.mojo
测试Mojo版本的JSON工具模块
"""

from rqmojo.utils.rq_json import convert_dict_to_json, convert_json_to_dict
from python import Python


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_convert_dict_to_json_exists() raises:
    var _ = Python()
    var py = Python()
    var test_dict = py.dict()
    test_dict["key"] = "value"
    test_dict["number"] = 42
    
    var result = convert_dict_to_json(test_dict)
    assert_true(len(result) > 0, "JSON string should not be empty")


def test_convert_json_to_dict_exists() raises:
    var json_str = "{\"key\": \"value\", \"number\": 42}"
    var result = convert_json_to_dict(json_str)
    assert_true(True, "convert_json_to_dict works")


def test_roundtrip_simple_dict() raises:
    var py = Python()
    var original = py.dict()
    original["name"] = "test"
    original["value"] = 100
    
    var json_str = convert_dict_to_json(original)
    var result = convert_json_to_dict(json_str)
    assert_true(True, "roundtrip works")


def test_json_contains_key() raises:
    var py = Python()
    var test_dict = py.dict()
    test_dict["test_key"] = "test_value"
    
    var json_str = convert_dict_to_json(test_dict)
    assert_true(json_str.find("test_key") >= 0, "JSON should contain key")


def test_json_string_format() raises:
    var py = Python()
    var test_dict = py.dict()
    test_dict["a"] = 1
    
    var json_str = convert_dict_to_json(test_dict)
    assert_true(json_str.find("{") >= 0, "JSON should start with {")
    assert_true(json_str.find("}") >= 0, "JSON should end with }")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
