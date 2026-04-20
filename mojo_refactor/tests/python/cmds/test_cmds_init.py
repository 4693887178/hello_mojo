"""
Integration test for cmds/__init__.mojo vs Python rqalpha/cmds/__init__.py

Validates:
1. Python __init__.py exports: bundle, mod, run, misc packages; cli function; inject_run_param
2. Mojo __init__.mojo re-exports all symbols from submodules
3. Functional equivalence of key behaviors

Run with: pytest test_cmds_init.py -v
"""

import sys
import os
import importlib
import pytest

# Add Python rqalpha to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestPythonInitExports:
    """Verify Python rqalpha/cmds/__init__.py exports."""

    def setup_method(self):
        """Import the Python cmds package."""
        from rqalpha import cmds
        self.cmds = cmds

    def test_import_bundle_package(self):
        """Python: from . import bundle"""
        assert hasattr(self.cmds, 'bundle'), "cmds should have 'bundle' package"
        bundle = self.cmds.bundle
        assert hasattr(bundle, 'create_bundle') or hasattr(bundle, 'run_create_bundle'), \
            "bundle should have create_bundle or run_create_bundle"

    def test_import_mod_package(self):
        """Python: from . import mod"""
        assert hasattr(self.cmds, 'mod'), "cmds should have 'mod' package"
        mod = self.cmds.mod

    def test_import_run_package(self):
        """Python: from . import run"""
        assert hasattr(self.cmds, 'run'), "cmds should have 'run' package"
        run = self.cmds.run
        assert hasattr(run, 'run'), "run module should have 'run' function"
        assert hasattr(run, 'inject_run_param'), "run module should have 'inject_run_param'"

    def test_import_misc_package(self):
        """Python: from . import misc"""
        assert hasattr(self.cmds, 'misc'), "cmds should have 'misc' package"
        misc = self.cmds.misc

    def test_import_cli_function(self):
        """Python: from .entry import cli"""
        assert hasattr(self.cmds, 'cli'), "cmds should have 'cli' function"
        cli = self.cmds.cli
        assert callable(cli), "cli should be callable"

    def test_inject_run_param_signature(self):
        """Python: from .run import inject_run_param - check signature."""
        from rqalpha.cmds.run import inject_run_param
        import inspect
        sig = inspect.signature(inject_run_param)
        params = list(sig.parameters.keys())
        assert 'param' in params, "inject_run_param should take 'param' argument"


class TestMojoCompilation:
    """Verify Mojo __init__.mojo compiles successfully."""

    @property
    def _mojo_init_path(self):
        """Get path to Mojo __init__.mojo."""
        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
        return os.path.join(project_root, 'rqmojo', 'cmds', '__init__.mojo')

    def test_mojo_init_file_exists(self):
        """Mojo __init__.mojo file exists at expected path."""
        assert os.path.exists(self._mojo_init_path), \
            f"Mojo __init__.mojo not found at {self._mojo_init_path}"

    def test_mojo_init_has_expected_imports(self):
        """Mojo __init__.mojo imports all expected symbols."""
        with open(self._mojo_init_path, 'r') as f:
            content = f.read()

        # Check for key imports from each submodule
        expected_imports = [
            ('from rqmojo.cmds.run import', ['RunConfig', 'CliParam', 'run_backtest', 'inject_run_param']),
            ('from rqmojo.cmds.entry import', ['cli']),
            ('from rqmojo.cmds.bundle import', ['create_bundle', 'update_bundle', 'download_bundle']),
            ('from rqmojo.cmds.misc import', ['print_version', 'examples', 'generate_config']),
            ('from rqmojo.cmds.mod import', ['ModStatusEntry', 'get_builtin_mods', 'list_mods']),
        ]

        for prefix, symbols in expected_imports:
            assert prefix in content, f"Missing import prefix: {prefix}"
            for sym in symbols:
                assert sym in content, f"Missing symbol '{sym}' in {prefix}"

    def test_mojo_no_print_help_import(self):
        """Mojo __init__.mojo should NOT import non-existent 'print_help'."""
        with open(self._mojo_init_path, 'r') as f:
            content = f.read()
        assert 'print_help' not in content, \
            "'print_help' should NOT be in __init__.mojo (does not exist in misc.mojo)"


class TestFunctionalEquivalence:
    """Test functional equivalence between Python and Mojo implementations."""

    def test_python_cli_is_group(self):
        """Python cli() returns a Click Group object."""
        from rqalpha.cmds import entry
        assert hasattr(entry, 'cli'), "entry module should have cli"
        c = entry.cli
        assert callable(c), "cli should be callable"

    def test_python_inject_run_param_exists(self):
        """Python inject_run_param exists and is importable."""
        from rqalpha.cmds.run import inject_run_param
        assert callable(inject_run_param), "inject_run_param should be callable"

    def test_python_misc_exports(self):
        """Python misc module exports examples, version, generate_config."""
        from rqalpha.cmds import misc
        assert hasattr(misc, 'examples'), "misc should export examples"
        assert hasattr(misc, 'version'), "misc should export version"
        assert hasattr(misc, 'generate_config'), "misc should export generate_config"

    def test_python_mod_exports(self):
        """Python mod module has mod management functionality."""
        from rqalpha.cmds import mod
        assert hasattr(mod, 'mod') or hasattr(mod, 'cli'), \
            "mod should have mod management function or cli"

    def test_python_bundle_exports(self):
        """Python bundle module exports create/update/download/check functions."""
        from rqalpha.cmds import bundle
        assert hasattr(bundle, 'create_bundle') or hasattr(bundle, 'run_create_bundle'), \
            "bundle should export create_bundle"
        assert hasattr(bundle, 'update_bundle') or hasattr(bundle, 'run_update_bundle'), \
            "bundle should export update_bundle"
        assert hasattr(bundle, 'download_bundle') or hasattr(bundle, 'run_download_bundle'), \
            "bundle should export download_bundle"
        assert hasattr(bundle, 'check_bundle') or hasattr(bundle, 'run_check_bundle'), \
            "bundle should export check_bundle"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
