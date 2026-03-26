# -*- coding: utf-8 -*-
"""
Test for cmds/bundle.py
Group 06 - File 06
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestBundleCommands:
    """Test cmds/bundle.py"""
    
    def test_module_imports(self):
        """Test that module can be imported"""
        from rqalpha.cmds import bundle
        assert bundle is not None
    
    def test_create_bundle_command_exists(self):
        """Test create_bundle command exists"""
        from rqalpha.cmds.bundle import create_bundle
        assert callable(create_bundle)
    
    def test_update_bundle_command_exists(self):
        """Test update_bundle command exists"""
        from rqalpha.cmds.bundle import update_bundle
        assert callable(update_bundle)
    
    def test_download_bundle_command_exists(self):
        """Test download_bundle command exists"""
        from rqalpha.cmds.bundle import download_bundle
        assert callable(download_bundle)
    
    def test_check_bundle_command_exists(self):
        """Test check_bundle command exists"""
        from rqalpha.cmds.bundle import check_bundle
        assert callable(check_bundle)
    
    def test_cdn_url_defined(self):
        """Test CDN_URL is defined"""
        from rqalpha.cmds.bundle import CDN_URL
        assert CDN_URL is not None
        assert "ricequant.com" in CDN_URL


class TestBundleHelperFunctions:
    """Test bundle helper functions"""
    
    def test_get_exactly_url_exists(self):
        """Test get_exactly_url function exists"""
        from rqalpha.cmds.bundle import get_exactly_url
        assert callable(get_exactly_url)
    
    def test_download_exists(self):
        """Test download function exists"""
        from rqalpha.cmds.bundle import download
        assert callable(download)
    
    def test_check_bundle_data_exists(self):
        """Test check_bundle_data function exists"""
        from rqalpha.cmds.bundle import check_bundle_data
        assert callable(check_bundle_data)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
