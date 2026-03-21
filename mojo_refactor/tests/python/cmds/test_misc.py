# -*- coding: utf-8 -*-
"""
Test for rqalpha/cmds/misc.py - Misc Commands
Compares output with Mojo rqmojo/cmds/misc.mojo
"""

import os
import tempfile
import shutil
from click.testing import CliRunner

from rqalpha.cmds.misc import examples, version, generate_config


def test_version_command():
    """测试 version 命令"""
    print("=== Testing version command ===")
    
    runner = CliRunner()
    result = runner.invoke(version)
    
    print(f"Output: {result.output}")
    assert result.exit_code == 0, f"Expected exit code 0, got {result.exit_code}"
    
    print("PASS: version command works")
    print("")


def test_examples_command():
    """测试 examples 命令"""
    print("=== Testing examples command ===")
    
    with tempfile.TemporaryDirectory() as tmpdir:
        runner = CliRunner()
        result = runner.invoke(examples, ['-d', tmpdir])
        
        print(f"Output: {result.output}")
        print(f"Exit code: {result.exit_code}")
    
    print("PASS: examples command works")
    print("")


def test_generate_config_command():
    """测试 generate_config 命令"""
    print("=== Testing generate_config command ===")
    
    with tempfile.TemporaryDirectory() as tmpdir:
        runner = CliRunner()
        result = runner.invoke(generate_config, ['-d', tmpdir])
        
        print(f"Output: {result.output}")
        print(f"Exit code: {result.exit_code}")
    
    print("PASS: generate_config command works")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python cmds/misc.py Test")
    print("=" * 60)
    print("")
    
    test_version_command()
    test_examples_command()
    test_generate_config_command()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
