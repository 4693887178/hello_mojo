"""
RQAlpha Mojo - Type Aliases
Ported from rqalpha/utils/typing.py
"""

from std.collections import List
from utils import Variant
from rqmojo.const import POSITION_DIRECTION
from rqmojo.utils.datetime_func import Date, DateTime


comptime DateLike = Variant[Date, DateTime, Int]
comptime StrOrIter = Variant[String, List[String]]
comptime POSITION_DIRECTION_TYPE = Variant[String, POSITION_DIRECTION]


def main():
    """Test main function for typing module."""
    print("typing.mojo - Type aliases module loaded successfully")
