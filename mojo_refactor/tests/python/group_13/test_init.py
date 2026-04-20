# -*- coding: utf-8 -*-
"""
Test for __init__.py
Group 13 - File 2
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestInitFunctions:
    def test_run_function_exists(self):
        from rqalpha import run
        assert callable(run)

    def test_run_file_function_exists(self):
        from rqalpha import run_file
        assert callable(run_file)

    def test_run_code_function_exists(self):
        from rqalpha import run_code
        assert callable(run_code)

    def test_run_func_function_exists(self):
        from rqalpha import run_func
        assert callable(run_func)


class TestVersion:
    def test_version_exists(self):
        from rqalpha import __version__
        assert __version__ is not None

    def test_version_is_string(self):
        from rqalpha import __version__
        assert isinstance(__version__, str)

    def test_version_info_exists(self):
        from rqalpha import version_info
        assert version_info is not None

    def test_version_info_is_tuple(self):
        from rqalpha import version_info
        assert isinstance(version_info, tuple)


class TestInitImports:
    def test_import_cli(self):
        from rqalpha.cmds import cli
        assert cli is not None

    def test_import_data(self):
        from rqalpha import data
        assert data is not None

    def test_import_interface(self):
        from rqalpha import interface
        assert interface is not None

    def test_import_portfolio(self):
        from rqalpha import portfolio
        assert portfolio is not None

    def test_import_apis(self):
        from rqalpha import apis
        assert apis is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
