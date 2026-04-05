"""
RQAlpha Mojo - Internationalization
Ported from rqalpha/utils/i18n.py

Design Philosophy (matching Python's gettext approach):
  Python uses GNU gettext: translation() reads .mo binary at init time,
  builds an internal hash table, then gettext(msg) is O(1) lookup.
  No manual file parsing in the hot path.

  Mojo equivalent: all 233 translation strings are comptime String constants
  (defined in i18n_translations.mojo), embedded in the binary at compile time.
  build_zh_cn_translations() assembles them into a Dict — zero runtime parsing,
  zero file I/O, zero JSON dependency, zero Python interop.

Singleton Pattern (Mojo 0.26.2 compatible):
  Uses process-level environment variables (std.os.setenv/getenv)
  as the backing store for locale state.
"""

from std.collections import Dict
from std.os import getenv, setenv
from rqmojo.utils.i18n_translations import build_zh_cn_translations
from rqmojo.utils.logger import system_log


struct Localization(Movable):
    var translations: Dict[String, String]
    var _locale: String

    def __init__(out self):
        self._locale = "en"
        self.translations = Dict[String, String]()

    def __init__(out self, lc: String):
        self._locale = lc
        self.translations = Dict[String, String]()
        self._load_translations()

    @staticmethod
    def get_sys_locale() -> String:
        var lang = getenv("LANG")
        if len(lang) > 0:
            var parts = lang.split(".")
            if len(parts) > 0:
                return String(parts[0])
            return lang

        var lc_ctype = getenv("LC_CTYPE")
        if len(lc_ctype) > 0:
            var parts = lc_ctype.split(".")
            if len(parts) > 0:
                return String(parts[0])
            return lc_ctype

        return "en"

    def _load_translations(mut self):
        var locale_lower = self._locale.lower()
        if "cn" in locale_lower:
            self.translations = build_zh_cn_translations()
        else:
            self.translations = Dict[String, String]()

    def set_locale(mut self, lc: String):
        self._locale = lc
        self._load_translations()

    def gettext(mut self, message: String) -> String:
        var result = self.translations.get(message, "")
        if len(result) > 0:
            return result
        return message


def _get_effective_locale() -> String:
    var stored = getenv("RQMOJO_LOCALE")
    if len(stored) > 0:
        return stored
    return Localization.get_sys_locale()


def gettext(message: String) -> String:
    var loc = Localization(_get_effective_locale())
    return loc.gettext(message)


def set_locale(lc: String = ""):
    if len(lc) > 0:
        _ = setenv("RQMOJO_LOCALE", lc, True)
    else:
        var sys_lc = Localization.get_sys_locale()
        _ = setenv("RQMOJO_LOCALE", sys_lc, True)


def lazy_gettext(message: String) -> String:
    return message


def get_locale() -> String:
    var stored = getenv("RQMOJO_LOCALE")
    if len(stored) > 0:
        return stored
    return Localization.get_sys_locale()
