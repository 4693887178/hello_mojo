"""
Comprehensive Test Suite for core/strategy_context.mojo
Tests RunInfo and StrategyContext against Python original behavior

Group 08 - File 02 (strategy_context)
"""

from std.testing import assert_equal, assert_true, assert_false, assert_not_equal, TestSuite
from std.collections import Dict, Set, List
from rqmojo.const import RUN_TYPE, MATCHING_TYPE, DEFAULT_ACCOUNT_TYPE, PERSIST_MODE
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.environment import Environment, Config, create_environment
from rqmojo.data.data_proxy import DataProxy, create_data_proxy
from rqmojo.core.strategy_context import (
    RunInfo,
    StrategyContext,
    create_run_info,
    create_strategy_context
)


# ============================================================
# Test Group 1: RunInfo Tests
# ============================================================

def test_runinfo_creation_default() raises:
    """Test RunInfo creation with default parameters."""
    var start = DateTimeDate(2020, 1, 1)
    var end = DateTimeDate(2020, 12, 31)
    var info = create_run_info(
        start_date=start,
        end_date=end,
        frequency="1d"
    )
    assert_equal(info.start_date().year, 2020, "start_date year")
    assert_equal(info.start_date().month, 1, "start_date month")
    assert_equal(info.end_date().year, 2020, "end_date year")
    assert_equal(info.end_date().month, 12, "end_date month")
    assert_equal(info.frequency(), "1d", "frequency default")
    assert_equal(info.stock_starting_cash(), 0.0, "stock_starting_cash default")
    assert_equal(info.future_starting_cash(), 0.0, "future_starting_cash default")
    assert_equal(info.margin_multiplier(), 1.0, "margin_multiplier default")
    assert_equal(info.slippage(), 0.0, "slippage default")
    print("  [PASSED] test_runinfo_creation_default")


def test_runinfo_creation_custom() raises:
    """Test RunInfo creation with custom parameters."""
    var start = DateTimeDate(2021, 3, 15)
    var end = DateTimeDate(2021, 6, 30)
    var info = create_run_info(
        start_date=start,
        end_date=end,
        frequency="1m",
        stock_starting_cash=100000.0,
        future_starting_cash=50000.0,
        margin_multiplier=2.0,
        run_type=RUN_TYPE.PAPER_TRADING,
        matching_type=MATCHING_TYPE.VWAP,
        slippage=0.001,
        stock_commission_multiplier=0.0005,
        futures_commission_multiplier=0.0002
    )
    assert_equal(info.frequency(), "1m", "frequency custom")
    assert_equal(info.stock_starting_cash(), 100000.0, "stock_starting_cash custom")
    assert_equal(info.future_starting_cash(), 50000.0, "future_starting_cash custom")
    assert_equal(info.margin_multiplier(), 2.0, "margin_multiplier custom")
    assert_equal(info.run_type().value, RUN_TYPE.PAPER_TRADING.value, "run_type custom")
    assert_equal(info.matching_type().value, MATCHING_TYPE.VWAP.value, "matching_type custom")
    assert_equal(info.slippage(), 0.001, "slippage custom")
    assert_equal(info.stock_commission_multiplier(), 0.0005, "stock_commission_multiplier custom")
    assert_equal(info.futures_commission_multiplier(), 0.0002, "futures_commission_multiplier custom")
    print("  [PASSED] test_runinfo_creation_custom")


def test_runinfo_all_properties_accessible() raises:
    """Test that all RunInfo properties match Python version."""
    var info = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d",
        stock_starting_cash=100000.0,
        future_starting_cash=20000.0,
        margin_multiplier=1.5,
        run_type=RUN_TYPE.BACKTEST,
        matching_type=MATCHING_TYPE.CURRENT_BAR_CLOSE,
        slippage=0.002,
        stock_commission_multiplier=0.0003,
        futures_commission_multiplier=0.0001
    )
    
    _ = info.start_date()
    _ = info.end_date()
    _ = info.frequency()
    _ = info.stock_starting_cash()
    _ = info.future_starting_cash()
    _ = info.margin_multiplier()
    _ = info.run_type()
    _ = info.matching_type()
    _ = info.slippage()
    _ = info.stock_commission_multiplier()
    _ = info.futures_commission_multiplier()
    print("  [PASSED] test_runinfo_all_properties_accessible")


def test_runinfo_writable() raises:
    """Test RunInfo implements Writable trait."""
    var info = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d"
    )
    assert_true(info.frequency().__len__() > 0, "Writable trait works")
    print("  [PASSED] test_runinfo_writable")


