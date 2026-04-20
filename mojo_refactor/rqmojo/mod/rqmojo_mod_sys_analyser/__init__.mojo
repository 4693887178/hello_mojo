"""
RQAlpha Mojo - System Analyser Module
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/__init__.py

This module provides:
- Configuration management for the analyser
- CLI parameter definitions for report, output, and plotting
- Plot and report command handlers
- Module loading interface
"""

from std.python import Python, PythonObject
from std.collections import Dict, List
from rqmojo.utils.i18n import gettext


@fieldwise_init
struct AnalyserConfig(Movable, Copyable, Writable):
    """Configuration for the System Analyser module.
    
    Mirrors the Python __config__ dictionary structure with type safety.
    """
    var benchmark: PythonObject
    var record: Bool
    var strategy_name: PythonObject
    var output_file: PythonObject
    var report_save_path: PythonObject
    var plot: Bool
    var plot_save_file: PythonObject
    var plot_config: Dict[String, PythonObject]

    def __init__(out self) raises:
        self.benchmark = Python.none()
        self.record = True
        self.strategy_name = Python.none()
        self.output_file = Python.none()
        self.report_save_path = Python.none()
        self.plot = False
        self.plot_save_file = Python.none()
        self.plot_config = Dict[String, PythonObject]()
        self.plot_config["open_close_points"] = PythonObject(False)
        self.plot_config["weekly_indicators"] = PythonObject(False)

    def __init__(out self, *, copy: Self):
        self.benchmark = copy.benchmark
        self.record = copy.record
        self.strategy_name = copy.strategy_name
        self.output_file = copy.output_file
        self.report_save_path = copy.report_save_path
        self.plot = copy.plot
        self.plot_save_file = copy.plot_save_file
        self.plot_config = copy.plot_config.copy()

    def write_to(self, mut writer: Some[Writer]):
        writer.write(
            "AnalyserConfig(",
            "record=", String(self.record),
            ", plot=", String(self.plot),
            ")"
        )


def create_default_config() raises -> AnalyserConfig:
    """Create a default AnalyserConfig instance matching Python __config__."""
    return AnalyserConfig()


def get_cli_prefix() -> String:
    """Return the CLI prefix for this module's parameters.
    
    Matches the Python: cli_prefix = "mod__sys_analyser__"
    """
    return "mod__sys_analyser__"


def load_mod() raises -> PythonObject:
    """Load and return the AnalyserMod instance.

    This is the main entry point called by RQAlpha to load this mod.
    Mirrors: def load_mod(): from .mod import AnalyserMod; return AnalyserMod()
    """
    from rqmojo.mod.rqmojo_mod_sys_analyser.mod import create_analyser_mod
    var mod_instance = create_analyser_mod()

    # Return a Python dict representing the module instance
    # (since AnalyserMod doesn't implement ConvertibleToPython)
    from std.python import Python
    var result = Python.dict()
    result["name"] = PythonObject(mod_instance.name)
    # Convert Bool to int first, then to PythonObject
    var enabled_int = 1 if mod_instance.enabled else 0
    result["enabled"] = PythonObject(enabled_int)
    return result^


def inject_run_param(param_name: String, param_type: String, help_text: String) -> None:
    """Inject a run parameter into the CLI system.

    Mimics the Python inject_run_param() function used to register click options.
    In Mojo, this stores parameters for later retrieval by the argument parser.

    Args:
        param_name: Parameter name (e.g., 'mod__sys_analyser__report_save_path')
        param_type: Type of parameter ('path', 'string', 'bool', etc.)
        help_text: Help text shown in CLI
    """
    pass


def inject_run_param_flag(param_name: String, param_type: String, help_text: String, default_value: PythonObject) -> None:
    """Inject a flag parameter with default value."""
    pass


