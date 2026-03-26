# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/i18n.py
Tests for internationalization functions
"""

import pytest


class TestLocalization:
    """Tests for Localization class"""

    def test_localization_class_exists(self):
        """Test that Localization class exists"""
        from rqalpha.utils.i18n import Localization
        assert Localization is not None

    def test_localization_get_sys_lc(self):
        """Test that get_sys_lc method exists"""
        from rqalpha.utils.i18n import Localization
        assert hasattr(Localization, 'get_sys_lc')

    def test_localization_get_trans(self):
        """Test that get_trans method exists"""
        from rqalpha.utils.i18n import Localization
        assert hasattr(Localization, 'get_trans')


class TestGettext:
    """Tests for gettext function"""

    def test_gettext_function_exists(self):
        """Test that gettext function exists"""
        from rqalpha.utils.i18n import gettext
        assert callable(gettext)

    def test_gettext_returns_string(self):
        """Test that gettext returns a string"""
        from rqalpha.utils.i18n import gettext
        result = gettext("test message")
        assert isinstance(result, str)

    def test_gettext_passthrough(self):
        """Test that gettext passes through unknown messages"""
        from rqalpha.utils.i18n import gettext
        result = gettext("unknown message xyz")
        assert result == "unknown message xyz"


class TestSetLocale:
    """Tests for set_locale function"""

    def test_set_locale_function_exists(self):
        """Test that set_locale function exists"""
        from rqalpha.utils.i18n import set_locale
        assert callable(set_locale)


class TestLazyGettext:
    """Tests for lazy_gettext function"""

    def test_lazy_gettext_function_exists(self):
        """Test that lazy_gettext function exists"""
        from rqalpha.utils.i18n import lazy_gettext
        assert callable(lazy_gettext)

    def test_lazy_gettext_returns_message(self):
        """Test that lazy_gettext returns the original message"""
        from rqalpha.utils.i18n import lazy_gettext
        result = lazy_gettext("test message")
        assert result == "test message"
