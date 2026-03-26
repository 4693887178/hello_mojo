# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_scheduler/scheduler.py
Group 09 - File 4
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestScheduler:
    def test_scheduler_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import Scheduler
        assert Scheduler is not None

    def test_scheduler_has_run_daily(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import Scheduler
        assert hasattr(Scheduler, 'run_daily')

    def test_scheduler_has_run_weekly(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import Scheduler
        assert hasattr(Scheduler, 'run_weekly')

    def test_scheduler_has_run_monthly(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import Scheduler
        assert hasattr(Scheduler, 'run_monthly')

    def test_scheduler_has_get_state(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import Scheduler
        assert hasattr(Scheduler, 'get_state')

    def test_scheduler_has_set_state(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import Scheduler
        assert hasattr(Scheduler, 'set_state')


class TestHelperFunctions:
    def test_market_close_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import market_close
        assert callable(market_close)

    def test_market_open_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import market_open
        assert callable(market_open)

    def test_physical_time_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import physical_time
        assert callable(physical_time)

    def test_verify_function_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_scheduler.scheduler import _verify_function
        assert callable(_verify_function)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
