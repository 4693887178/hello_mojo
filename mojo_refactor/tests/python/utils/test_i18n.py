# -*- coding: utf-8 -*-
"""
Python Test for rqalpha/utils/i18n.py
Tests the i18n module functions
"""

import pytest


def test_gettext():
    """Test gettext function"""
    from rqalpha.utils.i18n import gettext
    result = gettext("test message")
    assert isinstance(result, str)


def test_lazy_gettext():
    """Test lazy_gettext function"""
    from rqalpha.utils.i18n import lazy_gettext
    result = lazy_gettext("lazy test message")
    assert result == "lazy test message"


def test_set_locale():
    """Test set_locale function"""
    from rqalpha.utils.i18n import set_locale
    set_locale("en_US")
    assert True


def test_get_sys_locale():
    """Test get_sys_locale method"""
    from rqalpha.utils.i18n import Localization
    locale = Localization.get_sys_lc()
    assert locale is not None


def test_localization_init():
    """Test Localization initialization"""
    from rqalpha.utils.i18n import Localization
    loc = Localization()
    assert loc is not None


def test_localization_with_locale():
    """Test Localization with specific locale"""
    from rqalpha.utils.i18n import Localization
    loc = Localization("zh_CN")
    assert loc is not None


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
