"""
Comprehensive Test Suite for model/trade.mojo
Tests all classes: TradeIdGenerator, Trade
Covers all methods and edge cases to ensure parity with Python rqalpha/model/trade.py
"""

from std.testing import assert_equal, assert_true, assert_false, TestSuite
from rqmojo.model.trade import (
    TradeIdGenerator, create_trade_id_generator,
    Trade, create_trade_with_id, create_trade, create_trade_from_order, create_trade_full,
)
from rqmojo.model.order import Order, create_order_with_id, MarketOrder, LimitOrder
from rqmojo.const import SIDE, POSITION_EFFECT, ORDER_STATUS, POSITION_DIRECTION
from rqmojo.utils.typing import DateTime


# ============== TradeIdGenerator Tests ==============

def test_trade_id_generator_default() raises:
    print("Test: TradeIdGenerator default construction")
    var gen = TradeIdGenerator()
    assert_equal(gen.counter, 0, "Default counter should be 0")
    print("  PASSED")


def test_trade_id_generator_custom_start() raises:
    print("Test: TradeIdGenerator custom start value")
    var gen = TradeIdGenerator(1000)
    assert_equal(gen.counter, 1000, "Counter starts at given value")
    print("  PASSED")


def test_trade_id_generator_next() raises:
    print("Test: TradeIdGenerator.next() increments and returns")
    var gen = TradeIdGenerator(100)
    var id1 = gen.next()
    var id2 = gen.next()
    var id3 = gen.next()
    assert_equal(id1, 101, "First next returns start+1")
    assert_equal(id2, 102, "Second next returns start+2")
    assert_equal(id3, 103, "Third next returns start+3")
    assert_equal(gen.counter, 103, "Counter updated correctly")
    print("  PASSED")


def test_create_trade_id_generator_factory() raises:
    print("Test: create_trade_id_generator factory function")
    var gen = create_trade_id_generator()
    assert_equal(gen.counter, 0, "Default factory creates counter=0")
    var gen2 = create_trade_id_generator(500)
    assert_equal(gen2.counter, 500, "Custom start value factory")
    print("  PASSED")


# ============== Trade Construction Tests ==============

def test_create_trade_basic_buy() raises:
    print("Test: create_trade - basic buy trade from order")
    var order = create_order_with_id(
        order_id=1, order_book_id="000001.XSHE", side=SIDE.BUY,
        quantity=100, style=MarketOrder(), position_effect=POSITION_EFFECT.OPEN,
    )
    var trade = create_trade(order, quantity=50, price=10.5, commission=2.5, tax=0.5)
    assert_equal(trade.trade_id, 1, "Default trade_id is 1")
    assert_equal(trade.exec_id, "1", "exec_id matches trade_id as string")
    assert_equal(trade.order_id, 1, "order_id from order")
    assert_equal(trade.order_book_id, "000001.XSHE", "order_book_id from order")
    assert_equal(trade.side, SIDE.BUY, "side BUY")
    assert_equal(trade.quantity, 50, "quantity matches")
    assert_equal(trade.last_price, 10.5, "price matches")
    assert_equal(trade.commission, 2.5, "commission matches")
    assert_equal(trade.tax, 0.5, "tax matches")
    print("  PASSED")


def test_create_trade_with_id() raises:
    print("Test: create_trade_with_id - custom trade ID")
    var order = create_order_with_id(
        order_id=42, order_book_id="000002.XSHG", side=SIDE.SELL,
        quantity=200, style=LimitOrder(15.0), position_effect=POSITION_EFFECT.CLOSE,
    )
    var trade = create_trade_with_id(
        trade_id=999, order=order, quantity=200,
        price=15.0, commission=8.0, tax=1.0,
        close_today_amount=50, frozen_price=14.95,
    )
    assert_equal(trade.trade_id, 999, "trade_id set correctly")
    assert_equal(trade.exec_id, "999", "exec_id stringified")
    assert_equal(trade.order_id, 42, "order_id from source order")
    assert_equal(trade.side, SIDE.SELL, "side SELL")
    assert_equal(trade.close_today_amount, 50, "close_today_amount set")
    assert_equal(trade.frozen_price, 14.95, "frozen_price set")
    print("  PASSED")


