from std.utils import StaticTuple
from std.collections.string import StaticString

# todo: hardcode for tmp
comptime _MAX_TIMESTAMP: Int = 32503737600
comptime MAX_TIMESTAMP = _MAX_TIMESTAMP
comptime MAX_TIMESTAMP_MS = MAX_TIMESTAMP * 1000
comptime MAX_TIMESTAMP_US = MAX_TIMESTAMP * 1_000_000

comptime _DAYS_IN_MONTH = StaticTuple[Int, 13](
    -1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
)
comptime _DAYS_BEFORE_MONTH = StaticTuple[Int, 13](
    -1, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
)  # -1 is a placeholder for indexing purposes.


comptime MONTH_NAMES = StaticTuple[StaticString, 13](
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
)

comptime MONTH_ABBREVIATIONS = StaticTuple[StaticString, 13](
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
)

comptime DAY_NAMES = StaticTuple[StaticString, 8](
    "",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
)
comptime DAY_ABBREVIATIONS = StaticTuple[StaticString, 8](
    "", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
)