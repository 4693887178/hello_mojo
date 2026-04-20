"""
Comprehensive Tests for utils/testing/fixtures.mojo
Tests all Fixture structs against Python rqalpha/utils/testing/fixtures.py behavior.

Coverage:
  - MagicMock: construction, call counting, reset, copy, Writable
  - RQAlphaFixture: base fixture init
  - EnvironmentFixture: env creation with dates, config
  - UniverseFixture: env + StrategyUniverse creation
  - TempDirFixture: temp directory path setup
  - BaseDataSourceFixture: env + DataProxy creation
  - BarDictPriceBoardFixture: env + price board setup
  - DataProxyFixture: full fixture (env + data_proxy + price_board + data_source)
  - MatcherFixture: matcher config + env setup
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List

from rqmojo.utils.testing.fixtures import (
    MagicMock,
    RQAlphaFixture,
    EnvironmentFixture,
    UniverseFixture,
    TempDirFixture,
    BaseDataSourceFixture,
    BarDictPriceBoardFixture,
    DataProxyFixture,
    MatcherFixture
)


def test_magic_mock_default_init() raises:
    print("Test: MagicMock default constructor")
    var mock = MagicMock()
    assert_equal(mock._call_count, 0)
    assert_equal(mock._return_value, 0.0)
    assert_equal(len(mock._call_args_list), 0)
    print("  PASSED")


def test_magic_mock_call() raises:
    print("Test: MagicMock call increments count")
    var mock = MagicMock()
    var result = mock()
    assert_equal(mock._call_count, 1)
    assert_equal(result, 0.0)
    assert_equal(len(mock._call_args_list), 1)
    print("  PASSED")


def test_magic_mock_multiple_calls() raises:
    print("Test: MagicMock multiple calls")
    var mock = MagicMock()
    _ = mock()
    _ = mock()
    _ = mock()
    assert_equal(mock._call_count, 3)
    print("  PASSED")


def test_magic_mock_reset() raises:
    print("Test: MagicMock reset_mock clears state")
    var mock = MagicMock()
    _ = mock()
    _ = mock()
    assert_equal(mock._call_count, 2)
    mock.reset_mock()
    assert_equal(mock._call_count, 0)
    assert_equal(len(mock._call_args_list), 0)
    print("  PASSED")


def test_magic_mock_copy() raises:
    print("Test: MagicMock copy preserves state")
    var mock = MagicMock()
    _ = mock()
    _ = mock()
    var copied = mock.copy()
    assert_equal(copied._call_count, 2)
    assert_equal(copied._return_value, 0.0)
    print("  PASSED")


def test_magic_mock_writable() raises:
    print("Test: MagicMock Writable trait")
    var mock = MagicMock()
    var s = String.write(mock)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_rqalpha_fixture_default() raises:
    print("Test: RQAlphaFixture default state")
    var fixture = RQAlphaFixture()
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_rqalpha_fixture_init() raises:
    print("Test: RQAlphaFixture.init_fixture sets flag")
    var fixture = RQAlphaFixture()
    fixture.init_fixture()
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_environment_fixture_default() raises:
    print("Test: EnvironmentFixture default state")
    var fixture = EnvironmentFixture()
    assert_true(fixture.env == None, "env is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_environment_fixture_init() raises:
    print("Test: EnvironmentFixture.init_fixture creates env")
    var fixture = EnvironmentFixture()
    fixture.init_fixture()
    assert_true(fixture.env != None, "env created after init_fixture")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_environment_fixture_writable() raises:
    print("Test: EnvironmentFixture Writable trait")
    var fixture = EnvironmentFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_universe_fixture_default() raises:
    print("Test: UniverseFixture default state")
    var fixture = UniverseFixture()
    assert_true(fixture.env == None, "env is None by default")
    assert_true(fixture.universe == None, "universe is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_universe_fixture_init() raises:
    print("Test: UniverseFixture.init_fixture creates env + universe")
    var fixture = UniverseFixture()
    fixture.init_fixture()
    assert_true(fixture.env != None, "env created after init_fixture")
    assert_true(fixture.universe != None, "universe created after init_fixture")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_universe_fixture_writable() raises:
    print("Test: UniverseFixture Writable trait")
    var fixture = UniverseFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_temp_dir_fixture_default() raises:
    print("Test: TempDirFixture default state")
    var fixture = TempDirFixture()
    assert_true(fixture.temp_dir == None, "temp_dir is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_temp_dir_fixture_init() raises:
    print("Test: TempDirFixture.init_fixture sets temp dir path")
    var fixture = TempDirFixture()
    fixture.init_fixture()
    assert_true(fixture.temp_dir != None, "temp_dir set after init_fixture")
    assert_equal(fixture.temp_dir.value(), "/tmp/rqmojo_test", "correct temp dir path")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_temp_dir_fixture_writable() raises:
    print("Test: TempDirFixture Writable trait")
    var fixture = TempDirFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_base_data_source_fixture_default() raises:
    print("Test: BaseDataSourceFixture default state")
    var fixture = BaseDataSourceFixture()
    assert_true(fixture.env == None, "env is None by default")
    assert_true(fixture.base_data_source == None, "base_data_source is None by default")
    assert_true(fixture.temp_dir == None, "temp_dir is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_base_data_source_fixture_init() raises:
    print("Test: BaseDataSourceFixture.init_fixture creates env + ds")
    var fixture = BaseDataSourceFixture()
    fixture.init_fixture()
    assert_true(fixture.env != None, "env created after init_fixture")
    assert_true(fixture.base_data_source != None, "base_data_source created after init_fixture")
    assert_true(fixture.temp_dir != None, "temp_dir set after init_fixture")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_base_data_source_fixture_writable() raises:
    print("Test: BaseDataSourceFixture Writable trait")
    var fixture = BaseDataSourceFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_bar_dict_price_board_fixture_default() raises:
    print("Test: BarDictPriceBoardFixture default state")
    var fixture = BarDictPriceBoardFixture()
    assert_true(fixture.price_board == None, "price_board is None by default")
    assert_true(fixture.env == None, "env is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_bar_dict_price_board_fixture_init() raises:
    print("Test: BarDictPriceBoardFixture.init_fixture creates env + pb")
    var fixture = BarDictPriceBoardFixture()
    fixture.init_fixture()
    assert_true(fixture.env != None, "env created after init_fixture")
    assert_true(fixture.price_board != None, "price_board created after init_fixture")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_bar_dict_price_board_fixture_writable() raises:
    print("Test: BarDictPriceBoardFixture Writable trait")
    var fixture = BarDictPriceBoardFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_data_proxy_fixture_default() raises:
    print("Test: DataProxyFixture default state (all fields None)")
    var fixture = DataProxyFixture()
    assert_true(fixture.data_proxy == None, "data_proxy is None by default")
    assert_true(fixture.data_source == None, "data_source is None by default")
    assert_true(fixture.price_board == None, "price_board is None by default")
    assert_true(fixture.base_data_source == None, "base_data_source is None by default")
    assert_true(fixture.env == None, "env is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_data_proxy_fixture_init() raises:
    print("Test: DataProxyFixture.init_fixture creates all components")
    var fixture = DataProxyFixture()
    fixture.init_fixture()
    assert_true(fixture.env != None, "env created after init_fixture")
    assert_true(fixture.base_data_source != None, "base_data_source created after init_fixture")
    assert_true(fixture.data_source != None, "data_source created after init_fixture")
    assert_true(fixture.price_board != None, "price_board created after init_fixture")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_data_proxy_fixture_writable() raises:
    print("Test: DataProxyFixture Writable trait")
    var fixture = DataProxyFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def test_matcher_fixture_default() raises:
    print("Test: MatcherFixture default state")
    var fixture = MatcherFixture()
    assert_true(fixture.matcher == None, "matcher is None by default")
    assert_equal(fixture.matching_type, "CURRENT_BAR_CLOSE", "default matching_type")
    assert_true(fixture.env == None, "env is None by default")
    assert_false(fixture.initialized, "not initialized by default")
    print("  PASSED")


def test_matcher_fixture_init() raises:
    print("Test: MatcherFixture.init_fixture creates env + matcher")
    var fixture = MatcherFixture()
    fixture.init_fixture()
    assert_true(fixture.env != None, "env created after init_fixture")
    assert_true(fixture.matcher != None, "matcher set after init_fixture")
    assert_equal(fixture.matcher.value(), "DefaultMatcher", "correct matcher name")
    assert_true(fixture.initialized, "initialized after init_fixture")
    print("  PASSED")


def test_matcher_fixture_matching_type_preserved() raises:
    print("Test: MatcherFixture matching_type preserved through init")
    var fixture = MatcherFixture()
    assert_equal(fixture.matching_type, "CURRENT_BAR_CLOSE", "matching_type before init")
    fixture.init_fixture()
    assert_equal(fixture.matching_type, "CURRENT_BAR_CLOSE", "matching_type after init")
    print("  PASSED")


def test_matcher_fixture_writable() raises:
    print("Test: MatcherFixture Writable trait")
    var fixture = MatcherFixture()
    fixture.init_fixture()
    var s = String.write(fixture)
    assert_true(s.byte_length() > 0, "Writable should produce output")
    print("  PASSED")


def main() raises:
    print("=" * 60)
    print("Running fixtures.mojo Comprehensive Tests")
    print("=" * 60)
    print("")

    print("--- MagicMock ---")
    test_magic_mock_default_init()
    test_magic_mock_call()
    test_magic_mock_multiple_calls()
    test_magic_mock_reset()
    test_magic_mock_copy()
    test_magic_mock_writable()

    print("")
    print("--- RQAlphaFixture ---")
    test_rqalpha_fixture_default()
    test_rqalpha_fixture_init()

    print("")
    print("--- EnvironmentFixture ---")
    test_environment_fixture_default()
    test_environment_fixture_init()
    test_environment_fixture_writable()

    print("")
    print("--- UniverseFixture ---")
    test_universe_fixture_default()
    test_universe_fixture_init()
    test_universe_fixture_writable()

    print("")
    print("--- TempDirFixture ---")
    test_temp_dir_fixture_default()
    test_temp_dir_fixture_init()
    test_temp_dir_fixture_writable()

    print("")
    print("--- BaseDataSourceFixture ---")
    test_base_data_source_fixture_default()
    test_base_data_source_fixture_init()
    test_base_data_source_fixture_writable()

    print("")
    print("--- BarDictPriceBoardFixture ---")
    test_bar_dict_price_board_fixture_default()
    test_bar_dict_price_board_fixture_init()
    test_bar_dict_price_board_fixture_writable()

    print("")
    print("--- DataProxyFixture ---")
    test_data_proxy_fixture_default()
    test_data_proxy_fixture_init()
    test_data_proxy_fixture_writable()

    print("")
    print("--- MatcherFixture ---")
    test_matcher_fixture_default()
    test_matcher_fixture_init()
    test_matcher_fixture_matching_type_preserved()
    test_matcher_fixture_writable()

    print("")
    print("=" * 60)
    print("All fixtures tests completed successfully!")
    print("=" * 60)
