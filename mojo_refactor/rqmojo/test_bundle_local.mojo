from std.testing import assert_equal, assert_true, TestSuite
from cmds.bundle import _format_cdn_url, _expanduser, _get_proxy_env
from cmds.bundle import run_create_bundle, create_bundle, update_bundle, check_bundle
from cmds.bundle import create_create_bundle_command, register_bundle_commands, dispatch_bundle_command

def test_format_cdn_url() raises:
    var url = _format_cdn_url(2024, 6)
    assert_equal(url, "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202406.tar.bz2")

def test_format_january() raises:
    var url = _format_cdn_url(2024, 1)
    assert_equal(url, "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202301.tar.bz2")

def test_expanduser() raises:
    var result = _expanduser("~")
    assert_true(len(result) > 0)
    assert_true(result[byte=0] != '~')

def test_expanduser_path() raises:
    var result = _expanduser("~/.rqalpha")
    assert_true(result.contains(".rqalpha"))

def test_create_no_rqdatac() raises:
    var result = run_create_bundle("/tmp/test", "", False, 1)
    assert_equal(result, 1)

def test_alias() raises:
    var result = create_bundle("/tmp/test")
    assert_equal(result, 1)

def test_cli_creation() raises:
    var cmd = create_create_bundle_command()
    assert_true(cmd is not None)

def test_register() raises:
    from argmojo import Command
    var cli = Command("test", "test")
    register_bundle_commands(cli)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
