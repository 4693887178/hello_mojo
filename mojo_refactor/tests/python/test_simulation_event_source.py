"""
Test suite for RQAlpha simulation_event_source.py (Python original)
Validates event source implementation matches expected behavior.
Tests based on actual Python original from:
  rqalpha/mod/rqalpha_mod_sys_simulation/simulation_event_source.py
"""

import pytest
import sys
from datetime import date, time, datetime, timedelta
from types import SimpleNamespace

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.mod.rqalpha_mod_sys_simulation.simulation_event_source import (
    SimulationEventSource,
)


class MockDateWithToPyDatetime:
    """Mock date object that has to_pydatetime() like pandas Timestamp."""

    def __init__(self, d):
        self._date = d

    def to_pydatetime(self):
        return datetime(
            self._date.year, self._date.month, self._date.day,
            0, 0, 0
        )


class MockDataProxy:
    """Mock data proxy for testing."""

    def __init__(self, trading_dates=None):
        self._trading_dates = trading_dates or [
            date(2024, 1, 2),
            date(2024, 1, 3),
            date(2024, 1, 4),
            date(2024, 1, 5),
        ]

    def get_trading_dates(self, start_date, end_date):
        return [MockDateWithToPyDatetime(d) for d in self._trading_dates
                if start_date.date() <= d <= end_date.date()]

    def get_merge_ticks(self, universe, dt, last_dt=None):
        return []


class MockEnvironment:
    """Mock environment for testing."""

    def __init__(self):
        self.data_proxy = MockDataProxy()
        self.config = SimpleNamespace(
            base=SimpleNamespace(
                accounts={"STOCK": "stock"},
                matching_type="CURRENT_BAR_CLOSE",
            )
        )
        self.event_bus = SimpleNamespace(
            add_listener=lambda *a, **kw: None,
            prepend_listener=lambda *a, **kw: None,
        )
        self._universe = ["000001.XSHE"]

    def get_universe(self):
        return self._universe

    def get_account_type(self, order_book_id):
        return "STOCK"

    def get_instrument(self, order_book_id):
        return SimpleNamespace(type="CS")


class TestSimulationEventSourceCreation:
    """Test SimulationEventSource creation and initialization."""

    def test_can_create_with_env(self):
        """SimulationEventSource can be created with environment."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        assert source is not None

    def test_stores_env_reference(self):
        """Source stores reference to environment."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        assert source._env is env

    def test_stores_config_reference(self):
        """Source stores config from environment."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        assert source._config is env.config

    def test_universe_changed_initially_false(self):
        """Universe changed flag is initially False."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        assert source._universe_changed == False


class TestGetUniverse:
    """Test _get_universe method."""

    def test_returns_universe_when_non_empty(self):
        """Returns universe when it has items."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        result = source._get_universe()
        assert result == ["000001.XSHE"]

    def test_raises_when_empty_no_stock_account(self):
        """Raises error when universe is empty and no stock account."""
        env = MockEnvironment()
        env._universe = []
        env.config.base.accounts = {}  # No stock account
        source = SimulationEventSource(env)
        with pytest.raises(Exception, match="empty"):
            source._get_universe()


class TestDayBarDt:
    """Test _get_day_bar_dt method."""

    def test_returns_15_00_time(self):
        """Returns datetime set to 15:00."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        d = datetime(2024, 1, 15)  # Use datetime, not date
        result = source._get_day_bar_dt(d)
        assert result.hour == 15
        assert result.minute == 0

    def test_preserves_date(self):
        """Preserves the input date."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        d = datetime(2024, 6, 20)  # Use datetime, not date
        result = source._get_day_bar_dt(d)
        assert result.year == 2024
        assert result.month == 6
        assert result.day == 20


class TestAfterTradingDt:
    """Test _get_after_trading_dt method."""

    def test_returns_15_30_time(self):
        """Returns datetime set to 15:30."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        d = datetime(2024, 1, 15)  # Use datetime, not date
        result = source._get_after_trading_dt(d)
        assert result.hour == 15
        assert result.minute == 30


class TestStockTradingMinutes:
    """Test _get_stock_trading_minutes method."""

    def test_returns_set_of_datetimes(self):
        """Returns a set of trading minute datetimes."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        d = date(2024, 1, 15)
        minutes = source._get_stock_trading_minutes(d)
        assert isinstance(minutes, set)

    def test_has_correct_count(self):
        """Stock market has ~120 trading minutes (9:31-11:30 + 13:01-15:00)."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        d = date(2024, 1, 15)
        minutes = source._get_stock_trading_minutes(d)
        # AM: 9:31-11:30 = 120 min (9:31 to 11:30 inclusive)
        # PM: 13:01-15:00 = 120 min (13:01 to 15:00 inclusive)
        # Total should be around 240
        assert len(minutes) >= 200

    def test_starts_at_9_31(self):
        """First trading minute is at 9:31."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        d = date(2024, 1, 15)
        minutes = source._get_stock_trading_minutes(d)
        sorted_mins = sorted(minutes)
        first = sorted_mins[0]
        assert first.hour == 9
        assert first.minute == 31


class TestEventsDailyFrequency:
    """Test events() method with '1d' frequency."""

    def _make_source(self):
        env = MockEnvironment()
        return SimulationEventSource(env)

    def test_yields_events_for_each_trading_day(self):
        """Yields events for each trading day."""
        source = self._make_source()
        start = datetime(2024, 1, 1)
        end = datetime(2024, 1, 10)
        events_list = list(source.events(start, end, "1d"))
        # Should have 4 days x 4 events = 16 total
        assert len(events_list) == 16

    def test_daily_event_sequence(self):
        """Daily sequence: BEFORE_TRADING -> OPEN_AUCTION -> BAR -> AFTER_TRADING."""
        from rqalpha.core.events import EVENT
        source = self._make_source()
        start = datetime(2024, 1, 1)
        end = datetime(2024, 1, 3)
        events_list = list(source.events(start, end, "1d"))
        # Check first 4 events are correct sequence
        assert events_list[0].event_type == EVENT.BEFORE_TRADING
        assert events_list[1].event_type == EVENT.OPEN_AUCTION
        assert events_list[2].event_type == EVENT.BAR
        assert events_list[3].event_type == EVENT.AFTER_TRADING


class TestUniverseChangedCallback:
    """Test _on_universe_changed callback."""

    def test_sets_flag_to_true(self):
        """Callback sets universe_changed flag to True."""
        env = MockEnvironment()
        source = SimulationEventSource(env)
        assert source._universe_changed == False
        source._on_universe_changed(None)
        assert source._universe_changed == True


class TestInvalidFrequency:
    """Test invalid frequency handling."""

    def test_raises_on_invalid_frequency(self):
        """Raises NotImplementedError for unsupported frequency."""
        source = SimulationEventSource(MockEnvironment())
        start = datetime(2024, 1, 1)
        end = datetime(2024, 1, 3)
        with pytest.raises(NotImplementedError):
            list(source.events(start, end, "invalid_freq"))


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
