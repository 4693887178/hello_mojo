# 第四组测试结果 - utils/functools.py / functools.mojo

## 测试概述

| 项目 | Python | Mojo |
|------|--------|------|
| 文件路径 | `rqalpha/utils/functools.py` (123行) | `rqmojo/utils/functools.mojo` (~280行) |
| 测试时间 | 2026-04-20 | 2026-04-20 |
| 测试状态 | ✅ 通过 (11/11) | ✅ 通过 (**52/52**) |
| 警告数 | 0 | **0** |

## 修复摘要

### 本次修复的核心问题

| 问题类别 | 修复前（旧版） | 修复后（新版） |
|---------|---------------|---------------|
| **LazyProperty / lazy_property** | ❌ 存在（非Python原版API） | ✅ 已移除，__all__从10项精简为8项 |
| **SingleDispatchProtocol** | ❌ docstring内含非法pass语句 | ✅ pass移至函数体 |
| **memoize()签名** | ❌ 接受无用func_name参数 | ✅ 简化为memoize(max_size=128) |
| **测试覆盖** | ❌ 11个用例+编译错误(Instrument字段缺失) | ✅ 52个用例全覆盖+0警告 |
| **__all__一致性** | ❌ 含2个非原版导出 | ✅ 与Python原版完全对齐(6原版+2Mojo适配) |

### Python → Mojo API 映射

| Python 原版 (L18-123) | Mojo 实现 | 说明 |
|-----------------------|-----------|------|
| `lru_cache(*args, **kwargs)` 装饰器工厂 | `lru_cache` 结构体 + `memoize()` 工厂 | Mojo无装饰器协议的合理适配 |
| `cached_functions = []` 全局列表 | `cached_functions() -> Int` 计数器 | env var方案，O(1)查询 |
| `clear_all_cached_functions()` 遍历列表清缓存 | bump generation counter + 懒失效 | 更安全：所有实例自动失效 |
| `class SingleDispatchProtocol(Protocol)` | `struct SingleDispatchProtocol` 标记结构体 | Mojo无Protocol语法 |
| `cast_singledispatch(func)` 类型转换 | `cast_singledispatch(func) -> InstypeSingleDispatch` copy | 运行时等价于identity |
| `instype_singledispatch(func)` 装饰器 | `instype_singledispatch(name, arg)` 工厂 | 需显式参数(Mojo无inspect.signature) |
| _(无)_ | ~~LazyProperty / lazy_property~~ | 已移除 |

## 函数对比

### 公共 API（8个导出符号）

| 符号 | Python 原版 | Mojo 实现 | 状态 |
|------|------------|-----------|------|
| `lru_cache` | 装饰器工厂→property描述符 | LRU缓存结构体(Dict+access_order) | ✅ 功能等价 |
| `cached_functions` | List[callable] | Int计数器(env var) | ⚠️ 合理适配 |
| `clear_all_cached_functions` | 遍历list调用cache_clear() | generation counter全局失效 | ✅ 功能等价(更强) |
| `InstypeSingleDispatch` | 装饰器返回的wrapper对象 | 独立结构体(register/dispatch/cache) | ✅ 功能等价 |
| `instype_singledispatch` | 装饰器(提取func.__name__) | 工厂函数(name, arg显式参数) | ⚠️ 合理适配 |
| `SingleDispatchProtocol` | typing.Protocol | 标记struct | ✅ 用途一致 |
| `cast_singledispatch` | cast(SingleDispatchProtocol, func) | copy操作 | ✅ 行为等价 |
| `memoize` | _(无直接对应)_ | 注册工厂(lru_cache+计数) | 🆕 Mojo适配层 |

## 测试结果

### Mojo 测试 (52/52 PASS, 0 warnings)

