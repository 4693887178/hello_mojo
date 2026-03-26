# -*- coding: utf-8 -*-
"""
Test for cmds/run.py
Group 08 - File 1
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRunCommand:
    def test_run_function_exists(self):
        from rqalpha.cmds.run import run
        assert callable(run)

    def test_inject_run_param_exists(self):
        from rqalpha.cmds.run import inject_run_param
        assert callable(inject_run_param)

    def test_run_has_cli_decorator(self):
        from rqalpha.cmds.run import run
        assert hasattr(run, 'params')


class TestRunImports:
    def test_import_click(self):
        import click
        assert click is not None

    def test_import_parse_config(self):
        from rqalpha.utils.config import parse_config
        assert callable(parse_config)

    def test_import_cli(self):
        from rqalpha.cmds.entry import cli
        assert cli is not None


class TestRunOptions:
    def test_data_bundle_path_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__data_bundle_path' in param_names

    def test_strategy_file_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__strategy_file' in param_names

    def test_start_date_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__start_date' in param_names

    def test_end_date_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__end_date' in param_names

    def test_frequency_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__frequency' in param_names

    def test_account_option(self):
        from rqalpha.cmds.run import run
        param_names = [p.name for p in run.params]
        assert 'base__accounts' in param_names


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
