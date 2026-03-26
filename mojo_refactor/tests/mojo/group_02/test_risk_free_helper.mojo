"""
RQMojo Test for utils/risk_free_helper.mojo
Group 02 - File 6
Tests for risk free rate helper functions
"""

from std.collections import Dict, List
from rqmojo.utils.risk_free_helper import (
    get_yield_curve_tenors, get_yield_curve_duration,
    get_tenor_for, get_tenors_for
)
from rqmojo.utils.typing import DateTimeDate


def test_yield_curve_tenors() raises:
    print("Testing get_yield_curve_tenors...")
    
    var tenors = get_yield_curve_tenors()
    assert len(tenors) == 21
    assert tenors[0] == "0S"
    assert tenors[30] == "1M"
    assert tenors[365] == "1Y"
    assert tenors[3650] == "10Y"
    
    print("  get_yield_curve_tenors tests passed!")


def test_yield_curve_duration() raises:
    print("Testing get_yield_curve_duration...")
    
    var duration = get_yield_curve_duration()
    assert len(duration) == 21
    assert duration[0] == 0
    assert duration[1] == 30
    assert duration[6] == 365
    
    print("  get_yield_curve_duration tests passed!")


def test_get_tenor_for() raises:
    print("Testing get_tenor_for...")
    
    var start1 = DateTimeDate(2020, 1, 1)
    var end1 = DateTimeDate(2021, 1, 1)
    var tenor1 = get_tenor_for(start1, end1)
    assert tenor1 == "1Y"
    
    var start2 = DateTimeDate(2020, 1, 1)
    var end2 = DateTimeDate(2020, 2, 1)
    var tenor2 = get_tenor_for(start2, end2)
    assert tenor2 == "1M"
    
    var start3 = DateTimeDate(2020, 1, 1)
    var end3 = DateTimeDate(2030, 1, 1)
    var tenor3 = get_tenor_for(start3, end3)
    assert tenor3 == "10Y"
    
    var start4 = DateTimeDate(2020, 1, 1)
    var end4 = DateTimeDate(2020, 1, 1)
    var tenor4 = get_tenor_for(start4, end4)
    assert tenor4 == "0S"
    
    print("  get_tenor_for tests passed!")


def test_get_tenors_for() raises:
    print("Testing get_tenors_for...")
    
    var start1 = DateTimeDate(2020, 1, 1)
    var end1 = DateTimeDate(2021, 1, 1)
    var tenors1 = get_tenors_for(start1, end1)
    assert len(tenors1) > 0
    assert tenors1[0] == "0S"
    
    var start2 = DateTimeDate(2020, 1, 1)
    var end2 = DateTimeDate(2020, 2, 1)
    var tenors2 = get_tenors_for(start2, end2)
    assert len(tenors2) > 0
    
    print("  get_tenors_for tests passed!")


def main() raises:
    print("=" * 60)
    print("Testing utils/risk_free_helper.mojo")
    print("=" * 60)
    
    test_yield_curve_tenors()
    test_yield_curve_duration()
    test_get_tenor_for()
    test_get_tenors_for()
    
    print("=" * 60)
    print("All utils/risk_free_helper.mojo tests passed!")
    print("=" * 60)
