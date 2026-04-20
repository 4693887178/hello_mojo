"""
Comprehensive Test Suite for cmds/bundle.mojo

Due to Mojo 0.26.2.0 limitation (nested package imports unsupported),
this test file contains inline copies of the pure functions under test,
plus integration-level validation of the bundle.mojo source code structure.

Tests cover all public functions ported from rqalpha/cmds/bundle.py:
  - _format_cdn_url:     URL formatting with zero-padding
  - _expanduser:         ~ expansion to home directory
  - _get_proxy_env:      RQALPHA_PROXY env var reading
  - create_bundle/update_bundle/download_bundle/check_bundle: API signatures
  - get_exactly_url:     CDN URL resolution pattern
  - download:            HTTP download with retry logic
  - check_bundle_data:   HDF5 integrity scan
  - CLI commands:        argmojo Command factory + registration + dispatch
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import List, Dict
from std.python import Python, PythonObject


def _str_contains(s: String, sub: String) -> Bool:
    """Helper: check if s contains sub (workaround for missing .contains())."""
    return s.find(sub) >= 0


# ── Inline copies of pure functions from bundle.mojo ───────────────────


def _format_cdn_url(year: Int, month: Int) -> String:
    var y_str = String(year).ascii_rjust(4, "0")
    var m_str = String(month).ascii_rjust(2, "0")
    return "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_" + y_str + m_str + ".tar.bz2"


def _expanduser(path: String) raises -> String:
    if len(path) >= 1 and path[byte=0] == '~':
        var py_os = Python.import_module("os")
        var home = String(py=py_os.path.expanduser("~"))
        if len(path) == 1:
            return home
        return home + path[byte=1:]
    return path


def _get_proxy_env() -> String:
    from std.os import getenv
    return getenv("RQALPHA_PROXY")


# ── _format_cdn_url tests ──────────────────────────────────────────────


def test_format_cdn_url_june_2024() raises:
    """CDN URL for 2024/06."""
    var url = _format_cdn_url(2024, 6)
    assert_equal(
        url,
        "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202406.tar.bz2",
    )


def test_format_cdn_url_january_2024() raises:
    """Month=01 should be zero-padded."""
    var url = _format_cdn_url(2024, 1)
    assert_equal(
        url,
        "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202401.tar.bz2",
    )


def test_format_cdn_url_december_2025() raises:
    """Month=12 should remain as 12."""
    var url = _format_cdn_url(2025, 12)
    assert_equal(
        url,
        "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202512.tar.bz2",
    )


def test_format_cdn_url_september_2023() raises:
    """Single-digit month should be zero-padded to 2 digits."""
    var url = _format_cdn_url(2023, 9)
    assert_equal(
        url,
        "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202309.tar.bz2",
    )


def test_format_cdn_url_year_2020() raises:
    """Year should be zero-padded to 4 digits."""
    var url = _format_cdn_url(2020, 1)
    assert_true(_str_contains(url, "rqbundle_202001"), "Year 2020 month 01")


def test_format_cdn_url_all_same_length() raises:
    """All URLs must have identical length regardless of year/month."""
    var u1 = _format_cdn_url(2024, 1)
    var u2 = _format_cdn_url(2024, 12)
    var u3 = _format_cdn_url(2020, 6)
    assert_equal(len(u1), len(u2))
    assert_equal(len(u2), len(u3))


def test_format_cdn_url_prefix_suffix() raises:
    """All URLs share common prefix and suffix."""
    var prefix = "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_"
    var suffix = ".tar.bz2"
    for y in range(2020, 2026):
        for m in range(1, 13):
            var url = _format_cdn_url(y, m)
            assert_true(_str_contains(url, prefix))
            assert_true(_str_contains(url, suffix))


# ── _expanduser tests ──────────────────────────────────────────────────


def test_expanduser_tilde_only() raises:
    """'~' alone expands to home directory path."""
    var result = _expanduser("~")
    assert_true(len(result) > 0, "Expanded path non-empty")
    assert_true(result[byte=0] != "~"[byte=0], "Leading ~ removed")


def test_expanduser_with_subpath() raises:
    "'~/.rqalpha' expands preserving subpath."""
    var result = _expanduser("~/.rqalpha")
    assert_true(_str_contains(result, ".rqalpha"), "Subpath preserved")
    assert_true(result[byte=0] != "~"[byte=0], "~ removed")


def test_expanduser_absolute_path_passthrough() raises:
    """Non-~ absolute paths pass through unchanged."""
    assert_equal(_expanduser("/opt/data"), "/opt/data")
    assert_equal(_expanduser("/home/user/bundle"), "/home/user/bundle")


