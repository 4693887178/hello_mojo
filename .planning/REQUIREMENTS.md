# REQUIREMENTS.md

## Milestone: 完成剩余模块重构

**Version**: 1.0
**Created**: 2026-03-26
**Status**: Active

---

## 1. Overview

### 1.1 Purpose
完成 RQAlpha 框架到 RQMojo 的剩余 23 个文件重构，实现完整的量化交易框架迁移。

### 1.2 Scope
- Group 08: 10 个文件（依赖数量 4）
- Group 09: 10 个文件（依赖数量 4-5）
- Group 13: 3 个文件（依赖数量 15+）

### 1.3 Success Criteria
- 所有 23 个文件完成 Mojo 重构
- Python 测试 100% 通过
- Mojo 测试 100% 通过
- 函数签名与 Python 版本一致

---

## 2. Functional Requirements

### 2.1 Group 08 Requirements

#### FR-08-01: cmds/run.py
- **Description**: CLI 运行命令模块
- **Dependencies**: `rqalpha.utils.i18n`, `rqalpha.utils.click_helper`, `rqalpha.utils.config`, `rqalpha.cmds.entry`
- **Acceptance Criteria**:
  - 支持命令行参数解析
  - 支持配置文件加载
  - 支持策略运行

#### FR-08-02: core/strategy_context.py
- **Description**: 策略上下文模块
- **Dependencies**: `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger`
- **Acceptance Criteria**:
  - 提供策略执行上下文
  - 支持事件订阅
  - 支持日志记录

#### FR-08-03: data/base_data_source/storage_interface.py
- **Description**: 存储接口模块
- **Dependencies**: `rqalpha.model.instrument`, `rqalpha.utils.typing`, `rqalpha.const`, `.deprecated`
- **Acceptance Criteria**:
  - 定义存储接口
  - 支持仪器数据存储
  - 支持类型检查

#### FR-08-04: data/instruments_mixin.py
- **Description**: 仪器混入类模块
- **Dependencies**: `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`
- **Acceptance Criteria**:
  - 提供仪器数据访问接口
  - 支持仪器查询
  - 支持异常处理

#### FR-08-05: data/trading_dates_mixin.py
- **Description**: 交易日期混入类模块
- **Dependencies**: `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.interface`
- **Acceptance Criteria**:
  - 提供交易日期查询接口
  - 支持日期范围计算
  - 支持交易日历

#### FR-08-06: mod/__init__.py
- **Description**: 模块初始化
- **Dependencies**: `rqalpha.interface`, `rqalpha.utils.logger`, `rqalpha.utils.i18n`, `rqalpha.utils`
- **Acceptance Criteria**:
  - 正确导出模块接口
  - 支持模块加载
  - 支持日志记录

#### FR-08-07: mod/rqalpha_mod_sys_accounts/component_validator.py
- **Description**: 组件验证器模块
- **Dependencies**: `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`
- **Acceptance Criteria**:
  - 验证账户组件
  - 支持多种账户类型
  - 提供详细错误信息

#### FR-08-08: mod/rqalpha_mod_sys_accounts/validator.py
- **Description**: 账户验证器模块
- **Dependencies**: `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`
- **Acceptance Criteria**:
  - 验证账户配置
  - 验证订单合法性
  - 提供验证结果

#### FR-08-09: mod/rqalpha_mod_sys_analyser/mod.py
- **Description**: 分析器模块
- **Dependencies**: `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.const`, `rqalpha.utils.i18n`
- **Acceptance Criteria**:
  - 支持策略分析
  - 支持性能统计
  - 支持报告生成

#### FR-08-10: mod/rqalpha_mod_sys_analyser/plot_store.py
- **Description**: 图表存储模块
- **Dependencies**: `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger`
- **Acceptance Criteria**:
  - 存储图表数据
  - 支持事件监听
  - 支持数据序列化

---

### 2.2 Group 09 Requirements

#### FR-09-01: mod/rqalpha_mod_sys_analyser/report/report.py
- **Description**: 报告生成模块
- **Dependencies**: `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils.datetime_func`, `rqalpha.utils.logger`
- **Acceptance Criteria**:
  - 生成分析报告
  - 支持多种报告格式
  - 支持日期格式化

#### FR-09-02: mod/rqalpha_mod_sys_risk/validators/price_validator.py
- **Description**: 价格验证器模块
- **Dependencies**: `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`
- **Acceptance Criteria**:
  - 验证价格合法性
  - 支持涨跌停检查
  - 提供详细错误信息

#### FR-09-03: mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py
- **Description**: 自交易验证器模块
- **Dependencies**: `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`
- **Acceptance Criteria**:
  - 检测自交易行为
  - 防止违规交易
  - 提供警告信息

