"""
RQAlpha Mojo - Click Helper (CLI Date Parameter Type)
Ported from rqalpha/utils/click_helper.py

Python: class Date(click.ParamType)  -- Click custom param type for date parsing
Mojo:  struct Date                  -- Standalone date converter for argmojo integration

Usage with argmojo (functionally equivalent to Click's type=Date()):

    # Python Click (automatic conversion):
    @click.option('-s', '--start-date', type=Date())
    def run(start_date):  # start_date is already pd.Timestamp

    # Mojo argmojo (manual conversion):
    var result = cmd.parse_arguments(args)
    var start_date = Date().convert(result.get_string("start_date"))  # → Morrow
"""

from rqmojo.utils.typing import DateTimeDate
from argmojo import ParseResult


struct Date(Movable):
    """Custom date parameter type for CLI argument parsing.

    Equivalent to Python's ``class Date(click.ParamType)``.
    Used with argmojo to convert string CLI arguments into DateTimeDate (Morrow) objects.

    Python original:
        class Date(click.ParamType):
            def convert(self, value, param, ctx):
                return pd.Timestamp(value)
            @property
            def name(self):
                return type(self).__name__.upper()
    """

    var tz: Optional[String]

    def __init__(out self, tz: Optional[String] = None):
        self.tz = tz

    def convert(self, value: String) raises -> DateTimeDate:
        """Convert a date string to DateTimeDate (Morrow).

        Supports formats: YYYY-MM-DD, YYYY/MM/DD, YYYYMMDD
        Equivalent to Python's ``pd.Timestamp(value)``.
        """
        var trimmed = String(value.strip())

        if len(trimmed) == 10 and trimmed[byte=4] == '-' and trimmed[byte=7] == '-':
            return DateTimeDate.strptime(trimmed, "%Y-%m-%d")
        elif len(trimmed) == 10 and trimmed[byte=4] == '/' and trimmed[byte=7] == '/':
            return DateTimeDate.strptime(trimmed, "%Y/%m/%d")
        elif len(trimmed) == 8:
            return DateTimeDate.strptime(trimmed, "%Y%m%d")
        else:
            return DateTimeDate.strptime(trimmed, "%Y-%m-%d")

    def name(self) -> String:
        """Return the type name for display in help text.

        Python: ``type(self).__name__.upper()`` → "DATE"
        Mojo:   instance method returning literal → "DATE"
        """
        return "DATE"


def get_date(result: ParseResult, name: String) raises -> DateTimeDate:
    """Convenience helper: extract and convert a date argument from ParseResult.

    This bridges argmojo's ParseResult with the Date type converter,
    providing a one-call equivalent to Click's automatic type=Date() conversion.

    Usage:
        var start = get_date(result, "start_date")
        var end = get_date(result, "end_date")
    """
    var raw = result.get_string(name)
    return Date().convert(raw)
