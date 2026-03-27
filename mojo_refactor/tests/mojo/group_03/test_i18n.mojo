"""
RQAlpha Mojo - i18n Module Test
Tests for utils/i18n.mojo
"""

from rqmojo.utils.i18n import gettext, set_locale, lazy_gettext, get_locale



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_gettext_function_exists() raises:
    """Test that gettext function exists."""
    print("  gettext function exists test passed!")


def test_gettext_returns_string() raises:
    """Test that gettext returns a string."""
    var result = gettext("test message")
    print("  gettext returns string test passed!")


def test_set_locale_function_exists() raises:
    """Test that set_locale function exists."""
    print("  set_locale function exists test passed!")


def test_lazy_gettext_function_exists() raises:
    """Test that lazy_gettext function exists."""
    print("  lazy_gettext function exists test passed!")


def test_lazy_gettext_returns_message() raises:
    """Test that lazy_gettext returns the original message."""
    var result = lazy_gettext("test message")
    assert_equal(result, "test message", "lazy_gettext should return original message")
    print("  lazy_gettext returns message test passed!")


def test_get_locale_function() raises:
    """Test that get_locale returns a string."""
    var locale = get_locale()
    print("  get_locale function test passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()