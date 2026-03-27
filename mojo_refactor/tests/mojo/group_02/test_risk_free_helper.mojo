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


from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_yield_curve_tenors() raises:
    print("Testing get_yield_curve_tenors...")
    
    var tenors = get_yield_curve_tenors()
    assert_equal(len(tenors), 21)
    assert_equal(tenors[0], "0S")
    assert_equal(tenors[30], "1M")
    assert_equal(tenors[365], "1Y")
    assert_equal(tenors[3650], "10Y")
    print("  get_yield_curve_tenors tests passed!")


def test_yield_curve_duration() raises:
    print("Testing get_yield_curve_duration...")
    
    var duration = get_yield_curve_duration()
    assert_equal(len(duration), 21)
    assert_equal(duration[0], 0)
    assert_equal(duration[1], 30)
    assert_equal(duration[6], 365)
    print("  get_yield_curve_duration tests passed!")


def test_get_tenor_for() raises:
    print("Testing get_tenor_for...")
    
    var start1 = DateTimeDate(2020, 1, 1)
    var end1 = DateTimeDate(2021, 1, 1)
    var tenor1 = get_tenor_for(start1, end1)
    assert_equal(tenor1, "1Y")
    
    var start2 = DateTimeDate(2020, 1, 1)
    var end2 = DateTimeDate(2020, 2, 1)
    var tenor2 = get_tenor_for(start2, end2)
    assert_equal(tenor2, "1M")
    
    var start3 = DateTimeDate(2020, 1, 1)
    var end3 = DateTimeDate(2030, 1, 1)
    var tenor3 = get_tenor_for(start3, end3)
    assert_equal(tenor3, "10Y")
    
    var start4 = DateTimeDate(2020, 1, 1)
    var end4 = DateTimeDate(2020, 1, 1)
    var tenor4 = get_tenor_for(start4, end4)
    assert_equal(tenor4, "0S")
    print("  get_tenor_for tests passed!")


def test_get_tenors_for() raises:
    print("Testing get_tenors_for...")
    
    var start1 = DateTimeDate(2020, 1, 1)
    var end1 = DateTimeDate(2021, 1, 1)
    var tenors1 = get_tenors_for(start1, end1)
    assert_true(len(tenors1) > 0, "Should have tenors")
    assert_equal(tenors1[0], "0S")
    
    var start2 = DateTimeDate(2020, 1, 1)
    var end2 = DateTimeDate(2020, 2, 1)
    var tenors2 = get_tenors_for(start2, end2)
    assert_true(len(tenors2) > 0, "Should have tenors")
    
    print("  get_tenors_for tests passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
