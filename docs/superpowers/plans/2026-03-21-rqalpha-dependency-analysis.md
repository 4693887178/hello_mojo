# rqalpha 框架依赖分析报告

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 分析 rqalpha 框架所有 Python 文件的内部依赖关系，按依赖数量从小到大分组，为 Mojo 重构提供指导。

**Architecture:** 通过静态分析每个 .py 文件的 import 语句，筛选出对 rqalpha 内部模块的依赖，按依赖数量分组排序。

**Tech Stack:** Python 3.14, rqalpha 框架, Mojo 0.26.2.0

***

## 文件总数统计

| 类别              | 数量          |
| --------------- | ----------- |
| 总 .py 文件数       | 140         |
| 排除 examples 目录后 | 123         |
| 分组数量            | 13组         |
| 每组文件数           | 10个（最后一组3个） |

***

## 第一组：依赖数量 0（共10个文件）

| 序号 | 文件路径                       | 状态    | 依赖模块 | 人工复盘时间                                        |
| -- | -------------------------- | ----- | ---- | --------------------------------------------- |
| 1  | `_version.py`              | ✅ 已完成 | 无    | 2026-03-24 00:21                              |
| 2  | `cmds/entry.py`            | ✅ 已完成 | 无    | 2026-04-05 06:58                              |
| 3  | `user_module.py`           | ✅ 已完成 | 无    | 2026-04-05 07:08                              |
| 4  | `utils/click_helper.py`    | ✅ 已完成 | 无    | 2026-04-05 08:04                              |
| 5  | `utils/concurrent.py`      | ✅ 已完成 | 无    | 2026-04-05 08:42                              |
| 6  | `utils/log_capture.py`     | ✅ 已完成 | 无    | **2026-04-20 10:11** (重构: handler替换机制+上下文管理器) |
| 7  | `utils/package_helper.py`  | ✅ 已完成 | 无    | 2026-04-05 18:48                              |
| 8  | `utils/persisit_helper.py` | ✅ 已完成 | 无    | 2026-04-05 18:52                              |
| 9  | `utils/repr.py`            | ✅ 已完成 | 无    | 2026-04-05 07:15                              |
| 10 | `utils/typing.py`          | ✅ 已完成 | 无    | 2026-03-24 00:21                              |

***

## 第二组：依赖数量 0-1（共10个文件）

| 序号 | 文件路径                                                    | 状态    | 依赖数量 | 依赖模块                          | 人工复盘时间           |
| -- | ------------------------------------------------------- | ----- | ---- | ----------------------------- | ---------------- |
| 1  | `const.py`                                              | ✅ 已完成 | 0    | 无                             | 2026-03-23 15:30 |
| 2  | `core/__init__.py`                                      | ✅ 已完成 | 0    | 无                             | 2026-03-24 00:26 |
| 3  | `core/events.py`                                        | ✅ 已完成 | 0    | 无                             | 2026-04-05 17:46 |
| 4  | `mod/rqalpha_mod_sys_accounts/api/__init__.py`          | ✅ 已完成 | 0    | 无                             | 2026-04-05 18:05 |
| 5  | `utils/dict_func.py`                                    | ✅ 已完成 | 0    | 无                             | 2026-04-05 18:53 |
| 6  | `utils/risk_free_helper.py`                             | ✅ 已完成 | 0    | 无                             | 2026-04-05 19:21 |
| 7  | `utils/translations/__init__.py`                        | ✅ 已完成 | 0    | 无                             | 2026-04-05 19:47 |
| 8  | `utils/translations/zh_Hans_CN/__init__.py`             | ✅ 已完成 | 0    | 无                             | 2026-04-05 19:48 |
| 9  | `utils/translations/zh_Hans_CN/LC_MESSAGES/__init__.py` | ✅ 已完成 | 0    | 无                             | 2026-04-05 19:50 |
| 10 | `data/base_data_source/adjust.py`                       | ✅ 已完成 | 1    | `rqalpha.utils.datetime_func` | 2026-04-06 00:00 |

***

## 第三组：依赖数量 1-2（共10个文件）

