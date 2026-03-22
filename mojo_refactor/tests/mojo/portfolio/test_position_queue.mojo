"""
Position Queue Tests - Mojo Version
Tests for position_queue functionality using rqmojo
"""

from std.testing import assert_equal, assert_true, assert_false
from rqmojo.portfolio.position import Position, create_position, create_stock_position
from rqmojo.portfolio.position_queue import PositionQueue, PositionQueueItem, create_position_queue
from rqmojo.const import SIDE, POSITION_EFFECT, POSITION_DIRECTION, POSITION_DIRECTION_LONG, POSITION_DIRECTION_SHORT, POSITION_EFFECT_OPEN, POSITION_EFFECT_CLOSE, POSITION_EFFECT_CLOSE_TODAY, SIDE_BUY, SIDE_SELL
from rqmojo.model.trade import Trade, create_trade_from_order
from rqmojo.utils.datetime_func import DateTime, Date


fn test_position_queue_basic() raises:
    print("=== Testing PositionQueue Basic ===")
    
    var queue = create_position_queue()
    assert_equal(queue.len(), 0, "Empty queue should have length 0")
    assert_true(queue.is_empty(), "Empty queue should be empty")
    
    var date1 = Date(2016, 3, 7)
    queue.push(date1, 1000)
    assert_equal(queue.len(), 1, "Queue should have 1 item after push")
    assert_equal(queue.total_quantity(), 1000, "Total quantity should be 1000")
    
    var item = queue.get_item(0)
    assert_equal(item.quantity, 1000, "Item quantity should be 1000")
    
    print("Test test_position_queue_basic: PASSED")


fn test_position_queue_fifo() raises:
    print("=== Testing PositionQueue FIFO ===")
    
    var queue = create_position_queue()
    var date1 = Date(2016, 3, 7)
    var date2 = Date(2016, 3, 8)
    
    queue.push(date1, 1000)
    queue.push(date2, 500)
    
    assert_equal(queue.len(), 2, "Queue should have 2 items")
    assert_equal(queue.total_quantity(), 1500, "Total quantity should be 1500")
    
    queue.pop(800)
    
    assert_equal(queue.len(), 2, "Queue should still have 2 items after partial pop")
    assert_equal(queue.total_quantity(), 700, "Total quantity should be 700")
    
    var item0 = queue.get_item(0)
    assert_equal(item0.quantity, 200, "First item should have 200 remaining")
    assert_equal(item0.date.year, 2016, "First item date year should be 2016")
    assert_equal(item0.date.month, 3, "First item date month should be 3")
    assert_equal(item0.date.day, 7, "First item date day should be 7")
    
    print("Test test_position_queue_fifo: PASSED")


fn test_position_queue_clear() raises:
    print("=== Testing PositionQueue Clear ===")
    
    var queue = create_position_queue()
    var date1 = Date(2016, 3, 7)
    var date2 = Date(2016, 3, 8)
    
    queue.push(date1, 1000)
    queue.push(date2, 500)
    
    assert_equal(queue.len(), 2, "Queue should have 2 items")
    
    queue.clear()
    
    assert_equal(queue.len(), 0, "Queue should be empty after clear")
    assert_true(queue.is_empty(), "Queue should be empty after clear")
    
    print("Test test_position_queue_clear: PASSED")


fn test_position_with_queue() raises:
    print("=== Testing Position with PositionQueue ===")
    
    var pos = create_stock_position("000001.XSHE")
    assert_equal(pos.quantity, 0, "Initial quantity should be 0")
    assert_equal(pos.position_queue().len(), 0, "Initial queue should be empty")
    
    var trade1 = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1000, 10.0
    )
    
    var date1 = Date(2016, 3, 7)
    _ = pos.apply_trade_with_date(trade1, date1)
    
    assert_equal(pos.quantity, 1000, "Quantity should be 1000 after first trade")
    assert_equal(pos.position_queue().len(), 1, "Queue should have 1 item")
    assert_equal(pos.position_queue().total_quantity(), 1000, "Queue total should be 1000")
    
    var trade2 = create_trade_from_order(
        2, 2, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 500, 11.0
    )
    
    var date2 = Date(2016, 3, 8)
    _ = pos.apply_trade_with_date(trade2, date2)
    
    assert_equal(pos.quantity, 1500, "Quantity should be 1500 after second trade")
    assert_equal(pos.position_queue().len(), 2, "Queue should have 2 items")
    assert_equal(pos.position_queue().total_quantity(), 1500, "Queue total should be 1500")
    
    print("Test test_position_with_queue: PASSED")


