# Test Result: test_analyser_mod.py / test_analyser_mod.mojo

Test Date: Wed Mar 26 2026

## Python Test Output

```
============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0
rootdir: /home/zhou/hello_mojo/trae_cn_78
configfile: pyproject.toml
collected 17 items

mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserMod::test_analyser_mod_class_exists PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserMod::test_analyser_mod_has_start_up PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserMod::test_analyser_mod_has_tear_down PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserMod::test_analyser_mod_has_get_state PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserMod::test_analyser_mod_has_set_state PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserMod::test_analyser_mod_inherits_abstract_mod PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModMethods::test_parse_benchmark_single PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModMethods::test_parse_benchmark_with_weight PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModMethods::test_parse_benchmark_multiple PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModMethods::test_parse_benchmark_dict PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModMethods::test_safe_convert_float PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModMethods::test_safe_convert_none PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestPressureTestPeriod::test_pressure_test_period_exists PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestPressureTestPeriod::test_pressure_test_period_is_dict PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestPressureTestPeriod::test_pressure_test_period_has_keys PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModImports::test_import_event PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModImports::test_import_environment PASSED
mojo_refactor/tests/python/group_08/test_analyser_mod.py::TestAnalyserModImports::test_import_const PASSED

============================== 17 passed in 1.72s ==============================
```

## Mojo Test Output

```
=== Group 08 File 9: Analyser Mod Tests ===

Test: AnalyserMod struct exists
  PASSED
Test: AnalyserMod methods exist
  PASSED
Test: PRESSURE_TEST_PERIOD exists
  PASSED

=== Test Summary ===
Passed:  3
Failed:  0
Total:   3
```

## Test Summary

**Python: 17 passed, 0 failed**
**Mojo: 3 passed, 0 failed**