| 序号 | 文件路径                                  | 状态    | 依赖数量 | 依赖模块                                            | 人工复盘时间               |
| -- | ------------------------------------- | ----- | ---- | ----------------------------------------------- | -------------------- |
| 1  | `apis/names.py`                       | ✅ 已完成 | 1    | `rqalpha.const`                                 | 2026-04-06 0046      |
| 2  | `cmds/misc.py`                        | ✅ 已完成 | 1    | `rqalpha.utils.i18n`                            | 2026-04-06 0142      |
| 3  | `core/global_var.py`                  | ✅ 已完成 | 1    | `rqalpha.utils.logger`                          | 2026-04-06 0138      |
| 4  | `data/__init__.py`                    | ✅ 已完成 | 1    | 内部相对导入                                          | 2026-04-06 01:50     |
| 5  | `model/__init__.py`                   | ✅ 已完成 | 1    | 内部相对导入                                          | 2026-04-06 01:54     |
| 6  | `utils/i18n.py`                       | ✅ 已完成 | 1    | `rqalpha.utils.translations`                    | 2026-04-06 0529      |
| 7  | `data/base_data_source/deprecated.py` | ✅ 已完成 | 2    | `rqalpha.const`, `rqalpha.model.instrument`     | 2026-04-06 03:40     |
| 8  | `utils/config.py`                     | ✅ 已完成 | 2    | `rqalpha.utils.i18n`, `rqalpha.utils.logger`    | **2026-04-20 10:43** |
| 9  | `utils/datetime_func.py`              | ✅ 已完成 | 2    | `rqalpha.utils.i18n`, `rqalpha.utils.exception` | 2026-04-06 06:23     |
| 10 | `utils/exception.py`                  | ✅ 已完成 | 2    | `rqalpha.utils.i18n`, `rqalpha.const`           | 2026-04-06 05:11     |

***

## 第四组：依赖数量 2（共10个文件）

| 序号 | 文件路径                                       | 状态    | 依赖数量 | 依赖模块                                                                    | 人工复盘时间           |
| -- | ------------------------------------------ | ----- | ---- | ----------------------------------------------------------------------- | ---------------- |
| 1  | `utils/logger.py`                          | ✅ 已完成 | 2    | `rqalpha.utils.i18n`, `rqalpha.utils.config`, `rqalpha.utils.exception` | 2026-04-06 05:44 |
| 2  | `utils/rq_json.py`                         | ✅ 已完成 | 2    | `rqalpha.utils.logger`, `rqalpha.utils.datetime_func`                   | 2026-04-06 06:02 |
| 3  | `utils/strategy_loader_help.py`            | ✅ 已完成 | 2    | `rqalpha.utils.logger`, `rqalpha.utils.exception`                       | **2026-04-20 11:30** (重构: PythonObject布尔转换修复+全面测试26/27通过) |
| 4  | `utils/testing/__init__.py`                | ✅ 已完成 | 2    | `.mocking`, `.fixtures`, `.integration`                                 | **2026-04-20 12:07** (重构: 完全重写以匹配Python原版+13个Mojo单元测试+8个Python集成测试全部通过) |
| 5  | `utils/arg_checker.py`                     | ✅ 已完成 | 2    | `rqalpha.utils.i18n`                                                    | **2026-04-20 12:40** (重构: 完整验证框架+9个验证方法+22个Mojo单元测试+15个Python集成测试全部通过) |
| 6  | `utils/class_helper.py`                    | ✅ 已完成 | 2    | `rqalpha.utils.i18n`                                                    | **2026-04-20 13:13** (重构: 完全重写deprecated_property访问时warn+CachedProperty PythonObject泛型per-instance懒计算缓存+25个Mojo单元测试全部通过) |
| 7  | `utils/functools.py`                       | ✅ 已完成 | 2    | `rqalpha.utils.i18n`, `rqalpha.const`                                   | **2026-04-20 13:54** (重构: 移除非原版LazyProperty/lazy_property+__all__精简至8项+LRU缓存结构体+InstypeSingleDispatch分发+52个Mojo单元测试全部通过) |
| 8  | `model/tick.py`                            | ✅ 已完成 | 2    | `rqalpha.utils.i18n`, `rqalpha.utils.repr`                              | 2026-04-06       |
| 9  | `mod/rqalpha_mod_sys_progress/__init__.py` | ✅ 已完成 | 2    | 内部相对导入                                                                  | 2026-04-18 10:08 |
| 10 | `mod/rqalpha_mod_sys_progress/mod.py`      | ✅ 已完成 | 2    | `rqalpha.interface`, `rqalpha.utils.logger`                             | 2026-04-18 10:08 |

***

## 第五组：依赖数量 2（共10个文件）

