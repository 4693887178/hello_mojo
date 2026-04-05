"""
Mojo Test for utils/exception.mojo
Comprehensive test suite covering all exception types, methods, and edge cases.
Uses std.testing framework as required by project conventions.
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List
from rqmojo.utils.exception import (
    CustomError,
    CustomException,
    RQUserError,
    RQInvalidArgument,
    RQTypeError,
    RQApiNotSupportedError,
    RQDatacVersionTooLow,
    InstrumentNotFound,
    EnvironmentNotInitialized,
    BaseExceptionGroup,
    ExceptionGroup,
    StackFrame,
    LocalVar,
    ModifyExceptionFromType,
    format_exception_group,
    patch_user_exc,
    patch_system_exc,
    get_exc_from_type,
    is_user_exc,
    is_system_exc,
)
from rqmojo.const import EXC_TYPE


def string_contains(s: String, sub: String) -> Bool:
    return s.find(sub) != -1


def test_stack_frame_construction() raises:
    var frame = StackFrame("test_file.mojo", 42, "test_func", "x = 1 + 1")
    assert_equal(frame.filename, "test_file.mojo")
    assert_equal(frame.lineno, 42)
    assert_equal(frame.func_name, "test_func")
    assert_equal(frame.code, "x = 1 + 1")


def test_stack_frame_equality() raises:
    var f1 = StackFrame("a.mojo", 1, "f", "c")
    var f2 = StackFrame("a.mojo", 1, "f", "c")
    var f3 = StackFrame("b.mojo", 2, "g", "d")
    assert_true(f1 == f2)
    assert_false(f1 == f3)


def test_local_var_construction() raises:
    var lv = LocalVar("x", "42")
    assert_equal(lv.name, "x")
    assert_equal(lv.value_str, "42")


def test_custom_error_default_constructor() raises:
    var err = CustomError()
    assert_equal(err.msg, "")
    assert_equal(err.exc_type_name, "Exception")
    assert_equal(err.error_type, EXC_TYPE.NOTSET)
    assert_equal(err.stacks_length(), 0)


def test_custom_error_parameterized_constructor() raises:
    var err = CustomError("test msg", "ValueError", EXC_TYPE.USER_EXC)
    assert_equal(err.msg, "test msg")
    assert_equal(err.exc_type_name, "ValueError")
    assert_equal(err.error_type, EXC_TYPE.USER_EXC)


def test_custom_error_movable_semantics() raises:
    var orig = CustomError("original", "TypeError", EXC_TYPE.SYSTEM_EXC)
    orig.add_stack_info("file.mojo", 10, "func", "code")
    assert_equal(orig.msg, "original")
    assert_equal(orig.exc_type_name, "TypeError")
    assert_equal(orig.error_type, EXC_TYPE.SYSTEM_EXC)
    assert_equal(orig.stacks_length(), 1)


def test_custom_error_set_exc() raises:
    var err = CustomError()
    err.set_exc("RuntimeError", "something failed", "traceback")
    assert_equal(err.exc_type_name, "RuntimeError")
    assert_equal(err.msg, "something failed")


def test_custom_error_set_exc_preserves_existing_msg() raises:
    var err = CustomError("existing msg")
    err.set_exc("RuntimeError", "new val", "tb")
    assert_equal(err.msg, "existing msg")


def test_custom_error_set_msg() raises:
    var err = CustomError()
    err.set_msg("new message")
    assert_equal(err.msg, "new message")


def test_custom_error_repr_value_truncation() raises:
    var err = CustomError()
    var short = err._repr_value("short")
    assert_equal(short, "short")

    var long_str = "x" * 200
    var truncated = err._repr_value(long_str)
    assert_equal(len(truncated), 164)
    assert_true(string_contains(truncated, " ..."))


def test_custom_error_repr_value_no_truncation() raises:
    var err = CustomError()
    var exact = err._repr_value("x" * 160)
    assert_equal(len(exact), 160)
    assert_false(string_contains(exact, " ..."))


def test_custom_error_add_stack_info() raises:
    var err = CustomError("error")
    err.add_stack_info("file1.mojo", 10, "main", "call()")
    err.add_stack_info("file2.mojo", 20, "helper", "x = 1")
    assert_equal(err.stacks_length(), 2)


def test_custom_error_write_to_no_stacks() raises:
    var err = CustomError("simple error")
    var output = String.write(err)
    assert_true(string_contains(output, "simple error"))


def test_custom_error_write_to_with_stacks() raises:
    var err = CustomError("boom", "RuntimeError")
    err.add_stack_info("test.mojo", 99, "crash", "1/0")
    var output = String.write(err)
    assert_true(string_contains(output, "Traceback"))
    assert_true(string_contains(output, "test.mojo"))
    assert_true(string_contains(output, "99"))
    assert_true(string_contains(output, "crash"))
    assert_true(string_contains(output, "RuntimeError"))
    assert_true(string_contains(output, "boom"))


def test_custom_error_create_static() raises:
    var err = CustomError.create("created error", "OSError", EXC_TYPE.USER_EXC)
    assert_equal(err.msg, "created error")
    assert_equal(err.exc_type_name, "OSError")
    assert_equal(err.error_type, EXC_TYPE.USER_EXC)


def test_custom_exception_from_error() raises:
    var inner = CustomError.create("inner error")
    var exc = CustomException(inner^)
    var output = String.write(exc)
    assert_true(string_contains(output, "inner error"))


def test_custom_exception_from_params() raises:
    var exc = CustomException("direct msg", "CustomExc", EXC_TYPE.SYSTEM_EXC)
    var output = String.write(exc)
    assert_true(string_contains(output, "direct msg"))


def test_custom_exception_create_static() raises:
    var exc = CustomException.create("static exc", "StaticExc")
    var output = String.write(exc)
    assert_true(string_contains(output, "static exc"))


def test_rq_user_error() raises:
    var err = RQUserError.create("user did something wrong")
    assert_equal(err.message, "user did something wrong")
    assert_equal(err.error_type, EXC_TYPE.USER_EXC)
    var output = String.write(err)
    assert_true(string_contains(output, "user did something wrong"))


def test_rq_invalid_argument() raises:
    var err = RQInvalidArgument.create("bad arg: -1")
    assert_equal(err.message, "bad arg: -1")
    var output = String.write(err)
    assert_true(string_contains(output, "RQInvalidArgument"))


def test_rq_type_error() raises:
    var err = RQTypeError.create("expected int, got str")
    assert_equal(err.message, "expected int, got str")
    var output = String.write(err)
    assert_true(string_contains(output, "RQTypeError"))


def test_rq_api_not_supported() raises:
    var err = RQApiNotSupportedError.create("v2 API not available")
    assert_equal(err.message, "v2 API not available")
    var output = String.write(err)
    assert_true(string_contains(output, "RQApiNotSupportedError"))


def test_rq_datac_version_too_low() raises:
    var err = RQDatacVersionTooLow.create("need v3.0, have v1.0")
    assert_equal(err.message, "need v3.0, have v1.0")
    var output = String.write(err)
    assert_true(string_contains(output, "RQDatacVersionTooLow"))


def test_instrument_not_found() raises:
    var err = InstrumentNotFound.create("000001.XSHE")
    var output = String.write(err)
    assert_true(string_contains(output, "InstrumentNotFound"))
    assert_true(string_contains(output, "000001.XSHE"))


def test_environment_not_initialized() raises:
    var err = EnvironmentNotInitialized.create()
    var output = String.write(err)
    assert_true(string_contains(output, "EnvironmentNotInitialized"))
    assert_true(string_contains(output, "not been initialized"))


def test_base_exception_group_single() raises:
    var errs = List[Error]()
    errs.append(Error("first error"))
    var grp = BaseExceptionGroup.create("group msg", errs^)
    var output = String.write(grp)
    assert_true(string_contains(output, "group msg"))
    assert_true(string_contains(output, "1 sub-exception"))


def test_base_exception_group_multiple() raises:
    var errs = List[Error]()
    errs.append(Error("err1"))
    errs.append(Error("err2"))
    errs.append(Error("err3"))
    var grp = BaseExceptionGroup.create("multi group", errs^)
    var output = String.write(grp)
    assert_true(string_contains(output, "multi group"))
    assert_true(string_contains(output, "3 sub-exceptions"))


def test_base_exception_group_empty_message_raises() raises:
    var errs = List[Error]()
    errs.append(Error("e"))
    var raised = False
    try:
        _ = BaseExceptionGroup.create("", errs^)
    except e:
        raised = True
        assert_true(string_contains(String(e), "message must be a string"))
    assert_true(raised)


def test_base_exception_group_empty_exceptions_raises() raises:
    var raised = False
    try:
        _ = BaseExceptionGroup.create("msg", List[Error]())
    except e:
        raised = True
        assert_true(string_contains(String(e), "non-empty sequence"))
    assert_true(raised)


def test_base_exception_group_derive_empty_raises() raises:
    var errs = List[Error]()
    errs.append(Error("orig"))
    var grp = BaseExceptionGroup.create("original", errs^)
    var raised = False
    try:
        _ = grp.derive(List[Error]())
    except e:
        raised = True
    assert_true(raised)


def test_base_exception_group_derive_nonempty() raises:
    var errs = List[Error]()
    errs.append(Error("orig"))
    var grp = BaseExceptionGroup.create("original", errs^)
    var new_errs = List[Error]()
    new_errs.append(Error("derived err"))
    var derived = grp.derive(new_errs^)
    var output = String.write(derived)
    assert_true(string_contains(output, "original"))


def test_base_exception_group_subgroup_all_match() raises:
    var errs = List[Error]()
    errs.append(Error("type error"))
    errs.append(Error("value error"))
    var grp = BaseExceptionGroup.create("errors", errs^)

    def always_match(e: Error) -> Bool:
        return True

    var result = grp.subgroup(always_match)
    assert_true(result)


def test_base_exception_group_subgroup_none_match() raises:
    var errs = List[Error]()
    errs.append(Error("err1"))
    errs.append(Error("err2"))
    var grp = BaseExceptionGroup.create("errors", errs^)

    def never_match(e: Error) -> Bool:
        return False

    var result = grp.subgroup(never_match)
    assert_false(result)


def test_base_exception_group_subgroup_partial() raises:
    var errs = List[Error]()
    errs.append(Error("match me"))
    errs.append(Error("skip this"))
    var grp = BaseExceptionGroup.create("mixed", errs^)

    def match_first(e: Error) -> Bool:
        return string_contains(String(e), "match")

    var result = grp.subgroup(match_first)
    assert_true(result)


def test_exception_group_construction() raises:
    var errs = List[Error]()
    errs.append(Error("eg error"))
    var eg = ExceptionGroup.create("eg message", errs^)
    var output = String.write(eg)
    assert_true(string_contains(output, "eg message"))


def test_exception_group_from_inner() raises:
    var errs = List[Error]()
    errs.append(Error("inner err"))
    var inner = BaseExceptionGroup.create("inner msg", errs^)
    var eg = ExceptionGroup(inner^)
    var output = String.write(eg)
    assert_true(string_contains(output, "inner msg"))


def test_exception_group_derive() raises:
    var errs = List[Error]()
    errs.append(Error("base"))
    var eg = ExceptionGroup.create("base msg", errs^)
    var new_errs = List[Error]()
    new_errs.append(Error("derived"))
    var derived = eg.derive(new_errs^)
    var output = String.write(derived)
    assert_true(string_contains(output, "base msg"))


def test_exception_group_subgroup() raises:
    var errs = List[Error]()
    errs.append(Error("keep"))
    errs.append(Error("drop"))
    var eg = ExceptionGroup.create("filter test", errs^)

    def keep_fn(e: Error) -> Bool:
        return string_contains(String(e), "keep")

    var result = eg.subgroup(keep_fn)
    assert_true(result)


def test_format_exception_group_single() raises:
    var errs = List[Error]()
    errs.append(Error("only error"))
    var grp = BaseExceptionGroup.create("single", errs^)
    var formatted = format_exception_group(grp, "", "TestGroup")
    assert_true(string_contains(formatted, "TestGroup: single"))
    assert_true(string_contains(formatted, "only error"))
    assert_true(string_contains(formatted, "└─ "))


def test_format_exception_group_multiple() raises:
    var errs = List[Error]()
    errs.append(Error("err1"))
    errs.append(Error("err2"))
    var grp = BaseExceptionGroup.create("multiple", errs^)
    var formatted = format_exception_group(grp, "  ", "MyGroup")
    assert_true(string_contains(formatted, "MyGroup: multiple"))
    assert_true(string_contains(formatted, "├─ "))
    assert_true(string_contains(formatted, "└─ "))


def test_format_exception_group_indent() raises:
    var errs = List[Error]()
    errs.append(Error("indented"))
    var grp = BaseExceptionGroup.create("indented test", errs^)
    var formatted = format_exception_group(grp, "    ", "IndentedGroup")
    assert_true(string_contains(formatted, "    IndentedGroup"))


def test_patch_user_exc_notset() raises:
    assert_equal(patch_user_exc(EXC_TYPE.NOTSET), EXC_TYPE.USER_EXC)


def test_patch_user_exc_force() raises:
    assert_equal(patch_user_exc(EXC_TYPE.SYSTEM_EXC, force=True), EXC_TYPE.USER_EXC)


def test_patch_user_exc_preserves() raises:
    assert_equal(patch_user_exc(EXC_TYPE.USER_EXC), EXC_TYPE.USER_EXC)


def test_patch_system_exc_notset() raises:
    assert_equal(patch_system_exc(EXC_TYPE.NOTSET), EXC_TYPE.SYSTEM_EXC)


def test_patch_system_exc_force() raises:
    assert_equal(patch_system_exc(EXC_TYPE.USER_EXC, force=True), EXC_TYPE.SYSTEM_EXC)


def test_patch_system_exc_preserves() raises:
    assert_equal(patch_system_exc(EXC_TYPE.SYSTEM_EXC), EXC_TYPE.SYSTEM_EXC)


def test_get_exc_from_type_identity() raises:
    assert_equal(get_exc_from_type(EXC_TYPE.NOTSET), EXC_TYPE.NOTSET)
    assert_equal(get_exc_from_type(EXC_TYPE.USER_EXC), EXC_TYPE.USER_EXC)
    assert_equal(get_exc_from_type(EXC_TYPE.SYSTEM_EXC), EXC_TYPE.SYSTEM_EXC)


def test_is_user_exc() raises:
    assert_true(is_user_exc(EXC_TYPE.USER_EXC))
    assert_false(is_user_exc(EXC_TYPE.SYSTEM_EXC))
    assert_false(is_user_exc(EXC_TYPE.NOTSET))


def test_is_system_exc() raises:
    assert_true(is_system_exc(EXC_TYPE.SYSTEM_EXC))
    assert_false(is_system_exc(EXC_TYPE.USER_EXC))
    assert_false(is_system_exc(EXC_TYPE.NOTSET))


def test_modify_exception_from_type_create() raises:
    var mod = ModifyExceptionFromType.create(EXC_TYPE.USER_EXC)
    assert_equal(mod.exc_from_type, EXC_TYPE.USER_EXC)
    assert_equal(mod.force, False)
    assert_true(mod._active)


def test_modify_exception_from_type_enter() raises:
    var mod = ModifyExceptionFromType.create(EXC_TYPE.SYSTEM_EXC)
    var entered = mod.__enter__()
    assert_true(entered._active)


def test_modify_should_patch_active_notset() raises:
    var mod = ModifyExceptionFromType.create(EXC_TYPE.USER_EXC)
    var result = mod.should_patch(EXC_TYPE.NOTSET)
    assert_true(result)
    if result:
        assert_equal(result.value(), EXC_TYPE.USER_EXC)


def test_modify_should_patch_active_force() raises:
    var mod = ModifyExceptionFromType.create(EXC_TYPE.SYSTEM_EXC, force=True)
    var result = mod.should_patch(EXC_TYPE.USER_EXC)
    assert_true(result)
    if result:
        assert_equal(result.value(), EXC_TYPE.SYSTEM_EXC)


def test_modify_should_patch_no_override() raises:
    var mod = ModifyExceptionFromType.create(EXC_TYPE.USER_EXC)
    var result = mod.should_patch(EXC_TYPE.SYSTEM_EXC)
    assert_false(result)


def test_modify_should_patch_inactive() raises:
    var mod = ModifyExceptionFromType.create(EXC_TYPE.USER_EXC)
    mod._active = False
    var result = mod.should_patch(EXC_TYPE.NOTSET)
    assert_false(result)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
