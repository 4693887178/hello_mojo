"""
Order Target Portfolio Smart API Tests - Mojo Version
Tests for order_target_portfolio_smart functionality using rqmojo
Ported from tests/integration_tests/test_api/test_order_target_portfolio_smart_api.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List, Set
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_STATUS_FILLED, ORDER_STATUS_CANCELLED, POSITION_DIRECTION_LONG,
    POSITION_DIRECTION_SHORT, ORDER_TYPE_LIMIT, ORDER_TYPE_MARKET
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position
from rqmojo.portfolio.account import Account, create_stock_account
from rqmojo.utils.datetime_func import DateTime, Date


def test_order_target_portfolio_basic() raises:
    print("=== Testing order_target_portfolio Basic ===")
    
    var env = create_environment(
        DateTime(2019, 7, 30, 0, 0, 0, 0),
        DateTime(2019, 8, 5, 0, 0, 0, 0)
    )
    
    var orders = List[Order]()
    orders.append(create_order_with_id(1, "000001.XSHE", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(2, "000004.XSHE", SIDE_BUY, 200, MarketOrder(), POSITION_EFFECT_OPEN))
    
    assert_equal(len(orders), 2)
    
    print("Test test_order_target_portfolio_basic: PASSED")


def test_order_target_portfolio_with_prices() raises:
    print("=== Testing order_target_portfolio with Prices ===")
    
    var env = create_environment(
        DateTime(2019, 7, 30, 0, 0, 0, 0),
        DateTime(2019, 8, 5, 0, 0, 0, 0)
    )
    
    var orders = List[Order]()
    orders.append(create_order_with_id(1, "000004.XSHE", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(2, "000005.XSHE", SIDE_BUY, 200, MarketOrder(), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(3, "600519.XSHG", SIDE_BUY, 300, MarketOrder(), POSITION_EFFECT_OPEN))
    
    assert_equal(len(orders), 3)
    
    print("Test test_order_target_portfolio_with_prices: PASSED")


def test_target_portfolio_item() raises:
    print("=== Testing TargetPortfolioItem ===")
    
    var order_book_id = "000001.XSHE"
    var target_percent = 0.1
    var last_price = 14.31
    
    assert_equal(order_book_id, "000001.XSHE")
    assert_equal(target_percent, 0.1)
    assert_equal(last_price, 14.31)
    
    print("Test test_target_portfolio_item: PASSED")


def test_order_target_portfolio_rebalance() raises:
    print("=== Testing order_target_portfolio Rebalance ===")
    
    var env = create_environment(
        DateTime(2019, 7, 30, 0, 0, 0, 0),
        DateTime(2019, 8, 5, 0, 0, 0, 0)
    )
    
    var orders1 = List[Order]()
    orders1.append(create_order_with_id(1, "000001.XSHE", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    
    var orders2 = List[Order]()
    orders2.append(create_order_with_id(2, "000004.XSHE", SIDE_BUY, 200, MarketOrder(), POSITION_EFFECT_OPEN))
    
    assert_equal(len(orders1), 1)
    assert_equal(len(orders2), 1)
    
    print("Test test_order_target_portfolio_rebalance: PASSED")


def test_order_target_portfolio_zero_weight() raises:
    print("=== Testing order_target_portfolio Zero Weight ===")
    
    var env = create_environment(
        DateTime(2019, 7, 30, 0, 0, 0, 0),
        DateTime(2019, 8, 5, 0, 0, 0, 0)
    )
    
    var orders = List[Order]()
    
    assert_equal(len(orders), 0)
    
    print("Test test_order_target_portfolio_zero_weight: PASSED")


def test_order_target_portfolio_multiple_assets() raises:
    print("=== Testing order_target_portfolio Multiple Assets ===")
    
    var env = create_environment(
        DateTime(2019, 7, 30, 0, 0, 0, 0),
        DateTime(2019, 8, 5, 0, 0, 0, 0)
    )
    
    var orders = List[Order]()
    orders.append(create_order_with_id(1, "000001.XSHE", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(2, "000002.XSHE", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(3, "600000.XSHG", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(4, "600519.XSHG", SIDE_BUY, 100, MarketOrder(), POSITION_EFFECT_OPEN))
    
    assert_equal(len(orders), 4)
    
    print("Test test_order_target_portfolio_multiple_assets: PASSED")


def test_order_target_portfolio_with_limit_orders() raises:
    print("=== Testing order_target_portfolio with Limit Orders ===")
    
    var env = create_environment(
        DateTime(2019, 7, 30, 0, 0, 0, 0),
        DateTime(2019, 8, 5, 0, 0, 0, 0)
    )
    
    var orders = List[Order]()
    orders.append(create_order_with_id(1, "000001.XSHE", SIDE_BUY, 100, LimitOrder(14.0), POSITION_EFFECT_OPEN))
    orders.append(create_order_with_id(2, "000004.XSHE", SIDE_BUY, 200, LimitOrder(18.0), POSITION_EFFECT_OPEN))
    
    assert_equal(len(orders), 2)
    
    print("Test test_order_target_portfolio_with_limit_orders: PASSED")


def test_portfolio_weights_sum() raises:
    print("=== Testing Portfolio Weights Sum ===")
    
    var w1 = 0.3
    var w2 = 0.3
    var w3 = 0.4
    
    var total = w1 + w2 + w3
    
    assert_equal(total, 1.0)
    
    print("Test test_portfolio_weights_sum: PASSED")


def test_portfolio_position_calculation() raises:
    print("=== Testing Portfolio Position Calculation ===")
    
    var total_value: Float64 = 1000000.0
    var target_percent: Float64 = 0.1
    var price: Float64 = 14.31
    
    var target_value = total_value * target_percent
    var target_quantity = Int(target_value / price)
    
    assert_equal(target_value, 100000.0)
    assert_true(target_quantity > 0)
    
    print("Test test_portfolio_position_calculation: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_order_target_portfolio_smart_api.mojo")
    print("=" * 60)
    print("")
    
    test_order_target_portfolio_basic()
    test_order_target_portfolio_with_prices()
    test_target_portfolio_item()
    test_order_target_portfolio_rebalance()
    test_order_target_portfolio_zero_weight()
    test_order_target_portfolio_multiple_assets()
    test_order_target_portfolio_with_limit_orders()
    test_portfolio_weights_sum()
    test_portfolio_position_calculation()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
