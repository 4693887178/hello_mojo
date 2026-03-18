"""
RQAlpha Mojo - Internationalization
Ported from rqalpha/utils/i18n.py
Uses Python json module for loading translations, Mojo native for other logic
"""

from collections import Dict
from os import getenv
from os.path import exists
from python import Python
from rqmojo.utils.logger import system_log


@fieldwise_init
struct I18n(Movable):
    var locale: String
    var translations: Dict[String, Dict[String, String]]

    fn gettext(self, message: String) -> String:
        return message

    fn gettext_with_locale(self, message: String, locale: String) -> String:
        return message


struct Localization(Movable):
    var translations: Dict[String, String]
    var _initialized: Bool
    var _locale: String

    fn __init__(out self):
        self._initialized = False
        self._locale = "en"
        self.translations = Dict[String, String]()

    fn _get_sys_locale(self) -> String:
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

    fn _ensure_init(mut self):
        if self._initialized:
            return
        
        self._locale = self._get_sys_locale()
        self._load_translations()
        self._initialized = True

    fn _load_translations(mut self):
        var locale_lower = self._locale.lower()
        if "cn" not in locale_lower:
            return
        
        var json_path = "rqmojo/utils/translations/zh_Hans_CN/LC_MESSAGES/messages.json"
        
        if not exists(json_path):
            return
        
        try:
            self._load_json_file(json_path)
        except:
            system_log().debug("Failed to load translation file")

    fn _load_json_file(mut self, json_path: String) raises:
        var json_module = Python().import_module("json")
        var builtins = Python().import_module("builtins")
        
        var f = builtins.open(json_path, "r")
        var content = f.read()
        f.close()
        
        var json_dict = json_module.loads(content)
        
        for key in json_dict.keys():
            var key_str = String(key)
            var value = json_dict[key]
            var value_str = String(value)
            self.translations[key_str] = value_str

    fn _set_locale(mut self, lc: String):
        self._locale = lc
        self.translations = Dict[String, String]()
        self._load_translations()
        self._initialized = True

    fn gettext(mut self, message: String) -> String:
        self._ensure_init()
        
        var result = self.translations.get(message, "")
        if len(result) > 0:
            return result
        
        return message


fn gettext(message: String) -> String:
    var localization = Localization()
    return localization.gettext(message)


fn gettext(message: String, locale: String) -> String:
    return message


fn set_locale(locale: String):
    pass


fn set_locale():
    pass


fn get_locale() -> String:
    return "zh_CN"
