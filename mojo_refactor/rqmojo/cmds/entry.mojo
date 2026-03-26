"""
RQAlpha Mojo - Command Line Interface
Ported from rqalpha/cmds/entry.py
"""

from std.collections import List, Dict
from rqmojo.const import EXIT_CODE


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
            elif arg == "help" or arg == "-h" or arg == "--help":
                self._command = "help"
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


@fieldwise_init
struct CliRunner(Movable):
    var _parser: CliParser
    
    def run(mut self, args: List[String]) -> Int:
        self._parser.parse(args)
        
        var command = self._parser.get_command()
        
        if command == "help" or command == "-h" or command == "--help":
            show_help()
            return 0
        elif command == "run":
            print("=== RQAlpha Mojo Backtest ===")
            print("Strategy: ", self._parser.get_strategy_file())
            print("Start Date: ", self._parser.get_start_date_str())
            print("End Date: ", self._parser.get_end_date_str())
            print("Frequency: ", self._parser.get_frequency())
            print("Init Cash: ", self._parser.get_init_cash())
            return 0
        elif command == "bundle":
            print("Bundle command...")
            return 0
        elif command == "mod":
            print("Mod command...")
            return 0
        elif command == "":
            show_help()
            return 0
        else:
            print("Unknown command: ", command)
            print("Available commands: run, bundle, mod")
            print("Use -h or --help for more information")
            return 1


def create_cli_runner() -> CliRunner:
    return CliRunner(_parser=create_cli_parser())


def run_cli(args: List[String]) -> Int:
    var runner = create_cli_runner()
    return runner.run(args)


def inject_mod_commands() -> None:
    """
    Inject mod commands into CLI.
    In Python, this function dynamically adds mod commands to the CLI.
    In Mojo, we provide a placeholder implementation.
    """
    pass


def cli(obj: Dict[String, String] = Dict[String, String]()) -> None:
    """
    Main CLI entry point.
    In Python, this is a Click group.
    In Mojo, we provide a simplified implementation.
    """
    show_help()
