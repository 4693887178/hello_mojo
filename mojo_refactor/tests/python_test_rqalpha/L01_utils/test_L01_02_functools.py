# test_L01_02_functools.py
# Module: rqalpha.utils.functools
# Level: L01 - Utils module
# Dependencies: const

import pytest


class TestLRUCache:
    """Test lru_cache decorator"""
    
    def test_lru_cache_basic(self):
        """Test basic lru_cache functionality"""
        from rqalpha.utils.functools import lru_cache, cached_functions
        
        call_count = [0]
        
        @lru_cache(maxsize=128)
        def expensive_func(x):
            call_count[0] += 1
            return x * 2
        
        result1 = expensive_func(5)
        result2 = expensive_func(5)
        
        assert result1 == 10
        assert result2 == 10
        assert call_count[0] == 1  # Should only be called once
    
    def test_lru_cache_different_args(self):
        """Test lru_cache with different arguments"""
        from rqalpha.utils.functools import lru_cache
        
        call_count = [0]
        
        @lru_cache(maxsize=128)
        def func(x):
            call_count[0] += 1
            return x
        
        func(1)
        func(2)
        func(1)
        
        assert call_count[0] == 2
    
    def test_lru_cache_registered(self):
        """Test that cached functions are registered"""
        from rqalpha.utils.functools import lru_cache, cached_functions
        
        initial_count = len(cached_functions)
        
        @lru_cache(maxsize=128)
        def test_func():
            return "test"
        
        assert len(cached_functions) == initial_count + 1


class TestClearCachedFunctions:
    """Test clear_all_cached_functions"""
    
    def test_clear_all_cached_functions(self):
        """Test clearing all cached functions"""
        from rqalpha.utils.functools import lru_cache, clear_all_cached_functions, cached_functions
        
        @lru_cache(maxsize=128)
        def func(x):
            return x
        
        func(1)
        func(2)
        
        clear_all_cached_functions()


class TestSingleDispatchProtocol:
    """Test SingleDispatchProtocol"""
    
    def test_singledispatch_protocol_exists(self):
        """Test SingleDispatchProtocol exists"""
        from rqalpha.utils.functools import SingleDispatchProtocol
        assert SingleDispatchProtocol is not None
    
    def test_cast_singledispatch(self):
        """Test cast_singledispatch function"""
        from rqalpha.utils.functools import cast_singledispatch
        
        def dummy_func(x):
            return x
        
        result = cast_singledispatch(dummy_func)
        assert result is not None


class TestInstypeSingledispatch:
    """Test instype_singledispatch"""
    
    def test_instype_singledispatch_basic(self):
        """Test basic instype_singledispatch"""
        from rqalpha.utils.functools import instype_singledispatch
        from rqalpha.const import INSTRUMENT_TYPE
        
        @instype_singledispatch
        def get_name(id_or_ins):
            return "default"
        
        @get_name.register(INSTRUMENT_TYPE.CS)
        def _(id_or_ins):
            return "stock"
        
        assert hasattr(get_name, 'register')
    
    def test_instype_singledispatch_register(self):
        """Test instype_singledispatch register method"""
        from rqalpha.utils.functools import instype_singledispatch
        from rqalpha.const import INSTRUMENT_TYPE
        
        @instype_singledispatch
        def process(id_or_ins):
            return "default"
        
        @process.register([INSTRUMENT_TYPE.CS, INSTRUMENT_TYPE.ETF])
        def _(id_or_ins):
            return "equity"
        
        assert hasattr(process, 'register')
