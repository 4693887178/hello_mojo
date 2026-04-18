# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/slippage.py
Group 07 - Slippage Models

Comprehensive tests covering all slippage models in rqalpha:
  - PriceRatioSlippage: rate-based slippage with limit price clamping
  - TickSizeSlippage: tick-size-based slippage
  - LimitPriceSlippage: limit order price slippage
  - SlippageDecider: dispatcher for slippage models
  - is_valid_price: NaN/invalid price detection
"""

import pytest
import math
from unittest.mock import Mock, MagicMock, patch

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


# ============================================================
# is_valid_price tests
# ============================================================

class TestIsValidPrice:
    def test_positive_price(self):
        from rqalpha.utils import is_valid_price
        assert is_valid_price(10.0) is True

    def test_small_positive_price(self):
        from rqalpha.utils import is_valid_price
        assert is_valid_price(0.001) is True

    def test_zero_price(self):
        from rqalpha.utils import is_valid_price
        assert is_valid_price(0.0) is False

    def test_negative_price(self):
        from rqalpha.utils import is_valid_price
        assert is_valid_price(-1.0) is False

    def test_nan_price(self):
        from rqalpha.utils import is_valid_price
        assert is_valid_price(float('nan')) is False


# ============================================================
# SlippageDecider structure tests
# ============================================================

class TestSlippageDeciderStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        assert SlippageDecider is not None

    def test_class_methods(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        expected_methods = ['__init__', 'get_trade_price']
        for method in expected_methods:
            assert method in dir(SlippageDecider), f"Missing method: {method}"

    def test_invalid_model_raises(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        with pytest.raises(RuntimeError):
            SlippageDecider("NonExistentSlippage", 0.01)


# ============================================================
# BaseSlippage structure tests
# ============================================================

class TestBaseSlippageStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import BaseSlippage
        assert BaseSlippage is not None

    def test_is_abstract(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import BaseSlippage
        import abc
        assert hasattr(BaseSlippage, '__abstractmethods__')


# ============================================================
# PriceRatioSlippage tests
# ============================================================

class TestPriceRatioSlippage:
    def test_init_valid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        slippage = PriceRatioSlippage(rate=0.01)
        assert slippage.rate == 0.01

    def test_init_zero_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        slippage = PriceRatioSlippage(rate=0.0)
        assert slippage.rate == 0.0

    def test_init_near_one_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        slippage = PriceRatioSlippage(rate=0.999)
        assert abs(slippage.rate - 0.999) < 1e-9

    def test_init_invalid_rate_negative(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        with pytest.raises(ValueError):
            PriceRatioSlippage(rate=-0.01)

    def test_init_invalid_rate_one(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        with pytest.raises(ValueError):
            PriceRatioSlippage(rate=1.0)

    def test_init_invalid_rate_above_one(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        with pytest.raises(ValueError):
            PriceRatioSlippage(rate=1.5)

    def test_get_trade_price_buy(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = float('nan')
            mock_price_board.get_limit_down.return_value = float('nan')
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            slippage = PriceRatioSlippage(rate=0.01)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result > 10.0
            assert abs(result - 10.1) < 1e-9

    def test_get_trade_price_sell(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = float('nan')
            mock_price_board.get_limit_down.return_value = float('nan')
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            slippage = PriceRatioSlippage(rate=0.01)
            mock_order = MagicMock()
            mock_order.side = SIDE.SELL
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result < 10.0
            assert abs(result - 9.9) < 1e-9

    def test_get_trade_price_exercise_raises(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import POSITION_EFFECT

        slippage = PriceRatioSlippage(rate=0.01)
        mock_order = MagicMock()
        mock_order.position_effect = POSITION_EFFECT.EXERCISE

        with pytest.raises(NotImplementedError):
            slippage.get_trade_price(mock_order, 10.0)

    def test_get_trade_price_zero_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = float('nan')
            mock_price_board.get_limit_down.return_value = float('nan')
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            slippage = PriceRatioSlippage(rate=0.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result == 10.0

    def test_get_trade_price_limit_up_clamp(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = 11.0
            mock_price_board.get_limit_down.return_value = float('nan')
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            slippage = PriceRatioSlippage(rate=0.5)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result == 11.0

    def test_get_trade_price_limit_down_clamp(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = float('nan')
            mock_price_board.get_limit_down.return_value = 9.0
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            slippage = PriceRatioSlippage(rate=0.5)
            mock_order = MagicMock()
            mock_order.side = SIDE.SELL
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result == 9.0

    def test_get_trade_price_no_clamp_within_limits(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = 15.0
            mock_price_board.get_limit_down.return_value = 5.0
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            slippage = PriceRatioSlippage(rate=0.01)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result < 15.0
            assert result > 5.0
            assert abs(result - 10.1) < 1e-9


# ============================================================
# TickSizeSlippage tests
# ============================================================

class TestTickSizeSlippage:
    def test_init_valid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        slippage = TickSizeSlippage(rate=2)
        assert slippage.rate == 2

    def test_init_zero_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        slippage = TickSizeSlippage(rate=0)
        assert slippage.rate == 0

    def test_init_large_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        slippage = TickSizeSlippage(rate=100)
        assert slippage.rate == 100

    def test_init_invalid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        with pytest.raises(ValueError):
            TickSizeSlippage(rate=-1)

    def test_get_trade_price_buy(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_instrument = MagicMock()
            mock_instrument.tick_size.return_value = 0.01
            mock_data_proxy = MagicMock()
            mock_data_proxy.instrument.return_value = mock_instrument
            mock_env.data_proxy = mock_data_proxy
            MockEnv.get_instance.return_value = mock_env

            slippage = TickSizeSlippage(rate=1.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert abs(result - 10.01) < 1e-9

    def test_get_trade_price_sell(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_instrument = MagicMock()
            mock_instrument.tick_size.return_value = 0.01
            mock_data_proxy = MagicMock()
            mock_data_proxy.instrument.return_value = mock_instrument
            mock_env.data_proxy = mock_data_proxy
            MockEnv.get_instance.return_value = mock_env

            slippage = TickSizeSlippage(rate=1.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.SELL
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert abs(result - 9.99) < 1e-9

    def test_get_trade_price_exercise_raises(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        from rqalpha.const import POSITION_EFFECT

        slippage = TickSizeSlippage(rate=1.0)
        mock_order = MagicMock()
        mock_order.position_effect = POSITION_EFFECT.EXERCISE

        with pytest.raises(NotImplementedError):
            slippage.get_trade_price(mock_order, 10.0)

    def test_get_trade_price_zero_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_instrument = MagicMock()
            mock_instrument.tick_size.return_value = 0.01
            mock_data_proxy = MagicMock()
            mock_data_proxy.instrument.return_value = mock_instrument
            mock_env.data_proxy = mock_data_proxy
            MockEnv.get_instance.return_value = mock_env

            slippage = TickSizeSlippage(rate=0.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert result == 10.0

    def test_get_trade_price_multiple_ticks(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_instrument = MagicMock()
            mock_instrument.tick_size.return_value = 0.01
            mock_data_proxy = MagicMock()
            mock_data_proxy.instrument.return_value = mock_instrument
            mock_env.data_proxy = mock_data_proxy
            MockEnv.get_instance.return_value = mock_env

            slippage = TickSizeSlippage(rate=5.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = slippage.get_trade_price(mock_order, 10.0)
            assert abs(result - 10.05) < 1e-9

    def test_get_trade_price_negative_result_raises(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_instrument = MagicMock()
            mock_instrument.tick_size.return_value = 100.0
            mock_data_proxy = MagicMock()
            mock_data_proxy.instrument.return_value = mock_instrument
            mock_env.data_proxy = mock_data_proxy
            MockEnv.get_instance.return_value = mock_env

            slippage = TickSizeSlippage(rate=1.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.SELL
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            with pytest.raises(ValueError):
                slippage.get_trade_price(mock_order, 10.0)


# ============================================================
# LimitPriceSlippage tests
# ============================================================

class TestLimitPriceSlippage:
    def test_init(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import LimitPriceSlippage
        slippage = LimitPriceSlippage(None)
        assert slippage is not None

    def test_get_trade_price_limit_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import LimitPriceSlippage
        from rqalpha.const import ORDER_TYPE

        slippage = LimitPriceSlippage(None)
        mock_order = MagicMock()
        mock_order.type = ORDER_TYPE.LIMIT
        mock_order.price = 10.0

        result = slippage.get_trade_price(mock_order, 12.0)
        assert result == 10.0

    def test_get_trade_price_market_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import LimitPriceSlippage
        from rqalpha.const import ORDER_TYPE

        slippage = LimitPriceSlippage(None)
        mock_order = MagicMock()
        mock_order.type = ORDER_TYPE.MARKET

        result = slippage.get_trade_price(mock_order, 12.0)
        assert result == 12.0

    def test_get_trade_price_limit_sell_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import LimitPriceSlippage
        from rqalpha.const import ORDER_TYPE

        slippage = LimitPriceSlippage(None)
        mock_order = MagicMock()
        mock_order.type = ORDER_TYPE.LIMIT
        mock_order.price = 9.5

        result = slippage.get_trade_price(mock_order, 10.0)
        assert result == 9.5


# ============================================================
# SlippageDecider integration tests
# ============================================================

class TestSlippageDeciderIntegration:
    def test_price_ratio_dispatch(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = float('nan')
            mock_price_board.get_limit_down.return_value = float('nan')
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env

            decider = SlippageDecider("PriceRatioSlippage", 0.01)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = decider.get_trade_price(mock_order, 10.0)
            assert result > 10.0

    def test_tick_size_dispatch(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        from rqalpha.const import SIDE

        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_instrument = MagicMock()
            mock_instrument.tick_size.return_value = 0.01
            mock_data_proxy = MagicMock()
            mock_data_proxy.instrument.return_value = mock_instrument
            mock_env.data_proxy = mock_data_proxy
            MockEnv.get_instance.return_value = mock_env

            decider = SlippageDecider("TickSizeSlippage", 1.0)
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            mock_order.order_book_id = "000001.XSHE"

            result = decider.get_trade_price(mock_order, 10.0)
            assert abs(result - 10.01) < 1e-9

    def test_limit_price_dispatch(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        from rqalpha.const import ORDER_TYPE

        decider = SlippageDecider("LimitPriceSlippage", 0.0)
        mock_order = MagicMock()
        mock_order.type = ORDER_TYPE.LIMIT
        mock_order.price = 10.0

        result = decider.get_trade_price(mock_order, 12.0)
        assert result == 10.0

    def test_dotted_path_import(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        decider = SlippageDecider("PriceRatioSlippage", 0.01)
        assert decider is not None


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
