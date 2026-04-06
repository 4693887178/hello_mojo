"""
第四组测试 - model/tick.mojo
测试Mojo版本的Tick对象模型

覆盖范围:
  1. TickObject __init__(instrument, Dict[String, TickValue]) — Variant异构字典驱动
  2. 所有属性访问器 (order_book_id, instrument, close, last, open, high, low...)
  3. isnan() NaN 检测
  4. __getitem__ 键值访问（匹配 Python __getitem__）
  5. 订单簿字段 (asks/bids/ask_vols/bid_vols) 及层级访问器
  6. Writable 反射自动生成 repr/write_to
  7. Copyable trait 验证
  8. 边界条件 (越界level, 未知key, 缺失字段fallback)
"""

from rqmojo.model.tick import (
    TickObject, TickValue,
    _default_order_book, ORDER_BOOK_LEVELS,
)
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def _make_test_instrument() raises -> Instrument:
    return create_stock_instrument(
        "000001.XSHE", "000001",
        DateTime(2024, 1, 2, 0, 0, 0, 0),
        EXCHANGE.XSHE
    )


def _make_test_datetime() -> DateTime:
    return DateTime(2024, 3, 15, 10, 30, 0, 0)


def _make_tick_dict() -> Dict[String, TickValue]:
    """Build a heterogeneous tick dict using native Mojo Variant."""
    var d = Dict[String, TickValue]()
    d["datetime"] = TickValue(_make_test_datetime())
    d["last"] = TickValue(12.5)
    d["volume"] = TickValue(10000.0)
    d["total_turnover"] = TickValue(125000.0)
    d["open"] = TickValue(12.0)
    d["high"] = TickValue(13.0)
    d["low"] = TickValue(11.8)
    d["prev_close"] = TickValue(11.9)
    d["limit_up"] = TickValue(13.09)
    d["limit_down"] = TickValue(10.71)
    d["open_interest"] = TickValue(5000.0)
    d["prev_settlement"] = TickValue(11.85)
    return d^


def _make_default_tick() raises -> TickObject:
    var inst = _make_test_instrument()
    var td = _make_tick_dict()
    return TickObject(inst^, td^)


def test_TickObject_exists() raises:
    """Verify TickObject constructible via __init__(instrument, tick_dict)."""
    var inst = _make_test_instrument()
    var td = _make_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_true(tick.last == 12.5)


def test_init_basic_fields() raises:
    """Test __init__ populates all price fields from Variant dict."""
    var tick = _make_default_tick()
    assert_equal(tick.last, 12.5)
    assert_equal(tick.open, 12.0)
    assert_equal(tick.high, 13.0)
    assert_equal(tick.low, 11.8)
    assert_equal(tick.prev_close, 11.9)


def test_init_volume_fields() raises:
    var tick = _make_default_tick()
    assert_equal(tick.volume, 10000.0)
    assert_equal(tick.total_turnover, 125000.0)


def test_init_limit_fields() raises:
    var tick = _make_default_tick()
    assert_equal(tick.limit_up, 13.09)
    assert_equal(tick.limit_down, 10.71)


def test_init_future_fields() raises:
    var tick = _make_default_tick()
    assert_equal(tick.open_interest, 5000.0)
    assert_equal(tick.prev_settlement, 11.85)


def test_order_book_id() raises:
    var tick = _make_default_tick()
    assert_equal(tick.order_book_id(), "000001.XSHE")


def test_instrument_reference() raises:
    var tick = _make_default_tick()
    assert_equal(tick.instrument().order_book_id(), "000001.XSHE")


def test_close_returns_last() raises:
    var tick = _make_default_tick()
    assert_equal(tick.close(), tick.last)


def test_isnan_normal_values() raises:
    var tick = _make_default_tick()
    assert_false(tick.isnan())


def test_isnan_nan_last() raises:
    var inst = _make_test_instrument()
    var td = _make_tick_dict()
    var nan_val = Float64(0.0) / Float64(0.0)
    td["last"] = TickValue(nan_val)
    var tick = TickObject(inst^, td^)
    assert_true(tick.isnan())


def test_isnan_nan_volume() raises:
    var inst = _make_test_instrument()
    var td = _make_tick_dict()
    var nan_val = Float64(0.0) / Float64(0.0)
    td["volume"] = TickValue(nan_val)
    var tick = TickObject(inst^, td^)
    assert_true(tick.isnan())


def test_getitem_last() raises:
    var tick = _make_default_tick()
    assert_equal(tick["last"], 12.5)


def test_getitem_open_high_low() raises:
    var tick = _make_default_tick()
    assert_equal(tick["open"], 12.0)
    assert_equal(tick["high"], 13.0)
    assert_equal(tick["low"], 11.8)


def test_getitem_volume_turnover() raises:
    var tick = _make_default_tick()
    assert_equal(tick["volume"], 10000.0)
    assert_equal(tick["total_turnover"], 125000.0)


