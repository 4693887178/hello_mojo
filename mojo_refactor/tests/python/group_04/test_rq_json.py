# -*- coding: utf-8 -*-
"""
第四组测试 - utils/rq_json.py
测试Python版本的JSON工具模块
"""

import unittest
import sys
import os
import datetime

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestRqJson(unittest.TestCase):
    """测试rqalpha.utils.rq_json模块"""

    def setUp(self):
        from rqalpha.utils import rq_json
        self.rq_json_module = rq_json

    def test_convert_dict_to_json_exists(self):
        """测试convert_dict_to_json函数存在"""
        self.assertTrue(hasattr(self.rq_json_module, 'convert_dict_to_json'))
        self.assertTrue(callable(self.rq_json_module.convert_dict_to_json))

    def test_convert_json_to_dict_exists(self):
        """测试convert_json_to_dict函数存在"""
        self.assertTrue(hasattr(self.rq_json_module, 'convert_json_to_dict'))
        self.assertTrue(callable(self.rq_json_module.convert_json_to_dict))

    def test_custom_encode_exists(self):
        """测试custom_encode函数存在"""
        self.assertTrue(hasattr(self.rq_json_module, 'custom_encode'))
        self.assertTrue(callable(self.rq_json_module.custom_encode))

    def test_custom_decode_exists(self):
        """测试custom_decode函数存在"""
        self.assertTrue(hasattr(self.rq_json_module, 'custom_decode'))
        self.assertTrue(callable(self.rq_json_module.custom_decode))


class TestRqJsonFunctionality(unittest.TestCase):
    """测试JSON工具功能"""

    def setUp(self):
        from rqalpha.utils import rq_json
        self.rq_json_module = rq_json

    def test_convert_simple_dict_to_json(self):
        """测试简单字典转JSON"""
        test_dict = {"key": "value", "number": 123}
        result = self.rq_json_module.convert_dict_to_json(test_dict)
        self.assertIsInstance(result, str)
        self.assertIn("key", result)
        self.assertIn("value", result)

    def test_convert_json_to_simple_dict(self):
        """测试JSON转简单字典"""
        json_str = '{"key": "value", "number": 123}'
        result = self.rq_json_module.convert_json_to_dict(json_str)
        self.assertIsInstance(result, dict)
        self.assertEqual(result["key"], "value")
        self.assertEqual(result["number"], 123)

    def test_encode_datetime(self):
        """测试datetime编码"""
        dt = datetime.datetime(2024, 1, 15, 10, 30, 45, 123456)
        result = self.rq_json_module.custom_encode(dt)
        self.assertIsInstance(result, dict)
        self.assertTrue(result.get("__datetime__", False))
        self.assertIn("as_str", result)

    def test_encode_date(self):
        """测试date编码"""
        d = datetime.date(2024, 1, 15)
        result = self.rq_json_module.custom_encode(d)
        self.assertIsInstance(result, dict)
        self.assertTrue(result.get("__date__", False))
        self.assertIn("as_str", result)

    def test_decode_datetime(self):
        """测试datetime解码"""
        encoded = {"__datetime__": True, "as_str": "20240115T10:30:45.123456"}
        result = self.rq_json_module.custom_decode(encoded)
        self.assertIsInstance(result, datetime.datetime)
        self.assertEqual(result.year, 2024)
        self.assertEqual(result.month, 1)
        self.assertEqual(result.day, 15)

    def test_decode_date(self):
        """测试date解码"""
        encoded = {"__date__": True, "as_str": "20240115"}
        result = self.rq_json_module.custom_decode(encoded)
        self.assertIsInstance(result, datetime.date)
        self.assertEqual(result.year, 2024)
        self.assertEqual(result.month, 1)
        self.assertEqual(result.day, 15)

    def test_roundtrip_dict(self):
        """测试字典往返转换"""
        original = {"name": "test", "value": 42, "nested": {"a": 1, "b": 2}}
        json_str = self.rq_json_module.convert_dict_to_json(original)
        result = self.rq_json_module.convert_json_to_dict(json_str)
        self.assertEqual(result["name"], original["name"])
        self.assertEqual(result["value"], original["value"])


if __name__ == '__main__':
    unittest.main(verbosity=2)
