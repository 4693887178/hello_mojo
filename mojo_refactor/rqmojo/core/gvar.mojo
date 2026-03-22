from std.collections import Dict, List
from utils import Variant


comptime GlobalVarValue = Variant[Bool, Int, Float64, String]


@fieldwise_init
struct GlobalVars(Movable):
    var _data: Dict[String, GlobalVarValue]

    def __init__(out self):
        self._data = Dict[String, GlobalVarValue]()

    def size(self) -> Int:
        return len(self._data)

    def is_empty(self) -> Bool:
        return len(self._data) == 0

    def has(self, key: String) -> Bool:
        try:
            _ = self._data[key]
            return True
        except:
            return False

    def remove(mut self, key: String):
        try:
            _ = self._data.pop(key)
        except:
            pass

    def clear(mut self):
        self._data = Dict[String, GlobalVarValue]()

    def keys(self) -> List[String]:
        var result = List[String]()
        for key in self._data.keys():
            result.append(key)
        return result^

    def set[T: ImplicitlyCopyable](mut self, key: String, value: T):
        self._data[key] = GlobalVarValue(value)

    def get[T: ImplicitlyCopyable](self, key: String) -> Optional[T]:
        try:
            var val = self._data[key]
            if val.isa[T]():
                return val[T]
        except:
            pass
        return None

    def get_state(self) -> List[String]:
        var result = List[String]()
        for key in self._data.keys():
            result.append(key)
        return result^

    def set_state(mut self, state: List[String]):
        pass


def create_global_vars() -> GlobalVars:
    return GlobalVars()
