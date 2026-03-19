# test_L05_03_data_proxy.py
# Module: rqalpha.data.data_proxy
# Level: L05 - Data Layer
# Dependencies: interface, model

import pytest


class TestDataProxy:
    """Test DataProxy class"""
    
    def test_data_proxy_exists(self):
        """Test DataProxy exists"""
        from rqalpha.data.data_proxy import DataProxy
        assert DataProxy is not None
    
    def test_data_proxy_methods(self):
        """Test DataProxy has expected methods"""
        from rqalpha.data.data_proxy import DataProxy
        
        methods = [m for m in dir(DataProxy) if not m.startswith('_')]
        assert 'get_instrument' in methods or 'get_bar' in methods


class TestDataProxyMethods:
    """Test DataProxy methods - requires data_source"""
    
    @pytest.mark.skip(reason="Requires DataSource initialization")
    def test_get_instrument(self):
        """Test get_instrument method"""
        pass
    
    @pytest.mark.skip(reason="Requires DataSource initialization")
    def test_get_bar(self):
        """Test get_bar method"""
        pass
    
    @pytest.mark.skip(reason="Requires DataSource initialization")
    def test_history_bars(self):
        """Test history_bars method"""
        pass
