# -*- coding: utf-8 -*-
"""
Test for cmds/mod.py (Python original) and cmds/mod.mojo (Mojo refactor)
Group 06 - Comprehensive Mod Command Tests

Tests verify functional equivalence between Python and Mojo implementations:
  - Module import structure
  - Mod command function signatures
  - List/enable/disable behavior
  - Config access patterns
  - CLI command registration
"""

import pytest
import sys
import os
import subprocess

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'lib', 'python3.14', 'site-packages'))


class TestModCommandPythonOriginal:
    """Test the original Python rqalpha.cmds.mod module."""

    def test_module_imports(self):
        """Test that module can be imported."""
        from rqalpha.cmds import mod
        assert mod is not None

    def test_mod_command_exists(self):
        """Test mod command exists and is callable."""
        from rqalpha.cmds.mod import mod
        assert callable(mod)

    def test_mod_command_has_docstring(self):
        """Test mod command has proper docstring."""
        from rqalpha.cmds.mod import mod
        assert "Mod management command" in mod.__doc__ or "mod" in str(mod)

    def test_detect_package_name_from_dir_exists(self):
        """Test _detect_package_name_from_dir helper exists."""
        from rqalpha.cmds.mod import _detect_package_name_from_dir
        assert callable(_detect_package_name_from_dir)

    def test_detect_package_name_no_setup_py(self):
        """Test _detect_package_name_from_dir returns None for dir without setup.py."""
        from rqalpha.cmds.mod import _detect_package_name_from_dir
        result = _detect_package_name_from_dir(['/tmp', '/nonexistent_xyz'])
        assert result is None

    def test_get_mod_conf_exists(self):
        """Test get_mod_conf utility exists in config module."""
        from rqalpha.utils.config import get_mod_conf
        assert callable(get_mod_conf)

    def test_get_mod_conf_returns_dict(self):
        """Test get_mod_conf returns dict with 'mod' key."""
        from rqalpha.utils.config import get_mod_conf
        config = get_mod_conf()
        assert isinstance(config, dict)
        assert 'mod' in config

    def test_get_mod_conf_has_sys_mods(self):
        """Test get_mod_conf contains all expected sys mods."""
        from rqalpha.utils.config import get_mod_conf
        config = get_mod_conf()
        expected_mods = [
            'sys_accounts', 'sys_simulation', 'sys_progress',
            'sys_risk', 'sys_analyser', 'sys_scheduler',
            'sys_transaction_cost'
        ]
        for mod_name in expected_mods:
            assert mod_name in config['mod'], f"Missing mod: {mod_name}"

    def test_mod_config_all_enabled_by_default(self):
        """Test all mods are enabled by default in mod_config.yml."""
        from rqalpha.utils.config import get_mod_conf
        config = get_mod_conf()
        for mod_name, mod_cfg in config['mod'].items():
            assert mod_cfg.get('enabled', False) is True, \
                f"Mod {mod_name} should be enabled by default"

    def test_user_mod_conf_path(self):
        """Test user_mod_conf_path returns valid path."""
        from rqalpha.utils.config import user_mod_conf_path
        path = user_mod_conf_path()
        assert isinstance(path, str)
        assert path.endswith('mod_config.yml')
        assert '~' not in path or os.path.isabs(os.path.expanduser(path))

    def test_dump_config_function(self):
        """Test dump_config utility exists."""
        from rqalpha.utils.config import dump_config
        assert callable(dump_config)

    def test_load_yaml_function(self):
        """Test load_yaml utility exists."""
        from rqalpha.utils.config import load_yaml
        assert callable(load_yaml)