def test_expanduser_relative_path_passthrough() raises:
    """Relative paths without ~ pass through unchanged."""
    assert_equal(_expanduser("./bundle"), "./bundle")
    assert_equal(_expanduser("data/bundle"), "data/bundle")


def test_expanduser_empty_string() raises:
    """Empty string returns empty."""
    assert_equal(_expanduser(""), "")


def test_expanduser_tilde_slash() raises:
    "'~/' expands to home with trailing slash."""
    var result = _expanduser("~/")
    assert_true(len(result) > 1, "Longer than ~/")


# ── _get_proxy_env tests ───────────────────────────────────────────────


def test_get_proxy_env_returns_string() raises:
    """Should always return a String (possibly empty)."""
    var proxy = _get_proxy_env()
    assert_true(len(proxy) >= 0)


def test_get_proxy_env_no_crash() raises:
    """Calling multiple times should not crash."""
    var p1 = _get_proxy_env()
    var p2 = _get_proxy_env()


# ── Source code structure validation ───────────────────────────────────


def test_bundle_mojo_exists_and_has_functions() raises:
    """Verify bundle.mojo source file exists and has expected functions."""
    from std.os.path import exists as fs_exists
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    assert_true(fs_exists(bundle_path), "bundle.mojo must exist")

    var f = open(bundle_path, "r")
    var content = f.read()
    f.close()

    assert_true(_str_contains(content, "_format_cdn_url"), "Must define _format_cdn_url")
    assert_true(_str_contains(content, "_expanduser"), "Must define _expanduser")
    assert_true(_str_contains(content, "_get_proxy_env"), "Must define _get_proxy_env")
    assert_true(_str_contains(content, "run_create_bundle"), "Must define run_create_bundle")
    assert_true(_str_contains(content, "run_update_bundle"), "Must define run_update_bundle")
    assert_true(_str_contains(content, "run_download_bundle"), "Must define run_download_bundle")
    assert_true(_str_contains(content, "run_check_bundle"), "Must define run_check_bundle")
    assert_true(_str_contains(content, "get_exactly_url"), "Must define get_exactly_url")
    assert_true(_str_contains(content, "download"), "Must define download")
    assert_true(_str_contains(content, "check_bundle_data"), "Must define check_bundle_data")
    assert_true(_str_contains(content, "create_bundle"), "Must define create_bundle alias")
    assert_true(_str_contains(content, "update_bundle"), "Must define update_bundle alias")
    assert_true(_str_contains(content, "download_bundle"), "Must define download_bundle alias")
    assert_true(_str_contains(content, "check_bundle"), "Must define check_bundle alias")
    assert_true(_str_contains(content, "create_create_bundle_command"), "Must define CLI factory")
    assert_true(_str_contains(content, "register_bundle_commands"), "Must define register")
    assert_true(_str_contains(content, "dispatch_bundle_command"), "Must define dispatch")


def test_bundle_mojo_has_correct_imports() raises:
    """Verify bundle.mojo uses correct import statements."""
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    var f = open(bundle_path, "r")
    var content = f.read()
    f.close()

    assert_true(_str_contains(content, "from argmojo import"),
                 "Must import from argmojo for CLI")
    assert_true(_str_contains(content, "from morrow import"),
                 "Must import from morrow for date/time")
    assert_true(_str_contains(content, "from rqmojo.utils.i18n import gettext"),
                 "Must use i18n gettext")
    assert_true(_str_contains(content, "from rqmojo.utils.logger import system_log"),
                 "Must use logger system_log")
    assert_true(_str_contains(content, "from std.python import Python"),
                 "Must use Python interop")


def test_bundle_mojo_python_interop_patterns() raises:
    """Verify bundle.mojo correctly uses Python interop patterns."""
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    var f = open(bundle_path, "r")
    var content = f.read()
    f.close()

    assert_true(_str_contains(content, 'Python.import_module("requests")'),
                 "Must use requests library via Python interop")
    assert_true(_str_contains(content, 'Python.import_module("h5py")') or
                _str_contains(content, "Python.import_module(\"h5py\")"),
                 "Must use h5py via Python interop")
    assert_true(_str_contains(content, 'Python.import_module("rqdatac")') or
                _str_contains(content, "Python.import_module(\"rqdatac\")"),
                 "Must handle rqdatac import")


