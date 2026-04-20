# -*- coding: utf-8 -*-
"""
Test for core/strategy.py (Python original)
Group 09 - File 9

Comprehensive tests covering:
- Strategy class existence and structure
- Strategy.__init__ with event_bus, scope, ucontext
- Strategy lifecycle methods (init, before_trading, handle_bar, etc.)
- run_when_strategy_not_hold decorator behavior
- wrap_user_event_handler method
- Event registration on event_bus
- User context property
"""

import pytest
from unittest.mock import Mock, patch, MagicMock, PropertyMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestStrategyClass:
    """Test Strategy class basic existence and attributes."""

    def test_strategy_class_exists(self):
        from rqalpha.core.strategy import Strategy
        assert Strategy is not None

    def test_strategy_has_init_method(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'init')

    def test_strategy_has_handle_bar_method(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'handle_bar')

    def test_strategy_has_before_trading_method(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'before_trading')

    def test_strategy_has_after_trading_method(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'after_trading')

    def test_strategy_has_handle_tick_method(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'handle_tick')

    def test_strategy_has_open_auction_method(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'open_auction')

    def test_strategy_has_wrap_user_event_handler(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'wrap_user_event_handler')

    def test_strategy_has_user_context_property(self):
        from rqalpha.core.strategy import Strategy
        assert hasattr(Strategy, 'user_context')


class TestStrategyInit:
    """Test Strategy.__init__ behavior."""

    def test_init_stores_user_context(self):
        """Strategy stores the user_context passed in."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._user_context is ucontext

    def test_init_stores_empty_universe(self):
        """Strategy initializes with empty universe set."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)
        assert isinstance(strategy._current_universe, set)
        assert len(strategy._current_universe) == 0

    def test_init_extracts_init_from_scope(self):
        """Strategy extracts init function from scope dict."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()

        def my_init(ctx):
            pass

        scope = {'init': my_init}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._init is my_init

    def test_init_extracts_handle_bar_from_scope(self):
        """Strategy extracts handle_bar function from scope."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()

        def my_handle_bar(ctx, bar):
            pass

        scope = {'handle_bar': my_handle_bar}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._handle_bar is my_handle_bar

    def test_init_extracts_handle_tick_from_scope(self):
        """Strategy extracts handle_tick function from scope."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()

        def my_handle_tick(ctx, tick):
            pass

        scope = {'handle_tick': my_handle_tick}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._handle_tick is my_handle_tick

    def test_init_extracts_after_trading_from_scope(self):
        """Strategy extracts after_trading function from scope."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()

        def my_after_trading(ctx):
            pass

        scope = {'after_trading': my_after_trading}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._after_trading is my_after_trading

    def test_init_extracts_open_auction_from_scope(self):
        """Strategy extracts open_auction function from scope."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()

        def my_open_auction(ctx, bar):
            pass

        scope = {'open_auction': my_open_auction}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._open_auction is my_open_auction

    def test_init_none_for_missing_handlers(self):
        """Strategy sets None for missing handler functions in scope."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy._init is None
        assert strategy._handle_bar is None
        assert strategy._handle_tick is None
        assert strategy._before_trading is None
        assert strategy._after_trading is None
        assert strategy._open_auction is None


class TestStrategyEventRegistration:
    """Test that Strategy registers events on event_bus during __init__."""

    def test_registers_before_trading_when_present(self):
        """Registers BEFORE_TRADING listener when before_trading func exists."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, EVENT
        event_bus = EventBus()
        ucontext = Mock()

        def my_before_trading(ctx):
            pass

        scope = {'before_trading': my_before_trading}
        strategy = Strategy(event_bus, scope, ucontext)
        listeners = event_bus._listeners.get(EVENT.BEFORE_TRADING, [])
        assert len(listeners) > 0

    def test_registers_bar_when_present(self):
        """Registers BAR listener when handle_bar func exists."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, EVENT
        event_bus = EventBus()
        ucontext = Mock()

        def my_handle_bar(ctx, bar):
            pass

        scope = {'handle_bar': my_handle_bar}
        strategy = Strategy(event_bus, scope, ucontext)
        listeners = event_bus._listeners.get(EVENT.BAR, [])
        assert len(listeners) > 0

    def test_registers_tick_when_present(self):
        """Registers TICK listener when handle_tick func exists."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, EVENT
        event_bus = EventBus()
        ucontext = Mock()

        def my_handle_tick(ctx, tick):
            pass

        scope = {'handle_tick': my_handle_tick}
        strategy = Strategy(event_bus, scope, ucontext)
        listeners = event_bus._listeners.get(EVENT.TICK, [])
        assert len(listeners) > 0

    def test_registers_after_trading_when_present(self):
        """Registers AFTER_TRADING listener when after_trading func exists."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, EVENT
        event_bus = EventBus()
        ucontext = Mock()

        def my_after_trading(ctx):
            pass

        scope = {'after_trading': my_after_trading}
        strategy = Strategy(event_bus, scope, ucontext)
        listeners = event_bus._listeners.get(EVENT.AFTER_TRADING, [])
        assert len(listeners) > 0

    def test_registers_open_auction_when_present(self):
        """Registers OPEN_AUCTION listener when open_auction func exists."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, EVENT
        event_bus = EventBus()
        ucontext = Mock()

        def my_open_auction(ctx, bar):
            pass

        scope = {'open_auction': my_open_auction}
        strategy = Strategy(event_bus, scope, ucontext)
        listeners = event_bus._listeners.get(EVENT.OPEN_AUCTION, [])
        assert len(listeners) > 0

    def test_no_registration_when_handler_missing(self):
        """Does not register event listener when handler is None."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, EVENT
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)
        assert EVENT.BEFORE_TRADING not in event_bus._listeners
        assert EVENT.BAR not in event_bus._listeners


