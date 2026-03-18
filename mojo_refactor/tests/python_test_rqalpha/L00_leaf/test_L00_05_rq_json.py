# test_L00_05_rq_json.py
# Module: rqalpha.utils.rq_json
# Mojo: rqmojo.utils.rq_json
# Level: L00 - Leaf module
# Dependencies: simplejson, datetime

import pytest
from rqalpha.utils import rq_json
from rqalpha.const import POSITION_DIRECTION, SIDE, ORDER_TYPE
from datetime import datetime, date


class TestL00RqJson:
    """L00 - rq_json module tests"""

    class TestConvertDictToJson:
        """convert_dict_to_json function tests"""

        def test_simple_dict(self):
            """Test simple dict to JSON conversion"""
            test_dict = {"name": "test", "value": 123}
            result = rq_json.convert_dict_to_json(test_dict)
            assert isinstance(result, str)
            assert "name" in result
            assert "test" in result

        def test_datetime_encoding(self):
            """Test datetime encoding"""
            test_dict = {"dt": datetime(2024, 1, 15, 14, 30, 45, 123456)}
            result = rq_json.convert_dict_to_json(test_dict)
            assert "__datetime__" in result
            assert "20240115T14:30:45.123456" in result

        def test_date_encoding(self):
            """Test date encoding"""
            test_dict = {"date": date(2024, 1, 15)}
            result = rq_json.convert_dict_to_json(test_dict)
            assert "__date__" in result
            assert "20240115" in result

        def test_enum_encoding(self):
            """Test CustomEnum encoding - enums serialize to their value string"""
            test_dict = {"side": SIDE.BUY}
            result = rq_json.convert_dict_to_json(test_dict)
            assert "BUY" in result

        def test_position_direction_encoding(self):
            """Test POSITION_DIRECTION enum encoding"""
            test_dict = {"direction": POSITION_DIRECTION.LONG}
            result = rq_json.convert_dict_to_json(test_dict)
            assert "LONG" in result

        def test_order_type_encoding(self):
            """Test ORDER_TYPE enum encoding"""
            test_dict = {"order_type": ORDER_TYPE.MARKET}
            result = rq_json.convert_dict_to_json(test_dict)
            assert "MARKET" in result

        def test_nested_dict(self):
            """Test nested dict encoding"""
            test_dict = {
                "outer": {
                    "inner": "value",
                    "dt": datetime(2024, 1, 15, 14, 30, 45)
                }
            }
            result = rq_json.convert_dict_to_json(test_dict)
            assert "outer" in result
            assert "inner" in result

        def test_multiple_datetime_fields(self):
            """Test multiple datetime fields"""
            test_dict = {
                "start": datetime(2024, 1, 1, 9, 30, 0),
                "end": datetime(2024, 1, 1, 15, 0, 0)
            }
            result = rq_json.convert_dict_to_json(test_dict)
            assert result.count("__datetime__") == 2

    class TestConvertJsonToDict:
        """convert_json_to_dict function tests"""

        def test_simple_json(self):
            """Test simple JSON to dict conversion"""
            json_str = '{"name": "test", "value": 123}'
            result = rq_json.convert_json_to_dict(json_str)
            assert result["name"] == "test"
            assert result["value"] == 123

        def test_datetime_decoding(self):
            """Test datetime decoding"""
            json_str = '{"dt": {"__datetime__": true, "as_str": "20240115T14:30:45.123456"}}'
            result = rq_json.convert_json_to_dict(json_str)
            assert isinstance(result["dt"], datetime)
            assert result["dt"].year == 2024
            assert result["dt"].month == 1
            assert result["dt"].day == 15

        def test_date_decoding(self):
            """Test date decoding"""
            json_str = '{"date": {"__date__": true, "as_str": "20240115"}}'
            result = rq_json.convert_json_to_dict(json_str)
            assert isinstance(result["date"], date)
            assert result["date"].year == 2024
            assert result["date"].month == 1
            assert result["date"].day == 15

        def test_enum_decoding(self):
            """Test CustomEnum decoding"""
            json_str = '{"side": {"__enum__": true, "as_str": "SIDE.BUY"}}'
            result = rq_json.convert_json_to_dict(json_str)
            assert result["side"] == SIDE.BUY

        def test_position_direction_decoding(self):
            """Test POSITION_DIRECTION enum decoding"""
            json_str = '{"direction": {"__enum__": true, "as_str": "POSITION_DIRECTION.LONG"}}'
            result = rq_json.convert_json_to_dict(json_str)
            assert result["direction"] == POSITION_DIRECTION.LONG

        def test_nested_json(self):
            """Test nested JSON decoding"""
            json_str = '{"outer": {"inner": "value", "count": 42}}'
            result = rq_json.convert_json_to_dict(json_str)
            assert result["outer"]["inner"] == "value"
            assert result["outer"]["count"] == 42

    class TestRoundtrip:
        """Roundtrip conversion tests"""

        def test_simple_roundtrip(self):
            """Test simple dict roundtrip"""
            original = {"name": "test", "value": 123}
            json_str = rq_json.convert_dict_to_json(original)
            result = rq_json.convert_json_to_dict(json_str)
            assert result["name"] == original["name"]
            assert result["value"] == original["value"]

        def test_datetime_roundtrip(self):
            """Test datetime roundtrip"""
            original = {"dt": datetime(2024, 1, 15, 14, 30, 45, 123456)}
            json_str = rq_json.convert_dict_to_json(original)
            result = rq_json.convert_json_to_dict(json_str)
            assert result["dt"] == original["dt"]

        def test_date_roundtrip(self):
            """Test date roundtrip"""
            original = {"date": date(2024, 1, 15)}
            json_str = rq_json.convert_dict_to_json(original)
            result = rq_json.convert_json_to_dict(json_str)
            assert result["date"] == original["date"]

        def test_enum_roundtrip(self):
            """Test enum roundtrip"""
            original = {"side": SIDE.BUY}
            json_str = rq_json.convert_dict_to_json(original)
            result = rq_json.convert_json_to_dict(json_str)
            assert result["side"] == original["side"]

        def test_complex_roundtrip(self):
            """Test complex dict roundtrip"""
            original = {
                "name": "complex_test",
                "dt": datetime(2024, 1, 15, 14, 30, 45),
                "date": date(2024, 1, 15),
                "side": SIDE.BUY,
                "direction": POSITION_DIRECTION.LONG,
                "count": 42,
                "nested": {
                    "inner_dt": datetime(2024, 2, 1, 10, 0, 0)
                }
            }
            json_str = rq_json.convert_dict_to_json(original)
            result = rq_json.convert_json_to_dict(json_str)
            assert result["name"] == original["name"]
            assert result["dt"] == original["dt"]
            assert result["date"] == original["date"]
            assert result["side"] == original["side"]
            assert result["direction"] == original["direction"]
            assert result["count"] == original["count"]

    class TestCustomEncode:
        """custom_encode function tests"""

        def test_encode_datetime(self):
            """Test custom_encode with datetime"""
            dt = datetime(2024, 1, 15, 14, 30, 45, 123456)
            result = rq_json.custom_encode(dt)
            assert result["__datetime__"] == True
            assert result["as_str"] == "20240115T14:30:45.123456"

        def test_encode_date(self):
            """Test custom_encode with date"""
            d = date(2024, 1, 15)
            result = rq_json.custom_encode(d)
            assert result["__date__"] == True
            assert result["as_str"] == "20240115"

        def test_encode_enum(self):
            """Test custom_encode with enum"""
            result = rq_json.custom_encode(SIDE.BUY)
            assert result["__enum__"] == True
            assert result["as_str"] == "SIDE.BUY"

        def test_encode_unserializable_raises(self):
            """Test custom_encode raises for unserializable object"""
            class Unserializable:
                pass
            with pytest.raises(TypeError):
                rq_json.custom_encode(Unserializable())

    class TestCustomDecode:
        """custom_decode function tests"""

        def test_decode_datetime(self):
            """Test custom_decode with datetime"""
            obj = {"__datetime__": True, "as_str": "20240115T14:30:45.123456"}
            result = rq_json.custom_decode(obj)
            assert isinstance(result, datetime)
            assert result.year == 2024

        def test_decode_date(self):
            """Test custom_decode with date"""
            obj = {"__date__": True, "as_str": "20240115"}
            result = rq_json.custom_decode(obj)
            assert isinstance(result, date)
            assert result.year == 2024

        def test_decode_enum(self):
            """Test custom_decode with enum"""
            obj = {"__enum__": True, "as_str": "SIDE.BUY"}
            result = rq_json.custom_decode(obj)
            assert result == SIDE.BUY

        def test_decode_regular_dict(self):
            """Test custom_decode with regular dict"""
            obj = {"name": "test", "value": 123}
            result = rq_json.custom_decode(obj)
            assert result == obj

    class TestMojoCompatibility:
        """Tests for Mojo compatibility"""

        def test_datetime_format_compatibility(self):
            """Test datetime format is compatible with Mojo"""
            dt = datetime(2024, 1, 15, 14, 30, 45, 123456)
            formatted = dt.strftime("%Y%m%dT%H:%M:%S.%f")
            assert formatted == "20240115T14:30:45.123456"
            
            parsed = datetime.strptime(formatted, "%Y%m%dT%H:%M:%S.%f")
            assert parsed == dt

        def test_date_format_compatibility(self):
            """Test date format is compatible with Mojo"""
            d = date(2024, 1, 15)
            formatted = d.strftime("%Y%m%d")
            assert formatted == "20240115"
            
            parsed = datetime.strptime(formatted, "%Y%m%d").date()
            assert parsed == d
