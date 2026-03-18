"""
RQAlpha Mojo - Command Line Interface
Ported from rqalpha/cmds/entry.py
"""

from rqmojo.const import RUN_TYPE, EXIT_CODE
from rqmojo.main import RQAlpha, RQAlphaConfig, create_config
from rqmojo.utils.datetime_func import DateTime, Date


@fieldwise_init
struct CliParser(Movable):
    var _command: String
    var _start_date_str: String
    var _end_date_str: String
    var _strategy_file: String
    var _frequency: String
    var _init_cash: Float64
    
    fn parse(mut self, args: List[String]) -> None:
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
                    self._init_cash = float(args[i])
            i += 1
    
    fn get_command(self) -> String:
        return self._command
    
    fn get_start_date(self) -> DateTime:
        return DateTime(2020, 1, 1, 0, 0, 0, 0)
    
    fn get_end_date(self) -> DateTime:
        return DateTime(2020, 12, 31, 0, 0, 0, 0)
    
    fn get_strategy_file(self) -> String:
        return self._strategy_file
    
    fn get_frequency(self) -> String:
        return self._frequency
    
    fn get_init_cash(self) -> Float64:
        return self._init_cash


fn create_cli_parser() -> CliParser:
    return CliParser(
        _command="run",
        _start_date_str="2020-01-01",
        _end_date_str="2020-12-31",
        _strategy_file="",
        _frequency="1d",
        _init_cash=100000.0
    )


@fieldwise_init
struct CliRunner(Movable):
    var _parser: CliParser
    
    fn run(mut self, args: List[String]) -> Int:
        self._parser.parse(args)
        
        var command = self._parser.get_command()
        
        if command == "run":
            print("=== RQAlpha Mojo Backtest ===")
            print("Strategy: ", self._parser.get_strategy_file())
            print("Start Date: ", self._parser._start_date_str)
            print("End Date: ", self._parser._end_date_str)
            print("Frequency: ", self._parser.get_frequency())
            print("Init Cash: ", self._parser.get_init_cash())
            
            from rqmojo.cmds.run import run_strategy
            var start_date = self._parser.get_start_date()
            var end_date = self._parser.get_end_date()
            var result = run_strategy(
                self._parser.get_strategy_file(),
                start_date,
                end_date,
                self._parser.get_frequency(),
                self._parser.get_init_cash()
            )
            return result
        elif command == "bundle":
            print("Bundle command...")
            return 0
        elif command == "mod":
            print("Mod command...")
            return 0
        else:
            print("Unknown command: ", command)
            print("Available commands: run, bundle, mod")
            return 1


fn create_cli_runner() -> CliRunner:
    return CliRunner(_parser=create_cli_parser())


fn run_cli(args: List[String]) -> Int:
    var runner = create_cli_runner()
    return runner.run(args)
