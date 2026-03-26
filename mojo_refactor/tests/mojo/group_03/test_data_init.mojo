"""
RQAlpha Mojo - Data Package Init Test
Tests for data/__init__.mojo
"""

from rqmojo.data import DataProxy


def test_data_module_imports() raises:
    """Test that data module can be imported."""
    print("  data module imports test passed!")


def test_data_proxy_import() raises:
    """Test that DataProxy can be imported."""
    print("  DataProxy import test passed!")


def main() raises:
    print("============================================================")
    print("Testing data/__init__.mojo")
    print("============================================================")
    
    test_data_module_imports()
    test_data_proxy_import()
    
    print("============================================================")
    print("All data/__init__.mojo tests passed!")
    print("============================================================")
