"""
Test for rqalpha/core/__init__.py
"""

def test_core_init_imports():
    """Test that core module can be imported"""
    from rqalpha import core
    assert core is not None


def test_core_module_path():
    """Test core module path"""
    from rqalpha.core import __file__ as core_file
    assert core_file.endswith('__init__.py')


if __name__ == "__main__":
    test_core_init_imports()
    test_core_module_path()
    print("All core/__init__.py tests passed!")
