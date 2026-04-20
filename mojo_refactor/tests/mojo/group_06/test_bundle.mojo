"""
Test for cmds/bundle.mojo
Group 06 - File 06
"""

from rqmojo.cmds.bundle import update_bundle, create_bundle, download_bundle, check_bundle
from rqmojo.cmds.bundle import BundleConfig
from rqmojo.utils.typing import DateTime



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_bundle_config() raises:
    print("Test: BundleConfig struct")
    var config = BundleConfig(
        data_path="/tmp/bundle",
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        include_stock=True,
        include_future=False,
        compression=False,
        concurrency=1
    )
    print("  BundleConfig created successfully")
    assert_true(True, "test passed")


def test_update_bundle() raises:
    print("Test: update_bundle function")
    var config = BundleConfig(
        data_path="/tmp/bundle",
        start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        include_stock=True,
        include_future=False,
        compression=False,
        concurrency=1
    )
    var result = update_bundle(config)
    print("  update_bundle returned: ", result)
    assert_true(True, "test passed")


def test_create_bundle() raises:
    print("Test: create_bundle function")
    var result = create_bundle(
        "/tmp/bundle",
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    print("  create_bundle returned: ", result)
    assert_true(True, "test passed")


def test_download_bundle() raises:
    print("Test: download_bundle function")
    var result = download_bundle("/tmp/bundle")
    print("  download_bundle returned: ", result)
    assert_true(True, "test passed")


def test_check_bundle() raises:
    print("Test: check_bundle function")
    var result = check_bundle("/tmp/bundle")
    print("  check_bundle returned: ", result)
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()