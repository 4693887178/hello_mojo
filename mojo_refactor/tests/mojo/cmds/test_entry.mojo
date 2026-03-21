"""
Test for entry.mojo - Command Line Interface Entry
Compares output with Python rqalpha/cmds/entry.py
"""

from std.collections import List
from rqmojo.cmds.entry import CliParser, CliRunner, create_cli_parser, create_cli_runner, run_cli


def test_create_cli_parser():
    """Test CliParser creation and defaults."""
    print("=== Testing create_cli_parser ===")
    
    var parser = create_cli_parser()
    
    if parser.get_command() == "":
        print("PASS: default command is empty string")
    else:
        print("FAIL: expected '', got '" + parser.get_command() + "'")
    
    if parser.get_frequency() == "1d":
        print("PASS: default frequency is '1d'")
    else:
        print("FAIL: expected '1d', got '" + parser.get_frequency() + "'")
    
    if parser.get_init_cash() == 100000.0:
        print("PASS: default init_cash is 100000.0")
    else:
        print("FAIL: expected 100000.0, got " + String(parser.get_init_cash()))
    print("")


def test_cli_parser_parse_run_command():
    """Test parsing run command."""
    print("=== Testing parse run command ===")
    
    var parser = create_cli_parser()
    var args = List[String]()
    args.append("run")
    parser.parse(args)
    
    var command = parser.get_command()
    if command == "run":
        print("PASS: run command parsed correctly")
    else:
        print("FAIL: expected 'run', got '" + command + "'")
    print("")


def test_cli_parser_parse_bundle_command():
    """Test parsing bundle command."""
    print("=== Testing parse bundle command ===")
    
    var parser = create_cli_parser()
    var args = List[String]()
    args.append("bundle")
    parser.parse(args)
    
    var command = parser.get_command()
    if command == "bundle":
        print("PASS: bundle command parsed correctly")
    else:
        print("FAIL: expected 'bundle', got '" + command + "'")
    print("")


def test_cli_parser_parse_mod_command():
    """Test parsing mod command."""
    print("=== Testing parse mod command ===")
    
    var parser = create_cli_parser()
    var args = List[String]()
    args.append("mod")
    parser.parse(args)
    
    var command = parser.get_command()
    if command == "mod":
        print("PASS: mod command parsed correctly")
    else:
        print("FAIL: expected 'mod', got '" + command + "'")
    print("")


def test_cli_parser_parse_options():
    """Test parsing various options."""
    print("=== Testing parse options ===")
    
    var parser = create_cli_parser()
    var args = List[String]()
    args.append("run")
    args.append("-f")
    args.append("strategy.py")
    args.append("-s")
    args.append("2020-01-01")
    args.append("-e")
    args.append("2020-12-31")
    args.append("-fq")
    args.append("1d")
    args.append("-c")
    args.append("100000")
    parser.parse(args)
    
    var strategy_file = parser.get_strategy_file()
    var frequency = parser.get_frequency()
    var init_cash = parser.get_init_cash()
    
    if strategy_file == "strategy.py":
        print("PASS: strategy_file parsed correctly")
    else:
        print("FAIL: expected 'strategy.py', got '" + strategy_file + "'")
    
    if frequency == "1d":
        print("PASS: frequency parsed correctly")
    else:
        print("FAIL: expected '1d', got '" + frequency + "'")
    
    if init_cash == 100000.0:
        print("PASS: init_cash parsed correctly")
    else:
        print("FAIL: expected 100000.0, got " + String(init_cash))
    print("")


def test_cli_runner_run_bundle():
    """Test run bundle command."""
    print("=== Testing run bundle command ===")
    
    var runner = create_cli_runner()
    var args = List[String]()
    args.append("bundle")
    
    var result = runner.run(args)
    if result == 0:
        print("PASS: bundle command returned 0")
    else:
        print("FAIL: expected 0, got " + String(result))
    print("")


def test_cli_runner_run_mod():
    """Test run mod command."""
    print("=== Testing run mod command ===")
    
    var runner = create_cli_runner()
    var args = List[String]()
    args.append("mod")
    
    var result = runner.run(args)
    if result == 0:
        print("PASS: mod command returned 0")
    else:
        print("FAIL: expected 0, got " + String(result))
    print("")


def test_cli_runner_run_unknown_command():
    """Test unknown command returns error code."""
    print("=== Testing unknown command ===")
    
    var runner = create_cli_runner()
    var args = List[String]()
    args.append("unknown")
    
    var result = runner.run(args)
    if result == 1:
        print("PASS: unknown command returned 1")
    else:
        print("FAIL: expected 1, got " + String(result))
    print("")


def main():
    print("=" * 60)
    print("RQAlpha Mojo cmds/entry.mojo Test")
    print("=" * 60)
    print("")
    
    test_create_cli_parser()
    test_cli_parser_parse_run_command()
    test_cli_parser_parse_bundle_command()
    test_cli_parser_parse_mod_command()
    test_cli_parser_parse_options()
    test_cli_runner_run_bundle()
    test_cli_runner_run_mod()
    test_cli_runner_run_unknown_command()
    
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)
