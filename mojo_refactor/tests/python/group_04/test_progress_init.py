# -*- coding: utf-8 -*-
"""
第四组测试 - mod/rqalpha_mod_sys_progress/__init__.py
测试Python版本的进度模块初始化
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestProgressModInit(unittest.TestCase):
    """测试rqalpha.mod.rqalpha_mod_sys_progress模块"""

    def setUp(self):
        from rqalpha.mod import rqalpha_mod_sys_progress
        self.module = rqalpha_mod_sys_progress

    def test_load_mod_exists(self):
        """测试load_mod函数存在"""
        self.assertTrue(hasattr(self.module, 'load_mod'))
        self.assertTrue(callable(self.module.load_mod))

    def test_config_exists(self):
        """测试__config__存在"""
        self.assertTrue(hasattr(self.module, '__config__'))

    def test_config_show_default(self):
        """测试__config__默认值"""
        config = self.module.__config__
        self.assertIn('show', config)
        self.assertEqual(config['show'], False)


class TestLoadMod(unittest.TestCase):
    """测试load_mod函数"""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress import load_mod
        self.load_mod = load_mod

    def test_load_mod_returns_mod(self):
        """测试load_mod返回ProgressMod"""
        mod = self.load_mod()
        self.assertIsNotNone(mod)

    def test_load_mod_returns_correct_type(self):
        """测试load_mod返回正确类型"""
        from rqalpha.mod.rqalpha_mod_sys_progress.mod import ProgressMod
        mod = self.load_mod()
        self.assertIsInstance(mod, ProgressMod)


if __name__ == '__main__':
    unittest.main(verbosity=2)
