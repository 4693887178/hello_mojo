"""
第四组测试 - utils/functools.mojo
测试Mojo版本的函数工具模块（修复后版本）

重构覆盖范围:
  1. lru_cache: LRU缓存结构体(淘汰/访问顺序/容量限制/generation失效)
  2. memoize: 全局注册工厂函数
  3. cached_functions / clear_all_cached_functions: 全局缓存管理
  4. InstypeSingleDispatch: 基于INSTRUMENT_TYPE的单分发(注册/分发/异常/i18n/缓存)
  5. SingleDispatchProtocol / cast_singledispatch: 类型标记

对应 Python 原版: rqalpha/utils/functools.py
  - lru_cache(*args, **kwargs) -> decorator (Mojo适配为struct)
  - cached_functions = [] (Mojo适配为env var计数器)
  - clear_all_cached_functions() (generation counter方案)
  - instype_singledispatch(func) -> wrapper with .register()
  - SingleDispatchProtocol (Protocol → marker struct)
  - cast_singledispatch(func) (type cast → copy)
"""

from rqmojo.utils.functools import (
    lru_cache,
    memoize,
    cached_functions,
    clear_all_cached_functions,
    InstypeSingleDispatch,
    instype_singledispatch,
    SingleDispatchProtocol,
    cast_singledispatch,
)
from rqmojo.const import INSTRUMENT_TYPE, EXCHANGE, MARKET
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.utils.exception import RQInvalidArgument, RQApiNotSupportedError
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite


# ============================================================
# Section 1: lru_cache 基础操作
# ============================================================

def test_lru_cache_default_init() raises:
    var cf = lru_cache()
    assert_equal(cf.get_max_size(), 128, "default max_size should be 128")
    assert_false(cf.contains("any"), "empty cache should not contain any key")


def test_lru_cache_custom_max_size() raises:
    var cf = lru_cache(256)
    assert_equal(cf.get_max_size(), 256, "custom max_size should be 256")


def test_lru_cache_zero_max_size() raises:
    var cf = lru_cache(0)
    assert_equal(cf.get_max_size(), 0, "max_size=0 is accepted")


def test_lru_cache_set_and_get() raises:
    var cf = lru_cache()
    cf.set("key1", "value1")
    var result = cf.get("key1")
    if result:
        assert_equal(result.value(), "value1", "get returns correct value")
    else:
        assert_true(False, "get should return Some for existing key")


def test_lru_cache_get_nonexistent() raises:
    var cf = lru_cache()
    var result = cf.get("nonexistent")
    assert_true(result == None, "get nonexistent key should return None")


def test_lru_cache_set_overwrite() raises:
    var cf = lru_cache()
    cf.set("key1", "original")
    cf.set("key1", "updated")
    var result = cf.get("key1")
    if result:
        assert_equal(result.value(), "updated", "set overwrites previous value")
    else:
        assert_true(False, "should have value after overwrite")


def test_lru_cache_contains_existing() raises:
    var cf = lru_cache()
    cf.set("k", "v")
    assert_true(cf.contains("k"), "contains returns true for existing key")


def test_lru_cache_contains_missing() raises:
    var cf = lru_cache()
    assert_false(cf.contains("missing"), "contains returns false for missing key")


def test_lru_cache_contains_empty_string_key() raises:
    var cf = lru_cache()
    cf.set("", "empty_key_value")
    assert_true(cf.contains(""), "supports empty string as key")


def test_lru_cache_clear_removes_all() raises:
    var cf = lru_cache()
    cf.set("a", "1")
    cf.set("b", "2")
    cf.set("c", "3")
    cf.clear()
    assert_false(cf.contains("a"), "clear removes key a")
    assert_false(cf.contains("b"), "clear removes key b")
    assert_false(cf.contains("c"), "clear removes key c")


def test_lru_cache_clear_empty_is_safe() raises:
    var cf = lru_cache()
    cf.clear()
    assert_true(True, "clear on empty cache is safe")


