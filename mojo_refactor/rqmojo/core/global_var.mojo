"""
RQAlpha Mojo - Global Variables Module
Ported from rqalpha/core/global_var.py
"""

from std.collections import Dict, List
from std.python import Python, PythonObject


@fieldwise_init
struct GlobalVars(Movable):
    var _data: Dict[String, PythonObject]
    
    def __init__(out self):
        self._data = Dict[String, PythonObject]()
    
    def get_state(self) raises -> PythonObject:
        var pickle = Python.import_module("pickle")
        var dict_data = Python.dict()
        for key in self._data.keys():
            var value = self._data[key]
            try:
                dict_data[key] = pickle.dumps(value)
            except:
                pass
        return pickle.dumps(dict_data)
    
    def set_state(mut self, state: PythonObject) raises:
        var pickle = Python.import_module("pickle")
        var dict_data = pickle.loads(state)
        var builtins = Python.import_module("builtins")
        var keys_py = builtins.list(dict_data.keys())
        var n = Int(py=len(keys_py))
        for idx in range(n):
            var key = String(py=keys_py[idx])
            var value = dict_data[key]
            try:
                self._data[key] = pickle.loads(value)
            except:
                pass
    
    def get(self, key: String) -> PythonObject:
        try:
            return self._data[key]
        except:
            return Python.none()
    
    def set(mut self, key: String, value: PythonObject) -> None:
        self._data[key] = value
    
    def contains(self, key: String) -> Bool:
        try:
            _ = self._data[key]
            return True
        except:
            return False
    
    def remove(mut self, key: String) -> Bool:
        try:
            _ = self._data.pop(key)
            return True
        except:
            return False
    
    def keys(self) -> List[String]:
        var result = List[String]()
        for key in self._data.keys():
            result.append(key)
        return result^
    
    def clear(mut self) -> None:
        self._data = Dict[String, PythonObject]()


def create_global_vars() -> GlobalVars:
    return GlobalVars()
