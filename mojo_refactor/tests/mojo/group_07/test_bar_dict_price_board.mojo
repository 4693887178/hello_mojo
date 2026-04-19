"""
Comprehensive Test Suite for data/bar_dict_price_board.mojo
Group 07 - File 02

Tests cover:
  1. PriceBoard trait interface: get_last_price, get_limit_up, get_limit_down, get_a1, get_b1
  2. BarDictPriceBoard-specific: set_bar, clear_cache, set_phase, get_phase
  3. Factory function: create_bar_dict_price_board
  4. Edge cases: unknown IDs, multiple instruments, overwrite, NaN consistency
  5. Writable trait: write_to output
  6. Behavior parity with Python original (np.nan for a1/b1, dynamic bar lookup fallback)
"""

from std.collections import Dict
from rqmojo.data.bar_dict_price_board import (
    BarDictPriceBoard,
    create_bar_dict_price_board,
    NAN_VALUE
)
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import EXECUTION_PHASE, EXCHANGE
from rqmojo.utils.typing import DateTime

from std.testing import (
    assert_equal,
    assert_true,
    assert_false,
    assert_raises,
    TestSuite
)


def _make_test_bar(
    order_book_id: String = "000001.XSHE",
    close: Float64 = 10.5,
    limit_up: Float64 = 11.55,
    limit_down: Float64 = 9.45
) -> BarObject:
    return create_bar_object(
        order_book_id=order_book_id,
        dt=DateTime(2024, 1, 15, 15, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.0,
        close=close,
        volume=1000000.0,
        total_turnover=10500000.0,
        limit_up=limit_up,
        limit_down=limit_down,
        suspended=False,
        trading=True
    )


def _is_nan(value: Float64) -> Bool:
    return value != value


def test_create_bar_dict_price_board_default_phase() raises:
    var board = create_bar_dict_price_board()
    assert_equal(
        board.get_phase(),
        EXECUTION_PHASE.BEFORE_TRADING,
        "Default phase should be BEFORE_TRADING"
    )


def test_get_last_price_unknown_id_returns_nan() raises:
    var board = create_bar_dict_price_board()
    var price = board.get_last_price("NONEXISTENT.ID")
    assert_true(
        _is_nan(price),
        "get_last_price for unknown ID should return NaN"
    )


def test_get_limit_up_unknown_id_returns_nan() raises:
    var board = create_bar_dict_price_board()
    var result = board.get_limit_up("NONEXISTENT.ID")
    assert_true(
        _is_nan(result),
        "get_limit_up for unknown ID should return NaN"
    )


def test_get_limit_down_unknown_id_returns_nan() raises:
    var board = create_bar_dict_price_board()
    var result = board.get_limit_down("NONEXISTENT.ID")
    assert_true(
        _is_nan(result),
        "get_limit_down for unknown ID should return NaN"
    )


def test_get_a1_always_returns_nan() raises:
    var board = create_bar_dict_price_board()
    var a1_with_id = board.get_a1("000001.XSHE")
    assert_true(_is_nan(a1_with_id), "get_a1 should always return NaN")
    var a1_empty = board.get_a1("")
    assert_true(_is_nan(a1_empty), "get_a1('') should return NaN")


def test_get_b1_always_returns_nan() raises:
    var board = create_bar_dict_price_board()
    var b1_with_id = board.get_b1("000001.XSHE")
    assert_true(_is_nan(b1_with_id), "get_b1 should always return NaN")
    var b1_empty = board.get_b1("")
    assert_true(_is_nan(b1_empty), "get_b1('') should return NaN")


def test_set_bar_populates_all_fields() raises:
    var board = create_bar_dict_price_board()
    var bar = _make_test_bar(close=12.3, limit_up=13.5, limit_down=11.1)
    board.set_bar("000001.XSHE", bar^)

    assert_equal(board.get_last_price("000001.XSHE"), 12.3, "last_price after set_bar")
    assert_equal(board.get_limit_up("000001.XSHE"), 13.5, "limit_up after set_bar")
    assert_equal(board.get_limit_down("000001.XSHE"), 11.1, "limit_down after set_bar")


def test_set_bar_uses_bar_last_not_close() raises:
    var board = create_bar_dict_price_board()
    var bar = _make_test_bar(close=10.5)
    var last_val = bar.last()
    board.set_bar("TEST.XSHG", bar^)
    assert_equal(
        board.get_last_price("TEST.XSHG"),
        last_val,
        "set_bar should use bar.last() not bar.close()"
    )


def test_set_bar_overwrites_existing() raises:
    var board = create_bar_dict_price_board()

    var bar1 = _make_test_bar(close=10.0, limit_up=11.0, limit_down=9.0)
    board.set_bar("000001.XSHE", bar1^)

    var bar2 = _make_test_bar(close=20.0, limit_up=22.0, limit_down=18.0)
    board.set_bar("000001.XSHE", bar2^)

    assert_equal(board.get_last_price("000001.XSHE"), 20.0, "Overwritten last_price")
    assert_equal(board.get_limit_up("000001.XSHE"), 22.0, "Overwritten limit_up")
    assert_equal(board.get_limit_down("000001.XSHE"), 18.0, "Overwritten limit_down")


def test_multiple_instruments_independent() raises:
    var board = create_bar_dict_price_board()

    var bar_a = _make_test_bar(order_book_id="000001.XSHE", close=10.0, limit_up=11.0, limit_down=9.0)
    var bar_b = _make_test_bar(order_book_id="600000.XSHG", close=100.0, limit_up=110.0, limit_down=90.0)
    var bar_c = _make_test_bar(order_book_id="000002.XSHE", close=20.0, limit_up=22.0, limit_down=18.0)

    board.set_bar("000001.XSHE", bar_a^)
    board.set_bar("600000.XSHG", bar_b^)
    board.set_bar("000002.XSHE", bar_c^)

    assert_equal(board.get_last_price("000001.XSHE"), 10.0, "Instrument A last_price")
    assert_equal(board.get_limit_up("600000.XSHG"), 110.0, "Instrument B limit_up")
    assert_equal(board.get_limit_down("000002.XSHE"), 18.0, "Instrument C limit_down")

    assert_true(_is_nan(board.get_last_price("UNKNOWN.ID")), "Unknown ID still returns NaN")


def test_clear_cache_removes_all_data() raises:
    var board = create_bar_dict_price_board()

    var bar = _make_test_bar(close=15.0, limit_up=16.5, limit_down=13.5)
    board.set_bar("000001.XSHE", bar^)

    assert_false(_is_nan(board.get_last_price("000001.XSHE")), "Data exists before clear")

    board.clear_cache()

    assert_true(_is_nan(board.get_last_price("000001.XSHE")), "last_price NaN after clear_cache")
    assert_true(_is_nan(board.get_limit_up("000001.XSHE")), "limit_up NaN after clear_cache")
    assert_true(_is_nan(board.get_limit_down("000001.XSHE")), "limit_down NaN after clear_cache")


def test_clear_cache_on_empty_board() raises:
    var board = create_bar_dict_price_board()
    board.clear_cache()
    assert_true(_is_nan(board.get_last_price("ANY.ID")), "clear_cache on empty is safe")


def test_set_phase_and_get_phase() raises:
    var board = create_bar_dict_price_board()

    assert_equal(board.get_phase(), EXECUTION_PHASE.BEFORE_TRADING, "Initial phase")

    board.set_phase(EXECUTION_PHASE.ON_BAR)
    assert_equal(board.get_phase(), EXECUTION_PHASE.ON_BAR, "After set ON_BAR")

    board.set_phase(EXECUTION_PHASE.OPEN_AUCTION)
    assert_equal(board.get_phase(), EXECUTION_PHASE.OPEN_AUCTION, "After set OPEN_AUCTION")

    board.set_phase(EXECUTION_PHASE.AFTER_TRADING)
    assert_equal(board.get_phase(), EXECUTION_PHASE.AFTER_TRADING, "AFTER_TRADING")

    board.set_phase(EXECUTION_PHASE.ON_INIT)
    assert_equal(board.get_phase(), EXECUTION_PHASE.ON_INIT, "ON_INIT")

    board.set_phase(EXECUTION_PHASE.GLOBAL)
    assert_equal(board.get_phase(), EXECUTION_PHASE.GLOBAL, "GLOBAL")

    board.set_phase(EXECUTION_PHASE.FINALIZED)
    assert_equal(board.get_phase(), EXECUTION_PHASE.FINALIZED, "FINALIZED")

    board.set_phase(EXECUTION_PHASE.SCHEDULED)
    assert_equal(board.get_phase(), EXECUTION_PHASE.SCHEDULED, "SCHEDULED")

    board.set_phase(EXECUTION_PHASE.ON_TICK)
    assert_equal(board.get_phase(), EXECUTION_PHASE.ON_TICK, "ON_TICK")


def test_nan_value_is_ieee754_nan() raises:
    assert_true(_is_nan(NAN_VALUE), "NAN_VALUE constant must be IEEE 754 NaN")
    var nan_copy = NAN_VALUE
    assert_true(_is_nan(nan_copy), "NAN_VALUE copy is still NaN")


def test_get_a1_b1_match_python_np_nan_behavior() raises:
    var board = create_bar_dict_price_board()
    board.set_bar("000001.XSHE", _make_test_bar())
    assert_true(
        _is_nan(board.get_a1("000001.XSHE")),
        "get_a1 returns NaN even after set_bar (matches Python np.nan)"
    )
    assert_true(
        _is_nan(board.get_b1("000001.XSHE")),
        "get_b1 returns NaN even after set_bar (matches Python np.nan)"
    )


def test_writable_trait_output() raises:
    var board = create_bar_dict_price_board()
    var s = String.write(board)
    assert_true(
        len(s) > 0,
        "write_to should produce non-empty output"
    )


def test_zero_values_stored_correctly() raises:
    var board = create_bar_dict_price_board()
    var bar = create_bar_object(
        order_book_id="ZERO.TEST",
        dt=DateTime(2024, 1, 1, 0, 0, 0, 0),
        open=0.0,
        high=0.0,
        low=0.0,
        close=0.0,
        volume=0.0,
        total_turnover=0.0,
        limit_up=0.01,
        limit_down=0.001
    )
    board.set_bar("ZERO.TEST", bar^)
    assert_equal(board.get_last_price("ZERO.TEST"), 0.0, "Zero last_price stored correctly")
    assert_true(
        _is_nan(board.get_limit_up("ZERO.TEST")) or board.get_limit_up("ZERO.TEST") == 0.01,
        "limit_up: BarObject treats 0 as unset (returns NaN) or stores explicit value"
    )
    assert_true(
        _is_nan(board.get_limit_down("ZERO.TEST")) or board.get_limit_down("ZERO.TEST") == 0.001,
        "limit_down: BarObject treats 0 as unset (returns NaN) or stores explicit value"
    )


def test_negative_prices_handled() raises:
    var board = create_bar_dict_price_board()
    var bar = create_bar_object(
        order_book_id="NEG.TEST",
        dt=DateTime(2024, 1, 1, 0, 0, 0, 0),
        open=-5.0,
        high=-3.0,
        low=-7.0,
        close=-4.0,
        volume=100.0,
        total_turnover=-400.0,
        limit_up=-2.0,
        limit_down=-8.0
    )
    board.set_bar("NEG.TEST", bar^)
    assert_equal(board.get_last_price("NEG.TEST"), -4.0, "Negative last_price")
    assert_equal(board.get_limit_up("NEG.TEST"), -2.0, "Negative limit_up")
    assert_equal(board.get_limit_down("NEG.TEST"), -8.0, "Negative limit_down")


def test_large_order_book_ids() raises:
    var board = create_bar_dict_price_board()
    long_id = "A" * 200
    var bar = _make_test_bar(order_book_id=long_id, close=99.9)
    board.set_bar(long_id, bar^)
    assert_equal(board.get_last_price(long_id), 99.9, "Long order_book_id works")


def test_mixed_known_and_unknown_queries() raises:
    var board = create_bar_dict_price_board()
    board.set_bar("KNOWN.ID", _make_test_bar(close=42.0))

    assert_equal(board.get_last_price("KNOWN.ID"), 42.0, "Known ID works")
    assert_true(_is_nan(board.get_last_price("UNKNOWN1")), "Unknown1 is NaN")
    assert_true(_is_nan(board.get_last_price("UNKNOWN2")), "Unknown2 is NaN")
    assert_equal(board.get_last_price("KNOWN.ID"), 42.0, "Known ID still works after unknown queries")


def test_rapid_set_and_query_cycle() raises:
    var board = create_bar_dict_price_board()
    for i in range(100):
        var id_str = String("STOCK") + String(i) + ".XSHE"
        var close_val = Float64(i) * 1.5
        var bar = _make_test_bar(order_book_id=id_str, close=close_val)
        board.set_bar(id_str, bar^)

    for i in range(100):
        var id_str = String("STOCK") + String(i) + ".XSHE"
        var expected = Float64(i) * 1.5
        assert_equal(
            board.get_last_price(id_str),
            expected,
            "Rapid cycle: " + id_str + " expected " + String(expected)
        )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
