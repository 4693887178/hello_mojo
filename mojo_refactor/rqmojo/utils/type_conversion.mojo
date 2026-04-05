"""
RQAlpha Mojo - Type Conversion Utilities
Handles type conversion between Python and Mojo types
"""

from std.collections import Dict, List, Optional
from std.python import PythonObject, Python
from rqmojo.utils.typing import DateTime, DateTimeDate
from rqmojo.const import SIDE, POSITION_DIRECTION, ORDER_STATUS, EXECUTION_PHASE
from morrow import Morrow


# ============================================================
# 日期时间类型转换
# ============================================================

def python_date_to_morrow(py_date: PythonObject) -> DateTime:
    """将Python日期对象转换为Morrow日期时间对象"""
    var year = Int(py=py_date.year)
    var month = Int(py=py_date.month)
    var day = Int(py=py_date.day)
    var hour = Int(py=py_date.hour)
    var minute = Int(py=py_date.minute)
    var second = Int(py=py_date.second)
    var microsecond = Int(py=py_date.microsecond)
    return Morrow(year, month, day, hour, minute, second, microsecond)


def morrow_to_python_date(dt: DateTime) -> PythonObject:
    """将Morrow日期时间对象转换为Python日期对象"""
    var py_datetime = Python.import_module("datetime")
    return py_datetime.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.microsecond)


def string_to_morrow(date_str: String) -> DateTime:
    """将字符串转换为Morrow日期时间对象"""
    # 支持格式: "2020-01-01", "2020-01-01 12:00:00"
    var parts = date_str.split(" ")
    var date_parts = parts[0].split("-")
    var year = Int(date_parts[0])
    var month = Int(date_parts[1])
    var day = Int(date_parts[2])
    
    var hour = 0
    var minute = 0
    var second = 0
    var microsecond = 0
    
    if parts.len() > 1:
        var time_parts = parts[1].split(":")
        if time_parts.len() >= 1:
            hour = Int(time_parts[0])
        if time_parts.len() >= 2:
            minute = Int(time_parts[1])
        if time_parts.len() >= 3:
            var sec_part = time_parts[2].split(".")
            second = Int(sec_part[0])
            if sec_part.len() >= 2:
                microsecond = Int(sec_part[1].pad_end(6, "0").slice(0, 6))
    
    return Morrow(year, month, day, hour, minute, second, microsecond)


def morrow_to_string(dt: DateTime) -> String:
    """将Morrow日期时间对象转换为字符串"""
    var year_str = String(dt.year)
    var month_str = String(dt.month).pad_start(2, "0")
    var day_str = String(dt.day).pad_start(2, "0")
    var hour_str = String(dt.hour).pad_start(2, "0")
    var minute_str = String(dt.minute).pad_start(2, "0")
    var second_str = String(dt.second).pad_start(2, "0")
    
    return year_str + "-" + month_str + "-" + day_str + " " + \
           hour_str + ":" + minute_str + ":" + second_str


# ============================================================
# 枚举类型转换
# ============================================================

def string_to_side(side_str: String) -> SIDE:
    """将字符串转换为SIDE枚举"""
    if side_str == "buy":
        return SIDE.BUY
    elif side_str == "sell":
        return SIDE.SELL
    else:
        return SIDE.BUY


def side_to_string(side: SIDE) -> String:
    """将SIDE枚举转换为字符串"""
    if side == SIDE.BUY:
        return "buy"
    else:
        return "sell"


def string_to_position_direction(dir_str: String) -> POSITION_DIRECTION:
    """将字符串转换为POSITION_DIRECTION枚举"""
    if dir_str == "long":
        return POSITION_DIRECTION.LONG
    elif dir_str == "short":
        return POSITION_DIRECTION.SHORT
    else:
        return POSITION_DIRECTION.LONG


def position_direction_to_string(direction: POSITION_DIRECTION) -> String:
    """将POSITION_DIRECTION枚举转换为字符串"""
    if direction == POSITION_DIRECTION.LONG:
        return "long"
    else:
        return "short"


def string_to_order_status(status_str: String) -> ORDER_STATUS:
    """将字符串转换为ORDER_STATUS枚举"""
    if status_str == "pending_new":
        return ORDER_STATUS.PENDING_NEW
    elif status_str == "active":
        return ORDER_STATUS.ACTIVE
    elif status_str == "filled":
        return ORDER_STATUS.FILLED
    elif status_str == "canceled":
        return ORDER_STATUS.CANCELLED
    elif status_str == "rejected":
        return ORDER_STATUS.REJECTED
    else:
        return ORDER_STATUS.PENDING_NEW


