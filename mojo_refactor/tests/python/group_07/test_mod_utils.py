# -*- coding: utf-8 -*-
"""
Test for mod/utils.py
Group 07 - File 09
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestModConfigValueParse:
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

    def test_parse_float(self):
        from rqalpha.mod.utils import mod_config_value_parse
        
        assert mod_config_value_parse("3.14") == 3.14
        assert mod_config_value_parse("0.5") == 0.5

    def test_parse_string(self):
        from rqalpha.mod.utils import mod_config_value_parse
        
        assert mod_config_value_parse("hello") == "hello"
        assert mod_config_value_parse("test_value") == "test_value"


class TestInjectModCommands:
    def test_inject_mod_commands_exists(self):
        from rqalpha.mod.utils import inject_mod_commands
        assert callable(inject_mod_commands)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
