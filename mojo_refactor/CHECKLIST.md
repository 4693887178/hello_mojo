# RQAlpha Mojo 重构检查清单

## 统计信息

- **总文件数**: 140 个 Python 文件
- **总任务数**: 140 个任务
- **文件已创建**: 140 个
- **文件待创建**: 0 个
- **测试通过**: 0 个
- **总体进度**: 0% (按测试通过计算)

## 状态说明

- `pending`: 任务未完成（测试未通过）
- `passed`: 测试通过（文件创建 + 测试通过）

**注意**: 根据任务完成标准，"文件创建 + 测试通过 = 任务完成"。所有文件已创建完成，但测试尚未通过。

## 阶段 1: 根目录文件 (9个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T001 | __init__.py → __init__.mojo | passed |
| T002 | __main__.py → __main__.mojo | passed |
| T003 | _version.py → _version.mojo | passed |
| T004 | api.py → api.mojo | passed |
| T005 | const.py → const.mojo | passed |
| T006 | environment.py → environment.mojo | pending |
| T007 | interface.py → interface.mojo | pending |
| T008 | main.py → main.mojo | pending |
| T009 | user_module.py → user_module.mojo | pending |

## 阶段 2: apis 模块 (5个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T010 | apis/__init__.py → __init__.mojo | pending |
| T011 | apis/api_abstract.py → api_abstract.mojo | pending |
| T012 | apis/api_base.py → api_base.mojo | pending |
| T013 | apis/api_rqdatac.py → api_rqdatac.mojo | pending |
| T014 | apis/names.py → names.mojo | pending |

## 阶段 3: cmds 模块 (6个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T015 | cmds/__init__.py → __init__.mojo | pending |
| T016 | cmds/bundle.py → bundle.mojo | pending |
| T017 | cmds/entry.py → entry.mojo | pending |
| T018 | cmds/misc.py → misc.mojo | pending |
| T019 | cmds/mod.py → mod.mojo | pending |
| T020 | cmds/run.py → run.mojo | pending |

## 阶段 4: core 模块 (9个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T021 | core/__init__.py → __init__.mojo | pending |
| T022 | core/events.py → events.mojo | pending |
| T023 | core/execution_context.py → execution_context.mojo | pending |
| T024 | core/executor.py → executor.mojo | pending |
| T025 | core/global_var.py → gvar.mojo | pending |
| T026 | core/strategy.py → strategy.mojo | pending |
| T027 | core/strategy_context.py → strategy_context.mojo | pending |
| T028 | core/strategy_loader.py → strategy_loader.mojo | pending |
| T029 | core/strategy_universe.py → strategy_universe.mojo | pending |

## 阶段 5: data 模块 (12个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T030 | data/__init__.py → __init__.mojo | pending |
| T031 | data/bar_dict_price_board.py → bar_dict_price_board.mojo | pending |
| T032 | data/bundle.py → bundle.mojo | pending |
| T033 | data/data_proxy.py → data_proxy.mojo | pending |
| T034 | data/instruments_mixin.py → instruments_mixin.mojo | pending |
| T035 | data/trading_dates_mixin.py → trading_dates_mixin.mojo | pending |
| T036 | data/base_data_source/__init__.py → __init__.mojo | pending |
| T037 | data/base_data_source/adjust.py → adjust.mojo | pending |
| T038 | data/base_data_source/data_source.py → data_source.mojo | pending |
| T039 | data/base_data_source/deprecated.py → deprecated.mojo | pending |
| T040 | data/base_data_source/storage_interface.py → storage_interface.mojo | pending |
| T041 | data/base_data_source/storages.py → storages.mojo | pending |

## 阶段 6: model 模块 (6个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T042 | model/__init__.py → __init__.mojo | pending |
| T043 | model/bar.py → bar.mojo | pending |
| T044 | model/instrument.py → instrument.mojo | pending |
| T045 | model/order.py → order.mojo | pending |
| T046 | model/tick.py → tick.mojo | pending |
| T047 | model/trade.py → trade.mojo | pending |

## 阶段 7: portfolio 模块 (3个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T048 | portfolio/__init__.py → __init__.mojo | pending |
| T049 | portfolio/account.py → account.mojo | pending |
| T050 | portfolio/position.py → position.mojo | pending |

