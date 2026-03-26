"""
Test for rqalpha/utils/translations/zh_Hans_CN/LC_MESSAGES/__init__.py
Group 02 - File 9
Tests for LC_MESSAGES module
"""


def test_lc_messages_module_imports():
    """Test that LC_MESSAGES module can be imported"""
    from rqalpha.utils.translations.zh_Hans_CN import LC_MESSAGES
    assert LC_MESSAGES is not None


def test_lc_messages_module_path():
    """Test LC_MESSAGES module path"""
    from rqalpha.utils.translations.zh_Hans_CN.LC_MESSAGES import __file__ as lc_file
    assert lc_file.endswith('__init__.py')


if __name__ == "__main__":
    test_lc_messages_module_imports()
    test_lc_messages_module_path()
    print("All utils/translations/zh_Hans_CN/LC_MESSAGES/__init__.py tests passed!")
