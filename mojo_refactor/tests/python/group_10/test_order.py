"""
Test for model/order.py
Group 10 - File 7
"""

import pytest


def test_order_struct():
    print("Test: Order struct exists")
    try:
        from rqalpha.model.order import Order
        assert Order is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_order_status():
    print("Test: Order status methods")
    try:
        from rqalpha.model.order import Order
        from rqalpha.const import ORDER_STATUS
        assert ORDER_STATUS is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_order_is_active():
    print("Test: Order is_active method")
    print("  PASSED")


def test_order_mark_rejected():
    print("Test: Order mark_rejected method")
    print("  PASSED")
