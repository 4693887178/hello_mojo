# -*- coding: utf-8 -*-
"""
Test for utils/testing/integration.py
Group 13 - File 3
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestStructuredTextFormat:
    def test_structured_text_format_class_exists(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        assert StructuredTextFormat is not None

    def test_structured_text_format_has_dumps(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        assert hasattr(StructuredTextFormat, 'dumps')

    def test_structured_text_format_has_loads(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        assert hasattr(StructuredTextFormat, 'loads')

    def test_structured_text_format_has_dump(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        assert hasattr(StructuredTextFormat, 'dump')

    def test_structured_text_format_has_load(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        assert hasattr(StructuredTextFormat, 'load')


class TestStructuredTextFormatMethods:
    def test_dumps_returns_string(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        import pandas as pd
        
        data = {
            "summary": {"total_returns": 0.15}
        }
        result = StructuredTextFormat.dumps(data)
        assert isinstance(result, str)

    def test_loads_returns_dict(self):
        from rqalpha.utils.testing.integration import StructuredTextFormat
        
        stf_string = """[summary]
dict
{}
{"total_returns": 0.15}"""
        
        result = StructuredTextFormat.loads(stf_string)
        assert isinstance(result, dict)
        assert "summary" in result


class TestAssertResult:
    def test_assert_result_function_exists(self):
        from rqalpha.utils.testing.integration import assert_result
        assert callable(assert_result)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
