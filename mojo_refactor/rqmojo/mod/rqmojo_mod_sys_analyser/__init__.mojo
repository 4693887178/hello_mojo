"""
RQAlpha Mojo - System Analyser Module
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/__init__.py
"""

from python import click
from rqmojo.utils.i18n import gettext as _
from rqmojo import cli, inject_run_param


alias __config__ = {
    "benchmark": None,
    "record": True,
    "strategy_name": None,
    "output_file": None,
    "report_save_path": None,
    "plot": False,
    "plot_save_file": None,
    "plot_config": {
        "open_close_points": False,
        "weekly_indicators": False
    },
}


fn load_mod() -> object:
    from .mod import AnalyserMod
    return AnalyserMod()


var cli_prefix = "mod__sys_analyser__"
