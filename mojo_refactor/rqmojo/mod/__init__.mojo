"""
RQAlpha Mojo - Mod System
Ported from rqalpha/mod/__init__.py
"""

from std.collections import Dict, List
from rqmojo.const import EXIT_CODE
from rqmojo.utils.exception import CustomError


@fieldwise_init
struct ModInfo(Movable, Writable, Copyable, ImplicitlyCopyable):
    var name: String
    var version: String
    var enabled: Bool

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ModInfo(", self.name, " v", self.version, ")")


trait Mod:
    def start_up(mut self) -> None: ...
    def tear_down(mut self, code: EXIT_CODE, exception: Optional[CustomError]) -> Dict[String, String]: ...
    def get_name(self) -> String: ...


@fieldwise_init
struct ModHandler(Movable, Writable):
    var _mod_count: Int
    var _env: String
    var _started: Bool
    var _mod_list: List[ModInfo]

    def __init__(out self):
        self._mod_count = 0
        self._env = ""
        self._started = False
        self._mod_list = List[ModInfo]()
        self._mod_list.append(ModInfo(name="transaction_cost", version="0.1.0", enabled=True))
        self._mod_list.append(ModInfo(name="scheduler", version="0.1.0", enabled=True))
        self._mod_list.append(ModInfo(name="analyser", version="0.1.0", enabled=True))
        self._mod_list.append(ModInfo(name="progress", version="0.1.0", enabled=True))
        self._mod_list.append(ModInfo(name="simulation", version="0.1.0", enabled=True))
        self._mod_list.append(ModInfo(name="risk", version="0.1.0", enabled=True))
        self._mod_list.append(ModInfo(name="accounts", version="0.1.0", enabled=True))
        self._mod_count = 7

    def write_to(self, mut writer: Some[Writer]):
        writer.write("ModHandler(mods=", String(self._mod_count), ")")

    def set_env(mut self, env: String) -> None:
        self._env = env

    def start_up(mut self) -> None:
        self._started = True

    def tear_down(mut self, code: EXIT_CODE, exception: Optional[CustomError] = Optional[CustomError](None)) raises -> Dict[String, String]:
        var result = Dict[String, String]()
        self._started = False
        return result^

    def add_mod(mut self, name: String) -> None:
        self._mod_count += 1
        self._mod_list.append(ModInfo(name=name, version="1.0.0", enabled=True))

    def get_mod_count(self) -> Int:
        return self._mod_count

    def is_started(self) -> Bool:
        return self._started

    def get_mod_list(self) -> List[ModInfo]:
        return self._mod_list.copy()

    def get_mod(self, name: String) -> Optional[ModInfo]:
        for mod in self._mod_list:
            if mod.name == name:
                return mod
        return None

    def register_mod(mut self, mod: ModInfo) -> None:
        self._mod_list.append(mod)
        self._mod_count += 1

    def unregister_mod(mut self, name: String) -> Bool:
        var found = False
        var new_list = List[ModInfo]()
        for mod in self._mod_list:
            if mod.name != name:
                new_list.append(mod)
            else:
                found = True
        self._mod_list = new_list^
        if found:
            self._mod_count -= 1
        return found


def create_mod_handler() -> ModHandler:
    return ModHandler()


def get_system_mod_list() -> List[ModInfo]:
    var handler = create_mod_handler()
    return handler.get_mod_list()


def get_system_mod(name: String) -> Optional[ModInfo]:
    var handler = create_mod_handler()
    return handler.get_mod(name)


def register_mod(mod: ModInfo) -> None:
    pass


def unregister_mod(name: String) -> Bool:
    return True
