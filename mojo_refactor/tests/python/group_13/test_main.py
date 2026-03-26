# -*- coding: utf-8 -*-
"""
Test for main.py
Group 13 - File 1
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestMainFunctions:
    def test_run_function_exists(self):
        from rqalpha.main import run
        assert callable(run)

    def test_create_base_scope_exists(self):
        from rqalpha.main import create_base_scope
        assert callable(create_base_scope)

    def test_init_persist_helper_exists(self):
        from rqalpha.main import init_persist_helper
        assert callable(init_persist_helper)

    def test_init_strategy_loader_exists(self):
        from rqalpha.main import init_strategy_loader
        assert callable(init_strategy_loader)

    def test_get_strategy_apis_exists(self):
        from rqalpha.main import get_strategy_apis
        assert callable(get_strategy_apis)

    def test_set_loggers_exists(self):
        from rqalpha.main import set_loggers
        assert callable(set_loggers)


class TestMainImports:
    def test_import_datetime(self):
        import datetime
        assert datetime is not None

    def test_import_logbook(self):
        import logbook
        assert logbook is not None

    def test_import_environment(self):
        from rqalpha.environment import Environment
        assert Environment is not None

    def test_import_executor(self):
        from rqalpha.core.executor import Executor
        assert Executor is not None

    def test_import_strategy(self):
        from rqalpha.core.strategy import Strategy
        assert Strategy is not None

    def test_import_strategy_context(self):
        from rqalpha.core.strategy_context import StrategyContext
        assert StrategyContext is not None

    def test_import_data_proxy(self):
        from rqalpha.data.data_proxy import DataProxy
        assert DataProxy is not None

    def test_import_mod_handler(self):
        from rqalpha.mod import ModHandler
        assert ModHandler is not None


class TestHelperFunctions:
    def test_create_base_scope_returns_dict(self):
        from rqalpha.main import create_base_scope
        scope = create_base_scope()
        assert isinstance(scope, dict)

    def test_get_strategy_apis_returns_dict(self):
        from rqalpha.main import get_strategy_apis
        apis = get_strategy_apis()
        assert isinstance(apis, dict)

    def test_init_rqdatac_exists(self):
        from rqalpha.main import init_rqdatac
        assert callable(init_rqdatac)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
