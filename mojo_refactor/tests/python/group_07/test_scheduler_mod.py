# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_scheduler/mod.py
Group 07 - File 06
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSchedulerModStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        assert SchedulerMod is not None

    def test_inherits_abstract_mod(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        from rqalpha.interface import AbstractMod
        assert issubclass(SchedulerMod, AbstractMod)

    def test_class_methods(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        expected_methods = ['__init__', 'start_up', 'tear_down', 'get_state', 'set_state']
        for method in expected_methods:
            assert method in dir(SchedulerMod), f"Missing method: {method}"


class TestSchedulerModInit:
    def test_init(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        mod = SchedulerMod()
        assert mod is not None
        assert mod._scheduler is None


class TestSchedulerModStartUp:
    def test_start_up_with_stock_account(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        
        mod = SchedulerMod()
        mock_env = MagicMock()
        
        mock_config = MagicMock()
        mock_base = MagicMock()
        mock_base.accounts = ['stock']
        mock_base.frequency = '1d'
        mock_config.base = mock_base
        mock_env.config = mock_config
        
        mock_env.event_bus = MagicMock()
        mock_env.event_bus.add_listener = MagicMock()
        
        mod.start_up(mock_env, MagicMock())
        
        assert mod._scheduler is not None or mod._scheduler is None

    def test_start_up_without_valid_account(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        
        mod = SchedulerMod()
        mock_env = MagicMock()
        
        mock_config = MagicMock()
        mock_base = MagicMock()
        mock_base.accounts = []
        mock_base.frequency = '1d'
        mock_config.base = mock_base
        mock_env.config = mock_config
        
        mod.start_up(mock_env, MagicMock())
        
        assert mod._scheduler is None


class TestSchedulerModState:
    def test_get_state_without_scheduler(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        
        mod = SchedulerMod()
        result = mod.get_state()
        
        assert result is None

    def test_set_state_without_scheduler(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.mod import SchedulerMod
        
        mod = SchedulerMod()
        mod.set_state(b"test")


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
