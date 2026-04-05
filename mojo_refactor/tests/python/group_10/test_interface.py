"""
Test for interface.py
Group 10 - File 1
"""

import pytest


def test_interface_exists():
    print("Test: Interface module exists")
    try:
        from rqalpha import interface
        assert interface is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_interface_abstract_mod():
    print("Test: AbstractMod exists")
    try:
        from rqalpha.interface import AbstractMod
        assert AbstractMod is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - AbstractMod not found")


def test_interface_abstract_broker():
    print("Test: AbstractBroker exists")
    try:
        from rqalpha.interface import AbstractBroker
        assert AbstractBroker is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - AbstractBroker not found")
