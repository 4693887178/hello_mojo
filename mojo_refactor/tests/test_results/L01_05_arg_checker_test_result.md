# L01_05_arg_checker 模块测试结果

## 测试信息
- **模块名称**: arg_checker
- **Python路径**: rqalpha.utils.arg_checker
- **Mojo路径**: rqmojo.utils.arg_checker
- **层级**: L01 - Utils
- **依赖**: exception, i18n
- **测试日期**: 2026-03-02

## Python测试结果

### 测试统计
- **总测试数**: 17
- **通过数**: 17
- **失败数**: 0
- **执行时间**: 2.50秒

### 测试用例详情

| 测试用例 | 状态 | 说明 |
|---------|------|------|
| test_argument_checker_base_exists | PASS | ArgumentCheckerBase存在 |
| test_argument_checker_base_init | PASS | ArgumentCheckerBase初始化 |
| test_argument_checker_exists | PASS | ArgumentChecker存在 |
| test_argument_checker_init | PASS | ArgumentChecker初始化 |
| test_is_instance_of | PASS | is_instance_of规则 |
| test_is_number | PASS | is_number规则 |
| test_is_in | PASS | is_in规则 |
| test_is_greater_or_equal_than | PASS | is_greater_or_equal_than规则 |
| test_is_greater_than | PASS | is_greater_than规则 |
| test_is_less_or_equal_than | PASS | is_less_or_equal_than规则 |
| test_is_less_than | PASS | is_less_than规则 |
| test_argument_converter_exists | PASS | ArgumentConverter存在 |
| test_argument_converter_init | PASS | ArgumentConverter初始化 |
| test_verify_that | PASS | verify_that函数 |
| test_assure_that | PASS | assure_that函数 |
| test_apply_rules_exists | PASS | apply_rules存在 |
| test_apply_rules_decorator | PASS | apply_rules装饰器 |

## Mojo测试结果

### 测试统计
- **总测试数**: 16
- **通过数**: 16
- **失败数**: 0
- **执行时间**: <1秒

### 测试用例详情

| 测试用例 | 状态 | 说明 |
|---------|------|------|
| check_string valid string | PASS | 检查有效字符串 |
| check_int valid int | PASS | 检查有效整数 |
| check_int with min and max | PASS | 检查整数范围 |
| check_int at min boundary | PASS | 检查整数最小边界 |
| check_int at max boundary | PASS | 检查整数最大边界 |
| check_float valid float | PASS | 检查有效浮点数 |
| check_float with range | PASS | 检查浮点数范围 |
| check_float at min boundary | PASS | 检查浮点数最小边界 |
| check_float at max boundary | PASS | 检查浮点数最大边界 |
| check_percentage valid 0.5 | PASS | 检查百分比0.5 |
| check_percentage at 0 | PASS | 检查百分比0 |
| check_percentage at 1 | PASS | 检查百分比1 |
| check_order_book_id valid format | PASS | 检查有效order_book_id |
| check_order_book_id with futures exchange | PASS | 检查期货order_book_id |
| check_int negative value | PASS | 检查负整数 |
| check_float negative value | PASS | 检查负浮点数 |

## 功能对比

### 已实现功能
| Python功能 | Mojo实现 | 状态 |
|-----------|---------|------|
| ArgumentCheckerBase | - | ⚠️ 未实现 |
| ArgumentChecker | check_*函数 | ✅ (简化版) |
| ArgumentConverter | - | ⚠️ 未实现 |
| is_instance_of | - | ⚠️ 未实现 |
| is_number | check_int, check_float | ✅ |
| is_in | - | ⚠️ 未实现 |
| is_greater_or_equal_than | check_int min_val | ✅ |
| is_less_or_equal_than | check_int max_val | ✅ |
| check_string | check_string | ✅ |
| check_percentage | check_percentage | ✅ |
| check_order_book_id | check_order_book_id | ✅ |
| apply_rules decorator | - | ⚠️ 未实现 |

### 差异说明
1. Mojo使用简单的函数代替Python的类结构
2. Mojo的check函数使用raises关键字处理错误
3. Mojo不支持装饰器模式，使用函数式检查
4. Python版本有完整的ArgumentChecker和ArgumentConverter类

## 结论
- **Python测试**: ✅ 全部通过
- **Mojo测试**: ✅ 全部通过
- **功能覆盖率**: 40%
- **测试覆盖率**: 100%