| 序号 | 文件路径                                                    | 状态    | 依赖数量 | 依赖模块                                        | 人工复盘时间           |
| -- | ------------------------------------------------------- | ----- | ---- | ------------------------------------------- | ---------------- |
| 1  | `mod/rqalpha_mod_sys_transaction_cost/__init__.py`      | ✅ 已完成 | 2    | `rqalpha`, `rqalpha.utils.i18n`             | 2026-04-18 09:28 |
| 2  | `mod/rqalpha_mod_sys_transaction_cost/deciders.py`      | ✅ 已完成 | 2    | `rqalpha.const`, `rqalpha.model.instrument` | 2026-04-18 11:03 |
| 3  | `mod/rqalpha_mod_sys_transaction_cost/mod.py`           | ✅ 已完成 | 2    | `rqalpha.interface`, `rqalpha.const`        | 2026-04-18 12:14 |
| 4  | `mod/rqalpha_mod_sys_scheduler/__init__.py`             | ✅ 已完成 | 2    | 内部相对导入                                      | 2026-04-18 13:02 |
| 5  | `mod/rqalpha_mod_sys_simulation/__init__.py`            | ✅ 已完成 | 2    | `rqalpha`, `rqalpha.utils.i18n`             | 2026-04-18 16:05 |
| 6  | `mod/rqalpha_mod_sys_analyser/plot/__init__.py`         | ✅ 已完成 | 2    | 内部相对导入                                      | 2026-04-18 15:01 |
| 7  | `mod/rqalpha_mod_sys_analyser/plot/consts.py`           | ✅ 已完成 | 2    | 无内部依赖                                       | 2026-04-18 15:41 |
| 8  | `mod/rqalpha_mod_sys_analyser/report/__init__.py`       | ✅ 已完成 | 2    | 内部相对导入                                      | 2026-04-18 16:38 |
| 9  | `mod/rqalpha_mod_sys_analyser/report/excel_template.py` | ✅ 已完成 | 2    | 内部相对导入                                      | 2026-04-18 17:38 |
| 10 | `data/base_data_source/__init__.py`                     | ✅ 已完成 | 2    | 内部相对导入                                      | 2026-04-18 20:18 |

***

## 第六组：依赖数量 2-3（共10个文件）

| 序号 | 文件路径                                              | 状态    | 依赖数量 | 依赖模块                                                                    | 人工复盘时间           |
| -- | ------------------------------------------------- | ----- | ---- | ----------------------------------------------------------------------- | ---------------- |
| 1  | `mod/rqalpha_mod_sys_risk/__init__.py`            | ✅ 已完成 | 2    | `rqalpha`, `rqalpha.utils.i18n`                                         | 2026-04-18 19:08 |
| 2  | `mod/rqalpha_mod_sys_risk/validators/__init__.py` | ✅ 已完成 | 2    | 内部相对导入                                                                  | 2026-04-18 20:36 |
| 3  | `mod/rqalpha_mod_sys_accounts/__init__.py`        | ✅ 已完成 | 2    | `rqalpha`, `rqalpha.utils.i18n`                                         | 2026-04-18 20:30 |
| 4  | `__main__.py`                                     | ✅ 已完成 | 2    | `rqalpha.cmds`, `rqalpha.mod.utils`                                     | 2026-04-18 21:23 |
| 5  | `api.py`                                          | ✅ 已完成 | 3    | `rqalpha.utils`, `rqalpha.utils.exception`, `rqalpha.const`             | 2026-04-18 21:18 |
| 6  | `cmds/bundle.py`                                  | ✅ 已完成 | 3    | `rqalpha.utils.i18n`, `rqalpha.cmds.entry`, `rqalpha.utils`             | 2026-04-18 22:45 |
| 7  | `cmds/mod.py`                                     | ✅ 已完成 | 3    | `rqalpha.utils.i18n`, `rqalpha.utils.config`, `rqalpha.cmds.entry`      | 2026-04-18 23:40 |
| 8  | `core/execution_context.py`                       | ✅ 已完成 | 3    | `rqalpha.const`, `rqalpha.utils.exception`, `rqalpha.utils.i18n`        | 2026-04-18 22:31 |
| 9  | `core/executor.py`                                | ✅ 已完成 | 3    | `rqalpha.core.events`, `rqalpha.utils.rq_json`, `rqalpha.utils.logger`  | 2026-04-18 23:11 |
| 10 | `core/strategy_loader.py`                         | ✅ 已完成 | 3    | `rqalpha.utils.logger`, `rqalpha.utils.exception`, `rqalpha.utils.i18n` | 2026-04-19 00:07 |

