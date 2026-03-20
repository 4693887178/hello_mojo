# test_L01_07_risk_free_helper.py
# 对应模块: rqalpha.utils.risk_free_helper
# Mojo对应: rqmojo.utils.risk_free_helper
# 层级: L01 - Utils模块
# 依赖: 无

import sys
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

import unittest
from datetime import date
from rqalpha.utils.risk_free_helper import (
    YIELD_CURVE_TENORS,
    YIELD_CURVE_DURATION,
    get_tenor_for,
    get_tenors_for
)


class TestL01RiskFreeHelper(unittest.TestCase):
    """L01层 - risk_free_helper模块测试"""

    def test_module_import(self):
        """测试模块可导入"""
        self.assertIsNotNone(YIELD_CURVE_TENORS)
        self.assertIsNotNone(YIELD_CURVE_DURATION)
        self.assertIsNotNone(get_tenor_for)
        self.assertIsNotNone(get_tenors_for)

    def test_yield_curve_tenors(self):
        """测试收益率曲线期限字典"""
        self.assertIsInstance(YIELD_CURVE_TENORS, dict)
        self.assertGreater(len(YIELD_CURVE_TENORS), 0)
        # Check some expected values
        self.assertEqual(YIELD_CURVE_TENORS[0], '0S')
        self.assertEqual(YIELD_CURVE_TENORS[30], '1M')
        self.assertEqual(YIELD_CURVE_TENORS[365], '1Y')

    def test_yield_curve_duration(self):
        """测试收益率曲线期限列表"""
        self.assertIsInstance(YIELD_CURVE_DURATION, list)
        self.assertEqual(len(YIELD_CURVE_DURATION), len(YIELD_CURVE_TENORS))
        # Should be sorted
        self.assertEqual(YIELD_CURVE_DURATION, sorted(YIELD_CURVE_DURATION))

    def test_get_tenor_for(self):
        """测试获取单一期限"""
        start = date(2020, 1, 1)
        end = date(2020, 1, 2)
        tenor = get_tenor_for(start, end)
        self.assertEqual(tenor, '0S')

        end = date(2020, 2, 1)
        tenor = get_tenor_for(start, end)
        self.assertEqual(tenor, '1M')

        end = date(2021, 1, 1)
        tenor = get_tenor_for(start, end)
        self.assertEqual(tenor, '1Y')

    def test_get_tenors_for(self):
        """测试获取多个期限"""
        start = date(2020, 1, 1)
        end = date(2020, 12, 31)
        tenors = get_tenors_for(start, end)
        self.assertIsInstance(tenors, list)
        self.assertIn('0S', tenors)
        self.assertIn('1M', tenors)
        self.assertIn('1Y', tenors)

    def test_tenor_values(self):
        """测试期限值正确"""
        # 0S = 0 days
        self.assertEqual(YIELD_CURVE_TENORS[0], '0S')
        # 1M = 30 days
        self.assertEqual(YIELD_CURVE_TENORS[30], '1M')
        # 1Y = 365 days
        self.assertEqual(YIELD_CURVE_TENORS[365], '1Y')
        # 10Y = 3650 days
        self.assertEqual(YIELD_CURVE_TENORS[365 * 10], '10Y')


if __name__ == '__main__':
    unittest.main()
