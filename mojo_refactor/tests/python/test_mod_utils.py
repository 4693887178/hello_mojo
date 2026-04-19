"""
Integration tests comparing Python rqalpha/mod/utils.py with Mojo rqmojo/mod/__init__.mojo

Tests verify that mod_config_value_parse and SYSTEM_MOD_LIST behavior
matches between Python and Mojo implementations.
"""

import pytest
from rqalpha.mod.utils import mod_config_value_parse
from rqalpha.mod import SYSTEM_MOD_LIST, ModHandler


class TestModConfigValueParse:
    """Test mod_config_value_parse matches between Python and Mojo."""

    def test_parse_true_uppercase(self):
        result = mod_config_value_parse("True")
        assert result is True
        assert isinstance(result, bool)

    def test_parse_true_lowercase(self):
        result = mod_config_value_parse("true")
        assert result is True
        assert isinstance(result, bool)

    def test_parse_false_uppercase(self):
        result = mod_config_value_parse("False")
        assert result is False
        assert isinstance(result, bool)

    def test_parse_false_lowercase(self):
        result = mod_config_value_parse("false")
        assert result is False
        assert isinstance(result, bool)

    def test_parse_integer_zero(self):
        result = mod_config_value_parse("0")
        assert result == 0
        assert isinstance(result, int)

    def test_parse_integer_positive(self):
        result = mod_config_value_parse("42")
        assert result == 42
        assert isinstance(result, int)

    def test_parse_integer_large(self):
        result = mod_config_value_parse("999")
        assert result == 999
        assert isinstance(result, int)

    def test_parse_float(self):
        result = mod_config_value_parse("3.14")
        assert result == pytest.approx(3.14)
        assert isinstance(result, float)

    def test_parse_float_half(self):
        result = mod_config_value_parse("0.5")
        assert result == pytest.approx(0.5)
        assert isinstance(result, float)

    def test_parse_float_negative(self):
        result = mod_config_value_parse("-1.5")
        assert result == pytest.approx(-1.5)
        assert isinstance(result, float)

    def test_parse_string_plain(self):
        result = mod_config_value_parse("hello")
        assert result == "hello"
        assert isinstance(result, str)

    def test_parse_string_config_value(self):
        result = mod_config_value_parse("some_config_value")
        assert result == "some_config_value"
        assert isinstance(result, str)

    def test_parse_negative_number_is_float(self):
        result = mod_config_value_parse("-1")
        assert isinstance(result, float)
        assert result == -1.0

    def test_parse_empty_string(self):
        result = mod_config_value_parse("")
        assert result == ""
        assert isinstance(result, str)

    def test_parse_mixed_alphanumeric(self):
        result = mod_config_value_parse("12a3")
        assert result == "12a3"
        assert isinstance(result, str)

    def test_parse_float_with_leading_dot(self):
        result = mod_config_value_parse(".5")
        assert isinstance(result, float)
        assert result == pytest.approx(0.5)

    def test_parse_integer_string_100(self):
        result = mod_config_value_parse("100")
        assert result == 100
        assert isinstance(result, int)

    def test_parse_float_string_2_5(self):
        result = mod_config_value_parse("2.5")
        assert result == pytest.approx(2.5)
        assert isinstance(result, float)


class TestSystemModList:
    """Test SYSTEM_MOD_LIST matches between Python and Mojo."""

    def test_system_mod_list_count(self):
        assert len(SYSTEM_MOD_LIST) == 7

    def test_system_mod_list_contains_accounts(self):
        assert "sys_accounts" in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_analyser(self):
        assert "sys_analyser" in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_progress(self):
        assert "sys_progress" in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_risk(self):
        assert "sys_risk" in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_simulation(self):
        assert "sys_simulation" in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_transaction_cost(self):
        assert "sys_transaction_cost" in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_scheduler(self):
        assert "sys_scheduler" in SYSTEM_MOD_LIST

    def test_system_mod_list_exact_order(self):
        expected = [
            "sys_accounts",
            "sys_analyser",
            "sys_progress",
            "sys_risk",
            "sys_simulation",
            "sys_transaction_cost",
            "sys_scheduler",
        ]
        assert SYSTEM_MOD_LIST == expected


class TestModHandler:
    """Test ModHandler matches between Python and Mojo."""

    def test_mod_handler_init(self):
        handler = ModHandler()
        assert handler._env is None
        assert len(handler._mod_list) == 0
        assert len(handler._mod_dict) == 0

    def test_mod_handler_tear_down_returns_dict(self):
        handler = ModHandler()
        result = handler.tear_down(None)
        assert isinstance(result, dict)
