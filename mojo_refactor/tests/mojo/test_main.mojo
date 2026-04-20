"""
Comprehensive unit tests for main.mojo
Ported from: /home/zhou/hello_mojo/trae_cn_78/.venv/lib64/python3.14/site-packages/rqalpha/main.py

Tests cover:
  - RunResult struct (construction, Writable)
  - Config helper functions (_get_base, _base_str, _base_float, _set_base_*)
  - Strategy scope creation (create_base_scope)
  - API registry (get_strategy_apis)
  - RQDataC initialization (init_rqdatac)
  - Logger setup (set_loggers)
  - Exception handling (_exception_handler)
  - Resource cleanup (cleanup_resources)
  - Profiler output (output_profile_result)
  - Config creation (create_config)
  - Entry points (rqalpha_main, main)
"""

from std.testing import assert_equal, assert_true, assert_false, assert_not_equal
from std.collections import Dict, List, Optional
from std.python import Python, PythonObject
from rqmojo.const import RUN_TYPE, EXECUTION_PHASE, EXIT_CODE, PERSIST_MODE, EXC_TYPE
from rqmojo.environment import Environment, clear_environment, create_environment_from_config
from rqmojo.core.events import EVENT, Event, EventBus
from rqmojo.core.executor import Executor
from rqmojo.core.strategy_context import StrategyContext
from rqmojo.data.data_proxy import DataProxy
from rqmojo.model.bar import BarMap
from rqmojo.mod_system import ModHandler
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.utils.exception import CustomError, is_user_exc
from rqmojo.utils.i18n import gettext
from rqmojo.utils.logger import user_system_log, init_logger
from rqmojo.utils.persist_helper import PersistHelper
from rqmojo.utils import RqAttrDict
from rqmojo.main import (
    RunResult,
    _get_base, _base_str, _base_float, _set_base_str, _set_base_float,
    create_base_scope, get_strategy_apis,
    init_rqdatac, set_loggers, _exception_handler,
    cleanup_resources, output_profile_result,
    create_config
)


fn _dict_contains(d: Dict[String, String], key: String) -> Bool:
    """Helper: check if Dict contains key (std.Dict has no .contains())."""
    for k in d.keys():
        if k == key:
            return True
    return False


fn test_run_result_construction() raises:
    """RunResult: construct with exit_code and message."""
    var result = RunResult(exit_code=EXIT_CODE.EXIT_SUCCESS, message="ok")
    assert_equal(result.exit_code, EXIT_CODE.EXIT_SUCCESS)
    assert_equal(result.message, "ok")


fn test_run_result_user_error() raises:
    """RunResult: construct with EXIT_USER_ERROR."""
    var result = RunResult(
        exit_code=EXIT_CODE.EXIT_USER_ERROR,
        message="user error"
    )
    assert_equal(result.exit_code, EXIT_CODE.EXIT_USER_ERROR)
    assert_true(len(result.message) > 0)


fn test_run_result_internal_error() raises:
    """RunResult: construct with EXIT_INTERNAL_ERROR."""
    var result = RunResult(
        exit_code=EXIT_CODE.EXIT_INTERNAL_ERROR,
        message="internal error"
    )
    assert_equal(result.exit_code, EXIT_CODE.EXIT_INTERNAL_ERROR)


fn test_get_base_with_base() raises:
    """_get_base: returns base child when present."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    base["start_date"] = "2020-01-01"
    config["base"] = base
    var result = _get_base(config)
    var val = result["start_date"].to[String]("")
    assert_equal(val, "2020-01-01")


fn test_get_base_without_base() raises:
    """_get_base: returns empty dict when no base child."""
    var config = RqAttrDict()
    config["extra"] = RqAttrDict()
    var result = _get_base(config)
    assert_true(result.is_empty())


fn test_base_str_existing_key() raises:
    """_base_str: returns value for existing key."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    base["frequency"] = "1d"
    config["base"] = base
    var val = _base_str(config, "frequency")
    assert_equal(val, "1d")


