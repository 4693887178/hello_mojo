"""
Position Queue Tests - Mojo Version
Tests for position_queue functionality using rqmojo
Ported from tests/integration_tests/test_api/test_position_queue.py
"""

from std.testing import assert_equal, assert_true, assert_false
from std.collections import Dict, List
from rqmojo.const import (
    SIDE, POSITION_EFFECT, ORDER_TYPE, ORDER_STATUS, POSITION_DIRECTION,
    SIDE_BUY, SIDE_SELL, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE,
    ORDER_STATUS_FILLED, ORDER_STATUS_CANCELLED, POSITION_DIRECTION_LONG,
    POSITION_DIRECTION_SHORT, ORDER_TYPE_LIMIT, ORDER_TYPE_MARKET,
    POSITION_EFFECT_CLOSE_TODAY
)
from rqmojo.model.order import Order, MarketOrder, LimitOrder, create_order_with_id
from rqmojo.model.trade import Trade, create_trade
from rqmojo.model.instrument import Instrument, create_stock_instrument, create_future_instrument
from rqmojo.environment import Environment, create_environment
from rqmojo.portfolio.position import Position, create_stock_position, create_future_position
from rqmojo.portfolio.position_queue import PositionQueue, PositionQueueItem, create_position_queue
from rqmojo.portfolio.account import Account, create_stock_account, create_future_account
from rqmojo.utils.datetime_func import DateTime, Date


def test_position_queue_basic() raises:
    print("=== Testing PositionQueue Basic ===")
    
    var queue = create_position_queue()
    assert_equal(queue.len(), 0)
    assert_true(queue.is_empty())
    
    var date1 = Date(2016, 3, 7)
    queue.push(date1, 1000)
    assert_equal(queue.len(), 1)
    assert_equal(queue.total_quantity(), 1000)
    
    var item = queue.get_item(0)
    assert_equal(item.quantity, 1000)
    
    print("Test test_position_queue_basic: PASSED")


def test_position_queue_fifo() raises:
    print("=== Testing PositionQueue FIFO ===")
    
    var queue = create_position_queue()
    var date1 = Date(2016, 3, 7)
    var date2 = Date(2016, 3, 8)
    
    queue.push(date1, 1000)
    queue.push(date2, 500)
    
    assert_equal(queue.len(), 2)
    assert_equal(queue.total_quantity(), 1500)
    
    queue.pop(800)
    
    assert_equal(queue.len(), 2)
    assert_equal(queue.total_quantity(), 700)
    
    var item0 = queue.get_item(0)
    assert_equal(item0.quantity, 200)
    assert_equal(item0.date.year, 2016)
    assert_equal(item0.date.month, 3)
    assert_equal(item0.date.day, 7)
    
    print("Test test_position_queue_fifo: PASSED")


def test_position_queue_clear() raises:
    print("=== Testing PositionQueue Clear ===")
    
    var queue = create_position_queue()
    var date1 = Date(2016, 3, 7)
    var date2 = Date(2016, 3, 8)
    
    queue.push(date1, 1000)
    queue.push(date2, 500)
    
    assert_equal(queue.len(), 2)
    
    queue.clear()
    
    assert_equal(queue.len(), 0)
    assert_true(queue.is_empty())
    
    print("Test test_position_queue_clear: PASSED")


def test_stock_position_queue_open_close() raises:
    print("=== Testing Stock Position Queue Open Close ===")
    
    var pos = create_stock_position("000001.XSHE")
    assert_equal(pos.quantity, 0)
    
    var queue = create_position_queue()
    var date1 = Date(2016, 3, 7)
    queue.push(date1, 1000)
    
    assert_equal(queue.len(), 1)
    assert_equal(queue.total_quantity(), 1000)
    
    var date2 = Date(2016, 3, 8)
    queue.push(date2, 500)
    
    assert_equal(queue.len(), 2)
    assert_equal(queue.total_quantity(), 1500)
    
    queue.pop(800)
    
    assert_equal(queue.total_quantity(), 700)
    
    var item0 = queue.get_item(0)
    assert_equal(item0.quantity, 200)
    
    print("Test test_stock_position_queue_open_close: PASSED")


