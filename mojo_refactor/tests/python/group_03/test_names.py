# -*- coding: utf-8 -*-
"""
Test for rqalpha/apis/names.py
Tests for API names constants
"""

import pytest


class TestValidHistoryFields:
    """Tests for VALID_HISTORY_FIELDS constant"""

    def test_valid_history_fields_exists(self):
        """Test that VALID_HISTORY_FIELDS exists"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert VALID_HISTORY_FIELDS is not None

    def test_valid_history_fields_is_list(self):
        """Test that VALID_HISTORY_FIELDS is a list"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert isinstance(VALID_HISTORY_FIELDS, list)

    def test_valid_history_fields_count(self):
        """Test that VALID_HISTORY_FIELDS has correct number of items"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert len(VALID_HISTORY_FIELDS) == 16

    def test_valid_history_fields_contains_datetime(self):
        """Test that VALID_HISTORY_FIELDS contains 'datetime'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "datetime" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_open(self):
        """Test that VALID_HISTORY_FIELDS contains 'open'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "open" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_close(self):
        """Test that VALID_HISTORY_FIELDS contains 'close'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "close" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_high(self):
        """Test that VALID_HISTORY_FIELDS contains 'high'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "high" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_low(self):
        """Test that VALID_HISTORY_FIELDS contains 'low'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "low" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_volume(self):
        """Test that VALID_HISTORY_FIELDS contains 'volume'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "volume" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_limit_up(self):
        """Test that VALID_HISTORY_FIELDS contains 'limit_up'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "limit_up" in VALID_HISTORY_FIELDS

    def test_valid_history_fields_contains_limit_down(self):
        """Test that VALID_HISTORY_FIELDS contains 'limit_down'"""
        from rqalpha.apis.names import VALID_HISTORY_FIELDS
        assert "limit_down" in VALID_HISTORY_FIELDS


class TestValidTenors:
    """Tests for VALID_TENORS constant"""

    def test_valid_tenors_exists(self):
        """Test that VALID_TENORS exists"""
        from rqalpha.apis.names import VALID_TENORS
        assert VALID_TENORS is not None

    def test_valid_tenors_is_list(self):
        """Test that VALID_TENORS is a list"""
        from rqalpha.apis.names import VALID_TENORS
        assert isinstance(VALID_TENORS, list)

    def test_valid_tenors_count(self):
        """Test that VALID_TENORS has correct number of items"""
        from rqalpha.apis.names import VALID_TENORS
        assert len(VALID_TENORS) == 21

    def test_valid_tenors_contains_0s(self):
        """Test that VALID_TENORS contains '0S'"""
        from rqalpha.apis.names import VALID_TENORS
        assert "0S" in VALID_TENORS

    def test_valid_tenors_contains_1m(self):
        """Test that VALID_TENORS contains '1M'"""
        from rqalpha.apis.names import VALID_TENORS
        assert "1M" in VALID_TENORS

    def test_valid_tenors_contains_1y(self):
        """Test that VALID_TENORS contains '1Y'"""
        from rqalpha.apis.names import VALID_TENORS
        assert "1Y" in VALID_TENORS

    def test_valid_tenors_contains_10y(self):
        """Test that VALID_TENORS contains '10Y'"""
        from rqalpha.apis.names import VALID_TENORS
        assert "10Y" in VALID_TENORS

    def test_valid_tenors_contains_50y(self):
        """Test that VALID_TENORS contains '50Y'"""
        from rqalpha.apis.names import VALID_TENORS
        assert "50Y" in VALID_TENORS


class TestValidInstrumentTypes:
    """Tests for VALID_INSTRUMENT_TYPES constant"""

    def test_valid_instrument_types_exists(self):
        """Test that VALID_INSTRUMENT_TYPES exists"""
        from rqalpha.apis.names import VALID_INSTRUMENT_TYPES
        assert VALID_INSTRUMENT_TYPES is not None

    def test_valid_instrument_types_is_list(self):
        """Test that VALID_INSTRUMENT_TYPES is a list"""
        from rqalpha.apis.names import VALID_INSTRUMENT_TYPES
        assert isinstance(VALID_INSTRUMENT_TYPES, list)

    def test_valid_instrument_types_contains_fund(self):
        """Test that VALID_INSTRUMENT_TYPES contains 'Fund'"""
        from rqalpha.apis.names import VALID_INSTRUMENT_TYPES
        assert "Fund" in VALID_INSTRUMENT_TYPES

    def test_valid_instrument_types_contains_stock(self):
        """Test that VALID_INSTRUMENT_TYPES contains 'Stock'"""
        from rqalpha.apis.names import VALID_INSTRUMENT_TYPES
        assert "Stock" in VALID_INSTRUMENT_TYPES

    def test_valid_instrument_types_includes_instrument_type(self):
        """Test that VALID_INSTRUMENT_TYPES includes INSTRUMENT_TYPE values"""
        from rqalpha.apis.names import VALID_INSTRUMENT_TYPES
        from rqalpha.const import INSTRUMENT_TYPE
        for it in INSTRUMENT_TYPE:
            assert it in VALID_INSTRUMENT_TYPES


