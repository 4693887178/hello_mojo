"""
RQAlpha Mojo - Click Helper
Ported from rqalpha/utils/click_helper.py
"""

from rqmojo.utils.typing import DateTime, DateTimeDate


struct DateParam:
    var tz: Optional[String]

    def __init__(out self, tz: Optional[String] = None):
        self.tz = tz

    def convert(self, value: String) raises -> DateTimeDate:
        return DateTimeDate.from_string(value)

    def name(self) -> String:
        return "DATE"
