"""
RQAlpha Mojo - Type Aliases
Ported from rqalpha/utils/typing.py
"""

from std.collections import List
from utils import Variant
from rqmojo.const import POSITION_DIRECTION
from morrow import Morrow


comptime DateTime = Morrow
comptime DateTimeDate = Morrow
comptime DateLike = Variant[Morrow, Int, String]
comptime StrOrIter = Variant[String, List[String]]
comptime POSITION_DIRECTION_TYPE = Variant[String, POSITION_DIRECTION]
