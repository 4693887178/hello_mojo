# -*- coding: utf-8 -*-
"""
Test for data/bar_dict_price_board.py
Group 07 - File 02
"""

import pytest
from unittest.mock import Mock, patch
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestBarDictPriceBoardStructure:
    def test_class_exists(self):
        from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
        assert BarDictPriceBoard is not None

    def test_inherits_abstract_price_board(self):
        from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
        from rqalpha.interface import AbstractPriceBoard
        assert issubclass(BarDictPriceBoard, AbstractPriceBoard)

    def test_class_methods(self):
        from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
        expected_methods = ['__init__', 'get_last_price', 'get_limit_up', 'get_limit_down', 'get_a1', 'get_b1']
        for method in expected_methods:
            assert method in dir(BarDictPriceBoard), f"Missing method: {method}"


class TestBarDictPriceBoardInit:
    def test_init(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv:
            mock_env = Mock()
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()
            
            assert board._env is not None


class TestBarDictPriceBoardMethods:
    def test_get_a1_returns_nan(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv:
            mock_env = Mock()
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            import numpy as np
            
            board = BarDictPriceBoard()
            result = board.get_a1("000001.XSHE")
            
            assert np.isnan(result)

    def test_get_b1_returns_nan(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv:
            mock_env = Mock()
            MockEnv.get_instance.return_value = mock_env
            
            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            import numpy as np
            
            board = BarDictPriceBoard()
            result = board.get_b1("000001.XSHE")
            
            assert np.isnan(result)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
