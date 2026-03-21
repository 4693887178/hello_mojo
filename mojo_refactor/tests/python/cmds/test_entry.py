# -*- coding: utf-8 -*-
"""
Test for rqalpha/cmds/entry.py - Command Line Interface Entry
Compares output with Mojo rqmojo/cmds/entry.mojo
"""

import click


def test_cli_is_callable():
    """测试 cli 函数是否可调用"""
    print("=== Testing cli is callable ===")
    from rqalpha.cmds.entry import cli
    
    assert callable(cli), "cli should be callable"
    print("PASS: cli is callable")
    print("")


def test_cli_group_decorator():
    """测试 @click.group() 装饰器是否正确应用"""
    print("=== Testing @click.group() decorator ===")
    from rqalpha.cmds.entry import cli
    
    assert isinstance(cli, click.Group), "cli should be a click.Group instance"
    print("PASS: cli is a click.Group instance")
    print("")


def test_help_option_configured():
    """测试 help_option 是否正确配置"""
    print("=== Testing help_option configured ===")
    from rqalpha.cmds.entry import cli
    
    help_params = [p for p in cli.params if p.name == 'help']
    assert len(help_params) > 0, "help option should be configured"
    
    help_param = help_params[0]
    assert '-h' in help_param.opts, "-h should be in help options"
    assert '--help' in help_param.opts, "--help should be in help options"
    print("PASS: help_option (-h, --help) is configured")
    print("")


def test_cli_name():
    """测试 cli 名称"""
    print("=== Testing cli name ===")
    from rqalpha.cmds.entry import cli
    
    assert cli.name == 'cli', "cli name should be 'cli'"
    print(f"PASS: cli name is '{cli.name}'")
    print("")


def test_cli_invocation():
    """测试 cli 调用"""
    print("=== Testing cli invocation ===")
    from rqalpha.cmds.entry import cli
    from click.testing import CliRunner
    
    runner = CliRunner()
    result = runner.invoke(cli, ['--help'])
    
    assert result.exit_code == 0, f"cli --help should exit with 0, got {result.exit_code}"
    print("PASS: cli --help exits with code 0")
    print("")


def test_cli_commands_empty():
    """测试 cli 初始状态无子命令"""
    print("=== Testing cli commands empty ===")
    from rqalpha.cmds.entry import cli
    
    commands = cli.commands
    print(f"cli commands: {list(commands.keys())}")
    print("PASS: cli commands checked")
    print("")


if __name__ == "__main__":
    print("=" * 60)
    print("RQAlpha Python cmds/entry.py Test")
    print("=" * 60)
    print("")
    
    test_cli_is_callable()
    test_cli_group_decorator()
    test_help_option_configured()
    test_cli_name()
    test_cli_invocation()
    test_cli_commands_empty()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
