from std.collections import InlineArray
from .constants import MONTH_NAMES, MONTH_ABBREVIATIONS, DAY_NAMES, DAY_ABBREVIATIONS
from .timezone import UTC_TZ
from .util import _pad_left, _string_slice


comptime _Y = ord("Y")
comptime _M = ord("M")
comptime _D = ord("D")
comptime _d = ord("d")
comptime _H = ord("H")
comptime _h = ord("h")
comptime _m = ord("m")
comptime _s = ord("s")
comptime _S = ord("S")
comptime _X = ord("X")
comptime _x = ord("x")
comptime _Z = ord("Z")
comptime _A = ord("A")
comptime _a = ord("a")


struct _Formatter:
    var _sub_chrs: InlineArray[Int, 128]

    def __init__(out self):
        self._sub_chrs = InlineArray[Int, 128](fill=0)
        for i in range(128):
            self._sub_chrs[i] = 0
        self._sub_chrs[_Y] = 4
        self._sub_chrs[_M] = 4
        self._sub_chrs[_D] = 2
        self._sub_chrs[_d] = 4
        self._sub_chrs[_H] = 2
        self._sub_chrs[_h] = 2
        self._sub_chrs[_m] = 2
        self._sub_chrs[_s] = 2
        self._sub_chrs[_S] = 6
        self._sub_chrs[_Z] = 3
        self._sub_chrs[_A] = 1
        self._sub_chrs[_a] = 1

    def format(self, m: Morrow, fmt: String) raises -> String:
        if len(fmt) == 0:
            return ""
        var ret: String = ""
        var in_bracket = False
        var start_idx = 0
        for i in range(len(fmt)):
            if fmt[byte=i] == "[":
                if in_bracket:
                    ret += "["
                else:
                    in_bracket = True
                ret += self.replace(m, _string_slice(fmt, start_idx, i))
                start_idx = i + 1
            elif fmt[byte=i] == "]":
                if in_bracket:
                    ret += _string_slice(fmt, start_idx, i)
                    in_bracket = False
                else:
                    ret += self.replace(m, _string_slice(fmt, start_idx, i))
                    ret += "]"
                start_idx = i + 1
        if in_bracket:
            ret += "["
        if start_idx < len(fmt):
            ret += self.replace(m, _string_slice(fmt, start_idx, len(fmt)))
        return ret

    def replace(self, m: Morrow, s: String) raises -> String:
        if len(s) == 0:
            return ""
        var ret: String = ""
        var match_chr_ord = 0
        var match_count = 0
        for i in range(len(s)):
            var c = ord(s[byte=i])
            if 0 < c < 128 and self._sub_chrs[c] > 0:
                if c == match_chr_ord:
                    match_count += 1
                else:
                    ret += self.replace_token(m, match_chr_ord, match_count)
                    match_chr_ord = c
                    match_count = 1
                if match_count == self._sub_chrs[c]:
                    ret += self.replace_token(m, match_chr_ord, match_count)
                    match_chr_ord = 0
            else:
                if match_chr_ord > 0:
                    ret += self.replace_token(m, match_chr_ord, match_count)
                    match_chr_ord = 0
                ret += s[byte=i]
        if match_chr_ord > 0:
            ret += self.replace_token(m, match_chr_ord, match_count)
        return ret

    def replace_token(
        self, m: Morrow, token: Int, token_count: Int
    ) raises -> String:
        if token == _Y:
            if token_count == 1:
                return "Y"
            if token_count == 2:
                var year_str = _pad_left(String(m.year), 4, "0")
                return _string_slice(year_str, 2, 4)
            if token_count == 4:
                return _pad_left(String(m.year), 4, "0")
        elif token == _M:
            if token_count == 1:
                return String(m.month)
            if token_count == 2:
                return _pad_left(String(m.month), 2, "0")
            if token_count == 3:
                return self._get_month_abbr(m.month)
            if token_count == 4:
                return self._get_month_name(m.month)
        elif token == _D:
            if token_count == 1:
                return String(m.day)
            if token_count == 2:
                return _pad_left(String(m.day), 2, "0")
        elif token == _H:
            if token_count == 1:
                return String(m.hour)
            if token_count == 2:
                return _pad_left(String(m.hour), 2, "0")
        elif token == _h:
            var h_12 = m.hour
            if m.hour > 12:
                h_12 -= 12
            if token_count == 1:
                return String(h_12)
            if token_count == 2:
                return _pad_left(String(h_12), 2, "0")
        elif token == _m:
            if token_count == 1:
                return String(m.minute)
            if token_count == 2:
                return _pad_left(String(m.minute), 2, "0")
        elif token == _s:
            if token_count == 1:
                return String(m.second)
            if token_count == 2:
                return _pad_left(String(m.second), 2, "0")
        elif token == _S:
            if token_count == 1:
                return String(m.microsecond // 100000)
            if token_count == 2:
                return _pad_left(String(m.microsecond // 10000), 2, "0")
            if token_count == 3:
                return _pad_left(String(m.microsecond // 1000), 3, "0")
            if token_count == 4:
                return _pad_left(String(m.microsecond // 100), 4, "0")
            if token_count == 5:
                return _pad_left(String(m.microsecond // 10), 5, "0")
            if token_count == 6:
                return _pad_left(String(m.microsecond), 6, "0")
        elif token == _d:
            var weekday = m.isoweekday()
            if token_count == 1:
                return String(weekday)
            if token_count == 3:
                return self._get_day_abbr(weekday)
            if token_count == 4:
                return self._get_day_name(weekday)
        elif token == _Z:
            if token_count == 3:
                return UTC_TZ.name if m.tz.is_none() else m.tz.name
            var separator = "" if token_count == 1 else ":"
            if m.tz.is_none():
                return UTC_TZ.format(separator)
            else:
                return m.tz.format(separator)

        elif token == _a:
            return "am" if m.hour < 12 else "pm"
        elif token == _A:
            return "AM" if m.hour < 12 else "PM"
        return ""

    def _get_month_name(self, month: Int) -> String:
        if month == 1:
            return "January"
        elif month == 2:
            return "February"
        elif month == 3:
            return "March"
        elif month == 4:
            return "April"
        elif month == 5:
            return "May"
        elif month == 6:
            return "June"
        elif month == 7:
            return "July"
        elif month == 8:
            return "August"
        elif month == 9:
            return "September"
        elif month == 10:
            return "October"
        elif month == 11:
            return "November"
        elif month == 12:
            return "December"
        return ""

    def _get_month_abbr(self, month: Int) -> String:
        if month == 1:
            return "Jan"
        elif month == 2:
            return "Feb"
        elif month == 3:
            return "Mar"
        elif month == 4:
            return "Apr"
        elif month == 5:
            return "May"
        elif month == 6:
            return "Jun"
        elif month == 7:
            return "Jul"
        elif month == 8:
            return "Aug"
        elif month == 9:
            return "Sep"
        elif month == 10:
            return "Oct"
        elif month == 11:
            return "Nov"
        elif month == 12:
            return "Dec"
        return ""

    def _get_day_name(self, weekday: Int) -> String:
        if weekday == 1:
            return "Monday"
        elif weekday == 2:
            return "Tuesday"
        elif weekday == 3:
            return "Wednesday"
        elif weekday == 4:
            return "Thursday"
        elif weekday == 5:
            return "Friday"
        elif weekday == 6:
            return "Saturday"
        elif weekday == 7:
            return "Sunday"
        return ""

    def _get_day_abbr(self, weekday: Int) -> String:
        if weekday == 1:
            return "Mon"
        elif weekday == 2:
            return "Tue"
        elif weekday == 3:
            return "Wed"
        elif weekday == 4:
            return "Thu"
        elif weekday == 5:
            return "Fri"
        elif weekday == 6:
            return "Sat"
        elif weekday == 7:
            return "Sun"
        return ""