class TestValidMarginFields:
    """Tests for VALID_MARGIN_FIELDS constant"""

    def test_valid_margin_fields_exists(self):
        """Test that VALID_MARGIN_FIELDS exists"""
        from rqalpha.apis.names import VALID_MARGIN_FIELDS
        assert VALID_MARGIN_FIELDS is not None

    def test_valid_margin_fields_is_list(self):
        """Test that VALID_MARGIN_FIELDS is a list"""
        from rqalpha.apis.names import VALID_MARGIN_FIELDS
        assert isinstance(VALID_MARGIN_FIELDS, list)

    def test_valid_margin_fields_count(self):
        """Test that VALID_MARGIN_FIELDS has correct number of items"""
        from rqalpha.apis.names import VALID_MARGIN_FIELDS
        assert len(VALID_MARGIN_FIELDS) == 8

    def test_valid_margin_fields_contains_margin_balance(self):
        """Test that VALID_MARGIN_FIELDS contains 'margin_balance'"""
        from rqalpha.apis.names import VALID_MARGIN_FIELDS
        assert "margin_balance" in VALID_MARGIN_FIELDS

    def test_valid_margin_fields_contains_total_balance(self):
        """Test that VALID_MARGIN_FIELDS contains 'total_balance'"""
        from rqalpha.apis.names import VALID_MARGIN_FIELDS
        assert "total_balance" in VALID_MARGIN_FIELDS


class TestValidShareFields:
    """Tests for VALID_SHARE_FIELDS constant"""

    def test_valid_share_fields_exists(self):
        """Test that VALID_SHARE_FIELDS exists"""
        from rqalpha.apis.names import VALID_SHARE_FIELDS
        assert VALID_SHARE_FIELDS is not None

    def test_valid_share_fields_is_list(self):
        """Test that VALID_SHARE_FIELDS is a list"""
        from rqalpha.apis.names import VALID_SHARE_FIELDS
        assert isinstance(VALID_SHARE_FIELDS, list)

    def test_valid_share_fields_count(self):
        """Test that VALID_SHARE_FIELDS has correct number of items"""
        from rqalpha.apis.names import VALID_SHARE_FIELDS
        assert len(VALID_SHARE_FIELDS) == 5

    def test_valid_share_fields_contains_total(self):
        """Test that VALID_SHARE_FIELDS contains 'total'"""
        from rqalpha.apis.names import VALID_SHARE_FIELDS
        assert "total" in VALID_SHARE_FIELDS

    def test_valid_share_fields_contains_total_a(self):
        """Test that VALID_SHARE_FIELDS contains 'total_a'"""
        from rqalpha.apis.names import VALID_SHARE_FIELDS
        assert "total_a" in VALID_SHARE_FIELDS


class TestValidTurnoverFields:
    """Tests for VALID_TURNOVER_FIELDS constant"""

    def test_valid_turnover_fields_exists(self):
        """Test that VALID_TURNOVER_FIELDS exists"""
        from rqalpha.apis.names import VALID_TURNOVER_FIELDS
        assert VALID_TURNOVER_FIELDS is not None

    def test_valid_turnover_fields_is_tuple(self):
        """Test that VALID_TURNOVER_FIELDS is a tuple"""
        from rqalpha.apis.names import VALID_TURNOVER_FIELDS
        assert isinstance(VALID_TURNOVER_FIELDS, tuple)

    def test_valid_turnover_fields_count(self):
        """Test that VALID_TURNOVER_FIELDS has correct number of items"""
        from rqalpha.apis.names import VALID_TURNOVER_FIELDS
        assert len(VALID_TURNOVER_FIELDS) == 8

    def test_valid_turnover_fields_contains_today(self):
        """Test that VALID_TURNOVER_FIELDS contains 'today'"""
        from rqalpha.apis.names import VALID_TURNOVER_FIELDS
        assert "today" in VALID_TURNOVER_FIELDS

    def test_valid_turnover_fields_contains_total(self):
        """Test that VALID_TURNOVER_FIELDS contains 'total'"""
        from rqalpha.apis.names import VALID_TURNOVER_FIELDS
        assert "total" in VALID_TURNOVER_FIELDS


