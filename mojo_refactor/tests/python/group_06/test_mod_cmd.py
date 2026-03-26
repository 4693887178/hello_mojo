# -*- coding: utf-8 -*-
"""
Test for cmds/mod.py
Group 06 - File 07
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestModCommands:
    """Test cmds/mod.py"""
    
    def test_module_imports(self):
        """Test that module can be imported"""
        from rqalpha.cmds import mod
        assert mod is not None
    
    def test_mod_command_exists(self):
        """Test mod command exists"""
        from rqalpha.cmds.mod import mod
        assert callable(mod)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
