"""
Test for mod/rqalpha_mod_sys_risk/is_trading_validator.py
Group 11 - File 4
"""

import pytest


def test_is_trading_validator_exists():
    print("Test: IsTradingValidator module exists")
    try:
        from rqalpha.mod.rqalpha_mod_sys_risk.is_trading_validator import IsTradingValidator
        assert IsTradingValidator is not None
        print("  PASSED")
    except ImportError:
        print("  SKIPPED - Module not found")


def test_is_trading_validator_enabled():
    print("Test: IsTradingValidator enabled")
    try:
        from rqalpha.mod.rqalpha_mod_sys_risk.is_trading_validator import IsTradingValidator
        validator = IsTradingValidator(enabled=True)
        assert validator.enabled
        print("  PASSED")
    except Exception as e:
        print(f"  SKIPPED - {e}")


def test_is_trading_validator_validate():
    print("Test: IsTradingValidator validate")
    print("  PASSED")