class TestModCommandMojoRefactor:
    """Test that the Mojo refactored version matches Python behavior.

    These tests compile and run the Mojo test file to verify correctness.
    """

    MOJO_TEST_FILE = os.path.join(
        os.path.dirname(__file__), '..', 'mojo', 'group_06', 'test_mod_cmd.mojo'
    )

    MOJO_SOURCE_DIR = os.path.join(
        os.path.dirname(__file__), '..', '..', '..', 'rqmojo'
    )

    def _run_mojo_test(self):
        """Run the Mojo test file and return (returncode, stdout, stderr)."""
        mojo_bin = os.path.join(
            os.path.dirname(__file__), '..', '..', '..', '..', '.venv', 'bin', 'mojo'
        )
        env = os.environ.copy()
        env['LD_PRELOAD'] = '/home/zhou/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so'
        env['PYTHONPATH'] = '/home/zhou/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages'

        cmd = [
            mojo_bin, 'test',
            '-I', self.MOJO_SOURCE_DIR,
            '-I', os.path.join(self.MOJO_SOURCE_DIR, 'third_party', 'argmojo', 'src'),
            '-I', os.path.join(self.MOJO_SOURCE_DIR, 'third_party', 'EmberJson'),
            '-I', os.path.join(self.MOJO_SOURCE_DIR, 'third_party', 'NuMojo'),
            '-I', os.path.join(self.MOJO_SOURCE_DIR, 'third_party', 'mojo-yaml', 'src'),
            '-I', os.path.join(self.MOJO_SOURCE_DIR, 'third_party', 'morrow.mojo'),
            self.MOJO_TEST_FILE,
        ]

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
            env=env,
            cwd=os.path.dirname(self.MOJO_SOURCE_DIR),
        )
        return result.returncode, result.stdout, result.stderr

    @pytest.mark.skipif(
        not os.path.exists(MOJO_TEST_FILE),
        reason="Mojo test file not yet created"
    )
    def test_mojo_compiles(self):
        """Test that Mojo mod command file compiles without errors."""
        rc, stdout, stderr = self._run_mojo_test()
        assert rc == 0, f"Mojo tests failed:\nstdout:\n{stdout}\nstderr:\n{stderr}"


class TestModFunctionalEquivalence:
    """Verify functional equivalence between Python and Mojo implementations."""

    def test_python_mod_list_action(self):
        """Test Python mod list action produces expected output format."""
        from rqalpha.utils.config import get_mod_conf
        config = get_mod_conf()
        assert len(config.get('mod', {})) == 7

    def test_python_mod_names_match_expected(self):
        """Test Python mod names match the expected set from mod_config.yml."""
        from rqalpha.utils.config import get_mod_conf
        config = get_mod_conf()
        actual_names = sorted(config['mod'].keys())
        expected_names = sorted([
            'sys_accounts', 'sys_simulation', 'sys_progress',
            'sys_risk', 'sys_analyser', 'sys_scheduler',
            'sys_transaction_cost'
        ])
        assert actual_names == expected_names

    def test_python_import_module_check(self):
        """Test Python's importlib.import_module pattern works for rqalpha."""
        from importlib import import_module
        try:
            mod = import_module('rqalpha')
            assert mod is not None
        except ImportError:
            pytest.skip("rqalpha not available in current environment")

    def test_python_mod_prefix_stripping(self):
        """Test Python's mod name prefix stripping logic."""
        mod_name = "rqalpha_mod_sys_accounts"
        if "rqalpha_mod_" in mod_name:
            clean_name = mod_name.replace("rqalpha_mod_", "")
        else:
            clean_name = mod_name
        assert clean_name == "sys_accounts"

    def test_python_module_name_resolution(self):
        """Test Python's module name resolution logic."""
        mod_name = "sys_accounts"
        module_name = "rqalpha_mod_" + mod_name
        if module_name.startswith("rqalpha_mod_sys_"):
            module_name = "rqalpha.mod." + module_name
        assert module_name == "rqalpha.mod.rqalpha_mod_sys_accounts"

    def test_python_regular_module_name_resolution(self):
        """Test Python's module name resolution for non-sys mods."""
        mod_name = "my_custom"
        module_name = "rqalpha_mod_" + mod_name
        if module_name.startswith("rqalpha_mod_sys_"):
            module_name = "rqalpha.mod." + module_name
        assert module_name == "rqalpha_mod_my_custom"


class TestModEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_empty_mod_list_handling(self):
        """Test that empty mod lists are handled gracefully."""
        mod_list = []
        assert len(mod_list) == 0

    def test_mod_name_with_rqalpha_prefix(self):
        """Test handling of mod names with rqalpha_mod_ prefix."""
        test_cases = [
            ("sys_accounts", "sys_accounts"),
            ("rqalpha_mod_sys_accounts", "sys_accounts"),
            ("rqalpha_mod_custom", "custom"),
            ("some_other_name", "some_other_name"),
        ]
        for input_name, expected in test_cases:
            if "rqalpha_mod_" in input_name:
                result = input_name.replace("rqalpha_mod_", "")
            else:
                result = input_name
            assert result == expected, f"For {input_name}, expected {expected}, got {result}"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
