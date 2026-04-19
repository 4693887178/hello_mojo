
from std.testing import assert_true, assert_equal
from rqmojo.api import ApiRegistry, export_as_api, register_api, decorate_api_exc


def test_api_functions() raises:
    print("Testing API functions...")
    _ = export_as_api("my_func")
    register_api("my_alias", "my_func")
    _ = decorate_api_exc("my_func")
    assert_true(True, "API functions should not crash")


def test_api_registry_full() raises:
    """Test the full ApiRegistry functionality."""
    var reg = ApiRegistry()
    _ = reg.export_as_api("order_shares")
    var apis = reg.get_all_apis()
    assert_equal(len(apis), 1, "should have 1 registered API")
    assert_equal(apis[0], "order_shares", "name should match")
    assert_true(reg.is_exception_checked("order_shares"), "should be exception-checked after export")


def main() raises:
    test_api_functions()
    test_api_registry_full()
    print("All api.mojo tests passed!")
