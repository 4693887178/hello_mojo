# -*- coding: utf-8 -*-
"""
Python Test for rqalpha/data/__init__.py
Tests the data package exports
"""

import pytest


def test_data_proxy_import():
    """Test that DataProxy can be imported from data package"""
    from rqalpha.data import DataProxy
    assert DataProxy is not None


def test_data_proxy_module_import():
    """Test that data_proxy module can be imported"""
    from rqalpha.data import data_proxy
    assert data_proxy is not None


def test_data_package_structure():
    """Test the data package structure"""
    import rqalpha.data as data_pkg
    assert hasattr(data_pkg, 'DataProxy')
    assert hasattr(data_pkg, 'data_proxy')


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