def order_status_to_string(status: ORDER_STATUS) -> String:
    """将ORDER_STATUS枚举转换为字符串"""
    if status == ORDER_STATUS.PENDING_NEW:
        return "pending_new"
    elif status == ORDER_STATUS.ACTIVE:
        return "active"
    elif status == ORDER_STATUS.FILLED:
        return "filled"
    elif status == ORDER_STATUS.CANCELLED:
        return "canceled"
    elif status == ORDER_STATUS.REJECTED:
        return "rejected"
    else:
        return "pending_new"


def string_to_execution_phase(phase_str: String) -> EXECUTION_PHASE:
    """将字符串转换为EXECUTION_PHASE枚举"""
    if phase_str == "GLOBAL":
        return EXECUTION_PHASE.GLOBAL
    elif phase_str == "INIT":
        return EXECUTION_PHASE.INIT
    elif phase_str == "BEFORE_TRADING":
        return EXECUTION_PHASE.BEFORE_TRADING
    elif phase_str == "TRADING":
        return EXECUTION_PHASE.TRADING
    elif phase_str == "AFTER_TRADING":
        return EXECUTION_PHASE.AFTER_TRADING
    elif phase_str == "SETTLEMENT":
        return EXECUTION_PHASE.SETTLEMENT
    else:
        return EXECUTION_PHASE.GLOBAL


def execution_phase_to_string(phase: EXECUTION_PHASE) -> String:
    """将EXECUTION_PHASE枚举转换为字符串"""
    if phase == EXECUTION_PHASE.GLOBAL:
        return "GLOBAL"
    elif phase == EXECUTION_PHASE.INIT:
        return "INIT"
    elif phase == EXECUTION_PHASE.BEFORE_TRADING:
        return "BEFORE_TRADING"
    elif phase == EXECUTION_PHASE.TRADING:
        return "TRADING"
    elif phase == EXECUTION_PHASE.AFTER_TRADING:
        return "AFTER_TRADING"
    elif phase == EXECUTION_PHASE.SETTLEMENT:
        return "SETTLEMENT"
    else:
        return "GLOBAL"


# ============================================================
# 集合类型转换
# ============================================================

def python_list_to_mojo_list(py_list: PythonObject) -> List[String]:
    """将Python列表转换为Mojo列表"""
    var mojo_list = List[String]()
    var length = Int(py=py_list.__len__())
    for i in range(length):
        var item = py_list.__getitem__(i)
        mojo_list.append(String(py=item))
    return mojo_list^


def mojo_list_to_python_list(mojo_list: List[String]) -> PythonObject:
    """将Mojo列表转换为Python列表"""
    var py_list = Python.import_module("list")()
    for item in mojo_list:
        py_list.append(item)
    return py_list


def python_dict_to_mojo_dict(py_dict: PythonObject) -> Dict[String, String]:
    """将Python字典转换为Mojo字典"""
    var mojo_dict = Dict[String, String]()
    var keys = py_dict.keys()
    var keys_list = Python.import_module("list")(keys)
    var length = Int(py=keys_list.__len__())
    for i in range(length):
        var key = keys_list.__getitem__(i)
        var value = py_dict.__getitem__(key)
        mojo_dict[String(py=key)] = String(py=value)
    return mojo_dict^


def mojo_dict_to_python_dict(mojo_dict: Dict[String, String]) -> PythonObject:
    """将Mojo字典转换为Python字典"""
    var py_dict = Python.import_module("dict")()
    for key, value in mojo_dict.items():
        py_dict[key] = value
    return py_dict


# ============================================================
# 数值类型转换
# ============================================================

def python_number_to_float(py_num: PythonObject) -> Float64:
    """将Python数值转换为Mojo Float64"""
    return Float64(py=py_num)


def python_number_to_int(py_num: PythonObject) -> Int:
    """将Python数值转换为Mojo Int"""
    return Int(py=py_num)


def float_to_python_number(value: Float64) -> PythonObject:
    """将Mojo Float64转换为Python数值"""
    var py_float = Python.import_module("float")
    return py_float(value)


def int_to_python_number(value: Int) -> PythonObject:
    """将Mojo Int转换为Python数值"""
    var py_int = Python.import_module("int")
    return py_int(value)


# ============================================================
# 布尔类型转换
# ============================================================

def python_bool_to_mojo_bool(py_bool: PythonObject) -> Bool:
    """将Python布尔值转换为Mojo Bool"""
    return Bool(py=py_bool)


def mojo_bool_to_python_bool(value: Bool) -> PythonObject:
    """将Mojo Bool转换为Python布尔值"""
    var py_bool = Python.import_module("bool")
    return py_bool(value)


# ============================================================
# 可选类型处理
# ============================================================

def python_none_to_optional() -> Optional[String]:
    """将Python None转换为Mojo Optional"""
    return Optional[String](None)


def optional_to_python_none(opt: Optional[String]) -> PythonObject:
    """将Mojo Optional转换为Python None"""
    if opt is None:
        return Python.import_module("None")
    else:
        return opt.value
