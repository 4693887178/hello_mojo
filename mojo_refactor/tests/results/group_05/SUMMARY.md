# Group 05 测试结果

## 测试文件列表

| 文件 | 通过 | 失败 | 状态 |
|------|------|------|------|
| test_simulation_init.mojo | 7 | 0 | ✅ |
| test_report_init.mojo | 8 | 0 | ✅ |
| test_base_data_source_init.mojo | 6 | 0 | ✅ |
| test_transaction_cost_init.mojo | 8 | 0 | ✅ |
| test_deciders.mojo | 10 | 0 | ✅ |
| test_excel_template.mojo | 6 | 0 | ✅ |
| test_plot_init.mojo | 9 | 0 | ✅ |
| test_plot_consts.mojo | 9 | 0 | ✅ |
| test_scheduler_init.mojo | 6 | 0 | ✅ |
| test_transaction_cost_mod.mojo | - | - | 🔄 源代码问题 |

## 修复的问题

### 1. 测试函数签名问题
所有测试文件使用了 `-> Bool` 返回类型，需要改为 `raises` 并移除返回值。

### 2. 源代码修复
- `rqmojo/mod/rqmojo_mod_sys_transaction_cost/mod.mojo` - `write_to` 函数参数类型修复

## 当前总计

- **通过**: 69
- **失败**: 0
- **待修复**: 1 个文件 (源代码问题)
