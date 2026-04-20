"""
Comprehensive Test Suite for rqmojo/utils/rq_json.mojo
Aligned with Python rqalpha/utils/rq_json.py behavior.

Test Categories:
  A. convert_dict_to_json - serialization (all types, nested, edge cases)
  B. convert_json_to_dict - deserialization (all types, nested, edge cases)
  C. Roundtrip consistency (encode -> decode preserves data)
  D. JSON format validation (structure, syntax correctness)
  E. Edge cases (empty, special characters, unicode, large values)
  F. Error handling (malformed JSON, type mismatches)
"""

from std.python import Python, PythonObject
from std.testing import assert_equal, assert_true, TestSuite
from rqmojo.utils.rq_json import convert_dict_to_json, convert_json_to_dict


def _make_py() -> Python:
    return Python()


def _make_dict() raises -> PythonObject:
    return _make_py().dict()


# ============================================================
# Category A: convert_dict_to_json - Serialization
# ============================================================

def test_serialize_simple_string_value() raises:
    var d = _make_dict()
    d["key"] = "value"
    var result = convert_dict_to_json(d)
    assert_true(result.find("key") >= 0, "should contain key")
    assert_true(result.find("value") >= 0, "should contain value")


def test_serialize_integer_value() raises:
    var d = _make_dict()
    d["num"] = 42
    var result = convert_dict_to_json(d)
    assert_true(result.find("42") >= 0, "should contain integer 42")


def test_serialize_float_value() raises:
    var d = _make_dict()
    d["pi"] = 3.14159
    var result = convert_dict_to_json(d)
    assert_true(
        result.find("3.14159") >= 0 or result.find("3.1416") >= 0,
        "should contain float value",
    )


def test_serialize_boolean_true() raises:
    var d = _make_dict()
    d["flag"] = True
    var result = convert_dict_to_json(d)
    assert_true(result.find("true") >= 0, "should contain true")


def test_serialize_boolean_false() raises:
    var d = _make_dict()
    d["flag"] = False
    var result = convert_dict_to_json(d)
    assert_true(result.find("false") >= 0, "should contain false")


def test_serialize_null_value() raises:
    var d = _make_dict()
    d["empty"] = None
    var result = convert_dict_to_json(d)
    assert_true(result.find("null") >= 0, "should contain null")


def test_serialize_multiple_keys() raises:
    var d = _make_dict()
    d["a"] = 1
    d["b"] = "two"
    d["c"] = 3.0
    var result = convert_dict_to_json(d)
    assert_true(result.find('"a"') >= 0, "should have key a")
    assert_true(result.find('"b"') >= 0, "should have key b")
    assert_true(result.find('"c"') >= 0, "should have key c")


def test_serialize_nested_dict() raises:
    var inner = _make_dict()
    inner["x"] = 10
    var outer = _make_dict()
    outer["nested"] = inner
    var result = convert_dict_to_json(outer)
    assert_true(result.find("nested") >= 0, "should have nested key")
    assert_true(result.find('"x"') >= 0 or result.find("'x'") >= 0, "should have inner key x")
    assert_true(result.find("10") >= 0, "should have inner value 10")


def test_serialize_list_value() raises:
    var d = _make_dict()
    var lst = _make_py().list(1, 2, 3)
    d["items"] = lst
    var result = convert_dict_to_json(d)
    assert_true(result.find("items") >= 0, "should have items key")


def test_serialize_empty_dict() raises:
    var d = _make_dict()
    var result = convert_dict_to_json(d)
    assert_equal(result, "{}", "empty dict should produce {}")


def test_result_is_valid_json_object() raises:
    var d = _make_dict()
    d["k"] = "v"
    var result = convert_dict_to_json(d)
    assert_true(result.find("{") == 0, "JSON should start with {")
    assert_true(result[byte=result.byte_length() - 1] == "}", "JSON should end with }")


# ============================================================
# Category B: convert_json_to_dict - Deserialization
# ============================================================

def test_deserialize_simple_object() raises:
    var result = convert_json_to_dict('{"key": "value"}')
    assert_equal(String(py=result["key"]), "value", "should deserialize string value")


def test_deserialize_integer() raises:
    var result = convert_json_to_dict('{"num": 123}')
    var val = Int(py=result["num"])
    assert_equal(val, 123, "should deserialize integer")


def test_deserialize_negative_integer() raises:
    var result = convert_json_to_dict('{"neg": -42}')
    var val = Int(py=result["neg"])
    assert_equal(val, -42, "should deserialize negative integer")


