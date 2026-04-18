"""
Comprehensive test suite for rqmojo/mod/rqmojo_mod_sys_transaction_cost/mod.mojo
Tests all business logic ported from Python mod.py:
  - get_inst_type_in_stock_account constant
  - TransactionCostMod struct and factory
  - init_from_config with deprecated option handling
  - validate_config (commission/tax multiplier range checks)
  - create_stock_deciders (per instrument type, skip PUBLIC_FUND)
  - create_future_decider
  - tear_down no-op
"""

from rqmojo.const import INSTRUMENT_TYPE, EXIT_CODE, MARKET
from rqmojo.mod.rqmojo_mod_sys_transaction_cost import (
    TransactionCostMod,
    create_transaction_cost_mod,
    get_inst_type_in_stock_account,
)
from rqmojo.mod.rqmojo_mod_sys_transaction_cost.deciders import (
    StockTransactionCostDecider,
    FutureTransactionCostDecider,
)
from rqmojo.mod.utils import ConfigValue
from std.testing import (
    assert_equal, assert_true, assert_false,
    TestSuite,
)
from std.collections import Dict, Optional


def _make_default_config() -> Dict[String, ConfigValue]:
    """Helper: build standard mod config dict."""
    var config = Dict[String, ConfigValue]()
    config["cn_stock_min_commission"] = ConfigValue(-1.0)
    config["stock_min_commission"] = ConfigValue(5.0)
    config["stock_commission_multiplier"] = ConfigValue(1.0)
    config["futures_commission_multiplier"] = ConfigValue(1.0)
    config["tax_multiplier"] = ConfigValue(1.0)
    config["pit_tax"] = ConfigValue(False)
    return config^


# ============================================================
# get_inst_type_in_stock_account tests
# ============================================================

def test_get_inst_type_in_stock_account_has_all_types() raises:
    """Python: INST_TYPE_IN_STOCK_ACCOUNT = [CS, ETF, LOF, INDX, PUBLIC_FUND, REITs]."""
    var types = get_inst_type_in_stock_account()
    assert_equal(len(types), 6)

    var names = List[String]()
    for t in types:
        names.append(t.value)

    assert_true("CS" in names)
    assert_true("ETF" in names)
    assert_true("LOF" in names)
    assert_true("INDX" in names)
    assert_true("PublicFund" in names)
    assert_true("REITs" in names)


def test_get_inst_type_in_stock_account_contains_cs() raises:
    var types = get_inst_type_in_stock_account()
    assert_true(INSTRUMENT_TYPE.CS in types)


def test_get_inst_type_in_stock_account_contains_etf() raises:
    var types = get_inst_type_in_stock_account()
    assert_true(INSTRUMENT_TYPE.ETF in types)


def test_get_inst_type_in_stock_account_contains_lof() raises:
    var types = get_inst_type_in_stock_account()
    assert_true(INSTRUMENT_TYPE.LOF in types)


def test_get_inst_type_in_stock_account_contains_indx() raises:
    var types = get_inst_type_in_stock_account()
    assert_true(INSTRUMENT_TYPE.INDX in types)


def test_get_inst_type_in_stock_account_contains_public_fund() raises:
    var types = get_inst_type_in_stock_account()
    assert_true(INSTRUMENT_TYPE.PUBLIC_FUND in types)


def test_get_inst_type_in_stock_account_contains_reits() raises:
    var types = get_inst_type_in_stock_account()
    var found = False
    for t in types:
        if t.value == "REITs":
            found = True
    assert_true(found)


def test_get_inst_type_in_stock_account_no_future() raises:
    var types = get_inst_type_in_stock_account()
    assert_false(INSTRUMENT_TYPE.FUTURE in types)


def test_get_inst_type_in_stock_account_no_bond() raises:
    var types = get_inst_type_in_stock_account()
    assert_false(INSTRUMENT_TYPE.BOND in types)


# ============================================================
# TransactionCostMod construction / factory tests
# ============================================================

