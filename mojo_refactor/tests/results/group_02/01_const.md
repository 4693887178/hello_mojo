# 第二组测试结果 - const.py/const.mojo

## 测试概述

| 项目 | Python | Mojo |
|------|--------|------|
| 文件路径 | `rqalpha/const.py` | `rqmojo/const.mojo` |
| 测试时间 | 2026-03-26 | 2026-03-26 |
| 测试状态 | ✅ 通过 | ✅ 通过 |

## 类/结构体对比

### Python 类

| 类名 | 类型 | Mojo 实现 | 状态 |
|------|------|-----------|------|
| `CustomEnumMeta` | EnumMeta | N/A | ⚠️ Mojo无元类概念 |
| `CustomEnum` | Enum | N/A | ⚠️ 使用struct替代 |
| `EXECUTION_PHASE` | CustomEnum | `EXECUTION_PHASE` struct | ✅ |
| `RUN_TYPE` | CustomEnum | `RUN_TYPE` struct | ✅ |
| `DEFAULT_ACCOUNT_TYPE` | CustomEnum | `DEFAULT_ACCOUNT_TYPE` struct | ✅ |
| `MATCHING_TYPE` | CustomEnum | `MATCHING_TYPE` struct | ✅ |
| `ORDER_TYPE` | CustomEnum | `ORDER_TYPE` struct | ✅ |
| `ALGO` | CustomEnum | `ALGO` struct | ✅ |
| `ORDER_STATUS` | CustomEnum | `ORDER_STATUS` struct | ✅ |
| `SIDE` | CustomEnum | `SIDE` struct | ✅ |
| `POSITION_EFFECT` | CustomEnum | `POSITION_EFFECT` struct | ✅ |
| `POSITION_DIRECTION` | CustomEnum | `POSITION_DIRECTION` struct | ✅ |
| `EXC_TYPE` | CustomEnum | `EXC_TYPE` struct | ✅ |
| `INSTRUMENT_TYPE` | CustomEnum | `INSTRUMENT_TYPE` struct | ✅ |
| `PERSIST_MODE` | CustomEnum | `PERSIST_MODE` struct | ✅ |
| `COMMISSION_TYPE` | CustomEnum | `COMMISSION_TYPE` struct | ✅ |
| `EXIT_CODE` | CustomEnum | `EXIT_CODE` struct | ✅ |
| `HEDGE_TYPE` | CustomEnum | `HEDGE_TYPE` struct | ✅ |
| `DAYS_CNT` | object | `DAYS_CNT` struct | ✅ |
| `EXCHANGE` | CustomEnum | `EXCHANGE` struct | ✅ |
| `TRADING_CALENDAR_TYPE` | CustomEnum | `TRADING_CALENDAR_TYPE` struct | ✅ |
| `MARKET` | CustomEnum | `MARKET` struct | ✅ |
| N/A | N/A | `EnumRegistry` struct | ➕ Mojo新增 |

## 枚举值对比

### EXECUTION_PHASE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| GLOBAL | "[全局]" | "[全局]" | ✅ |
| ON_INIT | "[程序初始化]" | "[程序初始化]" | ✅ |
| BEFORE_TRADING | "[日内交易前]" | "[日内交易前]" | ✅ |
| OPEN_AUCTION | "[集合竞价]" | "[集合竞价]" | ✅ |
| ON_BAR | "[盘中 handle_bar 函数]" | "[盘中 handle_bar 函数]" | ✅ |
| ON_TICK | "[盘中 handle_tick 函数]" | "[盘中 handle_tick 函数]" | ✅ |
| AFTER_TRADING | "[日内交易后]" | "[日内交易后]" | ✅ |
| FINALIZED | "[程序结束]" | "[程序结束]" | ✅ |
| SCHEDULED | "[scheduler函数内]" | "[scheduler函数内]" | ✅ |

### RUN_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| BACKTEST | "BACKTEST" | "BACKTEST" | ✅ |
| PAPER_TRADING | "PAPER_TRADING" | "PAPER_TRADING" | ✅ |
| LIVE_TRADING | "LIVE_TRADING" | "LIVE_TRADING" | ✅ |

### DEFAULT_ACCOUNT_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| STOCK | "STOCK" | "STOCK" | ✅ |
| FUTURE | "FUTURE" | "FUTURE" | ✅ |
| BOND | "BOND" | "BOND" | ✅ |

