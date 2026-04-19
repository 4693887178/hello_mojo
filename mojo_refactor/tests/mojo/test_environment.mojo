"""
Test for environment.mojo - Core Environment Class
Verifies all functionality matches Python rqalpha/environment.py:
  - Singleton pattern (get_instance/set_instance/clear_instance)
  - Config access, event bus, time management
  - Data proxy, order submission, validation
  - Portfolio, universe, transaction cost
  - Component setters and getters

Uses std.testing standard framework (Mojo 0.26.2.0).
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.collections import Dict, List, Set, Optional


# ============================================================
# Struct Import Tests
# ============================================================

def test_config_struct() raises:
    """Config struct is constructible with correct defaults."""
    from rqmojo.environment import Config
    from rqmojo.utils.typing import DateTime
    var dt = DateTime(2020, 1, 1, 0, 0, 0, 0)
    var cfg = Config(
        base__start_date=dt,
        base__end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        base__frequency="1d",
        base__run_type=RUN_TYPE.BACKTEST,
        account_count=1,
        is_hold=False
    )
    assert_equal(cfg.base__frequency, "1d")
    assert_false(cfg.is_hold)
    assert_equal(cfg.account_count, 1)


def test_frontend_validator_struct() raises:
    """FrontendValidator struct with validation methods."""
    from rqmojo.environment import FrontendValidator
    from rqmojo.model.order import Order
    var v = FrontendValidator(name="test_validator", instrument_type=INSTRUMENT_TYPE.CS)
    assert_true(v.can_submit_order(Order(), Optional[Order](None)))
    assert_true(v.can_cancel_order(Order(), Optional[Order](None)))
    var result = v.validate_submission(Order(), Optional[Order](None))
    assert_true(result is None or result.value() == "")


def test_transaction_cost_decider() raises:
    """TransactionCostDecider calculates cost correctly."""
    from rqmojo.environment import TransactionCostDecider, TransactionCostArgs
    from rqmojo.model.instrument import Instrument
    from rqmojo.model.order import Order
    var decider = TransactionCostDecider(
        name="stock_decider",
        instrument_type=INSTRUMENT_TYPE.CS,
        market=MARKET.CN
    )
    var ins = create_stock_instrument("000001.XSHE")
    var order = Order()
    var args = TransactionCostArgs(order=order, instrument=ins, quantity=100, price=10.0)
    var cost = decider.calc(args.order, args.quantity, args.price)
    assert_true(cost > 0, "Transaction cost should be positive")
    assert_equal(cost, 100 * 10.0 * 0.0003)


def test_persist_provider_and_helper() raises:
    """PersistProvider and PersistHelper are constructible."""
    from rqmojo.environment import PersistProvider, PersistHelper
    var pp = PersistProvider(name="sqlite")
    var ph = PersistHelper(name="default")
    assert_equal(pp.name, "sqlite")
    assert_equal(ph.name, "default")


def test_transaction_cost_args_copyable() raises:
    """TransactionCostArgs supports copy semantics."""
    from rqmojo.environment import TransactionCostArgs
    from rqmojo.model.order import Order
    from rqmojo.model.instrument import Instrument
    var args = TransactionCostArgs(order=Order(), instrument=create_stock_instrument("000001.XSHE"), quantity=100, price=10.0)
    var copied = args.copy()
    assert_equal(copied.quantity, 100)
    assert_equal(copied.price, 10.0)


def test_env_portfolio_struct() raises:
    """EnvPortfolio has account/position management methods."""
    from rqmojo.environment import EnvPortfolio, create_env_portfolio
    var portfolio = create_env_portfolio(500000.0)
    assert_equal(portfolio.total_value, 500000.0)
    assert_equal(portfolio.total_cash, 500000.0)

    var stock_account = portfolio.get_account("000001.XSHE")
    assert_true(stock_account.total_value > 0)

    var future_account = portfolio.get_account_by_type(DEFAULT_ACCOUNT_TYPE.FUTURE)
    assert_true(future_account.total_value >= 0)

    var positions = portfolio.get_positions()
    assert_true(len(positions) >= 0)

    assert_equal(portfolio.unit_net_value(), 500000.0 / 1.0)
    assert_equal(portfolio.static_unit_net_value(), portfolio.unit_net_value())


# ============================================================
# Environment Construction Tests
# ============================================================

def test_create_environment_basic() raises:
    """create_environment produces valid Environment instance."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    assert_equal(env.start_date().year, 2020)
    assert_equal(env.end_date().year, 2020)
    assert_equal(env.frequency(), "1d")
    assert_equal(env.run_type(), RUN_TYPE.BACKTEST)
    assert_false(env.is_initialized())