fn test_position_queue_close() raises:
    print("=== Testing PositionQueue Close ===")
    
    var pos = create_stock_position("000001.XSHE")
    
    var trade1 = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1000, 10.0
    )
    _ = pos.apply_trade_with_date(trade1, Date(2016, 3, 7))
    
    var trade2 = create_trade_from_order(
        2, 2, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 500, 11.0
    )
    _ = pos.apply_trade_with_date(trade2, Date(2016, 3, 8))
    
    assert_equal(pos.quantity, 1500, "Quantity should be 1500")
    assert_equal(pos.position_queue().len(), 2, "Queue should have 2 items")
    
    var trade3 = create_trade_from_order(
        3, 3, "000001.XSHE", SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, 800, 12.0
    )
    _ = pos.apply_trade_with_date(trade3, Date(2016, 3, 9))
    
    assert_equal(pos.quantity, 700, "Quantity should be 700 after close")
    assert_equal(pos.position_queue().len(), 2, "Queue should still have 2 items")
    assert_equal(pos.position_queue().total_quantity(), 700, "Queue total should be 700")
    
    var item0 = pos.position_queue().get_item(0)
    assert_equal(item0.quantity, 200, "First item should have 200 remaining")
    
    print("Test test_position_queue_close: PASSED")


fn test_position_queue_full_close() raises:
    print("=== Testing PositionQueue Full Close ===")
    
    var pos = create_stock_position("000001.XSHE")
    
    var trade1 = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1000, 10.0
    )
    _ = pos.apply_trade_with_date(trade1, Date(2016, 3, 7))
    
    assert_equal(pos.quantity, 1000, "Quantity should be 1000")
    assert_equal(pos.position_queue().len(), 1, "Queue should have 1 item")
    
    var trade2 = create_trade_from_order(
        2, 2, "000001.XSHE", SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, 1000, 12.0
    )
    _ = pos.apply_trade_with_date(trade2, Date(2016, 3, 8))
    
    assert_equal(pos.quantity, 0, "Quantity should be 0 after full close")
    assert_equal(pos.position_queue().len(), 0, "Queue should be empty after full close")
    
    print("Test test_position_queue_full_close: PASSED")


fn test_position_queue_multiple_operations() raises:
    print("=== Testing PositionQueue Multiple Operations ===")
    
    var pos = create_stock_position("000001.XSHE")
    
    var trade1 = create_trade_from_order(
        1, 1, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 1000, 10.0
    )
    _ = pos.apply_trade_with_date(trade1, Date(2016, 3, 7))
    
    var trade2 = create_trade_from_order(
        2, 2, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 500, 11.0
    )
    _ = pos.apply_trade_with_date(trade2, Date(2016, 3, 8))
    
    var trade3 = create_trade_from_order(
        3, 3, "000001.XSHE", SIDE_BUY, POSITION_EFFECT_OPEN, POSITION_DIRECTION_LONG, 200, 12.0
    )
    _ = pos.apply_trade_with_date(trade3, Date(2016, 3, 9))
    
    assert_equal(pos.quantity, 1700, "Quantity should be 1700")
    assert_equal(pos.position_queue().len(), 3, "Queue should have 3 items")
    
    var trade4 = create_trade_from_order(
        4, 4, "000001.XSHE", SIDE_SELL, POSITION_EFFECT_CLOSE, POSITION_DIRECTION_LONG, 1200, 13.0
    )
    _ = pos.apply_trade_with_date(trade4, Date(2016, 3, 10))
    
    assert_equal(pos.quantity, 500, "Quantity should be 500 after close")
    assert_equal(pos.position_queue().len(), 2, "Queue should have 2 items")
    
    var item0 = pos.position_queue().get_item(0)
    var item1 = pos.position_queue().get_item(1)
    assert_equal(item0.quantity, 300, "First item should have 300 remaining")
    assert_equal(item1.quantity, 200, "Second item should have 200 remaining")
    
    print("Test test_position_queue_multiple_operations: PASSED")


fn main() raises:
    print("=" * 60)
    print("Running test_position_queue.mojo")
    print("=" * 60)
    print("")
    
    test_position_queue_basic()
    test_position_queue_fifo()
    test_position_queue_clear()
    test_position_with_queue()
    test_position_queue_close()
    test_position_queue_full_close()
    test_position_queue_multiple_operations()
    
    print("")
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
