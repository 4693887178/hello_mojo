# test_L00_03_typing.py
# Module: rqalpha.utils.typing
# Mojo: rqmojo.utils.typing
# Level: L00 - Leaf module
# Dependencies: const

import pytest
from rqalpha.utils import typing
from rqalpha.const import POSITION_DIRECTION
from datetime import date, datetime
import pandas


class TestL00Typing:
    """L00 - typing module tests"""

    class TestDateLike:
        """DateLike type tests"""

        def test_date_is_valid(self):
            """Test date is valid DateLike"""
            d = date(2023, 1, 1)
            assert isinstance(d, date)

        def test_datetime_is_valid(self):
            """Test datetime is valid DateLike"""
            dt = datetime(2023, 1, 1, 12, 0, 0)
            assert isinstance(dt, datetime)

        def test_pandas_timestamp_is_valid(self):
            """Test pandas.Timestamp is valid DateLike"""
            ts = pandas.Timestamp("2023-01-01")
            assert isinstance(ts, pandas.Timestamp)

        def test_date_like_type_alias_exists(self):
            """Test DateLike type alias exists"""
            assert hasattr(typing, 'DateLike')

        def test_date_like_is_union(self):
            """Test DateLike is Union type"""
            from typing import Union
            assert typing.DateLike == Union[date, datetime, pandas.Timestamp]

    class TestStrOrIter:
        """StrOrIter type tests"""

        def test_str_is_valid(self):
            """Test str is valid StrOrIter"""
            s = "test"
            assert isinstance(s, str)

        def test_list_is_valid(self):
            """Test list of str is valid StrOrIter"""
            lst = ["a", "b", "c"]
            assert isinstance(lst, list)
            assert all(isinstance(x, str) for x in lst)

        def test_tuple_is_valid(self):
            """Test tuple of str is valid StrOrIter"""
            tpl = ("a", "b", "c")
            assert isinstance(tpl, tuple)

        def test_stroriter_type_alias_exists(self):
            """Test StrOrIter type alias exists"""
            assert hasattr(typing, 'StrOrIter')

    class TestPositionDirectionType:
        """POSITION_DIRECTION_TYPE tests"""

        def test_str_is_valid(self):
            """Test str is valid POSITION_DIRECTION_TYPE"""
            s = "LONG"
            assert isinstance(s, str)

        def test_enum_is_valid(self):
            """Test POSITION_DIRECTION enum is valid"""
            pd = POSITION_DIRECTION.LONG
            assert isinstance(pd, POSITION_DIRECTION)
            assert pd.value == "LONG"

        def test_position_direction_type_exists(self):
            """Test POSITION_DIRECTION_TYPE exists"""
            assert hasattr(typing, 'POSITION_DIRECTION_TYPE')

        def test_long_enum_value(self):
            """Test POSITION_DIRECTION.LONG value"""
            pd = POSITION_DIRECTION.LONG
            assert pd.value == "LONG"

        def test_short_enum_value(self):
            """Test POSITION_DIRECTION.SHORT value"""
            pd = POSITION_DIRECTION.SHORT
            assert pd.value == "SHORT"

    class TestTypeAliases:
        """Type alias existence tests"""

        def test_datelike_exists(self):
            """Test DateLike type alias exists"""
            assert hasattr(typing, 'DateLike')

        def test_stroriter_exists(self):
            """Test StrOrIter type alias exists"""
            assert hasattr(typing, 'StrOrIter')

        def test_position_direction_type_exists(self):
            """Test POSITION_DIRECTION_TYPE exists"""
            assert hasattr(typing, 'POSITION_DIRECTION_TYPE')

    class TestMojoCompatibility:
        """Tests for Mojo compatibility"""

        def test_datelike_supports_int(self):
            """Test that DateLike concept supports integer representation"""
            date_int = 20230115
            assert isinstance(date_int, int)
            year = date_int // 10000
            month = (date_int % 10000) // 100
            day = date_int % 100
            assert year == 2023
            assert month == 1
            assert day == 15

        def test_stroriter_supports_list(self):
            """Test that StrOrIter supports list of strings"""
            lst = ["a", "b", "c"]
            assert isinstance(lst, list)
            assert len(lst) == 3
