"""
Test for rqalpha/mod/rqalpha_mod_sys_accounts/api/__init__.py
Note: This file only contains copyright notice, no actual code
"""


def test_api_module_imports():
    """Test that api module can be imported"""
    from rqalpha.mod.rqalpha_mod_sys_accounts import api
    assert api is not None


def test_api_module_path():
    """Test api module path"""
    from rqalpha.mod.rqalpha_mod_sys_accounts.api import __file__ as api_file
    assert api_file.endswith('__init__.py')


if __name__ == "__main__":
    test_api_module_imports()
    test_api_module_path()
    print("All mod/rqalpha_mod_sys_accounts/api/__init__.py tests passed!")
