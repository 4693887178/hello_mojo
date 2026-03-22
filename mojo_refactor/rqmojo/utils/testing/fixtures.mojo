"""
RQAlpha Mojo - Testing Fixtures
Ported from rqalpha/utils/testing/fixtures.py
"""

from std.collections import Dict, List
from rqmojo.utils import RqAttrDict, RqValue
from rqmojo.environment import Environment
from rqmojo.data.data_proxy import DataProxy, create_data_proxy


struct RQAlphaFixture:
    def init_fixture(mut self):
        pass


struct EnvironmentFixture:
    var env_config: RqAttrDict
    var env: Optional[Environment]
    
    def __init__(out self):
        self.env_config = RqAttrDict()
        self.env = None
    
    def init_fixture(mut self):
        pass


struct TempDirFixture:
    var temp_dir: Optional[String]
    
    def __init__(out self):
        self.temp_dir = None
    
    def init_fixture(mut self):
        pass


struct BaseDataSourceFixture:
    var default_bundle_path: String
    var env_config: RqAttrDict
    var base_data_source: Optional[DataProxy]
    var temp_dir: Optional[String]
    var env: Optional[Environment]
    
    def __init__(out self):
        self.default_bundle_path = ""
        self.env_config = RqAttrDict()
        self.base_data_source = None
        self.temp_dir = None
        self.env = None
    
    def init_fixture(mut self):
        pass


struct BarDictPriceBoardFixture:
    var price_board: Optional[DataProxy]
    var env: Optional[Environment]
    var env_config: RqAttrDict
    
    def __init__(out self):
        self.price_board = None
        self.env = None
        self.env_config = RqAttrDict()
    
    def init_fixture(mut self):
        pass


struct DataProxyFixture:
    var data_proxy: DataProxy
    var temp_dir: Optional[String]
    var env: Optional[Environment]
    var env_config: RqAttrDict
    var default_bundle_path: String
    var _initialized: Bool
    
    def __init__(out self):
        self.data_proxy = create_data_proxy()
        self.temp_dir = None
        self.env = None
        self.env_config = RqAttrDict()
        self.default_bundle_path = ""
        self._initialized = False
    
    def init_fixture(mut self):
        if not self._initialized:
            self.data_proxy = create_data_proxy()
            self._initialized = True
    
    def data_source(mut self) -> DataProxy:
        return self.data_proxy^
    
    def base_data_source(mut self) -> DataProxy:
        return self.data_proxy^
    
    def price_board(mut self) -> DataProxy:
        return self.data_proxy^


struct MatcherFixture:
    var env_config: RqAttrDict
    var env: Optional[Environment]
    var matcher: Optional[String]
    
    def __init__(out self):
        self.env_config = RqAttrDict()
        self.env = None
        self.matcher = None
    
    def init_fixture(mut self):
        pass
