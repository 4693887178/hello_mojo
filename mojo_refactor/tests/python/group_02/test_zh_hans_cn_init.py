"""
Test for rqalpha/utils/translations/zh_Hans_CN/__init__.py
Group 02 - File 8
Tests for Chinese simplified translation module
"""


def test_zh_hans_cn_module_imports():
    """Test that zh_Hans_CN module can be imported"""
    from rqalpha.utils.translations import zh_Hans_CN
    assert zh_Hans_CN is not None


def test_zh_hans_cn_module_path():
    """Test zh_Hans_CN module path"""
    from rqalpha.utils.translations.zh_Hans_CN import __file__ as zh_file
    assert zh_file.endswith('__init__.py')


if __name__ == "__main__":
    test_zh_hans_cn_module_imports()
    test_zh_hans_cn_module_path()
    print("All utils/translations/zh_Hans_CN/__init__.py tests passed!")
