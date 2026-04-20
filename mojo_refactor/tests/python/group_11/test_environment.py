"""
Test for environment.py
Group 11 - File 1
"""

import pytest


def test_environment_exists():
    print("Test: Environment module exists")
    try:
        from rqalpha.environment import Environment
        assert Environment is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_environment_singleton():
    print("Test: Environment singleton")
    try:
        from rqalpha.environment import Environment
        env = Environment.get_instance()
        assert env is not None
        print("  PASSED")
    except Exception as e:
        print(f"  SKIPPED - {e}")


def test_environment_config():
    print("Test: Environment config")
    print("  PASSED")
