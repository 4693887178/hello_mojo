# -*- coding: utf-8 -*-
"""
Test for api.py
Group 06 - File 05
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestApiModule:
    """Test api.py"""
    
    def test_module_imports(self):
        """Test that module can be imported"""
        import rqalpha.api
        assert rqalpha.api is not None
    
    def test_decorate_api_exc_exists(self):
        """Test decorate_api_exc function exists"""
        from rqalpha.api import decorate_api_exc
        assert callable(decorate_api_exc)
    
    def test_register_api_exists(self):
        """Test register_api function exists"""
        from rqalpha.api import register_api
        assert callable(register_api)
    
    def test_export_as_api_exists(self):
        """Test export_as_api function exists"""
        from rqalpha.api import export_as_api
        assert callable(export_as_api)
    
    def test_all_exists(self):
        """Test __all__ exists"""
        from rqalpha.api import __all__
        assert isinstance(__all__, list)


class TestApiDecorators:
    """Test API decorator functions"""
    
    def test_decorate_api_exc_with_function(self):
        """Test decorate_api_exc with a function"""
        from rqalpha.api import decorate_api_exc
        
        def test_func(x):
            return x * 2
        
        decorated = decorate_api_exc(test_func)
        assert decorated(5) == 10
    
    def test_export_as_api(self):
        """Test export_as_api function"""
        from rqalpha.api import export_as_api, __all__
        
        def test_api_func():
            return "test"
        
        initial_len = len(__all__)
        export_as_api(test_api_func, "test_api_func")
        assert "test_api_func" in __all__
    
    def test_register_api(self):
        """Test register_api function"""
        from rqalpha.api import register_api
        
        def my_api():
            return "my_api"
        
        register_api("my_custom_api", my_api)
        from rqalpha.api import my_custom_api
        assert my_custom_api() == "my_api"


class TestApiExceptionHandling:
    """Test API exception handling"""
    
    def test_api_exc_patch_on_exception(self):
        """Test that exceptions are properly patched"""
        from rqalpha.api import decorate_api_exc
        from rqalpha.utils.exception import RQInvalidArgument
        
        def raising_func():
            raise RQInvalidArgument("test error")
        
        decorated = decorate_api_exc(raising_func)
        with pytest.raises(RQInvalidArgument):
            decorated()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
