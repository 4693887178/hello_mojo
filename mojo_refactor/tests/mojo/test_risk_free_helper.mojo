"""
RQAlpha Mojo - Risk Free Helper Tests
Final test for risk_free_helper.mojo
"""

import std
from std.collections import Dict, List
from morrow import Morrow


# 复制risk_free_helper.mojo的实现
def get_yield_curve_tenors() -> Dict[Int, String]:
    var tenors = Dict[Int, String]()
    tenors[0] = "0S"
    tenors[30] = "1M"
    tenors[60] = "2M"
    tenors[90] = "3M"
    tenors[180] = "6M"
    tenors[270] = "9M"
    tenors[365] = "1Y"
    tenors[730] = "2Y"
    tenors[1095] = "3Y"
    tenors[1460] = "4Y"
    tenors[1825] = "5Y"
    tenors[2190] = "6Y"
    tenors[2555] = "7Y"
    tenors[2920] = "8Y"
    tenors[3285] = "9Y"
    tenors[3650] = "10Y"
    tenors[5475] = "15Y"
    tenors[7300] = "20Y"
    tenors[10950] = "30Y"
    tenors[14600] = "40Y"
    tenors[18250] = "50Y"
    return tenors^


def get_yield_curve_duration() -> List[Int]:
    return [0, 30, 60, 90, 180, 270, 365, 730, 1095, 1460, 1825, 2190, 2555, 2920, 3285, 3650, 5475, 7300, 10950, 14600, 18250]


def get_tenor_for(start_date: Morrow, end_date: Morrow) raises -> String:
    var duration = (end_date - start_date).days
    
    var tenors = get_yield_curve_tenors()
    var durations = get_yield_curve_duration()
    var result = "0S"
    for t in durations:
        if duration >= t:
            result = tenors[t]
        else:
            break
    
    return result


def get_tenors_for(start_date: Morrow, end_date: Morrow) raises -> List[String]:
    var duration = (end_date - start_date).days
    
    var tenors = get_yield_curve_tenors()
    var durations = get_yield_curve_duration()
    var result = List[String]()
    for t in durations:
        if duration >= t:
            result.append(tenors[t])
    
    return result^


# 主函数
fn main() raises:
    # 测试get_yield_curve_tenors
    var tenors = get_yield_curve_tenors()
    print("Testing get_yield_curve_tenors...")
    print("tenors[0] =", tenors[0])
    print("tenors[30] =", tenors[30])
    print("tenors[365] =", tenors[365])
    
    # 测试get_yield_curve_duration
    var durations = get_yield_curve_duration()
    print("\nTesting get_yield_curve_duration...")
    print("durations[0] =", durations[0])
    print("durations[6] =", durations[6])
    print("durations[-1] =", durations[-1])
    
    # 测试get_tenor_for
    var start_date = Morrow(2020, 1, 1)
    var end_date = Morrow(2020, 1, 31)
    var tenor = get_tenor_for(start_date, end_date)
    print("\nTesting get_tenor_for...")
    print("From 2020-01-01 to 2020-01-31:", tenor)
    
    # 测试get_tenors_for
    var tenors_list = get_tenors_for(start_date, end_date)
    print("\nTesting get_tenors_for...")
    print("From 2020-01-01 to 2020-01-31:", tenors_list)
    
    # 测试跨年月场景
    var start_date_leap = Morrow(2020, 2, 29)
    var end_date_leap = Morrow(2021, 2, 28)
    var tenor_leap = get_tenor_for(start_date_leap, end_date_leap)
    print("\nTesting cross year month...")
    print("From 2020-02-29 to 2021-02-28:", tenor_leap)
    
    print("\nAll tests completed!")