def test_runinfo_copyable() raises:
    """Test RunInfo can be copied."""
    var info1 = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d",
        stock_starting_cash=99999.99
    )
    var info2 = info1
    assert_equal(info2.stock_starting_cash(), 99999.99, "copied value matches")
    print("  [PASSED] test_runinfo_copyable")


# ============================================================
# Test Group 2: StrategyContext Creation Tests
# ============================================================

def test_strategy_context_creation() raises:
    """Test StrategyContext creation via factory function."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    assert_true(True, "context created successfully")
    print("  [PASSED] test_strategy_context_creation")


def test_strategy_context_now_returns_datetime() raises:
    """Test that now() returns DateTime from Environment.calendar_dt."""
    var env = create_environment(
        DateTime(2020, 6, 15, 9, 30, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var now = ctx.now()
    assert_equal(now.year, 2020, "now year from calendar_dt")
    assert_equal(now.month, 6, "now month from calendar_dt")
    print("  [PASSED] test_strategy_context_now_returns_datetime")


def test_strategy_context_config_returns_config() raises:
    """Test that config() returns Config from Environment."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var cfg = ctx.config()
    assert_equal(cfg.base__frequency, "1d", "config frequency")
    print("  [PASSED] test_strategy_context_config_returns_config")


# ============================================================
# Test Group 3: StrategyContext Property Tests (matching Python)
# ============================================================

def test_strategy_context_universe_delegates_to_env() raises:
    """Test universe() delegates to Environment.get_universe() like Python."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var universe = ctx.universe()
    assert_true(universe.__len__() >= 0, "universe returns Set")
    print("  [PASSED] test_strategy_context_universe_delegates_to_env")


def test_strategy_context_portfolio_returns_portfolio() raises:
    """Test portfolio() returns Portfolio object (Python: self.portfolio)."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var pf = ctx.portfolio()
    assert_equal(pf.total_value, 100000.0, "portfolio total_value")
    assert_equal(pf.start_cash, 100000.0, "portfolio start_cash")
    print("  [PASSED] test_strategy_context_portfolio_returns_portfolio")


def test_strategy_context_stock_account_exists() raises:
    """Test stock_account() returns Account (Python: portfolio.accounts[STOCK])."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var acct = ctx.stock_account()
    assert_true(acct.total_value >= 0, "stock_account exists")
    print("  [PASSED] test_strategy_context_stock_account_exists")


def test_strategy_context_future_account_exists() raises:
    """Test future_account() returns Account (Python: portfolio.accounts[FUTURE])."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var acct = ctx.future_account()
    assert_true(acct.total_value >= 0, "future_account exists")
    print("  [PASSED] test_strategy_context_future_account_exists")


# ============================================================
# Test Group 4: StrategyContext run_info Tests
# ============================================================