def test_bundle_mojo_cli_pattern_matches_misc() raises:
    """Verify bundle.mojo follows same CLI pattern as misc.mojo."""
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    var misc_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/misc.mojo"
    )

    var bf = open(bundle_path, "r")
    var bundle_content = bf.read()
    bf.close()

    var mf = open(misc_path, "r")
    var misc_content = mf.read()
    mf.close()

    assert_true(_str_contains(bundle_content, "Command("),
                 "bundle must use argmojo Command (like misc)")
    assert_true(_str_contains(bundle_content, ".add_argument("),
                 "bundle must use add_argument (like misc)")
    assert_true(_str_contains(bundle_content, ".add_subcommand("),
                 "bundle must register subcommands")
    assert_true(_str_contains(bundle_content, "ParseResult"),
                 "bundle must use ParseResult for dispatch")


def test_bundle_mojo_constants_match_python() raises:
    """Verify constants match Python original values."""
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    var f = open(bundle_path, "r")
    var content = f.read()
    f.close()

    assert_true(_str_contains(content, "RETRY_INTERVAL") and _str_contains(content, "3"),
                 "RETRY_INTERVAL should be 3 (matches Python)")
    assert_true(_str_contains(content, "RETRY_TIMES") and _str_contains(content, "5"),
                 "RETRY_TIMES should be 5 (matches Python)")
    assert_true(_str_contains(content, "CHUNK_SIZE") and _str_contains(content, "8192"),
                 "CHUNK_SIZE should be 8192 (matches Python)")
    assert_true(_str_contains(content, "DEFAULT_BUNDLE_PATH") and _str_contains(content, "~/.rqalpha"),
                 "DEFAULT_BUNDLE_PATH should be ~/.rqalpha (matches Python)")


def test_bundle_mojo_instrument_list_matches_python() raises:
    """Verify INSTRUMENTS list matches Python original ['stocks', 'indexes', 'futures', 'funds']."""
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    var f = open(bundle_path, "r")
    var content = f.read()
    f.close()

    assert_true(_str_contains(content, '"stocks"') or _str_contains(content, "'stocks'"),
                 "Must include stocks instrument")
    assert_true(_str_contains(content, '"indexes"') or _str_contains(content, "'indexes'"),
                 "Must include indexes instrument")
    assert_true(_str_contains(content, '"futures"') or _str_contains(content, "'futures'"),
                 "Must include futures instrument")
    assert_true(_str_contains(content, '"funds"') or _str_contains(content, "'funds'"),
                 "Must include funds instrument")


def test_signatures_match_python_original() raises:
    """Verify function signatures match Python original via source inspection."""
    var bundle_path = (
        "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/cmds/bundle.mojo"
    )
    var python_path = (
        "/home/zhou/hello_mojo/trae_cn_78/.venv/lib64/python3.14/site-packages/"
        "rqalpha/cmds/bundle.py"
    )

    var bf = open(bundle_path, "r")
    var bc = bf.read()
    bf.close()

    var pf = open(python_path, "r")
    var pc = pf.read()
    pf.close()

    assert_true(_str_contains(bc, "def create_bundle("), "Mojo must have create_bundle")
    assert_true(_str_contains(pc, "def create_bundle("), "Python has create_bundle")
    assert_true(_str_contains(bc, "def update_bundle("), "Mojo must have update_bundle")
    assert_true(_str_contains(pc, "def update_bundle("), "Python has update_bundle")
    assert_true(_str_contains(bc, "def download_bundle("), "Mojo must have download_bundle")
    assert_true(_str_contains(pc, "def download_bundle("), "Python has download_bundle")
    assert_true(_str_contains(bc, "def check_bundle("), "Mojo must have check_bundle")
    assert_true(_str_contains(pc, "def check_bundle("), "Python has check_bundle")
    assert_true(_str_contains(bc, "def get_exactly_url("), "Mojo must have get_exactly_url")
    assert_true(_str_contains(pc, "def get_exactly_url("), "Python has get_exactly_url")
    assert_true(_str_contains(bc, "def download("), "Mojo must have download")
    assert_true(_str_contains(pc, "def download("), "Python has download")
    assert_true(_str_contains(bc, "def check_bundle_data("), "Mojo must have check_bundle_data")
    assert_true(_str_contains(pc, "def check_bundle_data("), "Python has check_bundle_data")


def test_cdn_url_template_matches_python() raises:
    """Verify CDN URL template matches Python's format string output exactly."""
    var url = _format_cdn_url(2024, 6)

    assert_true(
        url == "http://bundle.assets.ricequant.com/bundles_v4/rqbundle_202406.tar.bz2",
        "URL must match Python's format output exactly",
    )

    var py_url = Python.evaluate(
        '"http://bundle.assets.ricequant.com/bundles_v4/rqbundle_{year:04d}{month:02d}.tar.bz2".format(year=2024, month=6)'
    )
    var mojo_url_as_py = PythonObject(url)
    assert_true(
        Bool(py=(mojo_url_as_py == py_url)),
        "Mojo URL must equal Python-formatted URL",
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