class TestStrategyUserContext:
    """Test user_context property."""

    def test_user_context_returns_stored_context(self):
        """user_context property returns the stored _user_context."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)
        assert strategy.user_context is ucontext


class TestRunWhenStrategyNotHold:
    """Test run_when_strategy_not_hold decorator."""

    def test_executes_when_not_hold(self):
        """Decorator executes function when is_hold is False."""
        from rqalpha.core.strategy import run_when_strategy_not_hold
        from unittest.mock import patch

        called = []

        @run_when_strategy_not_hold
        def my_func(*args, **kwargs):
            called.append(True)

        with patch('rqalpha.core.strategy.Environment') as MockEnv:
            mock_instance = MockEnv.get_instance.return_value
            mock_instance.config.extra.is_hold = False
            result = my_func("arg1", key="val")
            assert len(called) == 1

    def test_skips_when_is_hold_true(self):
        """Decorator skips execution when is_hold is True (returns None)."""
        from rqalpha.core.strategy import run_when_strategy_not_hold
        from unittest.mock import patch

        called = []

        @run_when_strategy_not_hold
        def my_func(*args, **kwargs):
            called.append(True)
            return "should_not_happen"

        with patch('rqalpha.core.strategy.Environment') as MockEnv:
            mock_instance = MockEnv.get_instance.return_value
            mock_instance.config.extra.is_hold = True
            result = my_func("arg1", key="val")
            assert len(called) == 0
            assert result is None


class TestWrapUserEventHandler:
    """Test wrap_user_event_handler method."""

    def test_wrap_returns_callable(self):
        """wrap_user_event_handler returns a callable wrapper."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)

        def my_handler(context, event):
            return "result"

        wrapped = strategy.wrap_user_event_handler(my_handler)
        assert callable(wrapped)

    def test_wrapped_calls_with_user_context(self):
        """Wrapped handler calls original with user_context as first arg."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, Event, EVENT
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)

        received_ctx = []
        received_evt = []

        def my_handler(context, event):
            received_ctx.append(context)
            received_evt.append(event)
            return "ok"

        wrapped = strategy.wrap_user_event_handler(my_handler)
        test_event = Event(EVENT.BAR)
        result = wrapped(test_event)
        assert len(received_ctx) == 1
        assert received_ctx[0] is ucontext
        assert len(received_evt) == 1
        assert result == "ok"


class TestStrategyInitMethod:
    """Test Strategy.init() lifecycle method."""

    def test_init_calls_user_init_if_exists(self):
        """Strategy.init() calls user's init function if defined."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, Event, EVENT
        event_bus = EventBus()
        ucontext = Mock()
        called = []

        def my_init(ctx):
            called.append(ctx)

        scope = {'init': my_init}
        strategy = Strategy(event_bus, scope, ucontext)

        with patch('rqalpha.core.strategy.Environment') as MockEnv:
            mock_instance = MockEnv.get_instance.return_value
            mock_instance.event_bus.publish_event = Mock()
            strategy.init()
            assert len(called) == 1
            assert called[0] is ucontext

    def test_init_publishes_post_user_init(self):
        """Strategy.init() publishes POST_USER_INIT event after calling init."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus, Event, EVENT
        event_bus = EventBus()
        ucontext = Mock()

        def my_init(ctx):
            pass

        scope = {'init': my_init}
        strategy = Strategy(event_bus, scope, ucontext)

        with patch('rqalpha.core.strategy.Environment') as MockEnv:
            mock_instance = MockEnv.get_instance.return_value
            strategy.init()
            mock_instance.event_bus.publish_event.assert_called_once()
            call_args = mock_instance.event_bus.publish_event.call_args
            published_event = call_args[0][0]
            assert published_event.event_type == EVENT.POST_USER_INIT

    def test_init_no_error_when_no_user_init(self):
        """Strategy.init() does not error when no init function defined."""
        from rqalpha.core.strategy import Strategy
        from rqalpha.core.events import EventBus
        event_bus = EventBus()
        ucontext = Mock()
        scope = {}
        strategy = Strategy(event_bus, scope, ucontext)

        with patch('rqalpha.core.strategy.Environment') as MockEnv:
            mock_instance = MockEnv.get_instance.return_value
            mock_instance.event_bus.publish_event = Mock()
            strategy.init()
            mock_instance.event_bus.publish_event.assert_called_once()


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
