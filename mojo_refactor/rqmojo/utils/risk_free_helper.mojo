"""
RQAlpha Mojo - Risk Free Rate Helper
Ported from rqalpha/utils/risk_free_helper.py
Reference: rqcpp/utils/risk_free_helper.cppm
"""

from rqmojo.utils.datetime_func import DateTime, Date
from collections import Dict, List


fn get_yield_curve_tenors() -> Dict[Int, String]:
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


fn get_yield_curve_duration() -> List[Int]:
    var tenors = get_yield_curve_tenors()
    var keys = tenors.keys()
    var result = List[Int]()
    for k in keys:
        result.append(k)
    return result^


fn get_tenor_for(start_date: Date, end_date: Date) raises -> String:
    var duration = (end_date.year - start_date.year) * 365 + (end_date.month - start_date.month) * 30 + (end_date.day - start_date.day)
    
    var tenors = get_yield_curve_tenors()
    var durations = get_yield_curve_duration()
    var result = "0S"
    for t in durations:
        if duration >= t:
            result = tenors[t]
        else:
            break
    
    return result


fn get_tenors_for(start_date: Date, end_date: Date) raises -> List[String]:
    var duration = (end_date.year - start_date.year) * 365 + (end_date.month - start_date.month) * 30 + (end_date.day - start_date.day)
    
    var tenors = get_yield_curve_tenors()
    var durations = get_yield_curve_duration()
    var result = List[String]()
    for t in durations:
        if duration >= t:
            result.append(tenors[t])
    
    return result^