### MATCHING_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| CURRENT_BAR_CLOSE | "CURRENT_BAR_CLOSE" | "CURRENT_BAR_CLOSE" | ✅ |
| VWAP | "VWAP" | "VWAP" | ✅ |
| COUNTERPARTY_OFFER | "COUNTERPARTY_OFFER" | "COUNTERPARTY_OFFER" | ✅ |
| NEXT_BAR_OPEN | "NEXT_BAR_OPEN" | "NEXT_BAR_OPEN" | ✅ |
| NEXT_TICK_LAST | "NEXT_TICK_LAST" | "NEXT_TICK_LAST" | ✅ |
| NEXT_TICK_BEST_OWN | "NEXT_TICK_BEST_OWN" | "NEXT_TICK_BEST_OWN" | ✅ |
| NEXT_TICK_BEST_COUNTERPARTY | "NEXT_TICK_BEST_COUNTERPARTY" | "NEXT_TICK_BEST_COUNTERPARTY" | ✅ |

### ORDER_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| MARKET | "MARKET" | "MARKET" | ✅ |
| LIMIT | "LIMIT" | "LIMIT" | ✅ |
| ALGO | "ALGO" | "ALGO" | ✅ |

### ALGO

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| TWAP | "TWAP" | "TWAP" | ✅ |
| VWAP | "VWAP" | "VWAP" | ✅ |

### ORDER_STATUS

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| PENDING_NEW | "PENDING_NEW" | "PENDING_NEW" | ✅ |
| ACTIVE | "ACTIVE" | "ACTIVE" | ✅ |
| FILLED | "FILLED" | "FILLED" | ✅ |
| REJECTED | "REJECTED" | "REJECTED" | ✅ |
| PENDING_CANCEL | "PENDING_CANCEL" | "PENDING_CANCEL" | ✅ |
| CANCELLED | "CANCELLED" | "CANCELLED" | ✅ |

### SIDE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| BUY | "BUY" | "BUY" | ✅ |
| SELL | "SELL" | "SELL" | ✅ |
| FINANCING | "FINANCING" | "FINANCING" | ✅ |
| MARGIN | "MARGIN" | "MARGIN" | ✅ |
| CONVERT_STOCK | "CONVERT_STOCK" | "CONVERT_STOCK" | ✅ |

### POSITION_EFFECT

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| OPEN | "OPEN" | "OPEN" | ✅ |
| CLOSE | "CLOSE" | "CLOSE" | ✅ |
| CLOSE_TODAY | "CLOSE_TODAY" | "CLOSE_TODAY" | ✅ |
| EXERCISE | "EXERCISE" | "EXERCISE" | ✅ |
| MATCH | "MATCH" | "MATCH" | ✅ |

### POSITION_DIRECTION

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| LONG | "LONG" | "LONG" | ✅ |
| SHORT | "SHORT" | "SHORT" | ✅ |

### EXC_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| USER_EXC | "USER_EXC" | "USER_EXC" | ✅ |
| SYSTEM_EXC | "SYSTEM_EXC" | "SYSTEM_EXC" | ✅ |
| NOTSET | "NOTSET" | "NOTSET" | ✅ |

### INSTRUMENT_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| CS | "CS" | "CS" | ✅ |
| FUTURE | "Future" | "Future" | ✅ |
| OPTION | "Option" | "Option" | ✅ |
| ETF | "ETF" | "ETF" | ✅ |
| LOF | "LOF" | "LOF" | ✅ |
| INDX | "INDX" | "INDX" | ✅ |
| PUBLIC_FUND | "PublicFund" | "PublicFund" | ✅ |
| FUND | "Fund" | "Fund" | ✅ |
| BOND | "Bond" | "Bond" | ✅ |
| CONVERTIBLE | "Convertible" | "Convertible" | ✅ |
| SPOT | "Spot" | "Spot" | ✅ |
| REPO | "Repo" | "Repo" | ✅ |
| REITs | "REITs" | "REITs" | ✅ |
| FutureArbitrage | "FutureArbitrage" | "FutureArbitrage" | ✅ |

### PERSIST_MODE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| ON_CRASH | "ON_CRASH" | "ON_CRASH" | ✅ |
| REAL_TIME | "REAL_TIME" | "REAL_TIME" | ✅ |
| ON_NORMAL_EXIT | "ON_NORMAL_EXIT" | "ON_NORMAL_EXIT" | ✅ |

### COMMISSION_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| BY_MONEY | "BY_MONEY" | "BY_MONEY" | ✅ |
| BY_VOLUME | "BY_VOLUME" | "BY_VOLUME" | ✅ |

### EXIT_CODE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| EXIT_SUCCESS | "EXIT_SUCCESS" | "EXIT_SUCCESS" | ✅ |
| EXIT_USER_ERROR | "EXIT_USER_ERROR" | "EXIT_USER_ERROR" | ✅ |
| EXIT_INTERNAL_ERROR | "EXIT_INTERNAL_ERROR" | "EXIT_INTERNAL_ERROR" | ✅ |