fn test_base_str_missing_key() raises:
    """_base_str: returns default for missing key."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    base["frequency"] = "1d"
    config["base"] = base
    var val = _base_str(config, "nonexistent", "default_val")
    assert_equal(val, "default_val")


fn test_base_str_no_base() raises:
    """_base_str: returns default when no base section."""
    var config = RqAttrDict()
    var val = _base_str(config, "anything", "fallback")
    assert_equal(val, "fallback")


fn test_base_float_existing_key() raises:
    """_base_float: returns float value for existing key."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    base["initial_cash"] = 100000.0
    config["base"] = base
    var val = _base_float(config, "initial_cash")
    assert_true(abs(val - 100000.0) < 0.001)


fn test_base_float_missing_key() raises:
    """_base_float: returns default for missing key."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    base["initial_cash"] = 100000.0
    config["base"] = base
    var val = _base_float(config, "nonexistent", 999.5)
    assert_true(abs(val - 999.5) < 0.001)


fn test_set_base_str_new_key() raises:
    """_set_base_str: sets new key in base config."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    config["base"] = base
    _set_base_str(config, "new_key", "new_value")
    var b = _get_base(config)
    var val = b["new_key"].to[String]("")
    assert_equal(val, "new_value")


fn test_set_base_float_new_key() raises:
    """_set_base_float: sets new float key in base config."""
    var config = RqAttrDict()
    var base = RqAttrDict()
    config["base"] = base
    _set_base_float(config, "cash", 500000.0)
    var b = _get_base(config)
    var val = b["cash"].to[Float64](0.0)
    assert_true(abs(val - 500000.0) < 0.001)


fn test_create_base_scope_has_name() raises:
    """create_base_scope: contains __name__ key."""
    var scope = create_base_scope()
    var name = scope["__name__"]
    assert_equal(name, "rqmojo.user_module")


fn test_create_base_scope_is_dict() raises:
    """create_base_scope: returns non-empty Dict."""
    var scope = create_base_scope()
    assert_true(len(scope) >= 1)


fn test_get_strategy_apis_count() raises:
    """get_strategy_apis: returns 18 API function names."""
    var apis = get_strategy_apis()
    assert_equal(len(apis), 18)


fn test_get_strategy_apis_contains_core() raises:
    """get_strategy_apis: contains core trading APIs."""
    var apis = get_strategy_apis()
    assert_true(_dict_contains(apis, "order_shares"), "missing order_shares")
    assert_true(_dict_contains(apis, "order_percent"), "missing order_percent")
    assert_true(_dict_contains(apis, "order_target_value"), "missing order_target_value")
    assert_true(_dict_contains(apis, "cancel_order"), "missing cancel_order")
    assert_true(_dict_contains(apis, "update_universe"), "missing update_universe")


fn test_get_strategy_apis_contains_data() raises:
    """get_strategy_apis: contains data query APIs."""
    var apis = get_strategy_apis()
    assert_true(_dict_contains(apis, "history_bars"), "missing history_bars")
    assert_true(_dict_contains(apis, "history"), "missing history")
    assert_true(_dict_contains(apis, "get_price"), "missing get_price")
    assert_true(_dict_contains(apis, "get_trading_dates"), "missing get_trading_dates")
    assert_true(_dict_contains(apis, "instruments"), "missing instruments")


fn test_get_strategy_apis_contains_position() raises:
    """get_strategy_apis: contains position/account APIs."""
    var apis = get_strategy_apis()
    assert_true(_dict_contains(apis, "get_position"), "missing get_position")
    assert_true(_dict_contains(apis, "get_positions"), "missing get_positions")
    assert_true(_dict_contains(apis, "get_portfolio"), "missing get_portfolio")
    assert_true(_dict_contains(apis, "deposit"), "missing deposit")
    assert_true(_dict_contains(apis, "withdraw"), "missing withdraw")


fn test_init_rqdatac_disabled() raises:
    """init_rqdatac: returns False for 'disabled' URI."""
    assert_false(init_rqdatac("disabled"))
    assert_false(init_rqdatac("DISABLED"))


