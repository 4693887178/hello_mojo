"""
Test suite for RQAlpha matcher.py (Python original)
Validates matcher module implementation matches expected behavior.
Tests are based on actual Python original from:
  rqalpha/mod/rqalpha_mod_sys_simulation/matcher.py
"""

import pytest
import sys
from types import SimpleNamespace

sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

from rqalpha.mod.rqalpha_mod_sys_simulation.matcher import (
    _price_reaches_limit,
    AbstractMatcher,
    DefaultBarMatcher,
    DefaultTickMatcher,
    CounterPartyOfferMatcher,
    LIMIT_PRICE_VALID_THRESHOLD,
)


class MockPriceBoard:
    """Mock AbstractPriceBoard for testing _price_reaches_limit."""
    def __init__(self, limit_up=10.0, limit_down=8.0):
        self._limit_up = limit_up
        self._limit_down = limit_down

    def get_limit_up(self, order_book_id):
        return self._limit_up

    def get_limit_down(self, order_book_id):
        return self._limit_down


class TestPriceReachesLimit:
    """Test _price_reaches_limit utility function."""

    def test_buy_at_limit_up(self):
        """BUY order at limit_up should reach limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=9.0)
        assert _price_reaches_limit("000001.XSHE", "BUY", 10.0, pb) == True

    def test_buy_above_limit_up(self):
        """BUY order above limit_up should reach limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=9.0)
        assert _price_reaches_limit("000001.XSHE", "BUY", 11.0, pb) == True

    def test_buy_below_limit_up(self):
        """BUY order below limit_up should not reach limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=9.0)
        assert _price_reaches_limit("000001.XSHE", "BUY", 9.5, pb) == False

    def test_sell_at_limit_down(self):
        """SELL order at limit_down should reach limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=8.0)
        assert _price_reaches_limit("000001.XSHE", "SELL", 8.0, pb) == True

    def test_sell_below_limit_down(self):
        """SELL order below limit_down should reach limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=8.0)
        assert _price_reaches_limit("000001.XSHE", "SELL", 7.5, pb) == True

    def test_sell_above_limit_down(self):
        """SELL order above limit_down should not reach limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=8.0)
        assert _price_reaches_limit("000001.XSHE", "SELL", 8.5, pb) == False

    def test_threshold_tolerance(self):
        """Values within threshold of limit should still be treated as reaching limit."""
        pb = MockPriceBoard(limit_up=10.0, limit_down=9.0)
        assert _price_reaches_limit(
            "000001.XSHE", "BUY",
            10.0 + LIMIT_PRICE_VALID_THRESHOLD * 0.5, pb
        ) == True


class TestAbstractMatcher:
    """Test AbstractMatcher base class."""

    def test_can_instantiate(self):
        """AbstractMatcher can be instantiated (no ABC)."""
        am = AbstractMatcher()
        assert am is not None

    def test_has_match_method(self):
        """AbstractMatcher defines match() method."""
        assert hasattr(AbstractMatcher, 'match')

    def test_has_update_method(self):
        """AbstractMatcher defines update() method."""
        assert hasattr(AbstractMatcher, 'update')


def _create_mock_env_and_config():
    """Helper to create mock env and mod_config as attribute-accessible objects."""
    mock_env = SimpleNamespace(
        config=SimpleNamespace(
            base=SimpleNamespace(matching_type=None)
        ),
        data_proxy=SimpleNamespace(get_bar=lambda *a, **kw: SimpleNamespace(
            close=10.0, open=9.5, volume=10000
        )),
        bar_dict={},
        open_auction_bar_dict={},
        price_board=MockPriceBoard(limit_up=12.0, limit_down=8.0),
    )

    mod_config = SimpleNamespace(
        matching_type="CURRENT_BAR_CLOSE",
        slippage_model="PriceRatioSlippage",
        slippage=0.002,
        volume_percent=0.25,
        price_limit=True,
        inactive_limit=True,
        volume_limit=True,
    )
    return mock_env, mod_config


def _create_mock_tick_env_and_config():
    """Helper for tick matcher creation."""
    mock_event_bus = SimpleNamespace(
        add_listener=lambda *a, **kw: None,
        prepend_listener=lambda *a, **kw: None,
    )
    mock_env = SimpleNamespace(
        config=SimpleNamespace(
            base=SimpleNamespace(matching_type=None, liquidity_limit=False)
        ),
        data_proxy=SimpleNamespace(),
        bar_dict={},
        open_auction_bar_dict={},
        price_board=SimpleNamespace(
            get_last_prices=lambda x: {},
            get_ask1=lambda x: 0,
            get_bid1=lambda x: 0,
            get_limit_up=lambda x: 12.0,
            get_limit_down=lambda x: 8.0,
        ),
        event_bus=mock_event_bus,
    )

    mod_config = SimpleNamespace(
        matching_type="NEXT_TICK_LAST",
        slippage_model="PriceRatioSlippage",
        slippage=0.002,
        volume_percent=0.25,
        price_limit=True,
        volume_limit=True,
        liquidity_limit=False,
    )
    return mock_env, mod_config


