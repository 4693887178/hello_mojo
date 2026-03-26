"""
Test for rqalpha/data/base_data_source/adjust.py
Group 02 - File 10
Tests for data adjustment functions
"""
import pytest
import numpy as np
from datetime import date


class TestAdjustModule:
    def test_module_imports(self):
        """Test that adjust module can be imported"""
        from rqalpha.data.base_data_source import adjust
        assert adjust is not None

    def test_price_fields(self):
        """Test PRICE_FIELDS constant"""
        from rqalpha.data.base_data_source.adjust import PRICE_FIELDS
        assert 'open' in PRICE_FIELDS
        assert 'close' in PRICE_FIELDS
        assert 'high' in PRICE_FIELDS
        assert 'low' in PRICE_FIELDS

    def test_fields_require_adjustment(self):
        """Test FIELDS_REQUIRE_ADJUSTMENT constant"""
        from rqalpha.data.base_data_source.adjust import FIELDS_REQUIRE_ADJUSTMENT
        assert 'open' in FIELDS_REQUIRE_ADJUSTMENT
        assert 'close' in FIELDS_REQUIRE_ADJUSTMENT
        assert 'volume' in FIELDS_REQUIRE_ADJUSTMENT


class TestFactorForDate:
    def test_factor_for_date_basic(self):
        """Test _factor_for_date function"""
        from rqalpha.data.base_data_source.adjust import _factor_for_date
        
        dates = np.array([20200101, 20210101, 20220101], dtype=np.uint64)
        factors = np.array([1.0, 1.1, 1.2], dtype=np.float64)
        
        result = _factor_for_date(dates, factors, 20200601)
        assert result == 1.0
        
        result = _factor_for_date(dates, factors, 20210601)
        assert result == 1.1
        
        result = _factor_for_date(dates, factors, 20220601)
        assert result == 1.2


class TestAdjustBars:
    def test_adjust_bars_none_factors(self):
        """Test adjust_bars with None factors"""
        from rqalpha.data.base_data_source.adjust import adjust_bars
        
        bars = np.array([(20200101, 10.0, 10.5)], 
                       dtype=[('datetime', 'uint64'), ('open', 'f8'), ('close', 'f8')])
        result = adjust_bars(bars, None, 'open', 'pre', date(2020, 1, 1))
        assert result is bars

    def test_adjust_bars_empty(self):
        """Test adjust_bars with empty bars"""
        from rqalpha.data.base_data_source.adjust import adjust_bars
        
        bars = np.array([], dtype=[('datetime', 'uint64'), ('open', 'f8'), ('close', 'f8')])
        ex_factors = np.array([(20200101, 1.0)], 
                             dtype=[('start_date', 'uint64'), ('ex_cum_factor', 'f8')])
        result = adjust_bars(bars, ex_factors, 'open', 'pre', date(2020, 1, 1))
        assert len(result) == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
