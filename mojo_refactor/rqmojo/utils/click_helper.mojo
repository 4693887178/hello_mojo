"""
RQAlpha Mojo - Click Helper
Ported from rqalpha/utils/click_helper.py
"""

from rqmojo.utils.datetime_func import DateTime


struct DateParam:
    var tz: Optional[String]

    fn __init__(inout self, tz: Optional[String] = None) -> Self:
        return Self(tz=tz)

    fn convert(self, value: String) -> DateTime:
        return DateTime.from_string(value)

    fn name(self) -> String:
        return "DATE"