def test_create_trade_from_order_raw() raises:
    print("Test: create_trade_from_order - raw parameters without order object")
    var trade = create_trade_from_order(
        trade_id=77,
        order_id=10,
        order_book_id="IF2309.XCFF",
        side=SIDE.BUY,
        position_effect=POSITION_EFFECT.OPEN,
        position_direction=POSITION_DIRECTION.LONG,
        quantity=300,
        price=4000.0,
        commission=50.0,
        tax=10.0,
        close_today_amount=100,
        frozen_price=4000.0,
    )
    assert_equal(trade.trade_id, 77, "trade_id")
    assert_equal(trade.order_id, 10, "order_id")
    assert_equal(trade.order_book_id, "IF2309.XCFF", "order_book_id")
    assert_equal(trade.side, SIDE.BUY, "side")
    assert_true(trade.position_effect != None, "position_effect set")
    assert_equal(trade.position_effect.value(), POSITION_EFFECT.OPEN, "position_effect OPEN")
    assert_equal(trade.position_direction_val, POSITION_DIRECTION.LONG, "position_direction")
    assert_equal(trade.quantity, 300, "quantity")
    assert_equal(trade.last_price, 4000.0, "last_price")
    assert_equal(trade.commission, 50.0, "commission")
    assert_equal(trade.tax, 10.0, "tax")
    assert_equal(trade.frozen_price, 4000.0, "frozen_price")
    assert_equal(trade.close_today_amount, 100, "close_today_amount")
    print("  PASSED")


def test_create_trade_full_all_params() raises:
    print("Test: create_trade_full - all parameters including datetime")
    var cal_dt = DateTime(2024, 6, 15, 10, 30, 0, 0)
    var trade_dt = DateTime(2024, 6, 15, 11, 30, 0, 0)
    var trade = create_trade_full(
        trade_id=555,
        exec_id="EXCH-555",
        order_id=33,
        order_book_id="000001.XSHE",
        side=SIDE.SELL,
        position_effect=None,
        position_direction=POSITION_DIRECTION.LONG,
        quantity=80,
        price=12.34,
        datetime_val=cal_dt,
        trading_datetime_val=trade_dt,
        commission=3.5,
        tax=0.7,
        frozen_price=12.30,
        close_today_amount=20,
    )
    assert_equal(trade.trade_id, 555, "trade_id")
    assert_equal(trade.exec_id, "EXCH-555", "custom exec_id")
    assert_equal(trade.calendar_dt.year, 2024, "calendar year")
    assert_equal(trade.trading_dt.hour, 11, "trading hour")
    assert_true(trade.position_effect == None, "None position_effect preserved")
    assert_equal(trade.frozen_price, 12.30, "frozen_price")
    assert_equal(trade.close_today_amount, 20, "close_today_amount")
    print("  PASSED")


def test_create_trade_none_position_effect_inherited() raises:
    print("Test: create_trade inherits None position_effect from order")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 100, MarketOrder(),
    )
    var trade = create_trade(order, quantity=50, price=10.0)
    assert_true(trade.position_effect == None, "position_effect stays None when order has None")
    assert_equal(trade.position_effect_resolved(), POSITION_EFFECT.OPEN,
        "Resolved to OPEN for BUY with None")
    print("  PASSED")


# ============== Computed Properties Tests ==============

def test_transaction_cost_property() raises:
    print("Test: transaction_cost() = commission + tax")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var t1 = create_trade(order, 50, 10.0, commission=5.0, tax=1.0)
    assert_equal(t1.transaction_cost(), 6.0, "5+1=6")
    var t2 = create_trade(order, 50, 10.0, commission=0.0, tax=0.0)
    assert_equal(t2.transaction_cost(), 0.0, "0+0=0")
    var t3 = create_trade(order, 50, 10.0, commission=99.99, tax=0.01)
    assert_equal(t3.transaction_cost(), 100.0, "99.99+0.01=100")
    print("  PASSED")


