"""
RQAlpha Mojo - Model Package Init Test
Tests for model/__init__.mojo
"""

from rqmojo.model import Order, Trade, Instrument, BarObject, TickObject



from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite

def test_model_module_imports() raises:
    """Test that model module can be imported."""
    print("  model module imports test passed!")


def test_order_import() raises:
    """Test that Order can be imported."""
    print("  Order import test passed!")


def test_trade_import() raises:
    """Test that Trade can be imported."""
    print("  Trade import test passed!")


def test_instrument_import() raises:
    """Test that Instrument can be imported."""
    print("  Instrument import test passed!")


def test_bar_import() raises:
    """Test that BarObject can be imported."""
    print("  BarObject import test passed!")


def test_tick_import() raises:
    """Test that TickObject can be imported."""
    print("  TickObject import test passed!")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()