"""
Test for rqalpha/utils/translations/__init__.py
Group 02 - File 7
Tests for translations module
"""


def test_translations_module_imports():
    """Test that translations module can be imported"""
    from rqalpha.utils import translations
    assert translations is not None


def test_translations_module_path():
    """Test translations module path"""
    from rqalpha.utils.translations import __file__ as translations_file
    assert translations_file.endswith('__init__.py')


if __name__ == "__main__":
    test_translations_module_imports()
    test_translations_module_path()
    print("All utils/translations/__init__.py tests passed!")
