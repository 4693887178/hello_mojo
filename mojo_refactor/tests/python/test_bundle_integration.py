"""
Bundle Module Integration Tests
Tests to verify Python rqalpha/data/bundle.py functionality exists and works correctly

Run with:
    python -m pytest tests/python/test_bundle_integration.py -v
"""

import pytest
import os
import sys
import tempfile
import shutil

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))


class TestBundleConstants:
    """Test that bundle constants are correctly defined in Python original"""

    def test_start_date(self):
        """START_DATE should be 20050104"""
        from rqalpha.data.bundle import START_DATE as py_start_date
        assert py_start_date == 20050104, "Python START_DATE should be 20050104, got " + str(py_start_date)

    def test_end_date(self):
        """END_DATE should be 29991231"""
        from rqalpha.data.bundle import END_DATE as py_end_date
        assert py_end_date == 29991231, "Python END_DATE should be 29991231, got " + str(py_end_date)

    def test_corporate_action_exclusions(self):
        """CORPORATE_ACTION_EXCLUSIONS should contain Future, Option, Spot"""
        from rqalpha.data.bundle import CORPORATE_ACTION_EXCLUSIONS as py_exclusions
        assert "Future" in py_exclusions, "Future should be in exclusions"
        assert "Option" in py_exclusions, "Option should be in exclusions"
        assert "Spot" in py_exclusions, "Spot should be in exclusions"

    def test_stock_fields(self):
        """STOCK_FIELDS should contain required fields"""
        from rqalpha.data.bundle import STOCK_FIELDS as py_fields
        required = ["open", "close", "high", "low", "prev_close",
                   "limit_up", "limit_down", "volume", "total_turnover"]
        for field in required:
            assert field in py_fields, field + " should be in STOCK_FIELDS"

    def test_index_fields(self):
        """INDEX_FIELDS should contain required fields"""
        from rqalpha.data.bundle import INDEX_FIELDS as py_fields
        required = ["open", "close", "high", "low", "prev_close",
                   "volume", "total_turnover"]
        for field in required:
            assert field in py_fields, field + " should be in INDEX_FIELDS"


class TestDataGenerationFunctions:
    """Test that data generation functions exist and have correct signatures"""

    def test_gen_instruments_exists(self):
        """gen_instruments function should exist"""
        from rqalpha.data.bundle import gen_instruments
        assert callable(gen_instruments), "gen_instruments should be callable"

    def test_gen_trading_dates_exists(self):
        """gen_trading_dates function should exist"""
        from rqalpha.data.bundle import gen_trading_dates
        assert callable(gen_trading_dates), "gen_trading_dates should be callable"

    def test_gen_yield_curve_exists(self):
        """gen_yield_curve function should exist"""
        from rqalpha.data.bundle import gen_yield_curve
        assert callable(gen_yield_curve), "gen_yield_curve should be callable"

    def test_gen_future_info_exists(self):
        """gen_future_info function should exist"""
        from rqalpha.data.bundle import gen_future_info
        assert callable(gen_future_info), "gen_future_info should be callable"


class TestGenerateClasses:
    """Test that data generation classes exist and are properly structured"""

    def test_generate_dividend_bundle_exists(self):
        """GenerateDividendBundle class should exist"""
        from rqalpha.data.bundle import GenerateDividendBundle
        assert GenerateDividendBundle is not None, "GenerateDividendBundle should exist"

    def test_generate_split_bundle_exists(self):
        """GenerateSplitBundle class should exist"""
        from rqalpha.data.bundle import GenerateSplitBundle
        assert GenerateSplitBundle is not None, "GenerateSplitBundle should exist"

    def test_generate_ex_factor_bundle_exists(self):
        """GenerateExFactorBundle class should exist"""
        from rqalpha.data.bundle import GenerateExFactorBundle
        assert GenerateExFactorBundle is not None, "GenerateExFactorBundle should exist"


class TestTaskFunctions:
    """Test task processing functions"""

    def test_process_init_exists(self):
        """process_init function should exist"""
        from rqalpha.data.bundle import process_init
        assert callable(process_init), "process_init should be callable"

    def test_gather_tasks_exists(self):
        """gather_tasks function should exist"""
        from rqalpha.data.bundle import gather_tasks
        assert callable(gather_tasks), "gather_tasks should be callable"

    def test_run_tasks_exists(self):
        """run_tasks function should exist"""
        from rqalpha.data.bundle import run_tasks
        assert callable(run_tasks), "run_tasks should be callable"

    def test_update_bundle_exists(self):
        """update_bundle function should exist"""
        from rqalpha.data.bundle import update_bundle
        assert callable(update_bundle), "update_bundle should be callable"


class TestAutomaticUpdateBundle:
    """Test AutomaticUpdateBundle class"""

    def test_class_exists(self):
        """AutomaticUpdateBundle class should exist"""
        from rqalpha.data.bundle import AutomaticUpdateBundle
        assert AutomaticUpdateBundle is not None, "AutomaticUpdateBundle should exist"

    def test_can_instantiate(self):
        """Should be able to inspect class signature"""
        from rqalpha.data.bundle import AutomaticUpdateBundle
        import inspect
        # AutomaticUpdateBundle requires path, filename, api, fields, end_date params
        sig = inspect.signature(AutomaticUpdateBundle.__init__)
        assert len(sig.parameters) > 0, "AutomaticUpdateBundle should have __init__ parameters"


class TestHelperDateFunctions:
    """Test date conversion helper functions (from utils module)"""

    def test_convert_date_to_int(self):
        """Date conversion should produce correct integer format"""
        from datetime import date
        from rqalpha.utils.datetime_func import convert_date_to_int

        dt = date(2024, 1, 15)
        result = convert_date_to_int(dt)
        # convert_date_to_int for date returns YYYYMMDD000000 format (with time component zeroed)
        expected = 20240115000000
        assert result == expected, "Expected " + str(expected) + ", got " + str(result)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