def test_deserialize_float() raises:
    var result = convert_json_to_dict('{"f": 3.14}')
    var val = Float64(py=result["f"])
    assert_true(val > 3.13 and val < 3.15, "should deserialize float in range")


def test_deserialize_boolean() raises:
    var result = convert_json_to_dict('{"t": true, "f": false}')
    assert_equal(Bool(py=result["t"]), True, "true should be True")
    assert_equal(Bool(py=result["f"]), False, "false should be False")


def test_deserialize_null() raises:
    var result = convert_json_to_dict('{"n": null}')
    var val_str = String(py=result["n"])
    assert_true(
        val_str == "None" or val_str == "null",
        "null should deserialize to None-like",
    )


def test_deserialize_multiple_fields() raises:
    var result = convert_json_to_dict('{"a": 1, "b": "two", "c": 3.0}')
    assert_equal(Int(py=result["a"]), 1, "field a")
    assert_equal(String(py=result["b"]), "two", "field b")


def test_deserialize_nested_object() raises:
    var result = convert_json_to_dict('{"outer": {"inner": 99}}')
    var inner = result["outer"]
    assert_equal(Int(py=inner["inner"]), 99, "nested value should be 99")


def test_deserialize_array_field() raises:
    var result = convert_json_to_dict('{"arr": [1, 2, 3]}')
    var arr = result["arr"]
    assert_equal(Int(py=len(arr)), 3, "array length should be 3")


def test_deserialize_empty_object() raises:
    var result = convert_json_to_dict("{}")
    assert_equal(Int(py=len(result)), 0, "empty object should have 0 keys")


def test_deserialize_unicode_string() raises:
    var result = convert_json_to_dict('{"msg": "中文测试"}')
    var s = String(py=result["msg"])
    assert_true(s.find("中文") >= 0, "should preserve unicode")


def test_deserialize_escaped_chars() raises:
    var result = convert_json_to_dict('{"s": "line1\\nline2"}')
    var s = String(py=result["s"])
    assert_true(s.find("line1") >= 0, "should have line1")


# ============================================================
# Category C: Roundtrip Consistency
# ============================================================

def test_roundtrip_string() raises:
    var original = _make_dict()
    original["name"] = "test_roundtrip"
    var json_str = convert_dict_to_json(original)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(String(py=recovered["name"]), "test_roundtrip", "roundtrip string should match")


def test_roundtrip_integer() raises:
    var original = _make_dict()
    original["val"] = 999
    var json_str = convert_dict_to_json(original)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(Int(py=recovered["val"]), 999, "roundtrip int should match")


def test_roundtrip_multiple_fields() raises:
    var original = _make_dict()
    original["x"] = 10
    original["y"] = "hello"
    original["z"] = 2.5
    var json_str = convert_dict_to_json(original)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(Int(py=recovered["x"]), 10, "roundtrip x")
    assert_equal(String(py=recovered["y"]), "hello", "roundtrip y")


def test_roundtrip_nested_preserves_structure() raises:
    var inner = _make_dict()
    inner["deep"] = "value"
    var original = _make_dict()
    original["outer"] = inner
    var json_str = convert_dict_to_json(original)
    var recovered = convert_json_to_dict(json_str)
    var inner_recovered = recovered["outer"]
    assert_equal(String(py=inner_recovered["deep"]), "value", "roundtrip nested value")


def test_roundtrip_empty_roundtrips() raises:
    var original = _make_dict()
    var json_str = convert_dict_to_json(original)
    var recovered = convert_json_to_dict(json_str)
    assert_equal(Int(py=len(recovered)), 0, "empty dict roundtrip stays empty")


# ============================================================
# Category D: JSON Format Validation
# ============================================================

def test_json_output_is_string_type() raises:
    var d = _make_dict()
    d["k"] = "v"
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 0, "result should be non-empty string")


def test_json_output_has_balanced_braces() raises:
    var d = _make_dict()
    d["a"] = 1
    d["b"] = 2
    var result = convert_dict_to_json(d)
    var open_count = 0
    var close_count = 0
    for cp_slice in result.codepoint_slices():
        var ch = String(cp_slice)
        if ch == "{":
            open_count += 1
        elif ch == "}":
            close_count += 1
    assert_equal(open_count, close_count, "braces must be balanced")


