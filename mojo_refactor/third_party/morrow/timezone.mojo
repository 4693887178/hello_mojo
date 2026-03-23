from ._libc import c_localtime
from .util import _pad_left, _string_slice


@fieldwise_init
struct TimeZone(Copyable, Movable, Writable, ImplicitlyCopyable):
    var offset: Int
    var name: String

    def write_to(self, mut writer: Some[Writer]):
        writer.write(self.name)

    def is_none(self) -> Bool:
        return self.name == "None"

    @staticmethod
    def none() -> TimeZone:
        return TimeZone(0, "None")

    @staticmethod
    def local() -> TimeZone:
        var local_t = c_localtime(0)
        return TimeZone(Int(local_t.tm_gmtoff), "local")

    @staticmethod
    def from_utc(utc_str: String) raises -> TimeZone:
        if len(utc_str) == 0:
            raise Error("utc_str is empty")
        if utc_str == "utc" or utc_str == "UTC" or utc_str == "Z":
            return TimeZone(0, "utc")
        var p = 3 if len(utc_str) > 3 and _string_slice(utc_str, 0, 3) == "UTC" else 0

        var sign = -1 if utc_str[byte=p] == "-" else 1
        if utc_str[byte=p] == "+" or utc_str[byte=p] == "-":
            p += 1

        if (
            len(utc_str) < p + 2
            or not _is_digit_char(utc_str[byte=p])
            or not _is_digit_char(utc_str[byte=p + 1])
        ):
            raise Error("utc_str format is invalid")
        var hours: Int = atol(_string_slice(utc_str, p, p + 2))
        p += 2

        var minutes: Int
        if len(utc_str) <= p:
            minutes = 0
        elif len(utc_str) == p + 3 and utc_str[byte=p] == ":":
            minutes = atol(_string_slice(utc_str, p + 1, p + 3))
        elif len(utc_str) == p + 2 and _is_digit_char(utc_str[byte=p]):
            minutes = atol(_string_slice(utc_str, p, p + 2))
        else:
            minutes = 0
            raise Error("utc_str format is invalid")
        var offset: Int = sign * (hours * 3600 + minutes * 60)
        return TimeZone(offset, "")

    def format(self, sep: String = ":") -> String:
        var sign: String
        var offset_abs: Int
        if self.offset < 0:
            sign = "-"
            offset_abs = -self.offset
        else:
            sign = "+"
            offset_abs = self.offset
        var hh = offset_abs // 3600
        var mm = (offset_abs % 3600) // 60
        return sign + _pad_left(String(hh), 2, "0") + sep + _pad_left(String(mm), 2, "0")


def _is_digit_char(ch: StringSlice) -> Bool:
    if len(ch) != 1:
        return False
    var byte_val = ord(ch[byte=0])
    return byte_val >= 48 and byte_val <= 57


comptime UTC_TZ = TimeZone(0, "UTC")
