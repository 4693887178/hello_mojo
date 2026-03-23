"""
RQAlpha Mojo - Package Helper
Ported from rqalpha/utils/package_helper.py
"""

from python import Python, PythonObject
from rqmojo.utils.rq_logger import system_log


def import_mod(mod_name: String) raises -> PythonObject:
    try:
        return Python.import_module(mod_name)
    except:
        var separator = "*" * 30
        system_log().error(separator)
        system_log().error("Mod Import Error: " + mod_name)
        system_log().error(separator)
        raise