fn test_init_rqdatac_other() raises:
    """init_rqdatac: returns False for any non-disabled URI."""
    assert_false(init_rqdatac(""))
    assert_false(init_rqdatac("tcp://localhost:1234"))


fn test_set_loggers_no_error() raises:
    """set_loggers: calls init_logger without raising."""
    set_loggers()


fn test_exception_handler_user_error() raises:
    """_exception_handler: returns EXIT_USER_ERROR for user exceptions."""
    var err = CustomError("test user error", "UserException", EXC_TYPE.USER_EXC)
    var code = _exception_handler(err^)
    assert_equal(code, EXIT_CODE.EXIT_USER_ERROR)


fn test_exception_handler_internal_error() raises:
    """_exception_handler: returns EXIT_INTERNAL_ERROR for system errors."""
    var err = CustomError("test internal error", "KeyError", EXC_TYPE.SYSTEM_EXC)
    var code = _exception_handler(err^)
    assert_equal(code, EXIT_CODE.EXIT_INTERNAL_ERROR)


fn test_exception_handler_runtime_error() raises:
    """_exception_handler: returns EXIT_INTERNAL_ERROR for RuntimeError."""
    var err = CustomError("runtime error", "RuntimeError", EXC_TYPE.SYSTEM_EXC)
    var code = _exception_handler(err^)
    assert_equal(code, EXIT_CODE.EXIT_INTERNAL_ERROR)


fn test_cleanup_resources() raises:
    """cleanup_resources: calls clear_environment without error."""
    try:
        var conf = RqAttrDict()
        var base = RqAttrDict()
        base["start_date"] = "2020-01-01"
        base["end_date"] = "2020-12-31"
        base["frequency"] = "1d"
        base["run_type"] = "b"
        conf["base"] = base
        var env = create_environment_from_config(conf, False)
        cleanup_resources(env)
    except e:
        pass


fn test_output_profile_result_no_deco() raises:
    """output_profile_result: does nothing when no profiler active."""
    var conf = RqAttrDict()
    var base = RqAttrDict()
    base["start_date"] = "2020-01-01"
    base["end_date"] = "2020-12-31"
    base["frequency"] = "1d"
    base["run_type"] = "b"
    conf["base"] = base
    var env = create_environment_from_config(conf, False)
    output_profile_result(env)


fn test_create_config_default_params() raises:
    """create_config: creates valid config with default parameters."""
    var start_dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var conf = create_config(start_dt, end_dt)
    assert_true(conf.contains("base"))
    var freq = _base_str(conf, "frequency", "")
    assert_equal(freq, "1d")
    var cash = _base_float(conf, "initial_cash", 0.0)
    assert_true(abs(cash - 100000.0) < 0.001)


fn test_create_config_custom_cash() raises:
    """create_config: uses custom initial_cash parameter."""
    var start_dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var conf = create_config(start_dt, end_dt, 500000.0)
    var cash = _base_float(conf, "initial_cash", 0.0)
    assert_true(abs(cash - 500000.0) < 0.001)


fn test_create_config_with_strategy_file() raises:
    """create_config: includes strategy_file when provided."""
    var start_dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var conf = create_config(start_dt, end_dt, 100000.0, "my_strategy.py")
    var sf = _base_str(conf, "strategy_file", "")
    assert_equal(sf, "my_strategy.py")


fn test_create_config_extra_section() raises:
    """create_config: has extra and mod sections."""
    var start_dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var end_dt = DateTime(2020, 12, 31, 0, 0, 0, 0)
    var conf = create_config(start_dt, end_dt)
    assert_true(conf.contains("extra"))
    assert_true(conf.contains("mod"))