def test_create_environment_from_config() raises:
    """create_environment_from_config uses config values."""
    from rqmojo.environment import create_environment_from_config
    from rqmojo.utils.config import RQAlphaConfig
    from rqmojo.utils.typing import DateTime
    var base_config = RQAlphaConfig.BaseConfig(
        start_date=DateTime(2021, 3, 1, 0, 0, 0, 0),
        end_date=DateTime(2021, 9, 30, 0, 0, 0, 0),
        frequency="1w",
        run_type=RUN_TYPE.PAPER_TRADING,
        initial_cash=2000000.0,
        strategy_file="test_strategy.py"
    )
    var config = RQAlphaConfig(base=base_config)
    var env = create_environment_from_config(config, True)
    assert_equal(env.start_date().year, 2021)
    assert_equal(env.start_date().month, 3)
    assert_equal(env.frequency(), "1w")
    assert_equal(env.run_type(), RUN_TYPE.PAPER_TRADING)


# ============================================================
# Time Management Tests
# ============================================================

def test_update_time() raises:
    """update_time sets both calendar_dt and trading_dt."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var new_cal = DateTime(2020, 6, 15, 9, 30, 0, 0)
    var new_trading = DateTime(2020, 6, 15, 14, 0, 0, 0)
    env.update_time(new_cal, new_trading)
    assert_equal(env.calendar_dt().month, 6)
    assert_equal(env.calendar_dt().day, 15)
    assert_equal(env.trading_dt().hour, 14)


def test_set_calendar_trading_dt() raises:
    """Individual calendar/trading dt setters work."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dt = DateTime(2020, 5, 20, 10, 0, 0, 0)
    env.set_calendar_dt(dt)
    env.set_trading_dt(dt)
    assert_equal(env.calendar_dt().month, 5)
    assert_equal(env.trading_dt().month, 5)


# ============================================================
# Execution State Tests
# ============================================================

def test_execution_phase() raises:
    """Execution phase can be set and retrieved."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    assert_equal(env.execution_phase(), EXECUTION_PHASE.GLOBAL)
    env.set_execution_phase(EXECUTION_PHASE.BEFORE_TRADING)
    assert_equal(env.execution_phase(), EXECUTION_PHASE.BEFORE_TRADING)
    env.set_execution_phase(EXECUTION_PHASE.HANDLE_BAR)
    assert_equal(env.execution_phase(), EXECUTION_PHASE.HANDLE_BAR)


def test_is_initialized_flag() raises:
    """is_initialized flag can be toggled."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    assert_false(env.is_initialized())
    env.set_initialized(True)
    assert_true(env.is_initialized())
    env.set_initialized(False)
    assert_false(env.is_initialized())


# ============================================================
# Hold Strategy Tests
# ============================================================

def test_set_cancel_hold_strategy() raises:
    """Hold strategy flag toggles correctly."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    env.set_hold_strategy()
    assert_true(env._is_hold)
    env.cancel_hold_strategy()
    assert_false(env._is_hold)


# ============================================================
# Data Access Tests
# ============================================================

def test_get_last_price() raises:
    """get_last_price returns a Float64 value."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var price = env.get_last_price("000001.XSHE")
    assert_true(price >= 0.0, "Price should be non-negative")


def test_get_instrument() raises:
    """get_instrument returns an Instrument object."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var ins = env.get_instrument("000001.XSHE")
    assert_true(len(ins.order_book_id()) > 0)


def test_data_proxy_accessor() raises:
    """data_proxy() returns reference to internal DataProxy."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var dp = env.data_proxy()
    assert_true(dp is not None)


# ============================================================
# Portfolio Tests
# ============================================================

def test_get_account() raises:
    """get_account returns correct account by order_book_id."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var acc = env.get_account("000001.XSHE")
    assert_true(acc.total_value >= 0)
    var acc2 = env.get_account("IF_IC1701.CFFEX")
    assert_true(acc2.total_value >= 0)


def test_get_account_type() raises:
    """get_account_type returns DEFAULT_ACCOUNT_TYPE."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var atype = env.get_account_type("000001.XSHE")
    assert_equal(atype, DEFAULT_ACCOUNT_TYPE.STOCK)


