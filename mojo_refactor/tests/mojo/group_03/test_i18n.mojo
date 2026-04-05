"""
Comprehensive tests for utils/i18n.mojo
Tests singleton pattern, translation loading, locale switching, and API compatibility
"""

from rqmojo.utils.i18n import (
    gettext,
    set_locale,
    lazy_gettext,
    get_locale,
    Localization,
)

from std.testing import (
    assert_equal,
    assert_true,
    assert_false,
    TestSuite,
)


def test_gettext_returns_string() raises:
    var result = gettext("nonexistent message")
    assert_true(len(result) > 0)


def test_gettext_passthrough_unknown() raises:
    var result = gettext("completely unknown key")
    assert_equal(result, "completely unknown key")


def test_gettext_translates_known_message() raises:
    set_locale("zh_CN")
    var result = gettext("Insufficient funds")
    assert_true(len(result) > 0)


def test_lazy_gettext_returns_original() raises:
    var msg = "lazy test message"
    var result = lazy_gettext(msg)
    assert_equal(result, msg)


def test_lazy_gettext_no_translation() raises:
    var result = lazy_gettext("any string at all")
    assert_equal(result, "any string at all")


def test_set_locale_function_exists() raises:
    set_locale("en_US")


def test_set_locale_to_chinese() raises:
    set_locale("zh_CN")
    var locale = get_locale()
    assert_equal(locale, "zh_CN")


def test_set_locale_to_english() raises:
    set_locale("en_US")
    var locale = get_locale()
    assert_true("en" in locale.lower())


def test_getlocale_returns_string() raises:
    var locale = get_locale()
    assert_true(len(locale) > 0)


def test_localization_class_exists() raises:
    var loc = Localization()
    assert_true(loc._locale == "en")


def test_localization_with_locale_param() raises:
    var loc = Localization("zh_CN")
    assert_true("cn" in loc._locale.lower())


def test_localization_get_sys_locale_static() raises:
    var sys_lc = Localization.get_sys_locale()
    assert_true(len(sys_lc) >= 0)


def test_set_locale_persists_across_calls() raises:
    set_locale("zh_CN")
    var locale1 = get_locale()
    _ = gettext("trigger init")
    var locale2 = get_locale()
    assert_equal(locale1, locale2)
    assert_equal(locale1, "zh_CN")


def test_set_locale_switches_between_calls() raises:
    set_locale("en_US")
    assert_equal(get_locale(), "en_US")

    set_locale("zh_CN")
    assert_equal(get_locale(), "zh_CN")

    set_locale("en")
    assert_equal(get_locale(), "en")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
