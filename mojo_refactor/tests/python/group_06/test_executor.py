# -*- coding: utf-8 -*-
"""
Test for core/executor.py (Python Original) vs executor.mojo (Mojo Refactor)
Group 06 - File 09
Behavioral parity verification tests.
"""

import pytest
import sys
import os
import json

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestExecutorBasic:
    """Test Executor class basic functionality"""

    def test_executor_exists(self):
        """Test Executor class exists and can be instantiated"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        assert executor is not None
        assert executor._last_before_trading is None

    def test_executor_init_with_env(self):
        """Test Executor initialization stores env reference"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        assert executor._env is env

    def test_event_split_map_exists(self):
        """Test EVENT_SPLIT_MAP exists with all 6 event types"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import EVENT
        expected_keys = [EVENT.BEFORE_TRADING, EVENT.BAR, EVENT.TICK,
                         EVENT.AFTER_TRADING, EVENT.SETTLEMENT, EVENT.OPEN_AUCTION]
        for key in expected_keys:
            assert key in Executor.EVENT_SPLIT_MAP, f"Missing key: {key}"
            split_tuple = Executor.EVENT_SPLIT_MAP[key]
            assert len(split_tuple) == 3, f"{key} should have 3 phases"

    def test_event_split_map_bar_phases(self):
        """Test BAR event splits into PRE_BAR, BAR, POST_BAR"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import EVENT
        pre, main, post = Executor.EVENT_SPLIT_MAP[EVENT.BAR]
        assert pre == EVENT.PRE_BAR
        assert main == EVENT.BAR
        assert post == EVENT.POST_BAR


class TestExecutorState:
    """Test state persistence (get_state/set_state)"""

    def test_get_state_initial(self):
        """Test get_state returns null for initial state"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        state = executor.get_state()
        data = json.loads(state.decode('utf-8'))
        assert data['last_before_trading'] is None

    def test_get_state_after_trading(self):
        """Test get_state returns custom date encoding after before_trading runs"""
        from rqalpha.core.executor import Executor
        from datetime import date
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        test_date = date(2020, 5, 15)
        executor._last_before_trading = test_date
        state = executor.get_state()
        data = json.loads(state.decode('utf-8'))
        assert '__date__' in data['last_before_trading']
        assert data['last_before_trading']['as_str'] == '20200515'

    def test_set_state_null(self):
        """Test set_state handles null value"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        executor.set_state(b'{"last_before_trading": null}')
        assert executor._last_before_trading is None

    def test_set_state_valid_date(self):
        """Test set_state parses valid date string (returns raw string via custom decoder)"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        executor.set_state(b'{"last_before_trading": "2020-03-15"}')
        assert isinstance(executor._last_before_trading, str)

    def test_set_state_empty_raises(self):
        """Test set_state raises on empty input (Python original doesn't guard this)"""
        from rqalpha.core.executor import Executor
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        with pytest.raises(Exception):
            executor.set_state(b"")


class TestExecutorEventHandling:
    """Test Executor event handling methods"""

    def test_run_method_exists(self):
        """Test run method exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, 'run')

    def test_ensure_before_trading_exists(self):
        """Test _ensure_before_trading method exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, '_ensure_before_trading')

    def test_split_and_publish_exists(self):
        """Test _split_and_publish method exists"""
        from rqalpha.core.executor import Executor
        assert hasattr(Executor, '_split_and_publish')

    def test_ensure_before_trading_first_call(self):
        """Test first _ensure_before_trading call publishes BEFORE_TRADING"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import Event, EVENT
        from datetime import datetime
        from unittest.mock import MagicMock, patch
        env = MagicMock()
        env.config.extra.is_hold = False
        executor = Executor(env)
        event = Event(EVENT.BAR, calendar_dt=datetime(2020, 1, 2),
                      trading_dt=datetime(2020, 1, 2))
        with patch.object(executor, '_split_and_publish') as mock_split:
            result = executor._ensure_before_trading(event)
            assert result is False
            mock_split.assert_called()

    def test_ensure_before_trading_same_day_skips(self):
        """Test same-day call to _ensure_before_trading returns True (skip)"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import Event, EVENT
        from datetime import datetime, date
        from unittest.mock import MagicMock
        env = MagicMock()
        env.config.extra.is_hold = False
        executor = Executor(env)
        test_date = date(2020, 1, 2)
        executor._last_before_trading = test_date
        event = Event(EVENT.BAR, calendar_dt=datetime(2020, 1, 2),
                      trading_dt=datetime(2020, 1, 2))
        result = executor._ensure_before_trading(event)
        assert result is True

    def test_ensure_before_trading_is_hold_always_skips(self):
        """Test is_hold=True always skips before_trading"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import Event, EVENT
        from datetime import datetime
        from unittest.mock import MagicMock
        env = MagicMock()
        env.config.extra.is_hold = True
        executor = Executor(env)
        event = Event(EVENT.BAR, calendar_dt=datetime(2020, 1, 2),
                      trading_dt=datetime(2020, 1, 2))
        result = executor._ensure_before_trading(event)
        assert result is True

    def test_split_and_publish_bar_splits_three(self):
        """Test BAR event splits into PRE_BAR + BAR + POST_BAR"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import Event, EVENT
        from copy import copy
        from datetime import datetime
        from unittest.mock import MagicMock
        env = MagicMock()
        executor = Executor(env)
        published = []

        def capture_publish(e):
            published.append(str(e.event_type))
            return False

        env.event_bus.publish_event = capture_publish
        event = Event(EVENT.BAR, calendar_dt=datetime(2020, 1, 2),
                      trading_dt=datetime(2020, 1, 2))
        executor._split_and_publish(event)
        bar_types = [e for e in published if 'BAR' in e]
        assert len(bar_types) == 3, f"Expected 3 BAR phases, got {bar_types}"


class TestExecutorSettlement:
    """Test settlement publishing behavior"""

    def test_settlement_published_between_days(self):
        """Test settlement is published between different trading days"""
        from rqalpha.core.executor import Executor
        from rqalpha.core.events import Event, EVENT
        from datetime import datetime, date
        from unittest.mock import MagicMock, patch
        env = MagicMock()
        env.config.extra.is_hold = False
        env.data_proxy.get_previous_trading_date.return_value = datetime(2020, 1, 1)
        env.calendar_dt = datetime(2020, 1, 1)
        env.trading_dt = datetime(2020, 1, 1)
        executor = Executor(env)
        executor._last_before_trading = date(2020, 1, 1)

        def capture_publish(e):
            return False

        env.event_bus.publish_event = capture_publish
        event = Event(EVENT.BAR, calendar_dt=datetime(2020, 1, 2),
                      trading_dt=datetime(2020, 1, 2))

        with patch.object(executor, '_split_and_publish') as mock_split:
            executor._ensure_before_trading(event)
            settlement_calls = [c for c in mock_split.call_args_list
                                if c[0][0].event_type == EVENT.SETTLEMENT]
            assert len(settlement_calls) > 0, "Should publish SETTLEMENT between days"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
