# PROJECT.md

## Project: RQAlpha Mojo Refactoring

### Overview
将 Python 量化交易框架 RQAlpha 使用 Mojo 语言重构，保持功能、文件名称、类名、函数、方法名一致。

### Tech Stack
- **Python**: 3.14 (UV 安装)
- **Mojo**: 0.26.2.0 (UV 安装)
- **Python RQAlpha**: `.venv/lib/python3.14/site-packages/rqalpha`
- **Mojo RQMojo**: `mojo_refactor/rqmojo`

### Project Structure
```
mojo_refactor/
├── rqmojo/                    # Mojo 重构代码
│   ├── third_party/           # 第三方 Mojo 包
│   │   ├── argmojo/           # 命令行参数解析
│   │   ├── EmberJson/         # JSON 解析
│   │   ├── NuMojo/            # 数值计算
│   │   ├── mojo-yaml/         # YAML 解析
│   │   └── morrow.mojo/       # 日期时间处理
│   └── ...
├── tests/
│   ├── python/                # Python 测试文件
│   ├── mojo/                  # Mojo 测试文件
│   └── results/               # 测试结果 (MD格式)
└── docs/                      # 文档
```

### Milestones

#### Milestone 1: 基础模块重构 (Group 01-09)
**Status**: ✅ Completed
**Description**: 完成依赖数量 0-5 的基础模块重构

**Completed Groups**:
- Group 01: 无依赖基础模块 (10 files)
- Group 02: 依赖数量 0-1 模块 (10 files)
- Group 03: 依赖数量 1-2 模块 (10 files)
- Group 04: 依赖数量 2 模块 (10 files)
- Group 05: 依赖数量 2 模块 (10 files)
- Group 06: 依赖数量 2-3 模块 (10 files)
- Group 07: 依赖数量 3-4 模块 (10 files)
- Group 08: 依赖数量 4 模块 (10 files)
- Group 09: 依赖数量 4-5 模块 (10 files)

#### Milestone 2: 高级业务层重构 (Group 10-12)
**Status**: 🔄 In Progress
**Description**: 完成依赖数量 5-10 的高级业务层模块重构

**Groups**:
- Group 10: 依赖数量 5-6 模块 (10 files) - 待重构
- Group 11: 依赖数量 6 模块 (10 files) - 待重构
- Group 12: 依赖数量 7-10 模块 (10 files) - 待重构

#### Milestone 3: 入口层重构 (Group 13)
**Status**: ⏳ Pending
**Description**: 完成依赖数量 15+ 的入口层模块重构

**Groups**:
- Group 13: 依赖数量 15+ 模块 (3 files)

### Current Milestone: Milestone 2 - 高级业务层重构 (Group 10-12)

**Goal**: 完成 Group 10-12 的 Mojo 重构和测试验证

**Target**:
- Group 10: 10 个文件的 Mojo 重构 (依赖数量 5-6)
- Group 11: 10 个文件的 Mojo 重构 (依赖数量 6)
- Group 12: 10 个文件的 Mojo 重构 (依赖数量 7-10)

**Group 10 文件列表**:
1. `interface.py` - 依赖数量 5
2. `mod/rqalpha_mod_sys_accounts/mod.py` - 依赖数量 5
3. `mod/rqalpha_mod_sys_accounts/position_validator.py` - 依赖数量 5
4. `mod/rqalpha_mod_sys_analyser/plot/plot.py` - 依赖数量 5
5. `mod/rqalpha_mod_sys_simulation/matcher.py` - 依赖数量 5
6. `mod/rqalpha_mod_sys_simulation/simulation_event_source.py` - 依赖数量 5
7. `model/order.py` - 依赖数量 5
8. `model/trade.py` - 依赖数量 5
9. `utils/__init__.py` - 依赖数量 5
10. `apis/__init__.py` - 依赖数量 6

**Group 11 文件列表**:
1. `apis/api_abstract.py` - 依赖数量 6
2. `cmds/__init__.py` - 依赖数量 6
3. `environment.py` - 依赖数量 6
4. `mod/rqalpha_mod_sys_risk/validators/cash_validator.py` - 依赖数量 6
5. `mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py` - 依赖数量 6
6. `mod/rqalpha_mod_sys_simulation/simulation_broker.py` - 依赖数量 6
7. `mod/rqalpha_mod_sys_accounts/api/order_target_portfolio.py` - 依赖数量 6
8. `mod/rqalpha_mod_sys_accounts/api/api_future.py` - 依赖数量 6
9. `model/bar.py` - 依赖数量 6
10. `data/base_data_source/storages.py` - 依赖数量 6

**Group 12 文件列表**:
1. `mod/rqalpha_mod_sys_accounts/api/api_stock.py` - 依赖数量 7
2. `apis/api_rqdatac.py` - 依赖数量 7
3. `mod/rqalpha_mod_sys_accounts/position_model.py` - 依赖数量 8
4. `data/data_proxy.py` - 依赖数量 8
5. `portfolio/__init__.py` - 依赖数量 8
6. `portfolio/position.py` - 依赖数量 8
7. `portfolio/account.py` - 依赖数量 8
8. `apis/api_base.py` - 依赖数量 9
9. `utils/testing/fixtures.py` - 依赖数量 9
10. `data/base_data_source/data_source.py` - 依赖数量 10

**Tasks**:
- [ ] Group 10 Mojo 代码重构
- [ ] Group 10 Mojo 测试验证
- [ ] Group 11 Mojo 代码重构
- [ ] Group 11 Mojo 测试验证
- [ ] Group 12 Mojo 代码重构
- [ ] Group 12 Mojo 测试验证

### Progress Summary

| Milestone | Status | Files |
|-----------|--------|-------|
| Milestone 1 (Group 01-09) | ✅ Completed | 90 |
| Milestone 2 (Group 10-12) | 🔄 In Progress | 30 |
| Milestone 3 (Group 13) | ⏳ Pending | 3 |
| **Total** | **75% Refactored** | **123** |

### Key Decisions
1. 使用工厂函数模式 (`create_*()`) 替代直接构造函数
2. 使用 struct 替代 dict 进行配置
3. 保留 Python 命名规范，但允许 Mojo 特定优化
4. 不支持 Python 特有功能（如 context manager, decorator）时提供替代方案

### Notes
- Mojo 编译需要预加载 Python 动态库
- 运行命令示例见 project_rules.md
