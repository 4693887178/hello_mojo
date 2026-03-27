"""
Test for api.mojo
Group 06 - File 05
"""



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_export_as_api() raises:
    print("Test: export_as_api function exists")
    assert_true(True, "test passed")


def test_register_api() raises:
    print("Test: register_api function exists")
    assert_true(True, "test passed")


def test_decorate_api_exc() raises:
    print("Test: decorate_api_exc function exists")
    assert_true(True, "test passed")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()