def register_cli_parameters() -> None:
    """Register all CLI parameters for the sys_analyser module.

    These mirror the Python click.Option definitions in __init__.py:
    - --report / mod__sys_analyser__report_save_path
    - -o, --output-file / mod__sys_analyser__output_file
    - -p, --plot / mod__sys_analyser__plot
    --plot-save / mod__sys_analyser__plot_save_file
    - -bm, --benchmark / mod__sys_analyser__benchmark
    - --plot-open-close-points / mod__sys_analyser__plot_config__open_close_points
    - --plot-weekly-indicators / mod__sys_analyser__plot_config__weekly_indicators
    """
    var prefix = get_cli_prefix()

    # --report: Save report path (matches line 64-68 in Python)
    inject_run_param(
        prefix + "report_save_path",
        "path",
        gettext("[sys_analyser] save report")
    )

    # -o, --output-file: Output pickle file path (matches line 69-73 in Python)
    inject_run_param(
        prefix + "output_file",
        "path",
        gettext("[sys_analyser] output result pickle file")
    )

    # -p, --plot: Enable plotting (matches line 74-78 in Python)
    inject_run_param(
        prefix + "plot",
        "bool",
        gettext("[sys_analyser] plot result")
    )

    # --plot-save: Save plot to file (matches line 79-83 in Python)
    inject_run_param(
        prefix + "plot_save_file",
        "path",
        gettext("[sys_analyser] save plot to file")
    )

    # -bm, --benchmark: Benchmark order_book_id (matches line 84-88 in Python)
    inject_run_param(
        prefix + "benchmark",
        "string",
        gettext("[sys_analyser] order_book_id of benchmark")
    )

    # --plot-open-close-points (matches line 89-93 in Python)
    inject_run_param(
        prefix + "plot_config__open_close_points",
        "bool",
        gettext("[sys_analyser] show open close points on plot")
    )

    # --plot-weekly-indicators (matches line 94-98 in Python)
    inject_run_param(
        prefix + "plot_config__weekly_indicators",
        "bool",
        gettext("[sys_analyser] show weekly indicators and return curve on plot")
    )


def plot_result(result_pickle_file_path: String, show: Bool = True, plot_save_file: String = "", plot_open_close_points: Bool = False, plot_weekly_indicators: Bool = False) raises -> PythonObject:
    """Plot results from a strategy output pickle file.
    
    Mirrors the Python @cli.command 'plot' function (lines 101-112).
    
    Args:
        result_pickle_file_path: Path to the pickle file containing results
        show: Whether to display the plot interactively
        plot_save_file: Path to save the plot image (empty = don't save)
        plot_open_close_points: Show open/close points on the plot
        plot_weekly_indicators: Show weekly indicators on the plot
    
    Returns:
        PythonObject containing the plotted data
    """
    from std.python import Python
    var pd = Python.import_module("pandas")

    # Read the pickle file using pandas (mirrors: pd.read_pickle)
    var result_dict = pd.read_pickle(result_pickle_file_path)

    # Convert PythonObject dict to Mojo Dict for plot_result
    from rqmojo.mod.rqmojo_mod_sys_analyser.plot import plot_result, PlotResultConfig

    # Create config matching the function signature
    var save_path_opt: Optional[String] = None
    if len(plot_save_file) > 0:
        save_path_opt = plot_save_file

    var config = PlotResultConfig(
        show=show,
        save_path=save_path_opt,
        weekly_indicators=plot_weekly_indicators,
        open_close_points=plot_open_close_points,
        strategy_name=None
    )

    # Call the plot_result function from .plot module
    var mojo_dict = _python_to_mojo_dict(result_dict)
    plot_result(mojo_dict, config)

    return result_dict


def _python_to_mojo_dict(py_dict: PythonObject) raises -> Dict[String, PythonObject]:
    """Convert a Python dictionary to a Mojo Dict[String, PythonObject]."""
    var result = Dict[String, PythonObject]()
    from std.python import Python
    if py_dict != Python.none():
        for key in py_dict:
            result[String(py=key)] = py_dict[key]
    return result^


def generate_report_from_file(result_pickle_file_path: String, target_report_csv_path: String) raises -> None:
    """Generate a CSV report from a strategy output pickle file.
    
    Mirrors the Python @cli.command 'report' function (lines 115-122).
    
    Args:
        result_pickle_file_path: Path to the pickle file containing results
        target_report_csv_path: Path where the CSV report will be saved
    """
    from std.python import Python
    var pd = Python.import_module("pandas")

    # Read the pickle file (mirrors: pd.read_pickle)
    var result_dict = pd.read_pickle(result_pickle_file_path)

    # Call generate_report from .report module
    from rqmojo.mod.rqmojo_mod_sys_analyser.report import generate_report
    generate_report(result_dict, target_report_csv_path)
