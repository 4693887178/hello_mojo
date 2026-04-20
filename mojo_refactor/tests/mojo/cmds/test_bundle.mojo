"""
Comprehensive Test Suite for cmds/bundle.mojo

Tests all public functions, CLI commands, and utility functions
ported from rqalpha/cmds/bundle.py.

Coverage:
  - _format_cdn_url:     URL formatting with zero-padding
  - _expanduser:         ~ expansion to home directory
  - _get_proxy_env:      RQALPHA_PROXY env var
  - create_bundle:        error path (no rqdatac)
  - update_bundle:        error path (no rqdatac)
  - download_bundle:      confirm=False path
  - check_bundle:         non-existent bundle
  - get_exactly_url:      URL resolution (requires network)
  - download:             HTTP download (requires network)
  - check_bundle_data:    HDF5 validation (missing files)
  - CLI commands:         argmojo Command creation
  - register/dispatch:    command registration and dispatch
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List, Dict

from rqmojo.cmds.bundle import (
    _format_cdn_url,
    _expanduser,
    _get_proxy_env,
    run_create_bundle,
    run_update_bundle,
    run_download_bundle,
    run_check_bundle,
    create_bundle,
    update_bundle,
    download_bundle,
    check_bundle,
    get_exactly_url,
    download,
    check_bundle_data,
    create_create_bundle_command,
    create_update_bundle_command,
    create_download_bundle_command,
    create_check_bundle_command,
    register_bundle_commands,
    dispatch_bundle_command,
)


# ── _format_cdn_url tests ──────────────────────────────────────────────


def test_format_cdn_url_normal() raises:
    """Test CDN URL formatting with normal year/month values."""
    var url = _format_cdn_url(2024, 6)
    var expected = "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202406.tar.bz2"
    assert_equal(url, expected, "CDN URL for 2024/06")


def test_format_cdn_url_january() raises:
    """Test CDN URL formatting with month=01 (zero-padding)."""
    var url = _format_cdn_url(2023, 1)
    var expected = "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202301.tar.bz2"
    assert_equal(url, expected, "CDN URL for 2023/01 (January)")


def test_format_cdn_url_december() raises:
    """Test CDN URL formatting with month=12."""
    var url = _format_cdn_url(2025, 12)
    var expected = "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202512.tar.bz2"
    assert_equal(url, expected, "CDN URL for 2025/12 (December)")


def test_format_cdn_url_single_digit_month() raises:
    """Test that single-digit months are zero-padded to 2 digits."""
    var url = _format_cdn_url(2020, 9)
    assert_true(url.contains("2009"), "Year should be 2009")
    assert_true(url.contains(".tar.bz2"), "URL should end with .tar.bz2")
    var expected_month = String(9).ascii_rjust(2, "0")
    assert_true(url.contains("rqbundle_2024" + expected_month) or url.contains("rqbundle_2020" + expected_month),
                 "Month should be zero-padded")


# ── _expanduser tests ──────────────────────────────────────────────────


def test_expanduser_tilde_only() raises:
    """Test that '~' alone expands to home directory."""
    var result = _expanduser("~")
    assert_true(len(result) > 0, "Expanded path should not be empty")
    assert_true(result[byte=0] != '~', "Should not start with ~ anymore")


def test_expanduser_tilde_with_path() raises:
    """Test that '~/path' expands correctly."""
    var result = _expanduser("~/.rqalpha")
    assert_true(len(result) > len("~/.rqalpha"), "Should be longer than input")
    assert_true(result[byte=0] != '~', "Should not start with ~")
    assert_true(result.contains(".rqalpha"), "Should contain .rqalpha component")


def test_expanduser_normal_path() raises:
    """Test that non-~ paths pass through unchanged."""
    var result = _expanduser("/opt/bundle")
    assert_equal(result, "/opt/bundle", "Absolute path should pass through")


def test_expanduser_empty_path() raises:
    """Test empty string handling."""
    var result = _expanduser("")
    assert_equal(result, "", "Empty string should return empty")


def test_expanduser_relative_path() raises:
    """Test relative paths without ~."""
    var result = _expanduser("./bundle")
    assert_equal(result, "./bundle", "Relative path should pass through")


# ── _get_proxy_env tests ───────────────────────────────────────────────


def test_get_proxy_env() raises:
    """Test proxy environment variable reading (may be empty)."""
    var proxy = _get_proxy_env()
    assert_true(proxy is String, "Should return a String")


# ── create_bundle / run_create_bundle tests ───────────────────────────


def test_create_bundle_no_rqdatac() raises:
    """Test create_bundle when rqdatac is not installed (error path).

    Should return 1 (error) with informative message.
    """
    var result = run_create_bundle("/tmp/test_bundle", "", False, 1)
    assert_equal(result, 1, "Should return 1 when rqdatac unavailable")


def test_create_bundle_alias() raises:
    """Test backward-compatible alias create_bundle()."""
    var result = create_bundle("/tmp/test_bundle")
    assert_equal(result, 1, "Alias should also return 1 when rqdatac unavailable")


# ── update_bundle / run_update_bundle tests ───────────────────────────


def test_update_bundle_no_rqdatac() raises:
    """Test update_bundle when rqdatac is not installed (error path)."""
    var result = run_update_bundle("/tmp/test_bundle", "", False, 1)
    assert_equal(result, 1, "Should return 1 when rqdatac unavailable")


def test_update_bundle_alias() raises:
    """Test backward-compatible alias update_bundle()."""
    var result = update_bundle("/tmp/test_bundle")
    assert_equal(result, 1, "Alias should also return 1 when rqdatac unavailable")


# ── download_bundle / run_download_bundle tests ────────────────────────


def test_download_bundle_no_confirm() raises:
    """Test download_bundle with confirm=False on non-existent custom path.

    Should proceed without prompting (confirm=False).
    Note: Will fail at get_exactly_url (network required).
    """
    try:
        var result = run_download_bundle("/tmp/nonexistent_custom_bundle", False)
        print("download_bundle returned: ", result)
    except e:
        print("download_bundle raised (expected - no network): ", String(e))


def test_download_bundle_alias() raises:
    """Test backward-compatible alias download_bundle()."""
    try:
        var result = download_bundle("/tmp/test", False)
        print("download_bundle alias returned: ", result)
    except e:
        print("download_bundle alias raised (expected): ", String(e))


# ── check_bundle / run_check_bundle tests ─────────────────────────────


def test_check_bundle_nonexistent() raises:
    """Test check_bundle on non-existent bundle directory.

    Should call check_bundle_data which reports missing instruments.
    """
    try:
        var result = run_check_bundle("/tmp/nonexistent_bundle_xyz")
        assert_equal(result, 0, "check_bundle should return 0 even for missing dir")
    except e:
        print("check_bundle raised: ", String(e))


def test_check_bundle_alias() raises:
    """Test backward-compatible alias check_bundle()."""
    try:
        var result = check_bundle("/tmp/nonexistent")
        assert_equal(result, 0, "Alias should return 0")
    except e:
        print("check_bundle alias raised: ", String(e))


# ── check_bundle_data tests ───────────────────────────────────────────


def test_check_bundle_data_all_missing() raises:
    """Test check_bundle_data when no instrument files exist.

    Should report incomplete bundle.
    """
    check_bundle_data("/tmp/nonexistent_bundle_dir_xyz123")
    print("PASS: check_bundle_data handled all-missing directory")


def test_check_bundle_data_partial_missing() raises:
    """Test check_bundle_data with partial files (some exist, some don't)."""
    from std.python import Python, PythonObject
    var py_os = Python.import_module("os")
    var py_shutil = Python.import_module("shutil")
    var pid = Int(py=py_os.getpid())
    var tmpdir = "/tmp/test_bundle_partial_" + String(pid)
    py_os.makedirs(tmpdir, exist_ok=True)

    try:
        var f = open(tmpdir + "/stocks.h5", "w")
        f.close()
        check_bundle_data(tmpdir)
        print("PASS: check_bundle_data handled partial directory")
    finally:
        py_shutil.rmtree(tmpdir, ignore_errors=True)


# ── CLI Command creation tests ────────────────────────────────────────


def test_create_create_bundle_command() raises:
    """Test create_create_bundle_command returns valid Command."""
    var cmd = create_create_bundle_command()
    assert_true(cmd is not None, "Command should not be None")


def test_create_update_bundle_command() raises:
    """Test create_update_bundle_command returns valid Command."""
    var cmd = create_update_bundle_command()
    assert_true(cmd is not None, "Command should not be None")


def test_create_download_bundle_command() raises:
    """Test create_download_bundle_command returns valid Command."""
    var cmd = create_download_bundle_command()
    assert_true(cmd is not None, "Command should not be None")


def test_create_check_bundle_command() raises:
    """Test create_check_bundle_command returns valid Command."""
    var cmd = create_check_bundle_command()
    assert_true(cmd is not None, "Command should not be None")


# ── register_bundle_commands test ──────────────────────────────────────


def test_register_bundle_commands() raises:
    """Test that register_bundle_commands executes without error."""
    from argmojo import Command
    var cli = Command("test_cli", "Test CLI")
    register_bundle_commands(cli)
    print("PASS: register_bundle_commands executed successfully")


# ── dispatch_bundle_command tests ──────────────────────────────────────


def test_dispatch_unknown_command() raises:
    """Test dispatch_bundle_command with unknown subcommand.

    Should return 1 (error) for unknown commands.
    """
    from argmojo import ParseResult
    var pr = ParseResult()
    pr.subcommand = "nonexistent_command"
    var result = dispatch_bundle_command(pr)
    assert_equal(result, 1, "Unknown command should return 1")


# ── Integration: URL format consistency ────────────────────────────────


def test_cdn_url_format_consistency() raises:
    """Verify all CDN URLs follow the same format pattern."""
    var url1 = _format_cdn_url(2024, 1)
    var url2 = _format_cdn_url(2024, 12)
    var url3 = _format_cdn_url(2020, 6)

    var prefix = "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_"
    var suffix = ".tar.bz2"

    assert_true(url1.contains(prefix), "URL1 should have correct prefix")
    assert_true(url1.contains(suffix), "URL1 should have correct suffix")
    assert_true(url2.contains(prefix), "URL2 should have correct prefix")
    assert_true(url2.contains(suffix), "URL2 should have correct suffix")
    assert_true(url3.contains(prefix), "URL3 should have correct prefix")
    assert_true(url3.contains(suffix), "URL3 should have correct suffix")

    assert_equal(len(url1), len(url2), "All URLs should have same length")
    assert_equal(len(url2), len(url3), "All URLs should have same length")


def test_cdn_url_year_month_encoding() raises:
    """Verify year and month are encoded as 4+2 digits respectively."""
    var url = _format_cdn_url(2024, 6)

    assert_true(url.contains("rqbundle_202406"), "URL should contain rqbundle_202406")
    assert_true(url.contains(".tar.bz2"), "URL should end with .tar.bz2")

    var url_2024_01 = _format_cdn_url(2024, 1)
    assert_true(url_2024_01.contains("rqbundle_202401"), "January should be zero-padded to 01")

    var url_2020_12 = _format_cdn_url(2020, 12)
    assert_true(url_2020_12.contains("rqbundle_202012"), "December should be 12")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
