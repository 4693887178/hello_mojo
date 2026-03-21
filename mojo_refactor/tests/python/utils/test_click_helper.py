# -*- coding: utf-8 -*-
"""
Test for rqalpha/utils/click_helper.py - Click Helper Module
Compares output with Mojo rqmojo/utils/click_helper.mojo
"""

import click
import pandas as pd

from rqalpha.utils.click_helper import Date


def test_date_instantiation():
    """测试 Date 类实例化"""
    print("=== Testing Date instantiation ===")
    
    date_param = Date()
    print(f"Date instance created: {date_param}")
    
    date_param_with_tz = Date(tz="Asia/Shanghai")
    print(f"Date instance with tz: {date_param_with_tz}")
    
    print("PASS: Date instances created successfully")
    print("")


def test_date_convert():
    """测试 convert 方法将字符串转换为 Timestamp"""
    print("=== Testing Date.convert ===")
    
    date_param = Date()
    
    result = date_param.convert("2020-01-01", None, None)
    print(f"convert('2020-01-01') = {result}")
    
    assert isinstance(result, pd.Timestamp), "Result should be a pandas Timestamp"
    assert str(result).startswith("2020-01-01"), "Result should be 2020-01-01"
    
    print("PASS: convert method works correctly")
    print("")


def test_date_name_property():
    """测试 name 属性返回 'DATE'"""
    print("=== Testing Date.name property ===")
    
    date_param = Date()
    name = date_param.name
    
    print(f"Date.name = {name}")
    assert name == "DATE", f"Expected 'DATE', got '{name}'"
    
    print("PASS: name property returns 'DATE'")
    print("")


def test_date_convert_with_datetime():
    """测试处理日期时间字符串"""
    print("=== Testing Date.convert with datetime string ===")
    
    date_param = Date()
    
    result = date_param.convert("2020-01-01 10:30:00", None, None)
    print(f"convert('2020-01-01 10:30:00') = {result}")
    
    assert isinstance(result, pd.Timestamp), "Result should be a pandas Timestamp"
    
    print("PASS: datetime string converted correctly")
    print("")


def test_date_convert_with_timestamp():
    """测试处理 Timestamp 对象"""
    print("=== Testing Date.convert with Timestamp ===")
    
    date_param = Date()
    
    ts = pd.Timestamp("2020-06-15")
    result = date_param.convert(ts, None, None)
    print(f"convert(Timestamp('2020-06-15')) = {result}")
    
    assert isinstance(result, pd.Timestamp), "Result should be a pandas Timestamp"
    
    print("PASS: Timestamp object handled correctly")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python utils/click_helper.py Test")
    print("=" * 60)
    print("")
    
    test_date_instantiation()
    test_date_convert()
    test_date_name_property()
    test_date_convert_with_datetime()
    test_date_convert_with_timestamp()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
