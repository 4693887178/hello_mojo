# -*- coding: utf-8 -*-
"""
Test for cmds/run.py
Group 08 - File 01
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestRunCommandStructure:
    def test_cli_command_exists(self):
        from rqalpha.cmds.run import cli
        assert cli is not None

    def test_run_command_registered(self):
        from rqalpha.cmds.run import cli
        assert 'run' in cli.commands


class TestRunCommandFunction:
    def test_run_function_exists(self):
        from rqalpha.cmds.run import run
        assert callable(run)

    def test_inject_run_param_exists(self):
        from rqalpha.cmds.run import inject_run_param
        assert callable(inject_run_param)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
