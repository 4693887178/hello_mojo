"""
RQAlpha Python - sys_simulation Module Integration Tests
Tests the original Python implementation - pure logic parts only.
Uses pytest framework.

Note: Many Python components require Environment.get_instance() which is only
available after full RQAlpha initialization. This test file focuses on
testable pure-logic components.
"""

import pytest
import sys
sys.path.insert(0, "/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages")

from rqalpha.mod.rqalpha_mod_sys_simulation.slippage import (
    PriceRatioSlippage,
    TickSizeSlippage,
    SlippageDecider,
)
from rqalpha.mod.rqalpha_mod_sys_simulation.mod import (
    SimulationMod,
)
from rqalpha.const import (
    MATCHING_TYPE, SIDE, ORDER_TYPE, POSITION_EFFECT,
)


# ==================== Slippage Tests (constructor only) ====================

class TestPriceRatioSlippage:
    def test_init_default_rate(self):
        s = PriceRatioSlippage()
        assert s.rate == 0.0

    def test_init_custom_rate(self):
        s = PriceRatioSlippage(0.01)
        assert s.rate == 0.01

    def test_invalid_rate_high_raises(self):
        with pytest.raises(Exception):
            PriceRatioSlippage(None, rate=1.0)

    def test_invalid_rate_negative_raises(self):
        with pytest.raises(Exception):
            PriceRatioSlippage(None, rate=-0.1)


class TestTickSizeSlippage:
    def test_init(self):
        s = TickSizeSlippage(0.001)
        assert s.rate == 0.001

    def test_invalid_rate_raises(self):
        with pytest.raises(Exception):
            TickSizeSlippage(None, rate=-0.01)


class TestSlippageDecider:
    def test_unknown_model_raises(self):
        with pytest.raises(RuntimeError, match="Missing SlippageModel"):
            SlippageDecider("UnknownModel", 0.0)


# ==================== Mod Tests (parse_matching_type is static) ====================

class TestSimulationMod:
    def test_init(self):
        mod = SimulationMod()
        assert mod._env is None

    def test_parse_current_bar(self):
        mt = SimulationMod.parse_matching_type("current_bar", "1d")
        assert mt == MATCHING_TYPE.CURRENT_BAR_CLOSE

    def test_parse_vwap(self):
        mt = SimulationMod.parse_matching_type("vwap", "1d")
        assert mt == MATCHING_TYPE.VWAP

    def test_parse_next_bar(self):
        mt = SimulationMod.parse_matching_type("next_bar", "1d")
        assert mt == MATCHING_TYPE.NEXT_BAR_OPEN

    def test_parse_last_tick(self):
        mt = SimulationMod.parse_matching_type("last", "tick")
        assert mt == MATCHING_TYPE.NEXT_TICK_LAST

    def test_parse_best_own(self):
        mt = SimulationMod.parse_matching_type("best_own", "tick")
        assert mt == MATCHING_TYPE.NEXT_TICK_BEST_OWN

    def test_parse_best_counterparty(self):
        mt = SimulationMod.parse_matching_type("best_counterparty", "tick")
        assert mt == MATCHING_TYPE.NEXT_TICK_BEST_COUNTERPARTY

    def test_parse_counterparty_offer(self):
        mt = SimulationMod.parse_matching_type("counterparty_offer", "tick")
        assert mt == MATCHING_TYPE.COUNTERPARTY_OFFER

    def test_parse_none_defaults_bar(self):
        mt = SimulationMod.parse_matching_type(None, "1d")
        assert mt == MATCHING_TYPE.CURRENT_BAR_CLOSE

    def test_parse_none_defaults_tick(self):
        mt = SimulationMod.parse_matching_type(None, "tick")
        assert mt == MATCHING_TYPE.NEXT_TICK_LAST

    def test_parse_empty_string_raises_not_implemented(self):
        with pytest.raises(NotImplementedError):
            SimulationMod.parse_matching_type("", "1d")

    def test_parse_invalid_type_raises(self):
        with pytest.raises((AssertionError, KeyError, RuntimeError)):
            SimulationMod.parse_matching_type("invalid_type", "1d")

    def test_tear_down(self):
        mod = SimulationMod()
        mod.tear_down(0)
