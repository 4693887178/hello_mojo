"""
RQAlpha Mojo - Chinese Simplified Translations
"""

from std.collections import Dict


def get_translation(key: String) raises -> String:
    var translations = Dict[String, String]()
    translations["error"] = "错误"
    translations["warning"] = "警告"
    translations["info"] = "信息"
    if translations.__contains__(key):
        return translations[key]
    return key