def test_position_queue_full_close() raises:
    print("=== Testing PositionQueue Full Close ===")
    
    var queue = create_position_queue()
    
    queue.push(Date(2016, 3, 7), 1000)
    
    assert_equal(queue.len(), 1)
    
    queue.pop(1000)
    
    assert_equal(queue.len(), 0)
    
    print("Test test_position_queue_full_close: PASSED")


def test_position_queue_multiple_operations() raises:
    print("=== Testing PositionQueue Multiple Operations ===")
    
    var queue = create_position_queue()
    
    queue.push(Date(2016, 3, 7), 1000)
    queue.push(Date(2016, 3, 8), 500)
    queue.push(Date(2016, 3, 9), 200)
    
    assert_equal(queue.len(), 3)
    
    queue.pop(1200)
    
    assert_equal(queue.len(), 2)
    
    var item0 = queue.get_item(0)
    var item1 = queue.get_item(1)
    assert_equal(item0.quantity, 300)
    assert_equal(item1.quantity, 200)
    
    print("Test test_position_queue_multiple_operations: PASSED")


def test_future_position_queue() raises:
    print("=== Testing Future Position Queue ===")
    
    var pos = create_future_position("IF1603", POSITION_DIRECTION_LONG)
    assert_equal(pos.quantity, 0)
    assert_equal(pos.order_book_id, "IF1603")
    
    var queue = create_position_queue()
    queue.push(Date(2016, 3, 7), 2)
    
    assert_equal(queue.len(), 1)
    
    queue.pop(1)
    
    assert_equal(queue.len(), 1)
    
    print("Test test_future_position_queue: PASSED")


def test_position_queue_item() raises:
    print("=== Testing PositionQueueItem ===")
    
    var item = queue_get_item_helper()
    
    assert_equal(item.date.year, 2016)
    assert_equal(item.date.month, 3)
    assert_equal(item.date.day, 7)
    assert_equal(item.quantity, 1000)
    
    print("Test test_position_queue_item: PASSED")


def queue_get_item_helper() -> PositionQueueItem:
    var queue = create_position_queue()
    queue.push(Date(2016, 3, 7), 1000)
    return queue.get_item(0)


def test_position_queue_iteration() raises:
    print("=== Testing PositionQueue Iteration ===")
    
    var queue = create_position_queue()
    queue.push(Date(2016, 3, 7), 1000)
    queue.push(Date(2016, 3, 8), 500)
    queue.push(Date(2016, 3, 9), 200)
    
    var total = 0
    for i in range(queue.len()):
        var item = queue.get_item(i)
        total += item.quantity
    
    assert_equal(total, 1700)
    
    print("Test test_position_queue_iteration: PASSED")


def test_position_queue_pop_partial() raises:
    print("=== Testing PositionQueue Pop Partial ===")
    
    var queue = create_position_queue()
    queue.push(Date(2016, 3, 7), 1000)
    queue.push(Date(2016, 3, 8), 500)
    
    queue.pop(300)
    
    assert_equal(queue.len(), 2)
    assert_equal(queue.total_quantity(), 1200)
    
    var item0 = queue.get_item(0)
    assert_equal(item0.quantity, 700)
    
    print("Test test_position_queue_pop_partial: PASSED")


def test_position_queue_pop_multiple_items() raises:
    print("=== Testing PositionQueue Pop Multiple Items ===")
    
    var queue = create_position_queue()
    queue.push(Date(2016, 3, 7), 1000)
    queue.push(Date(2016, 3, 8), 500)
    queue.push(Date(2016, 3, 9), 300)
    
    queue.pop(1200)
    
    assert_equal(queue.len(), 2)
    assert_equal(queue.total_quantity(), 600)
    
    var item0 = queue.get_item(0)
    assert_equal(item0.quantity, 300)
    
    print("Test test_position_queue_pop_multiple_items: PASSED")


def main() raises:
    print("=" * 60)
    print("Running test_position_queue.mojo")
    print("=" * 60)
    print("")
    
    test_position_queue_basic()
    test_position_queue_fifo()
    test_position_queue_clear()
    test_stock_position_queue_open_close()
    test_position_queue_full_close()
    test_position_queue_multiple_operations()
    test_future_position_queue()
    test_position_queue_item()
    test_position_queue_iteration()
    test_position_queue_pop_partial()
    test_position_queue_pop_multiple_items()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
