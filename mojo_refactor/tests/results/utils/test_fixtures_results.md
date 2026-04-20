Failed to initialize Crashpad.  Crash reporting will not be available.  Cause: while locating crashpad handler: unable to locate crashpad handler executable
============================================================
Running fixtures.mojo Comprehensive Tests
============================================================

--- MagicMock ---
Test: MagicMock default constructor
  PASSED
Test: MagicMock call increments count
  PASSED
Test: MagicMock multiple calls
  PASSED
Test: MagicMock reset_mock clears state
  PASSED
Test: MagicMock copy preserves state
  PASSED
Test: MagicMock Writable trait
  PASSED

--- RQAlphaFixture ---
Test: RQAlphaFixture default state
  PASSED
Test: RQAlphaFixture.init_fixture sets flag
  PASSED

--- EnvironmentFixture ---
Test: EnvironmentFixture default state
  PASSED
Test: EnvironmentFixture.init_fixture creates env
  PASSED
Test: EnvironmentFixture Writable trait
  PASSED

--- UniverseFixture ---
Test: UniverseFixture default state
  PASSED
Test: UniverseFixture.init_fixture creates env + universe
  PASSED
Test: UniverseFixture Writable trait
  PASSED

--- TempDirFixture ---
Test: TempDirFixture default state
  PASSED
Test: TempDirFixture.init_fixture sets temp dir path
  PASSED
Test: TempDirFixture Writable trait
  PASSED

--- BaseDataSourceFixture ---
Test: BaseDataSourceFixture default state
  PASSED
Test: BaseDataSourceFixture.init_fixture creates env + ds
  PASSED
Test: BaseDataSourceFixture Writable trait
  PASSED

--- BarDictPriceBoardFixture ---
Test: BarDictPriceBoardFixture default state
  PASSED
Test: BarDictPriceBoardFixture.init_fixture creates env + pb
  PASSED
Test: BarDictPriceBoardFixture Writable trait
  PASSED

--- DataProxyFixture ---
Test: DataProxyFixture default state (all fields None)
  PASSED
Test: DataProxyFixture.init_fixture creates all components
  PASSED
Test: DataProxyFixture Writable trait
  PASSED

--- MatcherFixture ---
Test: MatcherFixture default state
  PASSED
Test: MatcherFixture.init_fixture creates env + matcher
  PASSED
Test: MatcherFixture matching_type preserved through init
  PASSED
Test: MatcherFixture Writable trait
  PASSED

============================================================
All fixtures tests completed successfully!
============================================================
