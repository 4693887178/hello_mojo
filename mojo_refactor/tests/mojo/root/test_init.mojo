
from testing import assert_equal, assert_true
from rqmojo import get_version, run, run_file, load_ipython_extension, run_ipython_cell

def test_version() raises:
    print("Testing version...")
    var v = get_version()
    print("Version: " + v)
    assert_true(len(v) > 0, "Version should not be empty")

def test_run_stubs() raises:
    print("Testing run stubs...")
    run("config")
    run_file("strategy.py")
    load_ipython_extension()
    run_ipython_cell("line")

def main() raises:
    test_version()
    test_run_stubs()