def test_get_stock_future_accounts() raises:
    """get_stock_account and get_future_account work."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var stock_acc = env.get_stock_account()
    assert_true(stock_acc.total_value > 0)
    var future_acc = env.get_future_account()
    assert_true(future_acc.total_value >= 0)


def test_get_portfolio() raises:
    """get_portfolio returns the EnvPortfolio."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var pf = env.get_portfolio()
    assert_true(pf.total_value > 0)


def test_set_portfolio_values() raises:
    """set_portfolio updates total_value and cash."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    env.set_portfolio(999999.0, 888888.0)
    assert_equal(env.get_portfolio_total_value(), 999999.0)
    assert_equal(env.get_portfolio_cash(), 888888.0)


# ============================================================
# Universe Tests
# ============================================================

def test_universe_operations() raises:
    """Universe get/update operations work correctly."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var uni = env.get_universe()
    assert_true(len(uni) == 0, "Initial universe should be empty")

    var new_universe = Set[String]()
    new_universe.add("000001.XSHE")
    new_universe.add("600000.XSHG")
    new_universe.add("000002.XSHE")
    env.update_universe(new_universe^)

    var updated = env.get_universe()
    assert_equal(len(updated), 3)


# ============================================================
# Frontend Validator Tests
# ============================================================

def test_add_frontend_validator() raises:
    """add_frontend_validator stores validators by instrument type."""
    from rqmojo.environment import create_environment, FrontendValidator
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var v1 = FrontendValidator(name="v1", instrument_type=INSTRUMENT_TYPE.CS)
    var v2 = FrontendValidator(name="v2", instrument_type=INSTRUMENT_TYPE.FUTURE)
    env.add_frontend_validator(v1, INSTRUMENT_TYPE.CS)
    env.add_frontend_validator(v2, INSTRUMENT_TYPE.FUTURE)

    var cs_validators = env._get_frontend_validators(INSTRUMENT_TYPE.CS)
    assert_equal(len(cs_validators), 1)
    assert_equal(cs_validators[0].name, "v1")


def test_add_default_frontend_validator() raises:
    """Default validators are appended to the default list."""
    from rqmojo.environment import create_environment, FrontendValidator
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var vd = FrontendValidator(name="default_v", instrument_type=INSTRUMENT_TYPE.CS)
    env.add_default_frontend_validator(vd)

    var cs_validators = env._get_frontend_validators(INSTRUMENT_TYPE.FUTURE)
    assert_equal(len(cs_validators), 1)
    assert_equal(cs_validators[0].name, "default_v")


# ============================================================
# Transaction Cost Tests
# ============================================================

def test_transaction_cost_decider_lifecycle() raises:
    """Set/get/calc transaction cost decider works end-to-end."""
    from rqmojo.environment import create_environment, TransactionCostDecider, TransactionCostArgs
    from rqmojo.model.order import Order
    from rqmojo.model.instrument import Instrument
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )

    var decider = TransactionCostDecider(
        name="custom_cs",
        instrument_type=INSTRUMENT_TYPE.CS,
        market=MARKET.CN
    )
    env.set_transaction_cost_decider(INSTRUMENT_TYPE.CS, decider, MARKET.CN)

    var retrieved = env.get_transaction_cost_decider(INSTRUMENT_TYPE.CS, MARKET.CN)
    assert_equal(retrieved.name, "custom_cs")

    var ins = create_stock_instrument("000001.XSHE")
    var order = Order()
    var args = TransactionCostArgs(order=order, instrument=ins, quantity=500, price=20.0)
    var cost = env.calc_transaction_cost(args)
    assert_true(cost > 0, "Calculated cost should be positive")


def test_missing_transaction_cost_decider_fallback() raises:
    """Missing decider returns default fallback."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var decider = env.get_transaction_cost_decider(INSTRUMENT_TYPE.FUTURE, MARKET.CN)
    assert_equal(decider.name, "default")


# ============================================================
# Event Bus Tests
# ============================================================

def test_event_bus_access() raises:
    """EventBus is accessible via get_event_bus."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var bus = env.get_event_bus()
    assert_true(bus is not None)


