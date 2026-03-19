# L00_05_rq_json Test Result

**Test Date:** 2026-03-05
**Module:** rqmojo.utils.rq_json / rqalpha.utils.rq_json
**Level:** L00 - Leaf module

---

## Python Test Results

```
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_simple_dict PASSED [  3%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_datetime_encoding PASSED [  6%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_date_encoding PASSED [ 10%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_enum_encoding PASSED [ 13%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_position_direction_encoding PASSED [ 17%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_order_type_encoding PASSED [ 20%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_nested_dict PASSED [ 24%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertDictToJson::test_multiple_datetime_fields PASSED [ 27%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertJsonToDict::test_simple_json PASSED [ 31%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertJsonToDict::test_datetime_decoding PASSED [ 34%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertJsonToDict::test_date_decoding PASSED [ 37%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertJsonToDict::test_enum_decoding PASSED [ 41%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertJsonToDict::test_position_direction_decoding PASSED [ 44%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestConvertJsonToDict::test_nested_json PASSED [ 48%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestRoundtrip::test_simple_roundtrip PASSED [ 51%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestRoundtrip::test_datetime_roundtrip PASSED [ 55%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestRoundtrip::test_date_roundtrip PASSED [ 58%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestRoundtrip::test_enum_roundtrip PASSED [ 62%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestRoundtrip::test_complex_roundtrip PASSED [ 65%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomEncode::test_encode_datetime PASSED [ 68%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomEncode::test_encode_date PASSED [ 72%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomEncode::test_encode_enum PASSED [ 75%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomEncode::test_encode_unserializable_raises PASSED [ 79%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomDecode::test_decode_datetime PASSED [ 82%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomDecode::test_decode_date PASSED [ 86%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomDecode::test_decode_enum PASSED [ 89%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestCustomDecode::test_decode_regular_dict PASSED [ 93%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestMojoCompatibility::test_datetime_format_compatibility PASSED [ 96%]
tests/python_test_rqalpha/L00_leaf/test_L00_05_rq_json.py::TestL00RqJson::TestMojoCompatibility::test_date_format_compatibility PASSED [100%]

============================== 29 passed in 2.69s ==============================
```

**Result:** ✅ 29/29 tests passed

---

## Mojo Test Results

```
============================================================
L00_05_rq_json Module Tests
============================================================
PASS: Simple dict to JSON conversion
PASS: Simple JSON to dict conversion
PASS: Datetime to JSON conversion
PASS: Date to JSON conversion
PASS: JSON to datetime conversion
PASS: JSON to date conversion
PASS: Nested dict to JSON conversion
PASS: Roundtrip simple dict
PASS: Roundtrip datetime
PASS: Roundtrip date
PASS: Multiple fields roundtrip
============================================================
Results: 11/11 tests passed
============================================================
```

**Result:** ✅ 11/11 tests passed

**运行命令:**
```bash
PYTHONPATH=/home/zhou/hello-world/.venv/lib/python3.14/site-packages:$PYTHONPATH \
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libpython3.14.so.1.0 \
mojo run -I . tests/mojo_test_rqmojo/L00_leaf/test_L00_05_rq_json.mojo
```

---

## Test Coverage

### Python Tests
| Test Class | Test Method | Status |
|------------|-------------|--------|
| TestConvertDictToJson | test_simple_dict | ✅ |
| TestConvertDictToJson | test_datetime_encoding | ✅ |
| TestConvertDictToJson | test_date_encoding | ✅ |
| TestConvertDictToJson | test_enum_encoding | ✅ |
| TestConvertDictToJson | test_position_direction_encoding | ✅ |
| TestConvertDictToJson | test_order_type_encoding | ✅ |
| TestConvertDictToJson | test_nested_dict | ✅ |
| TestConvertDictToJson | test_multiple_datetime_fields | ✅ |
| TestConvertJsonToDict | test_simple_json | ✅ |
| TestConvertJsonToDict | test_datetime_decoding | ✅ |
| TestConvertJsonToDict | test_date_decoding | ✅ |
| TestConvertJsonToDict | test_enum_decoding | ✅ |
| TestConvertJsonToDict | test_position_direction_decoding | ✅ |
| TestConvertJsonToDict | test_nested_json | ✅ |
| TestRoundtrip | test_simple_roundtrip | ✅ |
| TestRoundtrip | test_datetime_roundtrip | ✅ |
| TestRoundtrip | test_date_roundtrip | ✅ |
| TestRoundtrip | test_enum_roundtrip | ✅ |
| TestRoundtrip | test_complex_roundtrip | ✅ |
| TestCustomEncode | test_encode_datetime | ✅ |
| TestCustomEncode | test_encode_date | ✅ |
| TestCustomEncode | test_encode_enum | ✅ |
| TestCustomEncode | test_encode_unserializable_raises | ✅ |
| TestCustomDecode | test_decode_datetime | ✅ |
| TestCustomDecode | test_decode_date | ✅ |
| TestCustomDecode | test_decode_enum | ✅ |
| TestCustomDecode | test_decode_regular_dict | ✅ |
| TestMojoCompatibility | test_datetime_format_compatibility | ✅ |
| TestMojoCompatibility | test_date_format_compatibility | ✅ |

### Mojo Tests
| Test Method | Status |
|-------------|--------|
| test_simple_dict_to_json | ✅ |
| test_simple_json_to_dict | ✅ |
| test_datetime_to_json | ✅ |
| test_date_to_json | ✅ |
| test_json_to_datetime | ✅ |
| test_json_to_date | ✅ |
| test_nested_dict_to_json | ✅ |
| test_roundtrip_simple | ✅ |
| test_roundtrip_datetime | ✅ |
| test_roundtrip_date | ✅ |
| test_multiple_fields | ✅ |

---

## Implementation Notes

### Python Implementation
- 使用 `simplejson` 模块
- `custom_encode` 处理 datetime, date, CustomEnum
- `custom_decode` 反序列化特殊类型
- datetime 格式: `%Y%m%dT%H:%M:%S.%f`

### Mojo Implementation
- 使用 Python 互操作调用 `simplejson`
- 通过 `builtins.exec()` 创建回调函数
- 支持 datetime, date, enum 的序列化/反序列化

### Key Features
1. **datetime 序列化**: `{"__datetime__": true, "as_str": "20240115T14:30:45.123456"}`
2. **date 序列化**: `{"__date__": true, "as_str": "20240115"}`
3. **enum 序列化**: `{"__enum__": true, "as_str": "SIDE.BUY"}`
4. **嵌套字典支持**: 支持多层嵌套结构
5. **往返转换**: 序列化和反序列化完全可逆

---

## Conclusion

✅ **所有测试通过**

- Python: 29/29 tests passed
- Mojo: 11/11 tests passed

rq_json 模块在 Python 和 Mojo 环境下功能完全正常。
