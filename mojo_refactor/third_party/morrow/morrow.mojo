from ._py import py_dt_datetime
from .util import normalize_timestamp, _ymd2ord, _days_before_year, _pad_left
from ._libc import c_gettimeofday, c_localtime, c_gmtime, c_strptime
from ._libc import CTimeval, CTm
from .timezone import TimeZone
from .timedelta import TimeDelta
from .formatter import _Formatter
from .constants import _DAYS_BEFORE_MONTH, _DAYS_IN_MONTH
from std.python import PythonObject, Python


comptime _DI400Y = 146097
comptime _DI100Y = 36524
comptime _DI4Y = 1461


struct Morrow(Copyable, Movable, Writable, ImplicitlyCopyable):
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var microsecond: Int
    var tz: TimeZone

    def __init__(
        out self,
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        microsecond: Int = 0,
        tz: TimeZone = TimeZone.none(),
    ):
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.microsecond = microsecond
        self.tz = tz

    @staticmethod
    def now() -> Self:
        var t = c_gettimeofday()
        return Self._fromtimestamp(t, False)

    @staticmethod
    def utcnow() -> Self:
        var t = c_gettimeofday()
        return Self._fromtimestamp(t, True)

    @staticmethod
    def _fromtimestamp(t: CTimeval, utc: Bool) -> Self:
        var tm: CTm
        var tz: TimeZone
        if utc:
            tm = c_gmtime(t.tv_sec)
            tz = TimeZone(0, "UTC")
        else:
            tm = c_localtime(t.tv_sec)
            tz = TimeZone(Int(tm.tm_gmtoff), "local")

        var result = Self(
            Int(tm.tm_year) + 1900,
            Int(tm.tm_mon) + 1,
            Int(tm.tm_mday),
            Int(tm.tm_hour),
            Int(tm.tm_min),
            Int(tm.tm_sec),
            t.tv_usec,
            tz,
        )
        return result

    @staticmethod
    def fromtimestamp(timestamp: Float64) raises -> Self:
        var timestamp_ = normalize_timestamp(timestamp)
        var t = CTimeval(Int(timestamp_), 0)
        return Self._fromtimestamp(t, False)

    @staticmethod
    def utcfromtimestamp(timestamp: Float64) raises -> Self:
        var timestamp_ = normalize_timestamp(timestamp)
        var t = CTimeval(Int(timestamp_), 0)
        return Self._fromtimestamp(t, True)

    @staticmethod
    def strptime(
        date_str: String, fmt: String, tzinfo: TimeZone = TimeZone.none()
    ) -> Self:
        var tm = c_strptime(date_str, fmt)
        var tz = TimeZone(Int(tm.tm_gmtoff), "") if tzinfo.is_none() else tzinfo
        return Self(
            Int(tm.tm_year) + 1900,
            Int(tm.tm_mon) + 1,
            Int(tm.tm_mday),
            Int(tm.tm_hour),
            Int(tm.tm_min),
            Int(tm.tm_sec),
            0,
            tz,
        )

    @staticmethod
    def strptime(date_str: String, fmt: String, tz_str: String) raises -> Self:
        var tzinfo = TimeZone.from_utc(tz_str)
        return Self.strptime(date_str, fmt, tzinfo)

    def format(self, fmt: String = "YYYY-MM-DD HH:mm:ss ZZ") raises -> String:
        return _Formatter().format(self, fmt)

    def isoformat(
        self, sep: String = "T", timespec: StringLiteral = "auto"
    ) raises -> String:
        var date_str = (
            _pad_left(String(self.year), 4, "0")
            + "-"
            + _pad_left(String(self.month), 2, "0")
            + "-"
            + _pad_left(String(self.day), 2, "0")
        )
        var time_str = String("")
        if timespec == "auto" or timespec == "microseconds":
            time_str = (
                _pad_left(String(self.hour), 2, "0")
                + ":"
                + _pad_left(String(self.minute), 2, "0")
                + ":"
                + _pad_left(String(self.second), 2, "0")
                + "."
                + _pad_left(String(self.microsecond), 6, "0")
            )
        elif timespec == "milliseconds":
            time_str = (
                _pad_left(String(self.hour), 2, "0")
                + ":"
                + _pad_left(String(self.minute), 2, "0")
                + ":"
                + _pad_left(String(self.second), 2, "0")
                + "."
                + _pad_left(String(self.microsecond // 1000), 3, "0")
            )
        elif timespec == "seconds":
            time_str = (
                _pad_left(String(self.hour), 2, "0")
                + ":"
                + _pad_left(String(self.minute), 2, "0")
                + ":"
                + _pad_left(String(self.second), 2, "0")
            )
        elif timespec == "minutes":
            time_str = (
                _pad_left(String(self.hour), 2, "0")
                + ":"
                + _pad_left(String(self.minute), 2, "0")
            )
        elif timespec == "hours":
            time_str = _pad_left(String(self.hour), 2, "0")
        else:
            raise Error()
        if self.tz.is_none():
            return date_str + sep + time_str
        else:
            return date_str + sep + time_str + self.tz.format()

    def toordinal(self) raises -> Int:
        return _ymd2ord(self.year, self.month, self.day)

    def isoweekday(self) raises -> Int:
        return self.toordinal() % 7 or 7

    def __str__(self) raises -> String:
        return self.isoformat()

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "Morrow(year=", self.year, ", month=", self.month, ", day=", self.day,
            ", hour=", self.hour, ", minute=", self.minute, ", second=", self.second,
            ", microsecond=", self.microsecond, ", tz=", self.tz.name, ")"
        )

    def __sub__(self, other: Self) raises -> TimeDelta:
        var days1 = self.toordinal()
        var days2 = other.toordinal()
        var secs1 = self.second + self.minute * 60 + self.hour * 3600
        var secs2 = other.second + other.minute * 60 + other.hour * 3600
        var base = TimeDelta(
            days1 - days2, secs1 - secs2, self.microsecond - other.microsecond
        )
        return base^

    def to_py(self) raises -> PythonObject:
        var datetime = Python.import_module("datetime")
        return datetime.datetime(
            self.year,
            self.month,
            self.day,
            self.hour,
            self.minute,
            self.second,
            self.microsecond,
        )

    @staticmethod
    def from_py(py_datetime: PythonObject) raises -> Self:
        if py_datetime.__class__.__name__ == "datetime":
            return Self(
                Int(py=py_datetime.year),
                Int(py=py_datetime.month),
                Int(py=py_datetime.day),
                Int(py=py_datetime.hour),
                Int(py=py_datetime.minute),
                Int(py=py_datetime.second),
                Int(py=py_datetime.microsecond),
            )
        elif py_datetime.__class__.__name__ == "date":
            return Self(
                Int(py=py_datetime.year),
                Int(py=py_datetime.month),
                Int(py=py_datetime.day),
            )
        else:
            raise Error(
                "invalid python object, only support py builtin datetime or date"
            )

    @staticmethod
    def fromordinal(ordinal: Int) raises -> Self:
        var n = ordinal
        n -= 1
        var n400 = n // _DI400Y
        n = n % _DI400Y
        var year = n400 * 400 + 1

        var n100 = n // _DI100Y
        n = n % _DI100Y

        var n4 = n // _DI4Y
        n = n % _DI4Y

        var n1 = n // 365
        n = n % 365

        year += n100 * 100 + n4 * 4 + n1
        if n1 == 4 or n100 == 4:
            return Self(year - 1, 12, 31)

        var leapyear = n1 == 3 and (n4 != 24 or n100 == 3)
        var month = (n + 50) >> 5
        var preceding: Int
        if month > 2 and leapyear:
            preceding = _DAYS_BEFORE_MONTH[month] + 1
        else:
            preceding = _DAYS_BEFORE_MONTH[month]
        if preceding > n:
            month -= 1
            if month == 2 and leapyear:
                preceding -= _DAYS_BEFORE_MONTH[month] + 1
            else:
                preceding -= _DAYS_BEFORE_MONTH[month]
        n -= preceding

        return Self(year, month, n + 1)

