# -*- coding: utf-8 -*-
"""
Test for data/bundle.py
Group 09 - File 10
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestBundle:
    def test_bundle_module_exists(self):
        from rqalpha.data import bundle
        assert bundle is not None


class TestBundleFunctions:
    def test_bundle_has_update_bundle(self):
        from rqalpha.data.bundle import update_bundle
        assert callable(update_bundle)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
