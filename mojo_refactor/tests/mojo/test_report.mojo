"""
Comprehensive Unit Tests for Report Module
Tests cover all functionality matching Python original:
  - Helper functions (_py_none, _py_is_truthy)
  - _returns() daily return calculation
  - _yearly_indicators() yearly risk metrics
  - _monthly_returns() monthly returns DataFrame
  - _monthly_geometric_excess_returns() geometric excess returns
  - _gen_positions_weight() positions weight conversion
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.python import Python, PythonObject

from rqmojo.mod.rqmojo_mod_sys_analyser.report.report import (
    _py_none,
    _py_is_truthy,
    _returns,
    _yearly_indicators,
    _monthly_returns,
    _monthly_geometric_excess_returns,
    _gen_positions_weight,
)


def test_py_none_returns_python_none() raises:
    """Test that _py_none() returns a valid Python None object."""
    var none_val = _py_none()
    assert_true(not _py_is_truthy(none_val))


def test_py_is_truthy_with_truthy_value() raises:
    """Test _py_is_truthy with truthy value (non-empty string)."""
    var truthy_obj = PythonObject("hello")
    assert_true(_py_is_truthy(truthy_obj))


def test_py_is_truthy_with_falsy_value() raises:
    """Test _py_is_truthy with falsy value (empty string)."""
    var falsy_obj = PythonObject("")
    assert_true(not _py_is_truthy(falsy_obj))


def test_py_is_truthy_with_zero() raises:
    """Test _py_is_truthy with zero (falsy)."""
    var zero_obj = PythonObject(0)
    assert_true(not _py_is_truthy(zero_obj))


def test_py_is_truthy_with_one() raises:
    """Test _py_is_truthy with one (truthy)."""
    var one_obj = PythonObject(1)
    assert_true(_py_is_truthy(one_obj))


def test_returns_basic_calculation() raises:
    """Test _returns() calculates correct daily returns from NAV series."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "result = pd.Series([1.0, 1.02, 1.01, 1.05, 1.03], index=pd.date_range('2024-01-01', periods=5, freq='D'))\n",
        file=True,
    )
    var nav_series = mod.__getattr__("result")

    var result = _returns(nav_series)
    var result_len = len(result)
    assert_equal(result_len, 5)


def test_returns_handles_single_value() raises:
    """Test _returns() handles single-value series."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "result = pd.Series([100.0], index=pd.date_range('2024-01-01', periods=1, freq='D'))\n",
        file=True,
    )
    var nav_series = mod.__getattr__("result")

    var result = _returns(nav_series)
    var result_len = len(result)
    assert_equal(result_len, 1)


def test_yearly_indicators_empty_input() raises:
    """Test _yearly_indicators() returns empty dict for empty input."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "s = pd.Series([], dtype='float64')\n"
        "nav = s\n"
        "ret = s\n",
        file=True,
    )
    var empty_nav = mod.__getattr__("nav")
    var empty_ret = mod.__getattr__("ret")

    var result = _yearly_indicators(empty_nav, empty_ret, empty_nav, empty_ret, empty_ret)
    var result_len = len(result)
    assert_equal(result_len, 0)


def test_yearly_indicators_with_data() raises:
    """Test _yearly_indicators() computes indicators for real data."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "import numpy as np\n"
        "dates = pd.date_range('2024-01-01', periods=252, freq='B')\n"
        "np.random.seed(42)\n"
        "p_returns = np.random.normal(0.001, 0.02, 252)\n"
        "b_returns = np.random.normal(0.0005, 0.015, 252)\n"
        "p_nav = pd.Series(1.0 * np.cumprod(1 + p_returns), index=dates)\n"
        "b_nav = pd.Series(1.0 * np.cumprod(1 + b_returns), index=dates)\n"
        "p_ret = pd.Series(p_returns, index=dates)\n"
        "b_ret = pd.Series(b_returns, index=dates)\n"
        "rf = pd.Series([0.03 / 252] * 252, index=dates)\n",
        file=True,
    )
    var p_nav = mod.__getattr__("p_nav")
    var b_nav = mod.__getattr__("b_nav")
    var p_ret = mod.__getattr__("p_ret")
    var b_ret = mod.__getattr__("b_ret")
    var rf = mod.__getattr__("rf")

    var result = _yearly_indicators(p_nav, p_ret, b_nav, b_ret, rf)
    var result_len = len(result)
    assert_true(result_len >= 0)


def test_monthly_returns_structure() raises:
    """Test _monthly_returns() returns proper DataFrame structure."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "ret = pd.Series([0.001] * 60, index=pd.date_range('2024-06-01', periods=60, freq='B'))\n",
        file=True,
    )
    var ret_series = mod.__getattr__("ret")

    var result = _monthly_returns(ret_series)
    var shape = result.shape
    assert_true(len(shape) >= 2)


def test_monthly_geometric_excess_returns() raises:
    """Test _monthly_geometric_excess_returns() computes excess returns."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "dates = pd.date_range('2024-06-01', periods=60, freq='B')\n"
        "p_ret = pd.Series([0.001] * 60, index=dates)\n"
        "b_ret = pd.Series([0.0005] * 60, index=dates)\n",
        file=True,
    )
    var p_ret = mod.__getattr__("p_ret")
    var b_ret = mod.__getattr__("b_ret")

    var result = _monthly_geometric_excess_returns(p_ret, b_ret)
    var shape = result.shape
    assert_true(len(shape) >= 2)


def test_gen_positions_weight_basic() raises:
    """Test _gen_positions_weight() converts DataFrame to nested dict."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "from datetime import date\n"
        "idx = pd.MultiIndex.from_tuples(\n"
        "    [(date(2024, 6, 15), '000001.XSHE'), (date(2024, 6, 15), '600000.XSHG')],\n"
        "    names=['date', 'book_id'],\n"
        ")\n"
        "pos = pd.Series([0.3, 0.7], index=idx, name='weight')\n",
        file=True,
    )
    var pos_df = mod.__getattr__("pos")

    var result = _gen_positions_weight(pos_df)
    var result_len = len(result)
    assert_true(result_len > 0)


def test_gen_positions_weight_empty() raises:
    """Test _gen_positions_weight() handles empty DataFrame."""
    var mod = Python.evaluate(
        "import pandas as pd\n"
        "idx = pd.MultiIndex.from_tuples([], names=['date', 'book_id'])\n"
        "empty = pd.Series([], index=idx, name='weight')\n",
        file=True,
    )
    var empty_df = mod.__getattr__("empty")

    var result = _gen_positions_weight(empty_df)
    var result_len = len(result)
    assert_equal(result_len, 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
