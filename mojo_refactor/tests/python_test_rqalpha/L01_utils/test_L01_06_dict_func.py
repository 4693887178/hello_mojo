# test_L01_06_dict_func.py
# 对应模块: rqalpha.utils.dict_func
# Mojo对应: rqmojo.utils.dict_func
# 层级: L01 - Utils模块
# 依赖: 无

import sys
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

import unittest
from rqalpha.utils.dict_func import deep_update


class TestL01DictFunc(unittest.TestCase):
    """L01层 - dict_func模块测试"""

    def test_module_import(self):
        """测试模块可导入"""
        self.assertIsNotNone(deep_update)

    def test_deep_update_simple(self):
        """测试简单的字典更新"""
        from_dict = {'a': 1, 'b': 2}
        to_dict = {'c': 3}
        deep_update(from_dict, to_dict)
        self.assertEqual(to_dict['a'], 1)
        self.assertEqual(to_dict['b'], 2)
        self.assertEqual(to_dict['c'], 3)

    def test_deep_update_nested(self):
        """测试嵌套字典更新"""
        from_dict = {'nested': {'a': 1, 'b': 2}}
        to_dict = {'nested': {'c': 3}}
        deep_update(from_dict, to_dict)
        self.assertEqual(to_dict['nested']['c'], 3)
        self.assertEqual(to_dict['nested']['a'], 1)
        self.assertEqual(to_dict['nested']['b'], 2)

    def test_deep_update_overwrite(self):
        """测试覆盖已有值"""
        from_dict = {'a': 100}
        to_dict = {'a': 50}
        deep_update(from_dict, to_dict)
        self.assertEqual(to_dict['a'], 100)

    def test_deep_update_new_keys(self):
        """测试添加新键"""
        from_dict = {'x': 1}
        to_dict = {}
        deep_update(from_dict, to_dict)
        self.assertEqual(to_dict['x'], 1)

    def test_deep_update_empty_from(self):
        """测试空源字典"""
        from_dict = {}
        to_dict = {'a': 1}
        original = to_dict.copy()
        deep_update(from_dict, to_dict)
        self.assertEqual(to_dict, original)


if __name__ == '__main__':
    unittest.main()
