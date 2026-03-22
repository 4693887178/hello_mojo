"""
Config Tests - Mojo Version
Tests for configuration functionality using rqmojo
Ported from tests/integration_tests/test_api/test_config.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List, Set
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    RUN_TYPE_BACKTEST, DEFAULT_ACCOUNT_TYPE_STOCK, DEFAULT_ACCOUNT_TYPE_FUTURE,
    POSITION_DIRECTION_LONG, POSITION_DIRECTION_SHORT, PERSIST_MODE_ON_CRASH,
    EXCHANGE_SHFE
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.model.trade import Trade, create_trade, create_trade_from_order
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.datetime_func import DateTime, Date
from rqmojo.core.events import EVENT, Event, EventBus


from rqmojo.model.order import OrderIdGenerator, create_order_id_generator


def test_base_config() raises:
    print("=== Testing BaseConfig ===")
    
    var start_date = DateTime(2018, 4, 1, 0, 0, 0, 0)
    var end_date = DateTime(2018, 5, 1, 0, 0, 0, 0)
    
    assert_equal(start_date.year, 2018)
    assert_equal(start_date.month, 4)
    assert_equal(end_date.month, 5)
    
    print("Test test_base_config: PASSED")


def test_environment_config() raises:
    print("=== Testing Environment Config ===")
    
    var start_date = DateTime(2018, 4, 1, 0, 0, 0, 0)
    var end_date = DateTime(2018, 5, 1, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    
    assert_equal(env.start_date().year, 2018)
    assert_equal(env.start_date().month, 4)
    assert_equal(env.end_date().month, 5)
    
    print("Test test_environment_config: PASSED")


def test_future_info_config() raises:
    print("=== Testing Future Info Config ===")
    
    var start_date = DateTime(2018, 4, 1, 0, 0, 0, 0)
    var end_date = DateTime(2018, 5, 1, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    
    var ins = create_future_instrument(
        "SC1809", "原油1809", 
        DateTime(2018, 1, 1, 0, 0, 0, 0),
        DateTime(2018, 9, 1, 0, 0, 0, 0),
        DateTime(2018, 9, 15, 0, 0, 0, 0),
        1000.0,
        EXCHANGE_SHFE,
        "SC"
    )
    assert_equal(ins.order_book_id(), "SC1809")
    assert_equal(ins.symbol(), "原油1809")
    
    print("Test test_future_info_config: PASSED")


def test_init_position_config() raises:
    print("=== Testing Init Position Config ===")
    
    var start_date = DateTime(2018, 4, 1, 0, 0, 0, 0)
    var end_date = DateTime(2018, 5, 1, 0, 0, 0, 0)
    
    var env = create_environment(start_date, end_date)
    
    var pos = create_stock_position("000006.XSHE")
    assert_equal(pos.order_book_id, "000006.XSHE")
    
    print("Test test_init_position_config: PASSED")


def test_account_types() raises:
    print("=== Testing Account Types ===")
    
    var stock_account = create_stock_account(10000000.0)
    var future_account = create_future_account(10000000000.0)
    
    assert_equal(stock_account.total_value, 10000000.0)
    assert_equal(future_account.total_value, 10000000000.0)
    
    print("Test test_account_types: PASSED")


def test_event_bus() raises:
    print("=== Testing EventBus ===")
    
    var event = Event("BAR")
    assert_equal(event.event_type, "BAR")
    
    print("Test test_event_bus: PASSED")


def test_trade_creation() raises:
    print("=== Testing Trade Creation ===")
    
    var style = MarketOrder()
    var order = create_order_with_id(
        1,
        "000001.XSHE",
        SIDE_BUY,
        100,
        style,
        POSITION_EFFECT_OPEN
    )
    
    var trade = create_trade(order, 100, 10.0)
    
    assert_equal(trade.order_book_id, "000001.XSHE")
    assert_equal(trade.quantity, 100)
    assert_equal(trade.price, 10.0)
    
    print("Test test_trade_creation: PASSED")


def test_position_direction_enum() raises:
    print("=== Testing Position Direction Enum ===")
    
    assert_equal(POSITION_DIRECTION_LONG.name(), "LONG")
    assert_equal(POSITION_DIRECTION_SHORT.name(), "SHORT")
    
    print("Test test_position_direction_enum: PASSED")


def test_run_type_enum() raises:
    print("=== Testing Run Type Enum ===")
    
    assert_equal(RUN_TYPE_BACKTEST.name(), "BACKTEST")
    
    print("Test test_run_type_enum: PASSED")


def test_default_account_type_enum() raises:
    print("=== Testing Default Account Type Enum ===")
    
    assert_equal(DEFAULT_ACCOUNT_TYPE_STOCK.name(), "STOCK")
    assert_equal(DEFAULT_ACCOUNT_TYPE_FUTURE.name(), "FUTURE")
    
    print("Test test_default_account_type_enum: PASSED")


def test_persist_mode_enum() raises:
    print("=== Testing Persist Mode Enum ===")
    
    assert_equal(PERSIST_MODE_ON_CRASH.name(), "ON_CRASH")
    
    print("Test test_persist_mode_enum: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_config.mojo")
    print("=" * 60)
    print("")
    
    test_base_config()
    test_environment_config()
    test_future_info_config()
    test_init_position_config()
    test_account_types()
    test_event_bus()
    test_trade_creation()
    test_position_direction_enum()
    test_run_type_enum()
    test_default_account_type_enum()
    test_persist_mode_enum()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
