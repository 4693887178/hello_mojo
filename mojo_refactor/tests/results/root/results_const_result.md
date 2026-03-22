# RQAlpha/RQMojo const 模块测试结果报告

## 测试概述

本报告记录了 RQAlpha Python 版本和 RQMojo 版本的 `const` 模块测试结果。

- **测试日期**: 2026-03-23
- **Python版本**: 3.14.3
- **Mojo版本**: 0.26.2.0
- **测试框架**: Python (pytest 9.0.2), Mojo (std.testing)

---

## Python 测试结果

### 测试环境

```
平台: linux
Python: 3.14.3
pytest: 9.0.2
pluggy: 1.6.0
```

### 测试统计

| 指标 | 数值 |
|------|------|
| 总测试数 | 118 |
| 通过 | 118 |
| 失败 | 0 |
| 错误 | 0 |
| 跳过 | 0 |
| 执行时间 | 3.45s |

### 测试覆盖的枚举类

| 枚举类 | 成员数 | 测试状态 |
|--------|--------|----------|
| EXECUTION_PHASE | 9 | ✅ 通过 |
| RUN_TYPE | 3 | ✅ 通过 |
| DEFAULT_ACCOUNT_TYPE | 3 | ✅ 通过 |
| MATCHING_TYPE | 7 | ✅ 通过 |
| ORDER_TYPE | 3 | ✅ 通过 |
| ALGO | 2 | ✅ 通过 |
| ORDER_STATUS | 6 | ✅ 通过 |
| SIDE | 5 | ✅ 通过 |
| POSITION_EFFECT | 5 | ✅ 通过 |
| POSITION_DIRECTION | 2 | ✅ 通过 |
| EXC_TYPE | 3 | ✅ 通过 |
| INSTRUMENT_TYPE | 14 | ✅ 通过 |
| PERSIST_MODE | 3 | ✅ 通过 |
| COMMISSION_TYPE | 2 | ✅ 通过 |
| EXIT_CODE | 3 | ✅ 通过 |
| HEDGE_TYPE | 3 | ✅ 通过 |
| DAYS_CNT | 2 | ✅ 通过 |
| EXCHANGE | 9 | ✅ 通过 |
| TRADING_CALENDAR_TYPE | 4 | ✅ 通过 |
| MARKET | 2 | ✅ 通过 |

### 特殊测试用例

| 测试类别 | 测试内容 | 状态 |
|----------|----------|------|
| CustomEnumFeatures | repr格式测试 | ✅ 通过 |
| CustomEnumFeatures | 字符串继承测试 | ✅ 通过 |
| CustomEnumFeatures | 相等性测试 | ✅ 通过 |
| CustomEnumFeatures | 可哈希测试 | ✅ 通过 |
| TRADING_CALENDAR_TYPE | EXCHANGE向后兼容性 | ✅ 通过 |

---

## Mojo 测试结果

### 测试环境

```
平台: linux
Mojo: 0.26.2.0
测试框架: std.testing
```

### 测试统计

| 指标 | 数值 |
|------|------|
| 总测试函数 | 24 |
| 通过 | 24 |
| 失败 | 0 |
| 错误 | 0 |
| 执行状态 | 成功 |

### 测试函数列表