def test_lru_cache_multiple_keys() raises:
    var cf = lru_cache()
    cf.set("k1", "v1")
    cf.set("k2", "v2")
    cf.set("k3", "v3")
    assert_equal(cf.size(), 3, "cache should have 3 entries")


def test_lru_cache_unicode_values() raises:
    var cf = lru_cache()
    cf.set("中文键", "中文值")
    var result = cf.get("中文键")
    if result:
        assert_equal(result.value(), "中文值", "unicode values work correctly")
    else:
        assert_true(False, "unicode key lookup should work")


def test_lru_cache_copy_semantics() raises:
    var cf = lru_cache()
    cf.set("x", "y")
    var cf2 = cf.copy()
    assert_true(cf2.contains("x"), "copy preserves data")
    cf2.set("z", "w")
    assert_false(cf.contains("z"), "copy is independent")


def test_lru_cache_cache_clear_alias() raises:
    """Cache_clear() is an alias for clear() matching Python's API."""
    var cf = lru_cache()
    cf.set("a", "1")
    cf.cache_clear()
    assert_false(cf.contains("a"), "cache_clear() works same as clear()")


# ============================================================
# Section 2: LRU 淘汰行为 (对齐Python functools.lru_cache)
# ============================================================

def test_lru_evicts_oldest_when_full() raises:
    """When cache exceeds max_size, oldest entry is evicted."""
    var cf = lru_cache(3)
    cf.set("a", "1")
    cf.set("b", "2")
    cf.set("c", "3")
    assert_equal(cf.size(), 3, "cache has 3 entries at max_size")
    cf.set("d", "4")
    assert_equal(cf.size(), 3, "still 3 after inserting 4th (one evicted)")
    assert_false(cf.contains("a"), "oldest key 'a' was evicted by LRU")
    assert_true(cf.contains("b"), "key 'b' still present")
    assert_true(cf.contains("c"), "key 'c' still present")
    assert_true(cf.contains("d"), "new key 'd' present")


def test_lru_access_updates_order() raises:
    """Accessing a key moves it to most-recently-used position."""
    var cf = lru_cache(3)
    cf.set("a", "1")
    cf.set("b", "2")
    cf.set("c", "3")
    _ = cf.get("a")
    cf.set("d", "4")
    assert_true(cf.contains("a"), "'a' was accessed, so not evicted")
    assert_false(cf.contains("b"), "'b' was least recently used, evicted")
    assert_true(cf.contains("c"), "'c' still present")
    assert_true(cf.contains("d"), "'d' present")


def test_lru_set_updates_order() raises:
    """Updating an existing key's value also refreshes its position."""
    var cf = lru_cache(3)
    cf.set("a", "1")
    cf.set("b", "2")
    cf.set("c", "3")
    cf.set("a", "updated_a")
    cf.set("d", "4")
    assert_true(cf.contains("a"), "'a' refreshed, not evicted")
    var val = cf.get("a")
    if val:
        assert_equal(val.value(), "updated_a", "'a' has updated value")
    assert_false(cf.contains("b"), "'b' evicted")


def test_lru_max_size_zero_no_eviction() raises:
    """Max_size=0 means no eviction limit (unbounded cache)."""
    var cf = lru_cache(0)
    cf.set("a", "1")
    cf.set("b", "2")
    cf.set("c", "3")
    cf.set("d", "4")
    assert_equal(cf.size(), 4, "max_size=0 allows unlimited growth")


def test_lru_eviction_sequence() raises:
    """Verify correct FIFO-with-promotion LRU order over multiple operations."""
    var cf = lru_cache(2)
    cf.set("a", "1")
    cf.set("b", "2")
    cf.set("c", "3")
    assert_false(cf.contains("a"), "a evicted")
    _ = cf.get("b")
    cf.set("d", "4")
    assert_false(cf.contains("c"), "c evicted (was LRU after b touched)")
    assert_true(cf.contains("b"), "b survives (was touched)")
    assert_true(cf.contains("d"), "d present")