```
Running 52 tests for test_functools.mojo
    PASS [ 0.003 ] test_lru_cache_default_init
    PASS [ 0.001 ] test_lru_cache_custom_max_size
    PASS [ 0.001 ] test_lru_cache_zero_max_size
    PASS [ 0.004 ] test_lru_cache_set_and_get
    PASS [ 0.001 ] test_lru_cache_get_nonexistent
    PASS [ 0.003 ] test_lru_cache_set_overwrite
    PASS [ 0.002 ] test_lru_cache_contains_existing
    PASS [ 0.001 ] test_lru_cache_contains_missing
    PASS [ 0.002 ] test_lru_cache_contains_empty_string_key
    PASS [ 0.005 ] test_lru_cache_clear_removes_all
    PASS [ 0.001 ] test_lru_cache_clear_empty_is_safe
    PASS [ 0.003 ] test_lru_cache_multiple_keys
    PASS [ 0.002 ] test_lru_cache_unicode_values
    PASS [ 0.017 ] test_lru_cache_copy_semantics
    PASS [ 0.002 ] test_lru_cache_cache_clear_alias
    PASS [ 0.006 ] test_lru_evicts_oldest_when_full
    PASS [ 0.005 ] test_lru_access_updates_order
    PASS [ 0.006 ] test_lru_set_updates_order
    PASS [ 0.003 ] test_lru_max_size_zero_no_eviction
    PASS [ 0.005 ] test_lru_eviction_sequence
    PASS [ 0.016 ] test_memoize_registers_in_cached_functions
    PASS [ 0.003 ] test_memoize_returns_lrucache_with_correct_max_size
    PASS [ 0.005 ] test_memoize_returned_instance_works
    PASS [ 0.003 ] test_memoize_default_max_size
    PASS [ 0.020 ] test_cached_functions_counts_across_calls
    PASS [ 0.015 ] test_clear_all_invalidates_registered_caches
    PASS [ 0.103 ] test_clear_also_invalidates_direct_caches
    PASS [ 0.012 ] test_clear_resets_registration_count
    PASS [ 0.017 ] test_clear_idempotent_multiple_calls
    PASS [ 0.006 ] test_new_caches_after_clear_work_normally
    PASS [ 0.016 ] test_instype_singledispatch_creation
    PASS [ 0.004 ] test_instype_singledispatch_register_single
    PASS [ 0.010 ] test_instype_singledispatch_register_multiple
    PASS [ 0.017 ] test_instype_singledispatch_dispatch_by_name_success
    PASS [ 0.059 ] test_instype_singledispatch_dispatch_unknown_type_raises_invalid_arg
    PASS [ 0.003 ] test_instype_singledispatch_registered_types_returns_names
    PASS [ 0.004 ] test_instype_singledispatch_copy_independent
    PASS [ 0.009 ] test_empty_registry_dispatch_raises_api_not_supported
    PASS [ 0.016 ] test_dispatch_future_registered_cs_raises_invalid_argument
    PASS [ 0.006 ] test_dispatch_by_instrument_direct_type_extraction
    PASS [ 0.003 ] test_dispatch_by_instrument_future_type
    PASS [ 0.008 ] test_dispatch_by_instrument_unregistered_type_raises
    PASS [ 0.005 ] test_dispatch_result_is_cached
    PASS [ 0.010 ] test_dispatch_cache_survives_multiple_types
    PASS [ 0.006 ] test_clear_dispatch_cache_resets_internal_lru
    PASS [ 0.006 ] test_dispatch_by_instrument_uses_shared_cache
    PASS [ 0.002 ] test_registry_keyed_by_instrtype_not_string
    PASS [ 0.005 ] test_register_overwrite_same_type
    PASS [ 0.002 ] test_cast_singledispatch_returns_same
    PASS [ 0.001 ] test_single_dispatch_protocol_exists
    PASS [ 0.001 ] test_all_exports_match_python
    PASS [ 0.001 ] test_lazy_property_not_exported
--------
Summary [ 0.487 ] 52 tests run: 52 passed , 0 failed , 0 skipped
```

### Python 测试 (11/11 PASS)

```
======================== 11 passed in 1.72s =========================
```

## 测试覆盖矩阵

### lru_cache 结构体 (16 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| default_init | 默认max_size=128 | functools.lru_cache(maxsize=128) |
| custom_max_size | 自定义容量 | @lru_cache(N) |
| zero_max_size | max_size=0不限制 | 无限制缓存 |
| set_and_get | 写入/读取 | cache[key] = value |
| get_nonexistent | 缺失key返回None | KeyError→None |
| set_overwrite | 覆写已有值 | 同key覆写 |
| contains_existing/missing | 包含检查 | key in cache |
| empty_string_key | 空字符串键 | 任意字符串均可 |
| clear_removes_all | 清空全部 | cache.clear() |
| clear_empty_is_safe | 空cache清空安全 | 无异常 |
| multiple_keys | 多键共存 | 多条目 |
| unicode_values | 中文键值对 | Unicode支持 |
| copy_semantics | Copyable独立拷贝 | 不共享状态 |
| cache_clear_alias | cache_clear()=clear() | Python别名API |

