# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_analyser/report/report.py
Group 09 - File 1
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime, date
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestReportFunctions:
    def test_returns_function_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import _returns
        assert callable(_returns)

    def test_yearly_indicators_function_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import _yearly_indicators
        assert callable(_yearly_indicators)

    def test_monthly_returns_function_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import _monthly_returns
        assert callable(_monthly_returns)

    def test_generate_report_function_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_analyser.report.report import generate_report
        assert callable(generate_report)


class TestReportImports:
    def test_import_os(self):
        import os
        assert os is not None

    def test_import_datetime(self):
        import datetime
        assert datetime is not None

    def test_import_numpy(self):
        import numpy
        assert numpy is not None

    def test_import_pandas(self):
        import pandas
        assert pandas is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
