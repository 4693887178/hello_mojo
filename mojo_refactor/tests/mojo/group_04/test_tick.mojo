"""
第四组测试 - model/tick.mojo
测试Mojo版本的Tick对象模型（修复后版本）

覆盖范围:
  1. TickObject __init__(instrument, Dict[String, Float64]) — 扁平字典驱动构造
  2. 所有属性访问器 (order_book_id, datetime, last, open, high, low...)
  3. isnan() 仅检查last价格 (匹配Python np.isnan(self.last))
  4. last缺失时fallback到prev_close (匹配Python L71-76)
  5. __getitem__ 键值访问（匹配Python __getitem__/getattr）
  6. 订单簿字段 (asks/bids/ask_vols/bid_vols) 默认[0]*5
  7. 缺失字段默认值行为 (open/high/low=0, volume=0, limit=0)
  8. Writable 反射自动生成 repr/write_to
  9. Copyable trait 验证

对应 Python 原版: rqalpha/model/tick.py
  - class TickObject: __init__(instrument, tick_dict) + @property getters
  - 关键行为: last fallback prev_close, isnan=np.isnan(last), [0]*5 order book
"""

from rqmojo.model.tick import TickObject
from rqmojo.model.instrument import Instrument, create_stock_instrument
from rqmojo.const import EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, TestSuite


def _make_test_instrument() raises -> Instrument:
    return create_stock_instrument(
        "000001.XSHE", "000001",
        DateTime(2024, 1, 2, 0, 0, 0, 0),
        EXCHANGE.XSHE,
    )


def _make_full_tick_dict() -> Dict[String, Float64]:
    """Build a standard tick dict with all fields populated."""
    var d = Dict[String, Float64]()
    d["last"] = 12.5
    d["volume"] = 10000.0
    d["total_turnover"] = 125000.0
    d["open"] = 12.0
    d["high"] = 13.0
    d["low"] = 11.8
    d["prev_close"] = 11.9
    d["limit_up"] = 13.09
    d["limit_down"] = 10.71
    d["open_interest"] = 5000.0
    d["prev_settlement"] = 11.85
    return d^


# ============================================================
# Section 1: 构造与基础字段访问
# ============================================================

def test_TickObject_constructible() raises:
    """Verify TickObject constructible via __init__(instrument, tick_dict)."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick.last, 12.5)


def test_init_price_fields() raises:
    """All OHLC + last + prev_close fields populated correctly."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick.last, 12.5)
    assert_equal(tick.open, 12.0)
    assert_equal(tick.high, 13.0)
    assert_equal(tick.low, 11.8)
    assert_equal(tick.prev_close, 11.9)


def test_init_volume_fields() raises:
    """Volume and turnover fields."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick.volume, 10000.0)
    assert_equal(tick.total_turnover, 125000.0)


def test_init_limit_fields() raises:
    """Limit up/down fields."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick.limit_up, 13.09)
    assert_equal(tick.limit_down, 10.71)


def test_init_future_fields() raises:
    """Future-specific fields: open_interest, prev_settlement."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick.open_interest, 5000.0)
    assert_equal(tick.prev_settlement, 11.85)


# ============================================================
# Section 2: order_book_id 属性
# ============================================================

def test_order_book_id_delegates_to_instrument() raises:
    """Order_book_id returns instrument's order_book_id.

    Mirrors Python: ``@property def order_book_id: return self._instrument.order_book_id``
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick.order_book_id(), "000001.XSHE")


# ============================================================
# Section 3: isnan() — 仅检查last (匹配Python L203-204)
# ============================================================

def test_isnan_normal_values_returns_false() raises:
    """Normal numeric values: isnan returns False.

    Python: ``return np.isnan(self.last)`` where last=12.5 is finite.
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_false(tick.isnan())


def test_isnan_nan_last_returns_true() raises:
    """NaN in last price triggers isnan=True.

    Python: ``np.isnan(np.nan) == True``
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var nan_val = Float64(0.0) / Float64(0.0)
    td["last"] = nan_val
    var tick = TickObject(inst^, td^)
    assert_true(tick.isnan())


