"""
RQAlpha Mojo - DateTime Functions
Ported from rqalpha/utils/datetime_func.py
"""

from python import Python, PythonObject


def _py_int_to_int(py_obj: PythonObject) raises -> Int:
    var builtins = Python.import_module("builtins")
    var s = builtins.str(py_obj)
    return Int(String(s))


@fieldwise_init
struct TimeRange(Copyable, Movable, ImplicitlyCopyable):
    var start_hour: Int
    var start_minute: Int
    var end_hour: Int
    var end_minute: Int


@fieldwise_init
struct Date(Copyable, Movable, ImplicitlyCopyable):
    var year: Int
    var month: Int
    var day: Int
    
    def __str__(self) -> String:
        return String(self.year) + "-" + String(self.month) + "-" + String(self.day)
    
    @staticmethod
    def from_string(s: String) raises -> Date:
        var parts = s.split("-")
        if len(parts) >= 3:
            return Date(Int(parts[0]), Int(parts[1]), Int(parts[2]))
        return Date(1970, 1, 1)


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
    
    def date(self) -> Date:
        return Date(self.year, self.month, self.day)
    
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


def convert_date_to_date_int(dt: Date) -> Int:
    return dt.year * 10000 + dt.month * 100 + dt.day


def convert_date_to_int(dt: Date) -> Int:
    return dt.year * 10000000000000 + dt.month * 100000000000 + dt.day * 1000000000


def convert_dt_to_int(dt: DateTime) -> Int:
    var t = convert_date_to_int(dt.date())
    t += dt.hour * 10000000 + dt.minute * 100000 + dt.second * 1000
    return t


def convert_int_to_date(dt_int: Int) -> DateTime:
    var dt = dt_int
    if dt > 100000000:
        dt //= 1000000
    return _convert_int_to_date(dt)


def _convert_int_to_date(dt_int: Int) -> DateTime:
    var year = dt_int // 10000
    var r = dt_int % 10000
    var month = r // 100
    var day = r % 100
    return DateTime(year, month, day, 0, 0, 0, 0)


def convert_int_to_datetime(dt_int: Int) -> DateTime:
    var dt = dt_int
    var ms = 0
    if dt > 10000000000:
        ms = dt % 1000
        dt //= 1000
    var year = dt // 10000000000
    var r = dt % 10000000000
    var month = r // 100000000
    r = r % 100000000
    var day = r // 1000000
    r = r % 1000000
    var hour = r // 10000
    r = r % 10000
    var minute = r // 100
    var second = r % 100
    return DateTime(year, month, day, hour, minute, second, ms * 1000)


def convert_ms_int_to_datetime(ms_dt_int: Int) -> DateTime:
    return convert_int_to_datetime(ms_dt_int)


def convert_date_time_ms_int_to_datetime(date_int: Int, time_int: Int) -> DateTime:
    var dt = _convert_int_to_date(date_int)
    var hours = time_int // 10000000
    var r = time_int % 10000000
    var minutes = r // 100000
    r = r % 100000
    var seconds = r // 1000
    var millisecond = r % 1000
    return dt.replace(hour=hours, minute=minutes, second=seconds, microsecond=millisecond * 1000)


def to_date_from_string(date_str: String) raises -> Date:
    var parser = Python.import_module("dateutil.parser")
    var py_dt = parser.parse(date_str)
    return Date(
        _py_int_to_int(py_dt.year),
        _py_int_to_int(py_dt.month),
        _py_int_to_int(py_dt.day)
    )


def to_date_from_datetime(dt: DateTime) -> Date:
    return dt.date()


def to_date_from_date(d: Date) -> Date:
    return d


def to_date_from_py_datetime(py_dt: PythonObject) raises -> Date:
    var datetime_module = Python.import_module("datetime")
    var builtins = Python.import_module("builtins")
    
    if builtins.isinstance(py_dt, datetime_module.datetime):
        return Date(
            _py_int_to_int(py_dt.year),
            _py_int_to_int(py_dt.month),
            _py_int_to_int(py_dt.day)
        )
    elif builtins.isinstance(py_dt, datetime_module.date):
        return Date(
            _py_int_to_int(py_dt.year),
            _py_int_to_int(py_dt.month),
            _py_int_to_int(py_dt.day)
        )
    else:
        raise Error("Invalid Python datetime object: " + builtins.str(py_dt))