class TestValidStockConnectFields:
    """Tests for VALID_STOCK_CONNECT_FIELDS constant"""

    def test_valid_stock_connect_fields_exists(self):
        """Test that VALID_STOCK_CONNECT_FIELDS exists"""
        from rqalpha.apis.names import VALID_STOCK_CONNECT_FIELDS
        assert VALID_STOCK_CONNECT_FIELDS is not None

    def test_valid_stock_connect_fields_is_list(self):
        """Test that VALID_STOCK_CONNECT_FIELDS is a list"""
        from rqalpha.apis.names import VALID_STOCK_CONNECT_FIELDS
        assert isinstance(VALID_STOCK_CONNECT_FIELDS, list)

    def test_valid_stock_connect_fields_count(self):
        """Test that VALID_STOCK_CONNECT_FIELDS has correct number of items"""
        from rqalpha.apis.names import VALID_STOCK_CONNECT_FIELDS
        assert len(VALID_STOCK_CONNECT_FIELDS) == 2

    def test_valid_stock_connect_fields_contains_shares_holding(self):
        """Test that VALID_STOCK_CONNECT_FIELDS contains 'shares_holding'"""
        from rqalpha.apis.names import VALID_STOCK_CONNECT_FIELDS
        assert "shares_holding" in VALID_STOCK_CONNECT_FIELDS

    def test_valid_stock_connect_fields_contains_holding_ratio(self):
        """Test that VALID_STOCK_CONNECT_FIELDS contains 'holding_ratio'"""
        from rqalpha.apis.names import VALID_STOCK_CONNECT_FIELDS
        assert "holding_ratio" in VALID_STOCK_CONNECT_FIELDS


class TestValidCurrentPerformanceFields:
    """Tests for VALID_CURRENT_PERFORMANCE_FIELDS constant"""

    def test_valid_current_performance_fields_exists(self):
        """Test that VALID_CURRENT_PERFORMANCE_FIELDS exists"""
        from rqalpha.apis.names import VALID_CURRENT_PERFORMANCE_FIELDS
        assert VALID_CURRENT_PERFORMANCE_FIELDS is not None

    def test_valid_current_performance_fields_is_list(self):
        """Test that VALID_CURRENT_PERFORMANCE_FIELDS is a list"""
        from rqalpha.apis.names import VALID_CURRENT_PERFORMANCE_FIELDS
        assert isinstance(VALID_CURRENT_PERFORMANCE_FIELDS, list)

    def test_valid_current_performance_fields_count(self):
        """Test that VALID_CURRENT_PERFORMANCE_FIELDS has correct number of items"""
        from rqalpha.apis.names import VALID_CURRENT_PERFORMANCE_FIELDS
        assert len(VALID_CURRENT_PERFORMANCE_FIELDS) == 39

    def test_valid_current_performance_fields_contains_operating_revenue(self):
        """Test that VALID_CURRENT_PERFORMANCE_FIELDS contains 'operating_revenue'"""
        from rqalpha.apis.names import VALID_CURRENT_PERFORMANCE_FIELDS
        assert "operating_revenue" in VALID_CURRENT_PERFORMANCE_FIELDS

    def test_valid_current_performance_fields_contains_basic_eps(self):
        """Test that VALID_CURRENT_PERFORMANCE_FIELDS contains 'basic_eps'"""
        from rqalpha.apis.names import VALID_CURRENT_PERFORMANCE_FIELDS
        assert "basic_eps" in VALID_CURRENT_PERFORMANCE_FIELDS


class TestModuleImports:
    """Tests for module imports"""

    def test_import_from_const(self):
        """Test that INSTRUMENT_TYPE is imported from const"""
        from rqalpha.apis.names import INSTRUMENT_TYPE
        from rqalpha.const import INSTRUMENT_TYPE as ConstInstrumentType
        assert INSTRUMENT_TYPE == ConstInstrumentType
