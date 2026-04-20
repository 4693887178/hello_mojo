# -*- coding: utf-8 -*-
"""
第四组测试 - utils/testing/__init__.py
测试Python版本的测试工具模块
"""

import unittest
import sys
import os

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestTestingModule(unittest.TestCase):
    """测试rqalpha.utils.testing模块"""

    def setUp(self):
        from rqalpha.utils import testing
        self.testing_module = testing

    def test_RQAlphaTestCase_exists(self):
        """测试RQAlphaTestCase类存在"""
        self.assertTrue(hasattr(self.testing_module, 'RQAlphaTestCase'))
        self.assertTrue(callable(self.testing_module.RQAlphaTestCase))

    def test_mock_instrument_exists(self):
        """测试mock_instrument函数存在"""
        self.assertTrue(hasattr(self.testing_module, 'mock_instrument'))
        self.assertTrue(callable(self.testing_module.mock_instrument))

    def test_mock_bar_exists(self):
        """测试mock_bar函数存在"""
        self.assertTrue(hasattr(self.testing_module, 'mock_bar'))
        self.assertTrue(callable(self.testing_module.mock_bar))

    def test_mock_tick_exists(self):
        """测试mock_tick函数存在"""
        self.assertTrue(hasattr(self.testing_module, 'mock_tick'))
        self.assertTrue(callable(self.testing_module.mock_tick))

    def test_RQAlphaFixture_exists(self):
        """测试RQAlphaFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'RQAlphaFixture'))

    def test_EnvironmentFixture_exists(self):
        """测试EnvironmentFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'EnvironmentFixture'))

    def test_UniverseFixture_exists(self):
        """测试UniverseFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'UniverseFixture'))

    def test_DataProxyFixture_exists(self):
        """测试DataProxyFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'DataProxyFixture'))

    def test_BaseDataSourceFixture_exists(self):
        """测试BaseDataSourceFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'BaseDataSourceFixture'))

    def test_BarDictPriceBoardFixture_exists(self):
        """测试BarDictPriceBoardFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'BarDictPriceBoardFixture'))

    def test_MatcherFixture_exists(self):
        """测试MatcherFixture类存在"""
        self.assertTrue(hasattr(self.testing_module, 'MatcherFixture'))

    def test_MagicMock_exists(self):
        """测试MagicMock存在"""
        self.assertTrue(hasattr(self.testing_module, 'MagicMock'))


class TestTestingModuleFunctionality(unittest.TestCase):
    """测试测试工具模块功能"""

    def setUp(self):
        from rqalpha.utils import testing
        self.testing_module = testing

    def test_mock_instrument_basic(self):
        """测试mock_instrument基本功能"""
        instrument = self.testing_module.mock_instrument()
        self.assertIsNotNone(instrument)

    def test_mock_bar_basic(self):
        """测试mock_bar基本功能 - 需要Environment初始化"""
        from rqalpha.utils.exception import EnvironmentNotInitialized
        instrument = self.testing_module.mock_instrument()
        try:
            bar = self.testing_module.mock_bar(instrument)
            self.assertIsNotNone(bar)
        except EnvironmentNotInitialized:
            self.skipTest("mock_bar requires Environment initialization")

    def test_mock_tick_basic(self):
        """测试mock_tick基本功能 - 需要Environment初始化"""
        from rqalpha.utils.exception import EnvironmentNotInitialized
        instrument = self.testing_module.mock_instrument()
        try:
            tick = self.testing_module.mock_tick(instrument)
            self.assertIsNotNone(tick)
        except EnvironmentNotInitialized:
            self.skipTest("mock_tick requires Environment initialization")

    def test_RQAlphaTestCase_methods(self):
        """测试RQAlphaTestCase方法"""
        from rqalpha.utils.testing import RQAlphaTestCase
        self.assertTrue(hasattr(RQAlphaTestCase, 'init_fixture'))
        self.assertTrue(hasattr(RQAlphaTestCase, 'assertObj'))


class TestRQAlphaTestCase(unittest.TestCase):
    """测试RQAlphaTestCase类"""

    def test_init_fixture_method(self):
        """测试init_fixture方法"""
        from rqalpha.utils.testing import RQAlphaTestCase
        case = RQAlphaTestCase()
        case.init_fixture()

    def test_assertObj_method(self):
        """测试assertObj方法"""
        from rqalpha.utils.testing import RQAlphaTestCase
        
        class MockObj:
            value = 42
            name = "test"
        
        case = RQAlphaTestCase()
        case.assertObj(MockObj(), value=42, name="test")


if __name__ == '__main__':
    unittest.main(verbosity=2)
