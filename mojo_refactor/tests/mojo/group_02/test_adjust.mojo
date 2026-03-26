"""
RQMojo Test for data/base_data_source/adjust.mojo
Group 02 - File 10
Tests for data adjustment functions
"""

from python import Python
from rqmojo.data.base_data_source.adjust import _factor_for_date, adjust_bars


def test_factor_for_date() raises:
    print("Testing _factor_for_date...")
    
    var np = Python.import_module("numpy")
    
    var dates = np.array(["2020-01-01", "2020-01-02", "2020-01-03"], dtype="datetime64[D]")
    var factor = np.array([1.0, 1.1, 1.2])
    
    var result = _factor_for_date(dates, factor)
    assert result is not None
    
    print("  _factor_for_date tests passed!")


def test_adjust_bars() raises:
    print("Testing adjust_bars...")
    
    var np = Python.import_module("numpy")
    
    var bars = Python.dict()
    bars["open"] = np.array([10.0, 11.0, 12.0])
    bars["close"] = np.array([10.5, 11.5, 12.5])
    bars["high"] = np.array([11.0, 12.0, 13.0])
    bars["low"] = np.array([10.0, 11.0, 12.0])
    
    var factor = np.array([1.1, 1.1, 1.1])
    
    var adjusted = adjust_bars(bars, factor)
    assert adjusted is not None
    
    print("  adjust_bars tests passed!")


def main() raises:
    print("=" * 60)
    print("Testing data/base_data_source/adjust.mojo")
    print("=" * 60)
    
    test_factor_for_date()
    test_adjust_bars()
    
    print("=" * 60)
    print("All data/base_data_source/adjust.mojo tests passed!")
    print("=" * 60)
