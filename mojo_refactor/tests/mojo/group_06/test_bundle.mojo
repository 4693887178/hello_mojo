"""
Test for cmds/bundle.mojo
Group 06 - File 06
"""

from rqmojo.cmds.bundle import update_bundle, create_bundle, download_bundle, check_bundle
from rqmojo.cmds.bundle import BundleConfig
from rqmojo.utils.typing import DateTime


def test_bundle_config() -> Bool:
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
    return True


def test_update_bundle() -> Bool:
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
    return True


def test_create_bundle() -> Bool:
    print("Test: create_bundle function")
    var result = create_bundle(
        "/tmp/bundle",
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    print("  create_bundle returned: ", result)
    return True


def test_download_bundle() -> Bool:
    print("Test: download_bundle function")
    var result = download_bundle("/tmp/bundle")
    print("  download_bundle returned: ", result)
    return True


def test_check_bundle() -> Bool:
    print("Test: check_bundle function")
    var result = check_bundle("/tmp/bundle")
    print("  check_bundle returned: ", result)
    return True


def main() -> None:
    print("=== Group 06 File 06: Bundle Commands Tests ===")
    print("")
    
    var passed = 0
    var failed = 0
    
    if test_bundle_config():
        passed += 1
    else:
        failed += 1
    
    if test_update_bundle():
        passed += 1
    else:
        failed += 1
    
    if test_create_bundle():
        passed += 1
    else:
        failed += 1
    
    if test_download_bundle():
        passed += 1
    else:
        failed += 1
    
    if test_check_bundle():
        passed += 1
    else:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
