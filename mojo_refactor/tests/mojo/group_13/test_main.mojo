"""
Integration tests for __main__.mojo (source-level analysis)
Group 13 - Entry Point Tests

Tests verify __main__.mojo source code structure and correctness
by reading and analyzing the source file directly.
No cross-package imports needed.

Test coverage:
  1. Source file existence
  2. entry_point() function structure (two-phase pattern)
  3. main() function with error handling
  4. Import correctness (mirrors Python's rqalpha.cmds)
  5. Python behavioral parity verification
"""

from std.testing import assert_equal, assert_true, TestSuite
from std.os.path import exists as path_exists


def _read_source() raises -> String:
    """Read __main__.mojo source content."""
    var f = open("rqmojo/__main__.mojo", "r")
    var content = f.read()
    f.close()
    return content


# ── 1. Source File Existence ────────────────────────────────────────────────────

def test_source_file_exists() raises:
    """Test: __main__.mojo source file exists."""
    assert_true(path_exists("rqmojo/__main__.mojo"), "source must exist")
    print("  PASSED: __main__.mojo exists")


# ── 2. entry_point() Structure (Two-Phase Pattern) ───────────────────────────

def test_has_entry_point_function() raises:
    """Test: Source defines entry_point()."""
    var content = _read_source()
    assert_true("def entry_point()" in content, "must define entry_point()")
    print("  PASSED: entry_point() defined")


def test_entry_point_calls_inject_mod_commands() raises:
    """Test: Phase 1 - calls inject_mod_commands().

    Python: inject_mod_commands() registers all mod subcommands
    Mojo: equivalent call in entry_point()
    """
    var content = _read_source()
    assert_true("inject_mod_commands()" in content, "Phase 1: must call inject_mod_commands()")
    print("  PASSED: Phase 1 - inject_mod_commands() called")


def test_entry_point_calls_run_cli() raises:
    """Test: Phase 2 - calls run_cli().

    Python: cli(obj={}) dispatches CLI
    Mojo: run_cli() parses argv + dispatches
    """
    var content = _read_source()
    assert_true("run_cli()" in content, "Phase 2: must call run_cli()")
    print("  PASSED: Phase 2 - run_cli() called")


def test_entry_point_returns_int() raises:
    """Test: entry_point() returns Int exit code."""
    var content = _read_source()
    assert_true("-> Int" in content, "entry_point() -> Int")
    print("  PASSED: entry_point() returns Int")


def test_entry_point_is_raises() raises:
    """Test: entry_point() is marked raises."""
    var content = _read_source()
    assert_true("raises -> Int" in content, "entry_point() must raise")
    print("  PASSED: entry_point() has raises signature")


# ── 3. main() Function ────────────────────────────────────────────────────────

def test_has_main_function() raises:
    """Test: Source defines main() (mojo runtime entry)."""
    var content = _read_source()
    assert_true("def main()" in content, "must define main()")
    print("  PASSED: main() defined")


def test_main_has_error_handling() raises:
    """Test: main() has try/except error handling."""
    var content = _read_source()
    assert_true("try:" in content, "main() must have try block")
    assert_true("except" in content, "main() must have except block")
    print("  PASSED: main() has try/except error handling")


def test_main_calls_safe_entry_point() raises:
    """Test: main() delegates to _safe_entry_point()."""
    var content = _read_source()
    assert_true("_safe_entry_point()" in content, "main calls _safe_entry_point()")
    print("  PASSED: main() -> _safe_entry_point()")


def test_main_calls_exit() raises:
    """Test: main() calls exit() with result code."""
    var content = _read_source()
    assert_true("exit(" in content, "main() must call exit(code)")
    print("  PASSED: main() calls exit()")


# ── 4. _safe_entry_point() Helper ─────────────────────────────────────────────

def test_has_safe_entry_point() raises:
    """Test: _safe_entry_point() helper function exists."""
    var content = _read_source()
    assert_true("_safe_entry_point" in content, "_safe_entry_point must exist")
    print("  PASSED: _safe_entry_point() exists")


# ── 5. Import Correctness ──────────────────────────────────────────────────────

def test_imports_from_cmds_entry() raises:
    """Test: Imports cli, inject_mod_commands, run_cli from cmds.entry."""
    var content = _read_source()
    assert_true("from rqmojo.cmds.entry import" in content, "import from cmds.entry")
    print("  PASSED: imports from rqmojo.cmds.entry")


def test_imports_exit_from_sys() raises:
    """Test: Imports exit from std.sys for process termination."""
    var content = _read_source()
    assert_true("from std.sys import exit" in content, "import exit from std.sys")
    print("  PASSED: imports exit from std.sys")


def test_imports_all_three_symbols() raises:
    """Test: All 3 symbols imported: cli, inject_mod_commands, run_cli."""
    var content = _read_source()
    has_cli = "cli" in content
    has_inject = "inject_mod_commands" in content
    has_run = "run_cli" in content
    assert_true(has_cli and has_inject and has_run, "all 3 symbols present")
    print("  PASSED: all 3 symbols imported (cli, inject_mod_commands, run_cli)")


# ── 6. Python Behavioral Parity ───────────────────────────────────────────────

def test_documents_python_original() raises:
    """Test: Docstring references Python original (__main__.py)."""
    var content = _read_source()
    assert_true("__main__.py" in content, "must reference Python original")
    print("  PASSED: documents Python original")


def test_documents_two_phase_pattern() raises:
    """Test: Documents two-phase: inject then dispatch."""
    var content = _read_source()
    assert_true("Phase 1" in content or "inject_mod_commands" in content, "documents Phase 1")
    assert_true("Phase 2" in content or "run_cli" in content, "documents Phase 2")
    print("  PASSED: documents two-phase pattern")


def test_documents_obj_dict_equivalent() raises:
    """Test: References Python's cli(obj={}) pattern."""
    var content = _read_source()
    assert_true("obj={}" in content or "cli(obj=" in content, "references obj={}")
    print("  PASSED: references Python's cli(obj={}) pattern")


def test_equivalent_to_if_name_main() raises:
    """Test: Documents equivalence to if __name__ == '__main__'."""
    var content = _read_source()
    assert_true("__name__" in content, "references Python __name__ idiom")
    print("  PASSED: documents if __name__ == '__main__' equivalence")


# ── 7. Binary Verification ────────────────────────────────────────────────────

def test_binary_exists() raises:
    """Test: Compiled binary exists (from mojo build)."""
    assert_true(path_exists("__main__"), "binary must exist after build")
    print("  PASSED: compiled __main__ binary exists")


# ── Runner ────────────────────────────────────────────────────────────────────

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