class TestDefaultBarMatcher:
    """Test DefaultBarMatcher class."""

    def test_creation(self):
        """DefaultBarMatcher can be created with env and mod_config."""
        env, cfg = _create_mock_env_and_config()
        matcher = DefaultBarMatcher(env, cfg)
        assert matcher is not None

    def test_has_turnover_dict(self):
        """Matcher initializes turnover dict."""
        env, cfg = _create_mock_env_and_config()
        matcher = DefaultBarMatcher(env, cfg)
        assert hasattr(matcher, '_turnover')
        assert isinstance(matcher._turnover, dict)

    def test_has_slippage_decider(self):
        """Matcher has slippage decider."""
        env, cfg = _create_mock_env_and_config()
        matcher = DefaultBarMatcher(env, cfg)
        assert hasattr(matcher, '_slippage_decider')

    def test_update_clears_turnover(self):
        """update() clears the turnover dict."""
        env, cfg = _create_mock_env_and_config()
        matcher = DefaultBarMatcher(env, cfg)
        matcher._turnover['test'] = 100
        event = SimpleNamespace()
        matcher.update(event)
        assert len(matcher._turnover) == 0


class TestDefaultTickMatcher:
    """Test DefaultTickMatcher class."""

    def test_creation(self):
        """DefaultTickMatcher can be created with env and mod_config."""
        env, cfg = _create_mock_tick_env_and_config()
        matcher = DefaultTickMatcher(env, cfg)
        assert matcher is not None

    def test_has_tick_dicts(self):
        """Matcher initializes tick tracking dicts."""
        env, cfg = _create_mock_tick_env_and_config()
        matcher = DefaultTickMatcher(env, cfg)
        assert hasattr(matcher, '_last_tick')
        assert hasattr(matcher, '_cur_tick')
        assert hasattr(matcher, '_slippage_decider')

    def test_update_updates_tick_state(self):
        """update() updates last/cur tick volumes."""
        env, cfg = _create_mock_tick_env_and_config()
        matcher = DefaultTickMatcher(env, cfg)
        mock_tick = SimpleNamespace(volume=500)
        matcher._cur_tick['000001.XSHE'] = mock_tick
        event = SimpleNamespace(order_book_id='000001.XSHE', tick=SimpleNamespace(volume=600, order_book_id='000001.XSHE'))
        matcher.update(event)
        assert '000001.XSHE' in matcher._last_tick


class TestCounterPartyOfferMatcher:
    """Test CounterPartyOfferMatcher class."""

    def test_inherits_from_default_tick_matcher(self):
        """CounterPartyOfferMatcher inherits from DefaultTickMatcher."""
        assert issubclass(CounterPartyOfferMatcher, DefaultTickMatcher)

    def test_creation(self):
        """CounterPartyOfferMatcher can be created."""
        env, cfg = _create_mock_tick_env_and_config()
        matcher = CounterPartyOfferMatcher(env, cfg)
        assert matcher is not None

    def test_has_ask_bid_data_structures(self):
        """Matcher has ask/bid volume and price structures."""
        env, cfg = _create_mock_tick_env_and_config()
        matcher = CounterPartyOfferMatcher(env, cfg)
        assert hasattr(matcher, '_a_volume')
        assert hasattr(matcher, '_b_volume')
        assert hasattr(matcher, '_a_price')
        assert hasattr(matcher, '_b_price')


class TestMatcherHierarchy:
    """Test inheritance hierarchy consistency."""

    def test_all_matchers_have_match_and_update(self):
        """All concrete matchers implement match() and update()."""
        for cls in [DefaultBarMatcher, DefaultTickMatcher, CounterPartyOfferMatcher]:
            assert hasattr(cls, 'match'), f"{cls.__name__} missing match()"
            assert hasattr(cls, 'update'), f"{cls.__name__} missing update()"

    def test_all_matchers_use_slippage_decider(self):
        """All matchers use a slippage decider internally."""
        env, cfg = _create_mock_env_and_config()
        bar_m = DefaultBarMatcher(env, cfg)
        assert hasattr(bar_m, '_slippage_decider')


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
