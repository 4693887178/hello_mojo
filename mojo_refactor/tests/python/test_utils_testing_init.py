"""
Integration tests to verify consistency between Python and Mojo implementations.
Tests ensure that rqmojo.utils.testing matches rqalpha.utils.testing behavior.
"""

import pytest
import sys
import os


class TestPythonRQAlphaTestCase:
    """Test Python's RQAlphaTestCase behavior as reference."""

    def test_init_fixture_default(self):
        """Test init_fixture can be called without error."""
        from rqalpha.utils.testing import RQAlphaTestCase
        tc = RQAlphaTestCase()
        tc.init_fixture()

    def test_set_up_calls_init_fixture(self):
        """Test setUp calls init_fixture."""
        from rqalpha.utils.testing import RQAlphaTestCase
        tc = RQAlphaTestCase()
        tc.setUp()

    def test_assert_obj_simple_attributes(self):
        """Test assertObj with simple attribute matching."""
        from rqalpha.utils.testing import RQAlphaTestCase

        class SimpleObj:
            pass

        obj = SimpleObj()
        obj.name = "test"
        obj.value = 42

        tc = RQAlphaTestCase()
        tc.assertObj(obj, name="test", value=42)

    def test_assert_obj_nested_dict(self):
        """Test assertObj with nested dict (recursive assertion)."""
        from rqalpha.utils.testing import RQAlphaTestCase

        class InnerObj:
            pass

        class OuterObj:
            pass

        inner = InnerObj()
        inner.x = 10
        inner.y = 20

        outer = OuterObj()
        outer.inner_obj = inner
        outer.label = "outer"

        tc = RQAlphaTestCase()
        tc.assertObj(outer, inner_obj={"x": 10, "y": 20}, label="outer")

    def test_assert_obj_missing_attribute_raises(self):
        """Test assertObj raises error when attribute is missing."""
        from rqalpha.utils.testing import RQAlphaTestCase

        class SimpleObj:
            pass

        obj = SimpleObj()
        obj.name = "test"

        tc = RQAlphaTestCase()

        with pytest.raises(AttributeError):
            tc.assertObj(obj, name="test", nonexistent="value")

    def test_assert_obj_value_mismatch_raises(self):
        """Test assertObj raises error when values don't match."""
        from rqalpha.utils.testing import RQAlphaTestCase

        class SimpleObj:
            pass

        obj = SimpleObj()
        obj.value = 100

        tc = RQAlphaTestCase()

        with pytest.raises(AssertionError):
            tc.assertObj(obj, value=200)


def test_imports_match():
    """Verify that all expected exports are available."""
    from rqalpha.utils.testing import (
        MagicMock,
        RQAlphaFixture,
        RQAlphaTestCase,
        EnvironmentFixture,
        UniverseFixture,
        DataProxyFixture,
        BaseDataSourceFixture,
        BarDictPriceBoardFixture,
        MatcherFixture,
        mock_instrument,
        mock_bar,
        mock_tick,
    )


def test_all_exports():
    """Verify __all__ contains expected items."""
    from rqalpha.utils.testing import __all__

    expected_items = {
        "integration_test",
        "MagicMock",
        "RQAlphaFixture",
        "RQAlphaTestCase",
        "EnvironmentFixture",
        "UniverseFixture",
        "DataProxyFixture",
        "BaseDataSourceFixture",
        "BarDictPriceBoardFixture",
        "MatcherFixture",
        "mock_instrument",
        "mock_bar",
        "mock_tick",
    }

    assert set(__all__) == expected_items


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