| 测试函数 | 测试内容 | 状态 |
|----------|----------|------|
| test_execution_phase | EXECUTION_PHASE 枚举测试 | ✅ 通过 |
| test_run_type | RUN_TYPE 枚举测试 | ✅ 通过 |
| test_default_account_type | DEFAULT_ACCOUNT_TYPE 枚举测试 | ✅ 通过 |
| test_matching_type | MATCHING_TYPE 枚举测试 | ✅ 通过 |
| test_order_type | ORDER_TYPE 枚举测试 | ✅ 通过 |
| test_algo | ALGO 枚举测试 | ✅ 通过 |
| test_order_status | ORDER_STATUS 枚举测试 | ✅ 通过 |
| test_side | SIDE 枚举测试 | ✅ 通过 |
| test_position_effect | POSITION_EFFECT 枚举测试 | ✅ 通过 |
| test_position_direction | POSITION_DIRECTION 枚举测试 | ✅ 通过 |
| test_exc_type | EXC_TYPE 枚举测试 | ✅ 通过 |
| test_instrument_type | INSTRUMENT_TYPE 枚举测试 | ✅ 通过 |
| test_persist_mode | PERSIST_MODE 枚举测试 | ✅ 通过 |
| test_commission_type | COMMISSION_TYPE 枚举测试 | ✅ 通过 |
| test_exit_code | EXIT_CODE 枚举测试 | ✅ 通过 |
| test_hedge_type | HEDGE_TYPE 枚举测试 | ✅ 通过 |
| test_days_cnt | DAYS_CNT 常量测试 | ✅ 通过 |
| test_exchange | EXCHANGE 枚举测试 | ✅ 通过 |
| test_trading_calendar_type | TRADING_CALENDAR_TYPE 枚举测试 | ✅ 通过 |
| test_market | MARKET 枚举测试 | ✅ 通过 |
| test_equality | 相等性测试 | ✅ 通过 |
| test_enum_registry_get | EnumRegistry.get() 测试 | ✅ 通过 |
| test_enum_registry_get_by_value | EnumRegistry.get_by_value() 测试 | ✅ 通过 |
| test_enum_registry_to_string | EnumRegistry.to_string() 测试 | ✅ 通过 |
| test_enum_registry_not_found | EnumRegistry 未找到测试 | ✅ 通过 |

---

## 枚举值对照表

### EXECUTION_PHASE

| 名称 | Python Value | Mojo Value | 一致性 |
|------|--------------|------------|--------|
| GLOBAL | [全局] | [全局] | ✅ |
| ON_INIT | [程序初始化] | [程序初始化] | ✅ |
| BEFORE_TRADING | [日内交易前] | [日内交易前] | ✅ |
| OPEN_AUCTION | [集合竞价] | [集合竞价] | ✅ |
| ON_BAR | [盘中 handle_bar 函数] | [盘中 handle_bar 函数] | ✅ |
| ON_TICK | [盘中 handle_tick 函数] | [盘中 handle_tick 函数] | ✅ |
| AFTER_TRADING | [日内交易后] | [日内交易后] | ✅ |
| FINALIZED | [程序结束] | [程序结束] | ✅ |
| SCHEDULED | [scheduler函数内] | [scheduler函数内] | ✅ |

### HEDGE_TYPE

| 名称 | Python Value | Mojo Value | 一致性 |
|------|--------------|------------|--------|
| HEDGE | hedge | hedge | ✅ |
| SPECULATION | speculation | speculation | ✅ |
| ARBITRAGE | arbitrage | arbitrage | ✅ |

### INSTRUMENT_TYPE

| 名称 | Python Value | Mojo Value | 一致性 |
|------|--------------|------------|--------|
| CS | CS | CS | ✅ |
| FUTURE | Future | Future | ✅ |
| OPTION | Option | Option | ✅ |
| ETF | ETF | ETF | ✅ |
| LOF | LOF | LOF | ✅ |
| INDX | INDX | INDX | ✅ |
| PUBLIC_FUND | PublicFund | PublicFund | ✅ |
| FUND | Fund | Fund | ✅ |
| BOND | Bond | Bond | ✅ |
| CONVERTIBLE | Convertible | Convertible | ✅ |
| SPOT | Spot | Spot | ✅ |
| REPO | Repo | Repo | ✅ |
| REITs | REITs | REITs | ✅ |
| FutureArbitrage | FutureArbitrage | FutureArbitrage | ✅ |

---

## 测试结论

### Python 测试

- **结果**: ✅ 全部通过
- **测试覆盖**: 118个测试用例
- **功能验证**: 所有枚举类的name、value、计数、包含性、索引访问等功能均正常

### Mojo 测试

- **结果**: ✅ 全部通过
- **测试覆盖**: 24个测试函数
- **功能验证**: 所有枚举类的name、value、相等性、EnumRegistry功能均正常

### 一致性验证

- Python和Mojo版本的枚举值完全一致
- 所有枚举成员的name和value属性匹配
- 特殊值（如HEDGE_TYPE的小写值、INSTRUMENT_TYPE的混合值）保持一致

---

## 测试文件路径

| 文件类型 | 路径 |
|----------|------|
| Python测试 | `mojo_refactor/tests/python/root/test_const.py` |
| Mojo测试 | `mojo_refactor/tests/mojo/root/test_const.mojo` |
| 测试结果报告 | `mojo_refactor/tests/results/root/results_const_result.md` |
