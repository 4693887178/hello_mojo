from std.collections.string import Codepoint
from ._libc import c_localtime

comptime UTC_TZ = TimeZone(0, "UTC")


struct TimeZone(Writable, ImplicitlyCopyable):
    var offset: Int
    var name: String

    def __init__(out self, offset: Int, name: String = ""):
        self.offset = offset
        self.name = name

    def __str__(self) -> String:
        return self.name

    def is_none(self) -> Bool:
        """
        Check if this TimeZone is None.
        """
        return self.name == "None"

    @staticmethod
    def none() -> TimeZone:
        """
        Create a None TimeZone.
        """
        return TimeZone(0, "None")

    @staticmethod
    def local() -> TimeZone:
        """
        Get the local TimeZone.
        """
        var local_t = c_localtime(0)
        return TimeZone(Int(local_t.tm_gmtoff), "local")

    @staticmethod
    def from_utc(utc_str: String) raises -> TimeZone:
        """
        Create a TimeZone from a UTC string.
        """
        if len(utc_str) == 0:
            raise Error("utc_str is empty")
        if utc_str == "utc" or utc_str == "UTC" or utc_str == "Z":
            return TimeZone(0, "utc")
        var p = 3 if len(utc_str) > 3 and utc_str[byte=0:3] == "UTC" else 0

        var sign = -1 if utc_str[byte=p] == "-" else 1
        if utc_str[byte=p] == "+" or utc_str[byte=p] == "-":
            p += 1

        if (
            len(utc_str) < p + 2
            or not Codepoint.ord(utc_str[byte=p]).is_ascii_digit()
            or not Codepoint.ord(utc_str[byte=p + 1]).is_ascii_digit()
        ):
            raise Error("utc_str format is invalid")
        var hours: Int = Int(utc_str[byte=p : p + 2])
        p += 2

        var minutes: Int
        if len(utc_str) <= p:
            minutes = 0
        elif len(utc_str) == p + 3 and utc_str[byte=p] == ":":
            minutes = Int(utc_str[byte=p + 1 : p + 3])
        elif len(utc_str) == p + 2 and Codepoint.ord(utc_str[byte=p]).is_ascii_digit():
            minutes = Int(utc_str[byte=p : p + 2])
        else:
            _ = 0
            raise Error("utc_str format is invalid")
        var offset: Int = sign * (hours * 3600 + minutes * 60)
        return TimeZone(offset)

    def format(self, sep: String = ":") -> String:
        """
        Format the TimeZone as a string.
        """
        var sign: String
        var offset_abs: Int
        if self.offset < 0:
            sign = "-"
            offset_abs = -self.offset
        else:
            sign = "+"
            offset_abs = self.offset
        var hh = offset_abs // 3600
        var mm = offset_abs % 3600
        return sign + String(hh).ascii_rjust(2, "0") + sep + String(mm).ascii_rjust(2, "0")
