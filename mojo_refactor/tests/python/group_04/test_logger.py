# -*- coding: utf-8 -*-
"""
第四组测试 - utils/logger.py
测试Python版本的logger模块
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestLogger(unittest.TestCase):
    """测试rqalpha.utils.logger模块"""

    def setUp(self):
        from rqalpha.utils import logger
        self.logger_module = logger

    def test_user_log_exists(self):
        """测试user_log存在"""
        self.assertTrue(hasattr(self.logger_module, 'user_log'))
        user_log = self.logger_module.user_log
        self.assertIsNotNone(user_log)

    def test_system_log_exists(self):
        """测试system_log存在"""
        self.assertTrue(hasattr(self.logger_module, 'system_log'))
        system_log = self.logger_module.system_log
        self.assertIsNotNone(system_log)

    def test_user_system_log_exists(self):
        """测试user_system_log存在"""
        self.assertTrue(hasattr(self.logger_module, 'user_system_log'))
        user_system_log = self.logger_module.user_system_log
        self.assertIsNotNone(user_system_log)

    def test_datetime_format(self):
        """测试日期时间格式"""
        self.assertTrue(hasattr(self.logger_module, 'DATETIME_FORMAT'))
        expected_format = "%Y-%m-%d %H:%M:%S.%f"
        self.assertEqual(self.logger_module.DATETIME_FORMAT, expected_format)

    def test_init_logger_function(self):
        """测试init_logger函数存在"""
        self.assertTrue(hasattr(self.logger_module, 'init_logger'))
        self.assertTrue(callable(self.logger_module.init_logger))

    def test_user_print_function(self):
        """测试user_print函数存在"""
        self.assertTrue(hasattr(self.logger_module, 'user_print'))
        self.assertTrue(callable(self.logger_module.user_print))

    def test_release_print_function(self):
        """测试release_print函数存在"""
        self.assertTrue(hasattr(self.logger_module, 'release_print'))
        self.assertTrue(callable(self.logger_module.release_print))

    def test_user_log_name(self):
        """测试user_log名称"""
        user_log = self.logger_module.user_log
        self.assertEqual(user_log.name, 'user_log')

    def test_system_log_name(self):
        """测试system_log名称"""
        system_log = self.logger_module.system_log
        self.assertEqual(system_log.name, 'system_log')

    def test_user_system_log_name(self):
        """测试user_system_log名称"""
        user_system_log = self.logger_module.user_system_log
        self.assertEqual(user_system_log.name, 'user_system_log')

    def test_all_exports(self):
        """测试__all__导出"""
        expected_exports = ['user_log', 'system_log', 'user_system_log', 'release_print']
        for export in expected_exports:
            self.assertTrue(hasattr(self.logger_module, export), f"Missing export: {export}")


class TestLoggerFunctionality(unittest.TestCase):
    """测试logger功能"""

    def setUp(self):
        from rqalpha.utils import logger
        self.logger_module = logger

    def test_user_print_basic(self):
        """测试user_print基本功能"""
        try:
            self.logger_module.user_print("Test message")
        except Exception as e:
            self.fail(f"user_print raised exception: {e}")

    def test_init_logger_basic(self):
        """测试init_logger基本功能"""
        try:
            self.logger_module.init_logger()
        except Exception as e:
            self.fail(f"init_logger raised exception: {e}")


if __name__ == '__main__':
    unittest.main(verbosity=2)
