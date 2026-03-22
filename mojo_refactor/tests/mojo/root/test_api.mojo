
from testing import assert_true
from rqmojo.api import export_as_api, register_api, decorate_api_exc

def test_api_functions() raises:
    print("Testing API functions...")
    export_as_api("my_func")
    register_api("my_alias", "my_func")
    decorate_api_exc("my_func")
    assert_true(True, "API functions should not crash")

def main() raises:
    test_api_functions()
