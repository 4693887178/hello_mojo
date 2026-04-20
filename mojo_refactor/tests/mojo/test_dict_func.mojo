from std.collections import Dict, List
from rqmojo.utils import RqValue, KIND_DICT, KIND_INT, KIND_FLOAT, KIND_STRING
from rqmojo.utils.dict_func import deep_update


def make_int(val: Int64) -> RqValue:
    var v = RqValue()
    v.kind = KIND_INT
    v.int_val = val
    return v^


def make_float(val: Float64) -> RqValue:
    var v = RqValue()
    v.kind = KIND_FLOAT
    v.float_val = val
    return v^


def make_string(val: String) -> RqValue:
    var v = RqValue()
    v.kind = KIND_STRING
    v.string_val = val
    return v^


def make_dict(mut d: Dict[String, RqValue]) -> RqValue:
    var v = RqValue()
    v.kind = KIND_DICT
    v.dict_val = d.copy()
    return v^


def make_bool_value() -> RqValue:
    var v = RqValue()
    v.kind = 3
    v.bool_val = True
    return v^


def test_deep_update_overwrite_scalar() raises:
    print("=== Test 1: Overwrite scalar values ===")
    var base = Dict[String, RqValue]()
    base["a"] = make_int(1)
    base["b"] = make_string("old")
    base["c"] = make_float(3.14)

    var override = Dict[String, RqValue]()
    override["a"] = make_int(99)
    override["b"] = make_string("new")

    deep_update(override, base)

    assert base["a"].int_val == 99
    assert base["b"].string_val == "new"
    assert base["c"].float_val == 3.14
    print("  ✓ scalars overwritten, untouched keys preserved")


def test_deep_update_add_new_keys() raises:
    print("\n=== Test 2: Add new keys ===")
    var base = Dict[String, RqValue]()
    base["x"] = make_int(10)

    var extra = Dict[String, RqValue]()
    extra["y"] = make_string("added")
    extra["z"] = make_float(2.71)

    deep_update(extra, base)

    assert len(base) == 3
    assert base["x"].int_val == 10
    assert base["y"].string_val == "added"
    assert base["z"].float_val == 2.71
    print("  ✓ new keys added, existing preserved")


def test_deep_update_nested_dict() raises:
    print("\n=== Test 3: Nested dict merge (recursive) ===")
    var inner_base = Dict[String, RqValue]()
    inner_base["p"] = make_int(100)
    inner_base["q"] = make_string("base_q")

    var inner_override = Dict[String, RqValue]()
    inner_override["p"] = make_int(200)
    inner_override["r"] = make_bool_value()

    var base = Dict[String, RqValue]()
    base["config"] = make_dict(inner_base)

    var override = Dict[String, RqValue]()
    override["config"] = make_dict(inner_override)

    deep_update(override, base)

    var merged_config = base["config"].dict_val.copy()
    assert merged_config["p"].int_val == 200
    assert merged_config["q"].string_val == "base_q"
    assert merged_config["r"].kind == 3
    print("  ✓ nested dict merged correctly (deep merge)")


def test_deep_update_nested_dict_to_scalar() raises:
    print("\n=== Test 4: Nested dict replaced by scalar ===")
    var inner = Dict[String, RqValue]()
    inner["deep"] = make_int(42)

    var base = Dict[String, RqValue]()
    base["node"] = make_dict(inner)

    var override = Dict[String, RqValue]()
    override["node"] = make_string("replaced")

    deep_update(override, base)

    assert base["node"].is_string()
    assert base["node"].string_val == "replaced"
    print("  ✓ dict value replaced by scalar")


def test_deep_update_empty_from() raises:
    print("\n=== Test 5: Empty from_dict (no-op) ===")
    var base = Dict[String, RqValue]()
    base["keep"] = make_int(42)

    var empty = Dict[String, RqValue]()

    deep_update(empty, base)

    assert len(base) == 1
    assert base["keep"].int_val == 42
    print("  ✓ empty source leaves target unchanged")


def test_deep_update_empty_to() raises:
    print("\n=== Test 6: Empty to_dict (copy all) ===")
    var base = Dict[String, RqValue]()

    var src = Dict[String, RqValue]()
    src["k1"] = make_int(1)
    src["k2"] = make_string("v2")

    deep_update(src, base)

    assert len(base) == 2
    assert base["k1"].int_val == 1
    assert base["k2"].string_val == "v2"
    print("  ✓ all keys copied into empty target")


def test_deep_update_triple_nesting() raises:
    print("\n=== Test 7: Triple-nested dict merge ===")
    var l3_base = Dict[String, RqValue]()
    l3_base["leaf_a"] = make_int(1)

    var l3_override = Dict[String, RqValue]()
    l3_override["leaf_b"] = make_int(2)

    var l2_base = Dict[String, RqValue]()
    l2_base["level3"] = make_dict(l3_base)

    var l2_override = Dict[String, RqValue]()
    l2_override["level3"] = make_dict(l3_override)

    var base = Dict[String, RqValue]()
    base["level2"] = make_dict(l2_base)

    var override = Dict[String, RqValue]()
    override["level2"] = make_dict(l2_override)

    deep_update(override, base)

    var result_l3 = base["level2"].dict_val["level3"].dict_val.copy()
    assert result_l3["leaf_a"].int_val == 1
    assert result_l3["leaf_b"].int_val == 2
    print("  ✓ triple-level deep merge works")


def test_deep_update_original_unchanged() raises:
    print("\n=== Test 8: Source dict not mutated ===")
    var src_inner = Dict[String, RqValue]()
    src_inner["x"] = make_int(99)

    var src = Dict[String, RqValue]()
    src["nested"] = make_dict(src_inner)

    var dst = Dict[String, RqValue]()

    deep_update(src, dst)

    assert src["nested"].dict_val["x"].int_val == 99
    assert len(src) == 1
    print("  ✓ source dict unchanged after deep_update")


def main() raises:
    test_deep_update_overwrite_scalar()
    test_deep_update_add_new_keys()
    test_deep_update_nested_dict()
    test_deep_update_nested_dict_to_scalar()
    test_deep_update_empty_from()
    test_deep_update_empty_to()
    test_deep_update_triple_nesting()
    test_deep_update_original_unchanged()
    print("\n=== All 8 tests passed! ===")
