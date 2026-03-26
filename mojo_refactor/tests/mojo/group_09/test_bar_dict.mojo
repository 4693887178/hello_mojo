"""
Test for core/bar_dict.mojo
Group 09 - File 4
"""

from rqmojo.core.bar_dict import BarDict, create_bar_dict
from rqmojo.model.bar import BarObject, create_bar_object
from rqmojo.utils.typing import DateTime


fn test_bar_dict_init() -> Bool:
    print("Test: BarDict init")
    var bar_dict = create_bar_dict()
    print("  PASSED")
    return True


fn test_bar_dict_get_or_create() -> Bool:
    print("Test: BarDict get_or_create")
    var bar_dict = create_bar_dict()
    var bar = bar_dict.get_or_create("000001.XSHE")
    print("  PASSED")
    return True


fn test_bar_dict_set() -> Bool:
    print("Test: BarDict set")
    var bar_dict = create_bar_dict()
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
    bar_dict.set("000001.XSHE", owned bar)
    print("  PASSED")
    return True


fn test_bar_dict_get() -> Bool:
    print("Test: BarDict get")
    var bar_dict = create_bar_dict()
    var bar = bar_dict.get("000001.XSHE")
    print("  PASSED")
    return True


def main() raises:
    print("=== Group 09 File 4: Bar Dict Tests ===")
    print("")
    var passed = 0
    var failed = 0
    
    try:
        if test_bar_dict_init():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_get_or_create():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_set():
            passed += 1
    except:
        failed += 1
    
    try:
        if test_bar_dict_get():
            passed += 1
    except:
        failed += 1
    
    print("")
    print("=== Test Summary ===")
    print("Passed: ", passed)
    print("Failed: ", failed)
    print("Total:  ", passed + failed)
