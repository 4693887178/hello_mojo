"""
RQAlpha Mojo - Click Helper
Ported from rqalpha/utils/click_helper.py
"""

from rqmojo.utils.datetime_func import DateTime, Date


struct DateParam:
    var tz: Optional[String]

    def __init__(out self, tz: Optional[String] = None):
        self.tz = tz

    def convert(self, value: String) raises -> Date:
        return Date.from_string(value)

    def name(self) -> String:
        return "DATE"
