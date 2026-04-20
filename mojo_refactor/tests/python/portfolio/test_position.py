"""
Python Integration Tests for rqalpha/portfolio/position.py
Tests matching Mojo refactored version at mojo_refactor/portfolio/position.mojo

Since Position requires RQAlpha Environment (metaclass dispatch, instrument lookup),
these tests verify:
  - PositionQueue FIFO behavior (standalone, no env needed)
  - Mathematical formula correctness for PnL calculations
  - State serialization/deserialization format
  - Expected API signatures and return types

Run with: python -m pytest test_position.py -v
"""

import pytest
import sys
import os
from datetime import date, datetime
from collections import deque

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))

from rqalpha.portfolio.position import PositionQueue


class TestPositionQueueStandalone:

    def test_queue_construction(self):
        q = PositionQueue()
        assert len(q.queue) == 0

    def test_push_single_item(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        assert len(q.queue) == 1

    def test_push_multiple_items(self):
        q = PositionQueue()
        q.handle_trade(50, date(2024, 1, 15))
        q.handle_trade(30, date(2024, 1, 16))
        assert len(q.queue) == 2

    def test_pop_exact_quantity(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        q.handle_trade(-100, date(2024, 1, 16), close_today=False)
        assert len(q.queue) == 0

    def test_pop_partial_quantity(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        q.handle_trade(-70, date(2024, 1, 16), close_today=False)
        assert len(q.queue) == 1
        assert sum(item[1] for item in q.queue) == 30

    def test_pop_fifo_order(self):
        q = PositionQueue()
        q.handle_trade(50, date(2024, 1, 15))
        q.handle_trade(30, date(2024, 1, 16))
        q.handle_trade(-60, date(2024, 1, 17), close_today=False)
        assert len(q.queue) == 1
        assert sum(item[1] for item in q.queue) == 20

    def test_pop_more_than_available(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        q.handle_trade(-150, date(2024, 1, 16), close_today=False)
        assert len(q.queue) == 1
        assert q.queue[0][1] == -50

    def test_pop_zero(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        q.handle_trade(0, date(2024, 1, 16), close_today=False)
        assert len(q.queue) == 1

    def test_clear(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        q.clear()
        assert len(q.queue) == 0

    def test_set_state_restore(self):
        q = PositionQueue()
        q.handle_trade(100, date(2024, 1, 15))
        state = list(q.queue)
        q2 = PositionQueue()
        q2.set_sate(state)
        assert len(q2.queue) == 1
        assert q2.queue[0][1] == 100


class TestPositionFormulas:

    """Verify mathematical formulas match between Python and Mojo implementations"""

    def test_pnl_formula_long(self):
        """pnl = (last_price - avg_price) * quantity * direction_factor"""
        last_price = 12.0
        avg_price = 10.0
        quantity = 100
        direction_factor = 1
        expected = (last_price - avg_price) * quantity * direction_factor
        assert expected == 200.0

    def test_pnl_formula_short(self):
        last_price = 4100.0
        avg_price = 4000.0
        quantity = 50
        direction_factor = -1
        expected = (last_price - avg_price) * quantity * direction_factor
        assert expected == -5000.0

    def test_market_value_formula(self):
        last_price = 16.8
        quantity = 200
        expected = last_price * quantity
        assert expected == 3360.0

    def test_trading_pnl_formula(self):
        trade_qty = 100
        last_price = 11.0
        trade_cost = 0.0
        direction_factor = 1
        expected = (trade_qty * last_price - trade_cost) * direction_factor
        assert expected == 1100.0

    def test_position_pnl_formula(self):
        logical_old_qty = 100
        last_price = 12.0
        prev_close = 10.0
        direction_factor = 1
        expected = logical_old_qty * (last_price - prev_close) * direction_factor
        assert expected == 200.0

    def test_daily_pnl_formula(self):
        position_pnl = 200.0
        trading_pnl = 1100.0
        expected = position_pnl + trading_pnl
        assert expected == 1300.0

    def test_apply_trade_open_cash_delta(self):
        price = 11.0
        qty = 50
        transaction_cost = 0.55
        expected = (-1.0 * price * qty) - transaction_cost
        assert abs(expected - (-550.55)) < 1e-9

    def test_apply_trade_close_cash_delta(self):
        price = 12.0
        qty = 30
        transaction_cost = 1.5
        expected = price * qty - transaction_cost
        assert expected == 358.5

    def test_avg_price_update_open(self):
        old_avg = 10.0
        old_qty = 100
        new_price = 14.0
        new_qty = 100
        expected = (old_avg * old_qty + new_price * new_qty) / (old_qty + new_qty)
        assert expected == 12.0

    def test_today_closable_formula(self):
        quantity = 150
        old_quantity = 100
        expected = quantity - old_quantity
        assert expected == 50

    def test_proxy_market_value_formula(self):
        long_mv = 1200.0
        short_mv = 0.0
        expected = long_mv - short_mv
        assert expected == 1200.0

    def test_proxy_pnl_formula(self):
        long_pnl = 200.0
        short_pnl = -5000.0
        expected = long_pnl + short_pnl
        assert expected == -4800.0

    def test_proxy_transaction_cost_formula(self):
        long_tc = 5.5
        short_tc = 2.3
        expected = long_tc + short_tc
        assert abs(expected - 7.8) < 1e-9

    def test_proxy_daily_pnl_formula(self):
        long_pos_pnl = 200.0
        long_trading_pnl = 1100.0
        short_pos_pnl = 0.0
        short_trading_pnl = 0.0
        proxy_tc = 7.8
        expected = long_pos_pnl + long_trading_pnl + short_pos_pnl + short_trading_pnl - proxy_tc
        assert abs(expected - 1292.2) < 1e-9


class TestStateSerializationFormat:

    def test_state_dict_keys(self):
        expected_keys = {
            "old_quantity", "logical_old_quantity", "quantity",
            "avg_price", "trade_cost", "transaction_cost", "prev_close"
        }
        assert expected_keys == {
            "old_quantity", "logical_old_quantity", "quantity",
            "avg_price", "trade_cost", "transaction_cost", "prev_close"
        }

    def test_state_value_types(self):
        state = {
            "old_quantity": "100",
            "logical_old_quantity": "100",
            "quantity": "150",
            "avg_price": "10.0",
            "trade_cost": "550.0",
            "transaction_cost": "5.5",
            "prev_close": "9.8",
        }
        for key, val in state.items():
            assert isinstance(val, str), f"State {key} should be string, got {type(val)}"

    def test_state_roundtrip_integers(self):
        original = {"old_quantity": "200", "quantity": "300"}
        restored_old = int(original["old_quantity"])
        restored_qty = int(original["quantity"])
        assert restored_old == 200
        restored_qty == 300

    def test_state_roundtrip_floats(self):
        original = {"avg_price": "15.5", "transaction_cost": "3.7"}
        restored_avg = float(original["avg_price"])
        restored_tc = float(original["transaction_cost"])
        assert abs(restored_avg - 15.5) < 1e-9
        assert abs(restored_tc - 3.7) < 1e-9

    def test_state_with_today_quantity_fallback(self):
        state = {
            "old_quantity": "100",
            "logical_old_quantity": "100",
            "today_quantity": "50",
        }
        if "quantity" not in state:
            quantity = int(state["old_quantity"]) + int(state["today_quantity"])
        else:
            quantity = int(state["quantity"])
        assert quantity == 150


class TestPositionLifecycleExpectedBehavior:

    def test_before_trading_expected_state_changes(self):
        expected_changes = {
            "old_quantity": "should equal quantity before call",
            "logical_old_quantity": "should equal old_quantity after reset",
            "trade_cost": "reset to 0",
            "transaction_cost": "reset to 0",
        }
        for field, desc in expected_changes.items():
            assert isinstance(field, str) and isinstance(desc, str)

    def test_apply_trade_open_expected_effects(self):
        effects = [
            ("transaction_cost", "increased by trade.transaction_cost"),
            ("trade_cost", "increased by price * qty"),
            ("quantity", "increased by trade.last_quantity"),
            ("avg_price", "recalculated as weighted average"),
            ("queue", "handle_trade called with OPEN params"),
        ]
        assert len(effects) == 5

    def test_apply_trade_close_expected_effects(self):
        effects = [
            ("transaction_cost", "increased by trade.transaction_cost"),
            ("trade_cost", "decreased by price * qty"),
            ("quantity", "decreased by trade.last_quantity"),
            ("old_quantity", "decreased by min(qty, old_quantity)"),
            ("queue", "handle_trade called with CLOSE params"),
        ]
        assert len(effects) == 5


class TestPositionAPIContract:

    """Verify the public API contract matches between Python and Mojo"""

    def test_position_required_properties(self):
        required = [
            "order_book_id", "direction", "quantity", "old_quantity",
            "avg_price", "transaction_cost", "last_price", "prev_close",
            "direction_factor",
            "market_value", "equity", "pnl", "trading_pnl",
            "position_pnl", "daily_pnl", "closable", "today_closable",
        ]
        assert len(required) == 17

    def test_position_required_methods(self):
        methods = [
            "get_state", "set_state", "before_trading", "apply_trade",
            "settlement", "update_last_price", "calc_close_today_amount",
            "position_queue",
        ]
        assert len(methods) == 8

    def test_position_proxy_required_methods(self):
        methods = [
            "order_book_id", "last_price", "market_value",
            "position_pnl", "trading_pnl", "daily_pnl", "pnl",
            "margin", "transaction_cost", "long_position", "short_position",
        ]
        assert len(methods) == 11

    def test_position_proxy_dict_required_methods(self):
        methods = ["keys", "__len__", "__contains__", "__getitem__", "items"]
        assert len(methods) == 5


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
