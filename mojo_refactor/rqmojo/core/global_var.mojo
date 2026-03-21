"""
RQAlpha Mojo - Global Variables Module
Ported from rqalpha/core/global_var.py
"""

from std.collections import Dict
from python import Python


@fieldwise_init
struct GlobalVars(Movable):
    var _data: Dict[String, object]
    
    def __init__(out self):
        self._data = Dict[String, object]()
    
    def get_state(self) -> object:
        return Python.serialize(self._data)
    
    def set_state(self, state: object) -> None:
        var loaded = Python.deserialize(state)
        if loaded != None:
            self._data = loaded
    
    def get(self, key: String, default: object = None) -> object:
        if self._data.contains(key):
            return self._data[key]
        return default
    
    def set(self, key: String, value: object) -> None:
        self._data[key] = value
    
    def contains(self, key: String) -> Bool:
        return self._data.contains(key)
    
    def remove(self, key: String) -> Bool:
        if self._data.contains(key):
            self._data.remove(key)
            return True
        return False
    
    def keys(self) -> List[String]:
        return self._data.keys()
    
    def clear(self) -> None:
        self._data.clear()


def create_global_vars() -> GlobalVars:
    return GlobalVars()


def main():
    print("global_var.mojo - Global variables module loaded successfully")
