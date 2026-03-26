# Test Result: test_instruments_mixin.py / test_instruments_mixin.mojo

Test Date: Wed Mar 26 2026

## Python Test Output

```
============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0
rootdir: /home/zhou/hello_mojo/trae_cn_78
configfile: pyproject.toml
collected 14 items

mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_class_exists PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_has_get_active_instrument PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_has_get_instrument_history PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_has_get_active_instruments PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_has_get_instruments_history PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_has_get_all_instruments PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixin::test_instruments_mixin_has_assure_order_book_id PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinDeprecatedMethods::test_instruments_mixin_has_all_instruments_deprecated PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinDeprecatedMethods::test_instruments_mixin_has_instrument_not_none_deprecated PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinDeprecatedMethods::test_instruments_mixin_has_instrument_deprecated PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinDeprecatedMethods::test_instruments_mixin_has_instruments_deprecated PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinImports::test_import_instrument PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinImports::test_import_instrument_not_found PASSED
mojo_refactor/tests/python/group_08/test_instruments_mixin.py::TestInstrumentsMixinImports::test_import_lru_cache PASSED

============================== 14 passed in 1.87s ==============================
```

## Mojo Test Output

```
=== Group 08 File 4: Instruments Mixin Tests ===

Test: InstrumentsMixin struct exists
  PASSED
Test: InstrumentsMixin methods exist
  PASSED

=== Test Summary ===
Passed:  2
Failed:  0
Total:   2
```

## Test Summary

**Python: 14 passed, 0 failed**
**Mojo: 2 passed, 0 failed**