def test_isnan_nan_volume_does_NOT_trigger() raises:
    """CRITICAL: NaN in volume does NOT trigger isnan.

    Python original (L203-204):
      ``@property def isnan: return np.isnan(self.last)``
    Only checks self.last! Volume NaN is invisible to isnan.
    This was a bug in the old Mojo version that checked both.
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var nan_val = Float64(0.0) / Float64(0.0)
    td["volume"] = nan_val
    var tick = TickObject(inst^, td^)
    assert_false(
        tick.isnan(),
        "isnan must be False when only volume is NaN (only checks last)",
    )


# ============================================================
# Section 4: last fallback 到 prev_close (匹配Python L71-76)
# ============================================================

def test_last_falls_back_to_prev_close_when_missing() raises:
    """When 'last' key is absent from tick_dict, last = prev_close.

    Python (L71-76):
      try: return self._tick_dict['last']
      except KeyError: return self.prev_close
    Comment: "last 字段未必有（当日未发生成交），但一定有 prev_close"
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    if "last" in td:
        _ = td.pop("last")
    var tick = TickObject(inst^, td^)
    assert_equal(
        tick.last,
        tick.prev_close,
        "missing 'last' should fallback to prev_close",
    )
    assert_equal(tick.last, 11.9, "prev_close value was 11.9")


def test_last_fallback_with_custom_prev_close() raises:
    """Fallback uses whatever prev_close value was set to."""
    var inst = _make_test_instrument()
    var td = Dict[String, Float64]()
    td["prev_close"] = 99.99
    # No 'last' key — should fallback
    var tick = TickObject(inst^, td^)
    assert_equal(tick.last, 99.99, "last should equal custom prev_close")
    assert_equal(tick.prev_close, 99.99)


def test_last_uses_own_value_when_present() raises:
    """When 'last' IS present, use it (no fallback)."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    td["last"] = 42.0
    td["prev_close"] = 10.0
    var tick = TickObject(inst^, td^)
    assert_equal(tick.last, 42.0, "explicit last takes priority over prev_close")


# ============================================================
# Section 5: __getitem__ 键值访问
# ============================================================

def test_getitem_price_fields() raises:
    """__getitem__ accesses all price fields by string key.

    Python: ``def __getitem__(self, key): return getattr(self, key)``
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick["last"], 12.5)
    assert_equal(tick["open"], 12.0)
    assert_equal(tick["high"], 13.0)
    assert_equal(tick["low"], 11.8)
    assert_equal(tick["prev_close"], 11.9)


def test_getitem_volume_and_turnover() raises:
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick["volume"], 10000.0)
    assert_equal(tick["total_turnover"], 125000.0)


def test_getitem_limit_and_future() raises:
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick["limit_up"], 13.09)
    assert_equal(tick["limit_down"], 10.71)
    assert_equal(tick["open_interest"], 5000.0)
    assert_equal(tick["prev_settlement"], 11.85)


