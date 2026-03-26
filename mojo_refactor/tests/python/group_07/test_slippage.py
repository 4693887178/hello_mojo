# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/slippage.py
Group 07 - File 07
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSlippageDeciderStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        assert SlippageDecider is not None

    def test_class_methods(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import SlippageDecider
        expected_methods = ['__init__', 'get_trade_price']
        for method in expected_methods:
            assert method in dir(SlippageDecider), f"Missing method: {method}"


class TestBaseSlippageStructure:
    def test_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import BaseSlippage
        assert BaseSlippage is not None


class TestPriceRatioSlippage:
    def test_init_valid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        
        slippage = PriceRatioSlippage(rate=0.01)
        assert slippage.rate == 0.01

    def test_init_invalid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        
        with pytest.raises(ValueError):
            PriceRatioSlippage(rate=1.5)

    def test_get_trade_price_buy(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import PriceRatioSlippage
        from rqalpha.const import SIDE
        
        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.slippage.Environment') as MockEnv:
            mock_env = MagicMock()
            mock_price_board = MagicMock()
            mock_price_board.get_limit_up.return_value = 15.0
            mock_price_board.get_limit_down.return_value = 9.0
            mock_env.price_board = mock_price_board
            MockEnv.get_instance.return_value = mock_env
            
            slippage = PriceRatioSlippage(rate=0.01)
            
            mock_order = MagicMock()
            mock_order.side = SIDE.BUY
            mock_order.position_effect = MagicMock()
            
            result = slippage.get_trade_price(mock_order, 10.0)
            
            assert result > 10.0


class TestTickSizeSlippage:
    def test_init_valid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        
        slippage = TickSizeSlippage(rate=2)
        assert slippage.rate == 2

    def test_init_invalid_rate(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import TickSizeSlippage
        
        with pytest.raises(ValueError):
            TickSizeSlippage(rate=-1)


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


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
