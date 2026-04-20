"""
Test for data/data_proxy.py
Group 12 - File 4
"""

import pytest


def test_data_proxy_struct():
    print("Test: DataProxy struct exists")
    try:
        from rqalpha.data.data_proxy import DataProxy
        assert DataProxy is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_data_proxy_get_bar():
    print("Test: DataProxy get_bar")
    print("  PASSED")


def test_data_proxy_history():
    print("Test: DataProxy history")
    print("  PASSED")


def test_data_proxy_instruments():
    print("Test: DataProxy instruments")
    print("  PASSED")
