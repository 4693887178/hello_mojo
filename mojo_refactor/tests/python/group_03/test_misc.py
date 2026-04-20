# -*- coding: utf-8 -*-
"""
Test for rqalpha/cmds/misc.py
Tests for misc commands (examples, version, generate_config)
"""

import pytest


class TestExamplesCommand:
    """Tests for examples command"""

    def test_examples_function_exists(self):
        """Test that examples function exists"""
        from rqalpha.cmds.misc import examples
        assert callable(examples)

    def test_examples_is_click_command(self):
        """Test that examples is a click command"""
        from rqalpha.cmds.misc import examples
        assert hasattr(examples, 'params')


class TestVersionCommand:
    """Tests for version command"""

    def test_version_function_exists(self):
        """Test that version function exists"""
        from rqalpha.cmds.misc import version
        assert callable(version)

    def test_version_is_click_command(self):
        """Test that version is a click command"""
        from rqalpha.cmds.misc import version
        assert hasattr(version, 'params')


class TestGenerateConfigCommand:
    """Tests for generate_config command"""

    def test_generate_config_function_exists(self):
        """Test that generate_config function exists"""
        from rqalpha.cmds.misc import generate_config
        assert callable(generate_config)

    def test_generate_config_is_click_command(self):
        """Test that generate_config is a click command"""
        from rqalpha.cmds.misc import generate_config
        assert hasattr(generate_config, 'params')


class TestModuleImports:
    """Tests for module imports"""

    def test_import_i18n(self):
        """Test that i18n gettext is imported"""
        from rqalpha.cmds.misc import _
        assert callable(_)

    def test_import_cli(self):
        """Test that cli is imported from entry"""
        from rqalpha.cmds.entry import cli
        assert cli is not None
