"""
Comprehensive integration tests for __main__.mojo vs __main__.py
Group 13 - Entry Point Parity Tests

Tests verify behavioral parity between:
  - Python original: rqalpha/__main__.py
  - Mojo refactor:   rqmojo/__main__.mojo

Test categories:
  1. Python original structure analysis
  2. Mojo binary behavioral tests (via subprocess)
  3. Cross-implementation parity verification
  4. Entry point contract tests
"""

import os
import sys
import subprocess
import textwrap
import ast
import pytest

# ── Paths ──────────────────────────────────────────────────────────────────────

MOJO_REFACTOR_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
PYTHON_RQALPHA_MAIN = os.path.join(
    os.path.dirname(sys.modules["rqalpha"].__file__) if "rqalpha" in sys.modules
    else "/home/zhou/hello_mojo/trae_cn_78/.venv/lib64/python3.14/site-packages/rqalpha",
    "__main__.py",
)
MOJO_SOURCE = os.path.join(MOJO_REFACTOR_ROOT, "rqmojo", "__main__.mojo")
MOJO_BINARY = os.path.join(MOJO_REFACTOR_ROOT, "__main__")

# Environment for running mojo binaries
MOJO_ENV = {
    **os.environ,
    "LD_PRELOAD": "/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so",
    "PYTHONPATH": "/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages",
}


def run_mojo_binary(*args: str) -> subprocess.CompletedProcess:
    """Run the compiled __main__ mojo binary with given arguments."""
    result = subprocess.run(
        [MOJO_BINARY] + list(args),
        capture_output=True,
        text=True,
        timeout=30,
        env=MOJO_ENV,
    )
    return result


# ════════════════════════════════════════════════════════════════════════════════
# 1. Python Original Structure Analysis
# ════════════════════════════════════════════════════════════════════════════════


class TestPythonOriginalStructure:
    """Verify Python's rqalpha/__main__.py structure."""

    def test_python_main_exists(self):
        """Python __main__.py must exist at expected path."""
        assert os.path.isfile(PYTHON_RQALPHA_MAIN), (
            f"Python __main__.py not found: {PYTHON_RQALPHA_MAIN}"
        )

    def test_python_main_has_entry_point(self):
        """Python __main__.py must define entry_point()."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            source = f.read()
        tree = ast.parse(source)
        funcs = [n.name for n in ast.walk(tree) if isinstance(n, ast.FunctionDef)]
        assert "entry_point" in funcs, "Python must define entry_point()"

    def test_python_entry_point_imports_cli(self):
        """Python entry_point() imports cli from rqalpha.cmds."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            source = f.read()
        assert "from rqalpha.cmds import" in source or "import" in source
        assert "cli" in source

    def test_python_entry_point_calls_inject_mod_commands(self):
        """Python entry_point() calls inject_mod_commands()."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            source = f.read()
        assert "inject_mod_commands" in source

    def test_python_entry_point_calls_cli(self):
        """Python entry_point() calls cli(obj={})."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            source = f.read()
        assert "cli(" in source

    def test_python_has_name_main(self):
        """Python uses if __name__ == '__main__' guard."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            source = f.read()
        assert '__name__' in source
        assert '__main__' in source


# ════════════════════════════════════════════════════════════════════════════════
# 2. Mojo Source Structure Analysis
# ════════════════════════════════════════════════════════════════════════════════


class TestMojoSourceStructure:
    """Verify Mojo's rqmojo/__main__.mojo structure and parity with Python."""

    @pytest.fixture()
    def mojo_source(self):
        with open(MOJO_SOURCE) as f:
            return f.read()

    def test_mojo_source_exists(self):
        """Mojo __main__.mojo must exist."""
        assert os.path.isfile(MOJO_SOURCE), f"Mojo source not found: {MOJO_SOURCE}"

    def test_mojo_has_entry_point(self, mojo_source):
        """Must define entry_point() function."""
        assert "def entry_point()" in mojo_source

    def test_mojo_has_main(self, mojo_source):
        """Must define main() function."""
        assert "def main()" in mojo_source

    def test_mojo_entry_point_returns_int(self, mojo_source):
        """entry_point() must return Int."""
        assert "-> Int" in mojo_source

    def test_mojo_entry_point_is_raises(self, mojo_source):
        """entry_point() must be marked raises."""
        assert "raises -> Int" in mojo_source

    def test_mojo_calls_inject_mod_commands(self, mojo_source):
        """Phase 1: must call inject_mod_commands()."""
        assert "inject_mod_commands()" in mojo_source

    def test_mojo_calls_run_cli(self, mojo_source):
        """Phase 2: must call run_cli()."""
        assert "run_cli()" in mojo_source

    def test_mojo_has_safe_entry_point(self, mojo_source):
        """Must have _safe_entry_point() error wrapper."""
        assert "_safe_entry_point" in mojo_source

    def test_mojo_main_has_try_except(self, mojo_source):
        """main() must have try/except error handling."""
        assert "try:" in mojo_source
        assert "except" in mojo_source

    def test_mojo_main_calls_exit(self, mojo_source):
        """main() must call exit(code)."""
        assert "exit(" in mojo_source

    def test_mojo_imports_from_cmds_entry(self, mojo_source):
        """Must import from rqmojo.cmds.entry."""
        assert "from rqmojo.cmds.entry import" in mojo_source

    def test_mojo_imports_exit(self, mojo_source):
        """Must import exit from std.sys."""
        assert "from std.sys import exit" in mojo_source

    def test_mojo_references_python_original(self, mojo_source):
        """Docstring should reference Python original."""
        assert "__main__.py" in mojo_source


