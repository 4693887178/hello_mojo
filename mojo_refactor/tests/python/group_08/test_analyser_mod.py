# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/mod.py
Group 08 - File 9
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, date
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestAnalyserMod:
    def test_analyser_mod_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert AnalyserMod is not None

    def test_analyser_mod_has_start_up(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert hasattr(AnalyserMod, 'start_up')

    def test_analyser_mod_has_tear_down(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert hasattr(AnalyserMod, 'tear_down')

    def test_analyser_mod_has_get_state(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert hasattr(AnalyserMod, 'get_state')

    def test_analyser_mod_has_set_state(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        assert hasattr(AnalyserMod, 'set_state')

    def test_analyser_mod_inherits_abstract_mod(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        from rqalpha.interface import AbstractMod
        assert issubclass(AnalyserMod, AbstractMod)


class TestAnalyserModMethods:
    def test_parse_benchmark_single(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        result = AnalyserMod._parse_benchmark("000001.XSHE")
        assert result == [("000001.XSHE", 1.0)]

    def test_parse_benchmark_with_weight(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        result = AnalyserMod._parse_benchmark("000001.XSHE:0.5")
        assert result == [("000001.XSHE", 0.5)]

    def test_parse_benchmark_multiple(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        result = AnalyserMod._parse_benchmark("000001.XSHE:0.5,000002.XSHE:0.5")
        assert len(result) == 2
        assert result[0] == ("000001.XSHE", 0.5)
        assert result[1] == ("000002.XSHE", 0.5)

    def test_parse_benchmark_dict(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        result = AnalyserMod._parse_benchmark({"000001.XSHE": 0.5, "000002.XSHE": 0.5})
        assert len(result) == 2

    def test_safe_convert_float(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        result = AnalyserMod._safe_convert(1.23456)
        assert result == 1.2346

    def test_safe_convert_none(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import AnalyserMod
        result = AnalyserMod._safe_convert(None)
        assert result is None


class TestPressureTestPeriod:
    def test_pressure_test_period_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import PRESSURE_TEST_PERIOD
        assert PRESSURE_TEST_PERIOD is not None

    def test_pressure_test_period_is_dict(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import PRESSURE_TEST_PERIOD
        assert isinstance(PRESSURE_TEST_PERIOD, dict)

    def test_pressure_test_period_has_keys(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.mod import PRESSURE_TEST_PERIOD
        assert "打击壳价值" in PRESSURE_TEST_PERIOD
        assert "公募基金抱团" in PRESSURE_TEST_PERIOD


class TestAnalyserModImports:
    def test_import_event(self):
        from rqalpha.core.events import EVENT
        assert EVENT is not None

    def test_import_environment(self):
        from rqalpha.environment import Environment
        assert Environment is not None

    def test_import_const(self):
        from rqalpha.const import EXIT_CODE, DEFAULT_ACCOUNT_TYPE
        assert EXIT_CODE is not None
        assert DEFAULT_ACCOUNT_TYPE is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
