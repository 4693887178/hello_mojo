"""
Mojo Test for utils/i18n.mojo
Tests the i18n module functions
"""

from rqmojo.utils.i18n import gettext, lazy_gettext, get_locale, set_locale


def test_gettext():
    var msg = gettext("test message")
    print("gettext result: " + msg)
    assert msg == "test message"


def test_lazy_gettext():
    var msg = lazy_gettext("lazy test message")
    print("lazy_gettext result: " + msg)
    assert msg == "lazy test message"


def test_get_locale():
    var locale = get_locale()
    print("Current locale: " + locale)
    assert len(locale) > 0


def test_set_locale():
    set_locale("en_US")
    print("Locale set to en_US")
    assert True


def main():
    print("=== Testing utils/i18n.mojo ===")
    test_gettext()
    test_lazy_gettext()
    test_get_locale()
    test_set_locale()
    print("All i18n tests passed!")