#### FR-09-04: mod/rqalpha_mod_sys_scheduler/scheduler.py
- **Description**: 调度器模块
- **Dependencies**: `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger`
- **Acceptance Criteria**:
  - 支持定时任务
  - 支持事件触发
  - 支持任务取消

#### FR-09-05: mod/rqalpha_mod_sys_simulation/mod.py
- **Description**: 模拟模块
- **Dependencies**: `rqalpha.core.events`, `rqalpha.utils.logger`, `rqalpha.interface`, `rqalpha.const`
- **Acceptance Criteria**:
  - 支持模拟交易
  - 支持订单撮合
  - 支持事件发布

#### FR-09-06: mod/rqalpha_mod_sys_simulation/signal_broker.py
- **Description**: 信号经纪商模块
- **Dependencies**: `rqalpha.interface`, `rqalpha.utils.logger`, `rqalpha.utils.i18n`, `rqalpha.core.events`
- **Acceptance Criteria**:
  - 处理交易信号
  - 支持信号转换
  - 支持事件通知

#### FR-09-07: mod/rqalpha_mod_sys_simulation/testing.py
- **Description**: 测试工具模块
- **Dependencies**: `rqalpha.const`, `rqalpha.interface`, `rqalpha.environment`, `rqalpha.model`
- **Acceptance Criteria**:
  - 提供测试辅助函数
  - 支持模拟环境
  - 支持数据模拟

#### FR-09-08: model/instrument.py
- **Description**: 仪器模型模块
- **Dependencies**: `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.repr`
- **Acceptance Criteria**:
  - 定义仪器数据结构
  - 支持多种仪器类型
  - 支持数据序列化

#### FR-09-09: core/strategy.py
- **Description**: 策略核心模块
- **Dependencies**: `rqalpha.utils.logger`, `rqalpha.core.events`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`, `rqalpha.const`
- **Acceptance Criteria**:
  - 管理策略生命周期
  - 支持策略初始化
  - 支持策略执行

#### FR-09-10: data/bundle.py
- **Description**: 数据包模块
- **Dependencies**: `rqalpha.apis.api_rqdatac`, `rqalpha.utils.concurrent`, `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.utils.functools`
- **Acceptance Criteria**:
  - 管理数据包
  - 支持数据下载
  - 支持数据更新

---

### 2.3 Group 13 Requirements

#### FR-13-01: main.py
- **Description**: 主入口模块
- **Dependencies**: 15 个内部模块
- **Acceptance Criteria**:
  - 提供主入口函数 `run()`
  - 初始化所有组件
  - 协调策略执行流程

#### FR-13-02: __init__.py
- **Description**: 包初始化模块
- **Dependencies**: 20 个内部模块
- **Acceptance Criteria**:
  - 导出所有公共 API
  - 设置版本信息
  - 初始化包配置

#### FR-13-03: utils/testing/integration.py
- **Description**: 集成测试模块
- **Dependencies**: `rqalpha`
- **Acceptance Criteria**:
  - 提供集成测试工具
  - 支持端到端测试
  - 支持测试数据管理

---

## 3. Non-Functional Requirements

### 3.1 Performance
- NFR-01: Mojo 版本性能不低于 Python 版本
- NFR-02: 编译时间在合理范围内

### 3.2 Compatibility
- NFR-03: 保持与 Python 版本的 API 兼容性
- NFR-04: 支持跨平台（Linux）

### 3.3 Maintainability
- NFR-05: 代码风格符合 Mojo 规范
- NFR-06: 提供完整的测试覆盖
- NFR-07: 文档完整准确

---

## 4. Constraints

### 4.1 Technical Constraints
- C-01: 使用 Mojo 0.26.2.0 版本
- C-02: 使用 Python 3.14 版本
- C-03: 需要预加载 Python 动态库

### 4.2 Process Constraints
- C-04: 按依赖顺序重构
- C-05: 每个文件需要完整的测试
- C-06: 保持函数签名一致

---

## 5. Dependencies

### 5.1 Internal Dependencies
- Group 08 依赖 Group 07 已完成
- Group 09 依赖 Group 08
- Group 13 依赖所有其他组

### 5.2 External Dependencies
- Mojo 标准库
- 第三方 Mojo 包（argmojo, EmberJson, NuMojo, mojo-yaml, morrow）
- Python 互操作

---

## 6. Risks

| Risk ID | Description | Probability | Impact | Mitigation |
|---------|-------------|-------------|--------|------------|
| R-01 | Group 13 高依赖复杂度 | High | High | 最后重构，确保依赖稳定 |
| R-02 | Mojo-Python 互操作问题 | Medium | Medium | 使用预加载方案 |
| R-03 | 测试覆盖不足 | Medium | High | 创建完整测试套件 |
| R-04 | 性能下降 | Low | Medium | 性能基准测试 |
