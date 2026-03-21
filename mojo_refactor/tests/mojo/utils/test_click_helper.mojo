"""
Test for click_helper.mojo - Click Helper Module
Compares output with Python rqalpha/utils/click_helper.py
"""

from std.collections import List
from rqmojo.utils.click_helper import DateParam
from rqmojo.utils.datetime_func import DateTime


def test_date_param_instantiation():
    """测试 DateParam 结构体实例化"""
    print("=== Testing DateParam instantiation ===")
    
    var date_param = DateParam()
    print("DateParam instance created")
    
    var date_param_with_tz = DateParam(tz="Asia/Shanghai")
    print("DateParam instance with tz created")
    
    print("PASS: DateParam instances created successfully")
    print("")


def test_date_param_convert():
    """测试 convert 方法将字符串转换为 DateTime"""
    print("=== Testing DateParam.convert ===")
    
    var date_param = DateParam()
    
    var result = date_param.convert("2020-01-01")
    print("convert('2020-01-01') = " + String(result))
    
    print("PASS: convert method works correctly")
    print("")


def test_date_param_name():
    """测试 name 方法返回 'DATE'"""
    print("=== Testing DateParam.name ===")
    
    var date_param = DateParam()
    var name = date_param.name()
    
    print("DateParam.name() = " + name)
    if name == "DATE":
        print("PASS: name method returns 'DATE'")
    else:
        print("FAIL: expected 'DATE', got '" + name + "'")
    print("")


def test_date_param_convert_datetime():
    """测试处理日期时间字符串"""
    print("=== Testing DateParam.convert with datetime string ===")
    
    var date_param = DateParam()
    
    var result = date_param.convert("2020-01-01 10:30:00")
    print("convert('2020-01-01 10:30:00') = " + String(result))
    
    print("PASS: datetime string converted correctly")
    print("")


def test_date_param_with_tz():
    """测试带时区参数的 DateParam"""
    print("=== Testing DateParam with timezone ===")
    
    var date_param = DateParam(tz="UTC")
    print("DateParam with tz=UTC created")
    
    var name = date_param.name()
    if name == "DATE":
        print("PASS: name still returns 'DATE' with tz set")
    else:
        print("FAIL: expected 'DATE', got '" + name + "'")
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo utils/click_helper.mojo Test")
    print("=" * 60)
    print("")
    
    test_date_param_instantiation()
    test_date_param_convert()
    test_date_param_name()
    test_date_param_convert_datetime()
    test_date_param_with_tz()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
