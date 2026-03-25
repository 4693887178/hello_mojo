from std.collections import InlineArray
from .constants import (
    MONTH_NAMES,
    MONTH_ABBREVIATIONS,
    DAY_NAMES,
    DAY_ABBREVIATIONS,
)
from .timezone import UTC_TZ
from .morrow import Morrow

# Global formatter instance
comptime formatter = _Formatter()


struct _Formatter(ImplicitlyCopyable):
    # Vector to store the maximum number of repetitions for each formatting character
    var _sub_chrs: InlineArray[Int, 128]

    def __init__(out self):
        self._sub_chrs = InlineArray[Int, 128](fill=0)
        for i in range(128):
            self._sub_chrs[i] = 0
        # Set the maximum number of repetitions for each formatting character
        self._sub_chrs[_Y] = 4  # Year
        self._sub_chrs[_M] = 4  # Month
        self._sub_chrs[_D] = 2  # Day
        self._sub_chrs[_d] = 4  # Day of week
        self._sub_chrs[_H] = 2  # Hour (24-hour)
        self._sub_chrs[_h] = 2  # Hour (12-hour)
        self._sub_chrs[_m] = 2  # Minute
        self._sub_chrs[_s] = 2  # Second
        self._sub_chrs[_S] = 6  # Microsecond
        self._sub_chrs[_Z] = 3  # Timezone
        self._sub_chrs[_A] = 1  # AM/PM
        self._sub_chrs[_a] = 1  # am/pm

    def format(self, m: Morrow, fmt: String) raises -> String:
        """
        Format the Morrow object according to the given format string.
        Handles brackets for literal text: "YYYY[abc]MM" -> replace("YYYY") + "abc" + replace("MM")
        """
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
                ret += self.replace(m, String(fmt[byte=start_idx:i]))
                start_idx = i + 1
            elif fmt[byte=i] == "]":
                if in_bracket:
                    ret += String(fmt[byte=start_idx:i])
                    in_bracket = False
                else:
                    ret += self.replace(m, String(fmt[byte=start_idx:i]))
                    ret += "]"
                start_idx = i + 1
        if in_bracket:
            ret += "["
        if start_idx < len(fmt):
            ret += self.replace(m, String(fmt[byte=start_idx:]))
        return ret

    def replace(self, m: Morrow, s: String) raises -> String:
        """
        Replace formatting tokens in the string with their corresponding values
        """
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
        # Replace individual formatting tokens based on their type and count
        if token == _Y:
            if token_count == 1:
                return "Y"
            if token_count == 2:
                return String(String(m.year).ascii_rjust(4, "0")[byte=2:4])
            if token_count == 4:
                return String(m.year).ascii_rjust(4, "0")
        elif token == _M:
            if token_count == 1:
                return String(m.month)
            if token_count == 2:
                return String(m.month).ascii_rjust(2, "0")
            if token_count == 3:
                return MONTH_ABBREVIATIONS[m.month]
            if token_count == 4:
                return MONTH_NAMES[m.month]
        elif token == _D:
            if token_count == 1:
                return String(m.day)
            if token_count == 2:
                return String(m.day).ascii_rjust(2, "0")
        elif token == _H:
            if token_count == 1:
                return String(m.hour)
            if token_count == 2:
                return String(m.hour).ascii_rjust(2, "0")
        elif token == _h:
            var h_12 = m.hour
            if m.hour > 12:
                h_12 -= 12
            if token_count == 1:
                return String(h_12)
            if token_count == 2:
                return String(h_12).ascii_rjust(2, "0")
        elif token == _m:
            if token_count == 1:
                return String(m.minute)
            if token_count == 2:
                return String(m.minute).ascii_rjust(2, "0")
        elif token == _s:
            if token_count == 1:
                return String(m.second)
            if token_count == 2:
                return String(m.second).ascii_rjust(2, "0")
        elif token == _S:
            if token_count == 1:
                return String(m.microsecond // 100000)
            if token_count == 2:
                return String(m.microsecond // 10000).ascii_rjust(2, "0")
            if token_count == 3:
                return String(m.microsecond // 1000).ascii_rjust(3, "0")
            if token_count == 4:
                return String(m.microsecond // 100).ascii_rjust(4, "0")
            if token_count == 5:
                return String(m.microsecond // 10).ascii_rjust(5, "0")
            if token_count == 6:
                return String(m.microsecond).ascii_rjust(6, "0")
        elif token == _d:
            if token_count == 1:
                return String(m.isoweekday())
            if token_count == 3:
                return String(DAY_ABBREVIATIONS[m.isoweekday()])
            if token_count == 4:
                return String(DAY_NAMES[m.isoweekday()])
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


# Define constants for formatting characters
comptime _Y = ord("Y")  # Year
comptime _M = ord("M")  # Month
comptime _D = ord("D")  # Day
comptime _d = ord("d")  # Day of week
comptime _H = ord("H")  # Hour (24-hour)
comptime _h = ord("h")  # Hour (12-hour)
comptime _m = ord("m")  # Minute
comptime _s = ord("s")  # Second
comptime _S = ord("S")  # Microsecond
comptime _X = ord("X")  # Time
comptime _x = ord("x")  # Date
comptime _Z = ord("Z")  # Timezone
comptime _A = ord("A")  # AM/PM
comptime _a = ord("a")  # am/pm
