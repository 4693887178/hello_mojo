"""
RQAlpha Mojo - Testing Fixtures
Ported from rqalpha/utils/testing/fixtures.py

Design Notes (vs Python original):
  Python: Class-based with multiple inheritance, @contextmanager decorators,
          unittest.mock.MagicMock, pickle, os, tempfile.TemporaryDirectory
  Mojo:   Struct-based with composition (no MI), RAII-style mock patterns,
          explicit fixture lifecycle. Each fixture is self-contained.

Fixture Map (Python class → Mojo struct):
  RQAlphaFixture              → RQAlphaFixture (base fixture)
    ├── EnvironmentFixture    → EnvironmentFixture (creates Environment)
    │     └── UniverseFixture → UniverseFixture (+StrategyUniverse)
    │     └── BarDictPriceBoardFixture → BarDictPriceBoardFixture (+BarDictPriceBoard)
    │     └── MatcherFixture  → MatcherFixture (config + env)
    ├── TempDirFixture        → TempDirFixture (temp dir path stub)
    └── BaseDataSourceFixture → BaseDataSourceFixture (env + DataProxy)
          └── DataProxyFixture → DataProxyFixture (full: env + data_proxy + price_board)
"""

from std.collections import Dict, List, Optional, Set
from rqmojo.utils import RqAttrDict
from rqmojo.utils.typing import DateTime
from rqmojo.const import MATCHING_TYPE, EXECUTION_PHASE, RUN_TYPE
from rqmojo.environment import Environment, create_environment
from rqmojo.core.events import EventBus, create_event_bus
from rqmojo.core.strategy_universe import StrategyUniverse
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board


struct MagicMock(Copyable, Movable, Writable):
    var _call_count: Int
    var _call_args_list: List[String]
    var _return_value: Float64

    def __init__(out self):
        self._call_count = 0
        self._call_args_list = List[String]()
        self._return_value = 0.0

    def __init__(out self, *, copy: MagicMock):
        self._call_count = copy._call_count
        self._call_args_list = copy._call_args_list.copy()
        self._return_value = copy._return_value

    def __call__(mut self) -> Float64:
        self._call_count += 1
        self._call_args_list.append("()")
        return self._return_value

    def call_count(self) -> Int:
        return self._call_count

    def reset_mock(mut self):
        self._call_count = 0
        self._call_args_list = List[String]()

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MagicMock(calls=", self._call_count, ")")


struct RQAlphaFixture(Movable, Writable):
    var initialized: Bool

    def __init__(out self):
        self.initialized = False

    def init_fixture(mut self):
        self.initialized = True


struct EnvironmentFixture(Movable, Writable):
    var env_config: RqAttrDict
    var env: Optional[Environment]
    var initialized: Bool

    def __init__(out self):
        self.env_config = RqAttrDict()
        self.env = None
        self.initialized = False

    def init_fixture(mut self) raises:
        self.env = create_environment(
            DateTime(2016, 1, 1, 0, 0, 0, 0),
            DateTime(2023, 12, 28, 0, 0, 0, 0),
            RUN_TYPE.BACKTEST
        )
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("EnvironmentFixture(env=", self.env != None, ")")


struct UniverseFixture(Movable, Writable):
    var env_config: RqAttrDict
    var env: Optional[Environment]
    var universe: Optional[StrategyUniverse]
    var initialized: Bool

    def __init__(out self):
        self.env_config = RqAttrDict()
        self.env = None
        self.universe = None
        self.initialized = False

    def init_fixture(mut self) raises:
        self.env = create_environment(
            DateTime(2016, 1, 1, 0, 0, 0, 0),
            DateTime(2023, 12, 28, 0, 0, 0, 0),
            RUN_TYPE.BACKTEST
        )
        var event_bus = create_event_bus()
        self.universe = StrategyUniverse(event_bus^)
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("UniverseFixture(env=", self.env != None, ", universe=", self.universe != None, ")")


struct TempDirFixture(Movable, Writable):
    var temp_dir: Optional[String]
    var initialized: Bool

    def __init__(out self):
        self.temp_dir = None
        self.initialized = False

    def init_fixture(mut self):
        self.temp_dir = "/tmp/rqmojo_test"
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("TempDirFixture(dir=", self.temp_dir, ")")


