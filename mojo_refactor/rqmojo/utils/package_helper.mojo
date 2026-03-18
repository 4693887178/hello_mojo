"""
RQAlpha Mojo - Package Helper
Ported from rqalpha/utils/package_helper.py
"""

from rqmojo.utils.logger import system_log


fn import_mod(mod_name: String) -> object:
    try:
        return __import__(mod_name)
    except:
        system_log.error("Mod Import Error: " + mod_name)
        raise
