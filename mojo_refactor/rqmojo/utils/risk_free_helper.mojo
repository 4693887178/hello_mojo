"""
RQAlpha Mojo - Risk Free Rate Helper
Ported from rqalpha/utils/risk_free_helper.py
Reference: rqcpp/utils/risk_free_helper.cppm
"""

from rqmojo.utils.typing import DateTime, DateTimeDate
from std.collections import Dict, List


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


def get_tenor_for(start_date: DateTimeDate, end_date: DateTimeDate) raises -> String:
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


def get_tenors_for(start_date: DateTimeDate, end_date: DateTimeDate) raises -> List[String]:
    var duration = (end_date - start_date).days
    
    var tenors = get_yield_curve_tenors()
    var durations = get_yield_curve_duration()
    var result = List[String]()
    for t in durations:
        if duration >= t:
            result.append(tenors[t])
    
    return result^
