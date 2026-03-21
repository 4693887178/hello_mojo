"""
RQAlpha Mojo - Global Variables Module
Ported from rqalpha/core/global_var.py
"""

from std.collections import Dict, List
from python import Python, PythonObject


@fieldwise_init
struct GlobalVars(Movable):
    var _data: Dict[String, PythonObject]
    
    def __init__(out self):
        self._data = Dict[String, PythonObject]()
    
    def get_state(self) -> PythonObject:
        return Python.serialize(self._data)
    
    def set_state(self, state: PythonObject) -> None:
        var loaded = Python.deserialize(state)
        if loaded != None:
            self._data = loaded
    
    def get(self, key: String, default: PythonObject = None) -> PythonObject:
        try:
            return self._data[key]
        except:
            return default
    
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


def main():
    print("global_var.mojo - Global variables module loaded successfully")
