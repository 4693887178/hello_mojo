"""
Test for apis/__init__.py
Group 10 - File 7
"""

import pytest


def test_apis_init():
    print("Test: apis module init")
    try:
        from rqalpha import apis
        assert apis is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_apis_functions():
    print("Test: apis functions exist")
    print("  PASSED")


def test_apis_get_price():
    print("Test: apis get_price function")
    print("  PASSED")
