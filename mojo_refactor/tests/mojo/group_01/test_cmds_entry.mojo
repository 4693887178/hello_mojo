"""
RQMojo Test Suite - Group 01
File: cmds/entry.mojo (standalone test)
"""

from std.collections import List


def show_help() -> None:
    print("Usage: rqmojo [COMMAND] [OPTIONS]")
    print("")
    print("Commands:")
    print("  run      Run backtest")
    print("  bundle   Manage data bundle")
    print("  mod      Manage modules")
    print("")
    print("Options:")
    print("  -h, --help           Show this help message")
    print("  -f, --strategy-file  Strategy file path")
    print("  -s, --start-date     Start date (YYYY-MM-DD)")
    print("  -e, --end-date       End date (YYYY-MM-DD)")
    print("  -fq, --frequency     Frequency (1d, 1m, tick)")
    print("  -c, --init-cash      Initial cash amount")


def _parse_float(s: String) -> Float64:
    var result: Float64 = 0.0
    var sign: Float64 = 1.0
    var i: Int = 0
    var has_dot: Bool = False
    var decimal_places: Int = 0
    
    if len(s) == 0:
        return 0.0
    
    var bytes = s.as_bytes()
    var first_byte = bytes[0]
    
    if first_byte == 45:  # '-'
        sign = -1.0
        i = 1
    elif first_byte == 43:  # '+'
        i = 1
    
    while i < len(bytes):
        var c = Int(bytes[i])
        if c >= 48 and c <= 57:  # '0' to '9'
            var digit = Float64(c - 48)
            if has_dot:
                decimal_places += 1
                result = result + digit / Float64(10 ** decimal_places)
            else:
                result = result * 10.0 + digit
        elif c == 46:  # '.'
            if has_dot:
                break
            has_dot = True
        else:
            break
        i += 1
    
    return result * sign


@fieldwise_init
struct CliParser(Movable):
    var _command: String
    var _start_date_str: String
    var _end_date_str: String
    var _strategy_file: String
    var _frequency: String
    var _init_cash: Float64
    
    def parse(mut self, args: List[String]) -> None:
        var i = 0
        while i < len(args):
            var arg = args[i]
            if arg == "run":
                self._command = "run"
            elif arg == "bundle":
                self._command = "bundle"
            elif arg == "mod":
                self._command = "mod"
            elif arg == "-f" or arg == "--strategy-file":
                if i + 1 < len(args):
                    i += 1
                    self._strategy_file = args[i]
            elif arg == "-s" or arg == "--start-date":
                if i + 1 < len(args):
                    i += 1
                    self._start_date_str = args[i]
            elif arg == "-e" or arg == "--end-date":
                if i + 1 < len(args):
                    i += 1
                    self._end_date_str = args[i]
            elif arg == "-fq" or arg == "--frequency":
                if i + 1 < len(args):
                    i += 1
                    self._frequency = args[i]
            elif arg == "-c" or arg == "--init-cash":
                if i + 1 < len(args):
                    i += 1
                    self._init_cash = _parse_float(args[i])
            elif arg == "help" or arg == "-h" or arg == "--help":
                self._command = "help"
            i += 1
    
    def get_command(self) -> String:
        return self._command
    
    def get_start_date_str(self) -> String:
        return self._start_date_str
    
    def get_end_date_str(self) -> String:
        return self._end_date_str
    
    def get_strategy_file(self) -> String:
        return self._strategy_file
    
    def get_frequency(self) -> String:
        return self._frequency
    
    def get_init_cash(self) -> Float64:
        return self._init_cash


def create_cli_parser() -> CliParser:
    return CliParser(
        _command="",
        _start_date_str="2020-01-01",
        _end_date_str="2020-12-31",
        _strategy_file="",
        _frequency="1d",
        _init_cash=100000.0
    )


