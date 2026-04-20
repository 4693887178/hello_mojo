# -*- coding: utf-8 -*-
"""
Test for rqalpha/core/global_var.py
Tests for GlobalVars class
"""

import pytest


class TestGlobalVars:
    """Tests for GlobalVars class"""

    def test_global_vars_class_exists(self):
        """Test that GlobalVars class exists"""
        from rqalpha.core.global_var import GlobalVars
        assert GlobalVars is not None

    def test_global_vars_get_state(self):
        """Test that GlobalVars has get_state method"""
        from rqalpha.core.global_var import GlobalVars
        gv = GlobalVars()
        assert hasattr(gv, 'get_state')

    def test_global_vars_set_state(self):
        """Test that GlobalVars has set_state method"""
        from rqalpha.core.global_var import GlobalVars
        gv = GlobalVars()
        assert hasattr(gv, 'set_state')

    def test_global_vars_get_state_returns_bytes(self):
        """Test that get_state returns bytes"""
        from rqalpha.core.global_var import GlobalVars
        gv = GlobalVars()
        state = gv.get_state()
        assert isinstance(state, bytes)

    def test_global_vars_set_state_from_bytes(self):
        """Test that set_state can restore from bytes"""
        from rqalpha.core.global_var import GlobalVars
        gv = GlobalVars()
        gv.test_value = "hello"
        state = gv.get_state()
        
        gv2 = GlobalVars()
        gv2.set_state(state)
        assert hasattr(gv2, 'test_value')

    def test_global_vars_pickle_attribute(self):
        """Test that GlobalVars can pickle attributes"""
        from rqalpha.core.global_var import GlobalVars
        gv = GlobalVars()
        gv.my_number = 42
        state = gv.get_state()
        assert isinstance(state, bytes)


class TestModuleImports:
    """Tests for module imports"""

    def test_import_logger(self):
        """Test that logger is imported"""
        from rqalpha.utils.logger import user_system_log, system_log
        assert user_system_log is not None
        assert system_log is not None