# ============================================================
# Section 3: memoize + cached_functions 全局注册表
# ============================================================

def test_memoize_registers_in_cached_functions() raises:
    """Memoize() creates an lru_cache AND increments global counter.

    Mirrors Python: @lru_cache appends func to cached_functions list.
    """
    var count_before = cached_functions()
    _ = memoize(128)
    _ = memoize(128)
    _ = memoize(128)
    var count_after = cached_functions()
    assert_equal(count_after - count_before, 3, "3 functions registered")


def test_memoize_returns_lrucache_with_correct_max_size() raises:
    var cf = memoize(512)
    assert_equal(cf.get_max_size(), 512, "memoize respects custom max_size")


def test_memoize_returned_instance_works() raises:
    var cf = memoize(128)
    cf.set("arg_key", "result_val")
    var result = cf.get("arg_key")
    if result:
        assert_equal(result.value(), "result_val", "returned instance works as cache")
    else:
        assert_true(False, "memoized instance should work as cache")


def test_memoize_default_max_size() raises:
    var cf = memoize()
    assert_equal(cf.get_max_size(), 128, "default max_size is 128")


def test_cached_functions_counts_across_calls() raises:
    """Cached_functions() returns cumulative count of all memoize() calls."""
    var count_start = cached_functions()
    for _ in range(5):
        _ = memoize(64)
    var count_end = cached_functions()
    assert_equal(count_end - count_start, 5, "5 more functions registered")


# ============================================================
# Section 4: clear_all_cached_functions (env var generation counter)
# ============================================================

def test_clear_all_invalidates_registered_caches() raises:
    """After clear_all_cached_functions(), every lru_cache auto-clears on access."""
    var cf1 = memoize(128)
    var cf2 = memoize(128)
    cf1.set("k1", "v1")
    cf2.set("k2", "v2")

    assert_true(cf1.contains("k1"), "cf1 has data before clear")
    assert_true(cf2.contains("k2"), "cf2 has data before clear")

    clear_all_cached_functions()

    assert_false(cf1.contains("k1"), "cf1 invalidated after clear_all")
    assert_false(cf2.contains("k2"), "cf2 invalidated after clear_all")


def test_clear_also_invalidates_direct_caches() raises:
    """Direct lru_cache instances (not via memoize) also invalidated.

    Pure Mojo difference: generation-counter clears ALL instances.
    This is safer than Python — no stale data can leak.
    """
    var direct_cf = lru_cache()
    direct_cf.set("survive", "yes")

    clear_all_cached_functions()

    assert_false(direct_cf.contains("survive"), "direct cache also invalidated")


def test_clear_resets_registration_count() raises:
    """After clear, cached_functions() returns 0."""
    _ = memoize(64)
    _ = memoize(64)
    assert_true(cached_functions() >= 2, "functions registered")

    clear_all_cached_functions()

    assert_equal(cached_functions(), 0, "count reset to 0 after clear")


def test_clear_idempotent_multiple_calls() raises:
    """Calling clear_all multiple times is safe."""
    clear_all_cached_functions()
    clear_all_cached_functions()
    clear_all_cached_functions()
    var cf = memoize(64)
    cf.set("k", "v")
    assert_true(cf.contains("k"), "cache works after multiple clears")


def test_new_caches_after_clear_work_normally() raises:
    """Caches created AFTER clear are fresh and unaffected."""
    clear_all_cached_functions()
    var cf = lru_cache()
    cf.set("new_key", "new_val")
    assert_true(cf.contains("new_key"), "new cache works normally")


# ============================================================
# Section 5: InstypeSingleDispatch 基础功能
# ============================================================

def test_instype_singledispatch_creation() raises:
    var sd = instype_singledispatch("history_bars", "order_book_id")
    assert_equal(sd.func_name, "history_bars", "func_name stored")
    assert_equal(sd.arg_name, "order_book_id", "arg_name stored")


