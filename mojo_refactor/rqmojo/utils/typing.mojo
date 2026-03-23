"""
RQAlpha Mojo - Type Aliases
Ported from rqalpha/utils/typing.py
"""

from std.collections import List
from utils import Variant
from python import Python, PythonObject
from rqmojo.const import POSITION_DIRECTION


def _py_int_to_int(py_obj: PythonObject) raises -> Int:
    var builtins = Python.import_module("builtins")
    var s = builtins.str(py_obj)
    return Int(String(s))


@fieldwise_init
struct DateTimeDate(Copyable, Movable, ImplicitlyCopyable):
    var year: Int
    var month: Int
    var day: Int
    
    def __str__(self) -> String:
        return String(self.year) + "-" + String(self.month) + "-" + String(self.day)
    
    @staticmethod
    def from_string(s: String) raises -> DateTimeDate:
        var parts = s.split("-")
        if len(parts) >= 3:
            return DateTimeDate(Int(parts[0]), Int(parts[1]), Int(parts[2]))
        return DateTimeDate(1970, 1, 1)


@fieldwise_init
struct DateTime(Copyable, Movable, ImplicitlyCopyable):
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    
    def __str__(self) -> String:
        return String(self.year) + "-" + String(self.month) + "-" + String(self.day) + " " + String(self.hour) + ":" + String(self.minute) + ":" + String(self.second)
    
    def date(self) -> DateTimeDate:
        return DateTimeDate(self.year, self.month, self.day)
    
    def replace(mut self, hour: Int = -1, minute: Int = -1, second: Int = -1, microsecond: Int = -1) -> DateTime:
        if hour >= 0:
            self.hour = hour
        if minute >= 0:
            self.minute = minute
        if second >= 0:
            self.second = second
        if microsecond >= 0:
            self.microsecond = microsecond
        return self
    
    def to_string(self) -> String:
        return self.__str__()
    
    @staticmethod
    def now() raises -> DateTime:
        var datetime_module = Python.import_module("datetime")
        var py_now = datetime_module.datetime.now()
        return DateTime(
            _py_int_to_int(py_now.year),
            _py_int_to_int(py_now.month),
            _py_int_to_int(py_now.day),
            _py_int_to_int(py_now.hour),
            _py_int_to_int(py_now.minute),
            _py_int_to_int(py_now.second),
            _py_int_to_int(py_now.microsecond)
        )
    
    @staticmethod
    def parse(s: String) raises -> DateTime:
        var datetime_module = Python.import_module("datetime")
        var py_dt = datetime_module.datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
        return DateTime(
            _py_int_to_int(py_dt.year),
            _py_int_to_int(py_dt.month),
            _py_int_to_int(py_dt.day),
            _py_int_to_int(py_dt.hour),
            _py_int_to_int(py_dt.minute),
            _py_int_to_int(py_dt.second),
            0
        )


comptime DateLike = Variant[DateTimeDate, DateTime, Int]
comptime StrOrIter = Variant[String, List[String]]
comptime POSITION_DIRECTION_TYPE = Variant[String, POSITION_DIRECTION]
