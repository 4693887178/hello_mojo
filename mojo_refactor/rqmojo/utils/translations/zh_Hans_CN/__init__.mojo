"""
RQAlpha Mojo - Chinese Simplified Translations
"""

fn get_translation(key: String) -> String:
    var translations = Dict[String, String]()
    translations["error"] = "错误"
    translations["warning"] = "警告"
    translations["info"] = "信息"
    if translations.contains(key):
        return translations[key]
    return key