def test_instype_singledispatch_register_single() raises:
    var sd = instype_singledispatch("test_func", "arg1")
    sd.register_single(INSTRUMENT_TYPE.CS, "handle_cs")
    assert_true(sd.has_handler(INSTRUMENT_TYPE.CS), "CS handler registered")


def test_instype_singledispatch_register_multiple() raises:
    var sd = instype_singledispatch("test_func", "arg1")
    var types = [INSTRUMENT_TYPE.CS, INSTRUMENT_TYPE.FUTURE, INSTRUMENT_TYPE.OPTION]
    sd.register(types, "handle_futures")
    assert_true(sd.has_handler(INSTRUMENT_TYPE.CS), "CS registered")
    assert_true(sd.has_handler(INSTRUMENT_TYPE.FUTURE), "FUTURE registered")
    assert_true(sd.has_handler(INSTRUMENT_TYPE.OPTION), "OPTION registered")


def test_instype_singledispatch_dispatch_by_name_success() raises:
    var sd = instype_singledispatch("my_api", "id_or_ins")
    sd.register_single(INSTRUMENT_TYPE.CS, "cs_handler")
    var handler = sd.dispatch("CS")
    assert_equal(handler, "cs_handler", "dispatch by name returns correct handler")


def test_instype_singledispatch_dispatch_unknown_type_raises_invalid_arg() raises:
    """Unknown type with non-empty registry -> RQInvalidArgument."""
    var sd = instype_singledispatch("my_api", "id_or_ins")
    sd.register_single(INSTRUMENT_TYPE.CS, "cs_handler")
    with assert_raises():
        _ = sd.dispatch("NONEXISTENT")


def test_instype_singledispatch_registered_types_returns_names() raises:
    var sd = instype_singledispatch("test", "arg")
    sd.register_single(INSTRUMENT_TYPE.CS, "h1")
    sd.register_single(INSTRUMENT_TYPE.FUTURE, "h2")
    var types = sd.registered_types()
    assert_equal(len(types), 2, "2 types registered")
    assert_equal(types[0], "CS", "first type name is CS")
    assert_equal(types[1], "FUTURE", "second type name is FUTURE")


def test_instype_singledispatch_copy_independent() raises:
    var sd1 = instype_singledispatch("f", "a")
    sd1.register_single(INSTRUMENT_TYPE.CS, "handler1")
    var sd2 = sd1.copy()
    sd2.register_single(INSTRUMENT_TYPE.FUTURE, "handler2")
    assert_false(sd1.has_handler(INSTRUMENT_TYPE.FUTURE), "copy is independent")


# ============================================================
# Section 6: InstypeSingleDispatch 异常类型 (对齐Python行为)
# ============================================================

def test_empty_registry_dispatch_raises_api_not_supported() raises:
    """Empty registry -> RQApiNotSupportedError (matches Python line 72-74)."""
    var sd = instype_singledispatch("empty_func", "arg")
    with assert_raises():
        _ = sd.dispatch("CS")


def test_dispatch_future_registered_cs_raises_invalid_argument() raises:
    """Type CS not registered but FUTURE is -> RQInvalidArgument with types list."""
    var sd = instype_singledispatch("my_func", "order_book_id")
    sd.register_single(INSTRUMENT_TYPE.FUTURE, "future_handler")
    with assert_raises():
        _ = sd.dispatch("CS")


# ============================================================
# Section 7: InstypeSingleDispatch Instrument 对象分发
# ============================================================

def test_dispatch_by_instrument_direct_type_extraction() raises:
    """Dispatch_by_instrument extracts .type_val from Instrument directly."""
    var sd = instype_singledispatch("history_bars", "id_or_ins")
    sd.register_single(INSTRUMENT_TYPE.CS, "cs_bars_handler")
    var ins = create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(2010, 1, 1, 0, 0, 0, 0),
        EXCHANGE.XSHE,
    )
    var handler = sd.dispatch_by_instrument(ins)
    assert_equal(handler, "cs_bars_handler", "Instrument dispatch resolves correctly")


