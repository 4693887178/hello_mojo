"""
Test for rqalpha/utils/risk_free_helper.py
Group 02 - File 6
Tests for risk free rate helper functions
"""
import pytest
from rqalpha.utils.risk_free_helper import (
    YIELD_CURVE_TENORS, YIELD_CURVE_DURATION,
    get_tenor_for, get_tenors_for
)
from datetime import date


class TestYieldCurveTenors:
    def test_tenors_dict(self):
        assert isinstance(YIELD_CURVE_TENORS, dict)
        assert YIELD_CURVE_TENORS[0] == '0S'
        assert YIELD_CURVE_TENORS[30] == '1M'
        assert YIELD_CURVE_TENORS[365] == '1Y'
        assert YIELD_CURVE_TENORS[365 * 10] == '10Y'

    def test_tenors_count(self):
        assert len(YIELD_CURVE_TENORS) == 21


class TestYieldCurveDuration:
    def test_duration_list(self):
        assert isinstance(YIELD_CURVE_DURATION, list)
        assert 0 in YIELD_CURVE_DURATION
        assert 30 in YIELD_CURVE_DURATION
        assert 365 in YIELD_CURVE_DURATION

    def test_duration_sorted(self):
        assert YIELD_CURVE_DURATION == sorted(YIELD_CURVE_DURATION)

    def test_duration_count(self):
        assert len(YIELD_CURVE_DURATION) == 21


class TestGetTenorFor:
    def test_one_year(self):
        start = date(2020, 1, 1)
        end = date(2021, 1, 1)
        tenor = get_tenor_for(start, end)
        assert tenor == '1Y'

    def test_short_period(self):
        start = date(2020, 1, 1)
        end = date(2020, 2, 1)
        tenor = get_tenor_for(start, end)
        assert tenor == '1M'

    def test_long_period(self):
        start = date(2020, 1, 1)
        end = date(2030, 1, 1)
        tenor = get_tenor_for(start, end)
        assert tenor == '10Y'

    def test_zero_days(self):
        start = date(2020, 1, 1)
        end = date(2020, 1, 1)
        tenor = get_tenor_for(start, end)
        assert tenor == '0S'


class TestGetTenorsFor:
    def test_one_year(self):
        start = date(2020, 1, 1)
        end = date(2021, 1, 1)
        tenors = get_tenors_for(start, end)
        assert isinstance(tenors, list)
        assert '0S' in tenors
        assert '1M' in tenors
        assert '1Y' in tenors

    def test_short_period(self):
        start = date(2020, 1, 1)
        end = date(2020, 2, 1)
        tenors = get_tenors_for(start, end)
        assert isinstance(tenors, list)
        assert '0S' in tenors
        assert '1M' in tenors


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