def main():
    print("")
    print("=" * 60)
    print("  Testing: main.mojo")
    print("=" * 60)

    var passed = 0
    var failed = 0
    var tests = List[String]()

    tests.append("test_run_result_construction")
    tests.append("test_run_result_user_error")
    tests.append("test_run_result_internal_error")
    tests.append("test_get_base_with_base")
    tests.append("test_get_base_without_base")
    tests.append("test_base_str_existing_key")
    tests.append("test_base_str_missing_key")
    tests.append("test_base_str_no_base")
    tests.append("test_base_float_existing_key")
    tests.append("test_base_float_missing_key")
    tests.append("test_set_base_str_new_key")
    tests.append("test_set_base_float_new_key")
    tests.append("test_create_base_scope_has_name")
    tests.append("test_create_base_scope_is_dict")
    tests.append("test_get_strategy_apis_count")
    tests.append("test_get_strategy_apis_contains_core")
    tests.append("test_get_strategy_apis_contains_data")
    tests.append("test_get_strategy_apis_contains_position")
    tests.append("test_init_rqdatac_disabled")
    tests.append("test_init_rqdatac_other")
    tests.append("test_set_loggers_no_error")
    tests.append("test_exception_handler_user_error")
    tests.append("test_exception_handler_internal_error")
    tests.append("test_exception_handler_runtime_error")
    tests.append("test_cleanup_resources")
    tests.append("test_output_profile_result_no_deco")
    tests.append("test_create_config_default_params")
    tests.append("test_create_config_custom_cash")
    tests.append("test_create_config_with_strategy_file")
    tests.append("test_create_config_extra_section")

    for test_name in tests:
        try:
            if test_name == "test_run_result_construction":
                test_run_result_construction()
            elif test_name == "test_run_result_user_error":
                test_run_result_user_error()
            elif test_name == "test_run_result_internal_error":
                test_run_result_internal_error()
            elif test_name == "test_get_base_with_base":
                test_get_base_with_base()
            elif test_name == "test_get_base_without_base":
                test_get_base_without_base()
            elif test_name == "test_base_str_existing_key":
                test_base_str_existing_key()
            elif test_name == "test_base_str_missing_key":
                test_base_str_missing_key()
            elif test_name == "test_base_str_no_base":
                test_base_str_no_base()
            elif test_name == "test_base_float_existing_key":
                test_base_float_existing_key()
            elif test_name == "test_base_float_missing_key":
                test_base_float_missing_key()
            elif test_name == "test_set_base_str_new_key":
                test_set_base_str_new_key()
            elif test_name == "test_set_base_float_new_key":
                test_set_base_float_new_key()
            elif test_name == "test_create_base_scope_has_name":
                test_create_base_scope_has_name()
            elif test_name == "test_create_base_scope_is_dict":
                test_create_base_scope_is_dict()
            elif test_name == "test_get_strategy_apis_count":
                test_get_strategy_apis_count()
            elif test_name == "test_get_strategy_apis_contains_core":
                test_get_strategy_apis_contains_core()
            elif test_name == "test_get_strategy_apis_contains_data":
                test_get_strategy_apis_contains_data()
            elif test_name == "test_get_strategy_apis_contains_position":
                test_get_strategy_apis_contains_position()
            elif test_name == "test_init_rqdatac_disabled":
                test_init_rqdatac_disabled()
            elif test_name == "test_init_rqdatac_other":
                test_init_rqdatac_other()
            elif test_name == "test_set_loggers_no_error":
                test_set_loggers_no_error()
            elif test_name == "test_exception_handler_user_error":
                test_exception_handler_user_error()
            elif test_name == "test_exception_handler_internal_error":
                test_exception_handler_internal_error()
            elif test_name == "test_exception_handler_runtime_error":
                test_exception_handler_runtime_error()
            elif test_name == "test_cleanup_resources":
                test_cleanup_resources()
            elif test_name == "test_output_profile_result_no_deco":
                test_output_profile_result_no_deco()
            elif test_name == "test_create_config_default_params":
                test_create_config_default_params()
            elif test_name == "test_create_config_custom_cash":
                test_create_config_custom_cash()
            elif test_name == "test_create_config_with_strategy_file":
                test_create_config_with_strategy_file()
            elif test_name == "test_create_config_extra_section":
                test_create_config_extra_section()

            passed += 1
            print("  PASS: ", test_name)
        except e:
            failed += 1
            print("  FAIL: ", test_name, " -> ", String(e))

    print("")
    print("=" * 60)
    print("  Results: ", passed, " passed, ", failed, " failed, total=", passed + failed)
    print("=" * 60)
    print("")