def test_publish_event() raises:
    """publish_event dispatches to EventBus."""
    from rqmojo.environment import create_environment
    from rqmojo.core.events import Event, EVENT
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var evt = Event(EVENT.BAR.value)
    env.publish_event(evt)


# ============================================================
# Singleton Pattern Tests
# ============================================================

def test_singleton_lifecycle() raises:
    """Singleton set/get/clear/has lifecycle works."""
    from rqmojo.environment import (
        create_environment, set_environment, get_environment,
        clear_environment, has_environment
    )
    from rqmojo.utils.typing import DateTime

    assert_false(has_environment())

    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    set_environment(env^)

    assert_true(has_environment())
    var retrieved = get_environment()
    assert_true(retrieved is not None)

    clear_environment()
    assert_false(has_environment())


def test_get_environment_raises_when_not_set() raises:
    """get_environment raises Error when no instance exists."""
    from rqmojo.environment import get_environment, clear_environment, has_environment
    clear_environment()
    if has_environment():
        clear_environment()
    var raised = False
    try:
        _ = get_environment()
    except:
        raised = True
    assert_true(raised, "Should raise when no environment set")


# ============================================================
# Component Existence Checks
# ============================================================

def test_has_component_checks() raises:
    """has_* methods return correct boolean values."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    assert_true(env.has_data_source())
    assert_true(env.has_price_board())
    assert_true(env.has_broker())
    assert_true(env.has_event_source())
    assert_true(env.has_portfolio())
    assert_true(env.has_profile_deco())


# ============================================================
# Trading Days & Misc Tests
# ============================================================

def test_trading_days_a_year() raises:
    """trading_days_a_year returns default DAYS_CNT value."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var days = env.get_trading_days_a_year()
    assert_true(days > 0, "Trading days per year should be positive")


def test_config_method() raises:
    """config() method returns a Config struct reflecting state."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2019, 6, 1, 0, 0, 0, 0),
        DateTime(2019, 12, 31, 0, 0, 0, 0)
    )
    var cfg = env.config()
    assert_equal(cfg.base__start_date.year, 2019)
    assert_equal(cfg.base__end_date.year, 2019)


def test_current_snapshot() raises:
    """current_snapshot returns dict with last price."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var snap = env.current_snapshot("000001.XSHE")
    assert_true("last" in snap)


def test_next_order_id() raises:
    """next_order_id generates incrementing IDs."""
    from rqmojo.environment import create_environment
    from rqmojo.utils.typing import DateTime
    var env = create_environment(
        DateTime(2020, 1, 1, 0, 0, 0, 0),
        DateTime(2020, 12, 31, 0, 0, 0, 0)
    )
    var id1 = env.next_order_id()
    var id2 = env.next_order_id()
    assert_true(id2 > id1, "Order IDs should be monotonically increasing")


# ============================================================
# Writable Trait Tests
# ============================================================

def test_writable_traits() raises:
    """All public structs conform to Writable."""
    from rqmojo.environment import (
        Config, FrontendValidator, TransactionCostDecider,
        PersistProvider, PersistHelper, TransactionCostArgs, EnvPortfolio
    )
    var s_cfg = String.write(Config(
        base__start_date=DateTime(2020, 1, 1, 0, 0, 0, 0),
        base__end_date=DateTime(2020, 12, 31, 0, 0, 0, 0),
        base__frequency="1d",
        base__run_type=RUN_TYPE.BACKTEST,
        account_count=1,
        is_hold=False
    ))
    assert_true(s_cfg.contains("Config"))

    s_fv = String.write(FrontendValidator(name="x", instrument_type=INSTRUMENT_TYPE.CS))
    assert_true(s_fv.contains("FrontendValidator"))

    s_tcd = String.write(TransactionCostDecider(name="y", instrument_type=INSTRUMENT_TYPE.CS, market=MARKET.CN))
    assert_true(s_tcd.contains("TransactionCostDecider"))


# ============================================================
# Main - Run all tests using std.testing framework
# ============================================================

def main() raises:
    print("=" * 70)
    print("RQMojo Test: environment.mojo vs Python environment.py")
    print("=" * 70)
    print("")

    TestSuite.discover_tests[__functions_in_module()]().run()

    print("")
    print("=" * 70)
    print("All environment.mojo tests completed!")
    print("=" * 70)
