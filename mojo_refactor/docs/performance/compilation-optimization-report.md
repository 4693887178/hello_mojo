# Mojo 编译性能优化报告

**日期**: 2026-04-19
**分析范围**: mojo_refactor/rqmojo 项目编译链

---

## 一、基准数据

| 指标 | 数值 |
|------|------|
| **rqmojo 自身代码量** | 27,188 行 / 486 个 .mojo 文件 |
| **第三方包总代码量** | ~141,922 行 / 329 个 .mojo 文件 |
| **每次编译需解析总量** | **~169,110+ 行** |
| **当前编译命令包含 -I 参数** | 5 个（全部第三方包） |

### 第三方包详细数据

| 包名 | 文件数 | 总行数 | 被 rqmojo 依赖的文件数 | 是否必需？ |
|------|--------|--------|--------------------------|-----------|
| **morrow.mojo** | 11 | 1,347 | **51 个文件**（通过 typing.mojo） | ✅ 核心依赖 |
| **argmojo** | 17 | 20,090 | **10 个文件** | ⚠️ 仅 CLI 相关 |
| **EmberJson** | 56 | 16,101 | **1 个文件** | ❌ 几乎不需要 |
| **NuMojo** | 91 | 45,739 | **0 个文件** | ❌ 完全未使用 |
| **mojo-yaml** | 25 | 3,155 | 0（间接） | ⚠️ 通过其他包引入 |
| **bison** | 124 | 53,929 | **1 个文件** | ❌ 几乎不需要 |
| **hdf5-mojo** | 4 | 1,561 | **0 个文件** | ❌ 完全未使用 |

---

## 二、发现的 5 大瓶颈

### 瓶颈 #1：过度包含的 `-I` 搜索路径（影响等级：🔴 严重）

**问题**: 所有编译命令统一使用 5 个 `-I` 参数，导致编译器搜索 **329+ 个无关文件**。

**证据**:
```
当前命令:
  mojo build -I . \
    -I rqmojo/third_party/argmojo/src \     # 17 文件/20K行 — 仅10个文件需要
    -I rqmojo/third_party/EmberJson \        # 56 文件/16K行 — 仅1个文件需要
    -I rqmojo/third_party/NuMojo \           # 91 文件/45K行 — 零个文件需要！
    -I rqmojo/third_party/mojo-yaml/src \   # 25 文件/3K行 — 间接依赖
    -I rqmojo/third_party/morrow.mojo        # 11 文件/1.3K行 — ✅ 必需
```

**浪费量**: NuMojo(45,739行) + bison(53,929行) + EmberJson(16,101行) = **115,769 行无效解析**

### 瓶颈 #2：typing.mojo 强制拉入 morrow 全包（影响等级：🔴 严重）

**问题**: `DateTime` 类型别名定义为 `comptime DateTime = Morrow`，导致任何使用 DateTime 的文件都拉入 morrow。

**依赖链**:
```
simulation_event_source.mojo
  → from rqmojo.utils.typing import DateTime
    → from morrow import Morrow          ← 整个 morrow 包被拉入
      → morrow/morrow.mojo (368行)       ← 导入 _py, util, _libc, timezone, timedelta, formatter, constants
```

**影响面**: 51 个 rqmojo 文件使用 DateTime，每个都触发完整 morrow 包解析。

### 瓶颈 #3：const.mojo 单体巨型文件（影响等级：🟡 中等）

**问题**: 669 行 / 99 个 def / 21 个 struct / 大量枚举定义全部在一个文件中。

**分析**:
- 每次编译都需完整解析此文件
- 包含 MATCHING_TYPE(6值), SIDE(4值), ORDER_TYPE(8值), POSITION_EFFECT(6值), POSITION_DIRECTION(2值) 等 15+ 枚举
- 被几乎所有文件直接或间接导入

### 瓶颈 #4：interface.mojo 11 个 trait 定义（影响等级：🟡 中等）

**问题**: 324 行定义了 11 个 trait + 58 个方法签名，每个 trait 的虚函数表都需要编译器处理。

**被实现方**: matcher.mojo (3 structs 实现 trait), mod.mojo (1 struct), 以及其他多个模块。

### 瓶颈 #5：matcher.mojo 高条件分支密度（影响等级：🟠 较轻）

**问题**: 639 行代码中有 **87 个 if/elif 分支**，编译器需为每个分支生成类型检查和代码路径。

**对比**:
| 文件 | 行数 | if/elif 分支 | 分支密度 |
|------|------|-------------|---------|
| simulation_event_source | 192 | 16 | 8.3% |
| matcher.mojo | 639 | 87 | **13.6%** |
| events.mojo | 294 | 10 | 3.4% |

---

## 三、优化方案

### 方案 A: 创建分层构建配置（立即可实施）

创建 `build_profiles.sh` 脚本，根据目标文件的依赖自动选择最小 `-I` 集合：

| 配置层 | 适用场景 | -I 参数 | 预估减少解析量 |
|--------|---------|---------|---------------|
| `light` | simulation_event_source, plot, test 文件 | `.`, `morrow.mojo` | **-140,000 行** |
| `standard` | matcher, slippage, mod 文件 | + `argmojo/src` | **-120,000 行** |
| `full` | strategy_universe, adjust 等特殊文件 | 全部 5 个 | 0（不变） |

### 方案 B: 创建统一的 MojoBuild 工具脚本

```bash
#!/bin/bash
# mojo_build.sh — 智能选择最优编译参数
# 用法: ./mojo_build.sh <file.mojo> [run|build]
```

### 方案 C: 代码级优化（长期）

1. **拆分 const.mojo** 为按功能域的子模块（const_match.py, const_order.py 等）
2. **延迟导入** EmberJson/Numojo/bison 到实际使用的文件中
3. **简化 matcher.mojo 条件逻辑** — 提取公共模式为独立函数

---

## 四、预期效果

| 优化项 | 当前耗时 | 优化后预估 | 改善幅度 |
|--------|---------|-----------|---------|
| light 层编译（simulation_event_source） | >60s | **<10s** | **~85%↓** |
| standard 层编译（matcher） | >60s | **<20s** | **~67%↓** |
| full 层编译（strategy_universe） | >60s | >60s | 无变化 |

---

## 五、风险与兼容性

| 风险 | 概率 | 缓解措施 |
|------|------|---------|
| 精简 -I 导致链接失败 | 低 | 测试套件全覆盖验证 |
| 延迟导入改变运行时行为 | 无 | 不修改运行时 import 逻辑 |
| 构建脚本维护成本 | 低 | 单一入口点，易于更新 |