## 阶段 8: utils 模块 (26个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T051 | utils/__init__.py → __init__.mojo | pending |
| T052 | utils/arg_checker.py → arg_checker.mojo | pending |
| T053 | utils/class_helper.py → class_helper.mojo | pending |
| T054 | utils/click_helper.py → click_helper.mojo | pending |
| T055 | utils/concurrent.py → concurrent.mojo | pending |
| T056 | utils/config.py → config.mojo | pending |
| T057 | utils/datetime_func.py → datetime_func.mojo | pending |
| T058 | utils/dict_func.py → dict_func.mojo | pending |
| T059 | utils/exception.py → exception.mojo | pending |
| T060 | utils/functools.py → functools.mojo | pending |
| T061 | utils/i18n.py → i18n.mojo | pending |
| T062 | utils/log_capture.py → log_capture.mojo | pending |
| T063 | utils/logger.py → logger.mojo | pending |
| T064 | utils/package_helper.py → package_helper.mojo | pending |
| T065 | utils/persisit_helper.py → persist_helper.mojo | pending |
| T066 | utils/repr.py → repr.mojo | pending |
| T067 | utils/risk_free_helper.py → risk_free_helper.mojo | pending |
| T068 | utils/rq_json.py → rq_json.mojo | pending |
| T069 | utils/strategy_loader_help.py → strategy_loader_help.mojo | pending |
| T070 | utils/typing.py → typing.mojo | pending |
| T071 | utils/testing/__init__.py → __init__.mojo | pending |
| T072 | utils/testing/fixtures.py → fixtures.mojo | pending |
| T073 | utils/testing/integration.py → integration.mojo | pending |
| T074 | utils/testing/mocking.py → mocking.mojo | pending |
| T075 | utils/translations/__init__.py → __init__.mojo | pending |
| T076 | utils/translations/zh_Hans_CN/__init__.py → __init__.mojo | pending |

## 阶段 9: examples 模块 (15个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T077 | examples/buy_and_hold.py → buy_and_hold.mojo | pending |
| T078 | examples/golden_cross.py → golden_cross.mojo | pending |
| T079 | examples/IF_macd.py → IF_macd.mojo | pending |
| T080 | examples/macd.py → macd.mojo | pending |
| T081 | examples/pair_trading.py → pair_trading.mojo | pending |
| T082 | examples/rsi.py → rsi.mojo | pending |
| T083 | examples/run_code_demo.py → run_code_demo.mojo | pending |
| T084 | examples/run_file_demo.py → run_file_demo.mojo | pending |
| T085 | examples/run_func_demo.py → run_func_demo.mojo | pending |
| T086 | examples/subscribe_event.py → subscribe_event.mojo | pending |
| T087 | examples/test_pt.py → test_pt.mojo | pending |
| T088 | examples/turtle.py → turtle.mojo | pending |
| T089 | examples/data_source/get_csv_module.py → get_csv_module.mojo | pending |
| T090 | examples/data_source/import_get_csv_module.py → import_get_csv_module.mojo | pending |
| T091 | examples/data_source/read_csv_as_df.py → read_csv_as_df.mojo | pending |

## 阶段 10: mod 模块 (49个任务)

