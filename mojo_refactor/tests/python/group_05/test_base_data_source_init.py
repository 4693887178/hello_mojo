"""
Test for rqalpha/data/base_data_source/__init__.py
"""


class TestBaseDataSourceInit:
    """Test base_data_source module initialization"""

    def test_base_data_source_import(self):
        """Test BaseDataSource can be imported"""
        from rqalpha.data.base_data_source import BaseDataSource
        
        assert BaseDataSource is not None

    def test_base_data_source_protocol_import(self):
        """Test BaseDataSourceProtocol can be imported"""
        from rqalpha.data.base_data_source import BaseDataSourceProtocol
        
        assert BaseDataSourceProtocol is not None


class TestBaseDataSourceClass:
    """Test BaseDataSource class"""

    def test_base_data_source_has_get_trading_calendars(self):
        """Test BaseDataSource has get_trading_calendars method"""
        from rqalpha.data.base_data_source import BaseDataSource
        
        assert hasattr(BaseDataSource, 'get_trading_calendars')

    def test_base_data_source_has_get_yield_curve(self):
        """Test BaseDataSource has get_yield_curve method"""
        from rqalpha.data.base_data_source import BaseDataSource
        
        assert hasattr(BaseDataSource, 'get_yield_curve')

    def test_base_data_source_has_get_instruments(self):
        """Test BaseDataSource has get_instruments method"""
        from rqalpha.data.base_data_source import BaseDataSource
        
        assert hasattr(BaseDataSource, 'get_instruments')

    def test_base_data_source_has_get_dividend(self):
        """Test BaseDataSource has get_dividend method"""
        from rqalpha.data.base_data_source import BaseDataSource
        
        assert hasattr(BaseDataSource, 'get_dividend')


class TestBaseDataSourceProtocol:
    """Test BaseDataSourceProtocol"""

    def test_protocol_has_required_methods(self):
        """Test protocol has required methods"""
        from rqalpha.data.base_data_source import BaseDataSourceProtocol
        
        assert hasattr(BaseDataSourceProtocol, 'register_day_bar_store')
        assert hasattr(BaseDataSourceProtocol, 'register_instruments')
        assert hasattr(BaseDataSourceProtocol, 'register_dividend_store')
        assert hasattr(BaseDataSourceProtocol, 'register_split_store')