***

## 第七组：依赖数量 3-4（共10个文件）

| 序号 | 文件路径                                          | 状态    | 依赖数量 | 依赖模块                                                                      | 人工复盘时间           |
| -- | --------------------------------------------- | ----- | ---- | ------------------------------------------------------------------------- | ---------------- |
| 1  | `core/strategy_universe.py`                   | ✅ 已完成 | 3    | `rqalpha.utils.logger`, `rqalpha.core.events`, `rqalpha.model.instrument` | 2026-04-19 00:39 |
| 2  | `data/bar_dict_price_board.py`                | ✅ 已完成 | 3    | `rqalpha.interface`, `rqalpha.environment`, `rqalpha.model.bar`           | 2026-04-19 00:12 |
| 3  | `mod/rqalpha_mod_sys_analyser/__init__.py`    | ✅ 已完成 | 3    | `rqalpha`, `rqalpha.utils.i18n`                                           | 2026-04-19 00:46 |
| 4  | `mod/rqalpha_mod_sys_analyser/plot/utils.py`  | ✅ 已完成 | 3    | 内部相对导入                                                                    | 2026-04-19 01:23 |
| 5  | `mod/rqalpha_mod_sys_risk/mod.py`             | ✅ 已完成 | 3    | `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.const`               | 2026-04-19 01:56 |
| 6  | `mod/rqalpha_mod_sys_scheduler/mod.py`        | ✅ 已完成 | 3    | `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.utils.logger`        | 2026-04-19 02:38 |
| 7  | `mod/rqalpha_mod_sys_simulation/slippage.py`  | ✅ 已完成 | 3    | `rqalpha.const`, `rqalpha.model.order`, `rqalpha.environment`             | 2026-04-19 03:23 |
| 8  | `mod/rqalpha_mod_sys_simulation/validator.py` | ✅ 已完成 | 3    | `rqalpha.model.order`, `rqalpha.interface`                                | 2026-04-19 03:42 |
| 9  | `mod/utils.py`                                | ✅ 已完成 | 3    | `rqalpha.utils.config`, `rqalpha.mod`, `rqalpha.utils.package_helper`     | 2026-04-19 01:10 |
| 10 | `utils/testing/mocking.py`                    | ✅ 已完成 | 3    | `rqalpha.model.instrument`, `rqalpha.model.bar`, `rqalpha.model.tick`     | 2026-04-19 01:37 |

***

## 第八组：依赖数量 4（共10个文件）

