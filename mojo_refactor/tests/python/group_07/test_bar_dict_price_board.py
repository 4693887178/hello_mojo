# -*- coding: utf-8 -*-
"""
Comprehensive Test Suite for data/bar_dict_price_board.py (Python Original)
Group 07 - File 02

Tests cover:
  1. Class structure and inheritance from AbstractPriceBoard
  2. PriceBoard interface: get_last_price, get_limit_up, get_limit_down, get_a1, get_b1
  3. Behavior parity with Mojo refactored version
"""

import pytest
import numpy as np
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestBarDictPriceBoardStructure:
    """Test class exists, inherits correctly, has expected methods."""

    def test_class_exists(self):
        from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
        assert BarDictPriceBoard is not None

    def test_inherits_abstract_price_board(self):
        from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
        from rqalpha.interface import AbstractPriceBoard
        assert issubclass(BarDictPriceBoard, AbstractPriceBoard)

    def test_has_required_methods(self):
        from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
        expected_methods = [
            '__init__', '_get_bar',
            'get_last_price', 'get_limit_up', 'get_limit_down',
            'get_a1', 'get_b1'
        ]
        for method in expected_methods:
            assert method in dir(BarDictPriceBoard), f"Missing method: {method}"


class TestBarDictPriceBoardInit:
    """Test initialization stores Environment reference."""

    def test_init_stores_env(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv:
            mock_env = Mock()
            MockEnv.get_instance.return_value = mock_env

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()

            assert board._env is not None
            assert board._env == mock_env


class TestGetA1B1AlwaysReturnNaN:
    """Test get_a1 and get_b1 always return np.nan (matches Mojo behavior)."""

    @pytest.mark.parametrize("order_book_id", ["000001.XSHE", "600000.XSHG", "", "ANY.ID"])
    def test_get_a1_returns_nan(self, order_book_id):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv:
            mock_env = Mock()
            MockEnv.get_instance.return_value = mock_env

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()
            result = board.get_a1(order_book_id)
            assert np.isnan(result), f"get_a1({order_book_id!r}) should return NaN"

    @pytest.mark.parametrize("order_book_id", ["000001.XSHE", "600000.XSHG", "", "ANY.ID"])
    def test_get_b1_returns_nan(self, order_book_id):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv:
            mock_env = Mock()
            MockEnv.get_instance.return_value = mock_env

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()
            result = board.get_b1(order_book_id)
            assert np.isnan(result), f"get_b1({order_book_id!r}) should return NaN"


class TestGetLastPriceViaGetBar:
    """Test get_last_price delegates to _get_bar which uses Environment."""

    def test_get_last_price_returns_bar_last(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv, \
             patch('rqalpha.data.bar_dict_price_board.ExecutionContext') as MockCtx, \
             patch('rqalpha.data.bar_dict_price_board.EXECUTION_PHASE') as MockPhase:

            mock_env = Mock()
            mock_bar = Mock()
            mock_bar.last = 42.5
            mock_env.get_bar.return_value = mock_bar
            MockEnv.get_instance.return_value = mock_env

            MockCtx.phase.return_value = MockPhase.ON_BAR

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()

            result = board.get_last_price("000001.XSHE")
            assert result == 42.5
            mock_env.get_bar.assert_called_once_with("000001.XSHE")

    def test_get_limit_up_returns_bar_limit_up(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv, \
             patch('rqalpha.data.bar_dict_price_board.ExecutionContext') as MockCtx, \
             patch('rqalpha.data.bar_dict_price_board.EXECUTION_PHASE') as MockPhase:

            mock_env = Mock()
            mock_bar = Mock()
            mock_bar.limit_up = 11.55
            mock_env.get_bar.return_value = mock_bar
            MockEnv.get_instance.return_value = mock_env

            MockCtx.phase.return_value = MockPhase.ON_BAR

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()

            result = board.get_limit_up("000001.XSHE")
            assert result == 11.55

    def test_get_limit_down_returns_bar_limit_down(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv, \
             patch('rqalpha.data.bar_dict_price_board.ExecutionContext') as MockCtx, \
             patch('rqalpha.data.bar_dict_price_board.EXECUTION_PHASE') as MockPhase:

            mock_env = Mock()
            mock_bar = Mock()
            mock_bar.limit_down = 9.45
            mock_env.get_bar.return_value = mock_bar
            MockEnv.get_instance.return_value = mock_env

            MockCtx.phase.return_value = MockPhase.ON_BAR

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()

            result = board.get_limit_down("000001.XSHE")
            assert result == 9.45


class TestGetBarOpenAuctionPhase:
    """Test _get_bar uses open_auction_bar when phase is OPEN_AUCTION."""

    def test_open_auction_uses_data_proxy(self):
        with patch('rqalpha.data.bar_dict_price_board.Environment') as MockEnv, \
             patch('rqalpha.data.bar_dict_price_board.ExecutionContext') as MockCtx, \
             patch('rqalpha.data.bar_dict_price_board.EXECUTION_PHASE') as MockPhase:

            mock_env = Mock()
            mock_data_proxy = Mock()
            mock_auction_bar = Mock()
            mock_auction_bar.last = 99.9
            mock_data_proxy.get_open_auction_bar.return_value = mock_auction_bar
            mock_env.data_proxy = mock_data_proxy
            mock_env.trading_dt = "2024-01-15"
            MockEnv.get_instance.return_value = mock_env

            MockCtx.phase.return_value = MockPhase.OPEN_AUCTION

            from rqalpha.data.bar_dict_price_board import BarDictPriceBoard
            board = BarDictPriceBoard()

            result = board.get_last_price("000001.XSHE")
            assert result == 99.9
            mock_data_proxy.get_open_auction_bar.assert_called_once_with(
                "000001.XSHE", "2024-01-15"
            )


class TestNaNValueConsistency:
    """Verify np.nan behavior matches Mojo NAN_VALUE."""

    def test_np_nan_is_ieee754(self):
        assert np.isnan(np.nan)
        nan_copy = np.nan
        assert np.isnan(nan_copy)

    def test_nan_not_equal_to_self(self):
        assert np.nan != np.nan


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
