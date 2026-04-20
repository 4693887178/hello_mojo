"""
Test for data/bar_dict_price_board.mojo
Group 09 - File 4
"""

from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board

from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_bar_dict_price_board_init() raises:
    print("Test: BarDictPriceBoard init")
    var _ = create_bar_dict_price_board()
    print("  PASSED")


def test_bar_dict_price_board_get_last_price() raises:
    print("Test: BarDictPriceBoard get_last_price")
    var board = create_bar_dict_price_board()
    var _ = board.get_last_price("000001.XSHE")
    print("  PASSED")


def test_bar_dict_price_board_clear_cache() raises:
    print("Test: BarDictPriceBoard clear_cache")
    var board = create_bar_dict_price_board()
    board.clear_cache()
    print("  PASSED")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
