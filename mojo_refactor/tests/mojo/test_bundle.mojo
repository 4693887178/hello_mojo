"""
Bundle Module Unit Tests.
Tests for rqmojo/data/bundle.mojo.

Coverage:
  - Constants (START_DATE, END_DATE, CORPORATE_ACTION_EXCLUSIONS)
  - BundleVersion (default, equality)
  - BundleMetadata (creation, fields)
  - Bundle (creation, paths, methods)
  - Field constants
  - create_bundle function
"""

from std.testing import assert_equal, assert_true, assert_false
from rqmojo.data.bundle import (
    START_DATE,
    END_DATE,
    CORPORATE_ACTION_EXCLUSIONS_0,
    CORPORATE_ACTION_EXCLUSIONS_1,
    CORPORATE_ACTION_EXCLUSIONS_2,
    STOCK_FIELDS_0,
    INDEX_FIELDS_0,
    FUTURES_EXTRA_0,
    BundleVersion,
    BundleMetadata,
    Bundle,
    create_bundle,
)


def test_constants() raises:
    """Test that constants are correctly defined."""
    assert_equal(START_DATE, 20050104, "START_DATE should be 20050104.")
    assert_equal(END_DATE, 29991231, "END_DATE should be 29991231.")
    assert_equal(CORPORATE_ACTION_EXCLUSIONS_0, "Future", "First exclusion should be Future.")
    assert_equal(CORPORATE_ACTION_EXCLUSIONS_1, "Option", "Second exclusion should be Option.")
    assert_equal(CORPORATE_ACTION_EXCLUSIONS_2, "Spot", "Third exclusion should be Spot.")


def test_bundle_version_default() raises:
    """Test BundleVersion default constructor."""
    var version = BundleVersion.default()
    assert_equal(version.major, 1, "Major version should be 1.")
    assert_equal(version.minor, 0, "Minor version should be 0.")
    assert_equal(version.patch, 0, "Patch version should be 0.")


def test_bundle_version_equality() raises:
    """Test BundleVersion equality."""
    var v1 = BundleVersion(major=1, minor=0, patch=0)
    var v2 = BundleVersion(major=1, minor=0, patch=0)
    var v3 = BundleVersion(major=2, minor=0, patch=0)

    assert_true(v1 == v2, "Same versions should be equal.")
    assert_false(v1 == v3, "Different versions should not be equal.")


def test_bundle_version_writable() raises:
    """Test BundleVersion Writable trait."""
    var version = BundleVersion(major=1, minor=2, patch=3)
    var output: String = String.write(version)
    assert_true(output.find("1") != -1, "Output should contain major version.")
    assert_true(output.find("2") != -1, "Output should contain minor version.")
    assert_true(output.find("3") != -1, "Output should contain patch version.")


def test_bundle_metadata_creation() raises:
    """Test BundleMetadata creation."""
    from rqmojo.utils.typing import DateTime
    var dt = DateTime(2024, 1, 15, 10, 30, 0, 0)
    var version = BundleVersion.default()
    var metadata = BundleMetadata(
        version=version,
        created_at=dt,
        market="cn",
        data_types=[]
    )
    assert_equal(metadata.market, "cn", "Market should be cn.")
    assert_equal(metadata.version.major, 1, "Metadata version major should be 1.")


def test_bundle_creation() raises:
    """Test Bundle creation with path."""
    var bundle = create_bundle("/tmp/test_bundle")
    assert_equal(bundle.get_path(), "/tmp/test_bundle", "Path should match.")
    assert_false(bundle.is_initialized(), "New bundle should not be initialized.")
    assert_equal(bundle.get_market(), "cn", "Default market should be cn.")


def test_bundle_paths() raises:
    """Test that Bundle generates correct file paths."""
    var bundle = create_bundle("/data/rqalpha")

    var instr_path = bundle.get_instruments_path()
    assert_true(instr_path.find("instruments.pk") != -1, "Instruments path should end with instruments.pk.")

    var trading_path = bundle.get_trading_dates_path()
    assert_true(trading_path.find("trading_dates.npy") != -1, "Trading dates path should end with trading_dates.npy.")

    var stocks_path = bundle.get_stocks_path()
    assert_true(stocks_path.find("stocks.h5") != -1, "Stocks path should end with stocks.h5.")

    var indexes_path = bundle.get_indexes_path()
    assert_true(indexes_path.find("indexes.h5") != -1, "Indexes path should end with indexes.h5.")

    var futures_path = bundle.get_futures_path()
    assert_true(futures_path.find("futures.h5") != -1, "Futures path should end with futures.h5.")

    var funds_path = bundle.get_funds_path()
    assert_true(funds_path.find("funds.h5") != -1, "Funds path should end with funds.h5.")

    var div_path = bundle.get_dividends_path()
    assert_true(div_path.find("dividends.h5") != -1, "Dividends path should end with dividends.h5.")

    var splits_path = bundle.get_splits_path()
    assert_true(splits_path.find("split_factor.h5") != -1, "Splits path should end with split_factor.h5.")

    var ex_path = bundle.get_ex_cum_factor_path()
    assert_true(ex_path.find("ex_cum_factor.h5") != -1, "Ex cum factor path should end with ex_cum_factor.h5.")


def test_bundle_update() raises:
    """Test Bundle update method."""
    var bundle = create_bundle("/tmp/update_test")
    var result = bundle.update()
    assert_true(result, "Update should return True.")
    assert_true(bundle.is_initialized(), "Bundle should be initialized after update.")


def test_bundle_load() raises:
    """Test Bundle load method."""
    var bundle = create_bundle("/tmp/load_test")
    var result = bundle.load()
    assert_true(result, "Load should return True.")
    assert_true(bundle.is_initialized(), "Bundle should be initialized after load.")


def test_bundle_version_accessor() raises:
    """Test Bundle version accessor."""
    var bundle = create_bundle("/tmp/version_test")
    var version = bundle.get_version()
    assert_equal(version.major, 1, "Default major version should be 1.")
    assert_equal(version.minor, 0, "Default minor version should be 0.")
    assert_equal(version.patch, 0, "Default patch version should be 0.")


def test_field_constants() raises:
    """Test that field constants are defined."""
    assert_equal(STOCK_FIELDS_0, "open", "First stock field should be open.")
    assert_equal(INDEX_FIELDS_0, "open", "First index field should be open.")
    assert_equal(FUTURES_EXTRA_0, "settlement", "First futures extra field should be settlement.")


def main() raises:
    print("=" * 60)
    print("Running Bundle Module Unit Tests")
    print("=" * 60)

    test_constants()
    print("[PASS] test_constants")

    test_bundle_version_default()
    print("[PASS] test_bundle_version_default")

    test_bundle_version_equality()
    print("[PASS] test_bundle_version_equality")

    test_bundle_version_writable()
    print("[PASS] test_bundle_version_writable")

    test_bundle_metadata_creation()
    print("[PASS] test_bundle_metadata_creation")

    test_bundle_creation()
    print("[PASS] test_bundle_creation")

    test_bundle_paths()
    print("[PASS] test_bundle_paths")

    test_bundle_update()
    print("[PASS] test_bundle_update")

    test_bundle_load()
    print("[PASS] test_bundle_load")

    test_bundle_version_accessor()
    print("[PASS] test_bundle_version_accessor")

    test_field_constants()
    print("[PASS] test_field_constants")

    print("=" * 60)
    print("All 11 tests passed!")
    print("=" * 60)
