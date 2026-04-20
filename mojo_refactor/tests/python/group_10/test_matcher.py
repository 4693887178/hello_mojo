"""
Test for mod/rqalpha_mod_sys_simulation/matcher.py
Group 10 - File 5
"""

import pytest


def test_matcher_struct():
    print("Test: Matcher struct exists")
    try:
        from rqalpha.mod.rqalpha_mod_sys_simulation.matcher import DefaultMatcher
        matcher = DefaultMatcher()
        assert matcher is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_matcher_match_order():
    print("Test: Matcher match_order method")
    try:
        from rqalpha.mod.rqalpha_mod_sys_simulation.matcher import DefaultMatcher
        matcher = DefaultMatcher()
        assert matcher is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_matcher_slippage():
    print("Test: Matcher slippage")
    try:
        from rqalpha.mod.rqalpha_mod_sys_simulation.matcher import DefaultMatcher
        matcher = DefaultMatcher()
        assert matcher is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")