### HEDGE_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| HEDGE | "hedge" | "hedge" | ✅ |
| SPECULATION | "speculation" | "speculation" | ✅ |
| ARBITRAGE | "arbitrage" | "arbitrage" | ✅ |

### DAYS_CNT

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| DAYS_A_YEAR | 365 | 365 | ✅ |
| TRADING_DAYS_A_YEAR | 252 | 252 | ✅ |

### EXCHANGE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| XSHE | "XSHE" | "XSHE" | ✅ |
| XSHG | "XSHG" | "XSHG" | ✅ |
| SHFE | "SHFE" | "SHFE" | ✅ |
| INE | "INE" | "INE" | ✅ |
| DCE | "DCE" | "DCE" | ✅ |
| CZCE | "CZCE" | "CZCE" | ✅ |
| CFFEX | "CFFEX" | "CFFEX" | ✅ |
| SGEX | "SGEX" | "SGEX" | ✅ |
| BJSE | "BJSE" | "BJSE" | ✅ |

### TRADING_CALENDAR_TYPE

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| CN_STOCK | "CN_STOCK" | "CN_STOCK" | ✅ |
| HK_STOCK | "HK_STOCK" | "HK_STOCK" | ✅ |
| SOUTHBOUND | "SOUTHBOUND" | "SOUTHBOUND" | ✅ |
| INTER_BANK | "INTERBANK" | "INTERBANK" | ✅ |
| EXCHANGE | "CN_STOCK" (alias) | "CN_STOCK" | ✅ |

### MARKET

| 常量名 | Python Value | Mojo Value | 状态 |
|--------|--------------|------------|------|
| CN | "CN" | "CN" | ✅ |
| HK | "HK" | "HK" | ✅ |

## 方法/函数对比

### Python CustomEnumMeta 方法

| 方法名 | 功能 | Mojo 实现 | 状态 |
|--------|------|-----------|------|
| `__new__` | 创建枚举类，添加反向映射 | N/A | ⚠️ Mojo无元类 |
| `__contains__` | 检查成员是否存在 | `EnumRegistry.contains` | ✅ |
| `__getitem__` | 通过名称或值获取成员 | `EnumRegistry.get` | ✅ |

### Python CustomEnum 方法

| 方法名 | 功能 | Mojo 实现 | 状态 |
|--------|------|-----------|------|
| `__repr__` | 返回类名.成员名 | `Writable.write_to` | ✅ |

### Mojo EnumRegistry 方法 (新增)

| 方法名 | 功能 | Python 实现 | 状态 |
|--------|------|-------------|------|
| `__init__` | 初始化注册表 | N/A | ➕ Mojo新增 |
| `get[T]` | 通过名称或值获取枚举 | CustomEnumMeta.__getitem__ | ➕ Mojo新增 |
| `contains[T]` | 检查是否存在 | CustomEnumMeta.__contains__ | ➕ Mojo新增 |

## 测试结果

### Python 测试

```
============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2
collected 96 items

test_const.py::TestCustomEnumMeta::test_contains_by_name PASSED
test_const.py::TestCustomEnumMeta::test_contains_by_value PASSED
test_const.py::TestCustomEnumMeta::test_getitem_by_name PASSED
test_const.py::TestCustomEnumMeta::test_getitem_by_value PASSED
... (共96个测试全部通过)

============================== 96 passed in 0.05s ==============================
```

### Mojo 测试

```
============================================================
RQMojo const.mojo Test Suite
============================================================

Testing EXECUTION_PHASE...
  EXECUTION_PHASE tests passed!
Testing RUN_TYPE...
  RUN_TYPE tests passed!
... (所有测试通过)

============================================================
All tests passed!
============================================================
```

## 差异说明

### 1. 枚举实现方式

**Python**: 使用 `Enum` 和元类 `EnumMeta` 实现
**Mojo**: 使用 `struct` + `comptime` 常量实现

**原因**: Mojo 不支持元类和动态类创建，因此使用 struct 替代枚举类。

### 2. 反向映射

**Python**: 通过 `CustomEnumMeta.__new__` 自动创建 `_member_reverse_map`
**Mojo**: 通过 `EnumRegistry` 结构体手动维护映射关系

### 3. 类型安全

**Python**: 动态类型，运行时检查
**Mojo**: 静态类型，编译时检查，更安全

## 结论

| 项目 | 结果 |
|------|------|
| 功能一致性 | ✅ 完全一致 |
| 测试通过率 | 100% (Python: 96/96, Mojo: 全部通过) |
| 实现质量 | ✅ 良好 |

**总体评价**: const.py/const.mojo 的重构完全成功，所有枚举值和方法都已正确实现，测试全部通过。
