# RQAlpha Mojo 重构计划

## 1. 项目概述

将 Python 量化交易框架 RQAlpha 重构为 Mojo 语言，保持功能、文件名、类名、函数名一致。

### 目标

- 将 ~140 个 Python 文件重构为 Mojo
- 保持 API 兼容性
- 支持 Python 和 Mojo 互操作

### 依赖工具

- Mojo 0.26.2.0
- Python 3.14

### 当前进度

- **文件已创建**: 140 个
- **文件待创建**: 0 个
- **测试通过**: 0 个
- **文件创建进度**: 100%
- **测试进度**: 0%

## 2. 目录结构

### 源代码结构 (Python)

```
/home/zhou/hello_mojo/.venv/lib/python3.14/site-packages/rqalpha/
├── __init__.py
├── __main__.py
├── _version.py
├── api.py
├── const.py
├── environment.py
├── interface.py
├── main.py
├── user_module.py
│
├── apis/                    # API 模块
│   ├── __init__.py
│   ├── api_abstract.py
│   ├── api_base.py
│   ├── api_future.py
│   ├── api_rqdatac.py
│   ├── api_stock.py
│   ├── names.py
│   └── order_target_portfolio.py
│
├── cmds/                    # 命令行模块
│   ├── __init__.py
│   ├── bundle.py
│   ├── entry.py
│   ├── misc.py
│   └── run.py
│
├── core/                    # 核心模块
│   ├── __init__.py
│   ├── events.py
│   ├── execution_context.py
│   ├── executor.py
│   ├── global_var.py
│   ├── strategy.py
│   ├── strategy_context.py
│   ├── strategy_loader.py
│   └── strategy_universe.py
│
├── data/                    # 数据模块
│   ├── __init__.py
│   ├── bar_dict_price_board.py
│   ├── bundle.py
│   ├── data_proxy.py
│   ├── instruments_mixin.py
│   ├── trading_dates_mixin.py
│   └── base_data_source/
│       ├── __init__.py
│       ├── adjust.py
│       ├── data_source.py
│       ├── deprecated.py
│       ├── storage_interface.py
│       └── storages.py
│
├── examples/                # 示例策略
│   ├── buy_and_hold.py
│   ├── golden_cross.py
│   ├── IF_macd.py
│   ├── macd.py
│   ├── pair_trading.py
│   ├── rsi.py
│   ├── run_code_demo.py
│   ├── run_file_demo.py
│   ├── run_func_demo.py
│   ├── subscribe_event.py
│   ├── test_pt.py
│   ├── turtle.py
│   ├── data_source/
│   └── extend_api/
│
├── model/                   # 数据模型
│   ├── __init__.py
│   ├── bar.py
│   ├── instrument.py
│   ├── order.py
│   ├── tick.py
│   └── trade.py
│
├── portfolio/               # 组合管理
│   ├── __init__.py
│   ├── account.py
│   └── position.py
│
├── utils/                   # 工具模块
│   ├── __init__.py
│   ├── arg_checker.py
│   ├── class_helper.py
│   ├── click_helper.py
│   ├── concurrent.py
│   ├── config.py
│   ├── datetime_func.py
│   ├── dict_func.py
│   ├── exception.py
│   ├── functools.py
│   ├── i18n.py
│   ├── log_capture.py
│   ├── logger.py
│   ├── package_helper.py
│   ├── persisit_helper.py
│   ├── repr.py
│   ├── risk_free_helper.py
│   ├── rq_json.py
│   ├── strategy_loader_help.py
│   └── typing.py
│
└── mod/                     # 扩展模块
    ├── __init__.py
    ├── utils.py
    ├── rqalpha_mod_sys_accounts/
    ├── rqalpha_mod_sys_analyser/
    ├── rqalpha_mod_sys_progress/
    ├── rqalpha_mod_sys_risk/
    ├── rqalpha_mod_sys_scheduler/
    ├── rqalpha_mod_sys_simulation/
    └── rqalpha_mod_sys_transaction_cost/
```

### 重构目标结构 (Mojo)

状态说明：
- 📝 `created`: 文件已创建，待测试
- ⏳ `pending`: 文件未创建
- ✅ `passed`: 测试通过

