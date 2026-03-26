# -*- coding: utf-8 -*-
"""
第四组测试 - model/tick.py
测试Python版本的Tick对象模块
"""

import unittest
import sys
import os
import datetime

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')


class TestTickModule(unittest.TestCase):
    """测试rqalpha.model.tick模块"""

    def setUp(self):
        from rqalpha.model import tick
        self.module = tick

    def test_TickObject_exists(self):
        """测试TickObject类存在"""
        self.assertTrue(hasattr(self.module, 'TickObject'))


class TestTickObject(unittest.TestCase):
    """测试TickObject类"""

    def setUp(self):
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        self.TickObject = TickObject
        self.Instrument = Instrument

    def _create_mock_instrument(self):
        """创建模拟Instrument对象"""
        ins_dict = {
            'order_book_id': '000001.XSHE',
            'symbol': '平安银行',
            'display_name': '平安银行',
            'exchange': 'XSHE',
            'type': 'CS',
            'listed_date': datetime.date(1991, 4, 3),
            'de_listed_date': datetime.date(2999, 12, 31),
        }
        return self.Instrument(ins_dict)

    def _create_mock_tick_dict(self):
        """创建模拟tick字典"""
        return {
            'datetime': datetime.datetime(2024, 1, 15, 10, 30, 0),
            'open': 10.0,
            'high': 10.5,
            'low': 9.8,
            'last': 10.2,
            'prev_close': 10.0,
            'volume': 1000000,
            'total_turnover': 10200000.0,
            'asks': [10.3, 10.4, 10.5, 10.6, 10.7],
            'ask_vols': [1000, 2000, 3000, 4000, 5000],
            'bids': [10.2, 10.1, 10.0, 9.9, 9.8],
            'bid_vols': [5000, 4000, 3000, 2000, 1000],
            'limit_up': 11.0,
            'limit_down': 9.0,
        }

    def test_tick_object_init(self):
        """测试TickObject初始化"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertIsNotNone(tick)

    def test_order_book_id(self):
        """测试order_book_id属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.order_book_id, '000001.XSHE')

    def test_datetime(self):
        """测试datetime属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.datetime, datetime.datetime(2024, 1, 15, 10, 30, 0))

    def test_open(self):
        """测试open属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.open, 10.0)

    def test_high(self):
        """测试high属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.high, 10.5)

    def test_low(self):
        """测试low属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.low, 9.8)

    def test_last(self):
        """测试last属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.last, 10.2)

    def test_prev_close(self):
        """测试prev_close属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.prev_close, 10.0)

    def test_volume(self):
        """测试volume属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.volume, 1000000)

    def test_total_turnover(self):
        """测试total_turnover属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.total_turnover, 10200000.0)

    def test_asks(self):
        """测试asks属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(len(tick.asks), 5)
        self.assertEqual(tick.asks[0], 10.3)

    def test_ask_vols(self):
        """测试ask_vols属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(len(tick.ask_vols), 5)
        self.assertEqual(tick.ask_vols[0], 1000)

    def test_bids(self):
        """测试bids属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(len(tick.bids), 5)
        self.assertEqual(tick.bids[0], 10.2)

    def test_bid_vols(self):
        """测试bid_vols属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(len(tick.bid_vols), 5)
        self.assertEqual(tick.bid_vols[0], 5000)

    def test_limit_up(self):
        """测试limit_up属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.limit_up, 11.0)

    def test_limit_down(self):
        """测试limit_down属性"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.limit_down, 9.0)

    def test_repr(self):
        """测试__repr__方法"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        repr_str = repr(tick)
        self.assertIn('Tick', repr_str)

    def test_getitem(self):
        """测试__getitem__方法"""
        instrument = self._create_mock_instrument()
        tick_dict = self._create_mock_tick_dict()
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick['last'], 10.2)
        self.assertEqual(tick['open'], 10.0)


class TestTickObjectEdgeCases(unittest.TestCase):
    """测试TickObject边界情况"""

    def setUp(self):
        from rqalpha.model.tick import TickObject
        from rqalpha.model.instrument import Instrument
        self.TickObject = TickObject
        self.Instrument = Instrument

    def _create_mock_instrument(self):
        """创建模拟Instrument对象"""
        ins_dict = {
            'order_book_id': '000001.XSHE',
            'symbol': '平安银行',
            'display_name': '平安银行',
            'exchange': 'XSHE',
            'type': 'CS',
            'listed_date': datetime.date(1991, 4, 3),
            'de_listed_date': datetime.date(2999, 12, 31),
        }
        return self.Instrument(ins_dict)

    def test_missing_last_returns_prev_close(self):
        """测试缺少last时返回prev_close"""
        instrument = self._create_mock_instrument()
        tick_dict = {
            'open': 10.0,
            'high': 10.5,
            'low': 9.8,
            'prev_close': 10.0,
        }
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.last, 10.0)

    def test_missing_prev_close_returns_zero(self):
        """测试缺少prev_close时返回0"""
        instrument = self._create_mock_instrument()
        tick_dict = {
            'open': 10.0,
            'high': 10.5,
            'low': 9.8,
        }
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.prev_close, 0)

    def test_missing_volume_returns_zero(self):
        """测试缺少volume时返回0"""
        instrument = self._create_mock_instrument()
        tick_dict = {
            'open': 10.0,
            'high': 10.5,
            'low': 9.8,
        }
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.volume, 0)

    def test_missing_asks_returns_zeros(self):
        """测试缺少asks时返回零数组"""
        instrument = self._create_mock_instrument()
        tick_dict = {
            'open': 10.0,
        }
        tick = self.TickObject(instrument, tick_dict)
        self.assertEqual(tick.asks, [0] * 5)


if __name__ == '__main__':
    unittest.main(verbosity=2)