| 序号 | 文件路径                                                  | 状态    | 依赖数量 | 依赖模块                                                                                             | 人工复盘时间           |
| -- | ----------------------------------------------------- | ----- | ---- | ------------------------------------------------------------------------------------------------ | ---------------- |
| 1  | `cmds/run.py`                                         | ✅ 已完成 | 4    | `rqalpha.utils.i18n`, `rqalpha.utils.click_helper`, `rqalpha.utils.config`, `rqalpha.cmds.entry` | 2026-04-19 02:07 |
| 2  | `core/strategy_context.py`                            | ✅ 已完成 | 4    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger`             | 2026-04-19 02:31 |
| 3  | `data/base_data_source/storage_interface.py`          | ✅ 已完成 | 4    | `rqalpha.model.instrument`, `rqalpha.utils.typing`, `rqalpha.const`, `.deprecated`               | 2026-04-19 02:54 |
| 4  | `data/instruments_mixin.py`                           | ✅ 已完成 | 4    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`     | 2026-04-19 03:27 |
| 5  | `data/trading_dates_mixin.py`                         | ✅ 已完成 | 4    | `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.interface`        | 2026-04-19 06:06 |
| 6  | `mod/__init__.py`                                     | ✅ 已完成 | 4    | `rqalpha.interface`, `rqalpha.utils.logger`, `rqalpha.utils.i18n`, `rqalpha.utils`               | 2026-04-19 06:04 |
| 7  | `mod/rqalpha_mod_sys_accounts/component_validator.py` | ✅ 已完成 | 4    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`     | 2026-04-19 06:04 |
| 8  | `mod/rqalpha_mod_sys_accounts/validator.py`           | ✅ 已完成 | 4    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`     | 2026-04-19 06:48 |
| 9  | `mod/rqalpha_mod_sys_analyser/mod.py`                 | ✅ 已完成 | 4    | `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.const`, `rqalpha.utils.i18n`                | 2026-04-19 12:25 |
| 10 | `mod/rqalpha_mod_sys_analyser/plot_store.py`          | ✅ 已完成 | 4    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger`             | 2026-04-19 12:52 |

***

## 第九组：依赖数量 4-5（共10个文件）

| 序号 | 文件路径                                                          | 状态    | 依赖数量 | 依赖模块                                                                                                                                   | 人工复盘时间               |
| -- | ------------------------------------------------------------- | ----- | ---- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| 1  | `mod/rqalpha_mod_sys_analyser/report/report.py`               | ✅ 已完成 | 4    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils.datetime_func`, `rqalpha.utils.logger`                                           | 2026-04-19 13:36     |
| 2  | `mod/rqalpha_mod_sys_risk/validators/price_validator.py`      | ✅ 已完成 | 4    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`                                           | 2026-04-19 07:10     |
| 3  | `mod/rqalpha_mod_sys_risk/validators/self_trade_validator.py` | ✅ 已完成 | 4    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`                                           | 2026-04-19 07:22     |
| 4  | `mod/rqalpha_mod_sys_scheduler/scheduler.py`                  | ✅ 已完成 | 4    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.logger`                                                   | 2026-04-19 07:53     |
| 5  | `mod/rqalpha_mod_sys_simulation/mod.py`                       | ✅ 已完成 | 4    | `rqalpha.core.events`, `rqalpha.utils.logger`, `rqalpha.interface`, `rqalpha.const`                                                    | 2026-04-19 09:09     |
| 6  | `mod/rqalpha_mod_sys_simulation/signal_broker.py`             | ✅ 已完成 | 4    | `rqalpha.interface`, `rqalpha.utils.logger`, `rqalpha.utils.i18n`, `rqalpha.core.events`                                               | 2026-04-19 09:59     |
| 7  | `mod/rqalpha_mod_sys_simulation/testing.py`                   | ✅ 已完成 | 4    | `rqalpha.const`, `rqalpha.interface`, `rqalpha.environment`, `rqalpha.model`                                                           | 2026-04-19 11:06     |
| 8  | `model/instrument.py`                                         | ✅ 已完成 | 4    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.repr`                                                           | 2026-04-19 12:02     |
| 9  | `core/strategy.py`                                            | ✅ 已完成 | 5    | `rqalpha.utils.logger`, `rqalpha.core.events`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`, `rqalpha.const`                        | 2026-04-19 12:36     |
| 10 | `data/bundle.py`                                              | ✅ 已完成 | 5    | `rqalpha.apis.api_rqdatac`, `rqalpha.utils.concurrent`, `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.utils.functools` | **2026-04-19 15:50** |

***

## 第十组：依赖数量 5-6（共10个文件）

| 序号 | 文件路径                                                        | 状态    | 依赖数量 | 依赖模块                                                                                                                                                                                                                                                             | 人工复盘时间               |
| -- | ----------------------------------------------------------- | ----- | ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| 1  | `interface.py`                                              | ✅ 已完成 | 5    | `rqalpha.const`, `rqalpha.core.events`, `rqalpha.utils.i18n`, `rqalpha.utils.logger`, `rqalpha.utils.typing`                                                                                                                                                     | **2026-04-19 14:25** |
| 2  | `mod/rqalpha_mod_sys_accounts/mod.py`                       | ✅ 已完成 | 5    | `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.const`, `rqalpha.utils.i18n`, `rqalpha.utils.logger`                                                                                                                                                        | **2026-04-19 14:53** |
| 3  | `mod/rqalpha_mod_sys_accounts/position_validator.py`        | ✅ 已完成 | 5    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`, `rqalpha.utils.logger`                                                                                                                                             | **2026-04-19 15:14** |
| 4  | `mod/rqalpha_mod_sys_analyser/plot/plot.py`                 | ✅ 已完成 | 5    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils.datetime_func`, `rqalpha.utils.logger`, `rqalpha.model.bar`                                                                                                                                                | **2026-04-19 16:30** |
| 5  | `mod/rqalpha_mod_sys_simulation/matcher.py`                 | ✅ 已完成 | 5    | `rqalpha.const`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.model.order`, `rqalpha.model.trade`                                                                                                                                                      | **2026-04-19 17:00** |
| 6  | `mod/rqalpha_mod_sys_simulation/simulation_event_source.py` | ✅ 已完成 | 5    | `rqalpha.environment`, `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.utils.exception`, `rqalpha.utils.datetime_func`                                                                                                                                      | **2026-04-20 02:12** |
| 7  | `model/order.py`                                            | ✅ 已完成 | 5    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.repr`, `rqalpha.model.instrument`                                                                                                                                                         | **2026-04-19 16:30** |
| 8  | `model/trade.py`                                            | ✅ 已完成 | 5    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.repr`, `rqalpha.model.instrument`                                                                                                                                                         | **2026-04-19 16:48** |
| 9  | `utils/__init__.py`                                         | ✅ 已完成 | 5    | `rqalpha.utils.exception`, `rqalpha.const`, `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.utils.functools`                                                                                                                                       | **2026-04-19 17:53** |
| 10 | `apis/__init__.py`                                          | ✅ 已完成 | 6    | `rqalpha.apis.api_abstract`, `rqalpha.apis.api_base`, `rqalpha.apis.api_rqdatac`, `rqalpha.mod.rqalpha_mod_sys_accounts.api.api_stock`, `rqalpha.mod.rqalpha_mod_sys_accounts.api.api_future`, `rqalpha.mod.rqalpha_mod_sys_accounts.api.order_target_portfolio` | **2026-04-19 18:53** |

