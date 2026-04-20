"""
Comprehensive Test Suite for rqmojo/utils/rq_json.mojo (utils-level)
Uses std.testing framework
"""

from std.python import Python, PythonObject
from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.utils.rq_json import convert_dict_to_json, convert_json_to_dict


def _make_py() -> Python:
    return Python()


def _make_dict() raises -> PythonObject:
    return _make_py().dict()


def test_basic_serialize() raises:
    var d = _make_dict()
    d["name"] = "test"
    var result = convert_dict_to_json(d)
    assert_true(result.find("name") >= 0)


def test_basic_deserialize() raises:
    var result = convert_json_to_dict('{"key": "value"}')
    assert_equal(String(py=result["key"]), "value")


def test_roundtrip() raises:
    var d = _make_dict()
    d["x"] = 42
    d["y"] = "hello"
    var json_str = convert_dict_to_json(d)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(Int(py=recovered["x"]), 42)
    assert_equal(String(py=recovered["y"]), "hello")


def test_empty_dict() raises:
    var d = _make_dict()
    var result = convert_dict_to_json(d)
    assert_equal(result, "{}")


def test_nested() raises:
    var inner = _make_dict()
    inner["deep"] = "val"
    var outer = _make_dict()
    outer["n"] = inner
    var json_str = convert_dict_to_json(outer)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(String(py=recovered["n"]["deep"]), "val")


def test_unicode() raises:
    var d = _make_dict()
    d["msg"] = "中文测试"
    var json_str = convert_dict_to_json(d)
    var recovered = convert_json_to_dict(json_str)
    assert_true(String(py=recovered["msg"]).find("中文") >= 0)


def test_error_handling() raises:
    var raised = False
    try:
        _ = convert_json_to_dict("{invalid}")
    except:
        raised = True
    assert_true(raised)


def test_all_types() raises:
    var d = _make_dict()
    d["int"] = 123
    d["float"] = 3.14
    d["bool"] = True
    d["str"] = "text"
    d["null"] = None
    var json_str = convert_dict_to_json(d)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(Int(py=recovered["int"]), 123)
    assert_equal(String(py=recovered["str"]), "text")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
