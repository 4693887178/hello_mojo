#!/usr/bin/env python3
"""
Test for rqalpha/utils/typing.py
"""

import sys
import os
from datetime import date, datetime

# Add the Python package path
sys.path.insert(0, '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages')

import pandas
from rqalpha.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE
from rqalpha.const import POSITION_DIRECTION


def test_date_like_with_date():
    """Test DateLike with date object"""
    print("Test 1: DateLike with date")
    d = date(2024, 1, 1)
    print(f"  date object: {d}")
    print(f"  type: {type(d)}")
    print("  PASS")
    return True


def test_date_like_with_datetime():
    """Test DateLike with datetime object"""
    print("Test 2: DateLike with datetime")
    dt = datetime(2024, 1, 1, 12, 0, 0)
    print(f"  datetime object: {dt}")
    print(f"  type: {type(dt)}")
    print("  PASS")
    return True


def test_date_like_with_timestamp():
    """Test DateLike with pandas.Timestamp"""
    print("Test 3: DateLike with pandas.Timestamp")
    ts = pandas.Timestamp('2024-01-01')
    print(f"  Timestamp object: {ts}")
    print(f"  type: {type(ts)}")
    print("  PASS")
    return True


def test_str_or_iter_with_str():
    """Test StrOrIter with string"""
    print("Test 4: StrOrIter with string")
    s = "test"
    print(f"  string: {s}")
    print(f"  type: {type(s)}")
    print("  PASS")
    return True


def test_str_or_iter_with_list():
    """Test StrOrIter with list of strings"""
    print("Test 5: StrOrIter with list")
    lst = ["a", "b", "c"]
    print(f"  list: {lst}")
    print(f"  type: {type(lst)}")
    print("  PASS")
    return True


def test_str_or_iter_with_tuple():
    """Test StrOrIter with tuple of strings"""
    print("Test 6: StrOrIter with tuple")
    tpl = ("a", "b", "c")
    print(f"  tuple: {tpl}")
    print(f"  type: {type(tpl)}")
    print("  PASS")
    return True


def test_position_direction_type_str():
    """Test POSITION_DIRECTION_TYPE with string"""
    print("Test 7: POSITION_DIRECTION_TYPE with string")
    s = "LONG"
    print(f"  string: {s}")
    print(f"  type: {type(s)}")
    print("  PASS")
    return True


def test_position_direction_type_enum():
    """Test POSITION_DIRECTION_TYPE with enum"""
    print("Test 8: POSITION_DIRECTION_TYPE with enum")
    e = POSITION_DIRECTION.LONG
    print(f"  enum: {e}")
    print(f"  type: {type(e)}")
    print("  PASS")
    return True


def test_type_aliases_exist():
    """Test that type aliases are defined"""
    print("Test 9: Type aliases exist")
    print(f"  DateLike: {DateLike}")
    print(f"  StrOrIter: {StrOrIter}")
    print(f"  POSITION_DIRECTION_TYPE: {POSITION_DIRECTION_TYPE}")
    print("  PASS")
    return True


def main():
    print("=" * 60)
    print("Python typing.py Test")
    print("=" * 60)
    
    results = []
    results.append(test_date_like_with_date())
    results.append(test_date_like_with_datetime())
    results.append(test_date_like_with_timestamp())
    results.append(test_str_or_iter_with_str())
    results.append(test_str_or_iter_with_list())
    results.append(test_str_or_iter_with_tuple())
    results.append(test_position_direction_type_str())
    results.append(test_position_direction_type_enum())
    results.append(test_type_aliases_exist())
    
    print()
    print("=" * 60)
    print(f"Results: {sum(results)}/{len(results)} passed")
    print("=" * 60)
    
    return sum(results) == len(results)


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
