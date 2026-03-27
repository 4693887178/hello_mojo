"""
Test for data/bar_dict_price_board.mojo
Group 07 - File 02
"""

from std.collections import Dict
from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board, nan_f64
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.typing import DateTime

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_bar_dict_price_board_init() raises:
    print("Test: BarDictPriceBoard init")
    var board = create_bar_dict_price_board()
    print("  PASSED")


def test_bar_dict_price_board_get_last_price() raises:
    print("Test: BarDictPriceBoard get_last_price")
    var board = create_bar_dict_price_board()
    var price = board.get_last_price("000001.XSHE")
    print("  Last price (empty): ", price)
    print("  PASSED")


def test_bar_dict_price_board_get_limit_up() raises:
    print("Test: BarDictPriceBoard get_limit_up")
    var board = create_bar_dict_price_board()
    var limit_up = board.get_limit_up("000001.XSHE")
    print("  Limit up (empty): ", limit_up)
    print("  PASSED")


def test_bar_dict_price_board_get_limit_down() raises:
    print("Test: BarDictPriceBoard get_limit_down")
    var board = create_bar_dict_price_board()
    var limit_down = board.get_limit_down("000001.XSHE")
    print("  Limit down (empty): ", limit_down)
    print("  PASSED")


def test_bar_dict_price_board_get_a1() raises:
    print("Test: BarDictPriceBoard get_a1")
    var board = create_bar_dict_price_board()
    var a1 = board.get_a1("000001.XSHE")
    print("  A1: ", a1)
    print("  PASSED")


def test_bar_dict_price_board_get_b1() raises:
    print("Test: BarDictPriceBoard get_b1")
    var board = create_bar_dict_price_board()
    var b1 = board.get_b1("000001.XSHE")
    print("  B1: ", b1)
    print("  PASSED")


def test_nan_f64() raises:
    print("Test: nan_f64 function")
    var _ = nan_f64()
    print("  NaN value created")
    print("  PASSED")


def test_bar_dict_price_board_set_bar() raises:
    print("Test: BarDictPriceBoard set_bar")
    var board = create_bar_dict_price_board()
    var bar = create_bar_object(
        order_book_id="000001.XSHE",
        dt=DateTime(2024, 1, 1, 0, 0, 0, 0),
        open=10.0,
        high=11.0,
        low=9.0,
        close=10.5,
        volume=1000000.0,
        total_turnover=10500000.0,
        limit_up=11.5,
        limit_down=9.5,
        suspended=False,
        trading=True
    )
    board.set_bar("000001.XSHE", bar^)
    
    var last_price = board.get_last_price("000001.XSHE")
    var limit_up = board.get_limit_up("000001.XSHE")
    var limit_down = board.get_limit_down("000001.XSHE")
    
    print("  Last price: ", last_price)
    print("  Limit up: ", limit_up)
    print("  Limit down: ", limit_down)
    print("  PASSED")


def test_bar_dict_price_board_clear_cache() raises:
    print("Test: BarDictPriceBoard clear_cache")
    var board = create_bar_dict_price_board()
    board.clear_cache()
    print("  PASSED")


def test_bar_dict_price_board_set_phase() raises:
    print("Test: BarDictPriceBoard set_phase")
    var board = create_bar_dict_price_board()
    board.set_phase(EXECUTION_PHASE.ON_BAR)
    var phase = board.get_phase()
    assert_equal(phase, EXECUTION_PHASE.ON_BAR, "Phase should be ON_BAR")
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
