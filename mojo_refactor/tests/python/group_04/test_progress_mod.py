# -*- coding: utf-8 -*-
"""
Test suite for rqalpha/mod/rqalpha_mod_sys_progress/mod.py
Tests ProgressMod class, its lifecycle methods, and interface compliance.
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestProgressModModule(unittest.TestCase):
    """Test rqalpha.mod.rqalpha_mod_sys_progress.mod module."""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress import mod
        self.module = mod

    def test_ProgressMod_exists(self):
        """ProgressMod class exists."""
        self.assertTrue(hasattr(self.module, 'ProgressMod'))


class TestProgressModInit(unittest.TestCase):
    """Test ProgressMod initialization."""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress.mod import ProgressMod
        self.ProgressMod = ProgressMod

    def test_init(self):
        """Default initialization values."""
        mod = self.ProgressMod()
        self.assertIsNotNone(mod)
        self.assertEqual(mod._show, False)
        self.assertIsNone(mod._progress_bar)
        self.assertEqual(mod._trading_length, 0)

    def test_init_has_env(self):
        """_env is None after init."""
        mod = self.ProgressMod()
        self.assertIsNone(mod._env)


class TestProgressModMethods(unittest.TestCase):
    """Test ProgressMod method existence."""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress.mod import ProgressMod
        self.ProgressMod = ProgressMod

    def test_start_up_exists(self):
        """start_up method exists."""
        mod = self.ProgressMod()
        self.assertTrue(hasattr(mod, 'start_up'))
        self.assertTrue(callable(mod.start_up))

    def test_tear_down_exists(self):
        """tear_down method exists."""
        mod = self.ProgressMod()
        self.assertTrue(hasattr(mod, 'tear_down'))
        self.assertTrue(callable(mod.tear_down))

    def test_init_method_exists(self):
        """_init method exists."""
        mod = self.ProgressMod()
        self.assertTrue(hasattr(mod, '_init'))
        self.assertTrue(callable(mod._init))

    def test_tick_method_exists(self):
        """_tick method exists."""
        mod = self.ProgressMod()
        self.assertTrue(hasattr(mod, '_tick'))
        self.assertTrue(callable(mod._tick))


class TestProgressModMethodsBehavior(unittest.TestCase):
    """Test ProgressMod method behavior."""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress.mod import ProgressMod
        self.ProgressMod = ProgressMod

    def test_tear_down_without_show(self):
        """tear_down with show=False does nothing."""
        mod = self.ProgressMod()
        mod._show = False
        mod.tear_down(True)

    def test_tear_down_with_show_no_bar(self):
        """tear_down with show=True but no bar does not crash."""
        mod = self.ProgressMod()
        mod._show = True
        mod._progress_bar = None
        mod.tear_down(True)

    def test_start_up_sets_show_from_config(self):
        """start_up reads show from config."""
        mod = self.ProgressMod()
        from types import SimpleNamespace
        config = SimpleNamespace(show=True)
        env = SimpleNamespace(config=SimpleNamespace(base=SimpleNamespace(
            trading_calendar=list(range(252))
        )), event_bus=SimpleNamespace(
            add_listener=lambda *a, **kw: None
        ))
        mod.start_up(env, config)
        self.assertEqual(mod._show, True)


class TestProgressModInterface(unittest.TestCase):
    """Test ProgressMod interface compliance."""

    def setUp(self):
        from rqalpha.mod.rqalpha_mod_sys_progress.mod import ProgressMod
        from rqalpha.interface import AbstractMod
        self.ProgressMod = ProgressMod
        self.AbstractMod = AbstractMod

    def test_implements_abstract_mod(self):
        """ProgressMod implements AbstractMod."""
        mod = self.ProgressMod()
        self.assertIsInstance(mod, self.AbstractMod)

    def test_has_start_up(self):
        """Has start_up method (from AbstractMod)."""
        mod = self.ProgressMod()
        self.assertTrue(hasattr(mod, 'start_up'))

    def test_has_tear_down(self):
        """Has tear_down method (from AbstractMod)."""
        mod = self.ProgressMod()
        self.assertTrue(hasattr(mod, 'tear_down'))


if __name__ == '__main__':
    unittest.main(verbosity=2)
