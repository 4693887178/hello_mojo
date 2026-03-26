"""
RQAlpha Mojo - System Analyser Module
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/__init__.py
"""

from python import PythonObject
from rqmojo.utils.i18n import gettext
from std.collections import Dict


struct AnalyserConfig:
    var benchmark: PythonObject
    var record: Bool
    var strategy_name: PythonObject
    var output_file: PythonObject
    var report_save_path: PythonObject
    var plot: Bool
    var plot_save_file: PythonObject
    var plot_config: Dict[String, Bool]

    fn __init__(out self) raises:
        self.benchmark = None
        self.record = True
        self.strategy_name = None
        self.output_file = None
        self.report_save_path = None
        self.plot = False
        self.plot_save_file = None
        self.plot_config = Dict[String, Bool]()
        try:
            self.plot_config["open_close_points"] = False
            self.plot_config["weekly_indicators"] = False
        except:
            pass

    fn __init__(out self, *, deinit take: Self):
        self.benchmark = take.benchmark
        self.record = take.record
        self.strategy_name = take.strategy_name
        self.output_file = take.output_file
        self.report_save_path = take.report_save_path
        self.plot = take.plot
        self.plot_save_file = take.plot_save_file
        self.plot_config = take.plot_config^


fn create_config() raises -> AnalyserConfig:
    return AnalyserConfig()


fn get_cli_prefix() -> String:
    return "mod__sys_analyser__"
