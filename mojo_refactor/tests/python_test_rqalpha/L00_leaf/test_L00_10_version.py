# test_L00_10_version.py
# 对应模块: rqalpha._version
# Mojo对应: rqmojo._version
# 层级: L00 - 叶子模块
# 依赖: 无

import sys
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

import unittest
from rqalpha import _version


class TestL00Version(unittest.TestCase):
    """L00层 - _version模块测试"""

    def test_module_import(self):
        """测试模块可导入"""
        self.assertIsNotNone(_version)

    def test_version_variable(self):
        """测试version变量存在"""
        self.assertTrue(hasattr(_version, 'version'))
        self.assertIsInstance(_version.version, str)

    def test_dunder_version(self):
        """测试__version__变量"""
        self.assertTrue(hasattr(_version, '__version__'))
        self.assertIsInstance(_version.__version__, str)

    def test_version_equals_dunder_version(self):
        """测试version和__version__相等"""
        self.assertEqual(_version.version, _version.__version__)

    def test_version_tuple(self):
        """测试version_tuple存在"""
        self.assertTrue(hasattr(_version, 'version_tuple'))
        self.assertTrue(hasattr(_version, '__version_tuple__'))

    def test_version_format(self):
        """测试版本号格式为X.Y.Z"""
        parts = _version.version.split('.')
        self.assertEqual(len(parts), 3)
        for part in parts:
            self.assertTrue(part.isdigit())

    def test_commit_id(self):
        """测试commit_id变量"""
        self.assertTrue(hasattr(_version, 'commit_id'))
        self.assertTrue(hasattr(_version, '__commit_id__'))

    def test_all_exports(self):
        """测试__all__导出"""
        self.assertTrue(hasattr(_version, '__all__'))
        expected = ["__version__", "__version_tuple__", "version", "version_tuple", "__commit_id__", "commit_id"]
        self.assertEqual(set(_version.__all__), set(expected))


if __name__ == '__main__':
    unittest.main()
