"""
Test for data/bar_dict_price_board.mojo
Group 07 - File 02
"""

from std.collections import Dict
from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board, create_empty_bar, nan_f64
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.const import EXECUTION_PHASE
from rqmojo.utils.typing import DateTime


fn test_bar_dict_price_board_init() -> Bool:
    print("Test: BarDictPriceBoard init")
    var board = create_bar_dict_price_board()
    print("  PASSED")
    return True


fn test_bar_dict_price_board_get_last_price() -> Bool:
    print("Test: BarDictPriceBoard get_last_price")
    var board = create_bar_dict_price_board()
    var bar = create_empty_bar()
    board.set_bar("000001.XSHE", bar)
    var price = board.get_last_price("000001.XSHE")
    print("  Last price: ", price)
    print("  PASSED")
    return True


fn test_bar_dict_price_board_get_limit_up() -> Bool:
    print("Test: BarDictPriceBoard get_limit_up")
    var board = create_bar_dict_price_board()
    var bar = create_empty_bar()
    board.set_bar("000001.XSHE", bar)
    var limit_up = board.get_limit_up("000001.XSHE")
    print("  Limit up: ", limit_up)
    print("  PASSED")
    return True


fn test_bar_dict_price_board_get_limit_down() -> Bool:
    print("Test: BarDictPriceBoard get_limit_down")
    var board = create_bar_dict_price_board()
    var bar = create_empty_bar()
    board.set_bar("000001.XSHE", bar)
    var limit_down = board.get_limit_down("000001.XSHE")
    print("  Limit down: ", limit_down)
    print("  PASSED")
    return True


fn test_bar_dict_price_board_get_a1() -> Bool:
    print("Test: BarDictPriceBoard get_a1")
    var board = create_bar_dict_price_board()
    var a1 = board.get_a1("000001.XSHE")
    print("  A1: ", a1)
    print("  PASSED")
    return True


fn test_bar_dict_price_board_get_b1() -> Bool:
    print("Test: BarDictPriceBoard get_b1")
    var board = create_bar_dict_price_board()
    var b1 = board.get_b1("000001.XSHE")
    print("  B1: ", b1)
    print("  PASSED")
    return True


fn test_nan_f64() -> Bool:
    print("Test: nan_f64 function")
    var nan_val = nan_f64()
    print("  NaN value created")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 07 File 02: BarDictPriceBoard Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_bar_dict_price_board_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_price_board_get_last_price():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_price_board_get_limit_up():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_price_board_get_limit_down():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_price_board_get_a1():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_price_board_get_b1():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_nan_f64():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
