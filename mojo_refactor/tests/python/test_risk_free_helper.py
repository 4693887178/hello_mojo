#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RQAlpha Python - Risk Free Helper Tests
Tests for risk_free_helper.py (original Python implementation)
"""

import sys
from datetime import datetime
from rqalpha.utils.risk_free_helper import get_tenor_for, get_tenors_for


def test_get_tenor_for():
    """Test get_tenor_for function"""
    start_date = datetime(2020, 1, 1)
    
    # Test 0 days
    end_date1 = datetime(2020, 1, 1)
    assert get_tenor_for(start_date, end_date1) == "0S"
    
    # Test 15 days
    end_date2 = datetime(2020, 1, 16)
    assert get_tenor_for(start_date, end_date2) == "0S"
    
    # Test 30 days
    end_date3 = datetime(2020, 1, 31)
    assert get_tenor_for(start_date, end_date3) == "1M"
    
    # Test 60 days
    end_date4 = datetime(2020, 3, 1)
    assert get_tenor_for(start_date, end_date4) == "2M"
    
    # Test 365 days
    end_date5 = datetime(2021, 1, 1)
    assert get_tenor_for(start_date, end_date5) == "1Y"
    
    # Test 730 days
    end_date6 = datetime(2022, 1, 1)
    assert get_tenor_for(start_date, end_date6) == "2Y"


def test_get_tenors_for():
    """Test get_tenors_for function"""
    start_date = datetime(2020, 1, 1)
    
    # Test 0 days
    end_date1 = datetime(2020, 1, 1)
    tenors1 = get_tenors_for(start_date, end_date1)
    assert len(tenors1) == 1
    assert tenors1[0] == "0S"
    
    # Test 30 days
    end_date2 = datetime(2020, 1, 31)
    tenors2 = get_tenors_for(start_date, end_date2)
    assert len(tenors2) == 2
    assert tenors2[0] == "0S"
    assert tenors2[1] == "1M"
    
    # Test 365 days
    end_date3 = datetime(2021, 1, 1)
    tenors3 = get_tenors_for(start_date, end_date3)
    assert len(tenors3) == 7
    assert tenors3[0] == "0S"
    assert tenors3[6] == "1Y"


def test_cross_year_month():
    """Test cross year and month scenarios"""
    # Test leap year
    start_date = datetime(2020, 2, 29)
    end_date = datetime(2021, 2, 28)
    duration = (end_date - start_date).days
    result = get_tenor_for(start_date, end_date)
    print(f"Leap year test: duration={duration}, result={result}")
    assert get_tenor_for(start_date, end_date) == "1Y"
    
    # Test different month lengths
    start_date2 = datetime(2020, 1, 31)
    end_date2 = datetime(2020, 2, 29)
    duration2 = (end_date2 - start_date2).days
    result2 = get_tenor_for(start_date2, end_date2)
    print(f"Different month lengths test: duration={duration2}, result={result2}")
    assert get_tenor_for(start_date2, end_date2) == "0S"
    
    # Test exactly 30 days
    start_date3 = datetime(2020, 1, 1)
    end_date3 = datetime(2020, 1, 31)
    duration3 = (end_date3 - start_date3).days
    result3 = get_tenor_for(start_date3, end_date3)
    print(f"Exactly 30 days test: duration={duration3}, result={result3}")
    assert get_tenor_for(start_date3, end_date3) == "1M"


def main():
    test_get_tenor_for()
    test_get_tenors_for()
    test_cross_year_month()
    print("All Python tests passed!")


if __name__ == "__main__":
    main()
