# -*- coding: utf-8 -*-
"""
Test for __main__.py
Group 06 - File 04
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestMainModule:
    """Test __main__.py"""
    
    def test_entry_point_exists(self):
        """Test that entry_point function exists"""
        from rqalpha.__main__ import entry_point
        assert callable(entry_point)
    
    def test_cli_import(self):
        """Test that cli can be imported"""
        from rqalpha.cmds import cli
        assert cli is not None
    
    def test_inject_mod_commands_import(self):
        """Test that inject_mod_commands can be imported"""
        from rqalpha.mod.utils import inject_mod_commands
        assert callable(inject_mod_commands)
    
    def test_module_structure(self):
        """Test module structure"""
        import rqalpha.__main__ as main_module
        assert hasattr(main_module, 'entry_point')


class TestMainModuleIntegration:
    """Integration tests for __main__.py"""
    
    def test_cli_is_click_group(self):
        """Test that cli is a click group"""
        import click
        from rqalpha.cmds import cli
        assert isinstance(cli, click.Group)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
