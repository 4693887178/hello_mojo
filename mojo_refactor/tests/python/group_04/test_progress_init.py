# -*- coding: utf-8 -*-
"""
Test suite for rqalpha/mod/rqalpha_mod_sys_progress/__init__.py
Tests all exported functions: __config__, load_mod, cli_prefix.
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestProgressModInit(unittest.TestCase):
    """Test rqalpha.mod.rqalpha_mod_sys_progress module."""

    def setUp(self):
        from rqalpha.mod import rqalpha_mod_sys_progress
        self.module = rqalpha_mod_sys_progress

    def test_load_mod_exists(self):
        """load_mod function exists and is callable."""
        self.assertTrue(hasattr(self.module, 'load_mod'))
        self.assertTrue(callable(self.module.load_mod))

    def test_config_exists(self):
        """__config__ exists."""
        self.assertTrue(hasattr(self.module, '__config__'))

    def test_config_show_default(self):
        """__config__ default value: show=False."""
        config = self.module.__config__
        self.assertIn('show', config)
        self.assertEqual(config['show'], False)

    def test_config_is_dict(self):
        """__config__ is a dict."""
        self.assertIsInstance(self.module.__config__, dict)


class TestLoadMod(unittest.TestCase):
    """Test load_mod function."""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress import load_mod
        self.load_mod = load_mod

    def test_load_mod_returns_mod(self):
        """load_mod returns ProgressMod."""
        mod = self.load_mod()
        self.assertIsNotNone(mod)

    def test_load_mod_returns_correct_type(self):
        """load_mod returns correct type (ProgressMod)."""
        from rqalpha.mod.rqalpha_mod_sys_progress.mod import ProgressMod
        mod = self.load_mod()
        self.assertIsInstance(mod, ProgressMod)


class TestCLIPrefix(unittest.TestCase):
    """Test CLI prefix configuration."""

    def setUp(self):
        from rqalpha.mod import rqalpha_mod_sys_progress
        self.module = rqalpha_mod_sys_progress

    def test_cli_prefix_exists(self):
        """cli_prefix attribute exists."""
        self.assertTrue(hasattr(self.module, 'cli_prefix'))

    def test_cli_prefix_value(self):
        """cli_prefix has correct value."""
        self.assertEqual(self.module.cli_prefix, "mod__sys_progress__")

    def test_cli_prefix_is_string(self):
        """cli_prefix is a string."""
        self.assertIsInstance(self.module.cli_prefix, str)


if __name__ == '__main__':
    unittest.main(verbosity=2)
