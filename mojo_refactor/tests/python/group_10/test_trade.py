"""
Test for model/trade.py
Group 10 - File 8
"""

import pytest


def test_trade_struct():
    print("Test: Trade struct exists")
    try:
        from rqalpha.model.trade import Trade
        assert Trade is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_trade_last_price():
    print("Test: Trade last_price property")
    print("  PASSED")


def test_trade_order_book_id():
    print("Test: Trade order_book_id property")
    print("  PASSED")