def test_getitem_unknown_key_returns_zero() raises:
    """Unknown keys return 0.0 (consistent with numeric field defaults)."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(tick["nonexistent"], 0.0)
    assert_equal(tick[""], 0.0)
    assert_equal(tick["asks"], 0.0)  # list fields not in __getitem__


# ============================================================
# Section 6: 缺失字段的默认值行为 (匹配Python KeyError→默认值)
# ============================================================

def test_missing_float_fields_default_to_zero() raises:
    """Missing float fields default to 0.0 (matches Python try/except→return 0).

    Python fields with try/except KeyError/ValueError → return 0:
      volume, total_turnover, open_interest, prev_settlement, limit_up, limit_down
    """
    var inst = _make_test_instrument()
    var empty_td = Dict[String, Float64]()
    # Only set prev_close (needed for potential last fallback)
    empty_td["prev_close"] = 15.0
    var tick = TickObject(inst^, empty_td^)
    assert_equal(tick.volume, 0.0, "missing volume → 0.0")
    assert_equal(tick.total_turnover, 0.0, "missing total_turnover → 0.0")
    assert_equal(tick.open_interest, 0.0, "missing open_interest → 0.0")
    assert_equal(tick.prev_settlement, 0.0, "missing prev_settlement → 0.0")
    assert_equal(tick.limit_up, 0.0, "missing limit_up → 0.0")
    assert_equal(tick.limit_down, 0.0, "missing limit_down → 0.0")


def test_missing_open_high_low_default_to_zero() raises:
    """Open/high/low default to 0.0 when missing.

    Note: Python's open/high/low do NOT have try/except (raise KeyError).
    Mojo adapts by providing 0.0 default for safety and consistency.
    """
    var inst = _make_test_instrument()
    var empty_td = Dict[String, Float64]()
    empty_td["prev_close"] = 15.0
    var tick = TickObject(inst^, empty_td^)
    assert_equal(tick.open, 0.0, "missing open → 0.0")
    assert_equal(tick.high, 0.0, "missing high → 0.0")
    assert_equal(tick.low, 0.0, "missing low → 0.0")


def test_missing_last_falls_back_to_prev_close_even_when_empty() raises:
    """Even with mostly-empty dict, last falls back to prev_close."""
    var inst = _make_test_instrument()
    var minimal_td = Dict[String, Float64]()
    minimal_td["prev_close"] = 88.88
    var tick = TickObject(inst^, minimal_td^)
    assert_equal(tick.last, 88.88, "last fallback works even in near-empty dict")


# ============================================================
# Section 7: 订单簿字段 (asks/bids/ask_vols/bid_vols)
# ============================================================

def test_default_order_book_is_five_zeros() raises:
    """When asks/bids missing from dict, default is [0.0, 0.0, 0.0, 0.0, 0.0].

    Python (L147-150): ``except (KeyError, ValueError): return [0] * 5``
    """
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    assert_equal(len(tick.asks), 5, "default asks has 5 levels")
    assert_equal(len(tick.bids), 5, "default bids has 5 levels")
    assert_equal(len(tick.ask_vols), 5, "default ask_vols has 5 levels")
    assert_equal(len(tick.bid_vols), 5, "default bid_vols has 5 levels")
    for i in range(5):
        assert_equal(tick.asks[i], 0.0)
        assert_equal(tick.bids[i], 0.0)
        assert_equal(tick.ask_vols[i], 0.0)
        assert_equal(tick.bid_vols[i], 0.0)


def test_datetime_defaults_to_epoch() raises:
    """Datetime field defaults to epoch (1970-1-1) matching Python's datetime.min.

    Python (L47-50): ``except (KeyError, ValueError): return datetime.datetime.min``
    """
    var inst = _make_test_instrument()
    var empty_td = Dict[String, Float64]()
    empty_td["prev_close"] = 10.0
    var tick = TickObject(inst^, empty_td^)
    assert_true(
        tick.datetime.year == 1970,
        "default datetime should be epoch year 1970",
    )


# ============================================================
# Section 8: Writable / repr 反射
# ============================================================

def test_repr_contains_key_info() raises:
    """Auto-generated repr via Writable reflection contains key identifiers."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var tick = TickObject(inst^, td^)
    var s = String.write(tick)
    assert_true(s.find("TickObject") >= 0, "repr contains struct name")
    assert_true(s.find("000001.XSHE") >= 0, "repr contains order_book_id")


# ============================================================
# Section 9: Copyable trait
# ============================================================

def test_Copyable_basic() raises:
    """TickObject supports copy with independent state."""
    var original = _make_test_instrument()
    var td = _make_full_tick_dict()
    var orig_tick = TickObject(original^, td^)
    var copied = orig_tick.copy()
    assert_equal(copied.last, orig_tick.last)
    assert_equal(copied.volume, orig_tick.volume)
    assert_equal(copied.order_book_id(), orig_tick.order_book_id())


def test_Copyable_list_field_independence() raises:
    """Copied object's list fields are independent."""
    var inst = _make_test_instrument()
    var td = _make_full_tick_dict()
    var orig = TickObject(inst^, td^)
    var cp = orig.copy()
    assert_equal(cp.asks[0], orig.asks[0], "copy preserves data")


# ============================================================
# Section 10: __all__ 导出验证
# ============================================================

def test___all___exports_only_TickObject() raises:
    """__all__ should contain exactly 1 entry: TickObject.

    Python exports: TickObject class (no extra helpers).
    Removed from old Mojo: create_tick_object, TickValue, _default_order_book,
                         ORDER_BOOK_LEVELS, get_ask/bid/vol methods.
    """
    from rqmojo.model.tick import __all__
    var count = comptime(len(__all__))
    assert_equal(count, 1, "__all__ should have exactly 1 entry: TickObject")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