### LRU淘汰行为 (5 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| evicts_oldest_when_full | 超容淘汰最老条目 | LRU策略核心 |
| access_updates_order | GET提升为最近使用 | LRU访问顺序更新 |
| set_updates_order | SET已存在也提升 | LRU写入顺序更新 |
| max_size_zero_no_eviction | 0=无限容量 | 无淘汰 |
| eviction_sequence | 复杂FIFO+promote序列 | 完整LRU正确性 |

### memoize + cached_functions (5 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| registers_in_cached_functions | memoize递增计数 | cached_functions.append(func) |
| returns_correct_max_size | 自定义maxsize传递 | @lru_cache(maxsize) |
| returned_instance_works | 返回实例可用作缓存 | 装饰后func可调用 |
| default_max_size | 默认128 | functools默认值 |
| counts_across_calls | 累计计数 | len(cached_functions)增长 |

### clear_all_cached_functions (5 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| invalidates_registered_caches | memoize创建的cache失效 | func.cache_clear() |
| invalidates_direct_caches | 直接创建的cache也失效 | **比Python更安全** |
| resets_registration_count | cached_functions()返回0 | 重置注册表 |
| idempotent_multiple_calls | 多次调用安全 | 幂等操作 |
| new_caches_after_clear | clear后新建正常 | 无副作用残留 |

### InstypeSingleDispatch 基础 (7 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| creation | func_name/arg_name存储 | inspect.signature提取 |
| register_single | 单类型注册 | wrapper.register(CS)(handler) |
| register_multiple | 批量注册 | wrapper.register([CS,FUT])(h) |
| dispatch_by_name_success | 名称分发成功 | __get__(instance, owner) |
| dispatch_unknown_type_raises | 未知类型→RQInvalidArgument | Python line 80-85 |
| registered_types_returns_names | 列出已注册类型名 | registry.keys() |
| copy_independent | 拷贝独立修改 | Copyable trait |

### 异常类型 (2 tests)

| 测试用例 | 验证内容 | 对应Python行号 |
|---------|---------|--------------|
| empty_registry→ApiNotSupported | 空注册表特殊异常 | L72-74 |
| wrong_type→InvalidArgument | 类型不匹配通用异常 | L80-85 |

### Instrument对象分发 (3 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| by_instrument_CS | CS股票Instrument分发 | dispatch(ins)路径 |
| by_instrument_FUTURE | FUTURE期货Instrument分发 | dispatch(ins)路径 |
| unregistered_type_raises | 未注册类型异常 | RQInvalidArgument |

### 分发缓存 (@lru_cache(1024)) (4 tests)

| 测试用例 | 验证内容 | 对应Python行为 |
|---------|---------|---------------|
| result_is_cached | 二次调用命中缓存 | @lru_cache(1024)效果 |
| cache_survives_multi_types | 多类型独立缓存 | 各type独立条目 |
| clear_dispatch_cache | 手动清缓存重解析 | cache_clear() |
| shared_cache | 两路径共享同一cache | _dispatch_cache单例 |

### Registry + 类型标记 (4 tests)

| 测试用例 | 验证内容 |
|---------|---------|
| keyed_by_instrtype_not_string | Dict[INSTRUMENT_TYPE,String]键是enum |
| register_overwrite_same_type | 同type覆写handler |
| cast_singledispatch_returns_same | identity/copy行为 |
| single_dispatch_protocol_exists | 标记struct可导入 |

### 导出验证 (2 tests)

| 测试用例 | 验证内容 |
|---------|---------|
| all_exports_match_python | __all__恰好8项 |
| lazy_property_not_exported | LazyProperty/lazy_property不在__all__中 |

## 结论

| 项目 | 结果 |
|------|------|
| 功能一致性 | ✅ 核心功能完整迁移，关键行为匹配Python原版 |
| Mojo测试通过率 | **100% (52/52)** |
| Python测试通过率 | **100% (11/11)** |
| 编译/运行警告 | **0** |
| API表面一致性 | ✅ 移除2个非原版API，__all__从10精简至8 |
| 代码质量 | ✅ SingleDispatchProtocol docstring修复，memoize签名简化 |

**总体评价**: functools.mojo 修复完成。移除2个非原版额外API(LazyProperty/lazy_property)，修复1处编译错误(pass位置)，重写测试从11个扩展到52个全覆盖，全部通过且零警告。
