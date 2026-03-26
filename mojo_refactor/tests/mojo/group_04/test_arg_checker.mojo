"""
第四组测试 - utils/arg_checker.mojo
测试Mojo版本的参数检查模块
"""

from rqmojo.utils.arg_checker import (
    check_string,
    check_int,
    check_float,
    check_percentage,
    check_order_book_id,
)


def test_check_string_valid() -> Bool:
    try:
        return check_string("hello", "test_arg")
    except:
        return False


def test_check_string_empty() -> Bool:
    try:
        check_string("", "test_arg")
        return False
    except:
        return True


def test_check_int_valid() -> Bool:
    try:
        return check_int(42, "test_arg")
    except:
        return False


def test_check_int_with_range() -> Bool:
    try:
        return check_int(50, "test_arg", 0, 100)
    except:
        return False


def test_check_int_below_min() -> Bool:
    try:
        check_int(-1, "test_arg", 0, 100)
        return False
    except:
        return True


def test_check_int_above_max() -> Bool:
    try:
        check_int(101, "test_arg", 0, 100)
        return False
    except:
        return True


def test_check_float_valid() -> Bool:
    try:
        return check_float(3.14, "test_arg")
    except:
        return False


def test_check_float_with_range() -> Bool:
    try:
        return check_float(0.5, "test_arg", 0.0, 1.0)
    except:
        return False


def test_check_percentage_valid() -> Bool:
    try:
        return check_percentage(0.5, "test_arg")
    except:
        return False


def test_check_percentage_invalid() -> Bool:
    try:
        check_percentage(1.5, "test_arg")
        return False
    except:
        return True


def test_check_order_book_id_valid() -> Bool:
    try:
        return check_order_book_id("000001.XSHE", "test_arg")
    except:
        return False


def test_check_order_book_id_invalid() -> Bool:
    try:
        check_order_book_id("invalid", "test_arg")
        return False
    except:
        return True


def test_check_order_book_id_empty() -> Bool:
    try:
        check_order_book_id("", "test_arg")
        return False
    except:
        return True


def main():
    var passed = 0
    var failed = 0
    
    print("=" * 60)
    print("Testing: utils/arg_checker.mojo")
    print("=" * 60)
    
    if test_check_string_valid():
        print("PASS: test_check_string_valid")
        passed += 1
    else:
        print("FAIL: test_check_string_valid")
        failed += 1
    
    if test_check_string_empty():
        print("PASS: test_check_string_empty")
        passed += 1
    else:
        print("FAIL: test_check_string_empty")
        failed += 1
    
    if test_check_int_valid():
        print("PASS: test_check_int_valid")
        passed += 1
    else:
        print("FAIL: test_check_int_valid")
        failed += 1
    
    if test_check_int_with_range():
        print("PASS: test_check_int_with_range")
        passed += 1
    else:
        print("FAIL: test_check_int_with_range")
        failed += 1
    
    if test_check_int_below_min():
        print("PASS: test_check_int_below_min")
        passed += 1
    else:
        print("FAIL: test_check_int_below_min")
        failed += 1
    
    if test_check_int_above_max():
        print("PASS: test_check_int_above_max")
        passed += 1
    else:
        print("FAIL: test_check_int_above_max")
        failed += 1
    
    if test_check_float_valid():
        print("PASS: test_check_float_valid")
        passed += 1
    else:
        print("FAIL: test_check_float_valid")
        failed += 1
    
    if test_check_float_with_range():
        print("PASS: test_check_float_with_range")
        passed += 1
    else:
        print("FAIL: test_check_float_with_range")
        failed += 1
    
    if test_check_percentage_valid():
        print("PASS: test_check_percentage_valid")
        passed += 1
    else:
        print("FAIL: test_check_percentage_valid")
        failed += 1
    
    if test_check_percentage_invalid():
        print("PASS: test_check_percentage_invalid")
        passed += 1
    else:
        print("FAIL: test_check_percentage_invalid")
        failed += 1
    
    if test_check_order_book_id_valid():
        print("PASS: test_check_order_book_id_valid")
        passed += 1
    else:
        print("FAIL: test_check_order_book_id_valid")
        failed += 1
    
    if test_check_order_book_id_invalid():
        print("PASS: test_check_order_book_id_invalid")
        passed += 1
    else:
        print("FAIL: test_check_order_book_id_invalid")
        failed += 1
    
    if test_check_order_book_id_empty():
        print("PASS: test_check_order_book_id_empty")
        passed += 1
    else:
        print("FAIL: test_check_order_book_id_empty")
        failed += 1
    
    print()
    print("=" * 60)
    print("Results: ", passed, " passed, ", failed, " failed")
    print("=" * 60)
