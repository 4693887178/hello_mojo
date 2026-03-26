"""
Test for data/bar_dict_price_board.mojo
Group 09 - File 4
"""

from rqmojo.data.bar_dict_price_board import BarDictPriceBoard, create_bar_dict_price_board


fn test_bar_dict_price_board_init() -> Bool:
    print("Test: BarDictPriceBoard init")
    var board = create_bar_dict_price_board()
    print("  PASSED")
    return True


fn test_bar_dict_price_board_get_last_price() -> Bool:
    print("Test: BarDictPriceBoard get_last_price")
    var board = create_bar_dict_price_board()
    var price = board.get_last_price("000001.XSHE")
    print("  PASSED")
    return True


fn test_bar_dict_price_board_clear_cache() -> Bool:
    print("Test: BarDictPriceBoard clear_cache")
    var board = create_bar_dict_price_board()
    board.clear_cache()
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 4: Bar Dict Price Board Tests ===")
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
        if test_bar_dict_price_board_clear_cache():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