```
/home/zhou/hello_mojo/mojo_refactor/
├── rqmojo/                  # Mojo 重构代码
│   ├── __init__.mojo        📝 created
│   ├── _version.mojo        📝 created
│   ├── api.mojo             📝 created
│   ├── const.mojo           📝 created
│   ├── environment.mojo     📝 created
│   ├── interface.mojo       📝 created
│   ├── main.mojo            📝 created
│   ├── user_module.mojo     📝 created
│   │
│   ├── apis/
│   │   ├── __init__.mojo    📝 created
│   │   ├── api_abstract.mojo 📝 created
│   │   ├── api_base.mojo    📝 created
│   │   ├── api_rqdatac.mojo 📝 created
│   │   └── names.mojo       📝 created
│   │
│   ├── core/
│   │   ├── __init__.mojo    📝 created
│   │   ├── events.mojo      📝 created
│   │   ├── execution_context.mojo 📝 created
│   │   ├── executor.mojo    📝 created
│   │   ├── gvar.mojo        📝 created (原 global_var.py)
│   │   ├── strategy.mojo    📝 created
│   │   ├── strategy_context.mojo 📝 created
│   │   ├── strategy_loader.mojo 📝 created
│   │   └── strategy_universe.mojo 📝 created
│   │
│   ├── model/
│   │   ├── __init__.mojo    📝 created
│   │   ├── bar.mojo         📝 created
│   │   ├── instrument.mojo  📝 created
│   │   ├── order.mojo       📝 created
│   │   ├── tick.mojo        📝 created
│   │   └── trade.mojo       📝 created
│   │
│   ├── portfolio/
│   │   ├── __init__.mojo    📝 created
│   │   ├── account.mojo     📝 created
│   │   └── position.mojo    📝 created
│   │
│   ├── data/
│   │   ├── __init__.mojo    📝 created
│   │   ├── bar_dict_price_board.mojo 📝 created
│   │   ├── bundle.mojo      📝 created
│   │   ├── data_proxy.mojo  📝 created
│   │   ├── instruments_mixin.mojo 📝 created
│   │   ├── trading_dates_mixin.mojo 📝 created
│   │   └── base_data_source/
│   │       ├── __init__.mojo 📝 created
│   │       ├── adjust.mojo  📝 created
│   │       ├── data_source.mojo 📝 created
│   │       ├── deprecated.mojo 📝 created
│   │       ├── storage_interface.mojo 📝 created
│   │       └── storages.mojo 📝 created
│   │
│   ├── utils/
│   │   ├── __init__.mojo    📝 created
│   │   ├── arg_checker.mojo 📝 created
│   │   ├── class_helper.mojo 📝 created
│   │   ├── click_helper.mojo 📝 created
│   │   ├── concurrent.mojo  📝 created
│   │   ├── config.mojo      📝 created
│   │   ├── datetime_func.mojo 📝 created
│   │   ├── dict_func.mojo   📝 created
│   │   ├── exception.mojo   📝 created
│   │   ├── functools.mojo   📝 created
│   │   ├── i18n.mojo        📝 created
│   │   ├── log_capture.mojo 📝 created
│   │   ├── logger.mojo      📝 created
│   │   ├── package_helper.mojo 📝 created
│   │   ├── persist_helper.mojo 📝 created
│   │   ├── repr.mojo        📝 created
│   │   ├── risk_free_helper.mojo 📝 created
│   │   ├── rq_json.mojo     📝 created
│   │   ├── strategy_loader_help.mojo 📝 created
│   │   ├── typing.mojo      📝 created
│   │   └── testing/
│   │       ├── __init__.mojo 📝 created
│   │       ├── fixtures.mojo 📝 created
│   │       ├── integration.mojo 📝 created
│   │       └── mocking.mojo 📝 created
│   │
│   ├── examples/
│   │   ├── __init__.mojo    📝 created
│   │   ├── buy_and_hold.mojo 📝 created
│   │   ├── golden_cross.mojo 📝 created
│   │   ├── IF_macd.mojo     ⏳ pending
│   │   ├── macd.mojo        ⏳ pending
│   │   ├── pair_trading.mojo ⏳ pending
│   │   ├── rsi.mojo         ⏳ pending
│   │   ├── run_code_demo.mojo ⏳ pending
│   │   ├── run_file_demo.mojo ⏳ pending
│   │   ├── run_func_demo.mojo ⏳ pending
│   │   ├── subscribe_event.mojo ⏳ pending
│   │   ├── test_pt.mojo     ⏳ pending
│   │   ├── turtle.mojo      ⏳ pending
│   │   └── data_source/     ⏳ pending
│   │
│   ├── cmds/
│   │   ├── __init__.mojo    📝 created
│   │   ├── bundle.mojo      📝 created
│   │   ├── entry.mojo       📝 created
│   │   ├── misc.mojo        📝 created
│   │   ├── mod.mojo         📝 created
│   │   └── run.mojo         📝 created
│   │
│   └── mod/
│       ├── __init__.mojo    📝 created
│       ├── utils.mojo       📝 created
│       ├── rqmojo_mod_sys_accounts/
│       │   ├── __init__.mojo ⏳ pending
│       │   ├── mod.mojo     📝 created
│       │   ├── component_validator.mojo 📝 created
│       │   ├── position_model.mojo 📝 created
│       │   ├── position_validator.mojo 📝 created
│       │   ├── validator.mojo 📝 created
│       │   └── api/
│       │       ├── __init__.mojo 📝 created
│       │       ├── api_future.mojo 📝 created
│       │       ├── api_stock.mojo 📝 created
│       │       └── order_target_portfolio.mojo 📝 created
│       ├── rqmojo_mod_sys_analyser/
│       │   ├── __init__.mojo ⏳ pending
│       │   ├── mod.mojo     📝 created
│       │   ├── plot_store.mojo 📝 created
│       │   ├── plot/
│       │   │   ├── __init__.mojo 📝 created
│       │   │   ├── consts.mojo 📝 created
│       │   │   ├── plot.mojo 📝 created
│       │   │   └── utils.mojo 📝 created
│       │   └── report/
│       │       ├── __init__.mojo 📝 created
│       │       ├── excel_template.mojo 📝 created
│       │       └── report.mojo 📝 created
│       ├── rqmojo_mod_sys_progress/
│       │   ├── __init__.mojo 📝 created
│       │   └── mod.mojo     📝 created
│       ├── rqmojo_mod_sys_risk/
│       │   ├── __init__.mojo 📝 created
│       │   ├── mod.mojo     📝 created
│       │   ├── risk_manager.mojo 📝 created (额外添加)
│       │   └── validators/
│       │       ├── __init__.mojo 📝 created
│       │       ├── cash_validator.mojo 📝 created
│       │       ├── is_trading_validator.mojo 📝 created
│       │       ├── price_validator.mojo 📝 created
│       │       └── self_trade_validator.mojo 📝 created
│       ├── rqmojo_mod_sys_scheduler/
│       │   ├── __init__.mojo 📝 created
│       │   ├── mod.mojo     📝 created
│       │   └── scheduler.mojo 📝 created
│       ├── rqmojo_mod_sys_simulation/
│       │   ├── __init__.mojo 📝 created
│       │   ├── matcher.mojo 📝 created
│       │   ├── mod.mojo     📝 created
│       │   ├── signal_broker.mojo 📝 created
│       │   ├── simulation_broker.mojo 📝 created
│       │   ├── simulation_event_source.mojo 📝 created
│       │   ├── slippage.mojo 📝 created
│       │   ├── testing.mojo 📝 created
│       │   └── validator.mojo 📝 created
│       └── rqmojo_mod_sys_transaction_cost/
│           ├── __init__.mojo 📝 created
│           ├── deciders.mojo 📝 created
│           └── mod.mojo     📝 created
│
└── tests/                   # 测试目录 (待创建)
    ├── mojo/                # Mojo 测试文件
    │   ├── root/
    │   ├── apis/
    │   ├── core/
    │   ├── model/
    │   ├── portfolio/
    │   ├── data/
    │   ├── utils/
    │   ├── examples/
    │   └── mod/
    │
    ├── python/              # Python 测试文件
    │   └── ...
    │
    └── results/             # 测试结果文件
        └── ...
```

