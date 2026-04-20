# REQUIREMENTS.md

## Milestone 3: 业务层重构 (Group 08-09)

### Overview
完成 RQAlpha 框架中依赖数量 4-5 的业务层模块的 Mojo 重构。

### Goals
1. 完成 Group 08 (10 files) 的 Mojo 重构
2. 完成 Group 09 (10 files) 的 Mojo 重构
3. 确保所有重构模块通过 Mojo 测试验证
4. 保持与 Python 版本的功能一致性

### Scope

#### Group 08: 依赖数量 4 模块 (10 files)

| 序号 | 文件路径 | 依赖模块 |
|-----|---------|---------|
| 1 | `cmds/run.py` | `rqalpha.utils.i18n`, `rqalpha.utils.click_helper`, `rqalpha.utils.config`, `rqalpha.cmds.entry` |
| 2 | `core/strategy_context.py` | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger` |
| 3 | `data/base_data_source/storage_interface.py` | `rqalpha.model.instrument`, `rqalpha.utils.typing`, `rqalpha.const`, `.deprecated` |
| 4 | `data/instruments_mixin.py` | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception` |
| 5 | `data/trading_dates_mixin.py` | `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.interface` |
| 6 | `mod/__init__.py` | `rqalpha.interface`, `rqalpha.utils.logger`, `rqalpha.utils.i18n`, `rqalpha.utils` |
| 7 | `mod/rqalpha_mod_sys_accounts/component_validator.py` | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception` |
| 8 | `mod/rqalpha_mod_sys_accounts/validator.py` | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception` |
| 9 | `mod/rqalpha_mod_sys_analyser/mod.py` | `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.const`, `rqalpha.utils.i18n` |
| 10 | `mod/rqalpha_mod_sys_analyser/plot_store.py` | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger` |

#### Group 09: 依赖数量 4-5 模块 (10 files)

| 序号 | 文件路径 | 依赖模块 |
|-----|---------|---------|
| 1 | `mod/rqalpha_mod_sys_analyser/report/report.py` | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils.datetime_func`, `rqalpha.utils.logger` |
| 2 | `mod/rqalpha_mod_sys_risk/validators/price_validator.py` | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception` |
| 3 | `mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py` | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception` |
| 4 | `mod/rqalpha_mod_sys_scheduler/scheduler.py` | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger` |
| 5 | `mod/rqalpha_mod_sys_simulation/mod.py` | `rqalpha.core.events`, `rqalpha.utils.logger`, `rqalpha.interface`, `rqalpha.const` |
| 6 | `mod/rqalpha_mod_sys_simulation/signal_broker.py` | `rqalpha.interface`, `rqalpha.utils.logger`, `rqalpha.utils.i18n`, `rqalpha.core.events` |
| 7 | `mod/rqalpha_mod_sys_simulation/testing.py` | `rqalpha.const`, `rqalpha.interface`, `rqalpha.environment`, `rqalpha.model` |
| 8 | `model/instrument.py` | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.repr` |
| 9 | `core/strategy.py` | `rqalpha.utils.logger`, `rqalpha.core.events`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`, `rqalpha.const` |
| 10 | `data/bundle.py` | `rqalpha.apis.api_rqdatac`, `rqalpha.utils.concurrent`, `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.utils.functools` |

### Requirements

#### Functional Requirements
1. **FR-01**: 所有重构模块必须保持与 Python 版本相同的公共 API
2. **FR-02**: 所有重构模块必须通过对应的 Mojo 单元测试
3. **FR-03**: 所有重构模块必须正确处理依赖关系
4. **FR-04**: 所有重构模块必须支持 Mojo 0.26.2.0 语法

#### Non-Functional Requirements
1. **NFR-01**: 代码可读性：保持与 Python 版本一致的命名规范
2. **NFR-02**: 性能：Mojo 版本应至少与 Python 版本性能相当
3. **NFR-03**: 可维护性：使用工厂函数模式替代复杂构造函数

#### Technical Requirements
1. **TR-01**: 使用 `struct` 替代 `dict` 进行配置
2. **TR-02**: 使用 `TrivialRegisterPassable` 或 `RegisterPassable` trait 优化性能
3. **TR-03**: 正确处理所有权转移（使用 `^` 运算符）
4. **TR-04**: 添加必要的 `Copyable` 和 `ImplicitlyCopyable` traits

### Acceptance Criteria
1. ✅ 所有 20 个文件完成 Mojo 重构
2. ✅ 所有 Mojo 测试通过
3. ✅ 代码通过 Mojo 编译器检查
4. ✅ 功能与 Python 版本一致

### Dependencies

#### Prerequisites
- Milestone 1 (Group 01-07) 已完成
- Milestone 2 (Group 10-12) 已完成
- 所有依赖模块已重构并通过测试

#### External Dependencies
- Mojo 0.26.2.0
- Python 3.14 (用于互操作测试)
- 第三方 Mojo 包 (argmojo, EmberJson, NuMojo, mojo-yaml, morrow)

### Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Python 互操作问题 | High | 使用预加载 Python 动态库方式 |
| 所有权转移错误 | Medium | 仔细处理 `^` 运算符和引用 |
| Trait 缺失 | Medium | 添加必要的 trait 声明 |
| 编译时间过长 | Low | 分组编译，增量测试 |

### Timeline
- **Phase 1**: Group 08 重构 (2-3 hours)
- **Phase 2**: Group 08 测试验证 (1-2 hours)
- **Phase 3**: Group 09 重构 (2-3 hours)
- **Phase 4**: Group 09 测试验证 (1-2 hours)

**Total Estimated Time**: 6-10 hours