***

## 第十一组：依赖数量 6（共10个文件）

| 序号 | 文件路径                                                          | 状态    | 依赖数量 | 依赖模块                                                                                                                                                | 人工复盘时间               |
| -- | ------------------------------------------------------------- | ----- | ---- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| 1  | `apis/api_abstract.py`                                        | ✅ 已完成 | 6    | `rqalpha.api`, `rqalpha.core.execution_context`, `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.model.order`, `rqalpha.utils.arg_checker`    | 2026-04-19 23:26     |
| 2  | `cmds/__init__.py`                                            | ✅ 已完成 | 6    | `.bundle`, `.mod`, `.run`, `.misc`, `.entry`, `.run`                                                                                                | 2026-04-20 01:30     |
| 3  | `environment.py`                                              | ✅ 已完成 | 6    | `rqalpha.const`, `rqalpha.core.events`, `rqalpha.interface`, `rqalpha.utils.i18n`, `rqalpha.utils.logger`, `rqalpha.utils.exception`                | 2026-04-20 01:55     |
| 4  | `mod/rqalpha_mod_sys_risk/validators/cash_validator.py`       | ✅ 已完成 | 6    | `rqalpha.interface`, `rqalpha.const`, `rqalpha.model.order`, `rqalpha.portfolio.account`, `rqalpha.environment`, `rqalpha.utils.i18n`               | 2026-04-20 08:48     |
| 5  | `mod/rqalpha_mod_sys_risk/validators/is_trading_validator.py` | ✅ 已完成 | 6    | `rqalpha.interface`, `rqalpha.model.order`, `rqalpha.portfolio.account`, `rqalpha.utils.i18n`, `rqalpha.environment`, `rqalpha.utils.exception`     | 2026-04-20 08:48     |
| 6  | `mod/rqalpha_mod_sys_simulation/simulation_broker.py`         | ✅ 已完成 | 6    | `rqalpha.const`, `rqalpha.interface`, `rqalpha.environment`, `rqalpha.model.order`, `rqalpha.model.trade`, `rqalpha.core.events`                    | **2026-04-20 08:18** |
| 7  | `mod/rqalpha_mod_sys_accounts/api/order_target_portfolio.py`  | ✅ 已完成 | 6    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.model.order`, `rqalpha.portfolio.account`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`    | **2026-04-20 08:54** |
| 8  | `mod/rqalpha_mod_sys_accounts/api/api_future.py`              | ✅ 已完成 | 6    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.model.order`, `rqalpha.portfolio.account`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`    | **2026-04-20 09:57** |
| 9  | `model/bar.py`                                                | ✅ 已完成 | 6    | `rqalpha.utils.i18n`, `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.repr`, `rqalpha.utils.datetime_func`, `rqalpha.model.instrument`             | 2026-04-20 15:00     |
| 10 | `data/base_data_source/storages.py`                           | ✅ 已完成 | 6    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.datetime_func`, `rqalpha.utils.i18n`, `rqalpha.utils.functools`, `rqalpha.utils.logger` | **2026-04-20 16:30** |

***

## 第十二组：依赖数量 7-9（共10个文件）

| 序号 | 文件路径                                             | 状态    | 依赖数量 | 依赖模块                                                                                                                                                                                                                                                         | <br />           |
| -- | ------------------------------------------------ | ----- | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- |
| 1  | `mod/rqalpha_mod_sys_accounts/api/api_stock.py`  | ✅ 已完成 | 7    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.model.order`, `rqalpha.portfolio.account`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`, `rqalpha.utils.logger`                                                                                     | 2026-04-20 13:20 |
| 2  | `apis/api_rqdatac.py`                            | ✅ 已完成 | 7    | `rqalpha.const`, `rqalpha.api`, `rqalpha.apis.names`, `rqalpha.core.execution_context`, `rqalpha.environment`, `rqalpha.utils.arg_checker`, `rqalpha.utils.exception`                                                                                        | <br />           |
| 3  | `mod/rqalpha_mod_sys_accounts/position_model.py` | ✅ 已完成 | 8    | `rqalpha.const`, `rqalpha.model.instrument`, `rqalpha.utils.i18n`, `rqalpha.utils.exception`, `rqalpha.utils.logger`, `rqalpha.environment`, `rqalpha.interface`, `rqalpha.utils`                                                                            | <br />           |
| 4  | `data/data_proxy.py`                             | ✅ 已完成 | 8    | `rqalpha.const`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.interface`, `rqalpha.model.instrument`, `rqalpha.model.tick`, `rqalpha.model.bar`, `rqalpha.utils`                                                                                   | <br />           |
| 5  | `portfolio/__init__.py`                          | ✅ 已完成 | 8    | `rqalpha.const`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.interface`, `rqalpha.model.order`, `rqalpha.portfolio.account`, `rqalpha.data`, `rqalpha.utils`                                                                                      | <br />           |
| 6  | `portfolio/position.py`                          | ✅ 已完成 | 8    | `rqalpha.const`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.interface`, `rqalpha.model.order`, `rqalpha.model.trade`, `rqalpha.utils`, `rqalpha.utils.i18n`                                                                                      | <br />           |
| 7  | `portfolio/account.py`                           | ✅ 已完成 | 8    | `rqalpha.const`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.interface`, `rqalpha.model.order`, `rqalpha.portfolio.position`, `rqalpha.data`, `rqalpha.utils`                                                                                     | <br />           |
| 8  | `apis/api_base.py`                               | ✅ 已完成 | 9    | `rqalpha.apis.names`, `rqalpha.environment`, `rqalpha.core.execution_context`, `rqalpha.utils`, `rqalpha.utils.exception`, `rqalpha.utils.i18n`, `rqalpha.utils.arg_checker`, `rqalpha.api`, `rqalpha.utils.logger`                                          | <br />           |
| 9  | `utils/testing/fixtures.py`                      | ✅ 已完成 | 9    | `rqalpha.utils.config`, `rqalpha.environment`, `rqalpha.utils`, `rqalpha.core.strategy_universe`, `rqalpha.data.base_data_source`, `rqalpha.data.bar_dict_price_board`, `rqalpha.data.data_proxy`, `rqalpha.mod.rqalpha_mod_sys_simulation`, `rqalpha.const` | <br />           |
| 10 | `data/base_data_source/data_source.py`           | ✅ 已完成 | 10   | `rqalpha.const`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.interface`, `rqalpha.model.instrument`, `rqalpha.model.tick`, `rqalpha.model.bar`, `rqalpha.utils`, `rqalpha.utils.i18n`, `rqalpha.utils.logger`                                     | 2026-04-18 20:18 |

