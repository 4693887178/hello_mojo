# Python vs Mojo 测试结果对比报告

## 测试概述

本报告对比了 rqalpha (Python) 和 rqmojo (Mojo) 在 `sys_accounts` 模块中的测试结果。

**测试日期**: 2026-03-22

**测试目录**: `mojo_refactor/tests/integration_tests/test_api/mod/sys_accounts/`

---

## 测试文件列表

| 文件名 | Python测试 | Mojo测试 |
|--------|-----------|----------|
| test_position_models.py/mojo | 12 tests | 12 tests |
| test_futures_settlement_price_type.py/mojo | 8 tests | 8 tests |
| test_margin_stocks.py/mojo | 11 tests | 11 tests |
| test_account_model.py/mojo | 15 tests | 15 tests |

---

## 详细测试结果

### 1. test_position_models

| 测试用例 | Python | Mojo | 状态 |
|---------|--------|------|------|
| test_stock_sellable | ✅ PASSED | ✅ PASSED | 一致 |
| test_stock_sellable_t1 | ✅ PASSED | ✅ PASSED | 一致 |
| test_trading_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_position_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_daily_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin | ✅ PASSED | ✅ PASSED | 一致 |
| test_short_position_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_position_apply_trade_open | ✅ PASSED | ✅ PASSED | 一致 |
| test_position_apply_trade_close | ✅ PASSED | ✅ PASSED | 一致 |
| test_position_update_last_price | ✅ PASSED | ✅ PASSED | 一致 |
| test_position_settlement | ✅ PASSED | ✅ PASSED | 一致 |
| test_position_before_trading | ✅ PASSED | ✅ PASSED | 一致 |

### 2. test_futures_settlement_price_type

| 测试用例 | Python | Mojo | 状态 |
|---------|--------|------|------|
| test_futures_settlement_price_type | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_de_listed | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_position_pnl_calculation | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_short_position_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_daily_pnl_vs_position_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_settlement_sequence | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_margin_calculation | ✅ PASSED | ✅ PASSED | 一致 |
| test_futures_close_today | ✅ PASSED | ✅ PASSED | 一致 |

### 3. test_margin_stocks

| 测试用例 | Python | Mojo | 状态 |
|---------|--------|------|------|
| test_margin_account_creation | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_position_creation | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_buy_order | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_position_apply_trade | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_financing_rate | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_stock_restriction_disabled | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_account_cash_management | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_position_market_value | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_position_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_multiple_positions | ✅ PASSED | ✅ PASSED | 一致 |
| test_margin_sell_position | ✅ PASSED | ✅ PASSED | 一致 |

### 4. test_account_model

| 测试用例 | Python | Mojo | 状态 |
|---------|--------|------|------|
| test_stock_account_creation | ✅ PASSED | ✅ PASSED | 一致 |
| test_future_account_creation | ✅ PASSED | ✅ PASSED | 一致 |
| test_stock_delist | ✅ PASSED | ✅ PASSED | 一致 |
| test_stock_dividend | ✅ PASSED | ✅ PASSED | 一致 |
| test_stock_transform | ✅ PASSED | ✅ PASSED | 一致 |
| test_stock_split | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_position_management | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_cash_update | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_total_value_calculation | ✅ PASSED | ✅ PASSED | 一致 |
| test_future_account_margin | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_multiple_positions | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_pnl_calculation | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_daily_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_position_pnl | ✅ PASSED | ✅ PASSED | 一致 |
| test_account_trading_pnl | ✅ PASSED | ✅ PASSED | 一致 |

---

## 关键修复

在测试过程中，发现并修复了以下Mojo实现问题：

### 1. Position.avg_price 计算错误

**问题**: `apply_trade` 方法中 `avg_price` 的计算错误地包含了 `contract_multiplier`

**修复前**:
```mojo
self.avg_price = (old_total + trade_amount) / Float64(self.quantity)
// trade_amount = trade.price * trade.quantity * contract_multiplier
```

**修复后**:
```mojo
self.avg_price = (old_total + trade.price * Float64(trade.quantity)) / Float64(self.quantity)
```

### 2. trading_pnl 计算逻辑缺失

**问题**: Mojo版本缺少 `_trade_cost` 和 `_logical_old_quantity` 字段来正确计算交易盈亏

**修复**: 添加了以下字段和方法：
- `_trade_cost: Float64` - 跟踪交易成本
- `_logical_old_quantity: Int` - 日初持仓量
- 更新 `apply_trade` 方法跟踪 `_trade_cost`
- 更新 `before_trading` 方法重置 `_logical_old_quantity` 和 `_trade_cost`
- 重新实现 `trading_pnl` 方法

### 3. daily_pnl 计算逻辑

**问题**: `daily_pnl` 应该等于 `position_pnl + trading_pnl`

**修复**:
```mojo
fn daily_pnl(self) -> Float64:
    return self.position_pnl() + self.trading_pnl()
```

---

## 测试统计

| 指标 | Python | Mojo |
|------|--------|------|
| 总测试数 | 46 | 46 |
| 通过数 | 46 | 46 |
| 失败数 | 0 | 0 |
| 通过率 | 100% | 100% |

---

## 结论

✅ **所有测试通过，Python和Mojo实现结果一致**

rqmojo 的 Position 模块已正确实现 rqalpha 的核心功能，包括：
- 持仓管理（开仓、平仓）
- 盈亏计算（持仓盈亏、交易盈亏、当日盈亏）
- 保证金计算
- T+1 规则
- 期货合约乘数处理

---

## 文件位置

- **Python测试**: `mojo_refactor/tests/integration_tests/test_api/mod/sys_accounts/*.py`
- **Mojo测试**: `mojo_refactor/tests/mojo/integration_tests/test_api/mod/sys_accounts/*.mojo`
- **Position实现**: `mojo_refactor/rqmojo/portfolio/position.mojo`