## 3. 测试要求

### 测试原则

- **测试条件一致**: Python 和 Mojo 测试使用相同的输入数据
- **输出一致**: 两个测试的输出结果必须完全相同才算通过
- **结果记录**: 每个测试完成后在 results/ 目录记录结果
- **任务完成标准**: 文件创建 + 测试通过 = 任务完成

### 测试结果格式 (RESULTS.md)

```markdown
# [模块名] 测试结果

## 测试时间
YYYY-MM-DD HH:MM:SS

## 测试条件
- 输入: [描述输入数据]
- 环境: Python 3.14 / Mojo 0.26.2.0

## Python 测试结果
\`\`\`
[Python 测试输出]
\`\`\`

## Mojo 测试结果
\`\`\`
[Mojo 测试输出]
\`\`\`

## 对比结果
- [ ] 输出一致
- [ ] 功能正确
- [ ] 性能对比

## 结论
[通过/失败]
```

## 4. 重构顺序

### 阶段 1: 基础模块 (无外部依赖) - 📝 文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 1 | const.mojo | created | pending |
| 2 | exception.mojo | created | pending |
| 3 | typing.mojo | created | pending |

### 阶段 2: 接口层 - 📝 文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 4 | interface.mojo | created | pending |
| 5 | events.mojo | created | pending |