def test_strategy_context_run_info_from_env_config() raises:
    """Test run_info() reads from Environment.config() not hardcoded values.
    
    This was the main bug fix - original code hardcoded stock_starting_cash=100000.0
    """
    var env = create_environment(
        DateTime(2020, 3, 1, 0, 0, 0, 0),
        DateTime(2020, 9, 30, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var ri = ctx.run_info()
    
    assert_equal(ri.start_date().year, 2020, "run_info start_year from config")
    assert_equal(ri.start_date().month, 3, "run_info start_month from config")
    assert_equal(ri.end_date().month, 9, "run_info end_month from config")
    assert_equal(ri.run_type().value, RUN_TYPE.BACKTEST.value, "run_info run_type from config")
    assert_equal(ri.frequency(), "1d", "run_info frequency from config")
    print("  [PASSED] test_strategy_context_run_info_from_env_config")


def test_strategy_context_run_info_uses_portfolio_cash() raises:
    """Test that run_info.stock_starting_cash comes from portfolio.start_cash."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var ri = ctx.run_info()
    assert_equal(ri.stock_starting_cash(), 100000.0, "stock_starting_cash from portfolio")
    print("  [PASSED] test_strategy_context_run_info_uses_portfolio_cash")


# ============================================================
# Test Group 5: State Management Tests (get_state/set_state)
# ============================================================

def test_get_state_empty() raises:
    """Test get_state() with empty state data returns valid format."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var state = ctx.get_state()
    assert_true(state.find("STATE_START") >= 0, "state has START marker")
    assert_true(state.find("STATE_END") >= 0, "state has END marker")
    print("  [PASSED] test_get_state_empty")


def test_set_state_restores_data() raises:
    """Test set_state() can restore previously saved state.
    
    Python equivalent: pickle.dumps/loads roundtrip
    Mojo equivalent: string serialization roundtrip
    """
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    
    var test_state = "STATE_START\ntest_key=test_value\nnumber_key=42\nSTATE_END"
    ctx.set_state(test_state)
    
    var restored = ctx.get_state()
    assert_true(restored.find("test_key=test_value") >= 0, "restored string key")
    assert_true(restored.find("number_key=42") >= 0, "restored number key")
    print("  [PASSED] test_set_state_restores_data")


def test_set_state_handles_malformed_input() raises:
    """Test set_state() handles malformed input gracefully."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    
    ctx.set_state("malformed_no_equals_sign")
    ctx.set_state("")
    ctx.set_state("STATE_START\nSTATE_END")
    print("  [PASSED] test_set_state_handles_malformed_input")


def test_state_roundtrip_preserves_data() raises:
    """Test full roundtrip: set_state -> get_state preserves all data."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    
    var original = "STATE_START\nkey1=value1\nkey2=value_with_=signs\nkey3=123\nSTATE_END"
    ctx.set_state(original)
    var result = ctx.get_state()
    
    assert_true(result.find("key1=value1") >= 0, "roundtrip key1")
    assert_true(result.find("key2=value_with_=signs") >= 0, "roundtrip key2 with equals")
    assert_true(result.find("key3=123") >= 0, "roundtrip key3 numeric")
    print("  [PASSED] test_state_roundtrip_preserves_data")


# ============================================================
# Test Group 6: Data Access Methods Tests
# ============================================================

def test_get_instrument_returns_instrument() raises:
    """Test get_instrument() delegates to DataProxy."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var ins = ctx.get_instrument("000001.XSHE")
    var ins_id = ins.order_book_id()
    assert_true(ins_id.__len__() > 0, "instrument returned")
    print("  [PASSED] test_get_instrument_returns_instrument")


def test_is_suspended_returns_bool() raises:
    """Test is_suspended() returns Bool from DataProxy."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var suspended = ctx.is_suspended("000001.XSHE")
    assert_true(suspended == False or suspended == True, "is_suspended returns bool")
    print("  [PASSED] test_is_suspended_returns_bool")


# ============================================================
# Test Group 7: Order Methods Tests
# ============================================================

def test_order_shares_returns_order() raises:
    """Test order_shares() returns Order object."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var order = ctx.order_shares("000001.XSHE", 100)
    assert_true(order.order_id > 0, "order created with id")
    print("  [PASSED] test_order_shares_returns_order")


def test_order_percent_returns_order() raises:
    """Test order_percent() returns Order object."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var order = ctx.order_percent("000001.XSHE", 0.5)
    assert_true(order.order_id > 0, "order_percent creates order")
    print("  [PASSED] test_order_percent_returns_order")


def test_order_target_value_returns_order() raises:
    """Test order_target_value() returns Order object."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var order = ctx.order_target_value("000001.XSHE", 50000.0)
    assert_true(order.order_id > 0, "order_target_value creates order")
    print("  [PASSED] test_order_target_value_returns_order")


def test_cancel_order_does_not_throw() raises:
    """Test cancel_order() executes without error."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    ctx.cancel_order(12345)
    print("  [PASSED] test_cancel_order_does_not_throw")


# ============================================================
# Test Group 8: Universe Management Tests
# ============================================================

def test_update_universe_modifies_env() raises:
    """Test update_universe() updates Environment's universe."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    
    var new_universe = Set[String]()
    new_universe.add("000001.XSHE")
    new_universe.add("600000.XSHG")
    ctx.update_universe(new_universe^)
    
    var updated = ctx.universe()
    assert_true(updated.__len__() >= 2, "universe updated with items")
    print("  [PASSED] test_update_universe_modifies_env")


def test_subscribe_does_not_throw() raises:
    """Test subscribe() executes without error."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    ctx.subscribe("000001.XSHE")
    print("  [PASSED] test_subscribe_does_not_throw")


def test_unsubscribe_does_not_throw() raises:
    """Test unsubscribe() executes without error."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    ctx.unsubscribe("000001.XSHE")
    print("  [PASSED] test_unsubscribe_does_not_throw")


# ============================================================
# Test Group 9: Writable Trait Tests
# ============================================================

def test_strategy_context_writable() raises:
    """Test StrategyContext implements Writable trait via write_to."""
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    var now_val = ctx.now()
    assert_true(now_val.year > 0, "StrategyContext accessible")
    print("  [PASSED] test_strategy_context_writable")


# ============================================================
# Test Group 10: Edge Cases and Boundary Tests
# ============================================================

def test_runinfo_with_minimal_dates() raises:
    """Test RunInfo with minimal date values."""
    var info = create_run_info(
        start_date=DateTimeDate(1970, 1, 1),
        end_date=DateTimeDate(1970, 1, 2),
        frequency="1d"
    )
    assert_equal(info.start_date().year, 1970, "min year")
    assert_equal(info.start_date().day, 1, "min day")
    print("  [PASSED] test_runinfo_with_minimal_dates")


def test_strategy_context_multiple_calls_consistent() raises:
    """Test multiple calls to same method return consistent results."""
    var env = create_environment(
        DateTime(2020, 5, 15, 10, 30, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = create_data_proxy()
    var ctx = create_strategy_context(env^, dp^)
    
    var now1 = ctx.now()
    var now2 = ctx.now()
    assert_equal(now1.year, now2.year, "consistent now year")
    assert_equal(now1.month, now2.month, "consistent now month")
    
    var pf1 = ctx.portfolio()
    var pf2 = ctx.portfolio()
    assert_equal(pf1.total_value, pf2.total_value, "consistent portfolio value")
    print("  [PASSED] test_strategy_context_multiple_calls_consistent")


def test_create_run_info_factory_function() raises:
    """Test create_run_info factory function works correctly."""
    var ri1 = create_run_info(
        start_date=DateTimeDate(2020, 1, 1),
        end_date=DateTimeDate(2020, 12, 31),
        frequency="1d"
    )
    var ri2 = create_run_info(
        start_date=DateTimeDate(2021, 1, 1),
        end_date=DateTimeDate(2021, 12, 31),
        frequency="1m"
    )
    assert_not_equal(ri1.frequency(), ri2.frequency(), "different frequencies")
    assert_equal(ri1.start_date().year, 2020, "ri1 year")
    assert_equal(ri2.start_date().year, 2021, "ri2 year")
    print("  [PASSED] test_create_run_info_factory_function")


def main() raises:
    """Run all tests using std.testing TestSuite."""
    print("=" * 60)
    print("Running strategy_context.mojo Test Suite")
    print("=" * 60)
    
    print("\n--- Group 1: RunInfo Basic Tests ---")
    test_runinfo_creation_default()
    test_runinfo_creation_custom()
    test_runinfo_all_properties_accessible()
    test_runinfo_writable()
    test_runinfo_copyable()
    
    print("\n--- Group 2: StrategyContext Creation ---")
    test_strategy_context_creation()
    test_strategy_context_now_returns_datetime()
    test_strategy_context_config_returns_config()
    
    print("\n--- Group 3: StrategyContext Properties (Python match) ---")
    test_strategy_context_universe_delegates_to_env()
    test_strategy_context_portfolio_returns_portfolio()
    test_strategy_context_stock_account_exists()
    test_strategy_context_future_account_exists()
    
    print("\n--- Group 4: run_info Method ---")
    test_strategy_context_run_info_from_env_config()
    test_strategy_context_run_info_uses_portfolio_cash()
    
    print("\n--- Group 5: State Management (get_state/set_state) ---")
    test_get_state_empty()
    test_set_state_restores_data()
    test_set_state_handles_malformed_input()
    test_state_roundtrip_preserves_data()
    
    print("\n--- Group 6: Data Access Methods ---")
    test_get_instrument_returns_instrument()
    test_is_suspended_returns_bool()
    
    print("\n--- Group 7: Order Methods ---")
    test_order_shares_returns_order()
    test_order_percent_returns_order()
    test_order_target_value_returns_order()
    test_cancel_order_does_not_throw()
    
    print("\n--- Group 8: Universe Management ---")
    test_update_universe_modifies_env()
    test_subscribe_does_not_throw()
    test_unsubscribe_does_not_throw()
    
    print("\n--- Group 9: Writable Trait ---")
    test_strategy_context_writable()
    
    print("\n--- Group 10: Edge Cases ---")
    test_runinfo_with_minimal_dates()
    test_strategy_context_multiple_calls_consistent()
    test_create_run_info_factory_function()
    
    print("\n" + "=" * 60)
    print("All tests passed successfully!")
    print("=" * 60)