def test_getitem_limit_future() raises:
    var tick = _make_default_tick()
    assert_equal(tick["limit_up"], 13.09)
    assert_equal(tick["limit_down"], 10.71)
    assert_equal(tick["open_interest"], 5000.0)
    assert_equal(tick["prev_settlement"], 11.85)


def test_getitem_unknown_key_fallback() raises:
    var tick = _make_default_tick()
    assert_equal(tick["nonexistent"], 0.0)
    assert_equal(tick[""], 0.0)


def test_missing_field_defaults_to_zero() raises:
    """Missing keys in tick_dict fallback to default values (like Python KeyError)."""
    var inst = _make_test_instrument()
    var empty_td = Dict[String, TickValue]()
    var tick = TickObject(inst^, empty_td^)
    assert_equal(tick.last, 0.0, "missing 'last' → default 0.0")
    assert_equal(tick.volume, 0.0, "missing 'volume' → default 0.0")
    assert_equal(tick.open, 1.0, "missing 'open' → default 1.0")
    assert_equal(tick.high, 1.0, "missing 'high' → default 1.0")
    assert_equal(tick.limit_up, 0.0, "missing 'limit_up' → default 0.0")


def test_default_order_book_length() raises:
    var ob = _default_order_book()
    assert_equal(len(ob), ORDER_BOOK_LEVELS)


def test_default_order_book_all_zeros() raises:
    var ob = _default_order_book()
    for i in range(len(ob)):
        assert_equal(ob[i], 0.0)


def test_asks_bids_default_when_missing() raises:
    """When asks/bids missing from dict, defaults to [0]*5."""
    var inst = _make_test_instrument()
    var td = _make_tick_dict()
    if "asks" in td:
        _ = td.pop("asks")
    if "bids" in td:
        _ = td.pop("bids")
    var tick = TickObject(inst^, td^)
    assert_equal(len(tick.asks), ORDER_BOOK_LEVELS)
    assert_equal(len(tick.bids), ORDER_BOOK_LEVELS)
    for i in range(ORDER_BOOK_LEVELS):
        assert_equal(tick.asks[i], 0.0)
        assert_equal(tick.bids[i], 0.0)


def test_custom_order_book_from_variant() raises:
    """Pass List[Float64] as Variant value for asks/bids."""
    var inst = _make_test_instrument()
    var td = _make_tick_dict()
    td["asks"] = TickValue([12.5, 12.6, 12.7, 12.8, 12.9])
    td["bids"] = TickValue([12.4, 12.3, 12.2, 12.1, 12.0])
    var tick = TickObject(inst^, td^)
    assert_equal(tick.get_ask(0), 12.5)
    assert_equal(tick.get_ask(4), 12.9)
    assert_equal(tick.get_bid(0), 12.4)
    assert_equal(tick.get_bid(4), 12.0)


def test_get_ask_boundary() raises:
    var tick = _make_default_tick()
    assert_equal(tick.get_ask(0), 0.0)
    assert_equal(tick.get_ask(4), 0.0)
    assert_equal(tick.get_ask(-1), 0.0)
    assert_equal(tick.get_ask(5), 0.0)
    assert_equal(tick.get_ask(99), 0.0)


def test_get_bid_boundary() raises:
    var tick = _make_default_tick()
    assert_equal(tick.get_bid(-1), 0.0)
    assert_equal(tick.get_bid(5), 0.0)


def test_get_ask_vol_boundary() raises:
    var tick = _make_default_tick()
    assert_equal(tick.get_ask_vol(-1), 0.0)
    assert_equal(tick.get_ask_vol(5), 0.0)


def test_get_bid_vol_boundary() raises:
    var tick = _make_default_tick()
    assert_equal(tick.get_bid_vol(-1), 0.0)
    assert_equal(tick.get_bid_vol(5), 0.0)


def test_repr_reflection_based() raises:
    """Test auto-generated repr via Writable reflection (no manual __repr__)."""
    var tick = _make_default_tick()
    var s = String.write(tick)
    assert_true(s.find("TickObject") >= 0)
    assert_true(s.find("000001.XSHE") >= 0)
    assert_true(s.find("12.5") >= 0)


def test_Copyable_trait() raises:
    var original = _make_default_tick()
    var copied = original.copy()
    assert_equal(copied.last, original.last)
    assert_equal(copied.volume, original.volume)
    assert_equal(copied.order_book_id(), original.order_book_id())


def test_Copyable_independence() raises:
    var original = _make_default_tick()
    var copied = original.copy()
    assert_equal(copied.last, original.last)
    assert_equal(copied.asks[0], original.asks[0])


def test___all___exports() raises:
    from rqmojo.model.tick import __all__
    var m = materialize[__all__]()
    assert_equal(len(m), 1, "__all__ should have 1 entry: TickObject")
    assert_equal(m[0], "TickObject")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
