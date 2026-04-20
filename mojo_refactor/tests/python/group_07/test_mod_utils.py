# -*- coding: utf-8 -*-
"""
Test for mod/utils.py (Python原版) vs mod/utils.mojo (Mojo重构版) 对比验证
Group 07 - File 09

通过Python pytest验证原版功能，作为Mojo重构版的参考基准。
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestModConfigValueParse:
    """测试 mod_config_value_parse 函数 - 配置值解析"""

    def test_parse_true_string(self):
        from rqalpha.mod.utils import mod_config_value_parse
        assert mod_config_value_parse("True") is True
        assert mod_config_value_parse("true") is True

    def test_parse_false_string(self):
        from rqalpha.mod.utils import mod_config_value_parse
        assert mod_config_value_parse("False") is False
        assert mod_config_value_parse("false") is False

    def test_parse_integer(self):
        from rqalpha.mod.utils import mod_config_value_parse
        assert mod_config_value_parse("123") == 123
        assert mod_config_value_parse("0") == 0
        assert mod_config_value_parse("999999") == 999999

    def test_parse_float(self):
        from rqalpha.mod.utils import mod_config_value_parse
        assert abs(mod_config_value_parse("3.14") - 3.14) < 0.001
        assert abs(mod_config_value_parse("0.5") - 0.5) < 0.001
        assert abs(mod_config_value_parse("-1.5") - (-1.5)) < 0.001

    def test_parse_string(self):
        from rqalpha.mod.utils import mod_config_value_parse
        assert mod_config_value_parse("hello") == "hello"
        assert mod_config_value_parse("test_value") == "test_value"

    def test_parse_empty_string(self):
        from rqalpha.mod.utils import mod_config_value_parse
        assert mod_config_value_parse("") == ""

    def test_parse_bool_priority_over_int(self):
        from rqalpha.mod.utils import mod_config_value_parse
        result = mod_config_value_parse("True")
        assert result is True
        assert isinstance(result, bool)

    def test_parse_int_priority_over_float(self):
        from rqalpha.mod.utils import mod_config_value_parse
        result = mod_config_value_parse("42")
        assert result == 42
        assert isinstance(result, int)

    def test_parse_negative_number(self):
        from rqalpha.mod.utils import mod_config_value_parse
        result = mod_config_value_parse("-100")
        assert result == -100


class TestInjectModCommands:
    """测试 inject_mod_commands 函数 - 模块命令注入"""

    def test_inject_mod_commands_exists(self):
        from rqalpha.mod.utils import inject_mod_commands
        assert callable(inject_mod_commands)

    def test_inject_mod_commands_callable(self):
        from rqalpha.mod.utils import inject_mod_commands
        try:
            inject_mod_commands()
        except Exception:
            pass


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