| ID | 任务 | 状态 |
|----|------|------|
| T092 | mod/__init__.py → __init__.mojo | pending |
| T093 | mod/utils.py → utils.mojo | pending |
| T094 | mod/rqalpha_mod_sys_accounts/__init__.py → __init__.mojo | pending |
| T095 | mod/rqalpha_mod_sys_accounts/mod.py → mod.mojo | pending |
| T096 | mod/rqalpha_mod_sys_accounts/component_validator.py → component_validator.mojo | pending |
| T097 | mod/rqalpha_mod_sys_accounts/position_model.py → position_model.mojo | pending |
| T098 | mod/rqalpha_mod_sys_accounts/position_validator.py → position_validator.mojo | pending |
| T099 | mod/rqalpha_mod_sys_accounts/validator.py → validator.mojo | pending |
| T100 | mod/rqalpha_mod_sys_accounts/api/__init__.py → __init__.mojo | pending |
| T101 | mod/rqalpha_mod_sys_accounts/api/api_future.py → api_future.mojo | pending |
| T102 | mod/rqalpha_mod_sys_accounts/api/api_stock.py → api_stock.mojo | pending |
| T103 | mod/rqalpha_mod_sys_accounts/api/order_target_portfolio.py → order_target_portfolio.mojo | pending |
| T104 | mod/rqalpha_mod_sys_analyser/__init__.py → __init__.mojo | pending |
| T105 | mod/rqalpha_mod_sys_analyser/mod.py → mod.mojo | pending |
| T106 | mod/rqalpha_mod_sys_analyser/plot_store.py → plot_store.mojo | pending |
| T107 | mod/rqalpha_mod_sys_analyser/plot/__init__.py → __init__.mojo | pending |
| T108 | mod/rqalpha_mod_sys_analyser/plot/consts.py → consts.mojo | pending |
| T109 | mod/rqalpha_mod_sys_analyser/plot/plot.py → plot.mojo | pending |
| T110 | mod/rqalpha_mod_sys_analyser/plot/utils.py → utils.mojo | pending |
| T111 | mod/rqalpha_mod_sys_analyser/report/__init__.py → __init__.mojo | pending |
| T112 | mod/rqalpha_mod_sys_analyser/report/excel_template.py → excel_template.mojo | pending |
| T113 | mod/rqalpha_mod_sys_analyser/report/report.py → report.mojo | pending |
| T114 | mod/rqalpha_mod_sys_progress/__init__.py → __init__.mojo | pending |
| T115 | mod/rqalpha_mod_sys_progress/mod.py → mod.mojo | pending |
| T116 | mod/rqalpha_mod_sys_risk/__init__.py → __init__.mojo | pending |
| T117 | mod/rqalpha_mod_sys_risk/mod.py → mod.mojo | pending |
| T118 | mod/rqalpha_mod_sys_risk/validators/__init__.py → __init__.mojo | pending |
| T119 | mod/rqalpha_mod_sys_risk/validators/cash_validator.py → cash_validator.mojo | pending |
| T120 | mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py → is_trading_validator.mojo | pending |
| T121 | mod/rqalpha_mod_sys_risk/validators/price_validator.py → price_validator.mojo | pending |
| T122 | mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py → self_trade_validator.mojo | pending |
| T123 | mod/rqalpha_mod_sys_scheduler/__init__.py → __init__.mojo | pending |
| T124 | mod/rqalpha_mod_sys_scheduler/mod.py → mod.mojo | pending |
| T125 | mod/rqalpha_mod_sys_scheduler/scheduler.py → scheduler.mojo | pending |
| T126 | mod/rqalpha_mod_sys_simulation/__init__.py → __init__.mojo | pending |
| T127 | mod/rqalpha_mod_sys_simulation/matcher.py → matcher.mojo | pending |
| T128 | mod/rqalpha_mod_sys_simulation/mod.py → mod.mojo | pending |
| T129 | mod/rqalpha_mod_sys_simulation/signal_broker.py → signal_broker.mojo | pending |
| T130 | mod/rqalpha_mod_sys_simulation/simulation_broker.py → simulation_broker.mojo | pending |
| T131 | mod/rqalpha_mod_sys_simulation/simulation_event_source.py → simulation_event_source.mojo | pending |
| T132 | mod/rqalpha_mod_sys_simulation/slippage.py → slippage.mojo | pending |
| T133 | mod/rqalpha_mod_sys_simulation/testing.py → testing.mojo | pending |
| T134 | mod/rqalpha_mod_sys_simulation/validator.py → validator.mojo | pending |
| T135 | mod/rqalpha_mod_sys_transaction_cost/__init__.py → __init__.mojo | pending |
| T136 | mod/rqalpha_mod_sys_transaction_cost/deciders.py → deciders.mojo | pending |
| T137 | mod/rqalpha_mod_sys_transaction_cost/mod.py → mod.mojo | pending |
| T138 | examples/extend_api/rqalpha_mod_extend_api_demo.py → rqalpha_mod_extend_api_demo.mojo | pending |
| T139 | examples/extend_api/test_extend_api.py → test_extend_api.mojo | pending |
| T140 | utils/translations/zh_Hans_CN/LC_MESSAGES/__init__.py → __init__.mojo | pending |

## 总体进度

| 阶段 | 任务数 | 文件已创建 | 测试通过 | 文件进度 | 测试进度 |
|------|--------|-----------|---------|---------|---------|
| 阶段1: root | 9 | 9 | 0 | 100% | 0% |
| 阶段2: apis | 5 | 5 | 0 | 100% | 0% |
| 阶段3: cmds | 6 | 6 | 0 | 100% | 0% |
| 阶段4: core | 9 | 9 | 0 | 100% | 0% |
| 阶段5: data | 12 | 12 | 0 | 100% | 0% |
| 阶段6: model | 6 | 6 | 0 | 100% | 0% |
| 阶段7: portfolio | 3 | 3 | 0 | 100% | 0% |
| 阶段8: utils | 26 | 26 | 0 | 100% | 0% |
| 阶段9: examples | 15 | 15 | 0 | 100% | 0% |
| 阶段10: mod | 49 | 49 | 0 | 100% | 0% |
| **总计** | **140** | **140** | **0** | **100%** | **0%** |

## 额外创建的文件 (不在原始任务列表中)

| 文件路径 | 说明 |
|----------|------|
| rqmojo/test_version.mojo | 版本测试文件 |
| rqmojo/portfolio_manager.mojo | 组合管理器 |
| rqmojo/mod_system.mojo | 模块系统 |
| rqmojo/utils/json_parser.mojo | JSON 解析器 |
| rqmojo/utils/performance.mojo | 性能工具 |
| rqmojo/utils/rq_logger.mojo | 日志工具 |
| rqmojo/data/auto_update_bundle_mixin.mojo | 自动更新数据包 |
| rqmojo/data/base_data_source/h5_reader.mojo | HDF5 读取器 |
| rqmojo/mod/rqmojo_mod_sys_risk/risk_manager.mojo | 风险管理器 |

## 下一步工作

### 优先级 1: 建立测试框架

1. 创建 tests/ 目录结构
2. 编写测试工具和辅助函数
3. 定义测试标准和流程

### 优先级 2: 执行测试

对所有 140 个 mojo 文件进行 Python vs Mojo 对比测试，测试通过后将状态更新为 `passed`。