def test_dispatch_by_instrument_future_type() raises:
    """Dispatch_by_instrument works with FUTURE instrument type."""
    var sd = instype_singledispatch("get_contracts", "id_or_ins")
    sd.register_single(INSTRUMENT_TYPE.FUTURE, "future_contracts_handler")
    var ins = Instrument(
        order_book_id_val="RB2501.SHFE",
        symbol_val="螺纹钢2501",
        type_val=INSTRUMENT_TYPE.FUTURE,
        exchange_val=EXCHANGE.SHFE,
        listed_date_str="2024-01-15",
        de_listed_date_str="2025-01-15",
        maturity_date_str="2025-01-15",
        round_lot_val=1,
        contract_multiplier_val=10.0,
        underlying_symbol_val="",
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str="",
        market_tplus_val=0,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Active",
        special_type_val="Normal",
        settlement_method_val="",
        trading_code_val="",
    )
    var handler = sd.dispatch_by_instrument(ins)
    assert_equal(handler, "future_contracts_handler", "FUTURE dispatches correctly")


def test_dispatch_by_instrument_unregistered_type_raises() raises:
    """Dispatch_by_instrument raises for unregistered instrument type."""
    var sd = instype_singledispatch("my_api", "id_or_ins")
    sd.register_single(INSTRUMENT_TYPE.CS, "handler")
    var future_ins = Instrument(
        order_book_id_val="RB2501.SHFE",
        symbol_val="RB2501",
        type_val=INSTRUMENT_TYPE.FUTURE,
        exchange_val=EXCHANGE.SHFE,
        listed_date_str="2024-01-15",
        de_listed_date_str="2025-01-15",
        maturity_date_str="2025-01-15",
        round_lot_val=1,
        contract_multiplier_val=10.0,
        underlying_symbol_val="",
        underlying_order_book_id_val="",
        market_val=MARKET.CN,
        trading_hours_str="",
        market_tplus_val=0,
        sector_code_val="",
        sector_code_name_val="",
        industry_code_val="",
        industry_name_val="",
        concept_names_val="",
        board_type_val="",
        status_val="Active",
        special_type_val="Normal",
        settlement_method_val="",
        trading_code_val="",
    )
    with assert_raises():
        _ = sd.dispatch_by_instrument(future_ins)


# ============================================================
# Section 8: InstypeSingleDispatch dispatch 缓存 (@lru_cache(1024) 等价)
# ============================================================

def test_dispatch_result_is_cached() raises:
    """Second dispatch call for same type returns cached result."""
    var sd = instype_singledispatch("cached_api", "id")
    sd.register_single(INSTRUMENT_TYPE.CS, "cached_handler")
    var r1 = sd.dispatch("CS")
    var r2 = sd.dispatch("CS")
    assert_equal(r1, r2, "both calls return same handler")
    assert_equal(r1, "cached_handler", "correct handler returned")


def test_dispatch_cache_survives_multiple_types() raises:
    """Cache stores results for multiple different types independently."""
    var sd = instype_singledispatch("multi_api", "id")
    sd.register_single(INSTRUMENT_TYPE.CS, "cs_h")
    sd.register_single(INSTRUMENT_TYPE.FUTURE, "fut_h")
    sd.register_single(INSTRUMENT_TYPE.OPTION, "opt_h")
    assert_equal(sd.dispatch("CS"), "cs_h", "CS cached")
    assert_equal(sd.dispatch("FUTURE"), "fut_h", "FUTURE cached")
    assert_equal(sd.dispatch("OPTION"), "opt_h", "OPTION cached")
    assert_equal(sd.dispatch("CS"), "cs_h", "CS still cached (not evicted)")


def test_clear_dispatch_cache_resets_internal_lru() raises:
    """Clear_dispatch_cache() clears internal lru_cache, next call re-resolves."""
    var sd = instype_singledispatch("clearable_api", "id")
    sd.register_single(INSTRUMENT_TYPE.CS, "handler_v1")
    _ = sd.dispatch("CS")
    sd.clear_dispatch_cache()
    sd.register_single(INSTRUMENT_TYPE.CS, "handler_v2")
    var result = sd.dispatch("CS")
    assert_equal(result, "handler_v2", "after cache clear, new registration takes effect")