### 阶段 3: 模型层 - 📝 文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 6 | instrument.mojo | created | pending |
| 7 | bar.mojo | created | pending |
| 8 | order.mojo | created | pending |
| 9 | trade.mojo | created | pending |

### 阶段 4: 核心层 - 📝 文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 10 | executor.mojo | created | pending |
| 11 | strategy.mojo | created | pending |

### 阶段 5: 组合层 - 📝 文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 12 | position.mojo | created | pending |
| 13 | account.mojo | created | pending |

### 阶段 6: 数据层 - 📝 文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 14 | data_proxy.mojo | created | pending |

### 阶段 7: 扩展模块 - 📝 大部分文件已创建，待测试

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 15-57 | mod 模块各文件 | 大部分 created | pending |

### 阶段 8: 示例模块 - ⏳ 大部分待创建

| 序号 | 文件 | 文件状态 | 测试状态 |
|------|------|---------|---------|
| 58-72 | examples 模块各文件 | 仅 2 个 created | pending |

## 5. 运行命令

### 编译 Mojo

```bash
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so \
PYTHONPATH=/home/zhou/hello_mojo/.venv/lib/python3.14/site-packages \
/home/zhou/hello_mojo/.venv/bin/mojo run -I . <file.mojo>
```

### 运行 Python 测试

```bash
/home/zhou/hello_mojo/.venv/bin/python -m pytest tests/python/
```

### 运行 Mojo 测试

```bash
LD_PRELOAD=/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so \
PYTHONPATH=/home/zhou/hello_mojo/.venv/lib/python3.14/site-packages \
/home/zhou/hello_mojo/.venv/bin/mojo run tests/mojo/<module>/test_<name>.mojo
```

## 6. 额外创建的文件

以下文件不在原始任务列表中，但为支持重构而额外创建：

| 文件路径 | 说明 | 测试状态 |
|----------|------|---------|
| rqmojo/test_version.mojo | 版本测试文件 | pending |
| rqmojo/portfolio_manager.mojo | 组合管理器 | pending |
| rqmojo/mod_system.mojo | 模块系统 | pending |
| rqmojo/utils/json_parser.mojo | JSON 解析器 | pending |
| rqmojo/utils/performance.mojo | 性能工具 | pending |
| rqmojo/utils/rq_logger.mojo | 日志工具 | pending |
| rqmojo/data/auto_update_bundle_mixin.mojo | 自动更新数据包 | pending |
| rqmojo/data/base_data_source/h5_reader.mojo | HDF5 读取器 | pending |
| rqmojo/mod/rqmojo_mod_sys_risk/risk_manager.mojo | 风险管理器 | pending |

## 7. 下一步工作

### 优先级 1: 建立测试框架

1. 创建 tests/ 目录结构
2. 编写测试工具和辅助函数
3. 定义测试标准和流程

### 优先级 2: 完成剩余文件创建

1. **T002**: __main__.mojo - 入口模块
2. **T094**: mod/rqmojo_mod_sys_accounts/__init__.mojo
3. **T104**: mod/rqmojo_mod_sys_analyser/__init__.mojo
4. **T079-T091**: examples 模块剩余 13 个示例文件
5. **T138-T140**: extend_api 示例和 LC_MESSAGES 翻译文件

### 优先级 3: 执行测试

对所有已创建的 110 个 mojo 文件进行 Python vs Mojo 对比测试，测试通过后更新状态为 `passed`。