def test_create_transaction_cost_mod_defaults() raises:
    """Factory creates mod with sensible defaults."""
    var mod = create_transaction_cost_mod()
    assert_equal(mod.name, "transaction_cost")
    assert_true(mod.enabled)
    assert_equal(mod.stock_commission_multiplier, 1.0)
    assert_equal(mod.futures_commission_multiplier, 1.0)
    assert_equal(mod.min_commission, 5.0)
    assert_equal(mod.tax_multiplier, 1.0)
    assert_false(mod.pit_tax)


def test_create_transaction_cost_mod_custom() raises:
    """Factory accepts custom commission multipliers."""
    var mod = create_transaction_cost_mod(
        stock_commission=0.0003,
        futures_commission=0.0001,
    )
    assert_equal(mod.stock_commission_multiplier, 0.0003)
    assert_equal(mod.futures_commission_multiplier, 0.0001)


def test_mod_writable() raises:
    """Mod implements Writable via write_to."""
    var mod = create_transaction_cost_mod()
    var s = String.write(mod)
    assert_true("TransactionCostMod" in s)
    assert_true("transaction_cost" in s)


# ============================================================
# init_from_config tests
# ============================================================

def test_init_from_config_default_values() raises:
    """Loading default config sets all fields correctly."""
    var mod = create_transaction_cost_mod()
    var config = _make_default_config()
    mod.init_from_config(config)

    assert_equal(mod.stock_commission_multiplier, 1.0)
    assert_equal(mod.futures_commission_multiplier, 1.0)
    assert_equal(mod.min_commission, 5.0)
    assert_equal(mod.tax_multiplier, 1.0)
    assert_false(mod.pit_tax)


def test_init_from_config_custom_values() raises:
    """Config overrides default values."""
    var mod = create_transaction_cost_mod()
    var config = _make_default_config()
    config["stock_commission_multiplier"] = ConfigValue(0.0003)
    config["futures_commission_multiplier"] = ConfigValue(0.00005)
    config["tax_multiplier"] = ConfigValue(2.0)
    config["pit_tax"] = ConfigValue(True)
    config["stock_min_commission"] = ConfigValue(10.0)
    mod.init_from_config(config)

    assert_equal(mod.stock_commission_multiplier, 0.0003)
    assert_equal(mod.futures_commission_multiplier, 0.00005)
    assert_equal(mod.tax_multiplier, 2.0)
    assert_true(mod.pit_tax)
    assert_equal(mod.min_commission, 10.0)


def test_init_from_config_cn_stock_min_commission_deprecated_used() raises:
    """Python: if cn_stock_min_commission is not None (>=0 here), use it (with deprecation warning)."""
    var mod = create_transaction_cost_mod()
    var config = _make_default_config()
    config["cn_stock_min_commission"] = ConfigValue(8.0)
    config["stock_min_commission"] = ConfigValue(5.0)
    mod.init_from_config(config)

    assert_equal(mod.min_commission, 8.0)


def test_init_from_config_cn_stock_min_commission_negative_falls_back() raises:
    """Python: if cn_stock_min_commission is None (-1 here), use stock_min_commission."""
    var mod = create_transaction_cost_mod()
    var config = _make_default_config()
    config["cn_stock_min_commission"] = ConfigValue(-1.0)
    config["stock_min_commission"] = ConfigValue(12.0)
    mod.init_from_config(config)

    assert_equal(mod.min_commission, 12.0)


def test_init_from_config_cn_zero_is_valid() raises:
    """Cn_stock_min_commission = 0 is valid (not negative fallback sentinel)."""
    var mod = create_transaction_cost_mod()
    var config = _make_default_config()
    config["cn_stock_min_commission"] = ConfigValue(0.0)
    mod.init_from_config(config)

    assert_equal(mod.min_commission, 0.0)


# ============================================================
# validate_config tests
# ============================================================

def test_validate_config_valid() raises:
    """Valid config returns None (no error)."""
    var mod = create_transaction_cost_mod()
    var result = mod.validate_config()
    assert_true(result == Optional[String](None))


