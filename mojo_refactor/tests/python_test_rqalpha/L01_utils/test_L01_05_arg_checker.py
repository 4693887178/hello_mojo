# test_L01_05_arg_checker.py
# Module: rqalpha.utils.arg_checker
# Level: L01 - Utils module
# Dependencies: exception, i18n

import pytest


class TestArgumentCheckerBase:
    """Test ArgumentCheckerBase class"""
    
    def test_argument_checker_base_exists(self):
        """Test ArgumentCheckerBase exists"""
        from rqalpha.utils.arg_checker import ArgumentCheckerBase
        assert ArgumentCheckerBase is not None
    
    def test_argument_checker_base_init(self):
        """Test ArgumentCheckerBase initialization"""
        from rqalpha.utils.arg_checker import ArgumentCheckerBase
        checker = ArgumentCheckerBase("test_arg")
        assert checker.arg_name == "test_arg"


class TestArgumentChecker:
    """Test ArgumentChecker class"""
    
    def test_argument_checker_exists(self):
        """Test ArgumentChecker exists"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        assert ArgumentChecker is not None
    
    def test_argument_checker_init(self):
        """Test ArgumentChecker initialization"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        assert checker.arg_name == "test_arg"
    
    def test_is_instance_of(self):
        """Test is_instance_of rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_instance_of((int, float))
        assert len(checker._rules) == 1
    
    def test_is_number(self):
        """Test is_number rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_number()
        assert len(checker._rules) == 1
    
    def test_is_in(self):
        """Test is_in rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_in([1, 2, 3])
        assert len(checker._rules) == 1
    
    def test_is_greater_or_equal_than(self):
        """Test is_greater_or_equal_than rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_greater_or_equal_than(0)
        assert len(checker._rules) == 1
    
    def test_is_greater_than(self):
        """Test is_greater_than rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_greater_than(0)
        assert len(checker._rules) == 1
    
    def test_is_less_or_equal_than(self):
        """Test is_less_or_equal_than rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_less_or_equal_than(100)
        assert len(checker._rules) == 1
    
    def test_is_less_than(self):
        """Test is_less_than rule"""
        from rqalpha.utils.arg_checker import ArgumentChecker
        checker = ArgumentChecker("test_arg", False)
        checker.is_less_than(100)
        assert len(checker._rules) == 1


class TestArgumentConverter:
    """Test ArgumentConverter class"""
    
    def test_argument_converter_exists(self):
        """Test ArgumentConverter exists"""
        from rqalpha.utils.arg_checker import ArgumentConverter
        assert ArgumentConverter is not None
    
    def test_argument_converter_init(self):
        """Test ArgumentConverter initialization"""
        from rqalpha.utils.arg_checker import ArgumentConverter
        converter = ArgumentConverter("test_arg")
        assert converter.arg_name == "test_arg"


class TestHelperFunctions:
    """Test helper functions"""
    
    def test_verify_that(self):
        """Test verify_that function"""
        from rqalpha.utils.arg_checker import verify_that
        checker = verify_that("test_arg")
        assert checker.arg_name == "test_arg"
    
    def test_assure_that(self):
        """Test assure_that function"""
        from rqalpha.utils.arg_checker import assure_that
        converter = assure_that("test_arg")
        assert converter.arg_name == "test_arg"


class TestApplyRules:
    """Test apply_rules decorator"""
    
    def test_apply_rules_exists(self):
        """Test apply_rules exists"""
        from rqalpha.utils.arg_checker import apply_rules
        assert callable(apply_rules)
    
    def test_apply_rules_decorator(self):
        """Test apply_rules as decorator"""
        from rqalpha.utils.arg_checker import apply_rules, verify_that
        
        @apply_rules(verify_that("x").is_instance_of(int))
        def test_func(x):
            return x * 2
        
        result = test_func(5)
        assert result == 10
