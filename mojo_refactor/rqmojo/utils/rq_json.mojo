"""
RQAlpha Mojo - JSON Utilities
Ported from rqalpha/utils/rq_json.py
Uses Python simplejson module
"""

from std.python import Python, PythonObject
from std.collections import List


comptime __all__: List[String] = [
    "convert_dict_to_json",
    "convert_json_to_dict",
]


def convert_dict_to_json(dict_obj: PythonObject) raises -> String:
    var json = Python.import_module("simplejson")
    var builtins = Python.import_module("builtins")
    
    var code = "def _encode(obj):\n    import datetime\n    from rqalpha import const\n    if isinstance(obj, datetime.datetime):\n        return {'__datetime__': True, 'as_str': obj.strftime('%Y%m%dT%H:%M:%S.%f')}\n    elif isinstance(obj, datetime.date):\n        return {'__date__': True, 'as_str': obj.strftime('%Y%m%d')}\n    elif isinstance(obj, const.CustomEnum):\n        return {'__enum__': True, 'as_str': str(obj)}\n    else:\n        raise TypeError('Unserializable object {} of type {}'.format(obj, type(obj)))"
    
    var ns = Python.dict()
    builtins.exec(code, ns)
    var encode_func = ns["_encode"]
    
    var result = json.dumps(dict_obj, default=encode_func)
    return String(result)


def convert_json_to_dict(json_str: String) raises -> PythonObject:
    var json = Python.import_module("simplejson")
    var builtins = Python.import_module("builtins")
    
    var code = "def _decode(obj):\n    import datetime\n    from rqalpha import const\n    if '__datetime__' in obj:\n        return datetime.datetime.strptime(obj['as_str'], '%Y%m%dT%H:%M:%S.%f')\n    elif '__date__' in obj:\n        return datetime.datetime.strptime(obj['as_str'], '%Y%m%d').date()\n    elif '__enum__' in obj:\n        e, v = obj['as_str'].split('.')\n        return getattr(getattr(const, e), v)\n    return obj"
    
    var ns = Python.dict()
    builtins.exec(code, ns)
    var decode_func = ns["_decode"]
    
    var result = json.loads(json_str, object_hook=decode_func)
    return result