struct BaseDataSourceFixture(Movable, Writable):
    var default_bundle_path: String
    var env_config: RqAttrDict
    var base_data_source: Optional[DataProxy]
    var temp_dir: Optional[String]
    var env: Optional[Environment]
    var initialized: Bool

    def __init__(out self):
        self.default_bundle_path = ""
        self.env_config = RqAttrDict()
        self.base_data_source = None
        self.temp_dir = None
        self.env = None
        self.initialized = False

    def init_fixture(mut self) raises:
        self.temp_dir = "/tmp/rqmojo_test"
        self.env = create_environment(
            DateTime(2016, 1, 1, 0, 0, 0, 0),
            DateTime(2023, 12, 28, 0, 0, 0, 0),
            RUN_TYPE.BACKTEST
        )
        self.base_data_source = create_data_proxy()
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BaseDataSourceFixture(ds=", self.base_data_source != None, ")")


struct BarDictPriceBoardFixture(Movable, Writable):
    var price_board: Optional[BarDictPriceBoard]
    var env_config: RqAttrDict
    var env: Optional[Environment]
    var initialized: Bool

    def __init__(out self):
        self.price_board = None
        self.env_config = RqAttrDict()
        self.env = None
        self.initialized = False

    def init_fixture(mut self) raises:
        self.env = create_environment(
            DateTime(2016, 1, 1, 0, 0, 0, 0),
            DateTime(2023, 12, 28, 0, 0, 0, 0),
            RUN_TYPE.BACKTEST
        )
        self.price_board = create_bar_dict_price_board()
        if self.env != None:
            self.env.value().set_price_board("BarDictPriceBoard")
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("BarDictPriceBoardFixture(pb=", self.price_board != None, ")")


struct DataProxyFixture(Movable, Writable):
    var data_proxy: Optional[DataProxy]
    var data_source: Optional[DataProxy]
    var price_board: Optional[BarDictPriceBoard]
    var base_data_source: Optional[DataProxy]
    var default_bundle_path: String
    var env_config: RqAttrDict
    var temp_dir: Optional[String]
    var env: Optional[Environment]
    var initialized: Bool

    def __init__(out self):
        self.data_proxy = None
        self.data_source = None
        self.price_board = None
        self.base_data_source = None
        self.default_bundle_path = ""
        self.env_config = RqAttrDict()
        self.temp_dir = None
        self.env = None
        self.initialized = False

    def init_fixture(mut self) raises:
        self.temp_dir = "/tmp/rqmojo_test"
        self.env = create_environment(
            DateTime(2016, 1, 1, 0, 0, 0, 0),
            DateTime(2023, 12, 28, 0, 0, 0, 0),
            RUN_TYPE.BACKTEST
        )
        self.base_data_source = create_data_proxy()
        self.price_board = create_bar_dict_price_board()
        self.data_source = create_data_proxy()
        var dp = create_data_proxy()
        if self.env != None:
            self.env.value().set_price_board("BarDictPriceBoard")
            self.env.value().set_data_proxy(dp^)
        self.data_proxy = None
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("DataProxyFixture(dp=", self.data_proxy != None, ", ds=", self.data_source != None, ")")


struct MatcherFixture(Movable, Writable):
    var matcher: Optional[String]
    var matching_type: String
    var env_config: RqAttrDict
    var env: Optional[Environment]
    var initialized: Bool

    def __init__(out self):
        self.matcher = None
        self.matching_type = "CURRENT_BAR_CLOSE"
        self.env_config = RqAttrDict()
        self.env = None
        self.initialized = False

    def init_fixture(mut self) raises:
        self.env = create_environment(
            DateTime(2016, 1, 1, 0, 0, 0, 0),
            DateTime(2023, 12, 28, 0, 0, 0, 0),
            RUN_TYPE.BACKTEST
        )
        self.matcher = "DefaultMatcher"
        self.initialized = True

    def write_to(self, mut writer: Some[Writer]):
        writer.write("MatcherFixture(matcher=", self.matcher, ")")
