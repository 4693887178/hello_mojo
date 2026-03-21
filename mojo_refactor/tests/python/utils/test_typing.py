# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/typing.py - Type Aliases
Compares output with Mojo rqmojo/utils/typing.mojo
"""

from datetime import date, datetime
from typing import Union, Iterable, get_args
import pandas

from rqalpha.const import POSITION_DIRECTION
from rqalpha.utils.typing import DateLike, StrOrIter, POSITION_DIRECTION_TYPE


def test_datelike_type():
    """测试 DateLike 类型别名"""
    print("=== Testing DateLike type ===")
    
    print(f"DateLike = {DateLike}")
    
    date_val = date(2020, 1, 1)
    datetime_val = datetime(2020, 1, 1, 10, 30)
    timestamp_val = pandas.Timestamp("2020-01-01")
    
    print(f"date instance: {date_val}")
    print(f"datetime instance: {datetime_val}")
    print(f"Timestamp instance: {timestamp_val}")
    
    args = get_args(DateLike)
    print(f"DateLike type args: {args}")
    
    assert date in args, "date should be in DateLike"
    assert datetime in args, "datetime should be in DateLike"
    assert pandas.Timestamp in args, "pandas.Timestamp should be in DateLike"
    
    print("PASS: DateLike type alias correct")
    print("")


def test_stroriter_type():
    """测试 StrOrIter 类型别名"""
    print("=== Testing StrOrIter type ===")
    
    print(f"StrOrIter = {StrOrIter}")
    
    str_val = "test_string"
    list_val = ["a", "b", "c"]
    
    print(f"str instance: {str_val}")
    print(f"list instance: {list_val}")
    
    args = get_args(StrOrIter)
    print(f"StrOrIter type args: {args}")
    
    assert str in args, "str should be in StrOrIter"
    
    print("PASS: StrOrIter type alias correct")
    print("")


def test_position_direction_type():
    """测试 POSITION_DIRECTION_TYPE 类型别名"""
    print("=== Testing POSITION_DIRECTION_TYPE ===")
    
    print(f"POSITION_DIRECTION_TYPE = {POSITION_DIRECTION_TYPE}")
    
    str_val = "LONG"
    enum_val = POSITION_DIRECTION.LONG
    
    print(f"str instance: {str_val}")
    print(f"enum instance: {enum_val}")
    
    args = get_args(POSITION_DIRECTION_TYPE)
    print(f"POSITION_DIRECTION_TYPE type args: {args}")
    
    assert str in args, "str should be in POSITION_DIRECTION_TYPE"
    assert POSITION_DIRECTION in args, "POSITION_DIRECTION should be in POSITION_DIRECTION_TYPE"
    
    print("PASS: POSITION_DIRECTION_TYPE type alias correct")
    print("")


def test_type_alias_consistency():
    """测试类型别名数量一致性"""
    print("=== Testing type alias consistency ===")
    
    datelike_args = get_args(DateLike)
    stroriter_args = get_args(StrOrIter)
    position_dir_args = get_args(POSITION_DIRECTION_TYPE)
    
    print(f"DateLike has {len(datelike_args)} type options")
    print(f"StrOrIter has {len(stroriter_args)} type options")
    print(f"POSITION_DIRECTION_TYPE has {len(position_dir_args)} type options")
    
    assert len(datelike_args) == 3, "DateLike should have 3 type options"
    assert len(stroriter_args) == 2, "StrOrIter should have 2 type options"
    assert len(position_dir_args) == 2, "POSITION_DIRECTION_TYPE should have 2 type options"
    
    print("PASS: Type alias counts consistent")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/typing.py Test")
    print("=" * 60)
    print("")
    
    test_datelike_type()
    test_stroriter_type()
    test_position_direction_type()
    test_type_alias_consistency()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
