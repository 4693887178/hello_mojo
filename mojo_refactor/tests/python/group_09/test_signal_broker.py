# -*- coding: utf-8 -*-
"""
Test for mod/rqalpha_mod_sys_simulation/signal_broker.py
Group 09 - File 6
Comprehensive tests verifying Python SignalBroker behavior.
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestSignalBroker:
    def test_signal_broker_class_exists(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert SignalBroker is not None

    def test_signal_broker_has_submit_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, 'submit_order')

    def test_signal_broker_has_cancel_order(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, 'cancel_order')

    def test_signal_broker_has_get_open_orders(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, 'get_open_orders')

    def test_signal_broker_inherits_abstract_broker(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.interface import AbstractBroker
        assert issubclass(SignalBroker, AbstractBroker)

    def test_signal_broker_has_match_method(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        assert hasattr(SignalBroker, '_match')


class TestSignalBrokerMethods:
    def test_signal_broker_is_abstract_broker(self):
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.interface import AbstractBroker
        assert issubclass(SignalBroker, AbstractBroker)

    def test_get_open_orders_returns_empty_list(self):
        """SignalBroker.get_open_orders should always return empty list."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.interface import AbstractBroker
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        broker = SignalBroker(env, env.config)
        assert broker.get_open_orders() == []
        assert broker.get_open_orders(order_book_id="000001.XSHE") == []

    def test_cancel_order_returns_none(self):
        """SignalBroker.cancel_order should return None and log warning."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        broker = SignalBroker(env, env.config)
        order = Mock()
        result = broker.cancel_order(order)
        assert result is None


class TestSignalBrokerSubmitOrder:
    """Test submit_order behavior matching Python implementation."""

    def test_submit_order_exercise_raises(self):
        """EXERCISE position_effect should raise NotImplementedError."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.const import POSITION_EFFECT, SIDE, ORDER_TYPE
        from rqalpha.model.order import Order
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        broker = SignalBroker(env, env.config)
        order = Mock()
        order.position_effect = POSITION_EFFECT.EXERCISE
        with pytest.raises(NotImplementedError, match="does not support exercise"):
            broker.submit_order(order)

    def test_submit_order_publishes_pending_new_event(self):
        """submit_order should publish ORDER_PENDING_NEW event."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.core.events import EVENT, Event
        from rqalpha.const import POSITION_EFFECT, SIDE, ORDER_TYPE
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        env.event_bus = Mock()
        env.get_account = Mock(return_value=Mock())
        broker = SignalBroker(env, env.config)
        order = Mock()
        order.position_effect = POSITION_EFFECT.OPEN
        order.is_final = Mock(return_value=False)
        order.order_book_id = "000001.XSHE"
        order.active = Mock()
        original_match = SignalBroker._match
        SignalBroker._match = Mock()
        try:
            broker.submit_order(order)
        finally:
            SignalBroker._match = original_match
        env.event_bus.publish_event.assert_called()

    def test_submit_order_final_order_returns_early(self):
        """If order.is_final() is True, should return without matching."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.core.events import EVENT
        from rqalpha.const import POSITION_EFFECT
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        env.event_bus = Mock()
        env.get_account = Mock(return_value=Mock())
        broker = SignalBroker(env, env.config)
        order = Mock()
        order.position_effect = POSITION_EFFECT.OPEN
        order.is_final = Mock(return_value=True)
        order.order_book_id = "000001.XSHE"
        broker.submit_order(order)
        order.active.assert_not_called()

    def test_submit_order_calls_active_and_match(self):
        """Normal order should call active() and _match()."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.const import POSITION_EFFECT, ORDER_TYPE, SIDE
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        env.event_bus = Mock()
        env.get_account = Mock(return_value=Mock())
        env.price_board = Mock()
        env.price_board.get_last_price = Mock(return_value=10.0)
        env.price_board.get_limit_up = Mock(return_value=11.0)
        env.price_board.get_limit_down = Mock(return_value=9.0)
        broker = SignalBroker(env, env.config)
        order = Mock()
        order.position_effect = POSITION_EFFECT.OPEN
        order.is_final = Mock(return_value=False)
        order.order_book_id = "000001.XSHE"
        order.order_type = Mock(return_value=ORDER_TYPE.MARKET)
        order.side = SIDE.BUY
        order.frozen_price = 10.0
        order.quantity = 100
        order.position_direction = Mock()
        order.active = Mock()
        original_match = SignalBroker._match
        call_count = [0]
        def track_match(self_ref, account, order_ref):
            call_count[0] += 1
        SignalBroker._match = track_match
        original_slippage = broker._slippage_decider
        broker._slippage_decider = Mock()
        broker._slippage_decider.get_trade_price = Mock(return_value=10.0)
        try:
            broker.submit_order(order)
            order.active.assert_called_once()
            assert call_count[0] == 1
        finally:
            SignalBroker._match = original_match
            broker._slippage_decider = original_slippage


class TestSignalBrokerMatch:
    """Test _match method behavior."""

    def test_match_limit_uses_frozen_price(self):
        """LIMIT orders should use frozen_price as deal_price."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.const import POSITION_EFFECT, SIDE, ORDER_TYPE
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        env.event_bus = Mock()
        env.price_board = Mock()
        env.price_board.get_last_price = Mock(return_value=10.0)
        env.price_board.get_limit_up = Mock(return_value=11.0)
        env.price_board.get_limit_down = Mock(return_value=9.0)
        account = Mock()
        account.calc_close_today_amount = Mock(return_value=0)
        broker = SignalBroker(env, env.config)
        broker._slippage_decider = Mock()
        broker._slippage_decider.get_trade_price = Mock(return_value=10.5)
        order = Mock()
        order.order_book_id = "000001.XSHE"
        order.order_type = Mock(return_value=ORDER_TYPE.LIMIT)
        order.frozen_price = 10.5
        order.side = SIDE.BUY
        order.quantity = 100
        order.position_direction = Mock()
        order.position_effect = POSITION_EFFECT.OPEN
        order.mark_rejected = Mock()
        order.fill = Mock()
        order.order_id = 1
        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.is_valid_price', return_value=True):
            with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.copy'):
                with patch('rqalpha.model.trade.Trade.__from_create__', return_value=Mock()):
                    broker._match(account, order)
        order.fill.assert_called_once()

    def test_match_buy_at_limit_up_rejected(self):
        """Buy order at or above limit_up should be rejected when price_limit=True."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.const import POSITION_EFFECT, SIDE, ORDER_TYPE
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        env.event_bus = Mock()
        env.price_board = Mock()
        env.price_board.get_last_price = Mock(return_value=11.0)
        env.price_board.get_limit_up = Mock(return_value=11.0)
        env.price_board.get_limit_down = Mock(return_value=9.0)
        account = Mock()
        broker = SignalBroker(env, env.config)
        broker._slippage_decider = Mock()
        broker._slippage_decider.get_trade_price = Mock(return_value=11.0)
        order = Mock()
        order.order_book_id = "000001.XSHE"
        order.order_type = Mock(return_value=ORDER_TYPE.MARKET)
        order.side = SIDE.BUY
        order.quantity = 100
        order.position_direction = Mock()
        order.position_effect = POSITION_EFFECT.OPEN
        order.mark_rejected = Mock()
        order.message = ""
        order.order_id = 1
        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.is_valid_price', return_value=True):
            with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.Trade'):
                with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.copy'):
                    broker._match(account, order)
        order.mark_rejected.assert_called_once()
        assert "limit_up" in order.mark_rejected.call_args[0][0].lower()

    def test_match_sell_at_limit_down_rejected(self):
        """Sell order at or below limit_down should be rejected when price_limit=True."""
        from rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker import SignalBroker
        from rqalpha.const import POSITION_EFFECT, SIDE, ORDER_TYPE
        env = Mock()
        env.config = Mock()
        env.config.slippage_model = "PriceRatioSlippage"
        env.config.slippage = 0.0
        env.config.price_limit = True
        env.event_bus = Mock()
        env.price_board = Mock()
        env.price_board.get_last_price = Mock(return_value=9.0)
        env.price_board.get_limit_up = Mock(return_value=11.0)
        env.price_board.get_limit_down = Mock(return_value=9.0)
        account = Mock()
        broker = SignalBroker(env, env.config)
        broker._slippage_decider = Mock()
        broker._slippage_decider.get_trade_price = Mock(return_value=9.0)
        order = Mock()
        order.order_book_id = "000001.XSHE"
        order.order_type = Mock(return_value=ORDER_TYPE.MARKET)
        order.side = SIDE.SELL
        order.quantity = 100
        order.position_direction = Mock()
        order.position_effect = POSITION_EFFECT.CLOSE
        order.mark_rejected = Mock()
        order.message = ""
        order.order_id = 1
        with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.is_valid_price', return_value=True):
            with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.Trade'):
                with patch('rqalpha.mod.rqalpha_mod_sys_simulation.signal_broker.copy'):
                    broker._match(account, order)
        order.mark_rejected.assert_called_once()
        assert "limit_down" in order.mark_rejected.call_args[0][0].lower()


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