def test_validate_config_negative_stock_commission() raises:
    """Python: stock_commission_multiplier < 0 -> raise ValueError."""
    var mod = create_transaction_cost_mod(stock_commission=-1.0)
    var result = mod.validate_config()
    assert_true(result != Optional[String](None))
    var msg = result.or_else("")
    assert_true("invalid commission" in msg)


def test_validate_config_negative_tax_multiplier() raises:
    """Python: tax_multiplier < 0 -> raise ValueError."""
    var mod = create_transaction_cost_mod()
    mod.tax_multiplier = -0.5
    var result = mod.validate_config()
    assert_true(result != Optional[String](None))
    var msg = result.or_else("")
    assert_true("invalid" in msg)


def test_validate_config_both_negative() raises:
    """Both negative still produces error message."""
    var mod = create_transaction_cost_mod(stock_commission=-1.0)
    mod.tax_multiplier = -1.0
    var result = mod.validate_config()
    assert_true(result != Optional[String](None))


def test_validate_config_zero_multipliers_ok() raises:
    """Zero is valid (range is [0, +inf))."""
    var mod = create_transaction_cost_mod(stock_commission=0.0)
    mod.tax_multiplier = 0.0
    var result = mod.validate_config()
    assert_true(result == Optional[String](None))


def test_validate_config_large_multipliers_ok() raises:
    """Large positive values are valid."""
    var mod = create_transaction_cost_mod(stock_commission=999.0)
    mod.tax_multiplier = 999.0
    var result = mod.validate_config()
    assert_true(result == Optional[String](None))


# ============================================================
# create_stock_deciders tests
# ============================================================

def test_create_stock_deciders_count() raises:
    """Creates deciders for CS, ETF, LOF, INDX, REITs (5 types, skipping PUBLIC_FUND)."""
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_equal(len(types), 5)


def test_create_stock_deciders_skips_public_fund() raises:
    """Python: if instrument_type == PUBLIC_FUND: continue."""
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_false(INSTRUMENT_TYPE.PUBLIC_FUND in types)


def test_create_stock_deciders_has_cs() raises:
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_true(INSTRUMENT_TYPE.CS in types)


def test_create_stock_deciders_has_etf() raises:
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_true(INSTRUMENT_TYPE.ETF in types)


def test_create_stock_deciders_has_lof() raises:
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_true(INSTRUMENT_TYPE.LOF in types)


def test_create_stock_deciders_has_indx() raises:
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_true(INSTRUMENT_TYPE.INDX in types)


def test_create_stock_deciders_has_reits() raises:
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    var found = False
    for k in types:
        if k.value == "REITs":
            found = True
    assert_true(found)


def test_make_stock_decider_for_correct_params() raises:
    """Each decider gets the mod's commission_multiplier, min_commission, tax_multiplier."""
    var mod = create_transaction_cost_mod(stock_commission=0.0003)
    mod.init_from_config(_make_default_config())
    mod.stock_commission_multiplier = 0.0003
    mod.min_commission = 8.0
    mod.tax_multiplier = 2.0

    var d = mod.make_stock_decider_for(INSTRUMENT_TYPE.CS)
    assert_equal(d.commission_multiplier, 0.0003)
    assert_equal(d.min_commission, 8.0)
    assert_equal(d.tax_multiplier, 2.0)

    var d2 = mod.make_stock_decider_for(INSTRUMENT_TYPE.ETF)
    assert_equal(d2.commission_multiplier, 0.0003)
    assert_equal(d2.min_commission, 8.0)
    assert_equal(d2.tax_multiplier, 2.0)


def test_create_stock_deciders_different_types_independent() raises:
    """All types are independent entries."""
    var mod = create_transaction_cost_mod()
    var types = mod.create_stock_deciders()
    assert_equal(len(types), 5)


# ============================================================
# create_future_decider tests
# ============================================================

def test_create_future_decider_default() raises:
    var mod = create_transaction_cost_mod()
    var decider = mod.create_future_decider()
    assert_equal(decider.commission_multiplier, 1.0)