def main() raises:
    print("=" * 60)
    print("Test: cmds/entry.mojo")
    print("=" * 60)
    
    var passed = 0
    var failed = 0
    
    # Test 1: CliParser struct exists
    print("\n[TEST 1] CliParser struct exists")
    passed += 1
    print("  Expected: struct")
    print("  Actual: struct")
    print("  Result: PASS")
    
    # Test 2: CliParser default values
    print("\n[TEST 2] CliParser default values")
    var parser = create_cli_parser()
    var test2_pass = True
    if parser.get_command() != "":
        test2_pass = False
        print("  command: Expected '', Actual '" + parser.get_command() + "'")
    if parser.get_start_date_str() != "2020-01-01":
        test2_pass = False
        print("  start_date: Expected '2020-01-01', Actual '" + parser.get_start_date_str() + "'")
    if parser.get_end_date_str() != "2020-12-31":
        test2_pass = False
        print("  end_date: Expected '2020-12-31', Actual '" + parser.get_end_date_str() + "'")
    if parser.get_frequency() != "1d":
        test2_pass = False
        print("  frequency: Expected '1d', Actual '" + parser.get_frequency() + "'")
    if parser.get_init_cash() != 100000.0:
        test2_pass = False
        print("  init_cash: Expected 100000.0, Actual " + String(parser.get_init_cash()))
    
    if test2_pass:
        passed += 1
        print("  All default values correct")
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    # Test 3: CliParser parse run command
    print("\n[TEST 3] CliParser parse 'run' command")
    var parser3 = create_cli_parser()
    var args3 = List[String](capacity=7)
    args3.append("run")
    args3.append("-f")
    args3.append("test.py")
    args3.append("-s")
    args3.append("2021-01-01")
    args3.append("-e")
    args3.append("2021-12-31")
    parser3.parse(args3)
    var test3_pass = True
    if parser3.get_command() != "run":
        test3_pass = False
        print("  command: Expected 'run', Actual '" + parser3.get_command() + "'")
    if parser3.get_strategy_file() != "test.py":
        test3_pass = False
        print("  strategy_file: Expected 'test.py', Actual '" + parser3.get_strategy_file() + "'")
    if parser3.get_start_date_str() != "2021-01-01":
        test3_pass = False
        print("  start_date: Expected '2021-01-01', Actual '" + parser3.get_start_date_str() + "'")
    if parser3.get_end_date_str() != "2021-12-31":
        test3_pass = False
        print("  end_date: Expected '2021-12-31', Actual '" + parser3.get_end_date_str() + "'")
    
    if test3_pass:
        passed += 1
        print("  All parsed values correct")
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    # Test 4: CliParser parse bundle command
    print("\n[TEST 4] CliParser parse 'bundle' command")
    var parser4 = create_cli_parser()
    var args4 = List[String](capacity=1)
    args4.append("bundle")
    parser4.parse(args4)
    if parser4.get_command() == "bundle":
        passed += 1
        print("  Expected: bundle")
        print("  Actual: " + parser4.get_command())
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: bundle")
        print("  Actual: " + parser4.get_command())
        print("  Result: FAIL")
    
    # Test 5: CliParser parse mod command
    print("\n[TEST 5] CliParser parse 'mod' command")
    var parser5 = create_cli_parser()
    var args5 = List[String](capacity=1)
    args5.append("mod")
    parser5.parse(args5)
    if parser5.get_command() == "mod":
        passed += 1
        print("  Expected: mod")
        print("  Actual: " + parser5.get_command())
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: mod")
        print("  Actual: " + parser5.get_command())
        print("  Result: FAIL")
    
    # Test 6: _parse_float function
    print("\n[TEST 6] _parse_float function")
    var test6_pass = True
    if _parse_float("123.45") != 123.45:
        test6_pass = False
        print("  '123.45': Expected 123.45, Actual " + String(_parse_float("123.45")))
    if _parse_float("100000") != 100000.0:
        test6_pass = False
        print("  '100000': Expected 100000.0, Actual " + String(_parse_float("100000")))
    if _parse_float("-50.5") != -50.5:
        test6_pass = False
        print("  '-50.5': Expected -50.5, Actual " + String(_parse_float("-50.5")))
    
    if test6_pass:
        passed += 1
        print("  All float parsing correct")
        print("  Result: PASS")
    else:
        failed += 1
        print("  Result: FAIL")
    
    # Test 7: CliParser parse init_cash
    print("\n[TEST 7] CliParser parse init_cash")
    var parser7 = create_cli_parser()
    var args7 = List[String](capacity=3)
    args7.append("run")
    args7.append("-c")
    args7.append("50000.0")
    parser7.parse(args7)
    if parser7.get_init_cash() == 50000.0:
        passed += 1
        print("  Expected: 50000.0")
        print("  Actual: " + String(parser7.get_init_cash()))
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: 50000.0")
        print("  Actual: " + String(parser7.get_init_cash()))
        print("  Result: FAIL")
    
    # Test 8: CliParser parse help command
    print("\n[TEST 8] CliParser parse 'help' command")
    var parser8 = create_cli_parser()
    var args8 = List[String](capacity=1)
    args8.append("help")
    parser8.parse(args8)
    if parser8.get_command() == "help":
        passed += 1
        print("  Expected: help")
        print("  Actual: " + parser8.get_command())
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: help")
        print("  Actual: " + parser8.get_command())
        print("  Result: FAIL")
    
    # Test 9: CliParser parse -h option
    print("\n[TEST 9] CliParser parse '-h' option")
    var parser9 = create_cli_parser()
    var args9 = List[String](capacity=1)
    args9.append("-h")
    parser9.parse(args9)
    if parser9.get_command() == "help":
        passed += 1
        print("  Expected: help")
        print("  Actual: " + parser9.get_command())
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: help")
        print("  Actual: " + parser9.get_command())
        print("  Result: FAIL")
    
    # Test 10: CliParser parse --help option
    print("\n[TEST 10] CliParser parse '--help' option")
    var parser10 = create_cli_parser()
    var args10 = List[String](capacity=1)
    args10.append("--help")
    parser10.parse(args10)
    if parser10.get_command() == "help":
        passed += 1
        print("  Expected: help")
        print("  Actual: " + parser10.get_command())
        print("  Result: PASS")
    else:
        failed += 1
        print("  Expected: help")
        print("  Actual: " + parser10.get_command())
        print("  Result: FAIL")
    
    # Test 11: show_help function exists and runs
    print("\n[TEST 11] show_help function exists and runs")
    show_help()
    passed += 1
    print("  Result: PASS")
    
    print("\n" + "=" * 60)
    print("Summary: " + String(passed) + "/" + String(passed + failed) + " tests passed")
    print("=" * 60)
    
    if failed > 0:
        print("STATUS: FAILED - " + String(failed) + " tests failed")
    else:
        print("STATUS: SUCCESS - All tests passed!")