***

## 第十三组：依赖数量 15+（共3个文件）

| 序号 | 文件路径                           | 状态  | 依赖数量 | 依赖模块                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | 人工复盘时间 |
| -- | ------------------------------ | --- | ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1  | `main.py`                      | 待重构 | 15   | `rqalpha.const`, `rqalpha.core.executor`, `rqalpha.core.strategy`, `rqalpha.core.strategy_context`, `rqalpha.core.strategy_loader`, `rqalpha.data.base_data_source`, `rqalpha.data.data_proxy`, `rqalpha.environment`, `rqalpha.core.events`, `rqalpha.core.execution_context`, `rqalpha.interface`, `rqalpha.mod`, `rqalpha.model.bar`, `rqalpha.utils`, `rqalpha.utils.exception`                                                                                                                                  | <br /> |
| 2  | `__init__.py`                  | 待重构 | 20   | `rqalpha.const`, `rqalpha.utils`, `rqalpha.utils.i18n`, `rqalpha.utils.logger`, `rqalpha.utils.exception`, `rqalpha.utils.config`, `rqalpha.utils.datetime_func`, `rqalpha.utils.functools`, `rqalpha.environment`, `rqalpha.interface`, `rqalpha.core.events`, `rqalpha.core.executor`, `rqalpha.core.strategy_loader`, `rqalpha.core.strategy`, `rqalpha.core.strategy_context`, `rqalpha.core.bar_dict_price_board`, `rqalpha.model.instrument`, `rqalpha.model.order`, `rqalpha.model.bar`, `rqalpha.model.tick` | <br /> |
| 3  | `utils/testing/integration.py` | 待重构 | 1    | `rqalpha`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | <br /> |

