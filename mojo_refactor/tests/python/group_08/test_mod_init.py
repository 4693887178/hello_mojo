# -*- coding: utf-8 -*-
"""
Test for mod/__init__.py
Group 08 - File 6
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestModHandler:
    def test_mod_handler_class_exists(self):
        from rqalpha.mod import ModHandler
        assert ModHandler is not None

    def test_mod_handler_has_set_env(self):
        from rqalpha.mod import ModHandler
        assert hasattr(ModHandler, 'set_env')

    def test_mod_handler_has_start_up(self):
        from rqalpha.mod import ModHandler
        assert hasattr(ModHandler, 'start_up')

    def test_mod_handler_has_tear_down(self):
        from rqalpha.mod import ModHandler
        assert hasattr(ModHandler, 'tear_down')


class TestSystemModList:
    def test_system_mod_list_exists(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert SYSTEM_MOD_LIST is not None

    def test_system_mod_list_is_list(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert isinstance(SYSTEM_MOD_LIST, list)

    def test_system_mod_list_contains_sys_accounts(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_accounts' in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_sys_analyser(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_analyser' in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_sys_progress(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_progress' in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_sys_risk(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_risk' in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_sys_simulation(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_simulation' in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_sys_transaction_cost(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_transaction_cost' in SYSTEM_MOD_LIST

    def test_system_mod_list_contains_sys_scheduler(self):
        from rqalpha.mod import SYSTEM_MOD_LIST
        assert 'sys_scheduler' in SYSTEM_MOD_LIST


class TestModImports:
    def test_import_abstract_mod(self):
        from rqalpha.interface import AbstractMod
        assert AbstractMod is not None

    def test_import_logger(self):
        from rqalpha.utils.logger import system_log
        assert system_log is not None

    def test_import_i18n(self):
        from rqalpha.utils.i18n import gettext as _
        assert callable(_)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
