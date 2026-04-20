"""
Unit tests for rqmojo/mod/__init__.mojo
Tests cover: ModInfo, ModHandler, mod_config_value_parse, SYSTEM_MOD_LIST
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List
from std.utils import Variant
from rqmojo.const import EXIT_CODE
from rqmojo.utils.exception import CustomError
from rqmojo.mod import (
    ModInfo, ModHandler, AbstractMod, ConfigValue,
    create_mod_handler, get_system_mod_list, get_system_mod,
    mod_config_value_parse, _is_digit_string, _try_parse_int,
    _try_parse_float, _get_system_mod_names, SYSTEM_MOD_COUNT,
)


def test_mod_info_creation() raises:
    var info = ModInfo(name="test_mod", version="1.0.0", enabled=True, priority=50)
    assert_equal(info.name, "test_mod")
    assert_equal(info.version, "1.0.0")
    assert_true(info.enabled)
    assert_equal(info.priority, 50)


def test_mod_info_default_priority() raises:
    var info = ModInfo(name="mod", version="0.1.0", enabled=False, priority=100)
    assert_equal(info.priority, 100)


def test_mod_info_copy() raises:
    var info = ModInfo(name="orig", version="2.0", enabled=True, priority=10)
    var copied = info.copy()
    assert_equal(copied.name, "orig")
    assert_equal(copied.version, "2.0")
    assert_true(copied.enabled)
    assert_equal(copied.priority, 10)


def test_mod_info_write_to() raises:
    var info = ModInfo(name="my_mod", version="1.0", enabled=True, priority=100)
    var s = String.write(info)
    assert_true(len(s) > 0)


def test_system_mod_names() raises:
    var names = _get_system_mod_names()
    assert_equal(len(names), 7)
    assert_equal(names[0], "sys_accounts")
    assert_equal(names[1], "sys_analyser")
    assert_equal(names[2], "sys_progress")
    assert_equal(names[3], "sys_risk")
    assert_equal(names[4], "sys_simulation")
    assert_equal(names[5], "sys_transaction_cost")
    assert_equal(names[6], "sys_scheduler")


def test_system_mod_count() raises:
    assert_equal(SYSTEM_MOD_COUNT, 7)


def test_mod_handler_init() raises:
    var handler = ModHandler()
    assert_equal(handler.get_mod_count(), 7)
    assert_false(handler.is_started())
    assert_equal(handler.get_env(), "")


def test_mod_handler_create() raises:
    var handler = create_mod_handler()
    assert_equal(handler.get_mod_count(), 7)


def test_mod_handler_set_env() raises:
    var handler = create_mod_handler()
    handler.set_env("test_env")
    assert_equal(handler.get_env(), "test_env")


def test_mod_handler_start_up() raises:
    var handler = create_mod_handler()
    assert_false(handler.is_started())
    handler.start_up()
    assert_true(handler.is_started())


def test_mod_handler_tear_down() raises:
    var handler = create_mod_handler()
    handler.start_up()
    assert_true(handler.is_started())
    var result = handler.tear_down(EXIT_CODE.EXIT_SUCCESS)
    assert_false(handler.is_started())
    assert_equal(len(result), 0)


def test_mod_handler_tear_down_with_exception() raises:
    var handler = create_mod_handler()
    handler.start_up()
    var exc = CustomError("test error")
    var result = handler.tear_down(EXIT_CODE.EXIT_USER_ERROR, exc^)
    assert_false(handler.is_started())


def test_mod_handler_add_mod() raises:
    var handler = create_mod_handler()
    assert_equal(handler.get_mod_count(), 7)
    handler.add_mod("custom_mod")
    assert_equal(handler.get_mod_count(), 8)
    var mod = handler.get_mod("custom_mod")
    assert_true(mod != None)


def test_mod_handler_add_mod_with_version() raises:
    var handler = create_mod_handler()
    handler.add_mod("my_mod", version="2.0.0", enabled=False, priority=50)
    var mod = handler.get_mod("my_mod")
    assert_true(mod != None)
    var m = mod.or_else(ModInfo(name="", version="", enabled=False, priority=0))
    assert_equal(m.version, "2.0.0")
    assert_false(m.enabled)
    assert_equal(m.priority, 50)


def test_mod_handler_get_mod() raises:
    var handler = create_mod_handler()
    var mod = handler.get_mod("sys_accounts")
    assert_true(mod != None)
    var m = mod.or_else(ModInfo(name="", version="", enabled=False, priority=0))
    assert_equal(m.name, "sys_accounts")
    assert_true(m.enabled)


def test_mod_handler_get_mod_not_found() raises:
    var handler = create_mod_handler()
    var mod = handler.get_mod("nonexistent_mod")
    assert_true(mod == None)


def test_mod_handler_get_mod_list() raises:
    var handler = create_mod_handler()
    var mod_list = handler.get_mod_list()
    assert_equal(len(mod_list), 7)
    assert_equal(mod_list[0].name, "sys_accounts")


def test_mod_handler_get_enabled_mod_list() raises:
    var handler = create_mod_handler()
    var enabled = handler.get_enabled_mod_list()
    assert_equal(len(enabled), 7)
    handler.add_mod("disabled_mod", enabled=False)
    var enabled2 = handler.get_enabled_mod_list()
    assert_equal(len(enabled2), 7)


def test_mod_handler_register_mod() raises:
    var handler = create_mod_handler()
    var new_mod = ModInfo(name="new_mod", version="3.0", enabled=True, priority=10)
    handler.register_mod(new_mod)
    assert_equal(handler.get_mod_count(), 8)
    var found = handler.get_mod("new_mod")
    assert_true(found != None)


def test_mod_handler_unregister_mod() raises:
    var handler = create_mod_handler()
    assert_true(handler.contains_mod("sys_accounts"))
    var result = handler.unregister_mod("sys_accounts")
    assert_true(result)
    assert_equal(handler.get_mod_count(), 6)
    assert_false(handler.contains_mod("sys_accounts"))


def test_mod_handler_unregister_mod_not_found() raises:
    var handler = create_mod_handler()
    var result = handler.unregister_mod("nonexistent")
    assert_false(result)
    assert_equal(handler.get_mod_count(), 7)


def test_mod_handler_contains_mod() raises:
    var handler = create_mod_handler()
    assert_true(handler.contains_mod("sys_accounts"))
    assert_true(handler.contains_mod("sys_analyser"))
    assert_false(handler.contains_mod("nonexistent"))


def test_mod_handler_sort_by_priority() raises:
    var handler = create_mod_handler()
    handler.add_mod("high_priority", priority=1)
    handler.add_mod("low_priority", priority=200)
    handler.sort_by_priority()
    var mod_list = handler.get_mod_list()
    assert_equal(mod_list[0].name, "high_priority")


def test_mod_handler_write_to() raises:
    var handler = create_mod_handler()
    var s = String.write(handler)
    assert_true(len(s) > 0)


def test_get_system_mod_list() raises:
    var mod_list = get_system_mod_list()
    assert_equal(len(mod_list), 7)
    assert_equal(mod_list[0].name, "sys_accounts")


def test_get_system_mod_found() raises:
    var mod = get_system_mod("sys_accounts")
    assert_true(mod != None)
    var m = mod.or_else(ModInfo(name="", version="", enabled=False, priority=0))
    assert_equal(m.name, "sys_accounts")


def test_get_system_mod_not_found() raises:
    var mod = get_system_mod("nonexistent")
    assert_true(mod == None)


def test_is_digit_string_true() raises:
    assert_true(_is_digit_string("123"))
    assert_true(_is_digit_string("0"))
    assert_true(_is_digit_string("999999"))


def test_is_digit_string_false() raises:
    assert_false(_is_digit_string(""))
    assert_false(_is_digit_string("12.3"))
    assert_false(_is_digit_string("abc"))
    assert_false(_is_digit_string("-1"))
    assert_false(_is_digit_string("12a3"))
    assert_false(_is_digit_string(" "))


def test_try_parse_int() raises:
    assert_equal(_try_parse_int("0"), 0)
    assert_equal(_try_parse_int("42"), 42)
    assert_equal(_try_parse_int("123"), 123)
    assert_equal(_try_parse_int("-1"), -1)
    assert_equal(_try_parse_int("+5"), 5)


def test_try_parse_int_errors() raises:
    var caught = False
    try:
        _ = _try_parse_int("")
    except:
        caught = True
    assert_true(caught)

    caught = False
    try:
        _ = _try_parse_int("abc")
    except:
        caught = True
    assert_true(caught)

    caught = False
    try:
        _ = _try_parse_int("12.3")
    except:
        caught = True
    assert_true(caught)


def test_try_parse_float() raises:
    var r1 = _try_parse_float("3.14")
    assert_true(r1 > 3.13 and r1 < 3.15)

    var r2 = _try_parse_float("0.5")
    assert_true(r2 > 0.49 and r2 < 0.51)

    var r3 = _try_parse_float("100")
    assert_true(r3 > 99.9 and r3 < 100.1)

    var r4 = _try_parse_float("-1.5")
    assert_true(r4 > -1.51 and r4 < -1.49)

    var r5 = _try_parse_float("0")
    assert_true(r5 == 0.0)


def test_try_parse_float_errors() raises:
    var caught = False
    try:
        _ = _try_parse_float("")
    except:
        caught = True
    assert_true(caught)

    caught = False
    try:
        _ = _try_parse_float("abc")
    except:
        caught = True
    assert_true(caught)


def test_mod_config_value_parse_true() raises:
    var v = mod_config_value_parse("True")
    assert_true(v.isa[Bool]())
    assert_true(v[Bool])

    var v2 = mod_config_value_parse("true")
    assert_true(v2.isa[Bool]())
    assert_true(v2[Bool])


def test_mod_config_value_parse_false() raises:
    var v = mod_config_value_parse("False")
    assert_true(v.isa[Bool]())
    assert_false(v[Bool])

    var v2 = mod_config_value_parse("false")
    assert_true(v2.isa[Bool]())
    assert_false(v2[Bool])


def test_mod_config_value_parse_int() raises:
    var v = mod_config_value_parse("42")
    assert_true(v.isa[Int]())
    assert_equal(v[Int], 42)

    var v2 = mod_config_value_parse("0")
    assert_true(v2.isa[Int]())
    assert_equal(v2[Int], 0)

    var v3 = mod_config_value_parse("999")
    assert_true(v3.isa[Int]())
    assert_equal(v3[Int], 999)


def test_mod_config_value_parse_float() raises:
    var v = mod_config_value_parse("3.14")
    assert_true(v.isa[Float64]())
    var fval = v[Float64]
    assert_true(fval > 3.13 and fval < 3.15)

    var v2 = mod_config_value_parse("0.5")
    assert_true(v2.isa[Float64]())


def test_mod_config_value_parse_string() raises:
    var v = mod_config_value_parse("hello")
    assert_true(v.isa[String]())
    assert_equal(v[String], "hello")

    var v2 = mod_config_value_parse("some_config_value")
    assert_true(v2.isa[String]())
    assert_equal(v2[String], "some_config_value")


def test_mod_config_value_parse_negative_not_int() raises:
    var v = mod_config_value_parse("-1")
    assert_true(v.isa[Float64]())


def test_mod_config_value_parse_empty_string() raises:
    var v = mod_config_value_parse("")
    assert_true(v.isa[String]())
    assert_equal(v[String], "")


def test_mod_config_value_parse_mixed() raises:
    var v1 = mod_config_value_parse("True")
    assert_true(v1.isa[Bool]())

    var v2 = mod_config_value_parse("100")
    assert_true(v2.isa[Int]())

    var v3 = mod_config_value_parse("2.5")
    assert_true(v3.isa[Float64]())

    var v4 = mod_config_value_parse("my_string")
    assert_true(v4.isa[String]())


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
