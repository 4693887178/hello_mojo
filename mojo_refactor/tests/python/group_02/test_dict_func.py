"""
Test for rqalpha/utils/dict_func.py
"""

import pytest
from rqalpha.utils.dict_func import deep_update


class TestDeepUpdate:
    def test_simple_update(self):
        """Test simple key-value update"""
        from_dict = {"a": 1, "b": 2}
        to_dict = {"c": 3}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": 1, "b": 2, "c": 3}

    def test_overwrite_value(self):
        """Test overwriting existing values"""
        from_dict = {"a": 1, "b": 2}
        to_dict = {"a": 0, "c": 3}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": 1, "b": 2, "c": 3}

    def test_nested_dict_update(self):
        """Test nested dictionary update"""
        from_dict = {"a": {"b": 1, "c": 2}}
        to_dict = {"a": {"b": 0, "d": 3}}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": {"b": 1, "c": 2, "d": 3}}

    def test_deeply_nested_update(self):
        """Test deeply nested dictionary update"""
        from_dict = {"a": {"b": {"c": {"d": 1}}}}
        to_dict = {"a": {"b": {"c": {"e": 2}}}}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": {"b": {"c": {"d": 1, "e": 2}}}}

    def test_empty_from_dict(self):
        """Test with empty source dictionary"""
        from_dict = {}
        to_dict = {"a": 1}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": 1}

    def test_empty_to_dict(self):
        """Test with empty target dictionary"""
        from_dict = {"a": 1}
        to_dict = {}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": 1}

    def test_non_dict_value_overwrite(self):
        """Test that non-dict values are overwritten"""
        from_dict = {"a": {"b": 1}}
        to_dict = {"a": "string"}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": {"b": 1}}

    def test_dict_replaces_non_dict(self):
        """Test that dict replaces non-dict value"""
        from_dict = {"a": "string"}
        to_dict = {"a": {"b": 1}}
        deep_update(from_dict, to_dict)
        assert to_dict == {"a": "string"}


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
