# test_L00_13_translations.py
# 对应模块: rqalpha.utils.translations
# Mojo对应: rqmojo.utils.translations
# 层级: L00 - 叶子模块
# 依赖: 无

import sys
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

import unittest


class TestL00Translations(unittest.TestCase):
    """L00层 - translations模块测试"""

    def test_module_import(self):
        """测试translations模块可导入"""
        from rqalpha.utils import translations
        self.assertIsNotNone(translations)

    def test_zh_hans_cn_import(self):
        """测试zh_Hans_CN模块可导入"""
        from rqalpha.utils.translations import zh_Hans_CN
        self.assertIsNotNone(zh_Hans_CN)

    def test_lc_messages_import(self):
        """测试LC_MESSAGES模块可导入"""
        from rqalpha.utils.translations.zh_Hans_CN import LC_MESSAGES
        self.assertIsNotNone(LC_MESSAGES)


if __name__ == '__main__':
    unittest.main()
