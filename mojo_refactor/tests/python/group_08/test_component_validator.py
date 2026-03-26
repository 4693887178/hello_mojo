# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_accounts/component_validator.py
Group 08 - File 07
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestComponentValidatorStructure:
    def test_module_exists(self):
        from rqalpha.mod import rqalpha_mod_sys_accounts
        assert rqalpha_mod_sys_accounts is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
