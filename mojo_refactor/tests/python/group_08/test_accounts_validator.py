# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_accounts/validator.py
Group 08 - File 08
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestValidatorStructure:
    def test_module_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_accounts import validator
        assert validator is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