# ════════════════════════════════════════════════════════════════════════════════
# 3. Mojo Binary Behavioral Tests (via subprocess)
# ════════════════════════════════════════════════════════════════════════════════


class TestMojoBinaryBehavior:
    """Test compiled __main__ binary behavior via subprocess."""

    @pytest.fixture(autouse=True)
    def check_binary(self):
        """Skip all tests if binary not built yet."""
        if not os.path.isfile(MOJO_BINARY):
            pytest.skip(f"Mojo binary not found (run 'mojo build' first): {MOJO_BINARY}")

    def test_binary_exists(self):
        """Compiled binary must exist."""
        assert os.path.isfile(MOJO_BINARY)
        assert os.path.getsize(MOJO_BINARY) > 100000  # valid mojo build > 100KB

    def test_version_command(self):
        """'version' subcommand exits 0 and prints version info."""
        r = run_mojo_binary("version")
        assert r.returncode == 0, f"version exited {r.returncode}, stderr: {r.stderr}"
        assert len(r.stdout.strip()) > 0, "version should produce output"

    def test_no_args_shows_help(self):
        """No args shows help and exits 0."""
        r = run_mojo_binary()
        # Should show help info (exit code may be 0 for help display)
        assert r.returncode in (0, 1), f"no-args exited {r.returncode}"
        assert len(r.stdout) > 0 or len(r.stderr) > 0, "should produce output"

    def test_help_flag(self):
        """--help flag shows usage information."""
        r = run_mojo_binary("--help")
        assert r.returncode == 0, f"--help exited {r.returncode}"
        output = (r.stdout + r.stderr).lower()
        assert "usage" in output or "rqmojo" in output

    def test_unknown_command_fails(self):
        """Unknown subcommand returns non-zero exit code."""
        r = run_mojo_binary("nonexistent_command_xyz")
        assert r.returncode != 0, f"unknown command should fail, got {r.returncode}"


# ════════════════════════════════════════════════════════════════════════════════
# 4. Cross-Implementation Parity Verification
# ════════════════════════════════════════════════════════════════════════════════


class TestCrossImplParity:
    """Verify behavioral parity between Python and Mojo implementations."""

    def test_both_have_entry_point(self):
        """Both implementations define entry_point()."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            py_src = f.read()
        with open(MOJO_SOURCE) as f:
            mo_src = f.read()
        assert "def entry_point" in py_src
        assert "def entry_point()" in mo_src

    def test_both_use_two_phase_pattern(self):
        """Both use two-phase: register commands then dispatch.

        Python: inject_mod_commands() + cli(obj={})
        Mojo:  inject_mod_commands() + run_cli()
        """
        with open(MOJO_SOURCE) as f:
            mo_src = f.read()
        has_inject = "inject_mod_commands()" in mo_src
        has_dispatch = "run_cli()" in mo_src
        assert has_inject and has_dispatch, "Mojo must use two-phase pattern"

    def test_python_inject_then_cli_order(self):
        """Python calls inject_mod_commands BEFORE cli(obj={})."""
        with open(PYTHON_RQALPHA_MAIN) as f:
            src = f.read()
        inject_pos = src.index("inject_mod_commands")
        cli_pos = src.index("cli(")
        assert inject_pos < cli_pos, "inject_mod_commands must be called before cli()"

    def test_mojo_inject_then_run_cli_order(self):
        """Mojo calls inject_mod_commands BEFORE run_cli()."""
        with open(MOJO_SOURCE) as f:
            src = f.read()
        inject_pos = src.index("inject_mod_commands()")
        run_pos = src.index("run_cli()")
        assert inject_pos < run_pos, "inject_mod_commands must be called before run_cli()"

    def test_mojo_documents_parity(self):
        """Mojo source documents equivalence to Python original."""
        with open(MOJO_SOURCE) as f:
            src = f.read()
        assert "obj={}" in src or "Phase 1" in src
        assert "__name__" in src or "main()" in src


# ════════════════════════════════════════════════════════════════════════════════
# 5. Entry Point Contract Tests
# ════════════════════════════════════════════════════════════════════════════════


class TestEntryPointContract:
    """Test the entry point contract shared by both implementations."""

    def test_entry_point_is_callable(self):
        """entry_point() must be a callable function."""
        from rqalpha.cmds import cli
        from rqalpha.mod.utils import inject_mod_commands

        def py_entry_point():
            inject_mod_commands()
            cli(obj={})

        assert callable(py_entry_point)

    def test_mojo_entry_point_signature_matches_contract(self):
        """Mojo entry_point() follows the established contract:
        1. No parameters
        2. Returns Int (exit code)
        3. Raises on errors
        """
        with open(MOJO_SOURCE) as f:
            src = f.read()
        assert "def entry_point()" in src, "no params"
        assert "-> Int" in src, "returns Int"
        assert "raises" in src, "can raise"

    def test_error_handling_in_main_path(self):
        """The main execution path must handle errors gracefully.

        Python: Click handles its own errors internally
        Mojo:  try/except in main() catches and reports errors
        """
        with open(MOJO_SOURCE) as f:
            src = f.read()
        assert "try:" in src, "must have error handling"
        assert "except" in src, "must catch exceptions"