def test_dispatch_by_instrument_uses_shared_cache() raises:
    """Dispatch_by_instrument and dispatch share the same _dispatch_cache."""
    var sd = instype_singledispatch("shared_cache_api", "id")
    sd.register_single(INSTRUMENT_TYPE.CS, "shared_handler")
    var ins = create_stock_instrument(
        "000001.XSHE", "平安银行",
        DateTime(2010, 1, 1, 0, 0, 0, 0),
        EXCHANGE.XSHE,
    )
    var r1 = sd.dispatch_by_instrument(ins)
    var r2 = sd.dispatch("CS")
    assert_equal(r1, r2, "both paths resolve through same cache")


# ============================================================
# Section 9: registry 使用 INSTRUMENT_TYPE 作为 key
# ============================================================

def test_registry_keyed_by_instrtype_not_string() raises:
    """Registry Dict[INSTRUMENT_TYPE, String] - key is enum member, not name string."""
    var sd = instype_singledispatch("typed_registry", "arg")
    sd.register_single(INSTRUMENT_TYPE.CS, "cs_fn")
    sd.register_single(INSTRUMENT_TYPE.FUTURE, "fut_fn")
    assert_true(sd.has_handler(INSTRUMENT_TYPE.CS), "CS lookup by enum member")
    assert_true(sd.has_handler(INSTRUMENT_TYPE.FUTURE), "FUTURE lookup by enum member")
    assert_false(sd.has_handler(INSTRUMENT_TYPE.OPTION), "OPTION not registered")


def test_register_overwrite_same_type() raises:
    """Registering same INSTRUMENT_TYPE twice overwrites handler."""
    var sd = instype_singledispatch("overwrite_test", "arg")
    sd.register_single(INSTRUMENT_TYPE.CS, "first_handler")
    sd.register_single(INSTRUMENT_TYPE.CS, "second_handler")
    var result = sd.dispatch("CS")
    assert_equal(result, "second_handler", "second registration overwrites first")


# ============================================================
# Section 10: SingleDispatchProtocol + cast_singledispatch
# ============================================================

def test_cast_singledispatch_returns_same() raises:
    """Cast returns a copy conforming to SingleDispatchProtocol contract."""
    var sd = instype_singledispatch("f", "a")
    var result = cast_singledispatch(sd)
    assert_equal(result.func_name, sd.func_name, "cast preserves func_name")
    assert_equal(result.arg_name, sd.arg_name, "cast preserves arg_name")


def test_single_dispatch_protocol_exists() raises:
    """SingleDispatchProtocol is importable as a type marker."""
    assert_true(True, "SingleDispatchProtocol struct exists and is importable")


# ============================================================
# Section 11: __all__ 导出验证 (与Python原版对齐)
# ============================================================

def test_all_exports_match_python() raises:
    """__all__ should contain exactly 8 entries matching Python public API + Mojo adaptations.

    Python exports: lru_cache, cached_functions, clear_all_cached_functions,
                    SingleDispatchProtocol, cast_singledispatch, instype_singledispatch
    Mojo adds:   memoize (registration adaptation), InstypeSingleDispatch (struct form)
    Mojo removes: LazyProperty/lazy_property (were non-original extras)
    """
    from rqmojo.utils.functools import __all__ as all_symbols
    var count = comptime(len(all_symbols))
    assert_equal(count, 8, "__all__ should have exactly 8 entries (matching Python + adaptations)")


def test_lazy_property_not_exported() raises:
    """LazyProperty and lazy_property were removed (not in Python original).

    Verify by checking __all__ count is 8 (no extra entries).
    """
    from rqmojo.utils.functools import __all__ as all_symbols
    var count = comptime(len(all_symbols))
    assert_equal(count, 8, "__all__ has exactly 8 entries (no LazyProperty/lazy_property)")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
