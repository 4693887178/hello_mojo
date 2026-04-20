# -*- coding: utf-8 -*-
"""
Test for rqalpha/data/__init__.py
Tests for data package initialization
"""

import pytest


class TestDataPackageInit:
    """Tests for data package initialization"""

    def test_data_module_imports(self):
        """Test that data module can be imported"""
        from rqalpha import data
        assert data is not None

    def test_data_proxy_import(self):
        """Test that DataProxy can be imported"""
        from rqalpha.data import DataProxy
        assert DataProxy is not None

    def test_data_proxy_module_import(self):
        """Test that data_proxy module can be imported"""
        from rqalpha.data import data_proxy
        assert data_proxy is not None


class TestDataProxyClass:
    """Tests for DataProxy class existence"""

    def test_data_proxy_class_exists(self):
        """Test that DataProxy class exists"""
        from rqalpha.data import DataProxy
        assert DataProxy is not None
