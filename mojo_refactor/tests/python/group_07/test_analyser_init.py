# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/__init__.py
Group 07 - File 03
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestAnalyserInitStructure:
    def test_config_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser import __config__
        assert __config__ is not None
        assert isinstance(__config__, dict)

    def test_config_keys(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser import __config__
        expected_keys = ['benchmark', 'record', 'strategy_name', 'output_file', 
                         'report_save_path', 'plot', 'plot_save_file', 'plot_config']
        for key in expected_keys:
            assert key in __config__, f"Missing config key: {key}"

    def test_load_mod_function(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser import load_mod
        assert callable(load_mod)


class TestAnalyserLoadMod:
    def test_load_mod_returns_mod(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser import load_mod
        result = load_mod()
        assert result is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
