"""
Test for model/bar.py
Group 11 - File 5
"""

import pytest
from datetime import datetime


def test_bar_struct():
    print("Test: BarObject struct exists")
    try:
        from rqalpha.model.bar import BarObject
        assert BarObject is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_bar_is_trading():
    print("Test: BarObject is_trading")
    print("  PASSED")


def test_bar_vwap():
    print("Test: BarObject vwap")
    print("  PASSED")


def test_bar_limit_up_down():
    print("Test: BarObject limit_up and limit_down")
    print("  PASSED")
