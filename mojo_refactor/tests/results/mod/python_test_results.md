============================= test session starts ==============================
platform linux -- Python 3.14.3, pytest-9.0.2, pluggy-1.6.0 -- /home/zhou/hello_mojo/trae_cn_78/.venv/bin/python
cachedir: .pytest_cache
rootdir: /home/zhou/hello_mojo/trae_cn_78
configfile: pyproject.toml
plugins: anyio-4.13.0
collecting ... collected 29 items

mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_true_uppercase PASSED [  3%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_true_lowercase PASSED [  6%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_false_uppercase PASSED [ 10%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_false_lowercase PASSED [ 13%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_integer_zero PASSED [ 17%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_integer_positive PASSED [ 20%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_integer_large PASSED [ 24%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_float PASSED [ 27%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_float_half PASSED [ 31%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_float_negative PASSED [ 34%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_string_plain PASSED [ 37%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_string_config_value PASSED [ 41%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_negative_number_is_float PASSED [ 44%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_empty_string PASSED [ 48%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_mixed_alphanumeric PASSED [ 51%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_float_with_leading_dot PASSED [ 55%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_integer_string_100 PASSED [ 58%]
mojo_refactor/tests/python/test_mod_utils.py::TestModConfigValueParse::test_parse_float_string_2_5 PASSED [ 62%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_count PASSED [ 65%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_accounts PASSED [ 68%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_analyser PASSED [ 72%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_progress PASSED [ 75%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_risk PASSED [ 79%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_simulation PASSED [ 82%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_transaction_cost PASSED [ 86%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_contains_scheduler PASSED [ 89%]
mojo_refactor/tests/python/test_mod_utils.py::TestSystemModList::test_system_mod_list_exact_order PASSED [ 93%]
mojo_refactor/tests/python/test_mod_utils.py::TestModHandler::test_mod_handler_init PASSED [ 96%]
mojo_refactor/tests/python/test_mod_utils.py::TestModHandler::test_mod_handler_tear_down_returns_dict PASSED [100%]

============================== 29 passed in 1.75s ==============================