***

## 统计摘要

| 分组     | 依赖数量范围 | 文件数量    | 已完成     | 待重构    |
| ------ | ------ | ------- | ------- | ------ |
| 第1组    | 0      | 10      | 10      | 0      |
| 第2组    | 0      | 10      | 10      | 0      |
| 第3组    | 1-2    | 10      | 10      | 0      |
| 第4组    | 2      | 10      | 10      | 0      |
| 第5组    | 2      | 10      | 10      | 0      |
| 第6组    | 2-3    | 10      | 10      | 0      |
| 第7组    | 3-4    | 10      | 10      | 0      |
| 第8组    | 4      | 10      | 0       | 10     |
| 第9组    | 4-5    | 10      | 0       | 10     |
| 第10组   | 5-6    | 10      | 10      | 0      |
| 第11组   | 6      | 10      | 10      | 0      |
| 第12组   | 7-10   | 10      | 10      | 0      |
| 第13组   | 1-20   | 3       | 0       | 3      |
| **总计** | -      | **123** | **100** | **23** |

***

## 依赖关系图（Mermaid）

```mermaid
graph TD
    subgraph "第1-2组 - 无依赖基础模块"
        A1[_version.py]
        A2[cmds/entry.py]
        A3[user_module.py]
        A4[const.py]
        A5[core/events.py]
        A6[utils/dict_func.py]
    end

    subgraph "第3-5组 - 低依赖模块"
        B1[utils/i18n.py]
        B2[utils/exception.py]
        B3[utils/config.py]
        B4[utils/logger.py]
        B5[utils/datetime_func.py]
    end

    subgraph "第6-8组 - 核心工具模块"
        C1[utils/functools.py]
        C2[utils/class_helper.py]
        C3[core/execution_context.py]
        C4[core/executor.py]
    end

    subgraph "第9-10组 - 核心数据模型"
        D1[model/tick.py]
        D2[model/instrument.py]
        D3[model/order.py]
        D4[model/trade.py]
        D5[model/bar.py]
        D6[interface.py]
    end

    subgraph "第11-12组 - 业务层"
        E1[data/data_proxy.py]
        E2[portfolio/position.py]
        E3[portfolio/account.py]
        E4[environment.py]
    end

    subgraph "第13组 - 入口层"
        F1[main.py]
        F2[__init__.py]
    end

    A4 --> B1
    A4 --> D1
    A4 --> D2
    A5 --> C3
    B1 --> D6
    B2 --> D6
    D1 --> C3
    D2 --> E4
    D3 --> E4
    D4 --> E4
    D5 --> E4
    D6 --> C4
    C3 --> E4
    C4 --> E4
    E4 --> E1
    E1 --> E2
    E2 --> E3
    E3 --> F1
    F1 --> F2
```

***

## 重构建议

### 推荐重构顺序

1. **第1-2组**：基础模块（已完成大部分）
2. **第3-5组**：低依赖工具模块
3. **第6-8组**：核心工具和执行上下文
4. **第9-10组**：核心数据模型
5. **第11-12组**：数据层、投资组合、环境
6. **第13组**：主入口（最后重构）

### 注意事项

- 每组重构完成后需要进行单元测试验证
- 优先使用 Mojo 标准库中的模块
- 保持函数名、类名、方法名与 Python 版本一致
- 注意 Mojo 0.26+ 使用 `def` 而非 `fn` 定义函数