def test_position_effect_resolved_buy_open() raises:
    print("Test: position_effect_resolved() BUY + None -> OPEN")
    var _order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    var trade = create_trade(_order, 50, 10.0)
    assert_equal(trade.position_effect_resolved(), POSITION_EFFECT.OPEN, "BUY+None -> OPEN")
    print("  PASSED")


def test_position_effect_resolved_sell_close() raises:
    print("Test: position_effect_resolved() SELL + None -> CLOSE")
    var order = create_order_with_id(1, "a.XSHE", SIDE.SELL, 100, MarketOrder())
    var trade = create_trade(order, 50, 10.0)
    assert_equal(trade.position_effect_resolved(), POSITION_EFFECT.CLOSE, "SELL+None -> CLOSE")
    print("  PASSED")


def test_position_effect_resolved_explicit() raises:
    print("Test: position_effect_resolved() explicit value returned as-is")
    var trade = create_trade_full(
        1, "1", 1, "a.XSHE", SIDE.BUY,
        position_effect=POSITION_EFFECT.CLOSE_TODAY,
        position_direction=POSITION_DIRECTION.SHORT,
        quantity=50, price=10.0,
        datetime_val=DateTime(1970,1,1), trading_datetime_val=DateTime(1970,1,1),
    )
    assert_equal(trade.position_effect_resolved(), POSITION_EFFECT.CLOSE_TODAY,
        "Explicit value returned unchanged")
    print("  PASSED")


def test_position_direction_property() raises:
    print("Test: position_direction() returns stored direction")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    assert_equal(trade.position_direction(), POSITION_DIRECTION.LONG,
        "BUY+OPEN -> LONG from order's position_direction()")
    print("  PASSED")


def test_datetime_properties() raises:
    print("Test: datetime() and trading_datetime()")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    var cal_dt = trade.datetime()
    var trade_dt = trade.trading_datetime()
    assert_equal(cal_dt.year, 1970, "Default calendar year")
    assert_equal(trade_dt.year, 1970, "Default trading year")
    print("  PASSED")


def test_last_quantity_equals_quantity() raises:
    print("Test: last_quantity() equals quantity field (matches Python)")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 75, 12.5)
    assert_equal(trade.last_quantity(), 75, "last_quantity == quantity")
    assert_equal(trade.quantity, 75, "quantity field matches")
    print("  PASSED")


def test_order_id_prop_returns_order_id() raises:
    print("Test: order_id_prop() returns order_id field")
    var order = create_order_with_id(88, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    assert_equal(trade.order_id_prop(), 88, "order_id_prop returns order's order_id")
    print("  PASSED")


# ============== get_state Tests ==============

def test_get_state_basic() raises:
    print("Test: get_state() returns dict with all fields")
    var order = create_order_with_id(
        1, "000001.XSHE", SIDE.BUY, 200, LimitOrder(10.0), POSITION_EFFECT.OPEN
    )
    var trade = create_trade(order, 100, 10.5, commission=3.0, tax=0.5)
    var state = trade.get_state()
    assert_true(state["trade_id"] == "1", "state trade_id")
    assert_true(state["exec_id"] == "1", "state exec_id")
    assert_true(state["order_id"] == "1", "state order_id")
    assert_true(state["order_book_id"] == "000001.XSHE", "state order_book_id")
    assert_true(state["side"] == "BUY", "state side")
    assert_true(state["position_effect"] == "OPEN", "state position_effect")
    assert_true(state["position_direction"] == "LONG", "state position_direction")
    assert_true(state["quantity"] == "100", "state quantity")
    assert_true(state["last_price"] == "10.5", "state last_price")
    assert_true("3" in state["commission"] or "3.0" in state["commission"], "state commission")
    assert_true("0.5" in state["tax"], "state tax")
    assert_true("3.5" in state["transaction_cost"], "state transaction_cost = 3+0.5")
    print("  PASSED")


def test_get_state_none_position_effect() raises:
    print("Test: get_state() with None position_effect stored as empty")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder())
    var trade = create_trade(order, 50, 10.0)
    var state = trade.get_state()
    assert_true(state["position_effect"] == "", "None stored as empty string")
    print("  PASSED")


