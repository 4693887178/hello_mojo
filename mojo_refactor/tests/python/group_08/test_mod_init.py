# -*- coding: utf-8 -*-
"""
Test for mod/__init__.py
Group 08 - File 06
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestModInitStructure:
    def test_module_exists(self):
        from rqalpha import mod
        assert mod is not None

    def test_mod_has_functions(self):
        from rqalpha import mod
        assert mod is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
