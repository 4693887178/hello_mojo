# test_L00_11_core_init.py
# 对应模块: rqalpha.core
# Mojo对应: rqmojo.core
# 层级: L00 - 叶子模块
# 依赖: 无

import sys
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

import unittest


class TestL00CoreInit(unittest.TestCase):
    """L00层 - core模块测试"""

    def test_core_module_import(self):
        """测试core模块可导入"""
        import rqalpha.core
        self.assertIsNotNone(rqalpha.core)

    def test_core_source_file_not_empty(self):
        """测试源文件不为空（至少有版权声明）"""
        import rqalpha.core
        source_file = rqalpha.core.__file__
        with open(source_file, 'r') as f:
            content = f.read()
        self.assertGreater(len(content), 0)
        self.assertIn('版权所有', content)


if __name__ == '__main__':
    unittest.main()