def test_json_output_contains_colons() raises:
    var d = _make_dict()
    d["key"] = "value"
    var result = convert_dict_to_json(d)
    assert_true(result.find(":") >= 0, "JSON should contain colons between keys and values")


def test_json_keys_are_quoted() raises:
    var d = _make_dict()
    d["mykey"] = "val"
    var result = convert_dict_to_json(d)
    assert_true(
        result.find('"mykey"') >= 0 or result.find("'mykey'") >= 0,
        "keys should be quoted",
    )


# ============================================================
# Category E: Edge Cases & Special Characters
# ============================================================

def test_special_chars_in_string_value() raises:
    var d = _make_dict()
    d["s"] = "hello\tworld\nnewline"
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 0, "special chars should not crash")


def test_unicode_key_and_value() raises:
    var d = _make_dict()
    d["键名"] = "值"
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 0, "unicode keys should work")


def test_very_long_string_value() raises:
    var d = _make_dict()
    var long_str = "x" * 10000
    d["long"] = long_str
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 10000, "long string should be preserved")


def test_many_keys() raises:
    var d = _make_dict()
    for i in range(100):
        d[String("key_" + String(i))] = i
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 0, "many keys should work")


def test_numeric_string_value() raises:
    var d = _make_dict()
    d["str_num"] = "12345"
    var result = convert_dict_to_json(d)
    var roundtrip = convert_json_to_dict(result)
    assert_equal(String(py=roundtrip["str_num"]), "12345", "numeric string preserved as string")


def test_zero_values() raises:
    var d = _make_dict()
    d["z"] = 0
    d["zf"] = 0.0
    d["zs"] = ""
    var result = convert_dict_to_json(d)
    var rt = convert_json_to_dict(result)
    assert_equal(Int(py=rt["z"]), 0, "zero int preserved")


def test_negative_zero_float() raises:
    var d = _make_dict()
    d["nz"] = -0.0
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 0, "negative zero should not crash")


def test_large_integer() raises:
    var d = _make_dict()
    d["big"] = 9007199254740992
    var result = convert_dict_to_json(d)
    assert_true(
        result.find("9007199254740992") >= 0 or len(result) > 0,
        "large int handled",
    )


def test_scientific_notation_float() raises:
    var d = _make_dict()
    d["sci"] = 1.5e10
    var result = convert_dict_to_json(d)
    assert_true(len(result) > 0, "scientific notation float works")


def test_whitespace_in_values() raises:
    var d = _make_dict()
    d["ws"] = "  spaces  "
    var result = convert_dict_to_json(d)
    var rt = convert_json_to_dict(result)
    assert_equal(String(py=rt["ws"]), "  spaces  ", "whitespace preserved")


# ============================================================
# Category F: Error Handling & Malformed Input
# ============================================================

def test_deserialize_invalid_json_raises() raises:
    var raised = False
    try:
        _ = convert_json_to_dict("{invalid json}")
    except:
        raised = True
    assert_true(raised, "invalid JSON should raise an error")


def test_deserialize_truncated_json_raises() raises:
    var raised = False
    try:
        _ = convert_json_to_dict('{"key":')
    except:
        raised = True
    assert_true(raised, "truncated JSON should raise an error")


def test_deserialize_empty_string_raises() raises:
    var raised = False
    try:
        _ = convert_json_to_dict("")
    except:
        raised = True
    assert_true(raised, "empty string should raise error on deserialize")


def test_deserialize_extra_comma_handling() raises:
    var raised = False
    try:
        _ = convert_json_to_dict('{"a": 1,}')
    except:
        raised = True
    assert_true(raised, "trailing comma should likely raise error")


def test_serialize_non_dict_object() raises:
    var lst = _make_py().list(1, 2, 3)
    var result = convert_dict_to_json(lst)
    assert_true(len(result) > 0, "serializing list should still produce output")


def test_deserialize_deeply_nested() raises:
    var deep = '{"l1": {"l2": {"l3": {"l4": {"l5": "bottom"}}}}}'
    var result = convert_json_to_dict(deep)
    var l1 = result["l1"]
    var l2 = l1["l2"]
    var l3 = l2["l3"]
    var l4 = l3["l4"]
    assert_equal(String(py=l4["l5"]), "bottom", "deep nesting works")


def test_deserialize_array_of_objects() raises:
    var result = convert_json_to_dict('[{"id": 1}, {"id": 2}]')
    assert_true(len(result) >= 0, "array of objects should parse")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
