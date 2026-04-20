# -*- coding: utf-8 -*-
"""
第四组测试 - utils/arg_checker.py
测试Python版本的参数检查模块
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestArgCheckerModule(unittest.TestCase):
    """测试rqalpha.utils.arg_checker模块"""

    def setUp(self):
        from rqalpha.utils import arg_checker
        self.module = arg_checker

    def test_ArgumentCheckerBase_exists(self):
        """测试ArgumentCheckerBase类存在"""
        self.assertTrue(hasattr(self.module, 'ArgumentCheckerBase'))

    def test_ArgumentChecker_exists(self):
        """测试ArgumentChecker类存在"""
        self.assertTrue(hasattr(self.module, 'ArgumentChecker'))

    def test_ArgumentConverter_exists(self):
        """测试ArgumentConverter类存在"""
        self.assertTrue(hasattr(self.module, 'ArgumentConverter'))

    def test_ApiArgumentsChecker_exists(self):
        """测试ApiArgumentsChecker类存在"""
        self.assertTrue(hasattr(self.module, 'ApiArgumentsChecker'))

    def test_assure_active_instrument_exists(self):
        """测试assure_active_instrument函数存在"""
        self.assertTrue(hasattr(self.module, 'assure_active_instrument'))
        self.assertTrue(callable(self.module.assure_active_instrument))

    def test_assure_listed_instrument_exists(self):
        """测试assure_listed_instrument函数存在"""
        self.assertTrue(hasattr(self.module, 'assure_listed_instrument'))
        self.assertTrue(callable(self.module.assure_listed_instrument))

    def test_assure_order_book_id_exists(self):
        """测试assure_order_book_id函数存在"""
        self.assertTrue(hasattr(self.module, 'assure_order_book_id'))
        self.assertTrue(callable(self.module.assure_order_book_id))

    def test_verify_that_exists(self):
        """测试verify_that函数存在"""
        self.assertTrue(hasattr(self.module, 'verify_that'))
        self.assertTrue(callable(self.module.verify_that))

    def test_assure_that_exists(self):
        """测试assure_that函数存在"""
        self.assertTrue(hasattr(self.module, 'assure_that'))
        self.assertTrue(callable(self.module.assure_that))

    def test_get_call_args_exists(self):
        """测试get_call_args函数存在"""
        self.assertTrue(hasattr(self.module, 'get_call_args'))
        self.assertTrue(callable(self.module.get_call_args))

    def test_apply_rules_exists(self):
        """测试apply_rules函数存在"""
        self.assertTrue(hasattr(self.module, 'apply_rules'))
        self.assertTrue(callable(self.module.apply_rules))


class TestArgumentCheckerBase(unittest.TestCase):
    """测试ArgumentCheckerBase类"""

    def setUp(self):
        from rqalpha.utils.arg_checker import ArgumentCheckerBase
        self.CheckerBase = ArgumentCheckerBase

    def test_init(self):
        """测试初始化"""
        checker = self.CheckerBase("test_arg")
        self.assertEqual(checker.arg_name, "test_arg")

    def test_arg_name_property(self):
        """测试arg_name属性"""
        checker = self.CheckerBase("my_argument")
        self.assertEqual(checker.arg_name, "my_argument")


class TestArgumentChecker(unittest.TestCase):
    """测试ArgumentChecker类"""

    def setUp(self):
        from rqalpha.utils.arg_checker import ArgumentChecker
        self.Checker = ArgumentChecker

    def test_init(self):
        """测试初始化"""
        checker = self.Checker("test_arg", pre_check=False)
        self.assertEqual(checker.arg_name, "test_arg")
        self.assertEqual(checker.pre_check, False)

    def test_is_instance_of(self):
        """测试is_instance_of方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_instance_of((int, float))
        self.assertEqual(result, checker)

    def test_is_number(self):
        """测试is_number方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_number()
        self.assertEqual(result, checker)

    def test_is_in(self):
        """测试is_in方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_in([1, 2, 3])
        self.assertEqual(result, checker)

    def test_is_greater_or_equal_than(self):
        """测试is_greater_or_equal_than方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_greater_or_equal_than(0)
        self.assertEqual(result, checker)

    def test_is_greater_than(self):
        """测试is_greater_than方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_greater_than(0)
        self.assertEqual(result, checker)

    def test_is_less_or_equal_than(self):
        """测试is_less_or_equal_than方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_less_or_equal_than(100)
        self.assertEqual(result, checker)

    def test_is_less_than(self):
        """测试is_less_than方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_less_than(100)
        self.assertEqual(result, checker)

    def test_is_valid_interval(self):
        """测试is_valid_interval方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_valid_interval()
        self.assertEqual(result, checker)

    def test_is_valid_frequency(self):
        """测试is_valid_frequency方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_valid_frequency()
        self.assertEqual(result, checker)

    def test_is_valid_date(self):
        """测试is_valid_date方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.is_valid_date()
        self.assertEqual(result, checker)

    def test_deprecated(self):
        """测试deprecated方法"""
        checker = self.Checker("test_arg", pre_check=False)
        result = checker.deprecated("use new_arg instead")
        self.assertEqual(result, checker)


class TestVerifyThat(unittest.TestCase):
    """测试verify_that函数"""

    def test_verify_that_returns_checker(self):
        """测试verify_that返回ArgumentChecker"""
        from rqalpha.utils.arg_checker import verify_that, ArgumentChecker
        result = verify_that("test_arg")
        self.assertIsInstance(result, ArgumentChecker)

    def test_verify_that_pre_check_default(self):
        """测试verify_that默认pre_check为False"""
        from rqalpha.utils.arg_checker import verify_that
        result = verify_that("test_arg")
        self.assertEqual(result.pre_check, False)

    def test_verify_that_pre_check_true(self):
        """测试verify_that设置pre_check为True"""
        from rqalpha.utils.arg_checker import verify_that
        result = verify_that("test_arg", pre_check=True)
        self.assertEqual(result.pre_check, True)


class TestAssureThat(unittest.TestCase):
    """测试assure_that函数"""

    def test_assure_that_returns_converter(self):
        """测试assure_that返回ArgumentConverter"""
        from rqalpha.utils.arg_checker import assure_that, ArgumentConverter
        result = assure_that("test_arg")
        self.assertIsInstance(result, ArgumentConverter)


if __name__ == '__main__':
    unittest.main(verbosity=2)
