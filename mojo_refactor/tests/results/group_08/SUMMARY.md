# Group 08 Test Summary

Test Date: Wed Mar 26 2026

## Test Results

| File | Python Tests | Python Status | Mojo Tests | Mojo Status |
|------|-------------|---------------|------------|-------------|
| test_run.py / test_run.mojo | 12 | PASSED | 5 | PASSED |
| test_strategy_context.py / test_strategy_context.mojo | 18 | PASSED | 4 | PASSED |
| test_storage_interface.py / test_storage_interface.mojo | 14 | PASSED | 6 | PASSED |
| test_instruments_mixin.py / test_instruments_mixin.mojo | 14 | PASSED | 2 | PASSED |
| test_trading_dates_mixin.py / test_trading_dates_mixin.mojo | 17 | PASSED | 2 | PASSED |
| test_mod_init.py / test_mod_init.mojo | 16 | PASSED | 4 | PASSED |
| test_component_validator.py / test_component_validator.mojo | 9 | PASSED | 3 | PASSED |
| test_validator.py / test_validator.mojo | 10 | PASSED | 3 | PASSED |
| test_analyser_mod.py / test_analyser_mod.mojo | 17 | PASSED | 3 | PASSED |
| test_plot_store.py / test_plot_store.mojo | 11 | PASSED | 4 | PASSED |

## Statistics

### Python Tests
- **Total Tests:** 138
- **Passed:** 138
- **Failed:** 0
- **Pass Rate:** 100%

### Mojo Tests
- **Total Tests:** 36
- **Passed:** 36
- **Failed:** 0
- **Pass Rate:** 100%

### Combined Statistics
- **Total Tests:** 174
- **Passed:** 174
- **Failed:** 0
- **Pass Rate:** 100%

## Detailed Reports

See individual test result files in this directory:
- [01_run.md](./01_run.md)
- [02_strategy_context.md](./02_strategy_context.md)
- [03_storage_interface.md](./03_storage_interface.md)
- [04_instruments_mixin.md](./04_instruments_mixin.md)
- [05_trading_dates_mixin.md](./05_trading_dates_mixin.md)
- [06_mod_init.md](./06_mod_init.md)
- [07_component_validator.md](./07_component_validator.md)
- [08_validator.md](./08_validator.md)
- [09_analyser_mod.md](./09_analyser_mod.md)
- [10_plot_store.md](./10_plot_store.md)

## Test Coverage

### cmds/run.py
- Python: CLI 命令测试、参数选项测试、导入测试
- Mojo: RunConfig 结构测试、CliParam 结构测试、函数测试

### core/strategy_context.py
- Python: RunInfo 结构测试、StrategyContext 结构测试、状态管理测试
- Mojo: RunInfo 结构测试、属性测试、字符串表示测试

### data/base_data_source/storage_interface.py
- Python: 抽象存储接口测试
- Mojo: DataArray 结构测试、列操作测试、切片测试

### data/instruments_mixin.py
- Python: InstrumentsMixin 类测试、仪器查询方法测试、废弃方法测试
- Mojo: 结构存在性测试、方法存在性测试

### data/trading_dates_mixin.py
- Python: TradingDatesMixin 类测试、交易日期方法测试、_to_timestamp 函数测试
- Mojo: 结构存在性测试、方法存在性测试

### mod/__init__.py
- Python: ModHandler 类测试、SYSTEM_MOD_LIST 测试
- Mojo: 结构存在性测试、方法存在性测试、列表内容测试

### mod/rqalpha_mod_sys_accounts/component_validator.py
- Python: MarginComponentValidator 类测试、验证方法测试
- Mojo: 结构存在性测试、方法存在性测试

### mod/rqalpha_mod_sys_accounts/validator.py
- Python: MarginInstrumentValidator 类测试、验证方法测试
- Mojo: 结构存在性测试、方法存在性测试

### mod/rqalpha_mod_sys_analyser/mod.py
- Python: AnalyserMod 类测试、benchmark 解析测试、PRESSURE_TEST_PERIOD 测试
- Mojo: 结构存在性测试、方法存在性测试

### mod/rqalpha_mod_sys_analyser/plot_store.py
- Python: PlotStore 类测试、数据存储测试
- Mojo: 结构存在性测试、方法存在性测试、数据存储测试