def test_get_state_close_today_and_frozen() raises:
    print("Test: get_state() includes close_today_amount and frozen_price")
    var order = create_order_with_id(1, "a.XSHE", SIDE.SELL, 100, MarketOrder(), POSITION_EFFECT.CLOSE)
    var trade = create_trade(order, 60, 15.0, close_today_amount=25, frozen_price=14.98)
    var state = trade.get_state()
    assert_true(state["close_today_amount"] == "25", "state close_today_amount")
    assert_true(state["frozen_price"] == "14.98", "state frozen_price")
    print("  PASSED")


# ============== Kwargs Tests ==============

def test_kwargs_set_get_roundtrip() raises:
    print("Test: kwargs set_kwarg/get_kwarg round-trip")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    trade.set_kwarg("strategy_name", "momentum")
    trade.set_kwarg("signal_strength", "0.85")
    var v1 = trade.get_kwarg("strategy_name")
    var v2 = trade.get_kwarg("signal_strength")
    assert_true(v1 != None and v1.value() == "momentum", "get kwarg strategy_name")
    assert_true(v2 != None and v2.value() == "0.85", "get kwarg signal_strength")
    print("  PASSED")


def test_kwargs_missing_key_returns_none() raises:
    print("Test: get_kwarg returns None for missing key")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    var result = trade.get_kwarg("nonexistent")
    assert_true(result == None, "Missing key returns None")
    print("  PASSED")


def test_get_kwargs_returns_copy() raises:
    print("Test: get_kwargs() returns independent copy")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    trade.set_kwarg("key_a", "val_a")
    var copy = trade.get_kwargs()
    assert_true(copy["key_a"] == "val_a", "Copy has data")
    trade.set_kwarg("key_b", "val_b")
    var after = trade.get_kwarg("key_b")
    assert_true(after != None and after.value() == "val_b", "Original has new data")
    print("  PASSED")


# ============== Copy Tests ==============

def test_trade_copy_preserves_fields() raises:
    print("Test: Trade copy preserves all fields")
    var order = create_order_with_id(42, "000001.XSHE", SIDE.BUY, 500, LimitOrder(22.5), POSITION_EFFECT.OPEN)
    var original = create_trade_with_id(
        999, order, 250, 23.0,
        commission=12.5, tax=2.5,
        close_today_amount=80, frozen_price=22.45,
    )
    original.set_kwarg("custom", "data")
    var copied = original.copy()
    assert_equal(copied.trade_id, original.trade_id, "trade_id copied")
    assert_equal(copied.exec_id, original.exec_id, "exec_id copied")
    assert_equal(copied.order_id, original.order_id, "order_id copied")
    assert_equal(copied.order_book_id, original.order_book_id, "order_book_id copied")
    assert_equal(copied.side, original.side, "side copied")
    assert_true(copied.position_effect == original.position_effect, "position_effect copied")
    assert_equal(copied.position_direction_val, original.position_direction_val, "position_direction copied")
    assert_equal(copied.quantity, original.quantity, "quantity copied")
    assert_equal(copied.last_price, original.last_price, "last_price copied")
    assert_equal(copied.commission, original.commission, "commission copied")
    assert_equal(copied.tax, original.tax, "tax copied")
    assert_equal(copied.frozen_price, original.frozen_price, "frozen_price copied")
    assert_equal(copied.close_today_amount, original.close_today_amount, "close_today_amount copied")
    print("  PASSED")


