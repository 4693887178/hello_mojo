# test_L00_08_risk_free_helper.py
# Module: rqalpha.utils.risk_free_helper
# Mojo: rqmojo.utils.risk_free_helper
# Level: L00 - Leaf module
# Dependencies: datetime

import pytest
from rqalpha.utils import risk_free_helper
from datetime import date


class TestL00RiskFreeHelper:
    """L00 - risk_free_helper module tests"""

    class TestYieldCurveTenors:
        """YIELD_CURVE_TENORS constant tests"""

        def test_tenors_dict_exists(self):
            """Test YIELD_CURVE_TENORS exists"""
            assert hasattr(risk_free_helper, 'YIELD_CURVE_TENORS')

        def test_tenors_dict_count(self):
            """Test YIELD_CURVE_TENORS has correct count"""
            assert len(risk_free_helper.YIELD_CURVE_TENORS) == 21

        def test_tenor_zero(self):
            """Test 0S tenor"""
            assert risk_free_helper.YIELD_CURVE_TENORS[0] == '0S'

        def test_tenor_one_month(self):
            """Test 1M tenor"""
            assert risk_free_helper.YIELD_CURVE_TENORS[30] == '1M'

        def test_tenor_one_year(self):
            """Test 1Y tenor"""
            assert risk_free_helper.YIELD_CURVE_TENORS[365] == '1Y'

        def test_tenor_ten_years(self):
            """Test 10Y tenor"""
            assert risk_free_helper.YIELD_CURVE_TENORS[3650] == '10Y'

    class TestYieldCurveDuration:
        """YIELD_CURVE_DURATION constant tests"""

        def test_duration_list_exists(self):
            """Test YIELD_CURVE_DURATION exists"""
            assert hasattr(risk_free_helper, 'YIELD_CURVE_DURATION')

        def test_duration_list_sorted(self):
            """Test YIELD_CURVE_DURATION is sorted"""
            durations = risk_free_helper.YIELD_CURVE_DURATION
            assert durations == sorted(durations)

        def test_duration_list_count(self):
            """Test YIELD_CURVE_DURATION has correct count"""
            assert len(risk_free_helper.YIELD_CURVE_DURATION) == 21

    class TestGetTenorFor:
        """get_tenor_for function tests"""

        def test_zero_days(self):
            """Test zero days returns 0S"""
            start = date(2024, 1, 1)
            end = date(2024, 1, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '0S'

        def test_one_month(self):
            """Test one month returns 1M"""
            start = date(2024, 1, 1)
            end = date(2024, 2, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '1M'

        def test_three_months(self):
            """Test three months returns 3M"""
            start = date(2024, 1, 1)
            end = date(2024, 4, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '3M'

        def test_one_year(self):
            """Test one year returns 1Y"""
            start = date(2024, 1, 1)
            end = date(2025, 1, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '1Y'

        def test_five_years(self):
            """Test five years returns 5Y"""
            start = date(2024, 1, 1)
            end = date(2029, 1, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '5Y'

        def test_ten_years(self):
            """Test ten years returns 10Y"""
            start = date(2024, 1, 1)
            end = date(2034, 1, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '10Y'

        def test_twenty_years(self):
            """Test twenty years returns 20Y"""
            start = date(2024, 1, 1)
            end = date(2044, 1, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert tenor == '20Y'

    class TestGetTenorsFor:
        """get_tenors_for function tests"""

        def test_zero_days(self):
            """Test zero days returns one tenor"""
            start = date(2024, 1, 1)
            end = date(2024, 1, 1)
            tenors = risk_free_helper.get_tenors_for(start, end)
            assert tenors == ['0S']

        def test_one_year(self):
            """Test one year returns correct tenors"""
            start = date(2024, 1, 1)
            end = date(2025, 1, 1)
            tenors = risk_free_helper.get_tenors_for(start, end)
            assert '0S' in tenors
            assert '1M' in tenors
            assert '1Y' in tenors
            assert '2Y' not in tenors

        def test_ten_years(self):
            """Test ten years returns correct tenors"""
            start = date(2024, 1, 1)
            end = date(2034, 1, 1)
            tenors = risk_free_helper.get_tenors_for(start, end)
            assert '0S' in tenors
            assert '1Y' in tenors
            assert '10Y' in tenors
            assert '15Y' not in tenors

    class TestMojoCompatibility:
        """Tests for Mojo compatibility"""

        def test_tenor_format_compatibility(self):
            """Test tenor format is compatible"""
            start = date(2024, 1, 1)
            end = date(2025, 1, 1)
            tenor = risk_free_helper.get_tenor_for(start, end)
            assert isinstance(tenor, str)
            assert len(tenor) <= 3

        def test_duration_calculation_compatibility(self):
            """Test duration calculation is compatible"""
            start = date(2024, 1, 1)
            end = date(2024, 1, 31)
            duration = (end - start).days
            assert duration == 30