def test_create_future_decider_custom_multiplier() raises:
    var mod = create_transaction_cost_mod(futures_commission=0.0001)
    var decider = mod.create_future_decider()
    assert_equal(decider.commission_multiplier, 0.0001)


def test_create_future_decider_hedge_type_speculation() raises:
    """Python default: hedge_type = HEDGE_TYPE.SPECULATION (mapped to 0)."""
    var mod = create_transaction_cost_mod()
    var decider = mod.create_future_decider()
    assert_equal(decider.hedge_type, 0)


# ============================================================
# tear_down tests
# ============================================================

def test_tear_down_no_op() raises:
    """Python: def tear_down(self, code, exception=None): pass."""
    var mod = create_transaction_cost_mod()
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))
    mod.tear_down(EXIT_CODE.EXIT_USER_ERROR, Optional[String]("test error"))


def test_tear_down_preserves_state() raises:
    """Tear_down does not modify mod fields."""
    var mod = create_transaction_cost_mod(stock_commission=0.5, futures_commission=0.25)
    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))
    assert_equal(mod.stock_commission_multiplier, 0.5)
    assert_equal(mod.futures_commission_multiplier, 0.25)


# ============================================================
# start_up stub tests (matches ModInterface contract)
# ============================================================

def test_start_up_does_not_crash() raises:
    """Start_up is a stub accepting env_name and mod_config_name strings."""
    var mod = create_transaction_cost_mod()
    mod.start_up("test_env", "test_config")


# ============================================================
# End-to-end: full lifecycle simulation (unit-level, no Environment)
# ============================================================

def test_full_lifecycle_init_validate() raises:
    """Simulate complete flow: load config -> validate."""
    var mod = create_transaction_cost_mod()

    var config = _make_default_config()
    config["stock_commission_multiplier"] = ConfigValue(0.0003)
    config["futures_commission_multiplier"] = ConfigValue(0.0001)
    config["tax_multiplier"] = ConfigValue(1.0)
    config["stock_min_commission"] = ConfigValue(5.0)
    mod.init_from_config(config)

    var err = mod.validate_config()
    assert_true(err == Optional[String](None))

    mod.tear_down(EXIT_CODE.EXIT_SUCCESS, Optional[String](None))


def test_full_lifecycle_with_deprecated_config() raises:
    """Simulate flow with deprecated cn_stock_min_commission set."""
    var mod = create_transaction_cost_mod()

    var config = _make_default_config()
    config["cn_stock_min_commission"] = ConfigValue(10.0)
    mod.init_from_config(config)

    assert_equal(mod.min_commission, 10.0)

    var d = mod.make_stock_decider_for(INSTRUMENT_TYPE.CS)
    assert_equal(d.min_commission, 10.0)


def test_full_lifecycle_validation_failure() raises:
    """Simulate flow where validation fails before setup."""
    var mod = create_transaction_cost_mod(stock_commission=-0.5)

    var err = mod.validate_config()
    assert_true(err != Optional[String](None))


def test_full_lifecycle_creates_all_stock_decider_types() raises:
    """Verify all expected stock types are produced by create_stock_deciders."""
    var mod = create_transaction_cost_mod()
    mod.init_from_config(_make_default_config())

    var types = mod.create_stock_deciders()

    var expected = [
        INSTRUMENT_TYPE.CS,
        INSTRUMENT_TYPE.ETF,
        INSTRUMENT_TYPE.LOF,
        INSTRUMENT_TYPE.INDX,
    ]
    for et in expected:
        assert_true(et in types)

    assert_false(INSTRUMENT_TYPE.PUBLIC_FUND in types)
    assert_false(INSTRUMENT_TYPE.FUTURE in types)

    for t in types:
        var d = mod.make_stock_decider_for(t)
        assert_equal(d.commission_multiplier, 1.0)
        assert_equal(d.min_commission, 5.0)
        assert_equal(d.tax_multiplier, 1.0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
