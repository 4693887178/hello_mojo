# Enum 精简设计文档（最终版）

## 目标

将 `test_enum.mojo` 中的多个枚举类型的 `from_name` / `from_value` 方法从冗长的 if-elif 链改为字典 + reversed 遍历，消除代码重复。

## 方案：全局 name→Enum 字典 + reversed 遍历

### 核心思路

每个 enum 只维护**一个**全局字典 `name→Enum`（O(1) 查找），`from_value` 用 `reversed(List)` 遍历查找。

```
┌────────────────────────────────────────────────────────┐
│  全局 name→Enum 字典（每个 enum 1 个）                   │
│  + List[Self]（用于 from_value 遍历，reversed）          │
│  = 消除所有 if-elif 链                                 │
└────────────────────────────────────────────────────────┘
```

### Mojo 验证结果

| 特性 | 结论 |
|------|------|
| `reversed(List[T])` | ✅ 支持 |
| 枚举值放入 `List` | ✅ 只需 `ImplicitlyCopyable` |
| `Dict[String, Self]` | ✅ 可作为模块级全局变量 |
| from_value O(n) 遍历 | ✅ 可接受（金融回测场景） |

### 设计

#### 1. 枚举条目结构

```mojo
struct EnumEntry[T: EnumTrait]:
    var name: String
    var value: String
```

#### 2. 全局字典（每个 enum 1 个）

```mojo
var _EXECUTION_PHASE_BY_NAME = Dict[String, EXECUTION_PHASE]()
```

#### 3. 填充函数（模块级别）

```mojo
fn _fill_execution_phase():
    _EXECUTION_PHASE_BY_NAME["GLOBAL"] = EXECUTION_PHASE.GLOBAL
    _EXECUTION_PHASE_BY_NAME["ON_INIT"] = EXECUTION_PHASE.ON_INIT
    # ... 其他值
```

#### 4. from_name / from_value

```mojo
@staticmethod
fn from_name(name: String) -> Optional[EXECUTION_PHASE]:
    return _EXECUTION_PHASE_BY_NAME.get(name)

@staticmethod
fn from_value(value: String) -> Optional[EXECUTION_PHASE]:
    for v in reversed(_ALL_EXECUTION_PHASES):
        if v.value() == value:
            return v
    return None
```

其中 `_ALL_EXECUTION_PHASES` 是 `List[EXECUTION_PHASE]`，在 `_fill_execution_phase()` 中填充。

### 代码量对比

| 项目 | 当前行数 | 目标行数 | 减少 |
|------|---------|---------|------|
| EXECUTION_PHASE (~10值) | ~50行 | ~25行 | 50% |
| 每个其他enum (~5值) | ~30行 | ~15行 | 50% |

主要节省：`from_name` 和 `from_value` 中的所有 if-elif 链（每个 9-10 行 → 1-3 行）。

### 文件结构

```
rqmojo/
  ├── test_enum.mojo          # 精简后的枚举定义
  └── test_enum_factory.mojo  # 测试
```

### 验收标准

1. 所有现有 enum 的 `name()` / `value()` / `from_name()` / `from_value()` 行为保持不变
2. `from_name` / `from_value` 不再包含任何 if-elif 链
3. 运行时测试通过（LD_PRELOAD + PYTHONPATH + mojo run）
4. 代码行数减少 ≥50%

## 依赖关系

无外部依赖，使用 Mojo 0.26+ 内置类型（Dict, Optional, String, List, ReversedIterator）。