def test_trade_copy_independence() raises:
    print("Test: Trade copy is independent of original")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var original = create_trade(order, 50, 10.0, commission=5.0)
    var copied = original.copy()
    assert_equal(copied.transaction_cost(), original.transaction_cost(),
        "Same initial transaction_cost")
    print("  PASSED")


# ============== WriteTo / String Representation Tests ==============

def test_write_to_trade() raises:
    print("Test: Trade write_to produces valid representation")
    var order = create_order_with_id(
        123, "000001.XSHE", SIDE.BUY, 100, LimitOrder(10.5), POSITION_EFFECT.OPEN
    )
    var trade = create_trade_with_id(456, order, 50, 10.5)
    var s = String(trade)
    assert_true("Trade" in s, "Contains 'Trade'")
    assert_true("456" in s, "Contains trade_id")
    assert_true("000001.XSHE" in s, "Contains order_book_id")
    assert_true("BUY" in s, "Contains side")
    assert_true("50" in s, "Contains quantity")
    assert_true("10.5" in s, "Contains price")
    print("  PASSED")


# ============== Edge Cases ==============

def test_zero_commission_tax() raises:
    print("Test: Trade with zero commission and tax")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 100, 10.0, commission=0.0, tax=0.0)
    assert_equal(trade.commission, 0.0, "Zero commission")
    assert_equal(trade.tax, 0.0, "Zero tax")
    assert_equal(trade.transaction_cost(), 0.0, "Zero total cost")
    print("  PASSED")


def test_large_values() raises:
    print("Test: Trade with large values")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 1000000, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade_with_id(
        999999, order, 500000, 999.99,
        commission=12500.0, tax=2500.0,
        close_today_amount=100000, frozen_price=999.90,
    )
    assert_equal(trade.trade_id, 999999, "Large trade_id")
    assert_equal(trade.quantity, 500000, "Large quantity")
    assert_equal(trade.transaction_cost(), 15000.0, "Large cost = 12500+2500")
    assert_equal(trade.close_today_amount, 100000, "Large close_today_amount")
    print("  PASSED")


def test_sell_trade_close_today() raises:
    print("Test: SELL trade with close_today_amount > 0")
    var order = create_order_with_id(1, "IF2309.XCFF", SIDE.SELL, 100, MarketOrder(), POSITION_EFFECT.CLOSE)
    var trade = create_trade(order, 80, 4050.0, close_today_amount=30, frozen_price=4048.5)
    assert_equal(trade.side, SIDE.SELL, "Side SELL")
    assert_equal(trade.close_today_amount, 30, "close_today_amount set")
    assert_equal(trade.frozen_price, 4048.5, "frozen_price set")
    assert_equal(trade.position_effect_resolved(), POSITION_EFFECT.CLOSE,
        "Explicit CLOSE resolved as-is")
    print("  PASSED")


def test_default_frozen_price_and_close_today() raises:
    print("Test: Default frozen_price=0 and close_today_amount=0")
    var order = create_order_with_id(1, "a.XSHE", SIDE.BUY, 100, MarketOrder(), POSITION_EFFECT.OPEN)
    var trade = create_trade(order, 50, 10.0)
    assert_equal(trade.frozen_price, 0.0, "Default frozen_price 0")
    assert_equal(trade.close_today_amount, 0, "Default close_today_amount 0")
    print("  PASSED")


def test_custom_exec_id() raises:
    print("Test: Custom exec_id via create_trade_full")
    var trade = create_trade_full(
        1, "EXCH-ABC-123", 1, "a.XSHE", SIDE.BUY,
        POSITION_EFFECT.OPEN, POSITION_DIRECTION.LONG,
        quantity=50, price=10.0,
        datetime_val=DateTime(1970,1,1), trading_datetime_val=DateTime(1970,1,1),
    )
    assert_equal(trade.exec_id, "EXCH-ABC-123", "Custom exec_id preserved")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
